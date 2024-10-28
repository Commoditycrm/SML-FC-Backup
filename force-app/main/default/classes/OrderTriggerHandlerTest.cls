@isTest
private class OrderTriggerHandlerTest {
	private static Order__c testOrder;
	private static Account testAccount;
	private static Account testAccount1;
	private static TriggerRecordWrapper records;

	private static void init() {
		String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();

		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);

		testAccount = AccountTestDataFactory.createAccount(
			'coffeeShop',
			'Location',
			'7366 E Shea Blvd',
			'Scottsdale',
			'AZ',
			'85260',
			33.5837301,
			-111.9244083,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 0'
		);

		testAccount1 = AccountTestDataFactory.createAccount(
			'radialSpark',
			'Location',
			'5710 W Chandler Blvd',
			'Chandler',
			'AZ',
			'85226',
			33.307501,
			-111.9421107,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 1'
		);

		// TODO: create test data factory for Order__c
		testOrder = new Order__c(
			Source_Location__c = testAccount.Id,
			Target_Location__c = testAccount1.Id,
			Number_of_Pallets__c = 20,
			Pickup__c = Date.Today(),
			Dropoff__c = Date.Today().addDays(1)
		);
	}
	
	/**
	 * @description verify that when an order is created, a BOL__c is created with correct data
	 */
	@isTest	static void test_createOrder_3gTms_success() {
		init();
		// Verify no Bols exist currently
		System.assert([SELECT Id FROM BOL__c].isEmpty());

		List<Order__c> orderList = new List<Order__c>{testOrder};
		records = new TriggerRecordWrapper(orderList, null, null, null);
		OrderTriggerHandler oth = new OrderTriggerHandler(records);

        System.Test.setMock(HttpCalloutMock.class, new CreateOrder3GTmsImpl());
        
		System.Test.startTest();
		HttpResponse res = oth.createOrder_3gTms(); 
		System.Test.stopTest();

		// Assert BOL__c was created with correct data
		//System.assert([SELECT Id FROM BOL__c].size() > 0);
		// TODO: add assertion to verify data on newly created BOL__c

        //Check POST response from Mock Callout
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        
        String actualValue = res.getBody();
        String expectedValue = '{"testProp": "testValue"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
	}
}