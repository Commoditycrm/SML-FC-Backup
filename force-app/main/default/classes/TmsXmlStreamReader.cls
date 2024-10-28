/**
 * @author RadialSpark
 * @date 05-01-2018
 * @description Parses XML responses from TMS into BOL__c SObjects
 * @changelog
	05-02-2018 - Bradley Wong - Created
	05-24-2018 - Bradley Wong - removed Order__c
	06-01-2018 - Bradley Wong - added parseTmsId()
	06-11-2018 - Bradley Wong - added getInternalId()
	06-14-2018 - Bradley Wong - removed parseTmsResponseToSObjects() and related methods
	08-06-2018 - Bradley Wong - refactored parseXmlForSpecificValue() to accept a parentNode parameter
 */
 
public class TmsXmlStreamReader {
	//SObject exceptions thrown when setting SObject fields with wrong types
	private static final String DECIMAL_TYPE_ERROR = 'Illegal assignment from String to Decimal';
	private static final String DATETIME_TYPE_ERROR = 'Illegal assignment from String to Datetime';

	//Tms Internal Id
	private String internalId;

	//xml node name that contains the requested value (ex. CurrencyValue)
	private String targetNode;

	//optional name of the parent node if the target node is a common name (ex. TotalThirdPartyCharge)
	private String parentNode;

	//value of the requested xml node
	private String targetValue;

	//Instance of TmsMapper that is either instantiated as a TmsBolMapper 
	private TmsMapper tmsMapper; 

	//Set of Node tags that contain child nodes 
	private static final Set<String> nodesWithChildNodes = new Set<String>{ 'OrderNums', 'OrderCharges', 'OrdCharge' };


	/* ----------- PARSE XML FOR SINGLE VALUE ----------- */
	/**
	 * @description parses through XML response and returns a specific value specific by the targetNode name
	 * @param {String} xmlString ==> Raw XML string from HttpResponse.getBody()
	 * @param {String} targetNode ==> the name of the node with the desired value; ex. CurrencyValue
	 * @param {String} parentNode ==> the name of the parent node. should be included when the targetNode is a generic value, like CurrencyValue, to ensure the proper
	 *   node value is returned. ex. TotalThirdPartyCharge.
	 */
	public String parseXmlForSpecificValue(String xmlString, String targetNode, String parentNode) {
		//init the targetValue as null
		this.targetValue = null;
		//set the desired node name
		this.targetNode = targetNode;
		//set the parent node name
		this.parentNode = parentNode;

		//init new DOM document
		Dom.Document xmlDoc = new Dom.Document();
		//cast the raw xml string to the new DOM document
		xmlDoc.load(xmlString);

		//loop through the highest level nodes (the child nodes of the root node)
		for (Dom.XmlNode node : xmlDoc.getRootElement().getChildElements()) {
			//attempt to extract the value of the specified node (this.targetNode)
			this.getTargetNodeValue(node);
		}

		return this.targetValue;
	}

	/**
	 * @description Method that digs through the XML to return the value of the InternalId node
	 */
	private void getTargetNodeValue(Dom.XmlNode node) {

		for (Dom.XmlNode currentNode : node.getChildElements()) {
			//if the current node has the same name as the target node ==> check if it's the desired node value
			if (currentNode.getName() == this.targetNode) {
				
				//if the parentNode is defined and not equal to this node's parent node name ==> do nothing and continue
				if (this.parentNode != null && node.getName() != this.parentNode) {
					continue;
				}

				//else ==> get the value of this node
				String nodeValue = currentNode.getText();

				//if the targetValue has not been defined yet ==> set as this node's value
				if (this.targetValue == null) {
					this.targetValue = nodeValue;
				}
				//else ==> there are multiple instances of the same node value and they will need to be added together (ex. multiple ThirdPartyCharges)
				else {
					this.targetValue = String.valueOf(Decimal.valueOf(nodeValue) + Decimal.valueOf(this.targetValue));
				}
				break;
			}

			//else ==> if there are more child nodes, continue searching for the desired value
			else if (currentNode.getChildElements() != null) {	
				getTargetNodeValue(currentNode);
			}
		}

	}

}