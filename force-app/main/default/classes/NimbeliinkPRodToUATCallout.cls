public class NimbeliinkPRodToUATCallout {
public class ApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse hr = new HttpResponse();
            hr.setHeader('Content-Type', 'text/html');
            hr.setStatusCode(200);
            hr.setBody('SUCCESS');
            if(req.getBody().contains('grant_type=password'))
            {
             hr.setBody('{"access_token": "00DEa000000DZG5!AQEAQFHp_DskwziiqJXz9rBFakO3Er76TNRQe2AQY339uUPsTkmGD3bxWNfuvKY.F0Y0N2vvWdjzJccdvyv9cazvJPJsPtDH"}'); 
            }
            
            return hr ;
        }
    }
}