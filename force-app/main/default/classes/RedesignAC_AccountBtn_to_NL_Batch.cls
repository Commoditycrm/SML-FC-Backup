/* Description : Batch to update Asset Config from an Account
* Notes : Keep Batch size maximum 100/150 as you cannot make more than 100/150 callouts in apex method/execute method
*/ 
global class RedesignAC_AccountBtn_to_NL_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    private Id accountId;
    private Id batchLogId;
    private Integer recCnt;
    private Integer failedRecords = 0;
    private Integer recursion;
    public Boolean isFailed;
    public string token;
    public List<Asset_Configuration__c> accAssetConfigLst;
    
    global RedesignAC_AccountBtn_to_NL_Batch(Id accountId, Id batchLogId) {
        system.debug('accIdCons '+ accountId);
        this.accountId = accountId;
        this.batchLogId = batchLogId;
        isFailed = false;
    }
    
    global RedesignAC_AccountBtn_to_NL_Batch(Id accountId, Id batchLogId, Integer recursionCount, Integer recCnt) {
        system.debug('accIdCons '+ accountId);
        this.accountId = accountId;
        this.batchLogId = batchLogId;
        this.recursion   = recursionCount;
        this.recCnt = recCnt;
        isFailed = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            failedRecords = 0;
            List<Asset_Configuration__c> defaultConfigLst = [SELECT id,name,Measurement_Period_desired__c, Account__r.Device_Ownership__c, Account__r.Account_ID__c, RecordType.DeveloperName,
                                                                Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c, LastModifiedDate,
                                                                ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                                                                Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                                                                Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,
                                                                Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, 
                                                                Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                                                                Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c,
                                                                Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_On_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c, 
                                                                Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c 
                                                                FROM Asset_Configuration__c WHERE Account__c =:accountId AND recordType.DeveloperName = 'Default' LIMIT 1];

            List<Asset_Configuration__c> locationConfigLst = [SELECT id,name,Measurement_Period_desired__c, Account__r.Device_Ownership__c, Account__r.Account_ID__c, RecordType.DeveloperName,
                                                                Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c, LastModifiedDate,
                                                                ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                                                                Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                                                                Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,
                                                                Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, 
                                                                Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                                                                Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c,
                                                                Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_On_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c, 
                                                                Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c 
                                                                FROM Asset_Configuration__c WHERE Account__c =:accountId AND recordType.DeveloperName = 'Account' LIMIT 1];
                String query;
                if(!locationConfigLst.isEmpty()) {
                    accAssetConfigLst = locationConfigLst[0].LastModifiedDate > defaultConfigLst[0].LastModifiedDate ? locationConfigLst : defaultConfigLst;
                    query = accAssetConfigLst[0].RecordType.DeveloperName == 'Default' ? 'SELECT  Device_Id__c, NLResponseStatus__c, Asset__r.Is_Loco_Asset__c FROM Asset_Configuration__c WHERE (Asset__r.Current_Location__c =: accountId OR Asset__r.AccountId =: accountId) AND recordType.DeveloperName = \'Asset\' AND Individual_config__c = false AND NLResponseStatus__c IN (\'Pending\',\'Failed\',\'Processing\') AND Configuration_Followed__c = \'Upstream\' AND Asset__r.Account.Ignore_Account_for_Callout__c = false' : 'SELECT  Device_Id__c, NLResponseStatus__c, Asset__r.Is_Loco_Asset__c FROM Asset_Configuration__c WHERE Asset__r.Current_Location__c =: accountId AND recordType.DeveloperName = \'Asset\' AND Individual_config__c = false AND NLResponseStatus__c IN (\'Pending\',\'Failed\',\'Processing\') AND Asset__r.Account.Ignore_Account_for_Callout__c = false';
                } else {
                    accAssetConfigLst = defaultConfigLst;
                    query = 'SELECT  Device_Id__c, NLResponseStatus__c, Asset__r.Is_Loco_Asset__c FROM Asset_Configuration__c WHERE (Asset__r.Current_Location__c =: accountId OR Asset__r.AccountId =: accountId) AND recordType.DeveloperName = \'Asset\' AND Individual_config__c = false AND NLResponseStatus__c IN (\'Pending\',\'Failed\',\'Processing\') AND Configuration_Followed__c = \'Upstream\' AND Asset__r.Account.Ignore_Account_for_Callout__c = false';
                }                           
            /*String query = 'SELECT  Device_Id__c, NLResponseStatus__c, Asset__r.Is_Loco_Asset__c '+
                'FROM Asset_Configuration__c ' + 
                'WHERE Asset__r.Current_Location__c =: accountId and recordType.DeveloperName = \'Asset\' and Individual_config__c = false and NLResponseStatus__c in (\'Pending\',\'Failed\',\'Processing\')' ;*/
            
            String DeviceType = accAssetConfigLst[0].Account__r.Device_Ownership__c == 'Leased' ? accAssetConfigLst[0].Account__r.Device_Ownership__c : accAssetConfigLst[0].Account__r.Account_ID__c;
            token = Utilityclass.generatetoken(DeviceType);
            return Database.getQueryLocator(query);            
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_AccountBtn_to_NL_Batch', 'start', null, null, null, true);            
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<Asset_Configuration__c> scope) {
        try {
            recCnt += scope.size();
            string authorize = 'Bearer'+' '+ token;
            String locoToken = 'Bearer'+' '+ System.Label.Loco_Ware_Config_Key;
            Asset_Configuration__c accAssetConfig = accAssetConfigLst.size() > 0 ? accAssetConfigLst[0] : null;
            for (Asset_Configuration__c astConfig : scope) {
                RedesignAC_Callout_SF_to_NL.RestAPIResponseResult response;
                if(astConfig.Asset__r.is_loco_Asset__c){
                    response = RedesignAC_Callout_SF_to_NL.getParameter(accAssetConfig, locoToken, astConfig.Device_Id__c, true);
                }else{
                    response = RedesignAC_Callout_SF_to_NL.getParameter(accAssetConfig, authorize, astConfig.Device_Id__c, false);
                }
                // Check response status code
                if (response.statusCode == '200') {
                    astConfig.NLResponseStatus__c = 'Success';
                    astConfig.Error_Reason__c = null;
                } else {
                    // Handle error response
                    astConfig.NLResponseStatus__c = 'Failed';
                    astConfig.Error_Reason__c = response.NlResponse;
                    isFailed = true;
                    failedRecords ++;
                }
            }
            update scope; 
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_AccountBtn_to_NL_Batch', 'execute', null, null, null, true);            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            if (recursion > 1 && isFailed) {
                recursion--;
                RedesignAC_AccountBtn_to_NL_Batch batch = new RedesignAC_AccountBtn_to_NL_Batch(this.accountId, this.batchLogId, recursion, recCnt);
                Redesign_NL__mdt dnl = Redesign_NL__mdt.getInstance('Default');
                Integer AccountBatchSize = dnl.Asset_Config_Account_Batch_Size__c  != null ? Integer.valueOf(dnl.Asset_Config_Account_Batch_Size__c) : 1;
                Id jobId = Database.executeBatch(batch, AccountBatchSize);
            }
            else {
                Asset_Configuration__c cur = accAssetConfigLst.isEmpty() ? null : accAssetConfigLst[0];
                List<Batch_Data_Custom__c> oldBatchList= [SELECT Id, SF_Push_History__c FROM Batch_Data_Custom__c WHERE Account_ID__c =: accountId AND Status__c = 'Completed' AND Batch_Name__c =: 'SF to NL Config Update Batch' ORDER BY CreatedDate DESC LIMIT 1];
                Batch_Data_Custom__c oldBatchLog = oldBatchList.isEmpty() ? null : oldBatchList[0];
                Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Id = batchLogId;
                batchLog.Complete_Time__c = system.now();
                batchLog.Status__c ='Completed';
                batchLog.Failure_records__c = failedRecords;
                batchLog.Total_no_of_records_processed__c = recCnt;
                batchLog.SF_Push_History__c = (cur != null) ? JSON.serialize(cur) : null;

                Map<String, Object> oldMap = (oldBatchLog != null && String.isNotBlank(oldBatchLog.SF_Push_History__c))
                    ? (Map<String, Object>) JSON.deserializeUntyped(oldBatchLog.SF_Push_History__c)
                    : new Map<String, Object>();

                List<String> fieldsToCompare = new List<String>{
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
                    'Impact_Alert_Desired__c',
                    'Max_Impact_Desired__c',
                    'Movement_Accuracy_Desired__c',
                    'Location_Accuracy_Desired__c',
                    'Sensor_Logging_Period_Desired__c',
                    'Tag_Detection_Desired__c',
                    'Min_RSSI_Desired__c',
                    'Scan_for_Tags_Interval_Desired__c',
                    'Missing_Tag_Report_Delay_Desired__c',
                    'Listen_Time_Desired__c',
                    'Distance_Status_Desired__c',
                    'Distance_Sampling_Period_Desired__c',
                    'Connect_On_Alert_Desired__c',
                    'Alert_Threshold_Low_Desired__c',
                    'Alert_Threshold_High_Desired__c',
                    'Alert_Count_Desired__c',
                    'Ignore_Errors_Desired__c',
                    'Log_Every_N_Samples_Desired__c',
                    'Skip_While_Moving_Desired__c'
                };

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
                update batchLog;
            }
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_AccountBtn_to_NL_Batch', 'finish', null, null, null, true);
        }
        
    }
}