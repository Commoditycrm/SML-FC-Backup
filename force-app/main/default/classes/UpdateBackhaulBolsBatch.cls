/**
 * @author RadialSpark
 * @date
 * @description Batch class used to catch updates from 3G-TMS and update SF BOL__c objects
 * @changelog
	05/10/2018 | Bradley Wong | added xml parser and handling for updated BOL__c, added Database.AllowsCallouts
	05/14/2018 | Bradley Wong | moved TMS credentials to Custom Settings TMS_CREDENTIALS, abstracted the TMS callout to TmsIntegrationService
	11/29/2018 | Jeffrey Underdown | Refactored and added multiple new fields to update on BOL__c
 */

global class UpdateBackhaulBolsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	private String query;
	private Id backhaulRecordTypeId;

	global UpdateBackhaulBolsBatch() {

		RecordType backhaulRecordtype = [
			SELECT Id, DeveloperName 
			FROM RecordType 
			WHERE DeveloperName =: 'Backhaul'
			AND sobjecttype = 'BOL__c'
			LIMIT 1
		];

		backhaulRecordTypeId = backhaulRecordtype.Id;
		//query = 'SELECT  Id, Name, Pickup_Confirmed__c, BOL_Number__c, CreatedDate FROM BOL__c WHERE CreatedDate > 2018-09-10T00:00:00.000Z AND RecordTypeId = \'' + backhaulRecordTypeId + '\'';
		query = 'SELECT  Id, Name, Pickup_Confirmed__c, BOL_Number__c FROM BOL__c WHERE RecordTypeId = \'' + backhaulRecordTypeId + '\' AND Pickup_Confirmed__c	= false AND Dropoff__c >= LAST_N_WEEKS:2';
		// String bolName = 'B-0239';
		// query = 'SELECT Id, Name, Pickup_Confirmed__c FROM BOL__c WHERE Name = \'' + 'B-2010' + '\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	} 
 
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {	
        
		//pass in relevant BOL__c objects and send GET requests to TMS
		List<String> updatedBolsFromTms = TmsIntegrationService.getLoads(scope);
        
        System.debug('updated BOLs from TMS: ' + updatedBolsFromTms[0].replaceAll('\n', ''));
        
		//parse through the XML responses to retrieve BOL Numbers and BOL Charges (to updated BOL__c records)
		TmsXmlStreamReader tmsXmlParser = new TmsXmlStreamReader();
        
		Map<String, Bol__c> updatedBolNumbersToBols = new Map<String, Bol__c>();
        
		for (String updatedBolXml : updatedBolsFromTms) {
			String bolNum = tmsXmlParser.parseXmlForSpecificValue(updatedBolXml, ConstantsUtility.LOAD_NUM, null);
			String bolCharges = tmsXmlParser.parseXmlForSpecificValue(updatedBolXml, ConstantsUtility.CURRENCY_VALUE, ConstantsUtility.THIRD_PARTY_CHARGES);
            String bolTrailerNumber = tmsXmlParser.parseXmlForSpecificValue(updatedBolXml, ConstantsUtility.TRAILER_NUMBER, null);
            String bolCarrier = tmsXmlParser.parseXmlForSpecificValue(updatedBolXml, ConstantsUtility.CARRIER_NAME, ConstantsUtility.CARRIER_PARENT_NODE);
            
            updatedBolNumbersToBols.put(
                bolNum,
                new BOL__c(
                	Other_Charges__c = (bolCharges != null) ? Decimal.valueOf(bolCharges) : null,
                    Trailer__c = bolTrailerNumber,
                    Carrier__c = bolCarrier,
                	Pickup_Confirmed__c = true
            	)
            );
            
		}

		//query for BOL__c objects with matching BOL_Number__c values
		List<BOL__c> bolsInSf = [
			SELECT 
				Id,
				Name,
				Other_Charges__c,
            	Trailer__c,
            	Carrier__c,
				Pickup_Confirmed__c,
				Source_Location__c,
				Target_Location__c
			FROM BOL__c
			WHERE Name IN :updatedBolNumbersToBols.keySet()
		];
 
		//update the BOL__c objects from Salesforce if their associated TMS Load record has been updated
		List<BOL__c> updatedBols = new List<BOL__c>();
		for (BOL__c bol : bolsInSf) {
            BOL__c bolFieldUpdates = updatedBolNumbersToBols.get(bol.Name);
            bol.Other_Charges__c = bolFieldUpdates.Other_Charges__c;
            bol.Trailer__c = bolFieldUpdates.Trailer__c;
            bol.Carrier__c = bolFieldUpdates.Carrier__c;
            bol.Pickup_Confirmed__c = bolFieldUpdates.Pickup_Confirmed__c;
			updatedBols.add(bol);
		}
        
        System.debug('updated BOLS: ' + updatedBols);

		try {
			update updatedBols;
		} catch (DmlException e) {
			//handle Dml error
			throw e;
		} 

	}
	
	global void finish(Database.BatchableContext BC) {
        
	}
	
}