Global class RedesignAC_SyncBulkConfig_Controller {
 @AuraEnabled
    webservice static String getAccountId(Id accountId) {
        String batchDataCustomStr = 'SF to NL Config Update Batch';// -' + accountId;
        DateTime currentTimestamp = DateTime.now();
        Integer recCnt = 0;
        String Asset_Configuration_Sync_success = system.label.Asset_Configuration_Sync_success;        
        String AccountBtn_to_NL_Another_Sync = system.label.AccountBtn_to_NL_Another_Sync;
        String AccountBtn_to_NL_No_Asset = system.label.AccountBtn_to_NL_No_Asset;
        String CommonException = system.label.Common_Exception_For_Nimblink;
        
        
        try {
            //Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId AND Ignore_Account_for_Callout__c = false];
            List<AggregateResult> astList = [SELECT COUNT(Id) total FROM Asset WHERE AccountId = :accountId];
            Integer totalCount = (Integer)astList[0].get('total');
            if(totalCount == 0) {
                //return 'This Account is ignored for Config Callouts.';
                return AccountBtn_to_NL_No_Asset;//No Assets are Assigned to this Account, but the Automatic Downstream Configuration will be Applied when an Asset Moves into this Location';
            }
            
            List<Batch_Data_Custom__c> batchData = [select Id, Batch_Name__c from Batch_Data_Custom__c where 
                                                    Batch_Name__c = :batchDataCustomStr and Status__c = 'Processing'];
            if(batchData.size() > 0) {
                return AccountBtn_to_NL_Another_Sync;//'Another Sync is already running. Please try to click this button after 10 mins.';
            }
            else {

                String query = 'SELECT Device_id__c, Desired_Blank_Check__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c, Asset__r.Is_Loco_Asset__c FROM Asset_Configuration__c WHERE recordType.DeveloperName = \'Asset\' AND Asset__r.Account.Ignore_Account_for_Callout__c = false AND Asset__r.Last_Connected__c = LAST_N_DAYS:30 AND Asset__r.AccountId = :accountId Order By Asset__r.AccountId';
               /* Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Batch_Name__c = batchDataCustomStr;
                batchLog.Start_Time__c= system.now();
                batchLog.Account_ID__c = accountId;
                batchLog.Status__c = 'Processing'; 
                insert batchLog;*/
                
               RedesignAC_NL_to_SF_CalloutBatch batch = new RedesignAC_NL_to_SF_CalloutBatch(query, accountId);
                Id jobId = Database.executeBatch(batch, 50);
                return Asset_Configuration_Sync_success;// 'Batch started successfully. Check status in Account related tab.';                
            }
            
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'RedesignAC_AccountBtn_to_NL_Controller', 'getAccountId', null, null, null, true);
            return CommonException;
        }
    }
}