public class ProdToUATNimblelink implements Queueable, Database.AllowsCallouts {
    
    public static void execute(QueueableContext context) {
        String authToken = basicAuthCallout();
        Nimbelink_Sync_Prod_Full_Copy__c sync = Nimbelink_Sync_Prod_Full_Copy__c.getOrgDefaults();
        Datetime updateddateTime = null;//Datetime.now();
        Datetime updateddateTimeGoogle = null;//Datetime.now();
        List<Api_Response__c> apiResponseList = [Select Name, createddate, Incoming_Messsage__c,ResEnteringDttime__c,ResEnteringTime__c,Is_Nimbelink_Asset__c,UpdateResponseToAsset__c,data__c,base__c,Device_Id__c,device_status__c,info__c,events__c,accel__c,Loc__c,Temp__c,Status__c,asset__c from Api_Response__c 
                                                 where Createddate >: sync.Last_Timestamp__c and Api_Callouts__c ='Nimbelink' order by Createddate DESC];
        
        List<Google_API_Data__c> googleApiList = [select id,createddate, Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                  where Createddate >: sync.Last_Timestamp_Google_API__c order by Createddate DESC];
        
        String googleOtpt = '';
        if(googleApiList.size()>0) {
            updateddateTimeGoogle = googleApiList[0].createddate;
            googleOtpt = ProdToUATNimblelink.httpGoogleCallout(authToken, JSON.serialize(googleApiList));
        }
        
        if(apiResponseList.size()>0 && (googleApiList.size() == 0 || (googleApiList.size()>0 && googleOtpt == 'SUCCESS'))) {
            updateddateTime = apiResponseList[0].createddate;
            String otpt = ProdToUATNimblelink.httpApiCallout(authToken, JSON.serialize(apiResponseList));
        }
        if(updateddateTime!=null)
        {
            sync.Last_Timestamp__c = updateddateTime;
        }
        if(updateddateTimeGoogle!=null)
        {
            sync.Last_Timestamp_Google_API__c = updateddateTimeGoogle;
        }
        if(updateddateTime!=null || updateddateTimeGoogle!=null)
        {
            update sync;
        }
    }
    public static string basicAuthCallout(){
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
         req.setEndpoint('callout:ProdtoFullcopy/services/oauth2/token');
       // req.setEndpoint('https://smartlogisticsinc--fullcopy.sandbox.my.salesforce.com/services/oauth2/token');
        String client_id = '3MVG9tYo_6NhaNhkBLDNR9ZFAd864xxyt6uwaCQNKlbfue2r0LoDA542xsRKEv5UqP_8GG4IRoivqajA9tB7Q';
        String client_secret = '8A580C8A83D2D59CB8552DA31E53EAA383D247E45CC9AC14AE878C7F22D44560';
       // String username = 'sfdcsupport1@commodityccrm.com.fullcopy';
       // String password = 'commoditycrm@August2024';
// String body = 'grant_type=password&client_id='+client_id+'&client_secret='+client_secret+'username='+username+'password='+password;

        String body = 'grant_type=password&client_id='+client_id+'&client_secret='+client_secret;
        req.setBody(body);
        req.setMethod('POST');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        authenticatorResponse auth = (authenticatorResponse)JSON.deserialize(res.getBody(), ProdToUATNimblelink.authenticatorResponse.class);
        system.debug('access_token---'+auth.access_token);
        return auth.access_token;
    }
    
    public static String httpApiCallout(String authToken, String requestBody) {
        HttpRequest req1 = new HttpRequest();
        req1.setTimeout(60000);
        req1.setEndpoint('https://smartlogisticsinc--fullcopy.sandbox.my.salesforce.com/services/apexrest/nimbeLinkProdToUAT/apiresponse');
        req1.setHeader('Authorization', 'Bearer '+authToken);
        req1.setHeader('Content-Type', 'application/json');
        req1.setMethod('POST');
        req1.setCompressed(true);
        req1.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        system.debug('body---'+res1.getBody());
        if(res1.getStatusCode() == 200)
            return 'SUCCESS';
        return null;
    }
    
    public static String httpGoogleCallout(String authToken, String requestBody) {
        HttpRequest req1 = new HttpRequest();
        req1.setTimeout(60000);
        req1.setEndpoint('https://smartlogisticsinc--fullcopy.sandbox.my.salesforce.com/services/apexrest/nimbeLinkProdToUAT/googleapi');
        req1.setHeader('Authorization', 'Bearer '+authToken);
        req1.setHeader('Content-Type', 'application/json');
        req1.setMethod('POST');
        req1.setCompressed(true);
        req1.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        system.debug('body---'+res1.getBody());
        if(res1.getStatusCode() == 200 && res1.getBody() == 'SUCCESS')
            return 'SUCCESS';
        return null;
    }    
    
    public class authenticatorResponse {
        public string access_token;
        public string instance_url;
        public string id;
        public string token_type;
        public string issued_at;
        public string signature;
        
    }
}