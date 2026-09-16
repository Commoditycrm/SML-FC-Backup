/**
 * @author Connor Zint
 * @date 01/18/2018
 * @description Test methods for PartOrderService
 */

@isTest
public with sharing class PartOrderServiceTest {
	private static Part_Order__c partOrder;
	
	private static void init() {
		partOrder = PartOrderTestDataFactory.createPartOrder(
            'test part order',
            'test tracking number',
        	date.newInstance(2018, 1, 1),
            'Ordered',
            false
        );
	}

	/**
	 * @description verify that a Case is created and associated with the part order
	 */
	@isTest
	public static void createOrderCase_successOnInsert() {
		init();

		// Verify there are initially no cases
		System.assert([SELECT Id FROM Case].isEmpty());

		System.Test.startTest();
		// need to insert so the part order has an Id
		insert partOrder;
		System.Test.stopTest();

		Case createdCase = [SELECT Part_Order__c FROM Case LIMIT 1];

		// Verify a case was created and that the correct part order is related
		System.assertNotEquals(null, createdCase);
		System.assertEquals(partOrder.Id, createdCase.Part_Order__c);
	}
}