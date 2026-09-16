/**
 * @author RadialSpark
 * @date 05-11-2018
 * @description Handler class for BolTrigger
 * @changelog
	05-11-2018 - Bradley Wong - created
	05-14-2018 - Bradley Wong - refactored postBolToTms() to call method from TmsIntegrationService
 */
 
public without sharing class BolTriggerHandler extends TriggerHandler {
	//static variable that acts as a flag to bypass trigger execution (for postBolToTms)
	@TestVisible public static Boolean bypassAfterInsertTrigger = false;
    
    /**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
    public BolTriggerHandler(TriggerRecordWrapper records) {
        super(records);
    }

    public override void doAfterInsert() {
        if (bypassAfterInsertTrigger) return;
        
		Map<Id, BOL__c> newMap = (Map<Id, BOL__c>)records.getNewMap();	
		postBolToTms(newMap);            

	} 

	/**
	 * @description New BOL__c objects should be mapped to TMS Load objects and POST to TMS records
	 *  ==> the BOL__c objects will then have to be updated with the BOL_Number__c number from TMS response 
	 */
	private void postBolToTms(Map<Id, BOL__c> newMap) {
		TmsIntegrationService.postLoads(newMap.keySet()); 
	}

}