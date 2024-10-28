/* Description : Batch to update Asset Config from an Account
* Notes : Keep Batch size maximum 100/150 as you cannot make more than 100/150 callouts in apex method/execute method
*/ 
global class RedesignAC_DC_to_NLUpdate_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful,schedulable {
    private Id accountId;
    private Id batchLogId;
    // New entry
    String batchDataCustomStr = 'SF to NL Config Update Batch';
    //============
    private Integer recCnt;
    private Integer failedRecords = 0;
    public string tokenLeased;
    public string tokenOwned;
    public string currentOwnedAccount = '';
    global RedesignAC_DC_to_NLUpdate_Batch(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            //token = Utilityclass.generatetoken();
            tokenLeased = Utilityclass.generatetoken('Leased');
            // tokenOwned = Utilityclass.generatetoken('Owned');
            // Creating BDC
            Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
            batchLog.Batch_Name__c = batchDataCustomStr;
            batchLog.Start_Time__c= system.now();
            batchLog.Status__c = 'Processing'; 
            insert batchLog;
            batchLogId = batchLog.Id;
            // ======*/
            //Set<Id> ACIds = new Set<Id>();
            
            failedRecords = 0;
            recCnt =0;
            /*List<Asset_Configuration__c> assetConfigList = [SELECT id, name, NLResponseStatus__c FROM Asset_Configuration__c WHERE recordType.DeveloperName = 'Asset' AND Individual_config__c = false AND NLResponseStatus__c IN ('Pending', 'Failed')];
// Update NLResponseStatus__c to 'Processing'
for (Asset_Configuration__c assetConfig : assetConfigList) {
// Maybe a problem
assetConfig.NLResponseStatus__c = 'Processing';
ACIds.add(assetConfig.Id);
}
// Perform the update
if (!assetConfigList.isEmpty()) {
update assetConfigList;
}
// Return the QueryLocator*/
            String query = 'SELECT id, name, Measurement_Period_desired__c, Trackmode_Desired__c, Individual_config__c, Accelerometer_Status_Desired__c, ConnectMovementStart_Desired__c,'+
                ' ConnectMovementEnd_Desired__c, Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Location_Status_Desired__c,'+
                ' Location_Sampling_Period_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c,Device_Id__c, Use_WiFi_Desired__c, Network_Check_in_period_Desired__c,'+
                ' Temperature_Status_Desired__c, Temperature_Check_in_Period_Desired__c, Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c,'+
                ' Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c'+
                ' FROM Asset_Configuration__c WHERE recordType.DeveloperName = \'Asset\' AND Individual_config__c = false AND NLResponseStatus__c In (\'Processing\') Order By Asset__r.AccountId';
            
            return Database.getQueryLocator(query);            
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_DC_to_NLUpdate_Batch', 'start', null, null, null, true);            
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<Asset_Configuration__c> scope) {
        try {
            string authorize;
            for (Asset_Configuration__c astConfig : scope) {
                if(astConfig.Asset__r.Account.Device_Ownership__c == 'Owned' && currentOwnedAccount != astConfig.Asset__r.Account.Account_Unique1_ID__c){
                   tokenOwned = Utilityclass.generatetoken(astConfig.Asset__r.Account.Account_Unique1_ID__c);  
                   currentOwnedAccount = astConfig.Asset__r.Account.Account_Unique1_ID__c;
                }
                string finalToken = astConfig.Asset__r.Account.Device_Ownership__c == 'Leased' ? tokenLeased : tokenOwned;
                authorize = 'Bearer'+' '+ finalToken;
                //authorize = 'Bearer'+' '+ token;
                RedesignAC_Callout_SF_to_NL.RestAPIResponseResult response = RedesignAC_Callout_SF_to_NL.getParameter(astConfig, authorize, astConfig.Device_Id__c);
                // Check response status code
                if (response.StatusCode == '200') {
                    recCnt=recCnt +1;
                    astConfig.NLResponseStatus__c = 'Success';
                    astConfig.Error_Reason__c = null;
                } else {
                    // Handle error response
                    astConfig.NLResponseStatus__c = 'Processing';
                    astConfig.Error_Reason__c = response.NlResponse;
                    failedRecords ++;
                }
            }
            update scope; 
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_DC_to_NLUpdate_Batch', 'execute', null, null, null, true);            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            
            Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
            batchLog.Id = batchLogId;
            batchLog.Complete_Time__c = system.now();
            batchLog.Status__c ='Completed';
            batchLog.Failure_records__c = failedRecords;
            batchLog.Total_no_of_records_processed__c = recCnt;
            update batchLog;
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignAC_DC_to_NLUpdate_Batch', 'finish', null, null, null, true);
        }
    }
    global void execute(SchedulableContext sc){
        database.executebatch(new RedesignAC_DC_to_NLUpdate_Batch(),50);
    }
}