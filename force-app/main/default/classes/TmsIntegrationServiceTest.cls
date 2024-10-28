/**
 * @author RadialSpark
 * @date 06-15-2018
 * @description Handler class for BolTriggerHandler
 * @changelog
	06-15-2018 - Bradley Wong - created
	08-27-2018 - Bradley Wong - removed postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateCarrierAccountExternalId() due to BOL__c.Carrier__c field update
 */

@isTest
private class TmsIntegrationServiceTest {

	private static Account sourceLocation;
	private static Account targetLocation;
	private static Account carrierLocation;

	private static void init() {
        //insert test TMS_Credentials Custom Setting
		insert new TMS_Credentials__c(
			Username__c = 'tmsUsername',
			Password__c = 'tmsPassword',
			Is_Production__c = false,
			Endpoint__c = 'https://www.testTmsEndpoint.com'
		);
		String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();

		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);


		carrierLocation = AccountTestDataFactory.createAccount(
			'carrierLocation',
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
            null
		);       
        carrierLocation.External_Location_Id__c = '0';
		carrierLocation.ShippingCountry = 'United States';
		insert carrierLocation;


		sourceLocation = AccountTestDataFactory.createAccount(
			'sourceLocation',
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
            null
		);       
		sourceLocation.External_Location_Id__c = '1';
		sourceLocation.ShippingCountry = 'United States';
		insert sourceLocation;


		targetLocation = AccountTestDataFactory.createAccount(
			'targetLocation',
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
            null
		);
        targetLocation.External_Location_Id__c = '2';
		targetLocation.ShippingCountry = 'United States';
		insert targetLocation;
	}


	/**
	 * @description verify that when a BOL__c object is inserted with a Carrier account w/o an External_Location_Id ==> POST TradingPartner to TMS
	 */
	 /* ----- REMOVED ==> Carrier__c is now a text field (instead of a lookup to Account) ----- */
	// @isTest	
	// private static void postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateCarrierAccountExternalId() {
	// 	init();

    //     System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));
        
	// 	System.Test.startTest();
	// 	TmsIntegrationService.postTradingPartner(carrierLocation.Id);
	// 	System.Test.stopTest();

	// 	Account carrierLocationAfterPost = [
	// 		SELECT
	// 			Id,
	// 			External_Location_Id__c
	// 		FROM Account
	// 		WHERE Id = :carrierLocation.Id
	// 	];

	// 	System.assertEquals('400696', carrierLocationAfterPost.External_Location_Id__c);

	// }
	
	/**
	 * @description verify that when a BOL__c object is inserted with a Source Location account w/o an External_Location_Id ==> POST TradingPartner to TMS
	 */
	@isTest	
	private static void postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateSourceLocationExternalId() {
		init();

        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));
        
		System.Test.startTest();
		Account updatedAccount = TmsIntegrationService.postTradingPartner(sourceLocation.Id);
		System.Test.stopTest();

		System.assertEquals('400696', updatedAccount.External_Location_Id__c);

	}

	/**
	 * @description verify that when a BOL__c object is inserted with a Target Location account w/o an External_Location_Id ==> POST TradingPartner to TMS
	 */
	@isTest	
	private static void postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateTargetLocationExternalId() {
		init();

        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));
        
		System.Test.startTest();
		Account updatedAccount = TmsIntegrationService.postTradingPartner(targetLocation.Id);
		System.Test.stopTest();

		System.assertEquals('400696', updatedAccount.External_Location_Id__c);

	}
}