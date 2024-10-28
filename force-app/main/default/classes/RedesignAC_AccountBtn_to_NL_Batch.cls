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
            accAssetConfigLst = [select id,name,Measurement_Period_desired__c, Account__r.Device_Ownership__c, Account__r.Account_Unique1_ID__c,
                                 Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c,
                                 ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                                 Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                                 Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,
                                 Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c
                                 from Asset_Configuration__c where Account__c =:accountId and recordType.DeveloperName = 'Account' LIMIT 1];
            
            String query = 'SELECT  Device_Id__c, NLResponseStatus__c '+
                'FROM Asset_Configuration__c ' + 
                'WHERE Asset__r.AccountId =: accountId and recordType.DeveloperName = \'Asset\' and Individual_config__c = false and NLResponseStatus__c in (\'Pending\',\'Failed\',\'Processing\')' ;
            
            String DeviceType = accAssetConfigLst[0].Account__r.Device_Ownership__c == 'Leased' ? accAssetConfigLst[0].Account__r.Device_Ownership__c : accAssetConfigLst[0].Account__r.Account_Unique1_ID__c ;
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
            string authorize = 'Bearer'+' '+ token;
            Asset_Configuration__c accAssetConfig = accAssetConfigLst.size() > 0 ? accAssetConfigLst[0] : null;
            for (Asset_Configuration__c astConfig : scope) {
                RedesignAC_Callout_SF_to_NL.RestAPIResponseResult response = RedesignAC_Callout_SF_to_NL.getParameter(accAssetConfig, authorize, astConfig.Device_Id__c);
                // Check response status code
                if (response.statusCode == '200') {
                    recCnt++;
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
                Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Id = batchLogId;
                batchLog.Complete_Time__c = system.now();
                batchLog.Status__c ='Completed';
                batchLog.Failure_records__c = failedRecords;
                batchLog.Total_no_of_records_processed__c = recCnt;
                update batchLog;
            }
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_AccountBtn_to_NL_Batch', 'finish', null, null, null, true);
        }
        
    }
}