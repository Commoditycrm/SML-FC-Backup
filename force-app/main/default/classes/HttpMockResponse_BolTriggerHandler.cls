/**
 * @author RadialSpark
 * @date 05-10-2018
 * @description Generates mock http response for testing UpdateBackhaulBolsBatch.cls
 * @changelog
	05-10-2018 - Bradley Wong - Created
 */

@isTest
global class HttpMockResponse_BolTriggerHandler implements HttpCalloutMock {
    private Boolean isSuccess;

	//Sample Xml String with two Load objects
    private static final String USERNAME = 'tmsUsername';
	private static final String PASSWORD = 'tmsPassword';
	private static final String TMS_ENDPOINT = 'https://www.testTmsEndpoint.com/postWebService?webServiceName=SmartPalletLoadInsert&username=' 
		+ USERNAME 
		+ '&password=' 
		+ PASSWORD;

	// private static final String sampleXmlLoadResponse = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><BatchInfo><BatchDateTime>2018-05-02T19:01:20.322Z</BatchDateTime><SentBy>SP-INT</SentBy><PageNum>1</PageNum><PageCnt>1</PageCnt></BatchInfo><Loads><Load><EntityHeader><DateCreated>2018-05-01T16:43:00Z</DateCreated><CreatedBy>SP-INT</CreatedBy><DateLastModified>2018-05-01T16:43:00Z</DateLastModified><LastModifiedBy>SP-INT</LastModifiedBy></EntityHeader><BOLNum>3gTmsBolNum</BOLNum><PlannedStart>2018-01-01T01:01:01Z</PlannedStart><PlannedEnd>2018-02-01T01:01:01Z</PlannedEnd><TransportMode>TL</TransportMode><TotalPieceCount>323</TotalPieceCount></Load></Loads></ns2:LoadData>';
	private static final String LOAD_POST_RESPONSE_SUCCESS = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><ImportLoadsResponse><Result>Total Success</Result><ImportEntities><SuccessCount>1</SuccessCount><FailureCount>0</FailureCount><WarningCount>0</WarningCount><ImportEntity><ExternalKey>B-0336</ExternalKey><Result>Success</Result><InternalId>2635270</InternalId><Action>Insert</Action><EntityType>Load</EntityType></ImportEntity></ImportEntities></ImportLoadsResponse></ns2:LoadData>';
	private static final String LOAD_POST_RESPONSE_FAILURE = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><ImportLoadsResponse><Result>Total Success</Result><ImportEntities><SuccessCount>0</SuccessCount><FailureCount>1</FailureCount><WarningCount>0</WarningCount><ImportEntity><ExternalKey>B-0336</ExternalKey><Result>Success</Result><InternalId>2635270</InternalId><Action>Insert</Action><EntityType>Load</EntityType></ImportEntity></ImportEntities></ImportLoadsResponse></ns2:LoadData>';

    public HttpMockResponse_BolTriggerHandler(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(TMS_ENDPOINT, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        
        if (this.isSuccess) {
            res.setBody(LOAD_POST_RESPONSE_SUCCESS);
        }
        else {
            res.setBody(LOAD_POST_RESPONSE_FAILURE);
        }

        res.setStatusCode(200);
        return res;
    }
}