/*
* Class Name: RedesignNL_DeletionBatch
* Created By: Murali Krishna
* Description: This class is used to delete Temperature,Events ARC records which are created Less than 7 days
* Modified Date  Modified By  		Last Change
* Jan 16, 2024   Murali Krishna    Added Comment in Top of Class
* Jan 19, 2024   Murali Krishna    Using Custom MetaData to get the no of days which will be stored in line no.24
*/
global class RedesignNL_DeletionBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    //BatchLog fields
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    global integer count = 0;
    Public string objectName;
    Public Integer LastDays;
    Public string objectFilter;
    global RedesignNL_DeletionBatch(){
        
    }
    global RedesignNL_DeletionBatch(String objectName,decimal num,string objectFilter){
        this.objectName = objectName;
        this.LastDays =integer.valueof(num);
        this.objectFilter = objectFilter;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';      
        this.batchStartTime = System.Now();      

        //Murali: Changed dateTs to get the no.of.days value instead of days
        string dateTs= String.valueof(this.LastDays) ;
        String query = 'Select id From ';
        if(this.objectName != null)
            query += this.objectName +' WHERE CreatedDate < LAST_N_DAYS:'+dateTs;//Murali:Changed the Condition with Last_N_Days
        if(this.objectFilter != null)
            query += ' AND '+ this.objectFilter; 
        system.debug(query);
        return Database.getQueryLocator(query);        
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> apiList) {
        try{
            List<Database.DeleteResult> ds =  Database.delete(apiList,false);            
        }
        catch(exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'DeleteApiResponseBatch', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - createAHCRecords. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        } 
    } 
    
    global void finish(Database.BatchableContext BC) {
        if(batchStatus == 'Processing')
            batchStatus = 'Completed';
        RedesignNL_Helper.createBatchDataCustom(BC,null, 'RedesignNL_DeletionBatch', this.batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
    }
    //Murali Added this to execute the batch
    global void execute(SchedulableContext sc){
        
        List<Deletion_Setting__mdt> deletionMdtList = [Select Id, DeveloperName, Custom_Setup__c, Deletion_Batch_Size__c, Days_to_Retain_Data__c, Enabled__c ,
                                                       Object_Filter__c, Object_Name__c from Deletion_Setting__mdt where Custom_Setup__c = false];
        for(Deletion_Setting__mdt dst: deletionMdtList) {
	        database.executeBatch(new RedesignNL_DeletionBatch(dst.Object_Name__c,dst.Days_to_Retain_Data__c,dst.Object_Filter__c),Integer.valueOf(dst.Deletion_Batch_Size__c));            
        }
    }
}