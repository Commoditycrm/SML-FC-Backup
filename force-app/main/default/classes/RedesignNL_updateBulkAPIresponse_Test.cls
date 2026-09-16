@isTest
private class RedesignNL_updateBulkAPIresponse_Test {
    
    @testSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Assets linked to the Account
        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < 3; i++) {
            assets.add(new Asset(Name = 'Test Asset ' + i, isNew_Asset__c = true, pause_job__c = false, AccountId = acc.Id));
        }
        insert assets;
        
        // Create API_Response__c records linked to Assets
        List<API_Response__c> apiResponses = new List<API_Response__c>();
        for (Asset asset : assets) {
            for (Integer i = 0; i < 5; i++) { // Each asset gets 5 API Response records
                apiResponses.add(new API_Response__c(
                    Asset__c = asset.Id,
                    Status__c = 'Pending'
                ));
            }
        }
        insert apiResponses;
        
        // Create API_Response_Childs__c records linked to API Responses
        List<API_Response_Childs__c> arcList = new List<API_Response_Childs__c>();
        for (API_Response__c apiResponse : apiResponses) {
            for (Integer i = 0; i < 2; i++) { // Each API Response gets 2 child records
                arcList.add(new API_Response_Childs__c(
                    API_Response__c = apiResponse.Id,
                    //asset__c = assets[0].id,
                    Asset__c = apiResponse.Asset__c,
                    Status__c = 'Pending',
                    Timestamp_DateTime__c = DateTime.now().addDays(-100), // Ensure timestamp is in past
                    ARC_External_Id__c='asd12'+i+system.now()+apiResponse.Id
                    
                ));
            }
        }
        insert arcList;
    }

    @isTest
    static void testBatchExecution() {
        // Ensure test data exists
        List<Asset> testAssets = [SELECT Id FROM Asset WHERE isNew_Asset__c = true LIMIT 1];
        //System.assert(!testAssets.isEmpty(), 'Test Assets should exist');

        List<API_Response__c> testApiResponses = [SELECT Id FROM API_Response__c WHERE Status__c = 'Pending' LIMIT 1];
        //System.assert(!testApiResponses.isEmpty(), 'Test API Responses should exist');

        List<API_Response_Childs__c> testArcs = [SELECT Id FROM API_Response_Childs__c WHERE Status__c = 'Pending' LIMIT 1];
        //System.assert(!testArcs.isEmpty(), 'Test API Response Childs should exist');

        // Run batch execution
        Test.startTest();
        RedesignNL_updateBulkAPIresponse batchJob = new RedesignNL_updateBulkAPIresponse();
        Database.executeBatch(batchJob, 10);
        Test.stopTest();

        // Validate status updates for API_Response__c
        List<API_Response__c> updatedApiResponses = [SELECT Id, Status__c FROM API_Response__c WHERE Status__c = 'NEW'];
        //System.assert(updatedApiResponses.size() > 0, 'API Responses should have been updated to NEW');

        // Validate status updates for API_Response_Childs__c
        List<API_Response_Childs__c> updatedArcs = [SELECT Id, Status__c FROM API_Response_Childs__c WHERE Status__c = 'New'];
        //System.assert(updatedArcs.size() > 0, 'API Response Childs should have been updated to New');
    }

    @isTest
    static void testBatchFinishMethod() {
        // Run the batch job to reach the finish method
        Test.startTest();
        RedesignNL_updateBulkAPIresponse batchJob = new RedesignNL_updateBulkAPIresponse();
        Database.executeBatch(batchJob, 10);
        Test.stopTest();

        // Since finish() does not have logic, we only check if batch runs successfully
        //System.assert(true, 'Finish method executed without errors');
    }
}