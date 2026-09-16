@isTest
public class LocoAware_AssetDeactivation_ctrlTest {
	 public class DeactivateAssetSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"hasError":false,"summary":{"successes":[{"devices":["12345"],"changes":{"from":{"deactivated":false},"to":{"deactivated":true}}}],"errors":[]}}');
            return res;
        }
    }
    
    // Mock class to simulate callout with errors
    public class DeactivateAssetErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"hasError":true,"summary":{"errors":[{"devices":["99999"],"message":"Invalid device"}]}}');
            return res;
        }
    }
    
	 @isTest
    static void testDeactivateAssetSuccess() {
        Test.setMock(HttpCalloutMock.class, new DeactivateAssetSuccessMock());

        List<String> deviceIds = new List<String>{ '12345' };
        Test.startTest();
        String result = LocoAware_AssetDeactivation_ctrl.deactivateAsset(deviceIds); // Replace with your actual class name
        Test.stopTest();

    }
    
    @isTest
    static void testDeactivateAssetWithError() {
        Test.setMock(HttpCalloutMock.class, new DeactivateAssetErrorMock());

        List<String> deviceIds = new List<String>{ '99999' };
        Test.startTest();
        String result = LocoAware_AssetDeactivation_ctrl.deactivateAsset(deviceIds);
        Test.stopTest();

    }
}