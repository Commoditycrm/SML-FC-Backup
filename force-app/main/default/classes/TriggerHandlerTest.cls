/**
 * @author Connor Zint
 * @date 01/11/2018
 * @description Test for virtual methods on TriggerHandler abstract class
 */
@isTest
private class TriggerHandlerTest {
	private static TriggerRecordWrapper records;

	private static void init() {
		// create test account to use as data for trigger context
		Account acc = new Account(Name='test account', External_Location_Id__c='fakeExternal', Type='Other');
		insert acc;
		
		// create map to use for newMap and oldMap
		Map<Id, Account> accMap = new Map<Id, Account>();
		accMap.put(acc.Id, acc);

		// create triggerNew and deepClone to create triggerOld
		List<Account> triggerNew = new List<Account>{acc};
		List<Account> triggerOld = triggerNew.deepClone();

		// instantiate TriggerRecordWrapper with data
		records = new TriggerRecordWrapper(
			triggerNew,
			triggerOld,
			accMap,
			accMap
		);
	}

	/**
	 *@description Run static virtual methods on TriggerHandler
	 *        	   Implementation for coverage
	 */	
	@isTest
	static void test_TriggerHandler() {
		init();

		TriggerHandlerImp handlerImp = new TriggerHandlerImp(records);

		System.Test.startTest();

		if(!TriggerHandler.hasRun) {
			handlerImp.isTriggerActive();
			handlerImp.doBeforeInsert();
			handlerImp.doBeforeUpdate();
			handlerImp.doBeforeDelete();
			handlerImp.doAfterInsert();
			handlerImp.doAfterUpdate();
			handlerImp.doAfterDelete();
			handlerImp.doAfterUndelete();
		}

		System.Test.stopTest();
	}

	private class TriggerHandlerImp extends TriggerHandler {
		
		public TriggerHandlerImp(TriggerRecordWrapper records) {
			super(records);
		}

		public override void doBeforeInsert() {
			List<sObject> triggerNew = records.getTriggerNew();
			List<sObject> triggerOld = records.getTriggerOld();
			Map<Id, sObject> newMap = records.getNewMap();
			Map<Id, sObject> oldMap = records.getOldMap();
		}
	}
}