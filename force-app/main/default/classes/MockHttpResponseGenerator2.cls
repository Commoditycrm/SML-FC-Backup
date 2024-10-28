@isTest
global class MockHttpResponseGenerator2 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"query": "SELECT Id, Name FROM Asset LIMIT 10"}');
        return res;
        
    }
}