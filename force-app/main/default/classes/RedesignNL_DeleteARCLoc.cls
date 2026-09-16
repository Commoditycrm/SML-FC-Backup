/*
* Class Name: RedesignNL_DeleteARCLoc
* Created By: Murali Krishna
* Description: This class is used to delete Location ARC records which are created Less than 30 days
* Modified Date  Modified By        Last Change
* Jan 16, 2024   Murali Krishna    Added Comment in Top of Class
* Jan 19, 2024   Murali Krishna    Using Custom MetaData from RedesignNL_helper to get the no of days which will be stored in line no.22 deletedate
* Feb 04, 2024   Murali Krishna    Changed the Status Condition for Status to pick Processed,Backdated and Future.Added the Fields in the Select Query in line.no 48
*/  
global class RedesignNL_DeleteARCLoc implements Database.Batchable<sObject>,Database.stateful, Schedulable{
    //BatchLog fields
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    Public DateTime DeleteDate;
    
    Global RedesignNL_DeleteARCLoc() {
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';
        this.batchStartTime = System.Now();      
        Deletion_Setting__mdt deletemdt = Deletion_Setting__mdt.getInstance('API_Response_Child_Location');
        integer ds=deletemdt.Days_to_Retain_Data__c != null ? integer.valueof(deletemdt.Days_to_Retain_Data__c) : 30;
        this.DeleteDate = Date.today().addDays(-ds) ;
        String query = 'SELECT Id, Name FROM Asset';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        try{
            set<ID> assetIdSet =new set<ID>();
            Map<Id,Set<datetime>> AssetTimeMap = new  Map<Id,Set<datetime>>();
            for(Asset ast:scope) {
                assetIdSet.add(ast.id);
            }
            List<Asset_History_Custom__c> ahcList = [SELECT Id,Start_time__c,End_time__c, Still_in_this_Location__c, 
                                                     Asset__c, Last_Known_Location__c, Location__c, currentLocationId__c, Last_known_location_Lookup__c 
                                                     FROM Asset_History_custom__c WHERE Delete_check__c = True and Asset__c IN :assetIdSet];
            for(Asset_History_Custom__c ahc:ahclist){
                set<Datetime> dt = New set<Datetime>();
                if(AssetTimeMap.containsKey(ahc.Asset__c)){
                    dt=AssetTimeMap.get(ahc.Asset__c);
                }
                dt.add(ahc.Start_time__c);
                dt.add(ahc.End_Time__c);
                AssetTimeMap.put(ahc.asset__c,dt);
            }
            List<API_Response_Childs__c> arcDeleteLst = [SELECT Id,Asset__c,Timestamp_DateTime__c,Status__c FROM API_Response_Childs__c WHERE CreatedDate  <: this.DeleteDate AND Asset__c IN :assetIdSet
                                                         AND RecordType.DeveloperName IN ('Location') AND Status__c in ('Processed','BackdatedTS','FutureTS', 'Duplicate')];
            
            if(arcDeleteLst.size() > 0) {
                List<API_Response_Childs__c> arclist= new List<API_Response_Childs__c>();
                for(API_Response_Childs__c arc :arcDeleteLst) {
                    if(AssetTimeMap.containsKey(arc.Asset__c)){
                        set<DateTime> assetTime = AssetTimeMap.get(arc.Asset__c);
                        System.Debug(arc.Timestamp_DateTime__c);
                        if(!assetTime.contains(arc.Timestamp_DateTime__c)){
                            arclist.add(arc); 
                        }
                    }
                }
                totalRecords += arclist.size();
                if(arclist.size()>0){
                    Database.delete(arclist,False);
                }
            }
        }
        catch(exception e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_DeleteARCLoc', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('RedesignNL_DeleteARCLoc - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            this.batchStatus = 'Failed';
        }
    }
    global void finish(Database.BatchableContext bC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC, null, 'RedesignNL_DeleteARCLoc', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        //Add the AHC execute line here
    }
    global void execute(SchedulableContext sc){
        database.executeBatch(new RedesignNL_DeleteARCLoc(),25);
    }
}