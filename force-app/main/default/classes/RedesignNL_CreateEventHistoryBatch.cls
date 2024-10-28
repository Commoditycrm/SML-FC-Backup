/*
* Class Name: RedesignNL_CreateEventHistoryBatch
* Created By: Jayesh Khattar
* Description: This is a batch class used to create Asset History Events records and update Asset from API Response Childs
* Change Log:
* Modified Date  Modified By  		Last Change
* Jan 16, 2024   Murali Krishna    Added Comment in Top of Class
* Jan 16, 2024   Murali Krishna    Added Asset Movement check box where it will be true for Latest Event Record
* Jan 18, 2024   Murali Krishna	Added the if condition witharcEventList on line no.75 where it loops only if it has arc
* Jan 18, 2024   Murali Krishna    Added the LatestEventAHC ahc variable on line no.81 which pick the Latest AHC and updates Asset
* Jan 22,2024    Murali Krishna    Removed ARCinsert method because it was not been using anywhere and add the try catch for wole block
* Feb 12,2024    Murali Krishna    Passing the Batch Job to Helper class to Insert the values in the BDC from Apexjob
* Feb 13,2024    Murali Krishna    Added FailureAstIds list to not Process Batch for Asset having Exception on Unable to Lock Row
*/  
global class RedesignNL_CreateEventHistoryBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
      
    public string query;
    public Datetime BefAssetProcDttime;
    public Datetime AfterAssetProcDttime;
    public List<API_Response__c> apiRespRecList;
    public static final String movement = 'movement';
    public static final String movementEnd = 'movementEnd';
    //Murali:Added the failureAst for unable to lock row line no:22
    public List<Id> failureAssetIds;
    
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    
    //contructor for chaining batch - Chandru
    global RedesignNL_CreateEventHistoryBatch (List<ID>failureAssetIds,Datetime BefAssetProcDttime,List<API_Response__c> apiRespRecList){
        //Initializing for BatchLogs
        this.batchName='RedesignNL_CreateEventHistoryBatch';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime = BefAssetProcDttime;
        this.apiRespRecList = apiRespRecList;
        //Murali:Added the failureAst for unable to lock row line no:51
        this.failureAssetIds =failureAssetIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        this.batchStatus = 'Processing';      
        if(String.isBlank(query)) {
            SET<ID> AssetIDSet = New SET<ID>();
            For(API_Response__c ar : apiRespRecList) {
                //Murali:Added the failureAst for unable to lock row line no:60
                if(!failureAssetIds.contains(ar.Asset__r.Id))                 
                    AssetIDSet.add(ar.Asset__c);
            }
            query = 'SELECT Id, Name, Movement__c, Movement_End__c from Asset where Id IN : AssetIDSet and Capture_Movement_Event__c = true';
        }
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        totalRecords += scope.size();
        List<API_Response_Childs__c> arcEventList = [Select Id, Name, Event_Name__c,Asset__c, Timestamp__c, Timestamp_DateTime__c, Asset_History__c, Api_Response__c 
                                                     from API_Response_Childs__c 
                                                     where RecordType.developerName = 'Events' and Asset__c = :Scope and
                                                     Status__c = 'New' order by Timestamp_DateTime__c asc]; // order by createdDate Used by Jayesh
        List<Asset_History_custom__c> LastEventAHC = [Select id, Name, Start_Time__c,Asset__c,Asset_Movement__c  , End_Time__c 
                                                      from Asset_History_custom__c 
                                                      where Asset_Movement__c = True AND RecordType.developerName = 'Events' 
                                                      AND Asset__c = :Scope order by Start_Time__c DESC];
        Map<String, Asset_History_custom__c> ahcMap = new Map<String, Asset_History_custom__c>();
        For(Asset_History_custom__c ahc : LastEventAHC){
            ahcMap.put(ahc.Asset__c,ahc);
        }
        if(arcEventList.size()>0){
            for(Asset ast : scope) {
                List<Asset_History_custom__c> ahcEventList = createEventRecords(ast.Id,arcEventList,ahcMap);
                Integer listLength = ahcEventList.size();
                if(listLength > 0) {
                    Asset_History_custom__c latestEventAHC = null;
                    For(Asset_History_custom__c ahc : ahcEventList){
                        if(latestEventAHC == null || latestEventAHC.Start_Time__c < ahc.Start_Time__c)
                            latestEventAHC=ahc;
                    }
                    ast = updateAssetSummary(ast,latestEventAHC);
                    
                }
            }
            try{// Murali: Added Try catch Block here
                update scope;
            }
            catch(Exception e){
                RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateEventHistoryBatch', 'execute', 'DML Error', null, null, true);
                failureMsgs.add('RedesignNL_CreateEventHistoryBatch - createEventRecords. Error msg: '+e.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
            
        }
    }
    global void finish(Database.BatchableContext bC) {
        //Creation of BatchLogs - Chandru
        
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        //Murali:Passing  the bC to insert values from AsyncApexJob line no:119
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        /*
Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
batchLog.Batch_Name__c = batchName;
batchLog.Start_Time__c= batchStartTime;
batchLog.Complete_Time__c = system.now();
batchLog.Error_msg__c = String.join(failureMsgs, '\n');
batchLog.Failure_records__c = totalFailureRecords ;
if(batchStatus == 'Processing'){
batchLog.Status__c = 'Completed';
}
else if(totalFailureRecords >0 || this.batchStatus == 'Failed'){
batchLog.status__c=batchStatus;
}
batchLog.Total_no_of_records_processed__c = totalRecords;
insert batchLog;*/
        List<Asset> astList = new List<Asset>();
        Set<Id> astIDs = new Set<Id>();
        if(apiRespRecList.size() < 10000){
            for(API_Response__c ar : apiRespRecList) {
                //Murali:Added the failureAst for unable to lock row line no:136
                if(!failureAssetIds.contains(ar.Asset__r.id)){
                    ar.Status__c = 'PROCESSED';
                    ar.AfterAssetProcDttime__c=system.now();
                    ar.BefAssetProcDttime__c =BefAssetProcDttime;
                    ar.BefAssetProcTime__c=(BefAssetProcDttime.getTime()/1000);
                    ar.AfterAssetProcTime__c=(system.now().getTime()/1000);
                           astIDs.add(ar.Asset__c);
                }
            }
            update apiRespRecList;
            if(astIDs.size()>0){
                astList = [Select Id, Current_Location__c, State_of_pallet__c, AccountId from Asset where id in :astIDs];
            }
            database.executeBatch(new RedesignAC_Downstream_Config_UpdateBatch(astList),200);
        }
        else{
            //Murali:Added the failureAst for unable to lock row line no:156
            database.executeBatch(new RedesignNL_UpdateAPIResponse(failureAssetIds,BefAssetProcDttime,apiRespRecList),2000);
        }
    }
    
    public static Asset updateAssetSummary(Asset ast,Asset_History_custom__c ahc) {
        ast.Movement__c = ahc.Start_Time__c;
        ast.Movement_End__c = ahc.End_Time__c;
        return ast;
    }
    
    public static List<Asset_History_custom__c> createEventRecords(String assetId, List<API_Response_Childs__c> arcEventList, Map<String,Asset_History_custom__c> ahcMap) {
        system.debug('createEventRecords method running');
        // order by createdDate Used by Jayesh
        Map<id, Asset_History_custom__c> arcwithAHCMap = new Map<id, Asset_History_custom__c>(); //Added for 343
        Map<Integer, Asset_History_custom__c> eventMap = new  Map<Integer, Asset_History_custom__c>();
        String rectypeid = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCEventsRecordtype);
        Asset_History_custom__c latestRec= new Asset_History_custom__c();
        Boolean recIncomplete;
        Integer count = 0;
        try{
            if(ahcMap.size()>0){        
                latestRec = ahcMap.containsKey(assetId) ? ahcMap.get(assetId) : null;
                if(latestRec != null && latestRec.Start_time__c != null && latestRec.End_Time__c == null){
                    recIncomplete = true;
                }else{
                    recIncomplete = false;
                }
            }
            else{
                recIncomplete = false;
            }
            
            for(API_Response_Childs__c arc : arcEventList){
                if(arc.Asset__c == assetId) {
                    if(latestRec != null && latestRec.Start_Time__c != null){
                        if(recIncomplete) {
                            if(arc.Event_Name__c == movementEnd && arc.Timestamp_DateTime__c > latestRec.Start_Time__c) {
                                latestRec.End_Time__c = arc.Timestamp_DateTime__c;
                                eventMap.put(count,latestRec);
                                arcwithAHCMap.put(arc.id,latestRec);
                                count++;
                                recIncomplete = false;
                            }
                            else if (arc.Event_Name__c == movement && arc.Timestamp_DateTime__c > latestRec.Start_Time__c){
                                latestRec.End_Time__c = arc.Timestamp_DateTime__c;
                                eventMap.put(count,latestRec);
                                arcwithAHCMap.put(arc.id,latestRec);
                                count++;
                                latestRec = createNewTempAHC(arc,assetId,rectypeid);
                                eventMap.put(count,latestRec);
                                arcwithAHCMap.put(arc.id,latestRec);
                                recIncomplete = true;
                            }
                        }
                        else if(!recIncomplete){
                            if(arc.Event_Name__c == movement && arc.Timestamp_DateTime__c > latestRec.End_Time__c){
                                latestRec = createNewTempAHC(arc,assetId,rectypeid);
                                eventMap.put(count,latestRec);
                                arcwithAHCMap.put(arc.id,latestRec);
                                recIncomplete = true;
                            }
                        }
                    }
                    else if(latestRec.Start_Time__c ==null){
                        if(arc.Event_Name__c == movement){
                            latestRec = createNewTempAHC(arc,assetId,rectypeid);
                            eventMap.put(count,latestRec);
                            arcwithAHCMap.put(arc.id,latestRec);
                            recIncomplete = true;
                        }                
                    }
                }
            }
            
            List<Asset_History_custom__c> ahcListToInsert = new List<Asset_History_custom__c>(eventMap.values());
            upsert ahcListToInsert;
            //Changes for 343 - Need to Assign AHC to Events AHC start
            for(API_Response_Childs__c arc : arcEventList) {
                system.debug(arc.id);
                Asset_History_custom__c ahc = arcwithAHCMap.get(arc.id);
                if(ahc != null) {
                    arc.Asset_History__c = ahc.Id;
                }                
                arc.Status__c = 'Processed';
            }
            update arcEventList;
            //Changes for 343 - Need to Assign AHC to Events AHC end
        }
        catch(Exception e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateEventHistoryBatch', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('RedesignNL_CreateEventHistoryBatch - createEventRecords. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
        
        return eventMap.values();
    }
    
    public static Asset_History_custom__c createNewTempAHC(API_Response_Childs__c arc, string astId,String recTypeId){
        Asset_History_custom__c Ahc = new Asset_History_custom__c();
        Ahc.Start_Time__c = arc.Timestamp_DateTime__c;
        Ahc.Asset__c = astId;
        Ahc.Latest_API_Response_Child__c = arc.Id;
        // tempAhc.Api_Response__c = arc.Api_Response__c;
        Ahc.RecordTypeId = recTypeId;
        return Ahc;
    }
    
}