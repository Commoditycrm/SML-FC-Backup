@isTest
public class LocoAwareTestControlerTest {
    
    @testSetup
    static void testDataSetup() {
        // Create necessary records for testing
        Account acc = new Account(Name = 'Testing');
        insert acc;
        
       /* Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            Device_Id__c = '72308628872194290',
            Is_Loco_Asset__c = true
        );
        insert asset;*/
        
    }

    @isTest
    static void testParseResponse_Success() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator());
        
        // Construct request body
        String requestBody = '{' +
            '"rxTime": 1731893323734,' +
            '"model": "LTP-HGC4-1-0",' +
            '"pos": {' +
            '"type": 8700,' +
            '"time": 1742290786153,' +
            '"lat": 44.893783,' +
            '"lon": -85.976608,' +
            '"cep": 15' +
            '},' +
            '"device": 72308628872194290,' +
            '"deviceId": "72308628872194290",' +
            '"status": {' +
            '"externalPower": false,' +
            '"deviceId": "Test Asset",' +
            '"charging": false,' +
            '"batteryVoltage": 5.653,' +
            '"temperature": 20.1875,' +
            '"signal": 50' +
            '},' +
            '"rssi" : 22,'+
            '"master" : "12334"'+
            
        '}';
        
        // Set the authorization header
        RestContext.request = new RestRequest();
        RestContext.request.headers.put('X-API-Key', System.label.Loco_Ware_API_Key);
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Invoke the method
        String response = LocoAwareTestControler.parseResponse();
    }
	 /*@isTest
    static void testRest_methods() {
        String devId = 'Test Asset';
        String model = 'test-model';
        LocoAwareTestControler.getAssetSummary(devId, model);
    }*/

    private class MockSuccessHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"results":[{"formatted_address":"Test Address, Test City, Test State, 12345","geometry":{"location":{"lat":44.893783,"lng":-85.976608}}}]}');
            return res;
        }
    }
}