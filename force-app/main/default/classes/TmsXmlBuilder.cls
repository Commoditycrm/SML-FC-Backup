/**
 * @author RadialSpark
 * @date 05-24-2018
 * @description XML Builder for POST to TMS
 * @changelog
	05-24-2018 - Bradley Wong - Created
	06-01-2018 - Bradley Wong - generalized for use in building Order XML
	06-05-2018 - Bradley Wong - added specific fields to build Loads and Requests within the same XML Body
	11-05-2018 - Jeffrey Underdown - fix null pointer,
 */

public class TmsXmlBuilder {

	// new SObject passed in from TmsIntegrationService
	private SObject obj;

	// name of the root element ('LoadData')
	private String rootElement;

	// names of nodes that are on the highest level of XML
	private Set<String> rootNodes;

	// set of values that are manually set
	private Set<String> calculatedValues;

	// map of nodes that contain child nodes for this object
	private Map<String, List<String>> nodesWithChildNodes;

	// map of nodes to default values
	private Map<String, String> defaultValues;

	// map of TMS Fields to SF Fields for this SObject
	private Map<String, String> tmsFieldsToSfFields;


	// configuration information for XML Schema
	private final String PREFIX = 'ns2';
	private final String TMS_NS = 'http://schemas.3gtms.com/tms/v1/tns';
	private final String XSI = 'http://www.w3.org/2001/XMLSchema-instance';
 

	/**
	 * @description constructor that sets the object, root element, root node, and field mapper based on object type
	 */
	public TmsXmlBuilder(SObject obj, String sobjectType, Map<String, String> tmsValueMapper) {
		// handle xml builds for sObjects
		this.obj = obj;
        System.debug('OBJ IN TMS XML BUILDER: ' + this.obj);
		this.tmsFieldsToSfFields = tmsValueMapper;

		if (sobjectType == ConstantsUtility.LOADS) {
			this.rootElement = ConstantsUtility.LOADS;
			this.rootNodes = ConstantsUtility.BOL_ROOT_NODES;
			this.defaultValues = ConstantsUtility.BOL_DEFAULT_VALUES;
			this.calculatedValues = ConstantsUtility.BOL_CALCULATED_VALUES;
			this.nodesWithChildNodes = ConstantsUtility.BOL_NODES_WITH_CHILD_NODES;
		}
	}

	/**
	 * @description constructor used when building XML Strings for non-SObjects
	 */
	public TmsXmlBuilder(String objectType, Map<String, String> tmsValueMapper) {
		this.tmsFieldsToSfFields = tmsValueMapper;

		if (objectType == ConstantsUtility.TRADING_PARTNER) {
			this.rootElement = ConstantsUtility.TRADING_PARTNER;
			this.rootNodes = ConstantsUtility.TRADING_PARTNER_ROOT_NODES;
			this.defaultValues = ConstantsUtility.TRADING_PARTNER_DEFAULT_VALUES;
			this.calculatedValues = ConstantsUtility.TRADING_PARTNER_CALCULATED_VALUES;
			this.nodesWithChildNodes = ConstantsUtility.TRADING_PARTNER_NODES_WITH_CHILD_NODES;
		}
	}


	/**
	 * @description method that creates a DOM Document and adds appropriate XML nodes to build XML String
	 *  that will be posted to TMS
	 */
	public String buildXmlString() {

		// create new DOM to build XML
		DOM.Document doc = new DOM.Document();

		// create the outer-most node and add appropriate Schema information
		DOM.XmlNode envelope = doc.createRootElement(rootElement, TMS_NS, PREFIX);
		envelope.setNamespace('xsi', XSI);

		// create child elements for all elements on the 'root' level (for BOL__c ==> Loads, Orders, Locs)
		Boolean isFirstNode = true;
		for (String rootNode : this.rootNodes) {

			// if this is the first iteration ==> do not need to walk up to parent element
			if (isFirstNode) {
				envelope.addChildElement(rootNode, null, null);
				envelope = buildChildNodes(rootNode, envelope.getChildElement(rootNode, null));

				isFirstNode = false;
			}

			// else get the parent element and create a new child element within
			else {
				envelope.getParent().addChildElement(rootNode, null, null);
				envelope = buildChildNodes(rootNode, envelope.getParent().getChildElement(rootNode, null));
			}
		}

		// return the resulting XML doc as a string
		return doc.toXmlString();

	}


