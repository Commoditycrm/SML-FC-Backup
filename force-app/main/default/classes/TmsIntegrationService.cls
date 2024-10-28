/**
 * @author RadialSpark
 * @date 05-14-2018
 * @description Service class to handle TMS Integration
 * @changelog
	05-14-2018 - Bradley Wong - created
	05-15-2018 - Bradley Wong - made custom settings for TMS Credentials
	06-01-2018 - Bradley Wong - added POST to /orders TMS endpoint before POST to /loads
	06-11-2018 - Bradley Wong - added POST of TradingPartner via postTradingPartner()
	06-14-2018 - Bradley Wong - added field updates, refactored to use TmsXmlStreamReader.parseXmlForSpecificValue instead of TmsXmlStreamReader.parseTmsResponseToSObjects()
	08-31-2018 - Bradley Wong - set BOL__c.Other_Charges__c value based on response from POST to 3GTMS
	09-05-2018 - Bradley Wong - refactored 3GTMS Endpoints from shipdlx to crossdoc endpoint
 */


public without sharing class TmsIntegrationService {
	public static final String POST_LOAD_ERROR = 'There has been an error posting the Load object to 3G-TMS. Response: ';
	public static final String POST_LOAD_UNAUTHORIZED_ERROR = 'An authorization error occurred while trying to POST to 3G-TMS. Response: ';
	public static final String GET_LOAD_UNAUTHORIZED_ERROR = 'An authorization error occurred while trying to retrieve Load data from 3G-TMS.';
	public static final String GET_LOAD_BAD_LOAD_NUM_ERROR = 'The specified load was not found in 3GTMS.';
	public static final String GENERIC_GET_ERROR = 'An error occured while attempting a GET request from 3GTMS: ';

	//query for the SF Id for the Account record type: Corporate
	private static final Id CORPORATE_RECORD_TYPE_ID = [
		SELECT
			Id,
			DeveloperName
		FROM RecordType
		WHERE DeveloperName = 'Corporate'
		LIMIT 1
	][0].Id;

	//TMS Credentials (USERNAME, PASSWORD, ENDPOINT) from custom settings
	private static final TMS_Credentials__c TMS_CREDENTIALS = [
		SELECT
			Username__c,
			Password__c,
			Is_Production__c,
			Endpoint__c
		FROM TMS_Credentials__c
		LIMIT 1
	];

	//TMS Credentials as URL String appendage
	private static final String TMS_CREDENTIALS_STRING = 'username=' + TMS_CREDENTIALS.Username__c + '&password=' + TMS_CREDENTIALS.Password__c;

	/**
	 * @description Service method that performs GET request to TMS Load endpoint and returns BOL__c objects mapped
	 *   from TMS response
	 */
	public static List<String> getLoads(List<BOL__c> bolScope) {

		//instantiate the TMS XML parser
		TmsXmlStreamReader tmsXmlParser = new TmsXmlStreamReader();

		List<String> updatedLoads = new List<String>();
        for (BOL__c relevantBol : bolScope) {

			// SAMPLE GET ENDPOINT: https://crossdoc.3gtms.com/xdoc/rest/callWebService?webServiceName=SmartPalletLoadGet&username=<username>&password=<password>&xmlPayload=<loadNum>L180530-00012</loadNum>
			String xmlPayload = EncodingUtil.urlEncode('<loadNum>' + relevantBol.Name + '</loadNum>', 'UTF-8');
			String tmsGetLoadsEndpoint = TMS_CREDENTIALS.Endpoint__c + '/callWebService?webServiceName=SmartPalletLoadGet&' + TMS_CREDENTIALS_STRING + '&xmlPayload=' + xmlPayload;
            System.debug('endpoint: ' + tmsGetLoadsEndpoint);

			//parse through the response from the HTTP GET request
			HttpResponse response = HttpUtility.httpCallout(tmsGetLoadsEndpoint, 'GET', null, 'application/xml');

			if (response.getStatusCode() == 200) {
				updatedLoads.add(response.getBody());
			}
			else if (response.getStatusCode() == 401) {
				//handle unauthorized user error here
				throw new CalloutException(GET_LOAD_UNAUTHORIZED_ERROR);
			}
			else if (response.getStatusCode() == 404) {
				throw new CalloutException(GET_LOAD_BAD_LOAD_NUM_ERROR);
			}
			else {
				throw new CalloutException(GENERIC_GET_ERROR + response.getStatusCode());
			}

        }

		return updatedLoads;
	}

	/**
	 * @description Service method that maps new BOL__c records into TMS Load objects and POST to TMS endpoint
	 */
	@future (callout=true)
	public static void postLoads(Set<Id> newBolIds) {
		//set the tms order endpoint based on Custom Settings query
		String tmsPostOrderEndpoint = TMS_CREDENTIALS.Endpoint__c + '/orders?' + TMS_CREDENTIALS_STRING;

		//query for new BOL__c objects just created
		List<BOL__c> newBols = [
			SELECT
				Id,
				Name,
				Pickup__c,
				Dropoff__c,
				Carrier__c,
				BOL_Number__c,
				Total_Pallets__c,
				// Carrier__r.ShippingAddress,
				// Carrier__r.External_Location_Id__c,
				Source_Location__r.Name,
				Source_Location__r.ShippingState,
				Source_Location__r.ShippingCountry,
				Source_Location__r.ShippingAddress,
				Source_Location__r.External_Location_Id__c,
				Target_Location__r.Name,
				Target_Location__r.ShippingState,
				Target_Location__r.ShippingCountry,
				Target_Location__r.ShippingAddress,
				Target_Location__r.External_Location_Id__c
			FROM BOL__c
			WHERE Id IN :newBolIds
		];

        System.debug(newBols);

		List<Account> accsToUpdate = new List<Account>();
		List<BOL__c> bolsWithBolNumber = new List<BOL__c>();
		for (BOL__c bol : newBols) {

            System.debug('posting BOL: ' + bol);

			//instantiate an XML parser
			TmsXmlStreamReader tmsXmlParser = new TmsXmlStreamReader();
            System.debug('created TmsXmlStreamReader');

			//if any of the Accounts (Carrier__c, Source_Location__c, Target_Location__c) do not have external ID ==> POST TradingPartner to TMS
			// if (bol.Carrier__r.External_Location_Id__c == null) accsToUpdate.add(postTradingPartner(bol.Carrier__c));
			if (bol.Target_Location__r.External_Location_Id__c == null) accsToUpdate.add(postTradingPartner(bol.Target_Location__c));
			if (bol.Source_Location__r.External_Location_Id__c == null) accsToUpdate.add(postTradingPartner(bol.Source_Location__c));

			//map fields from TMS to SF and add values from this BOL__c object
			TmsBolMapper tmsBolMapper = new TmsBolMapper();
			tmsBolMapper.buildBolValueMapper(bol);

            System.debug('called tmsBolMapper.buildBolValueMapper(bol)');

			//map the BOL__c object to XML string
			TmsXmlBuilder bolXmlBuilder = new TmsXmlBuilder((SObject)bol, ConstantsUtility.LOADS, tmsBolMapper.getTmsFieldsToSfFields());
			String bolXml = bolXmlBuilder.buildXmlString();

            System.debug('called bolXmlBuilder.buildXmlString()');

			// SAMPLE POST ENDPOINT: POST https://crossdoc.3gtms.com/xdoc/rest/postWebService?webServiceName=SmartPalletLoadInsert&username=DLX-SmartPallet-SB&password=OruMEYh7QM
			String tmsPostLoadEndpoint = TMS_CREDENTIALS.Endpoint__c + '/postWebService?webServiceName=SmartPalletLoadInsert&' + TMS_CREDENTIALS_STRING;

            System.debug('TMS endpoint = ' + tmsPostLoadEndpoint);
            System.debug('XML = ' + bolXml);

			//POST the Load XML String to 3G-TMS
			HttpResponse tmsLoadsResponse = HttpUtility.httpCallout(tmsPostLoadEndpoint, 'POST', bolXml, 'application/xml;charset=UTF-8');
            System.debug('called HttpUtility.httpCallout()');

			//if the http response returns a status code of 200 ==> parse through response body
			if (tmsLoadsResponse.getStatusCode() == 200) {
				String responseBody = tmsLoadsResponse.getBody();

                System.debug('response = ' + responseBody);

				//parse through Load POST response to find the SuccessCount (even TMS Insert requests that fail will respond with a 200 code)
				Boolean isSuccess = Integer.valueOf(tmsXmlParser.parseXmlForSpecificValue(responseBody, ConstantsUtility.SUCCESS_COUNT, null)) > 0;
                System.debug('isSuccess = ' + isSuccess);

				if (isSuccess) {
					//parse through the XML response for the Tms Load Internal Id
					String tmsLoadNum = tmsXmlParser.parseXmlForSpecificValue(responseBody, ConstantsUtility.INTERNAL_ID, null);
                    System.debug('tmsLoadNum = ' + tmsLoadNum);
					//set the Tms Internal Id to the BOL__c.BOL_Number__c field (external id)
					bol.BOL_Number__c = tmsLoadNum;
					bolsWithBolNumber.add(bol);
				}

				//there was an error in inserting the Load object ==> handle error
				else {
					throw new CalloutException(POST_LOAD_ERROR + tmsLoadsResponse.getBody());
				}

			}

			else if (tmsLoadsResponse.getStatusCode() > 400) {
				//handle other errors here
				throw new CalloutException(POST_LOAD_UNAUTHORIZED_ERROR + tmsLoadsResponse.getBody());
			}
		}

		try {
			update accsToUpdate;
			update bolsWithBolNumber;
		} catch (DmlException e) {
			//handle Dml errors
			throw e;
		}
	}

	/**
	 * @description Service method that will POST a TradingPartner to TMS
	 */
	@TestVisible
	private static Account postTradingPartner(Id accountId) {

		//query for the account object that does not have an external id
		Account acc = [
			SELECT
				Id,
				Name
			FROM Account
			WHERE Id = :accountId
			LIMIT 1
		][0];

		//convert the current time to a formatted string
		String now = DateTimeUtility.toString(DateTime.now());

		//create a value mapper that contains values derived from the SF Account
		Map<String, String> tradingPartnerValues = new Map<String, String> {
			'DateCreated' => now,
			'DateLastModified' => now,
			'TradingPartnerNum' => 'Smart Logistics',
			'TradingPartnerName' => 'Smart Logistics'
		};

		//create a TmsMapper with these values
		TmsTradingPartnerMapper tradingPartnerMapper = new TmsTradingPartnerMapper(tradingPartnerValues);

		//build the XML String to POST Account as TradingPartner
		TmsXmlBuilder tradingPartnerXmlBuilder = new TmsXmlBuilder(ConstantsUtility.TRADING_PARTNER, tradingPartnerMapper.getTradingPartnerValues());
		String tradingPartnerXml = tradingPartnerXmlBuilder.buildXmlString();

		//build tms endpoint for POSTing trading partners
		String tmsTradingPartnerEndpoint = TMS_CREDENTIALS.Endpoint__c + '/tradingPartners?' + TMS_CREDENTIALS_STRING;

		HttpResponse tmsTradingPartnerResponse = HttpUtility.httpCallout(tmsTradingPartnerEndpoint, 'POST', tradingPartnerXml, 'application/xml;charset=UTF-8');

		//instantiate TmsXmlStreamReader to use to parse for TradingPartner Internal Id
		TmsXmlStreamReader tmsXmlParser = new TmsXmlStreamReader();
		String tmsInternalId = tmsXmlParser.parseXmlForSpecificValue(tmsTradingPartnerResponse.getBody(), ConstantsUtility.INTERNAL_ID, null);

		acc.External_Location_Id__c = tmsInternalId;
		return acc;
	}

}