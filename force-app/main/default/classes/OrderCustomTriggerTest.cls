/**
 * @author 		Bradley Wong, RadialSpark
 * @date 		2/28/18
 * @description Tests for OrderCustomTrigger (required to successfully deploy)
 */

@isTest
public with sharing class OrderCustomTriggerTest {
    
    private static testMethod void doItForTheCoverage() {
        Account testAccount = AccountTestDataFactory.createParentAccount('Test Account', true);
        
        DateTime orderDropoff = dateTime.newInstance(2018, 1, 1);
        Integer numberOfPallets = 5;
        DateTime pickup = dateTime.newInstance(2018, 1, 2);
       	Id sourceLocation = testAccount.Id;
        Id targetLocation = testAccount.Id;
        
        Order__c testOrder = new Order__c(
        	Dropoff__c = orderDropoff,
            Number_of_Pallets__c = numberOfPallets,
            Pickup__c = pickup,
            Source_Location__c = sourceLocation,
            Target_Location__c = targetLocation
        );
        
        System.Test.startTest();
		insert testOrder;
        System.Test.stopTest();
        
		List<Order__c> findOrder = [SELECT Id FROM Order__c];
        System.assertEquals(1, findOrder.size());
    }
	
}