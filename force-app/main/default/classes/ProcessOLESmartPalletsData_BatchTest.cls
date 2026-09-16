@isTest
private class ProcessOLESmartPalletsData_BatchTest {

    @isTest
    static void testBatchExecution() {
        // Create test Account
        Account acc = new Account(Name = 'Testing');
        insert acc;

        // Create test Asset
        Asset ast = new Asset(
            Name = 'LPN1001',
            AccountId = acc.Id,
            Field2__c = 'LPN1001'
        );
        insert ast;

        // Create matching API_Response__c record
        API_Response__c response = new API_Response__c(
            check_class__c = 'SmartPallet Data',
            Status__c = 'NEW',
            Smart_Pallets__c = 'LPN1001',
            Shipment_BOL_Number__c = 12345,
            Order_Type__c = 'Standard',
            Shipped_From_Zip_code__c = 12345,
            Shipped_To_Zip_code__c = 54321,
            Shipped_Date__c = Date.today(),
            Shipped_method__c = 'Ground',
            Ship_To_Customer_Name__c = 'Test Customer'
        );
        insert response;

        // Run the batch
        Test.startTest();
        ProcessOLESmartPalletsData_Batch batch = new ProcessOLESmartPalletsData_Batch();
        Database.executeBatch(batch, 1); // Use batch size of 1 for simple test coverage
        Test.stopTest(); 

       
    }
}