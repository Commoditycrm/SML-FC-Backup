/**
 * @author RadialSpark
 * @date 05-02-2018
 * @description Test class for TmsXmlStreamReader class
 * @changelog
	05-02-2018 - Bradley Wong - Created
	05-24-2018 - Bradley Wong - removed Order__c
	06-14-2018 - Bradley Wong - refactored for new TmsXmlStreamReader methods, removed tests for TmsXmlStreamReader.parseTmsResponseToSObjects()

 */

@isTest
private class TmsXmlStreamReaderTest {
	//instance of tmsXmlReader
	private static TmsXmlStreamReader tmsXmlReader; 

	//Sample Xml response from posting a Load to TMS
	private static final String tmsPostResponse = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><ImportLoadsResponse><Result>Total Success</Result><ImportEntities><SuccessCount>1</SuccessCount><FailureCount>0</FailureCount><WarningCount>0</WarningCount><ImportEntity><ExternalKey>B-0336</ExternalKey><Result>Success</Result><InternalId>2635270</InternalId><Action>Insert</Action><EntityType>Load</EntityType></ImportEntity></ImportEntities></ImportLoadsResponse></ns2:LoadData>';

	//Carrier Account
	private static Account carrier;

	private static void init() {
		tmsXmlReader = new TmsXmlStreamReader();
		
		Account parentAccount = AccountTestDataFactory.createParentAccount('Test Parent', true);

		String locationType = String.valueOf(Account.Location_Type__c.getDescribe().getPicklistValues()[0].getValue());

		carrier = AccountTestDataFactory.createAccount(
			'FloPath_Common_Customer',
			'Carrier',
			'123 Street',
			'City',
			'State',
			'11111',
			11.11,
			111.11,
			parentAccount.Id,
			locationType,
			true,
			'External Id'
		);
	} 

	@isTest
	private static void parseXmlForSpecificValue_ShouldReturnProperInternalId() {
		init();

		System.Test.startTest();
		String internalId = tmsXmlReader.parseXmlForSpecificValue(tmsPostResponse, ConstantsUtility.INTERNAL_ID, null);
		System.Test.stopTest();

		System.assertEquals(internalId, '2635270');
	}

	@isTest
	private static void parseXmlForSpecificValue_ShouldReturnProperSuccessCount() {
		init();

		System.Test.startTest();
		String internalId = tmsXmlReader.parseXmlForSpecificValue(tmsPostResponse, ConstantsUtility.SUCCESS_COUNT, null);
		System.Test.stopTest();

		System.assertEquals(internalId, '1');
	}
}