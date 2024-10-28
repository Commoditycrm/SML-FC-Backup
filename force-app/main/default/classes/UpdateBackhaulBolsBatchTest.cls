/**
 * @author RadialSpark
 * @date
 * @description Test method to test the BOL__c update via batchable callout class
 * @changelog
	05-10-2018 - Bradley Wong - added mock callout execution to execute_UpdateBackhaulBolsBatch_success
	06-15-2018 - Bradley Wong - added carrierLocation and Carrier__c field to BOL__c, added error cases
 */

@isTest
private class UpdateBackhaulBolsBatchTest {
	private static BOL__c  testBol;
	private static Account sourceLocation;
	private static Account targetLocation;
	private static Account carrierLocation;
	private static TriggerRecordWrapper records;
	private static RecordType backhaulRecordtype;

	/**
	 *@description Inits the required fields to create a BOL__c object
	*/
	private static void init() {
		String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);

		//create a test source location account
		sourceLocation = AccountTestDataFactory.createAccount(
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

		//create a test target location account
		targetLocation = AccountTestDataFactory.createAccount(
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

		carrierLocation = AccountTestDataFactory.createAccount(
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
            'Location ID 2'
		);

		//query for backhaul record type
		backhaulRecordtype = [
			SELECT Id, DeveloperName
			FROM RecordType
			WHERE DeveloperName =: 'Backhaul'
			AND sobjecttype = 'BOL__c'
			LIMIT 1
		];

		//insert test TMS_Credentials Custom Setting
		insert new TMS_Credentials__c(
			Username__c = 'tmsUsername',
			Password__c = 'tmsPassword',
			Is_Production__c = false,
			Endpoint__c = 'https://www.testTmsEndpoint.com'
		);

        BolTriggerHandler.bypassAfterInsertTrigger = true;
		//insert a new BOL__c object that will mirror the XML response in HttpMockResponse_UpdateBackhaulBolsBatch
		testBol = new BOL__c(
			Pickup_Confirmed__c = false,
			Total_Pallets__c = 20,
			Carrier__c = carrierLocation.Name,
			Source_Location__c = sourceLocation.Id,
			Target_Location__c = targetLocation.Id,
			Pickup__c = System.now(),
			Dropoff__c = System.now(),
			BOL_Number__c = '3gTmsBolNum',
			RecordTypeId = backhaulRecordtype.Id
		);
		insert testBol;

	}

	/**
	 * @description Should insert a BOL__c w/ Pickup_Confirmed__c = false, run the batch (whose HTTP response should
	 *  have a Load with a matching BolNum) ==> should update the BOL__c.Pickup_Confirmed__c value to true
	*/
	@isTest
	private static void execute_UpdateBackhaulBolsBatch_success() {
		init();

        Test.setMock(HttpCalloutMock.class, new HttpMockResponse_UpdateBackhaulBolsBatch(200));

        Test.startTest();
		UpdateBackhaulBolsBatch bolBatchJob = new UpdateBackhaulBolsBatch();
		DataBase.executeBatch(bolBatchJob);
        Test.stopTest();

		BOL__c updatedTestBol = [
			SELECT
				Id,
				Pickup_Confirmed__c
			FROM BOL__c
			WHERE Id =:testBol.Id
			LIMIT 1
		][0];

		System.assertEquals(true, updatedTestBol.Pickup_Confirmed__c);
	}

}