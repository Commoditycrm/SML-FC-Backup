/**
 * @author -- Gokulprasath
 * @date -- 02/20/2019
 * @description -- This Class will generate mock callout in order to cover googleapicallout class.
 **/

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCrly_ofyHrFUf70poqHLnWUblnTAOKn0o&latlng=40.12568900%20-90.15486000&sensor=true', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"results" : [{"address_components" : [{"long_name" : "North Co Road 1040 East","short_name" : "IL-78","types" : [ "route" ]},{"long_name" : "Chandlerville","short_name" : "Chandlerville","types" : [ "locality", "political" ]},{"long_name" : "Bath Township","short_name" : "Bath Township","types" : [ "administrative_area_level_3", "political" ]},{"long_name" : "Mason County","short_name" : "Mason County","types" : [ "administrative_area_level_2", "political" ]},{"long_name" : "Illinois","short_name" : "IL","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "United States","short_name" : "US","types" : [ "country", "political" ]},{"long_name" : "62627","short_name" : "62627","types" : [ "postal_code" ]}],"formatted_address" : "N Co Rd 1040 E, Chandlerville, IL 62627, USA"}]}');
        res.setStatusCode(200);
        return res;
    }
}