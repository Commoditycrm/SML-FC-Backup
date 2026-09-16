global class RedesignNL_BusinessName implements Database.Batchable<SObject> {
    
    // Query to retrieve records with a non-null Business_Name__c field
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Business_Name__c FROM Google_Api_Data__c WHERE Business_Name__c != null'
        );
    }
    
    // Execute method to clear Business_Name__c on each batch of records
    global void execute(Database.BatchableContext bc, List<Google_Api_Data__c> scope) {
        List<Google_Api_Data__c> recordsToUpdate = new List<Google_Api_Data__c>();
        
        for (Google_Api_Data__c record : scope) {
            record.Business_Name__c = null;
            recordsToUpdate.add(record);
        }
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
    
    // Optional: finish method to log or send completion notifications
    global void finish(Database.BatchableContext bc) {
        System.debug('ClearBusinessNameBatch has completed successfully.');
    }
}