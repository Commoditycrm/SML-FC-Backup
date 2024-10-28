public class RedesignAC_NL_to_SF_CalloutBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public Integer totalFailureRecords = 0;
    public List<String> failureMsgs = new List<String>();
    public String queryName; 
    public string query;
    public string dayQuery = 'DayQuery';
    public Static string monthQuery = 'MonthQuery';
    public string tokenLeased;
    public string tokenOwned;
    public string currentOwnedAccount = '';
	public Datetime expirationTime;
    public String batchDataCustomStr = 'SF to NL Config Update Batch';
    
    //contructor for testing single record - chandru
    public RedesignAC_NL_to_SF_CalloutBatch(String query,Boolean forTesting){
        this.query = query;
    }
    
    //Main Contructor - Chandru
    public RedesignAC_NL_to_SF_CalloutBatch(String queryName){
        this.queryName = queryName;
        this.query = null;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        try {
            batchStartTime = system.now();
            expirationTime = Datetime.now().addMinutes(50);
            List<Batch_Data_Custom__c> batchData = [select Id, Batch_Name__c from Batch_Data_Custom__c where 
                                                    Batch_Name__c = :batchDataCustomStr and Status__c = 'Processing'];
            if(batchData.size() > 0) {
                return null;
            }

            if(string.isBlank(query)){                
                String Master_Configuration_check;
                Master_Configuration_check =  queryName== dayQuery ? 'Master_Configuration_check__c=false' : 'Master_Configuration_check__c=true';
                query = 'SELECT Device_id__c, Desired_Blank_Check__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c FROM Asset_Configuration__c WHERE recordType.DeveloperName = \'Asset\' AND Asset__r.Account.Ignore_Account_for_Callout__c = false AND Asset__r.Last_Connected__c = Last_n_Days:30 AND ';
                query += Master_Configuration_check + ' Order By Asset__r.AccountId';
                // Hardcoded Account only for FC 3 accounts
			    //query += ' AND Asset__r.Account.Name in (\'Testing\', \'Available\', \'SMART Plant - Minnesota\')';
            }
            tokenLeased = Utilityclass.generatetoken('Leased');
            //tokenOwned = Utilityclass.generatetoken('Owned');
            return Database.getQuerylocator(query);            
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_NL_to_SF_CalloutBatch', 'start', null, null, null, true);            
        }
        return null;
    }
    
    public void execute(Database.BatchableContext bc, List<Asset_configuration__c> assets){
        
        string authorize;
        totalRecords+=assets.size();
        try{
            List<asset_configuration__c> assetconfigtoUpdate = new List<asset_configuration__c>();
            for(asset_configuration__c asts : assets){
                   
                string response;        
                string deviceId = asts.Device_Id__c;
                HttpResponse res =new HttpResponse();             
               // try{
                    if(expirationTime <= Datetime.now()){
tokenLeased = Utilityclass.generatetoken('Leased');
            //tokenOwned = Utilityclass.generatetoken('Owned');
                                    expirationTime = Datetime.now().addMinutes(50);
                    }
                    if(asts.Asset__r.Account.Device_Ownership__c == 'Owned' && currentOwnedAccount != asts.Asset__r.Account.Account_Unique1_ID__c){
                        tokenOwned = Utilityclass.generatetoken(asts.Asset__r.Account.Account_Unique1_ID__c);
                        currentOwnedAccount = asts.Asset__r.Account.Account_Unique1_ID__c;
                    }
                    string finalToken = asts.Asset__r.Account.Device_Ownership__c == 'Leased' ? tokenLeased : tokenOwned;
                authorize = 'Bearer'+' '+ finalToken; 
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
                        assetconfigtoUpdate.add(asts);
                        response=res.getBody();
                        map<string,Object> lst_JsonParse = new map<string,Object>();
                        if(res.getBody() != null)
                            lst_JsonParse = (map<string,Object>)Json.deserializeUntyped(res.getBody()); 
                        
                        map<string,object> configMap = new map<string,object>();
                        
                        if(lst_JsonParse.containskey('config')){
                            configMap = (map<string,object>) lst_JsonParse.get('config');
                        }

                        //Update all desired fields if Desired_Blank_Check__c = true
                        if(queryName != monthQuery && asts.Desired_Blank_Check__c){
                            updateConfigDesired(asts,configMap);
                        }
                        /*if (queryName == monthQuery){
            				Date dt = Date.valueOf(system.now());
           				 	asts.callout_date__c =dt;
        				}*/
                        //Update all reported fields 
                        updateConfigReported(asts,configMap, queryName);
                    }
                    else {
                        system.debug(res.getBody());
						system.debug(res.getStatusCode());
						system.debug(res.getStatus());                   
                         }
                /*}
                catch(exception ex){
                    RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_NL_to_SF_CalloutBatch', 'execute', 'API Error', asts.Device_id__c, null, true);
                    Utilityclass.sendemailtoadmin(ex); 
                } */
            }
            if(!assetconfigtoUpdate.isEmpty()){
                upsert assetconfigtoUpdate ; 
            }
        } catch(Exception exp) {
            RedesignNL_CaptureErrors.createErrorLogs(exp,'RedesignAC_NL_to_SF_CalloutBatch', 'execute', 'Exception', null, null, true);
            failureMsgs.add(exp.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    public void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest()){ }           
        
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = 'Configuration Batch';
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
        batchLog.Status__c = 'Completed';
        batchLog.Total_no_of_records_processed__c = totalRecords;
        insert batchLog;   
        if(queryName == monthQuery){
            //Database.executeBatch(new AssetConfig_report_Batch(Date.today()), 1000);
        }
    }
    
    public static void updateConfigDesired(asset_configuration__c asts,map<string,object> configMap ){        
        map<string,object> desiredMap = new map<string,object>();
        map<string,object> accelMap = new map<string,object>();
        map<string,object> trackmap = new map<string,object>();
        map<string,object> tiltmap = new map<string,object>();
        map<string,object> locMap = new map<string,object>();
        map<string,object> networkMap = new map<string,object>();
        map<string,object> tempMap = new map<string,object>();
        map<string,object> bleMap = new map<string,object>();   //For BLE Enabled - Not stored now
        
        if(configMap.containskey('desired')){
            desiredMap = (map<string,object>) configMap.get('desired');  
        }
        
        if(desiredMap.containskey('accelerometer')){
            accelMap = (map<string,object>)desiredMap.get('accelerometer');
            trackmap = (map<string,object>)accelMap.get('tracking');
            tiltmap = (map<string,object>)accelMap.get('tilt');
            if(accelMap.containskey('enabled'))
                asts.Accelerometer_Status_Desired__c = string.valueof(accelMap.get('enabled'));
            if(accelMap.containskey('mode'))
                asts.Trackmode_Desired__c = string.valueof(accelMap.get('mode')); 
            if(accelMap.containskey('measurement_period'))
                asts.Measurement_Period_desired__c = string.valueof(accelMap.get('measurement_period'));
            if(trackmap != null){
                if(trackmap.containskey('connect_on_movement_start'))
                    asts.ConnectMovementStart_Desired__c=string.valueof(trackmap.get('connect_on_movement_start'));
                if(trackmap.containskey('connect_on_movement_end'))
                    asts.ConnectMovementEnd_Desired__c=string.valueof(trackmap.get('connect_on_movement_end'));
                if(trackmap.containskey('locations_per_checkin'))
                    asts.Tracking_Locations_per_Check_Ins_Desired__c=string.valueof(trackmap.get('locations_per_checkin'));
                if(trackmap.containskey('location_period'))
                    asts.Tracking_Location_Period_desired__c=string.valueof(trackmap.get('location_period'));
            }
            if(tiltmap != null){
                if(tiltmap.containskey('connect_on_tilt'))
                    asts.Connect_On_Tilt_Desired__c= string.valueof(tiltmap.get('connect_on_tilt'));
                if(tiltmap.containskey('log_every_n'))
                    asts.Log_Every_n_Desired__c= Integer.valueof(tiltmap.get('log_every_n'));
                if(tiltmap.containskey('degrees'))
                    asts.Tilt_Degrees_Desired__c= Integer.valueof(tiltmap.get('degrees'));
                if(tiltmap.containskey('reference_x'))
                    asts.Reference_X_Desired__c=Integer.valueof(tiltmap.get('reference_x'));
                if(tiltmap.containskey('reference_y'))
                    asts.Reference_Y_Desired__c=Integer.valueof(tiltmap.get('reference_y'));
                if(tiltmap.containskey('reference_z'))
                    asts.Reference_Z_Desired__c=Integer.valueof(tiltmap.get('reference_z'));
            }
        } 
        
        if(desiredMap.containskey('location')){
            locMap = (map<string,object>)desiredMap.get('location');
            if(locMap.containskey('sampling_period'))
                asts.Location_Sampling_Period_Desired__c = string.valueof(locMap.get('sampling_period'));
            if(locMap.containskey('enabled'))  
                asts.Location_Status_Desired__c = string.valueof(locMap.get('enabled'));
            if(locMap.containskey('useCell'))
                asts.Use_Cell_Desired__c = string.valueof(locMap.get('useCell'));
            if(locMap.containskey('useGPS'))
                asts.Use_GPS_Desired__c = string.valueof(locMap.get('useGPS'));
            if(locMap.containskey('useWiFi'))
                asts.Use_WiFi_Desired__c = string.valueof(locMap.get('useWiFi'));
        }        
        
        if(desiredMap.containskey('network')){
            networkMap = (map<string,object>)desiredMap.get('network');
            if(networkMap.containskey('period'))
                asts.Network_Check_in_period_Desired__c = string.valueof(networkMap.get('period'));
        }        
        
        if(desiredMap.containskey('temperature')){
            tempMap = (map<string,object>)desiredMap.get('temperature');
            if(tempMap.containskey('enabled'))
                asts.Temperature_Status_Desired__c = string.valueof(tempMap.get('enabled'));
            if(tempMap.containskey('sampling_period'))
                asts.Temperature_Check_in_Period_Desired__c = string.valueof(tempMap.get('sampling_period'));
            
        }
    }
    
    public static void updateConfigReported(asset_configuration__c asts,map<string,object> configMap, String queryName ){
        map<string,object> reportedMap = new map<string,object>();
        map<string,object> accelMap = new map<string,object>();
        map<string,object> trackmap = new map<string,object>();
        map<string,object> tiltmap = new map<string,object>();
        map<string,object> locMap = new map<string,object>();
        map<string,object> networkMap = new map<string,object>();
        map<string,object> tempMap = new map<string,object>();
        
        if (queryName == monthQuery && queryName == monthQuery){
            				Date dt = Date.valueOf(system.now());
           				 	asts.callout_date__c =dt;
        				}
        
        if(configMap.containskey('reported')){
            reportedMap = (map<string,object>) configMap.get('reported');
        } 
        
        if(reportedMap.containskey('accelerometer')){
            accelMap = (map<string,object>) reportedMap.get('accelerometer');
            trackmap =(map<string,object>)accelMap.get('tracking');
            tiltmap =(map<string,object>)accelMap.get('tilt');
            if(string.valueof(accelMap.get('enabled')) != null)
                asts.Accelerometer_Status_Reported__c =string.valueof(accelMap.get('enabled'));
            else
                asts.Accelerometer_Status_Reported__c = 'false';   
            if(accelMap.containskey('mode'))
                asts.Trackmode_Reported__c=string.valueof(accelMap.get('mode'));
            if(accelMap.containskey('measurement_period'))
                asts.Measurement_Period_Reported__c=string.valueof(accelMap.get('measurement_period'));
            if(string.valueof(trackmap.get('connect_on_movement_start')) != null)
                asts.ConnectMovementStart_Reported__c=string.valueof(trackmap.get('connect_on_movement_start'));
            else
                asts.ConnectMovementStart_Reported__c = 'false';
            if(string.valueof(trackmap.get('connect_on_movement_end')) != null)
                asts.ConnectMovementEnd_Reported__c=string.valueof(trackmap.get('connect_on_movement_end'));
            else
                asts.ConnectMovementEnd_Reported__c='false';   
            if(trackmap.containskey('locations_per_checkin'))
                asts.Tracking_Locations_per_Check_Ins_Reporte__c=string.valueof(trackmap.get('locations_per_checkin'));
            if(trackmap.containskey('location_period'))
                asts.Tracking_Location_Period_Reported__c=string.valueof(trackmap.get('location_period'));
            
            if(tiltmap != null){
                if(tiltmap.containskey('connect_on_tilt'))
                    asts.Connect_On_Tilt_Reported__c= string.valueof(tiltmap.get('connect_on_tilt'));
                if(tiltmap.containskey('log_every_n'))
                    asts.Log_Every_n_Reported__c= Integer.valueof(tiltmap.get('log_every_n'));
                if(tiltmap.containskey('degrees'))
                    asts.Tilt_Degrees_Reported__c= Integer.valueof(tiltmap.get('degrees'));
                if(tiltmap.containskey('reference_x'))
                    asts.Reference_X_Reported__c=Integer.valueof(tiltmap.get('reference_x'));
                if(tiltmap.containskey('reference_y'))
                    asts.Reference_Y_Reported__c=Integer.valueof(tiltmap.get('reference_y'));
                if(tiltmap.containskey('reference_z'))
                    asts.Reference_Z_Reported__c=Integer.valueof(tiltmap.get('reference_z'));
            }
            
        } 
        
        if(reportedMap.containskey('location')){
            locMap = (map<string,object>) reportedMap.get('location');
            if(locMap.containskey('sampling_period'))
                asts.Location_Sampling_Period_reported__c=string.valueof(locMap.get('sampling_period'));
            if(string.valueof(locMap.get('enabled')) != null)
                asts.Location_Status_reported__c=string.valueof(locMap.get('enabled'));
            else
                asts.Location_Status_reported__c = 'false';    
            asts.Use_Cell_Reported__c = locMap.get('useCell') != null ? string.valueof(locMap.get('useCell')): 'False';
            asts.Use_GPS_Reported__c = locMap.get('useGPS') != null ? string.valueof(locMap.get('useGPS')): 'False';
            asts.Use_Wifi_Reported__c = locMap.get('useWiFi') != null ? string.valueof(locMap.get('useWiFi')): 'False';
        }                        
        
        if(reportedMap.containskey('network')){
            networkMap = (map<string,object>) reportedMap.get('network');
            if(networkMap.containskey('period'))
                asts.Network_Check_in_period_reported__c =string.valueof(networkMap.get('period'));
        }                        
        
        if(reportedMap.containskey('temperature')){
            tempMap = (map<string,object>) reportedMap.get('temperature');
            if(string.valueof(tempMap.get('enabled')) != null)
                asts.Temperature_Status_reported__c =string.valueof(tempMap.get('enabled'));
            else
                asts.Temperature_Status_reported__c = 'false';  
            if(tempMap.containskey('sampling_period'))
                asts.Temperature_Check_in_Period_reported__c =string.valueof(tempMap.get('sampling_period'));
            
        }
        
        //For BLE Configuration 
        map<string,object> BLEMap = new map<string,object>();
    }
    public static void testing(){
        
        For(Account acc:[Select id,(select id from assets limit 1) from account]){
            
        }
    }
}