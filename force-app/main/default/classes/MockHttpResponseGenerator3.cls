@IsTest
global class MockHttpResponseGenerator3 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
         res.setBody('{"token": "mocked_token_value"}');
        res.setBody('{"status": "success"}');
            res.setStatusCode(200);
        /*if (req.getEndpoint().contains('/auth')) {
            // Mock response for the token generation endpoint
            res.setBody('{"token": "mocked_token_value"}');
            res.setStatusCode(200);
        } else if (req.getEndpoint().contains('/activate') || req.getEndpoint().contains('/deactivate')) {
            // Mock response for the activation/deactivation endpoint
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
        }*/
        
        return res;
    }
}