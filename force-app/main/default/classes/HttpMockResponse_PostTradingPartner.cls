/**
 * @author RadialSpark
 * @date 06-15-2018
 * @description Generates mock http response for testing TmsIntegrationService.postTradingPartner()
 * @changelog
	06-15-2018 - Bradley Wong - Created
 */

@isTest
global class HttpMockResponse_PostTradingPartner implements HttpCalloutMock {
    private Boolean isSuccess;

	//Sample Xml String with two Load objects
    private static final String USERNAME = 'tmsUsername';
	private static final String PASSWORD = 'tmsPassword';
	private static final String TMS_ENDPOINT = 'https://www.testTmsEndpoint.com/tradingPartners?username=' 
		+ USERNAME 
		+ '&password=' 
		+ PASSWORD;
		

	private static final String TRADING_PARTNER_POST_RESPONSE_SUCCESS = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:TradingPartnerData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><ImportTradingPartnersResponse><Result>Total Success</Result><ImportEntities><SuccessCount>1</SuccessCount><FailureCount>0</FailureCount><WarningCount>0</WarningCount><ImportEntity><ExternalKey>1</ExternalKey><Result>Success</Result><InternalId>400696</InternalId><Action>Update</Action></ImportEntity></ImportEntities></ImportTradingPartnersResponse></ns2:TradingPartnerData>';
	private static final String TRADING_PARTNER_POST_RESPONSE_FAILURE = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:TradingPartnerData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><ImportTradingPartnersResponse><Result>Total Success</Result><ImportEntities><SuccessCount>0</SuccessCount><FailureCount>1</FailureCount><WarningCount>0</WarningCount><ImportEntity><ExternalKey>1</ExternalKey><Result>Success</Result><InternalId>400696</InternalId><Action>Update</Action></ImportEntity></ImportEntities></ImportTradingPartnersResponse></ns2:TradingPartnerData>';

    public HttpMockResponse_PostTradingPartner(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(TMS_ENDPOINT, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        
        if (this.isSuccess) {
            res.setBody(TRADING_PARTNER_POST_RESPONSE_SUCCESS);
        }
        else {
            res.setBody(TRADING_PARTNER_POST_RESPONSE_FAILURE);
        }

        res.setStatusCode(200);
        return res;
    }
}