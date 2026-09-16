@isTest

public class EAcalloutMockClass implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response similar to the one you provided
        HTTPResponse res = new HTTPResponse();
         if (req.getEndpoint().contains('wave/query')) {
            String responseBody = '{"action":"query","responseId":"SLB:7476457903eb238f2ed4f26557d5d4f1","results":{"metadata":[{"lineage":{"type":"foreach","projections":[{"field":{"id":"result.Id","type":"string"},"inputs":[{"id":"q.Id"}]},{"field":{"id":"result.latitude__c","type":"string"},"inputs":[{"id":"q.Latitude__c"}]},{"field":{"id":"result.longitude__c","type":"string"},"inputs":[{"id":"q.Longitude__c"}]},{"field":{"id":"result.Railway_Line_Information__c","type":"string"},"inputs":[{"id":"q.Railway_Line_Information__c"}]}]},"queryLanguage":"SAQL"}],"records":[{"Id":"a0bVA000001a7X3YAI","Railway_Line_Information__c":"a0cVA000002HkjfYAC","latitude__c":"44.0108973616","longitude__c":"-90.5183598671"},{"Id":"a0bVA000001a7X4YAI","Railway_Line_Information__c":"a0cVA000002HkjfYAC","latitude__c":"44.0109944488","longitude__c":"-90.5162087859"},{"Id":"a0bVA000001a7X5YAI","Railway_Line_Information__c":"a0cVA000002HkjfYAC","latitude__c":"44.0110485988","longitude__c":"-90.5149772777"}]},"query":"q = load \"0FbVA000000gMnJ0AU/0FcVA0000040WGv0AM\"; q = filter q by Lat_formula__c >= 43.95313549275362318840579710144927540  and Lat_formula__c <= 44.01110650724637681159420289855072460 and Lon_formula__c >= -90.52165946005826499871510114061220160 and Lon_formula__c <= -90.44109453994173500128489885938779840; result = foreach q generate q.Id as Id, q.Latitude__c as latitude__c, q.Longitude__c as longitude__c, q.Railway_Line_Information__c as Railway_Line_Information__c; ","responseTime":15}';
            //string responseBody = '{"results":{"records":[{"Id":"a0bVA000001rUV5YAM","Railway_Line_Information__c":"a0cVA000002KjPdYAK","latitude__c":"43.9898370649","longitude__c":"-90.5196822482"},{"Id":"a0bVA000001rUV6YAM","Railway_Line_Information__c":"a0cVA000002KjPdYAK","latitude__c":"43.9891346845","longitude__c":"-90.5169771820"},{"Id":"a0bVA000001rUV7YAM","Railway_Line_Information__c":"a0cVA000002KjPdYAK","latitude__c":"43.9879614560","longitude__c":"-90.5124587416"}]}';
            res.setStatusCode(200);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
         }else{
             res.setHeader('Content-Type', 'text/html');
            res.setStatusCode(200);
            res.setBody('SUCCESS');
             res.setBody('{"access_token": system.label.NL_Client_Id}'); 
            return res ;
         }
    }


}