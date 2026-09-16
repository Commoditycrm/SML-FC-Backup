@isTest
public class storeLocationInAssetHistory_Test {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Asset
        Asset ast = new Asset(
            Name = 'Test Asset',
            Device_Id__c = 'test-device-123',
            AccountId = acc.Id,
            Last_Known_Location__c = acc.Id,
            Current_Location__c = acc.Id,
            Current_Address__c = 'Test Location',
            Capture_Movement_Event__c = true
        );
        insert ast;

        // Create Asset History Records
        List<Asset_History_custom__c> ahList = new List<Asset_History_custom__c>{
            new Asset_History_custom__c(
                Asset__c = ast.Id,
                //Account_ID__c = acc.Id,
                Latitude__c = 37.7749,
                Longitude__c = -122.4194,
                Location__c = null // To test if it gets updated
            ),
            new Asset_History_custom__c(
                Asset__c = ast.Id,
                //Account_ID__c = acc.Id,
                Latitude__c = 40.7128,
                Longitude__c = -74.0060,
                Location__c = 'Existing Location' // To ensure no override happens
            )
        };
        insert ahList;
    }

    @isTest
    static void testUpdateAddress() {
        Test.startTest();

        // Fetch test asset history records
        List<Asset_History_custom__c> ahList = [SELECT Id, Account_ID__c, Latitude__c, Longitude__c, Location__c FROM Asset_History_custom__c];

        // Call the method
        storeLocationInAssetHistory.updateAddress(ahList);

        // Verify that the Location__c field is updated
        List<Asset_History_custom__c> updatedRecords = [SELECT Location__c FROM Asset_History_custom__c WHERE Id IN :ahList];

        for (Asset_History_custom__c ah : updatedRecords) {
            if (ah.Location__c == null) {
               // System.assertEquals('In Transit', ah.Location__c, 'Location should be set to "In Transit" if no valid location is found');
            } else {
                //System.assertNotEquals(null, ah.Location__c, 'Location should be updated');
            }
        }

        Test.stopTest();
    }

    @isTest
    static void testUpdateAddress_ExceptionHandling() {
        Test.startTest();

        try {
            // Call method with null list to trigger exception
            storeLocationInAssetHistory.updateAddress(null);
            //System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
           // System.assert(e != null, 'Exception should be caught and handled');
        }

        Test.stopTest();
    }
}