public class RedesignNL_PauseAssetForAccDeletion implements Database.Batchable<SObject>, Database.Stateful {
    public  List<Account> accList;
    public set<id> assetIds;
    public DateTime batchStartTime;
    public List<string> failureMsgs = new List<string>();
    public static Integer totalFailureRecords = 0;
    public String batchStatus;
     public Integer totalRecords = 0;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus='Processing';
        this.batchStartTime = system.Now();
         boolean updaterec = true;
        return getBatchQuery(updaterec);
         
    }
    public void execute(Database.BatchableContext BC, List<Asset> scope) {
        totalRecords += scope.size();
        for(Asset ast: scope){
            ast.Pause_Job__c =true;
        }
        try{
            update scope;
        }catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_PauseAssetForAccDeletion', 'executeMethod', 'DML Error', null, null, true);
            failureMsgs.add('RedesignNL_PauseAssetForAccDeletion - while updating Assets. Error msg: '+e.getMessage());
			totalFailureRecords = totalFailureRecords + 1;
        }
    }
    public void finish(Database.BatchableContext BC) {
        if(accList.size()>0){
            for(Account acc:accList){
                acc.UpdateRecords__c = false;
            }
        }
        try{
            update accList;
        }catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_PauseAssetForAccDeletion', 'finishMethod', 'DML Error', null, null, true);
            failureMsgs.add('RedesignNL_PauseAssetForAccDeletion - while updating Accounts. Error msg: '+e.getMessage());
			totalFailureRecords = totalFailureRecords + 1;
        }
        //update accList;
        
         if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, 'RedesignNL_PauseAssetForAccDeletion', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
	 if(accList.size()>0){        
        Database.executeBatch(new RedesignNL_UpdateAccForARC( this.accList , 'Api_Response_childs__c'));
     }
    }
    
    //Flow : Replace_acc =''; UpdateRecords__c = true; isdelete= false
    public  Database.QueryLocator getBatchQuery(boolean updateRecs) {
     list<Account> accList = [select id,UpdateRecords__c, Name, Address__c,Replaced_account__c from Account where Replaced_Account__c != null and UpdateRecords__c = :updateRecs];
        set<id> accIds = New set<id>();
        set<id> astIds = New set<id>();
        if(accList.size()>0){
            for(Account acc : accList){
                accIds.add(acc.id);
            }
        }
        List<AggregateResult> arcList = [SELECT Asset__c  asset, COUNT(Id) cnt FROM API_Response_Childs__c  WHERE CurrentLocationId__c IN :accIds  GROUP BY Asset__c];
        if(arcList.size()>0){
            for (AggregateResult result : arcList) {
                String fieldValue = (String) result.get('asset');
               astIds.add(fieldValue);
            }
        }
         List<AggregateResult> ahcList = [SELECT Asset__c  asset, COUNT(Id) cnt FROM Asset_History_custom__c WHERE ( Last_Known_Location_Lookup__c IN :accIds or Current_Location__c IN :accIds )  GROUP BY Asset__c];
        if(ahcList.size()>0){
            for (AggregateResult result : ahcList) {
                String fieldValue = (String) result.get('asset');
                astIds.add(fieldValue);
            }
        }
        this.assetIds = astIds;
        this.accList = accList;
        String query = 'select id,Pause_Job__c from Asset where (Last_Known_Location__c IN : accIds or Current_Location__c IN :accIds or Id IN :assetIds)' ;
        return Database.getQueryLocator(query);
    }
}