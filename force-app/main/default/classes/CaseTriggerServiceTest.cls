/**
 * @author Connor Zint
 * @date 01/17/2018
 * @description Unit test methods for CaseTriggerService
 */
@isTest
private class CaseTriggerServiceTest {
	private static Part_Order__c partOrder;
	private static Case testCase;
	private static Map<Id, Case> caseOldMap;
	private static TriggerRecordWrapper records;
	
	/**
	 *@description initialize test data
	 */	
	private static void init() {

		partOrder = PartOrderTestDataFactory.createPartOrder('test part order', 'test tracking number', Date.today().addDays(1), 'Shipped', true);

		testCase = CaseTestDataFactory.createCase('New', 'Automated Order', partOrder.Id, true);

		caseOldMap = new Map<Id, Case>([
				SELECT
					Id,
					Part_Order__c,
					Status
				FROM Case
				WHERE Id =: testCase.Id
		]);
	}

	/**
	 *@description Verify that when a Case is inserted with status 'Closed'
	 * 			   that it's related Part Order is set to Has_Been_Delivered = true
	 */	
	@isTest
	private static void checkPartOrderDeliveredOnClosedCase_successOnInsert() {
		init();

		// Verify part order related to case has not been delivered
		System.assertEquals('Shipped', partOrder.Status__c);
		
		// deep clone case to remove id and test insert
		List<Case> testCaseList = new List<Case> {testCase};
		List<Case> newTestCaseList = testCaseList.deepClone();
		newTestCaseList[0].Status = 'Closed';

		records = new TriggerRecordWrapper(
			newTestCaseList,
			null,
			null,
			null
		);
		CaseTriggerService cts = new CaseTriggerService(records);
		
		System.Test.startTest();
		cts.checkPartOrderDeliveredOnClosedCase();
		System.Test.stopTest();

		// Verify that service method set Status__c to Shipped
		Part_Order__c pOrder = [SELECT Status__c FROM Part_Order__c WHERE Id =:partOrder.Id];
		System.assertEquals('Delivered', pOrder.Status__c);
	}

	/**
	 *@description Verify that when a Case is inserted with status other than 'Closed'
	 * 			   that it's related Part Order is not set to Has_Been_Delivered = true
	 */	
	@isTest
	private static void checkPartOrderDeliveredOnClosedCase_hasBeenDeliveredNotSet() {
		init();

		// Verify part order related to case has not been delivered
		System.assertEquals('Shipped', partOrder.Status__c);
		
		// deep clone case to remove id and test insert
		List<Case> testCaseList = new List<Case> {testCase};
		List<Case> newTestCaseList = testCaseList.deepClone();
		newTestCaseList[0].Status = 'New';

		records = new TriggerRecordWrapper(
			newTestCaseList,
			null,
			null,
			null
		);
		CaseTriggerService cts = new CaseTriggerService(records);
		
		System.Test.startTest();
		// run insert method with the case list
		cts.checkPartOrderDeliveredOnClosedCase();
		System.Test.stopTest();

		// Verify that service method did not set Status__c to Shipped
		Part_Order__c pOrder = [SELECT Status__c FROM Part_Order__c WHERE Id =:partOrder.Id];
		System.assertNotEquals('Delivered', pOrder.Status__c);
	}

	/**
	 *@description Verify that when a Case is updated with status 'Closed'
	 * 			   that it's related Part Order is set to Has_Been_Delivered = true
	 */	
	@isTest
	private static void checkPartOrderDeliveredOnClosedCase_successOnUpdate() {
		init();

		// Verify part order related to case has not been delivered
		System.assertNotEquals('Delivered', partOrder.Status__c);
		
		// create list with test case to simulate triggerNew
		List<Case> testCaseList = new List<Case> {testCase};
		testCaseList[0].Status = 'Closed';

		records = new TriggerRecordWrapper(
			testCaseList,
			null,
			null,
			caseOldMap
		);
		CaseTriggerService cts = new CaseTriggerService(records);
		
		System.Test.startTest();
		cts.checkPartOrderDeliveredOnClosedCase();
		System.Test.stopTest();

		// Verify that service method set Status__c to Shipped
		Part_Order__c pOrder = [SELECT Status__c FROM Part_Order__c WHERE Id =:partOrder.Id];
		System.assertEquals('Delivered', pOrder.Status__c);
	}


	/**
	 *@description unit tests don't actually update the pallets, get update coverage here
	 */	
	@isTest
	public static void cover_update() {
		init();
		testCase.Status = 'Closed';

		System.Test.startTest();
		update testCase;
		System.Test.stopTest();
	}
}