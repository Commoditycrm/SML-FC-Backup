@IsTest
public class testInsights_Controller {
 private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod(), 'Method should be POST');
            System.assert(req.getEndpoint().contains('/query'), 'Endpoint should contain /query');
            System.assertEquals('application/json', req.getHeader('Content-Type'));

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            // Sample payload your LWC expects
            res.setBody('{"success":true,"response":"ok","data":[{"Asset_ID__c":"A1","Battery_Voltage__c":4.5}],"record_count":1}');
            return res;
        }
    }

    // --- Error mock ---
    private class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Server Error');
            res.setBody('{"message":"boom"}');
            return res;
        }
    }

    @IsTest
    static void testGenerateInsights_Success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Test.startTest();
        String out = Insights_Controller.generateInsights('battery < 6', '001000000000001');
        Test.stopTest();

        System.assertNotEquals(null, out, 'Should return a string');
        // Current controller returns JSON.serialize(res.getBody()) -> a JSON-quoted string
        System.assert(out.startsWith('"') && out.endsWith('"'), 'Return should be JSON-quoted');
        System.assert(out.contains('record_count'), 'Serialized payload should contain content');
    }

    @IsTest
    static void testGenerateInsights_ErrorFromServer() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());
        try {
            Test.startTest();
            Insights_Controller.generateInsights('any', '001000000000001');
            System.assert(false, 'Should have thrown AuraHandledException');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('External call failed'), 'Should include failure message');
        } finally {
            Test.stopTest();
        }
    }

    @IsTest
    static void testGenerateInsights_BlankPrompt() {
        try {
            Test.startTest();
            Insights_Controller.generateInsights('', '001000000000001');
            System.assert(false, 'Should have thrown AuraHandledException for blank prompt');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Prompt is required.'), 'Should enforce prompt');
        } finally {
            Test.stopTest();
        }
    }
}