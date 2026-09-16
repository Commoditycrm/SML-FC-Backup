public class RedesignAC_SyncAssetConfig {
    
    @InvocableMethod(label='SyncAssetConfigForSingleRecord')
    public static list<result> SyncAssetConfigForSingleRecord(List<Request> reqList){
        try {
            //string token = Utilityclass.generatetoken();
            //string token = Utilityclass.generatetoken('OwnedDevices');
            //string authorize = 'Bearer'+' '+ token;
            
            id astId = reqList[0].recordId;
            
            Asset_Configuration__c astcon = [SELECT Device_id__c, Measurement_Period_desired__c,Measurement_Period_Reported__c,Desired_Blank_Check__c,
                                             Accelerometer_Status_Desired__c, Trackmode_Desired__c, ConnectMovementStart_Desired__c, ConnectMovementEnd_Desired__c,
                                             Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Location_Period_Desired__c,Location_Sampling_Period_Desired__c, 
                                             Location_Status_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c, Use_Wifi_Desired__c, Asset__r.Is_Loco_Asset__c, 
                                             Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Network_Check_in_period_Desired__c,
                                             Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c,
                                             Reference_Z_Desired__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c, Impact_Alert_Desired__c, 
                                             Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                                             Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, 
                                             Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, 
                                             Alert_Threshold_High_Desired__c, Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c  
                                             FROM Asset_Configuration__c 
                                             WHERE Asset__c =: astId];
            List<Result> resLst = new list<Result>();
            if(astcon.Asset__r.Is_Loco_Asset__c){
                string token = System.Label.Loco_Ware_Config_Key;
                string authorize = 'Bearer'+' '+ token;
                resLst.add(getResponseFromLoco(astcon, authorize));
            }else{
                String DeviceType = astcon.Asset__r.Account.Device_Ownership__c == 'Leased' ? astcon.Asset__r.Account.Device_Ownership__c : astcon.Asset__r.Account.Account_Unique1_ID__c;
                string token = Utilityclass.generatetoken(DeviceType);
                string authorize = 'Bearer'+' '+ token;
                resLst.add(getResponseFromNimbelink(astcon, authorize));
            }
            return resLst;            
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_SyncAssetConfig', 'SyncAssetConfigForSingleRecord', null, null, null, true);            
        }
        return null;
    }
    public static Result getResponseFromNimbelink(Asset_Configuration__c astcon, String authorize) {
        Result rest =  new Result();
        String Asset_Configuration_400_error = system.label.Asset_Configuration_400_error;
        String Asset_Configuration_401_error = system.label.Asset_Configuration_401_error;
        String Asset_Configuration_403_error = system.label.Asset_Configuration_403_error;
        String CommonException = system.label.Common_Exception_For_Nimblink;
        String Asset_Configuration_Sync_success = system.label.Asset_Configuration_Sync_success;        
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
                Integer statusCode = res.getStatusCode();
                if (statusCode==200){
                    
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
                rest.response = Asset_Configuration_Sync_success;
                }
                
                else {
                rest.response = statusCode==400 ? Asset_Configuration_400_error : statusCode==401 ? Asset_Configuration_401_error : statusCode==403 ? Asset_Configuration_403_error : CommonException ;
                }
                
            }
            catch(exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_SyncAssetConfig', 'getResponseFromNimbelink', null, null, null, true);            
                Utilityclass.sendemailtoadmin(ex);
                rest.response = CommonException;  
            }     
        upsert astcon;
        return rest;
    }

    public static Result getResponseFromLoco(Asset_Configuration__c astcon, String authorize) {
        Result result = new Result();
        String badRequest = system.label.Asset_Configuration_400_error;
        String unAuthorized = system.label.Asset_Configuration_401_error;
        String forbidden = system.label.Asset_Configuration_403_error;
        String commonException = system.label.Common_Exception_For_Nimblink;
        string deviceId = astcon.Device_Id__c;
        try{Http h1 = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setMethod('GET');
        req.setHeader('Authorization', authorize); 
        string endpt = 'https://locoaware.com/api/device/'+ deviceId +'/settings';
        req.setEndpoint(endpt);
        HttpResponse res = h1.send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode==200){
            map<string,Object> responseJson = new map<string,Object>();
            if(res.getBody() != null){
                responseJson = (map<string,Object>)Json.deserializeUntyped(res.getBody());
                if(responseJson.containskey('active')){
                    updateLocoActive(astcon,responseJson);
                }
                if(astcon.Desired_blank_check__c == true && responseJson.containskey('pending')){
                    updateLocoPending(astcon,responseJson);
                    }
            }
                         
            result.response = 'Request processed successfully. Refresh and check again.';
        } else {
            result.response = statusCode==400 ? badRequest : statusCode==401 ? unAuthorized : statusCode==403 ? forbidden : commonException ;
        }
    }catch(exception ex){
        RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_SyncAssetConfig', 'getResponseFromLoco', null, null, null, true);            
        Utilityclass.sendemailtoadmin(ex);
    }
    upsert astcon;
    return result;
}

