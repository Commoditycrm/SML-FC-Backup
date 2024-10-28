public class getconfigurationNimbelink {

    @future(callout = true)
    public static void getCofigs2(string deviceId){
        getCofigs(deviceId);
    } 
    
    public static void getCofigs(string deviceId){
        system.debug('deviceid'+deviceId);
        string response;
        string assetid;
        string token = Utilityclass.generatetoken();
        HttpResponse res =new HttpResponse();
        Asset asts =[select Id,name,Device_id__c,Measurement_Period_desired__c,Measurement_Period_Reported__c,Config_Check_Reported__c,Accelerometer_Status_Desired__c, Trackmode_Desired__c, ConnectMovementStart_Desired__c, ConnectMovementEnd_Desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Location_Period_Desired__c,Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c, Use_Wifi_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Network_Check_in_period_Desired__c FROM Asset where Device_Id__c =:deviceId];
                system.debug('deviceidquery'+asts);
        assetid=asts.Id;
        system.debug('assetid'+assetid);

        try{
            string authorize = 'Bearer'+' '+ token;
            Http h1 = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(60000);
            req.setMethod('GET');
            req.setHeader('content-type','application/json');
            req.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34'); 
            req.setHeader('Authorization', authorize); 
            string endpt = 'https://api.iot.nimbelink.net/v1/devices/'+deviceId+'/config';
            system.debug(endpt);    
            req.setEndpoint(endpt);
            system.debug(req);
            res=h1.send(req);
            response=res.getBody();
            system.debug('res---'+response);
           
            map<string,Object> lst_JsonParse = new map<string,Object>();
            if(res.getBody() != null)
                lst_JsonParse = (map<string,Object>)Json.deserializeUntyped(res.getBody()); 
            system.debug('parse--'+lst_JsonParse);
            map<string,object> configMap = new map<string,object>();
            if(lst_JsonParse.containskey('config')){
                configMap = (map<string,object>) lst_JsonParse.get('config');
                system.debug('configMap---'+configMap);    
            }
            
            //Newly Added
            System.debug('Config Reported Flag'+asts.Config_Check_Reported__c);
           if(asts.Config_Check_Reported__c)
                updateConfigparams(asts,configMap);
            map<string,object> desiredMap = new map<string,object>();
            if(configMap.containskey('reported')){
                desiredMap = (map<string,object>) configMap.get('reported');
                system.debug('desiredMap---'+desiredMap);    
            }
            
            map<string,object> accelMap = new map<string,object>();
            map<string,object> trackmap = new map<string,object>();
            map<string, object> tiltReportedMap = new map<string, object>();
            
            if(desiredMap.containskey('accelerometer')){
                accelMap = (map<string,object>) desiredMap.get('accelerometer');
                trackmap =(map<string,object>)accelMap.get('tracking');
                tiltReportedMap =(map<string,object>)accelMap.get('tilt');
                system.debug('accelMap---'+accelMap); 
                system.debug('trackmap---'+trackmap);
                system.debug('tiltMap---'+ tiltReportedMap);
                if(string.valueof(accelMap.get('enabled')) != null)
                    asts.Accelerometer_Status_Desired__c =string.valueof(accelMap.get('enabled'));
                else
                    asts.Accelerometer_Status_Desired__c = 'false';   
                if(accelMap.containskey('mode'))
                asts.Trackmode_Desired__c=string.valueof(accelMap.get('mode'));
                if(accelMap.containskey('measurement_period'))
                asts.Measurement_Period_Reported__c=string.valueof(accelMap.get('measurement_period'));
                if(string.valueof(trackmap.get('connect_on_movement_start')) != null)
                    asts.ConnectMovementStart_Desired__c=string.valueof(trackmap.get('connect_on_movement_start'));
                else
                    asts.ConnectMovementStart_Desired__c = 'false';
                if(string.valueof(trackmap.get('connect_on_movement_end')) != null)
                    asts.ConnectMovementEnd_Desired__c=string.valueof(trackmap.get('connect_on_movement_end'));
                else
                    asts.ConnectMovementEnd_Desired__c='false';   
                if(trackmap.containskey('locations_per_checkin'))
                asts.Tracking_Locations_per_Check_Ins_Desired__c=string.valueof(trackmap.get('locations_per_checkin'));
                if(trackmap.containskey('location_period'))
                asts.Tracking_Location_Period_Desired__c=string.valueof(trackmap.get('location_period'));
                 if (tiltReportedMap.containsKey('degrees')) {
                    asts.Tilt_Degrees_Reported__c = (Decimal) tiltReportedMap.get('degrees');
                }
                if (tiltReportedMap.containsKey('connect_on_tilt')) {
                    asts.Connect_On_Tilt_Reported__c = string.valueof(tiltReportedMap.get('connect_on_tilt'));
                }
                if (tiltReportedMap.containsKey('log_every_n')) {
                    asts.Log_Every_n_Reported__c = (Decimal) tiltReportedMap.get('log_every_n');
                }
                if (tiltReportedMap.containsKey('reference_x')) {
                    system.debug('tiltReported x '+ tiltReportedMap.get('reference_x'));
                    asts.Reference_X_Reported__c = (Decimal) tiltReportedMap.get('reference_x');
                }
                if (tiltReportedMap.containsKey('reference_y')) {
                    system.debug('tiltReported y '+ tiltReportedMap.get('reference_y'));
                    asts.Reference_Y_Reported__c = (Decimal) tiltReportedMap.get('reference_y');
                }
                if (tiltReportedMap.containsKey('reference_z')) {
                    system.debug('tiltReported z '+ tiltReportedMap.get('reference_z'));
                    asts.Reference_Z_Reported__c = (Decimal) tiltReportedMap.get('reference_z');
                }
                
            } 
          //  System.debug('Track loc period Reported : '+string.valueof(trackmap.get('location_period')));//added 25-11-2021
            map<string,object> locMap = new map<string,object>();
            if(desiredMap.containskey('location')){
                locMap = (map<string,object>) desiredMap.get('location');
                if(locMap.containskey('sampling_period'))
                asts.Location_Sampling_Period_Desired__c=string.valueof(locMap.get('sampling_period'));
                if(string.valueof(locMap.get('enabled')) != null)
                asts.Location_Status_Desired__c=string.valueof(locMap.get('enabled'));
                else
                asts.Location_Status_Desired__c = 'false';    
                //use cell
                if(string.valueof(locMap.get('useCell')) != null)
                    asts.Use_Cell_Desired__c =string.valueof(locMap.get('useCell'));
                else
                    asts.Use_Cell_Desired__c = 'false';   
                //use gps
                if(string.valueof(locMap.get('useGPS')) != null)
                    asts.Use_GPS_Desired__c =string.valueof(locMap.get('useGPS'));
                else
                    asts.Use_GPS_Desired__c = 'false';  
                //use wifi
                if(string.valueof(locMap.get('useWiFi')) != null)
                    asts.Use_Wifi_Desired__c =string.valueof(locMap.get('useWiFi'));
                else
                    asts.Use_Wifi_Desired__c = 'false';   
            }
            
            map<string,object> networkMap = new map<string,object>();
            if(desiredMap.containskey('network')){
                networkMap = (map<string,object>) desiredMap.get('network');
                if(networkMap.containskey('period'))
                  asts.Network_Check_in_period_Desired__c =string.valueof(networkMap.get('period'));
  
            }
            
            map<string,object> tempMap = new map<string,object>();
            if(desiredMap.containskey('temperature')){
                tempMap = (map<string,object>) desiredMap.get('temperature');
                if(string.valueof(tempMap.get('enabled')) != null)
                 asts.Temperature_Status_Desired__c =string.valueof(tempMap.get('enabled'));
                else
                  asts.Temperature_Status_Desired__c = 'false';  
                if(tempMap.containskey('sampling_period'))
                 asts.Temperature_Check_in_Period_Desired__c =string.valueof(tempMap.get('sampling_period'));
    
            }
            //For BLE Configuration 
            map<string,object> BLEMap = new map<string,object>();
           
            //END

        }
          
        catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
       System.debug('Asset config'+asts);
       Update asts;  
} 
    public static void updateConfigparams(asset asts,map<string,object> configMap ){
        
         map<string,object> desiredMap = new map<string,object>();
            if(configMap.containskey('desired')){
                desiredMap = (map<string,object>) configMap.get('desired');  
            }
            
            map<string, object> tiltMap = new map<string, object>();
            map<string,object> accelMap = new map<string,object>();
            map<string,object> trackmap = new map<string,object>();
            
            if(desiredMap.containskey('accelerometer')){
                accelMap = (map<string,object>) desiredMap.get('accelerometer');
                trackmap =(map<string,object>)accelMap.get('tracking');
                tiltMap =(map<string,object>)accelMap.get('tilt');
                if(accelMap.containskey('enabled'))
                asts.Accel_Enabled__c =string.valueof(accelMap.get('enabled'));
                if(accelMap.containskey('mode'))
                asts.Trackmode__c=string.valueof(accelMap.get('mode')); 
                    if(accelMap.containskey('measurement_period'))
                    asts.Measurement_Period_desired__c=string.valueof(accelMap.get('measurement_period'));
                if(trackmap != null){
                     if(trackmap.containskey('connect_on_movement_start'))
                    asts.ConnectMovementStart__c=string.valueof(trackmap.get('connect_on_movement_start'));
                    if(trackmap.containskey('connect_on_movement_end'))
                      asts.ConnectMovementEnd__c=string.valueof(trackmap.get('connect_on_movement_end'));
                    if(trackmap.containskey('locations_per_checkin'))
                      asts.Locations_per_Check_Ins__c=string.valueof(trackmap.get('locations_per_checkin'));
                    if(trackmap.containskey('location_period'))
                    asts.LocationPeriod__c=string.valueof(trackmap.get('location_period'));    
                  
                }
                if(tiltMap != null){
                        if (tiltMap.containsKey('degrees')) {
        asts.Tilt_Degrees_Desired__c = (Decimal)tiltMap.get('degrees');
    }
    if (tiltMap.containsKey('connect_on_tilt')) {
        asts.Connect_On_Tilt_Desired__c = string.valueof(tiltMap.get('connect_on_tilt'));
    }
        if (tiltMap.containsKey('log_every_n')) {
        asts.Log_Every_n_Desired__c = (Decimal)tiltMap.get('log_every_n');
    }
    if (tiltMap.containsKey('reference_x')) {
        asts.Reference_X_Desired__c = (Decimal)tiltMap.get('reference_x');
    }
    if (tiltMap.containsKey('reference_y')) {
        asts.Reference_Y_Desired__c = (Decimal)tiltMap.get('reference_y');
    }
    if (tiltMap.containsKey('reference_z')) {
        asts.Reference_Z_Desired__c = (Decimal)tiltMap.get('reference_z');
    }
                }
                } 
            map<string,object> locMap = new map<string,object>();
            if(desiredMap.containskey('location')){
                locMap = (map<string,object>) desiredMap.get('location');
                if(locMap.containskey('sampling_period'))
           asts.Sampling_Period__c=string.valueof(locMap.get('sampling_period'));
            if(locMap.containskey('enabled'))  
           asts.Loc_Enabled__c=string.valueof(locMap.get('enabled'));
                if(locMap.containskey('useCell'))
           asts.Use_Cell__c =string.valueof(locMap.get('useCell'));
                if(locMap.containskey('useGPS'))
           asts.Use_GPS__c =string.valueof(locMap.get('useGPS'));
                if(locMap.containskey('useWiFi'))
           asts.Use_WiFi__c  =string.valueof(locMap.get('useWiFi'));

            }
            
            map<string,object> networkMap = new map<string,object>();
            if(desiredMap.containskey('network')){
                networkMap = (map<string,object>) desiredMap.get('network');
                if(networkMap.containskey('period'))
                  asts.Check_in_period__c =string.valueof(networkMap.get('period'));
    
            }
            
            map<string,object> tempMap = new map<string,object>();
            if(desiredMap.containskey('temperature')){
                tempMap = (map<string,object>) desiredMap.get('temperature');
                if(tempMap.containskey('enabled'))
                 asts.Temp_Enabled__c =string.valueof(tempMap.get('enabled'));
                if(tempMap.containskey('sampling_period'))
                 asts.Temperature_Check_in_Period__c =string.valueof(tempMap.get('sampling_period'));
 
            }
       //FOR BLE Enabled 
        map<string,object> bleMap = new map<string,object>();
         

    }  
}