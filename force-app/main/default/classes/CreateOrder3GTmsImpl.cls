public class CreateOrder3GTmsImpl implements HttpCalloutMock {
    //response for mock callout with temporary placeholder information
    public HTTPResponse respond(HTTPRequest req) {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"testProp": "testValue"}');
        res.setStatusCode(200);
        
        return res;
    }
}