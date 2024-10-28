@isTest
global class EinsteinCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        string datasetid = system.label.DatasetId;
        string url1 = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v45.0/wave/datasets/'+datasetid+'/versions';
        system.debug(url1);
        string url2 = '/services/data/v44.0/wave/datasets/'+datasetid;
        System.assertEquals(url1, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');        
       // res.setBody('{"results" : [{"url"="/services/data/v44.0/wave/datasets/0Fb0v0000008svICAQ/versions", "versions"=({"createdBy"={"id"="0050v000002KWl6AAG", "name"="Integration User", "profilePhotoUrl"="https://smartlogisticsinc464--UAT--c.cs66.content.force.com/profilephoto/005/T"}, "createdDate"="2019-04-23T13:01:49.000Z", "dataset"={"id"="0Fb0v0000008svICAQ", "url"="/services/data/v44.0/wave/datasets/0Fb0v0000008svICAQ"}, "files"=(), "id"="0Fc0v000001L4nwCAC", "lastModifiedBy"={"id"="0050v000002KWl6AAG", "name"="Integration User", "profilePhotoUrl"="https://smartlogisticsinc464--UAT--c.cs66.content.force.com/profilephoto/005/T"]}');
        res.setBody('{"url" : "url1","versions" : [ {"dataset" : {"id" : "datasetid","url" : "url2"}}]}');
        system.debug(res);
        return res;
    }
}