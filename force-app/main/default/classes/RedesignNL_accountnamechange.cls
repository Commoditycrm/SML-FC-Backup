global class RedesignNL_accountnamechange implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Asset_Account__c, Location__c, currentLocationId__c ,Last_Known_Location__c,Last_Known_Location_Lookup__c
            FROM Asset_History_custom__c 
            WHERE (Location__c != 'In Transit'  OR Last_Known_Location__c != null)
            AND Asset_Account__c = 'Target Corporation, Inc.'
        ]);
    }
    global void execute(Database.BatchableContext BC, List<Asset_History_custom__c> scope) {
        Set<String> accountIds = new Set<String>();
        for (Asset_History_custom__c assetHistory : scope) {
            if (assetHistory.currentLocationId__c != null) {
                accountIds.add(assetHistory.currentLocationId__c);
            }
            if (assetHistory.Last_Known_Location_Lookup__c != null) {
                accountIds.add(assetHistory.Last_Known_Location_Lookup__c);
            }
        }
        
        Map<String, Account> accountMap = new Map<String, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
        
        List<Asset_History_custom__c> assetHistoryToUpdate = new List<Asset_History_custom__c>();
        for (Asset_History_custom__c assetHistory : scope) {
            if (assetHistory.currentLocationId__c != null && accountMap.containsKey(assetHistory.currentLocationId__c)) {
                assetHistory.Location__c = accountMap.get(assetHistory.currentLocationId__c).Name;
            }
            if (assetHistory.Last_Known_Location_Lookup__c != null && accountMap.containsKey(assetHistory.Last_Known_Location_Lookup__c)) {
                assetHistory.Last_Known_Location__c = accountMap.get(assetHistory.Last_Known_Location_Lookup__c).Name;
            }
            assetHistoryToUpdate.add(assetHistory);
            
        }
        
        if (!assetHistoryToUpdate.isEmpty()) {
            Database.update(assetHistoryToUpdate,false);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}