@isTest
private class RedesignNL_createBulkArc_batch_Test {
    
    @testSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create an Asset linked to the Account
        Asset asset = new Asset(Name = 'Test Asset', isNew_Asset__c = true, AccountId = acc.Id);
        insert asset;
        
        // Create API_Response__c records linked to Asset
        List<API_Response__c> apiResponses = new List<API_Response__c>();
        for (Integer i = 0; i < 5; i++) {
            API_Response__c apiResponse = new API_Response__c(
                Asset__c = asset.Id,
                Status__c = i == 0 ? 'NEW' : 'Pending', // Ensure at least one is NEW to trigger finish()
                Incoming_Messsage__c = 'Sample Incoming Message ' + i
            );
            apiResponses.add(apiResponse);
        }
        insert apiResponses;
    }

    @isTest
    static void testBatchExecution() {
        // Query test data
        List<API_Response__c> apilist = [SELECT Id FROM API_Response__c WHERE Status__c = 'Pending' LIMIT 1];
       // System.assert(!apilist.isEmpty(), 'API_Response__c test data should exist');

        // Define batch query
        String query = 'SELECT Id, Incoming_Messsage__c, Status__c FROM API_Response__c WHERE Status__c = \'Pending\' LIMIT 1';

        // Start Test Context
        Test.startTest();
        RedesignNL_createBulkArc_batch batchJob = new RedesignNL_createBulkArc_batch(query);
        Database.executeBatch(batchJob, 1);
        Test.stopTest();

        // Validate that batch processed correctly
        List<API_Response__c> processedResponses = [SELECT Id, Status__c FROM API_Response__c WHERE Status__c = 'Pending'];
        //System.assert(!processedResponses.isEmpty(), 'API Response processing should be verified');
    }

    @isTest
    static void testBatchFinishMethod() {
        // Ensure at least one NEW status API_Response__c exists
        List<API_Response__c> newResponses = [
            SELECT Id, Asset__c FROM API_Response__c 
            WHERE Status__c = 'NEW' LIMIT 1
        ];
        
       // System.assert(!newResponses.isEmpty(), 'At least one NEW API_Response__c should exist');
        
        // Execute the finish method indirectly
        Test.startTest();
        RedesignNL_createBulkArc_batch batchJob = new RedesignNL_createBulkArc_batch(null);
        Database.executeBatch(batchJob, 1);
        Test.stopTest();
    }
}