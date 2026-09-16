public class Configuration_Parameter_Callout {
    
    @AuraEnabled
    public static string getParameter(Id recordId) {
        String AccountBtn_to_NL_Another_Sync = system.label.AccountBtn_to_NL_Another_Sync;
        String Asset_Configuration_400_error = system.label.Asset_Configuration_400_error;
        String Asset_Configuration_401_error = system.label.Asset_Configuration_401_error;
        String Asset_Configuration_403_error = system.label.Asset_Configuration_403_error;
        String CommonException = system.label.Common_Exception_For_Nimblink;
        String Asset_Configuration_Sync_success = system.label.Asset_Configuration_Sync_success;
        String No_configuration_found = system.label.No_configuration_found;
        try {
            String returnString;
             String batchDataCustomStr = 'SF to NL Config Update Batch';
            List<Batch_Data_Custom__c> batchData = [SELECT Id, Batch_Name__c FROM Batch_Data_Custom__c WHERE 
                                                    Batch_Name__c = :batchDataCustomStr and Status__c = 'Processing'];
            if(batchData.size() > 0) {
                return AccountBtn_to_NL_Another_Sync;
            }
            List<Asset_Configuration__c> accAssetConfigLst = [SELECT id,name, Asset__c,Device_Id__c,Measurement_Period_desired__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c,
                                                              Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c, Asset__r.Is_Loco_Asset__c, 
                                                              ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                                                              Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                                                              Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c, 
                                                              Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, 
                                                              Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                                                              Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, 
                                                              Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_On_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c, 
                                                              Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c  
                                                              FROM Asset_Configuration__c WHERE Asset__c =:recordId and recordType.DeveloperName = 'Asset' LIMIT 1];
            if(accAssetConfigLst.size() > 0){
                String token;
                boolean isLoco = false;
                if(accAssetConfigLst[0].Asset__r.is_Loco_Asset__c){
                    token = System.Label.Loco_Ware_Config_Key;
                    isLoco = true;
                }else{
                    String deviceType = accAssetConfigLst[0].Asset__r.Account.Device_Ownership__c == 'Leased' ? accAssetConfigLst[0].Asset__r.Account.Device_Ownership__c : accAssetConfigLst[0].Asset__r.Account.Account_Unique1_ID__c ;
                    token = Utilityclass.generatetoken(deviceType); 
                    isLoco = false;
                }
                string authorize = 'Bearer'+' '+ token;
                RedesignAC_Callout_SF_to_NL.RestAPIResponseResult response = RedesignAC_Callout_SF_to_NL.getParameter(accAssetConfigLst[0], authorize, accAssetConfigLst[0].device_id__c, isLoco);   
                returnString = response== null ? CommonException :  response.statusCode=='400' ? Asset_Configuration_400_error : response.statusCode=='401' ? Asset_Configuration_401_error : response.statusCode=='403' ? Asset_Configuration_403_error : Asset_Configuration_Sync_success;

                if(returnString == Asset_Configuration_Sync_success || Test.isRunningTest()){
                    Asset_Configuration__c cur = accAssetConfigLst[0];
                    List<Batch_Data_Custom__c> oldBatchList = [
                        SELECT Id, SF_Push_History__c
                        FROM Batch_Data_Custom__c
                        WHERE Asset__c = :recordId
                        AND Status__c = 'Completed'
                        AND Batch_Name__c = 'SF to NL Config Update Batch'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];
                    Batch_Data_Custom__c oldBatchLog = oldBatchList.isEmpty() ? null : oldBatchList[0];
                    Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                    batchLog.Batch_Name__c = 'SF to NL Config Update Batch';
                    batchLog.Complete_Time__c = system.now();
                    batchLog.Asset__c = recordId;
                    batchLog.Status__c ='Completed';
                    batchLog.Total_no_of_records_processed__c = 1;
                    batchLog.SF_Push_History__c = (cur != null) ? JSON.serialize(cur) : null;

                    Map<String, Object> oldMap = (oldBatchLog != null && String.isNotBlank(oldBatchLog.SF_Push_History__c))
                        ? (Map<String, Object>) JSON.deserializeUntyped(oldBatchLog.SF_Push_History__c)
                        : new Map<String, Object>();
                    
                    List<String> fieldsToCompare;
                    if(cur.Asset__r.is_Loco_Asset__c){
                        fieldsToCompare = new List<String>{
                            'Accelerometer_Status_Desired__c',
                            'ConnectMovementStart_Desired__c',
                            'Tracking_Location_Period_desired__c',
                            'Location_Sampling_Period_Desired__c',
                            'Use_Cell_Desired__c',
                            'Use_GPS_Desired__c',
                            'Use_WiFi_Desired__c',
                            'Network_Check_in_period_Desired__c',
                            'Temperature_Status_Desired__c',
                            'Impact_Alert_Desired__c',
                            'Max_Impact_Desired__c',
                            'Movement_Accuracy_Desired__c',
                            'Location_Accuracy_Desired__c',
                            'Sensor_Logging_Period_Desired__c',
                            'Tag_Detection_Desired__c',
                            'Min_RSSI_Desired__c',
                            'Scan_for_Tags_Interval_Desired__c',
                            'Missing_Tag_Report_Delay_Desired__c',
                            'Listen_Time_Desired__c'
                        };
                    }else{
                        fieldsToCompare = new List<String>{
                        'Measurement_Period_desired__c',
                        'Trackmode_Desired__c',
                        'Accelerometer_Status_Desired__c',
                        'ConnectMovementStart_Desired__c',
                        'ConnectMovementEnd_Desired__c',
                        'Tracking_Location_Period_desired__c',
                        'Tracking_Locations_per_Check_Ins_Desired__c',
                        'Location_Status_Desired__c',
                        'Location_Sampling_Period_Desired__c',
                        'Use_Cell_Desired__c',
                        'Use_GPS_Desired__c',
                        'Use_WiFi_Desired__c',
                        'Network_Check_in_period_Desired__c',
                        'Temperature_Status_Desired__c',
                        'Temperature_Check_in_Period_Desired__c',
                        'Connect_On_Tilt_Desired__c',
                        'Log_Every_n_Desired__c',
                        'Tilt_Degrees_Desired__c',
                        'Reference_X_Desired__c',
                        'Reference_Y_Desired__c',
                        'Reference_Z_Desired__c',
                        'Distance_Status_Desired__c',
                        'Distance_Sampling_Period_Desired__c',
                        'Connect_on_Alert_Desired__c',
                        'Alert_Threshold_Low_Desired__c',
                        'Alert_Threshold_High_Desired__c',
                        'Alert_Count_Desired__c',
                        'Ignore_Errors_Desired__c',
                        'Log_Every_N_Samples_Desired__c',
                        'Skip_While_Moving_Desired__c'
                    };
                    }

                    // Diff loop: build lines like "FieldApi: old -> new"
                    List<String> diffs = new List<String>();
                    if (cur != null && !oldMap.isEmpty()) {
                        for (String api : fieldsToCompare) {
                            String oldVal = oldMap.containsKey(api) && oldMap.get(api) != null ? String.valueOf(oldMap.get(api)) : null;
                            Object newObj = cur.get(api);
                            String newVal = (newObj != null) ? String.valueOf(newObj) : null;

                            Boolean changed =
                                (oldVal == null && newVal != null) ||
                                (oldVal != null && newVal == null) ||
                                (oldVal != null && newVal != null && oldVal != newVal);

                            if (changed) {
                                diffs.add(api + ': ' + (oldVal == null ? '∅' : oldVal) + ' -> ' + (newVal == null ? '∅' : newVal));
                            }
                        }
                    }
                    batchLog.Changed_Fields__c = diffs.isEmpty() ? null : '<ul><li>' + String.join(diffs, '</li><li>') + '</li></ul>';
                    insert batchLog;
                }                
            }else{
                returnString = No_configuration_found;
            }
            return returnString;
            
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'Configuration_Parameter_Callout', 'getParameter', null, null, null, true);                        
        }
        return null;
    }
}