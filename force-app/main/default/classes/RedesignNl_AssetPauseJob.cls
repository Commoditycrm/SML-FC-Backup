public class RedesignNl_AssetPauseJob implements Database.Batchable<SObject>, Database.Stateful {
    public set<id> accids;
    public DateTime batchStartTime;
    public List<string> failureMsgs = New List<String>();
    public static Integer totalFailureRecords = 0;
    public String batchStatus;
     public Integer totalRecords = 0;
    public RedesignNl_AssetPauseJob(set<id> accIdList){
        this.accids = accIdList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
          this.batchStatus='Processing';
        this.batchStartTime = system.Now();
          boolean updaterec = false;
        redesignNL_updateAssets helper = new redesignNL_updateAssets();
        return helper.getBatchQuery(updaterec);
         // String query = 'select id,Pause_Job__c from Asset where (Last_Known_Location__c IN : accids or Current_Location__c IN :accids )' ;
        //return Database.getQueryLocator(query);
    }

     public void execute(Database.BatchableContext BC, List<Asset> scope) {
        totalRecords += scope.size();
        for(Asset ast: scope){
            ast.Pause_Job__c =false;
        }
        try{
            update scope;
        }catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNl_AssetPauseJob', 'executeMethid', 'DML Error', null, null, true);

            failureMsgs.add('redesignNL_updateAssets - while updating Assets. Error msg: '+e.getMessage());
			totalFailureRecords = totalFailureRecords + 1;
        }
    }
    public void finish(Database.BatchableContext BC) {
        List<Account> accList = [select id from Account where Id IN : accids];
        if(accList.size()>0){
            try{
                delete accList;
            }catch(DMLException e){
                RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNl_AssetPauseJob', 'finishMethod', 'DML Error', null, null, true);
                failureMsgs.add('redesignNL_updateAssets - while deleting Account. Error msg: '+e.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
        }
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, 'RedesignNL_AccountDeletion', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);

    }
}