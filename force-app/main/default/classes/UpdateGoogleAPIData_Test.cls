@isTest
private class UpdateGoogleAPIData_Test {
    
    @isTest
    static void testBatch() {
        // Step 1: Create test data
        List<Google_API_Data__c> testData = new List<Google_API_Data__c>();

        // Case 1: Address with "USA"
        testData.add(new Google_API_Data__c(Current_Address__c = '123 Main St, Springfield, USA'));
        
        // Case 2: Address with "United States"
        testData.add(new Google_API_Data__c(Current_Address__c = '456 Elm St, Seattle, United States'));
        
        // Case 3: Address with a different country
        testData.add(new Google_API_Data__c(Current_Address__c = '789 Oak St, Toronto, Canada'));
        
        // Case 4: Address without a country
        testData.add(new Google_API_Data__c(Current_Address__c = '101 Pine St, Denver'));
         testData.add(new Google_API_Data__c(Current_Address__c = 'USA'));
        // Case 5: Null Current_Address__c
        testData.add(new Google_API_Data__c(Current_Address__c = null));
        
        // Insert test records
        insert testData;

        // Step 2: Run the batch class
        Test.startTest();
        UpdateGoogleAPIData batch = new UpdateGoogleAPIData();
        Database.executeBatch(batch, 10); // Batch size of 10
        Test.stopTest();

    }
}