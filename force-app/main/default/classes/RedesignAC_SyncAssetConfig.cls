public class RedesignAC_SyncAssetConfig {
    
    @InvocableMethod(label='SyncAssetConfigForSingleRecord')
    public static list<result> SyncAssetConfigForSingleRecord(List<request> reqList){
        try {
            //string token = Utilityclass.generatetoken();
            //string token = Utilityclass.generatetoken('OwnedDevices');
            //string authorize = 'Bearer'+' '+ token;
            
            id astId = reqList[0].recordId;
            
            Asset_Configuration__c astcon = [SELECT Device_id__c, Measurement_Period_desired__c,Measurement_Period_Reported__c,Desired_Blank_Check__c,
                                             Accelerometer_Status_Desired__c, Trackmode_Desired__c, ConnectMovementStart_Desired__c, ConnectMovementEnd_Desired__c,
                                             Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Location_Period_Desired__c,Location_Sampling_Period_Desired__c, 
                                             Location_Status_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c, Use_Wifi_Desired__c,
                                             Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Network_Check_in_period_Desired__c,
                                             Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c,
                                              Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c
                                             FROM Asset_Configuration__c  Where Asset__c =: astId];
            List<Result> resLst = new list<Result>();
            String DeviceType = astcon.Asset__r.Account.Device_Ownership__c == 'Leased' ? astcon.Asset__r.Account.Device_Ownership__c : astcon.Asset__r.Account.Account_Unique1_ID__c ;
            string token = Utilityclass.generatetoken(DeviceType);
            string authorize = 'Bearer'+' '+ token;
            
            resLst.add(getResponseFromNimbelink(astcon, authorize));
            return resLst;            
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_SyncAssetConfig', 'SyncAssetConfigForSingleRecord', null, null, null, true);            
        }
        return null;
    }
    public static Result getResponseFromNimbelink(Asset_Configuration__c astcon, String authorize) {
        Result rest =  new Result();
        string response;
        string deviceId = astcon.Device_Id__c;
        HttpResponse res =new HttpResponse();             
        try{
            Http h1 = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(60000);
            req.setMethod('GET');
            req.setHeader('content-type','application/json');
            req.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34'); 
            req.setHeader('Authorization', authorize); 
            string endpt = 'https://api.iot.nimbelink.net/v1/devices/'+deviceId+'/config';
            req.setEndpoint(endpt);
            res=h1.send(req);
            if (res.getStatusCode()==200){
                
                response=res.getBody();
                
                map<string,Object> lst_JsonParse = new map<string,Object>();
                if(res.getBody() != null)
                    lst_JsonParse = (map<string,Object>)Json.deserializeUntyped(res.getBody()); 
                
                map<string,object> configMap = new map<string,object>();
                
                if(lst_JsonParse.containskey('config')){
                    configMap = (map<string,object>) lst_JsonParse.get('config');
                }
                
                //Update all desired fields if Desired_Blank_Check__c = true
                if(astcon.Desired_Blank_Check__c == true)
                    RedesignAC_NL_to_SF_CalloutBatch.updateConfigDesired(astcon,configMap);
                
                //Update all reported fields 
                RedesignAC_NL_to_SF_CalloutBatch.updateConfigReported(astcon,configMap, null);
                rest.response = 'Request processed successfully. Refresh and check again.';
            }
            
            else {
                rest.response = 'Request failed: '+res.getBody();
            }
            
        }
        catch(exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_SyncAssetConfig', 'getResponseFromNimbelink', null, null, null, true);            
            Utilityclass.sendemailtoadmin(ex);  
        }
        
        upsert astcon;
        return rest;
    }
    
    public class request {
        @InvocableVariable(label='recordId' description='recordId' required='true')
        public String recordId;
        
    }
    public class result {
        @InvocableVariable(label='response' description='response')
        public String response;
    }
    
}