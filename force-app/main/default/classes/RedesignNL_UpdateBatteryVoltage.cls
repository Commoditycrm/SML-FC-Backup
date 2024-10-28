public class RedesignNL_UpdateBatteryVoltage implements Database.Batchable<SObject>, Database.Stateful {
    
    // Batchable Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query Asset_History_custom__c records
        String query = 'SELECT Id, Device_Status_Time__c, Battery_Voltage__c, Start_Time__c, End_Time__c, Asset__c '
            + 'FROM Asset_History_custom__c '
            + 'WHERE Device_Status_Time__c != NULL AND Battery_Voltage__c = NULL';
        return Database.getQueryLocator(query);
    }
    
    // Batchable Execute Method
    public void execute(Database.BatchableContext BC, List<Asset_History_custom__c> assetHistoryList) {
        Set<Id> assetIds = new Set<Id>();
        Set<Datetime> deviceStatusTimes = new Set<Datetime>();
        
        // Collect asset Ids and Device Status Times from assetHistoryList
        for (Asset_History_custom__c ahc : assetHistoryList) {
            assetIds.add(ahc.Asset__c);
            deviceStatusTimes.add(ahc.Device_Status_Time__c);
        }
        
        // Query corresponding API_Response_Childs__c records that match the device status time and asset Id
        List<API_Response_Childs__c> apiResponseList = [SELECT Id, Battery__c, Timestamp_Date_Time_Device_Status__c, Asset__c 
                                                        FROM API_Response_Childs__c 
                                                        WHERE Timestamp_Date_Time_Device_Status__c IN :deviceStatusTimes 
                                                        AND Asset__c IN :assetIds AND Battery__c != null];
        
        // Map to relate the Asset Id and Device Status Time to the API Response record
        Map<Id, Map<Datetime, API_Response_Childs__c>> assetToApiResponseMap = new Map<Id, Map<Datetime, API_Response_Childs__c>>();
        
        // Populate the map with the queried API_Response_Childs__c records
        for (API_Response_Childs__c arc : apiResponseList) {
            if (!assetToApiResponseMap.containsKey(arc.Asset__c)) {
                assetToApiResponseMap.put(arc.Asset__c, new Map<Datetime, API_Response_Childs__c>());
            }
            assetToApiResponseMap.get(arc.Asset__c).put(arc.Timestamp_Date_Time_Device_Status__c, arc);
        }
        
        // Update Asset_History_custom__c records with the Battery Voltage from the matching API_Response_Childs__c
        List<Asset_History_custom__c> ahcToUpdateList = new List<Asset_History_custom__c>();
        for (Asset_History_custom__c ahc : assetHistoryList) {
            if (assetToApiResponseMap.containsKey(ahc.Asset__c) 
                && assetToApiResponseMap.get(ahc.Asset__c).containsKey(ahc.Device_Status_Time__c)) {
                    // Find the matching API Response record
                    API_Response_Childs__c matchingApiResponse = assetToApiResponseMap.get(ahc.Asset__c).get(ahc.Device_Status_Time__c);
                    
                    // Update the Battery_Voltage__c field
                    ahc.Battery_Voltage__c = matchingApiResponse.Battery__c;
                    ahcToUpdateList.add(ahc);
                }
        }
        
        // Update all the Asset_History_custom__c records
        if (!ahcToUpdateList.isEmpty()) {
            update ahcToUpdateList;
        }
    }
    
    // Batchable Finish Method
    public void finish(Database.BatchableContext BC) {
        // Optionally, add logic to send notification or handle post-process operations
        System.debug('Batch execution completed.');
    }
}