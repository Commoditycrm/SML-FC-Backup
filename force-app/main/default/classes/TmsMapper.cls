/**
 * @author RadialSpark
 * @date 05-01-2018
 * @description Virtual class used to map between Salesforce and TMS Objects
 * @changelog
	05-01-2018 - Bradley Wong - Created
 */

public virtual class TmsMapper {
	/**
	 * @description Maps of field names between Salesforce and TMS that will be set in each extension's constructor
	*/
	protected Map<String, String> sfFieldsToTmsFields;
	protected Map<String, String> tmsFieldsToSfFields; 

	/**
	 * @description maps a TMS payload to the proper SObject fields in Salesforce
	 * @param {Map<String, String>} tmsPayload - TMS object 
	*/
	public Map<String, String> mapToSf(Map<String, String> tmsPayload) {
		Map<String, String> mappedToSf = new Map<String, String>();
		for (String key : tmsPayload.keySet()) {
			mappedToSf.put(tmsFieldsToSfFields.get(key), tmsPayload.get(key));
		}
		return mappedToSf;
	}

	/**
	 * @description maps a Salesforce object to proper fields in TMS
	 * @param {Map<String, String>} sfPayload - Salesforce object 
	*/
	public Map<String, String> mapToTms(Map<String, String> sfPayload) {
		Map<String, String> mappedToTms = new Map<String, String>();
		for (String key : sfPayload.keySet()) {
			mappedToTms.put(sfFieldsToTmsFields.get(key), sfPayload.get(key));
		}
		return mappedToTms;	
	}

	public Map<String, String> getSfFieldsToTmsFields() {
		return sfFieldsToTmsFields;
	}

	public Map<String, String> getTmsFieldsToSfFields() {
		return tmsFieldsToSfFields;
	}

}