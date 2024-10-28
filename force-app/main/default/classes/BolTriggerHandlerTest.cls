/**
 * @author RadialSpark
 * @date 05-11-2018
 * @description Handler class for BolTriggerHandler
 * @changelog
	05-11-2018 - Bradley Wong - created
	06-14-2018 - Bradley Wong - updated to reflect changes in TmsIntegrationService
	06-15-2018 - Bradley Wong - added test methods to test error handling
 */

@isTest
private class BolTriggerHandlerTest {

	private static Account sourceLocation;
	private static Account targetLocation;
	private static Account carrierLocation;
	private static TriggerRecordWrapper records;

	private static void init() {
		String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();

		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);

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
			false, 
            'Location ID 0'
		);
		sourceLocation.ShippingCountry = 'United States';
		insert sourceLocation;

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
			false, 
            'Location ID 1'
		);
		targetLocation.ShippingCountry = 'United States';
		insert targetLocation;

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
			false, 
            'Location ID 2'
		);       
		carrierLocation.ShippingCountry = 'United States';
		insert carrierLocation;

        //insert test TMS_Credentials Custom Setting
		insert new TMS_Credentials__c(
			Username__c = 'tmsUsername',
			Password__c = 'tmsPassword',
			Is_Production__c = false,
			Endpoint__c = 'https://www.testTmsEndpoint.com'
		);
	}


	/**
	 * @description verify that when a BOL__c object is inserted, it is posted to TMS and a BOL_Number__c value
	 *  is set from the TMS response
	 */
	@isTest	
	private static void postBolToTms_ShouldUpdateBolRecordWithBolNumber() {
		init();

        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_BolTriggerHandler(true));

		//create BOL__c record with the same information as the mock response in HttpMockResponse_BolTriggerHandler -- sampleXmlLoadResponse
		BOL__c testBol = new BOL__c (
			Pickup__c = DateTime.newInstance(2018, 1, 1, 1, 1, 1),
			Dropoff__c = DateTime.newInstance(2018, 2, 1, 1, 1, 1),
			Total_Pallets__c = 323,
			Carrier__c = carrierLocation.Name,
			Target_Location__c = targetLocation.Id,
			Source_Location__c = sourceLocation.Id
		);
        
		System.Test.startTest();
		insert testBol;
		System.Test.stopTest();

		BOL__c updatedBol = [
			SELECT
				Id,
				Pickup__c,
				Dropoff__c,
				BOL_Number__c,
				Total_Pallets__c
			FROM BOL__c
			LIMIT 1
		][0];

		//verify that the BOL__c record has been updated with the proper BOL_Number__c value
		System.assertEquals('2635270', updatedBol.BOL_Number__c);
		System.assertEquals(testBol.Total_Pallets__c, updatedBol.Total_Pallets__c);
	}
	
}