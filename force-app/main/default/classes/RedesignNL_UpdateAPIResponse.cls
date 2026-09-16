/*
* Class Name: RedesignNL_UpdateAPIResponse
* Description: This class is used to update Api response records status to Processed
* Modified Date  Modified By  		Last Change
* Jan 16, 2024   Murali Krishna     Added errorlog method in catch 
* Feb 12,2024    Murali Krishna    Passing the Batch Job to Helper class to Insert the values in the BDC from Apexjob
* Feb 13,2024    Murali Krishna    Added FailureAstIds list to not Process Batch for Asset having Exception on Unable to Lock Row
*/
global class RedesignNL_UpdateAPIResponse implements Database.Batchable<sObject>, Database.Stateful{
    
    
    public List<String> assetIdList = new List<String>();
    public DateTime previousHour;
    public Datetime BefAssetProcDttime;
    public List<API_Response__c> apiRespRecList;
    public String Query;
    //Murali:Added the failureAst for unable to lock row line no:18
    public List<Id> failureAssetIds = new List<Id>();
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    global RedesignNL_UpdateAPIResponse(List<ID>failureAssetIds,Datetime BefAssetProcDttime,List<API_Response__c> apiRespRecList){
        //Initializing for BatchLogs
        this.batchName='RedesignNL_UpdateAPIResponse';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime = BefAssetProcDttime;
        this.apiRespRecList = apiRespRecList;
        //Murali:Added the failureAst for unable to lock row line no:33
        this.failureAssetIds =failureAssetIds;
    }
    //Contructor for testing
    global RedesignNL_UpdateAPIResponse(String Query){
        this.Query = Query;
        //Initializing for BatchLogs
        this.batchName='RedesignNL_UpdateAPIResponse';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime= system.now();
    }
    
    global List<API_Response__c> start(Database.BatchableContext bc){
        /*if(String.isBlank(Query)){
Query = 'Select Id,BefAssetProcDttime__c,BefAssetProcTime__c,AfterAssetProcTime__c,AfterAssetProcDttime__c from API_Response__c where  Status__c = \'New\' and CreatedDate >: previousHour and Asset__c in :assetIdList ORDER BY Asset__c';
}
return Database.getQueryLocator(Query);*/
        return apiRespRecList;
    }
    
    global void execute(Database.BatchableContext bc, List<API_Response__c> scope){
        totalRecords += scope.size();
        for(API_Response__c ar : scope) {
            //Murali:Added the failureAst for unable to lock row line no:56
            if(!failureAssetIds.contains(ar.Asset__c)) {
                ar.Status__c = 'PROCESSED';
                ar.AfterAssetProcDttime__c=system.now();
                ar.BefAssetProcTime__c=(BefAssetProcDttime.getTime()/1000);
                ar.AfterAssetProcTime__c=(system.now().getTime()/1000);
            }
        }
        try{
            update scope;
            //update updateArcStatus;
        }
        catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_UpdateAPIResponse', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('UpdateApiResponse - '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        //Creation of BatchLogs - Chandru
        //Murali:Passing  the bC to insert values from AsyncApexJob line no:77
        RedesignNL_Helper.createBatchDataCustom(bc,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, null, totalRecords);
        /*        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
batchLog.Batch_Name__c = batchName;
batchLog.Start_Time__c= batchStartTime;
batchLog.Complete_Time__c = system.now();
batchLog.Error_msg__c = String.join(failureMsgs, '\n');
batchLog.Failure_records__c = totalFailureRecords ;
batchLog.Status__c = 'Completed';
batchLog.Total_no_of_records_processed__c = totalRecords;
insert batchLog;*/
        
        //RedesignNL_CreateEventHistoryBatch.runInTransitEverBatch(); 
        RedesignAC_Downstream_Config_UpdateBatch.runInTransitEverBatch();
    }
}