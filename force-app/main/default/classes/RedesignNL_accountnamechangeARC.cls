global class RedesignNL_accountnamechangeARC implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Location__c, CurrentLocationId__c, Asset__c FROM API_Response_Childs__c where Location__c != 'In Transit' AND Asset__r.account.name = 'Target Corporation, Inc.'
        ]);
    }
    global void execute(Database.BatchableContext BC, List<API_Response_Childs__c> scope) {
        Set<String> accountIds = new Set<String>();
        for (API_Response_Childs__c apiChild : scope) {
            if (apiChild.currentLocationId__c != null) {
                accountIds.add(apiChild.currentLocationId__c);
            }
        }
        
        Map<String, Account> accountMap = new Map<String, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
        
        List<API_Response_Childs__c> apiResponseChildToUpdate = new List<API_Response_Childs__c>();
        for (API_Response_Childs__c apiChild : scope) {
            if (apiChild.currentLocationId__c != null && accountMap.containsKey(apiChild.currentLocationId__c)) {
                apiChild.Location__c = accountMap.get(apiChild.currentLocationId__c).Name;
                apiResponseChildToUpdate.add(apiChild);
            }
        }
        
        if (!apiResponseChildToUpdate.isEmpty()) {
            Database.update(apiResponseChildToUpdate,false);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}