	/**
	 * @description method that gets the child nodes for a parent node and adds the following if applicable:
	 *  unit of measurement attributes and values from the associated SF object
	 *  NOTE: is recursive until no more child nodes are present (determined by ConstantsUtility.NODES_WITH_CHILD_NODES)
	 */
	private DOM.XmlNode buildChildNodes(String parentNode, DOM.XmlNode node) {

		// loop through all the child nodes for the node passed in
		for (String childNode : this.nodesWithChildNodes.get(parentNode)) {

			// add the child node to the parent node
			DOM.XmlNode newChild = node.addChildElement(childNode, null, null);

			// check for an attribute (only uom values)
			if (ConstantsUtility.NODE_UNIT_OF_MEASUREMENT.containsKey(childNode)) {

				//set default value if the value is not a calculated value
				if (!this.calculatedValues.contains(childNode)) newChild.addTextNode('0.00');
				newChild.setAttribute('uom', ConstantsUtility.NODE_UNIT_OF_MEASUREMENT.get(childNode));

			}

			// handle duplicate nodes (e.g. There will be more than one Stop and each has different values)
			childNode = this.handleDuplicateNodes(childNode, parentNode);

			// see if the value was previously calculated (not an SObject field)
			if (
				this.calculatedValues.contains(childNode) &&
				this.tmsFieldsToSfFields.containsKey(childNode)
			) {

				String nodeValue = this.tmsFieldsToSfFields.get(childNode);
                if (nodeValue != null) {
                    newChild.addTextNode(nodeValue);
                }

			}

			// check if there should be a value from the SF org that should be included
			else if (this.tmsFieldsToSfFields.containsKey(childNode)) {

				// get the SF field name for this node
				String sfField = this.tmsFieldsToSfFields.get(childNode);

				// get the formatted value of this field from the SObject
				String nodeValue = this.getNodeValue(sfField);
				newChild.addTextNode(nodeValue);

			}

			// check if there should be a default value set for this node
			else if (this.defaultValues.containsKey(childNode)) {

				// get the default value of the node
				String defaultValue = this.defaultValues.get(childNode);
				newChild.addTextNode(defaultValue);

			}

			// if this child itself has more child nodes ==> pass in this node and node name
			if (this.nodesWithChildNodes.containsKey(childNode)) this.buildChildNodes(childNode, newChild);
		}

		return node;

	}


	/**
	 * @description method that will take a SF field for the object and format the object value (if required)
	 */
	private String getNodeValue(String sfField) {

		String nodeValue;

		// DateTime fields for BOL__c objects need to be formatted into yyyy-MM-ddThh:mm:ssZ format
		if (ConstantsUtility.DATE_FIELDS.contains(sfField)) {

			List<String> splitDate = DateTime.valueOf(this.obj.get(sfField)).format('yyyy-MM-dd\'T\'hh:mm:ssZ').split('-');
			nodeValue = splitDate[0] + '-' + splitDate[1] + '-' + splitDate[2] + 'Z';

		}

		// other values do not need to be formated
		else {
            System.debug('THIS OBJ: ' + this.obj);
			System.debug('SF FIELD: ' + sfField);
			if (this.obj != null) {
				nodeValue = String.valueOf(this.obj.get(sfField));
			}
			else {
				nodeValue = sfField;
			}

		}

		// return the value of the field for this object
		return nodeValue;

	}

	/**
	 * @description Handle nodes that have more than one instance in the XML file
	 *  ==> e.g. there will be multiple Stop nodes with different values
	 */
	private String handleDuplicateNodes(String childNode, String parentNode) {

		// separate pickup and delivery stops by incrementing static value
		if (
			ConstantsUtility.STOP_NODES.contains(childNode) ||
			(childNode == ConstantsUtility.LOC_NUM && parentNode == ConstantsUtility.STOP) ||
			(childNode == ConstantsUtility.TOTAL_PIECE_COUNT_PLANNED && parentNode == ConstantsUtility.STOP)
		) {
			if (childNode == ConstantsUtility.STOP_NUM) ConstantsUtility.stopNum++;

			// rename the node as Stop1 / Stop2 to get different Stop information
			childNode = childNode + ConstantsUtility.stopNum;
		}

		// separate locations by incrementing static value
		if (
			parentNode == ConstantsUtility.LOC &&
			childNode != ConstantsUtility.ORGANIZATION_NAME
		) {
			// the static count should only be incremented once per Location Node
			if (childNode == ConstantsUtility.TRADING_PARTNER_NUM) ConstantsUtility.locNum++;

			// update the childNode name (e.g. LocNum1)
			childNode = childNode + ConstantsUtility.locNum;
		}



		// separate OrderLineItems by incrementing static value
		if (
			parentNode == ConstantsUtility.ORDER_LINE &&
			(
				childNode == ConstantsUtility.ORDER_LINE_NUM ||
				childNode == ConstantsUtility.PIECE_COUNT
			)
		) {
			if (childNode == ConstantsUtility.ORDER_LINE_NUM) ConstantsUtility.orderLineNum++;
			childNode = childNode + ConstantsUtility.orderLineNum;
		}

		// separate Handling Units by incrementing static values
		if (
			parentNode == ConstantsUtility.HANDLING_UNIT_LINE &&
			(
				childNode == ConstantsUtility.ORDER_LINE_NUM ||
				childNode == ConstantsUtility.PIECE_COUNT_PLANNED ||
				childNode == ConstantsUtility.HANDLING_UNIT_COUNT_PLANNED
			)
		) {
			if (childNode == ConstantsUtility.ORDER_LINE_NUM) ConstantsUtility.handlingUnitNum++;
			childNode = childNode + ConstantsUtility.handlingUnitNum;
		}

		return childNode;
	}

}