global with sharing class RedesignNl_FillRedesigned_ProcessedBatch implements Database.Batchable<sObject>, Database.Stateful{
 public static Integer totalFailureRecords = 0;
    public List<String> failureMsgs = new List<String>();
    public DateTime batchStartTime;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        batchStartTime = system.now();
        String query = 'Select id, Redesigned_Processed__c from Api_Response__c where Id in(Select Api_Response__c from API_Response_Childs__c ) AND Redesigned_Processed__c = False';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Api_Response__c> Scope) {
        try{
            for(Api_Response__c ar : Scope){
                ar.Redesigned_Processed__c = true;
            }
            update Scope;
        }
        catch(Exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_FillRedesigned_ProcessedBatch', 'execute', 'Exception', null, null, true);
            failureMsgs.add('RedesignNl_FillRedesigned_ProcessedBatch- Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    global void finish(Database.BatchableContext bc) {
       Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
            batchLog.Batch_Name__c = 'RedesignNl_FillRedesigned_ProcessedBatch';
            batchLog.Start_Time__c = batchStartTime;
            batchLog.Complete_Time__c = System.now();
            batchLog.Error_msg__c = 'No error';
            batchLog.Failure_records__c = 0;
            batchLog.Status__c = 'Completed';
        if(totalFailureRecords>0){
              batchLog.Error_msg__c = String.join(failureMsgs, '\n');
            batchLog.Failure_records__c = totalFailureRecords;
            batchLog.Status__c = 'Failed';
        }
        insert batchLog;
    }
}