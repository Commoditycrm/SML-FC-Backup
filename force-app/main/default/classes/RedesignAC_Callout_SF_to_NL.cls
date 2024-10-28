public class RedesignAC_Callout_SF_to_NL {    
    //running from flow. so no auraEnabled
    @AuraEnabled
    public static RestAPIResponseResult getParameter(Asset_Configuration__c astCon, String authorize, String Deviceid) {
        try {
            String trackmode;
            String MeasurementPeriod;
            Boolean accelEnabled;
            Boolean connectMovementStart;
            Boolean connectMovementEnd;
            String TrackinglocationPeriod;
            String TrackinglocPerCheckIns;
            Boolean locEnabled;
            String LocationsamplingPeriod;
            Boolean useGps;
            Boolean useCell;
            Boolean useWifi;
            String NetworkcheckInPeriod;
            Boolean tempEnabled;
            String Temperaturecheckinperiod;
            Boolean bleenabled;
            String blesamplingperiod;
            Decimal tiltDegrees;
            Boolean connectOnTilt;
            Decimal logEveryN;
            Decimal referenceX;
            Decimal referenceY;
            Decimal referenceZ;
            boolean trueVar = true;
            boolean falseVar = false;
            MeasurementPeriod = astCon.Measurement_Period_desired__c != null ? astCon.Measurement_Period_desired__c : MeasurementPeriod;
            trackmode = astCon.Trackmode_Desired__c != null ? astCon.Trackmode_Desired__c : trackmode;
            accelEnabled = astCon.Accelerometer_Status_Desired__c != null ? Boolean.valueOf(astCon.Accelerometer_Status_Desired__c) : accelEnabled;
            connectMovementStart = astCon.ConnectMovementStart_Desired__c != null ? Boolean.valueOf(astCon.ConnectMovementStart_Desired__c) : connectMovementStart;
            connectMovementEnd = astCon.ConnectMovementEnd_Desired__c != null ? Boolean.valueOf(astCon.ConnectMovementEnd_Desired__c) : connectMovementEnd;
            TrackinglocationPeriod = astCon.Tracking_Location_Period_desired__c != null ? astCon.Tracking_Location_Period_desired__c : TrackinglocationPeriod;
            TrackinglocPerCheckIns = astCon.Tracking_Locations_per_Check_Ins_Desired__c != null ? astCon.Tracking_Locations_per_Check_Ins_Desired__c : TrackinglocPerCheckIns;
            locEnabled = astCon.Location_Status_Desired__c != null ? Boolean.valueOf(astCon.Location_Status_Desired__c) : locEnabled;
            LocationsamplingPeriod = astCon.Location_Sampling_Period_Desired__c != null ? astCon.Location_Sampling_Period_Desired__c : LocationsamplingPeriod;
            useGps = astCon.Use_GPS_Desired__c != null ? Boolean.valueOf(astCon.Use_GPS_Desired__c) : useGps;
            useCell = astCon.Use_Cell_Desired__c != null ? Boolean.valueOf(astCon.Use_Cell_Desired__c) : useCell;
            useWifi = astCon.Use_WiFi_Desired__c != null ? Boolean.valueOf(astCon.Use_WiFi_Desired__c) : useWifi;
            NetworkcheckInPeriod = astCon.Network_Check_in_period_Desired__c != null ? astCon.Network_Check_in_period_Desired__c : NetworkcheckInPeriod;
            tempEnabled = astCon.Temperature_Status_Desired__c != null ? Boolean.valueOf(astCon.Temperature_Status_Desired__c) : tempEnabled;
            Temperaturecheckinperiod = astCon.Temperature_Check_in_Period_Desired__c != null ? astCon.Temperature_Check_in_Period_Desired__c : Temperaturecheckinperiod;
            connectOnTilt = astCon.Connect_On_Tilt_Desired__c != null ? (astCon.Connect_On_Tilt_Desired__c.equalsIgnoreCase('True') ? true : false): connectOnTilt;
            tiltDegrees = astCon.Tilt_Degrees_Desired__c != null ? Integer.valueOf(astCon.Tilt_Degrees_Desired__c) : tiltDegrees;
            logEveryN = astCon.Log_Every_n_Desired__c != null ? Integer.valueOf(astCon.Log_Every_n_Desired__c) : logEveryN;
            referenceX= astCon.Reference_X_Desired__c != null ? Integer.valueOf(astCon.Reference_X_Desired__c) : referenceX;
            referenceY = astCon.Reference_Y_Desired__c != null ? Integer.valueOf(astCon.Reference_Y_Desired__c) : referenceY;
            referenceZ = astCon.Reference_Z_Desired__c  != null ? Integer.valueOf(astCon.Reference_Z_Desired__c) : referenceZ;
            
            
            string accelBody;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            
            gen.writeFieldName('config');
            gen.writeStartObject();
            if(accelEnabled == true || (accelEnabled == null && (trackmode != null || MeasurementPeriod!=null || TrackinglocationPeriod != null || TrackinglocPerCheckIns != null || connectMovementStart != null || connectMovementEnd != null)) ){
                gen.writeFieldName('accelerometer');
                gen.writeStartObject();
                if(trackmode != null)
                    gen.writeNumberField('mode', integer.valueOf(trackmode));
                if(MeasurementPeriod!=null)
                    gen.writeNumberField('measurement_period', integer.valueOf(MeasurementPeriod));
                if(accelEnabled == true)
                    gen.writeBooleanField('enabled', trueVar);
                
                gen.writeFieldName('tracking');
                gen.writeStartObject();
                if(TrackinglocationPeriod != null)
                    gen.writeNumberField('location_period', integer.valueOf(TrackinglocationPeriod));
                if(TrackinglocPerCheckIns != null)
                    gen.writeNumberField('locations_per_checkin', integer.valueOf(TrackinglocPerCheckIns));
                if(connectMovementStart == true)
                    gen.writeBooleanField('connect_on_movement_start', truevar);
                if(connectMovementStart == false)
                    gen.writeBooleanField('connect_on_movement_start', falsevar);
                if(connectMovementEnd == true)
                    gen.writeBooleanField('connect_on_movement_end', truevar);
                if(connectMovementEnd == false)
                    gen.writeBooleanField('connect_on_movement_end', falsevar);
                gen.writeEndObject();
                
                gen.writeFieldName('tilt');
                gen.writeStartObject();
                if(tiltDegrees != null)
                    gen.writeNumberField('degrees', integer.valueOf(tiltDegrees));
                if(connectOnTilt == true)
                    gen.writeBooleanField('connect_on_tilt', truevar);
                if(connectOnTilt == false)
                    gen.writeBooleanField('connect_on_tilt', falsevar);
                if(logEveryN != null)
                    gen.writeNumberField('log_every_n', integer.valueOf(logEveryN));
                if(referenceX != null)
                    gen.writeNumberField('reference_x', integer.valueOf(referenceX));
                if(referenceY != null)
                    gen.writeNumberField('reference_y', integer.valueOf(referenceY));
                if(referenceZ != null)
                    gen.writeNumberField('reference_z', integer.valueOf(referenceZ));
                gen.writeEndObject();
                gen.writeEndObject();
                
            }else if(accelEnabled == false){
                gen.writeFieldName('accelerometer');
                gen.writeStartObject();            
                gen.writeBooleanField('enabled', falseVar);
                gen.writeEndObject();
            }
            if(locEnabled == true || (locEnabled == null && (useGps != null || useCell != null || useWifi != null || LocationsamplingPeriod != null ))){
                gen.writeFieldName('location');
                gen.writeStartObject();
                
                if(useGps == true)
                    gen.writeBooleanField('useGPS', truevar);
                if(useGps == false)
                    gen.writeBooleanField('useGPS', falsevar);
                if(useCell == true)
                    gen.writeBooleanField('useCell', truevar);
                if(useCell == false)
                    gen.writeBooleanField('useCell', falsevar);
                if(useWifi == true)
                    gen.writeBooleanField('useWiFi', truevar);
                if(useWifi == false)
                    gen.writeBooleanField('useWiFi', falsevar);
                if(locEnabled == true)
                    gen.writeBooleanField('enabled', trueVar);
                
                if(LocationsamplingPeriod != null)
                    gen.writeNumberField('sampling_period', integer.valueOf(LocationsamplingPeriod));        
                gen.writeEndObject();    
            }else if (locEnabled == false){
                gen.writeFieldName('location');
                gen.writeStartObject(); 
                gen.writeBooleanField('enabled', falseVar);
                gen.writeEndObject(); 
            }
            
            if(NetworkcheckInPeriod != null){
                gen.writeFieldName('network');
                gen.writeStartObject();
                gen.writeNumberField('period', integer.valueOf(NetworkcheckInPeriod));
                gen.writeEndObject();    
            }
            boolean tempstatus;
            if(tempEnabled == true)
                tempstatus = true;
            if(tempEnabled == false)
                tempstatus = false;  
            
            if(tempEnabled != null){
                gen.writeFieldName('temperature');
                gen.writeStartObject();
                gen.writeBooleanField('enabled', tempstatus);
                if(Temperaturecheckinperiod != '' && tempEnabled == true){
                    gen.writeNumberField('sampling_period', integer.valueOf(Temperaturecheckinperiod));
                    
                }
                gen.writeEndObject();    
            }
            
            if(bleenabled != null){
                gen.writeFieldName('ble');
                gen.writeStartObject();
                if(bleenabled == true)
                    gen.writeBooleanField('enabled', true);
                else
                    gen.writeBooleanField('enabled', false);
                if(blesamplingperiod != ''){
                    gen.writeNumberField('sampling_period', integer.valueOf(blesamplingperiod));
                }
                gen.writeEndObject();    
            }
            
            gen.writeEndObject();
            gen.writeEndObject();
            String body = gen.getAsString();
            system.debug('body--'+body);
            
            HttpResponse res1 =new HttpResponse(); 
            try{
                Http h1 = new Http();
                HttpRequest req1 = new HttpRequest();
                req1.setTimeout(60000);
                req1.setMethod('PUT');
                req1.setHeader('content-type','application/json');
                req1.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34'); 
                req1.setHeader('Authorization', authorize); 
                string endpt1 = 'https://api.iot.nimbelink.net/v1/devices/'+Deviceid+'/config';
                //  system.debug(endpt1);    
                req1.setEndpoint(endpt1);
                
                req1.setBody(body);
                system.debug(req1);
                system.debug(req1.getHeader('Authorization'));
                
                res1=h1.send(req1);
                
            }
            
            catch(exception ex) {
                RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_Callout_SF_to_NL', 'getParameter', 'API Error', Deviceid, body, true);
                Utilityclass.sendemailtoadmin(ex);
            } 
            system.debug('--------'+res1.getBody());
            RestAPIResponseResult result = new RestAPIResponseResult();
            result.statusCode = String.valueOf(res1.getStatusCode());
            result.status = res1.getStatus();
            result.message = 'Your Request has been Processed. Nimbelink Response is ' + res1.getStatusCode() + ' ' + res1.getStatus();
            // capturing error body
            String responseBody = res1.getBody();
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            if (jsonResponse.containsKey('error')) {
                result.NlResponse = (String)jsonResponse.get('error');
            }
            return result;
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_Callout_SF_to_NL', 'getParameter', 'Exception', Deviceid, null, true);        
        }
        return null;
    }   
    Public class RestAPIResponseResult {
        Public String statusCode;
        Public String status;
        Public String message;
        Public String NlResponse;
    }
}