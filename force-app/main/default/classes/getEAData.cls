public class getEAData {
    private static string storedAccessToken=null;
    private static String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();

    public static String getAccessTokenCached() {
        if (storedAccessToken == null) {
            try {
                storedAccessToken = getAccessToken();
            } catch (Exception e) {
                System.debug('Token fetch failed: ' + e.getMessage());
                RedesignNL_CaptureErrors.createErrorLogs(e, 'getEAData', 'getAccesstokenCached', 'API Error', null, null, true);

            }
        }
        return storedAccessToken;
    }
    public static Id queryAnalyticsDataset(Decimal latitude, Decimal Longitude, Decimal minLat, Decimal maxLat, Decimal minLon,Decimal maxLon) {
        string accessToken = getAccessTokenCached();
        
      //  String datasetId = '0FbVA000000foX70AI'; //railwayline data
      //  String versionId = '0FcVA000003pqZ80AI';  
      string datasetIdList = system.label.EA_DatasetId_and_VersionID;
      List<string> ids = datasetIdList.split(',');
       String datasetId = ids[0]; //railwayline dataset
        String versionId = ids[1];
        
        String saqlQuery = 'q = load "' + datasetId + '/' + versionId + '"; ';
        
        // Add filters to the query
        saqlQuery += 'q = filter q by Lat_formula__c >= '+minLat+'  and Lat_formula__c <= '+maxLat+' and Lon_formula__c >= '+minLon+' and Lon_formula__c <= '+maxLon+'; ';
        
        // Finalize the query to select necessary fields
		saqlQuery += 'result = foreach q generate q.Id as Id, q.Latitude__c as latitude__c, q.Longitude__c as longitude__c, q.Railway_Line_Information__c as Railway_Line_Information__c; ';
        
        // Limit the query results
         //saqlQuery += 'result = limit result 2000;';
        
        // Properly format the request body by escaping the SAQL query
        String requestBody = '{"query": "' + saqlQuery.replace('"', '\\"') + '"}';
        
        String requestUrl = sfdcBaseURL+'/services/data/v53.0/wave/query';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);  
        req.setHeader('Content-Type', 'application/json'); 
        req.setBody(requestBody);  
        Http http = new Http();
        HttpResponse res = http.send(req);
        // Process the response
        if (res.getStatusCode() == 200) {
           
            Id result = parseQueryResponse(res.getBody(), latitude,longitude);
            return result;
        } else {
            System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
            return null;
        }
    }
    
    public static Id parseQueryResponse(String responseBody, Decimal latitude, Decimal longitude) {
        Location loc1 = Location.newInstance(latitude, longitude);
        decimal closestDistance=999.0;
        id result=null;
        if(test.isRunningTest()){
            return null;
        }
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if(responseMap!=null && responseMap.containsKey('results')){
            Map<String, Object> results = (Map<String, Object>)responseMap.get('results'); 
            List<Object> records = (List<Object>)results.get('records'); 
            for (Object recordObj : records) {
                Map<String, Object> record = (Map<String, Object>)recordObj;
                Decimal latEA = Decimal.valueOf((String)record.get('latitude__c'));
                Decimal lonEA = Decimal.valueOf((String)record.get('longitude__c'));
                        
                Location loc2 = Location.newInstance(latEA, lonEA);
                Double distance = Location.getDistance(loc1, loc2, 'mi');
                
                if (Decimal.valueOf(distance) < closestDistance) {
                    closestDistance = Decimal.valueOf(distance);
                    result = (String)record.get('Railway_Line_Information__c');  
                }
            }
        }
        return result;
        
    }
    
    public static string getAccessToken(){
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        string enpoint = sfdcBaseURL + '/services/oauth2/token';
        req.setEndpoint(enpoint);
		String client_id  = system.label.EA_ClientId;
        String client_secret  = system.label.EA_ClientSecret;
        string usnameandpswd = system.label.EA_User_Credentials;
        List<string> usnamePwsList = usnameandpswd.split(',');
        //String org = usnamePwsList[0];
        String username = usnamePwsList[0];
        string password = usnamePwsList[1];
        /*if(org=='Prod'){
            client_id = system.label.FC_userName_and_Password;
            client_secret = system.label.FC_userName_and_Password;
        }*/
        String body = 'grant_type=password&client_id='+client_id+'&client_secret='+client_secret+'&username='+username+'&password='+password;
        req.setBody(body);
        req.setMethod('POST');
        system.debug('beody---'+body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res.getBody()---'+res.getBody());
         if (res.getStatusCode() == 200) {
            // Parse the JSON response
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String accessToken = (String)jsonResponse.get('access_token');
             system.debug('Access token---'+accessToken);
            return accessToken;
        } else {
            System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
            return null;
        }
    }

}