public static void updateLocoActive(asset_configuration__c asts,map<string,object> configMap ){  
    Map<String, Object> reportedMap = new Map<String, Object>();      
        reportedMap = (map<string,object>) configMap.get('active');
        if(reportedMap.containskey('loggingPeriod')){
            asts.Location_Sampling_Period_reported__c=string.valueof(reportedMap.get('loggingPeriod'));
        }
        if(reportedMap.containskey('wakeupPeriod')){
            asts.Network_Check_in_period_reported__c =string.valueof(reportedMap.get('wakeupPeriod'));
        }
        if(reportedMap.containskey('logCollectWifi')){
            asts.Use_Wifi_Reported__c = string.valueof(reportedMap.get('logCollectWifi'));
        }
        if(reportedMap.containskey('logCollectCell')){
            asts.Use_Cell_Reported__c = string.valueof(reportedMap.get('logCollectCell'));
        }
        if(reportedMap.containskey('logFullGps')){
            asts.Use_Gps_Reported__c = string.valueof(reportedMap.get('logFullGps'));
        }
        if(reportedMap.containskey('temperatureLogging')){
            asts.Temperature_Status_reported__c = string.valueof(reportedMap.get('temperatureLogging'));
        }
        /*if(reportedMap.containskey('temperatureLogging')){
            asts.Temperature_Check_in_Period_reported__c = string.valueof(reportedMap.get('temperatureLogging'));
        }*/
        if(reportedMap.containskey('enableMovementDetection')){
            asts.Accelerometer_Status_Reported__c = string.valueof(reportedMap.get('enableMovementDetection'));
        }
        if(reportedMap.containskey('moveWakeupPeriod')){
            asts.Tracking_Location_Period_Reported__c = string.valueof(reportedMap.get('moveWakeupPeriod'));
        }
        if(reportedMap.containskey('immediateMovementReport')){
           asts.ConnectMovementStart_Reported__c = string.valueof(reportedMap.get('immediateMovementReport'));
        }
        if(reportedMap.containskey('impactAlert')){
            asts.Impact_Alert_Reported__c = string.valueof(reportedMap.get('impactAlert'));
        }
        if(reportedMap.containskey('maxImpact')){
            asts.Max_Impact_Reported__c = Integer.valueof(reportedMap.get('maxImpact'));
        }
        if(reportedMap.containskey('movementAccuracy')){
            asts.Movement_Accuracy_Reported__c = Integer.valueof(reportedMap.get('movementAccuracy'));
        }
        if(reportedMap.containskey('timerAccuracy')){
            asts.Location_Accuracy_Reported__c = Integer.valueof(reportedMap.get('timerAccuracy'));
        }
        if(reportedMap.containskey('sensorLoggingPeriod')){
            asts.Sensor_Logging_Period_Reported__c = Integer.valueof(reportedMap.get('sensorLoggingPeriod'));
        }
        if (reportedMap.containskey('zMicroDetection')) {
            asts.Tag_Detection_Reported__c = string.valueof(reportedMap.get('zMicroDetection'));
        }
        if (reportedMap.containsKey('zMicroDeviceMinRSSINew')) {
            asts.Min_RSSI_Reported__c = Integer.valueof(reportedMap.get('zMicroDeviceMinRSSINew'));
        }
        if (reportedMap.containsKey('zMicroDeviceOldTime')) {
            asts.Missing_Tag_Report_Delay_Reported__c = Integer.valueof(reportedMap.get('zMicroDeviceOldTime'));
        }
        if (reportedMap.containsKey('zMicroRxPeriod')) {
            asts.Scan_for_Tags_Interval_Reported__c = Integer.valueof(reportedMap.get('zMicroRxPeriod'));
        }
        if (reportedMap.containsKey('zMicroRxTime')) {
            asts.Listen_Time_Reported__c = Integer.valueof(reportedMap.get('zMicroRxTime'));
        }
  }

  public static void updateLocoPending(asset_configuration__c asts,map<string,object> configMap ){  
    Map<String, Object> desiredMap = new Map<String, Object>();      
        desiredMap = (map<string,object>) configMap.get('pending');
        if(desiredMap.containskey('loggingPeriod')){
            asts.Location_Sampling_Period_desired__c=string.valueof(desiredMap.get('loggingPeriod'));
        }
        if(desiredMap.containskey('wakeupPeriod')){
            asts.Network_Check_in_period_Desired__c =string.valueof(desiredMap.get('wakeupPeriod'));
        }
        if(desiredMap.containskey('logCollectWifi')){
            asts.Use_WiFi_Desired__c = string.valueof(desiredMap.get('logCollectWifi'));
        }
        if(desiredMap.containskey('logCollectCell')){
            asts.Use_Cell_Desired__c = string.valueof(desiredMap.get('logCollectCell'));
        }
        if(desiredMap.containskey('logFullGps')){
            asts.Use_GPS_Desired__c = string.valueof(desiredMap.get('logFullGps'));
        }
        if(desiredMap.containskey('temperatureLogging')){
            asts.Temperature_Status_Desired__c = string.valueof(desiredMap.get('temperatureLogging'));
        }
        /*if(desiredMap.containskey('temperatureLogging')){
            asts.Temperature_Check_in_Period_Desired__c = string.valueof(desiredMap.get('temperatureLogging'));
        }*/
        if(desiredMap.containskey('enableMovementDetection')){
            asts.Accelerometer_Status_Desired__c = string.valueof(desiredMap.get('enableMovementDetection'));
        }
        if(desiredMap.containskey('moveWakeupPeriod')){
            asts.Tracking_Location_Period_Desired__c = string.valueof(desiredMap.get('moveWakeupPeriod'));
        }
        if(desiredMap.containskey('immediateMovementReport')){
           asts.ConnectMovementStart_Desired__c = string.valueof(desiredMap.get('immediateMovementReport'));
        }
        if(desiredMap.containskey('impactAlert')){
            asts.Impact_Alert_Desired__c = string.valueof(desiredMap.get('impactAlert'));
        }
        if(desiredMap.containskey('maxImpact')){
            asts.Max_Impact_Desired__c = Integer.valueof(desiredMap.get('maxImpact'));
        }
        if(desiredMap.containskey('movementAccuracy')){
            asts.Movement_Accuracy_Desired__c = Integer.valueof(desiredMap.get('movementAccuracy'));
        }
        if(desiredMap.containskey('timerAccuracy')){
            asts.Location_Accuracy_Desired__c = Integer.valueof(desiredMap.get('timerAccuracy'));
        }
        if(desiredMap.containskey('sensorLoggingPeriod')){
            asts.Sensor_Logging_Period_Desired__c = Integer.valueof(desiredMap.get('sensorLoggingPeriod'));
        }
        if (desiredMap.containskey('zMicroDetection')) {
            asts.Tag_Detection_Desired__c = string.valueof(desiredMap.get('zMicroDetection'));
        }
        if (desiredMap.containsKey('zMicroDeviceMinRSSINew')) {
            asts.Min_RSSI_Desired__c = Integer.valueof(desiredMap.get('zMicroDeviceMinRSSINew'));
        }
        if (desiredMap.containsKey('zMicroDeviceOldTime')) {
            asts.Missing_Tag_Report_Delay_Desired__c = Integer.valueof(desiredMap.get('zMicroDeviceOldTime'));
        }
        if (desiredMap.containsKey('zMicroRxPeriod')) {
            asts.Scan_for_Tags_Interval_Desired__c = Integer.valueof(desiredMap.get('zMicroRxPeriod'));
        }
        if (desiredMap.containsKey('zMicroRxTime')) {
            asts.Listen_Time_Desired__c = Integer.valueof(desiredMap.get('zMicroRxTime'));
        }
  }
    
    public class Request {
        @InvocableVariable(label='recordId' description='recordId' required='true')
        public String recordId;
        
    }
    public class Result {
        @InvocableVariable(label='response' description='response')
        public String response;
    }
    
}