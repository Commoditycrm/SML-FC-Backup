global class RedesignAC_AccountBtn_to_NL_Controller {
    
    @AuraEnabled
    webservice static String getAccountId(Id accountId) {
        String batchDataCustomStr = 'SF to NL Config Update Batch';// -' + accountId;
        DateTime currentTimestamp = DateTime.now();
        Integer recCnt = 0;
        try {
            //Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId AND Ignore_Account_for_Callout__c = false];
            List<AggregateResult> astList = [SELECT COUNT(Id) total FROM Asset WHERE AccountId = :accountId];
            Integer totalCount = (Integer)astList[0].get('total');
            if(totalCount == 0) {
                //return 'This Account is ignored for Config Callouts.';
                return 'No Assets are Assigned to this Account, but the Automatic Downstream Configuration will be Applied when an Asset Moves into this Location';
            }
            List<Asset_Configuration__c> acgList = [SELECT id FROM Asset_Configuration__c WHERE Asset__r.AccountId =: accountId 
            and recordType.DeveloperName = 'Asset' and Individual_config__c = false and NLResponseStatus__c in ('Pending','Failed') limit 1];

            if(acgList.size() == 0) {
                return 'Save Desired Configuration prior to update';
            }
            
            List<Batch_Data_Custom__c> batchData = [select Id, Batch_Name__c from Batch_Data_Custom__c where 
                                                    Batch_Name__c = :batchDataCustomStr and Status__c = 'Processing'];
            if(batchData.size() > 0) {
                return 'Another Sync is already running. Please try to click this button after 10 mins.';
            }
            else {
                Redesign_NL__mdt dnl = Redesign_NL__mdt.getInstance('Default');
                Integer RecursiveBatchCount = dnl.Recursive_Batch_Count__c != null ? Integer.valueOf(dnl.Recursive_Batch_Count__c) : 3;
                Integer AccountBatchSize = dnl.Asset_Config_Account_Batch_Size__c  != null ? Integer.valueOf(dnl.Asset_Config_Account_Batch_Size__c) : 1;
                
                Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Batch_Name__c = batchDataCustomStr;
                batchLog.Start_Time__c= system.now();
                batchLog.Account_ID__c = accountId;
                batchLog.Status__c = 'Processing'; 
                insert batchLog;
                
               RedesignAC_AccountBtn_to_NL_Batch batch = new RedesignAC_AccountBtn_to_NL_Batch(accountId, batchLog.Id, RecursiveBatchCount, recCnt);
                Id jobId = Database.executeBatch(batch, AccountBatchSize);
                return 'Batch started successfully. Check status in Account related tab.';                
            }
            
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'RedesignAC_AccountBtn_to_NL_Controller', 'getAccountId', null, null, null, true);
            return 'Error: ' + e.getMessage();
        }
    }
}