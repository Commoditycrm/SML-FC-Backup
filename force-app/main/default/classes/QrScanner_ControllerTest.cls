@IsTest
private class QrScanner_ControllerTest {
    
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
            
            Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
    	ast.Last_connected__c = DateTime.now();
        ast.battery_Voltage__c = 3.7;
        insert ast;
        
    }
    

    @IsTest
    static void testParseResponseWithDeviceId() {

        // Set mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/qrScanner/?deviceId=TEST-DEVICE-123';
        req.httpMethod = 'GET';
        req.params.put('deviceId', 'TEST-DEVICE-123');

        RestContext.request = req;
        RestContext.response = res;

        // Call controller method
        List<Asset> result = QrScanner_Controller.parseResponse();
    }

    @IsTest
    static void testParseResponseWithoutDeviceId() {
        // Set mock request with no deviceId
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/qrScanner/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        // Call controller method
        List<Asset> result = QrScanner_Controller.parseResponse();

        // Assert null is returned
        System.assertEquals(null, result, 'Expected null when deviceId is missing');
    }
}