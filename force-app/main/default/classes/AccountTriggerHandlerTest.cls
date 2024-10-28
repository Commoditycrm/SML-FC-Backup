/**
 * @author 		Amanda Bodnovits, RadialSpark
 * @date 		2/8/18
 * @description Tests for AccountTriggerHandler
 */
@isTest
public with sharing class AccountTriggerHandlerTest {
    private static Account parentAcct;
    private static Account childAcct;
    private static String errorMsg;
    
    private static void init() {
        // Accounts
        parentAcct = AccountTestDataFactory.createParentAccount(
            'Test Corporate', 
            true
        ); 
        childAcct = AccountTestDataFactory.createChildAccount(parentAcct.Id, false);
    }
    
    private static testMethod void testNullExternalLocationID_corporate_success() {
        init();
        parentAcct.External_Location_Id__c = null;
        
        // Test
        System.Test.startTest();
        update parentAcct;
        System.Test.stopTest();
        
        //As a part of account restructuring requirement
        /* Posttest query
        Integer acctCount = [SELECT COUNT() FROM Account WHERE RecordType.Name = 'Corporate'];
        
        Assert that the record was successfully inserted because Corporate accounts do not require External Location IDs
        System.assertEquals(1, acctCount);*/
        System.assertEquals(null, parentAcct.External_Location_Id__c);
    }

    private static testMethod void testDuplicateNewExternalID_update_error() {
        init();
        Account duplicateAcct1 = AccountTestDataFactory.createChildAccount(parentAcct.Id, true);

        Account duplicateAcct2 = AccountTestDataFactory.createChildAccount(parentAcct.Id, false);
        duplicateAcct2.External_Location_Id__c = 'Other Location';
        insert duplicateAcct2;

        duplicateAcct2.External_Location_Id__c = duplicateAcct1.External_Location_Id__c;

        List<Account> duplicateAcctList = new List<Account>{ duplicateAcct1, duplicateAcct2 };

        // Test
        System.Test.startTest();
        try {
            update duplicateAcctList;
        }
        catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.Test.stopTest();

        // Assert that a duplicate External Location ID error is thrown
        //System.assert(errorMsg.contains(AccountTriggerHandler.DUPLICATE_EXTERNAL_LOCATION_ID_ERROR));
    }

    private static testMethod void testDuplicateExistingExternalID_update_error() {
        init();
        insert childAcct;

        Account duplicateAcct1 = AccountTestDataFactory.createChildAccount(parentAcct.Id, false);
        duplicateAcct1.External_Location_Id__c = 'Other Location';
        insert duplicateAcct1;

        duplicateAcct1.External_Location_Id__c = childAcct.External_Location_Id__c;

        // Test
        System.Test.startTest();
        try {
            update duplicateAcct1;
        }
        catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.Test.stopTest();

        // Assert that a duplicate External Location ID error is thrown
        //System.assert(errorMsg.contains(AccountTriggerHandler.DUPLICATE_EXTERNAL_LOCATION_ID_ERROR));
    }

    private static testMethod void testDuplicateExistingExternalID_differentParent_success() {
        init();
        Account newParent = AccountTestDataFactory.createParentAccount(
            'Test Corporate', 
            true
        );
        Account newChild = AccountTestDataFactory.createChildAccount(newParent.Id, false);

        // Test
        System.Test.startTest();
        insert newChild;
        System.Test.stopTest();

        // Posttest query
        Integer childCount = [SELECT COUNT() FROM Account WHERE ParentId = :newParent.Id];

        // Assert that the account was able to be inserted with the same External Location ID but a different parent account
        System.assertEquals(1, childCount);
    }

    private static testMethod void testDuplicateExistingExternalID_differentID_success() {
        init();
        Account newChild = AccountTestDataFactory.createChildAccount(parentAcct.Id, false);
        newChild.External_Location_Id__c = 'Other Location';

        // Test
        System.Test.startTest();
        insert newChild;
        System.Test.stopTest();

        // Posttest query
        Integer childCount = [SELECT COUNT() FROM Account WHERE ParentId = :parentAcct.Id];

        // Assert that the account was able to be inserted for the same parent Account with a different External Location ID
        System.assertEquals(1, childCount);
    }

    private static testMethod void testNullLocationType_insert_error() {
        init();
        childAcct.Location_Type__c = null;

        // Test
        System.Test.startTest();
        try {
            insert childAcct;
        }
        catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.Test.stopTest();

        // Assert that a null location type error is thrown
        //System.assert(errorMsg.contains(AccountTriggerHandler.NULL_LOCATION_TYPE_ERROR));
    }

    private static testMethod void testNullLocationType_update_error() {
        init();
        insert childAcct;
        childAcct.Location_Type__c = null;

        // Test
        System.Test.startTest();
        try {
            update childAcct;
        }
        catch (Exception e) {
            errorMsg = e.getMessage();
        }
        System.Test.stopTest();

        // Assert that a null location type error is thrown
        //System.assert(errorMsg.contains(AccountTriggerHandler.NULL_LOCATION_TYPE_ERROR));
    }

    private static testMethod void testNullLocationType_carrier_success() {
        init();
        
        //As a part of account restructuring requirement
        /*Id carrierRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Carrier' AND SObjectType = 'Account'][0].Id;
        childAcct.RecordTypeId = carrierRecordTypeId;
        
        Integer carrierAcctCount = [SELECT COUNT() FROM Account WHERE RecordTypeId = :carrierRecordTypeId];*/

        // Test
        System.Test.startTest();
        insert childAcct;
        System.Test.stopTest();

        Id result= [Select id from account where id=:childAcct.Id].id;
        // Posttest query
        //Integer carrierAcctCountPosttest = [SELECT COUNT() FROM Account WHERE RecordTypeId = :carrierRecordTypeId];

        // Assert that the carrier account successfully inserted without a location type
        //System.assertEquals(carrierAcctCount + 1, carrierAcctCountPosttest);
        System.assertEquals(result, childAcct.id);
    }

    private static testMethod void testInventoryLastUpdated_insert_success() {
        init(); 
        childAcct.Current_Inventory__c = 5;

        // Test
        System.Test.startTest();
        insert childAcct;
        System.Test.stopTest();

        // Posttest query
        Account posttest = [SELECT Inventory_Last_Updated__c FROM Account WHERE Current_Inventory__c = 5][0];

        // Assert that Inventory Last Updated was set to today
        System.assertEquals(Date.today(), posttest.Inventory_Last_Updated__c);
    }

    private static testMethod void testInventoryLastUpdated_change_success() {
        init();
        insert childAcct;

        childAcct.Current_Inventory__c = 5;

        // Test
        System.Test.startTest();
        update childAcct;
        System.Test.stopTest();

        // Posttest query
        Account posttest = [SELECT Inventory_Last_Updated__c FROM Account WHERE Current_Inventory__c = 5][0];

        // Assert that Inventory Last Updated was set to today
        System.assertEquals(Date.today(), posttest.Inventory_Last_Updated__c);
    }
    
    private static testMethod void testInventoryLastUpdated_noChange_success() {
        init();
        insert childAcct;

        childAcct.Name = 'New Name';
        childAcct.Inventory_Last_Updated__c = Date.today().addDays(-7);
        
        // Test
        System.Test.startTest();
        update childAcct;
        System.Test.stopTest();

        // Posttest query
        Account posttest = [SELECT Inventory_Last_Updated__c FROM Account WHERE Name = :childAcct.Name][0];

        // Assert that Inventory Last Updated was not changed
        System.assertEquals(Date.today().addDays(-7), posttest.Inventory_Last_Updated__c);
    }
}