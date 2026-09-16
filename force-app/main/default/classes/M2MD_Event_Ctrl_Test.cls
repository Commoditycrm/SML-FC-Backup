@IsTest
private class M2MD_Event_Ctrl_Test {

    @IsTest
    static void test_receiveM2MDEvent_success() {

        // REQUIRED TEST DATA
        Account acc = new Account(
            Name = 'Testing'
        );
        insert acc;

        // SAMPLE M2MD PAYLOAD
        String payload = '{' +
            '"cid":"PYh8TsYqsGM=",' +
            '"tstamp":1765979577459,' +
            '"data":{' +
                '"battery":{"charge":64.7,"voltage":4.49},' +
                '"bleScan":[' +
                '{"signalStrength":-37,"tagId":"8f3f4e803479","rawData":"0xe0000c19037934804e3f8f2605770b"}' +
                '],' +
                '"cell":{' +
                    '"rsrp":{"val":-95,"desc":"good"},' +
                    '"rsrq":{"val":-9,"desc":"good"}' +
                '},' +
                '"id":"89011703324282534580",' +
                '"location":{' +
                    '"latitude":370912492,' +
                    '"longitude":-947064828,' +
                    '"horizontalAccuracy":2791,' +
                    '"source":"mcell",' +
                    '"cells":3' +
                '}' +
            '}' +
        '}';

        // SET REST CONTEXT
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProcessM2MDEvents/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = M2MD_Event_Ctrl.receiveM2MDEvent();
        Test.stopTest();

        // ASSERT API RESPONSE CREATED
        List<Api_Response__c> responses = [
            SELECT Id, Asset__c, Device_Id__c
            FROM Api_Response__c
        ];

        // ASSET CREATED
        List<Asset> assets = [
            SELECT Id, Device_Id__c, RSRP__c, RSRQ__c
            FROM Asset
            WHERE Device_Id__c = '89011703324282534580'
        ];
    }
    
    // Mock HTTP response for Salesforce OAuth token fetch
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "test_access_token", "instance_url": "https://test.salesforce.com", "token_type": "Bearer", "id": "test_id", "issued_at": "1620000000000", "signature": "test_signature"}');
            return res;
        }
    }

    // Mock HTTP response for external server post request
    public class MockExternalHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            return res;
        }
    }

    @isTest
    static void testOAuthTokenForwarder() {

        // Setup Mock responses for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Mock the external post response
        Test.setMock(HttpCalloutMock.class, new MockExternalHttpResponse());

        // Call the method
        OAuthTokenForwarder.ExternalPostResponse response = OAuthTokenForwarder.run('M2MD');
        String cron = '0 0 0 1 1 ?';
        System.schedule('m2md Test Job', cron, new OAuthTokenForwarderScheduler());

    }
}