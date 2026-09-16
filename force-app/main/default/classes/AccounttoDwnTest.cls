@isTest
public class AccounttoDwnTest {

    @isTest
    static void testTriggerWithCustomerUser() {
       
        User testCustomerUser  = [select id from user where profile.name LIKE 'Customer User%' and isactive=true limit 1];

        // Use System.runAs to simulate actions by the test customer user.
        System.runAs(testCustomerUser) {
            Test.startTest();
            // Insert an Account record to fire the trigger.
            Account acc = new Account(Name = 'Test Account for Customer Trigger',OwnerId=testCustomerUser.id);
            insert acc; 
            Test.stopTest();
        }

      
    }

    @isTest
    static void testTriggerWithoutCustomerUser() {
        // Query a Profile that does NOT include "Customer User" in its Name.

        // Create a test user with a non-customer profile.
        User testNonCustomerUser =  [select id from user where profile.name LIKE 'System Administrator' and isActive=true limit 1];
        // Run as the non-customer user. The trigger should not create any Related_Customer__c record.
        System.runAs(testNonCustomerUser) {
            Test.startTest();
            Account acc = new Account(Name = 'Test Account for Non-Customer Trigger',OwnerId=UserInfo.getUserId());
           insert acc;
            Test.stopTest();
        }

    }
}