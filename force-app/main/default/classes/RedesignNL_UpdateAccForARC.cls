public class RedesignNL_UpdateAccForARC implements Database.Batchable<SObject>, Database.Stateful{
    public Id currentAcc;
    public String objectName;
    public Map<Id, Account> accMap = new Map<Id, Account>();
    public List<Account> accList = new List<Account>();
    public DateTime batchStartTime;
    public List<string> failureMsgs = new List<String>();
    public static Integer totalFailureRecords = 0;
    public String batchStatus;
    public Integer totalRecords = 0;
    public set<id> accIds;
    public set<id> assetIds;
    
    // Constructor
    public RedesignNL_UpdateAccForARC(String objectName) {
        this.batchStartTime = system.Now();
        this.objectName = objectName;
    }
    public RedesignNL_UpdateAccForARC(List<Account> accList, String objectName) {
        this.accList = accList;
        this.objectName = objectName;
        this.batchStartTime = system.Now();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus='Processing';
        Set<Id> deleteAccIds = new  Set<Id>() ;
        accList = accList != null? accList :[Select Id, Name, Address__c,Replaced_account__c from Account Where Replaced_account__c != null Limit 10000];
            if(accList.size()>0){
                for(Account loopVar : accList){
                    deleteAccIds.add(loopVar.Id);
                    accMap.put(loopVar.Id,loopVar);
                }
            }
        this.accIds = deleteAccIds;
        String query = 'SELECT Id, Asset__c ,Currentlocationid__c, Current_Location_Address__c, Location__c FROM Api_Response_childs__c WHERE CurrentLocationId__c IN :deleteAccIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Api_Response_childs__c> scope) {
        totalRecords += scope.size();
         for (Api_Response_childs__c arc : scope) {
            Account acc = accMap.get(arc.Currentlocationid__c);
            if (acc != null) {
                arc.Currentlocationid__c = null;
                arc.Location__c = 'In Transit';
            }
        }
        
        try{
            update scope;
        }catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_UpdateAccForARC', 'executeMethod', 'DML Error', null, null, true);
            
            failureMsgs.add('RedesignNL_UpdateAccForARC - updating ' + this.objectName + '. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, 'RedesignNL_UpdateAccForARC', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        Database.executeBatch(new RedesignNL_UpdateAccForAHCAst(accList),1);
    }
    
}