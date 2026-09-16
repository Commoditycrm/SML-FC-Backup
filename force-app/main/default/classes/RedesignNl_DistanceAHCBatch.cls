/*
* Class Name: RedesignNl_DistanceAHCBatch
* Created By: Govardhan Reddy
* Description: This class is used to Create Distance AHC records and update Asset
* Modified Date  Modified By        Last Change
* July 11,2025    Govardhan Reddy   Newly created
* 
*/
public class RedesignNl_DistanceAHCBatch implements Database.Batchable<sObject>, Database.Stateful{
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public String batchstatus;
    
    public String assetId;
    public static String recType = '';
    public String query='';
    public Datetime BefAssetProcDttime;
    public List<API_Response__c> apiRespRecList;
    public list<Rail_car_data__mdt> railCarData;
    public List<Id> failureAssetIds;
    public Map<string,Rail_car_data__mdt> railCarMap;
    
    Public RedesignNl_DistanceAHCBatch(List<ID>failureAssetIds,Datetime BefAssetProcDttime, List<API_Response__c> apiRespRecList){ 
        //Initializing for BatchLogs
        this.batchName='RedesignNl_DistanceAHCBatch';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime = BefAssetProcDttime;      
        this.apiRespRecList = apiRespRecList;
        this.failureAssetIds =failureAssetIds;
    }
    Public Database.QueryLocator start(Database.BatchableContext BC) {
        railCarMap = New Map<string,Rail_car_data__mdt>();
        railCarData = [select id,label,DeveloperName,Tare_Distance__c,Tare_Weight__c,Loaded_weight__c,Loaded_Distance__c from Rail_car_data__mdt];
        for(Rail_car_data__mdt rc : railCarData){
            railCarMap.put(rc.label,rc);
        }
        this.batchStatus = 'Processing';
        SET<ID> AssetIDSet = New SET<ID>();
        For(API_Response__c ar : apiRespRecList) {
            if(!failureAssetIds.contains(ar.Asset__c)) 
                AssetIDSet.add(ar.Asset__c);
        }
        
        query = 'SELECT Id, Name ,Distance_Datetime__c ,Distance__c,Distance_Level__c,async__c, Capture_Distance_Records__c,' + 
            'rack_type__c,current_weight__c FROM Asset WHERE Id IN :AssetIDSet';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope) {
        
        totalRecords += scope.size();
        Map<String, Asset_History_custom__c> assetLatestDistMap = new Map<String, Asset_History_custom__c>(); 
        Map<String, API_Response_Childs__c> assetLatestARCMap = new Map<String, API_Response_Childs__c>();
        
        List<API_Response_Childs__c> ARCList = [SELECT Id, Asset__c,  Timestamp_DateTime__c, timestamp__c  ,Distance__c,Distance_Level__c,async__c,
                                                Status__c,Asset__r.Capture_Distance_Records__c  ,asset__r.rack_type__c
                                                FROM API_Response_Childs__c 
                                                WHERE Asset__c = :scope and RecordType.DeveloperName = 'Distance' 
                                                AND Status__c = 'New' order by Asset__c, createddate desc];
        if(ARCList.size()>0){
            Map<String, Asset_History_custom__c> ahcmap = new Map<String, Asset_History_custom__c>();
            recType = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.ArcDistanceRecordtype);
            // Create Asset_History_custom__c records using the data FROM API_Response_Childs__c records
            try{
                For(API_Response_Childs__c arc:ARCList){
                    if(arc.Asset__r.Capture_Distance_Records__c  == True){
                        Asset_History_custom__c ahc = New Asset_History_custom__c();
                        ahc.Asset__c = arc.Asset__c;
                        ahc.RecordTypeId = recType;
                        ahc.Start_Time__c = arc.Timestamp_DateTime__c;
                        ahc.End_Time__c = arc.Timestamp_DateTime__c;
                        ahc.Distance__c = arc.Distance__c;
                        ahc.Distance_Level__c = arc.Distance_Level__c;
                        ahc.async__c = arc.async__c;
                        ahc.Latest_API_Response_Child__c = arc.Id;
                        if(railCarMap.containsKey(arc.asset__r.rack_type__c)){
                            Rail_car_data__mdt rcd = railCarMap.get(arc.asset__r.rack_type__c);
                            decimal distance = decimal.valueof(ahc.Distance__c);
                            ahc.current_weight__c = calculateCurrentWeight(rcd,distance);
                        }
                        ahcmap.put(arc.id,ahc);
                        Asset_History_custom__c latestAHC = null;
                        if(!assetLatestDistMap.containsKey(arc.Asset__c)){
                            latestAHC = ahc;
                        }else {
                            latestAHC = assetLatestDistMap.get(arc.Asset__c);
                            if(latestAHC.Start_Time__c < ahc.Start_Time__c)
                                latestAHC = ahc;                
                        }
                        assetLatestDistMap.put(arc.Asset__c, latestAHC);
                    }
                    else{
                        API_Response_Childs__c latestARC = null;
                        if(!assetLatestARCMap.containsKey(arc.Asset__c)) {
                            latestARC = arc;
                        }else {
                            latestARC = assetLatestARCMap.get(arc.Asset__c);
                            if(latestARC.Timestamp_DateTime__c < arc.Timestamp_DateTime__c)
                                latestARC = arc;                
                        }
                        if(latestARC != null){
                            assetLatestARCMap.put(arc.Asset__c, latestARC);
                        }
                    }
                }
                
                if (!ahcmap.values().isEmpty()) {
                    insert ahcmap.values();
                }
            }
            catch(Exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_DistanceAHCBatch', 'execute', 'DML Error', null, null, true);
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNl_DistanceAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
            try{
                for(Asset ast : scope) {
                    Asset_History_custom__c AHCdist = assetLatestDistMap.get(ast.Id);
                    if(AHCdist !=null){
                        if(AHCdist.Start_Time__c >= ast.Distance_Datetime__c || ast.Distance_Datetime__c==null) {
                            ast.Distance_Datetime__c = AHCdist.Start_Time__c != null ? AHCdist.Start_Time__c :ast.Distance_Datetime__c;
                            ast.Distance__c = AHCdist.Distance__c != null ? AHCdist.Distance__c :ast.Distance__c;
                            ast.Distance_Level__c = AHCdist.Distance_Level__c != null ? AHCdist.Distance_Level__c :ast.Distance_Level__c;
                            ast.async__c = AHCdist.async__c != null ? AHCdist.async__c :ast.async__c;
                            ast.current_weight__c = AHCdist.current_weight__c != null ? AHCdist.current_weight__c :ast.current_weight__c;

                        }
                    }
                    else{
                        API_Response_Childs__c ARCdist = assetLatestARCMap.get(ast.Id);
                        if(ARCdist !=null){
                            if(ARCdist.Timestamp_DateTime__c >= ast.Distance_Datetime__c || ast.Distance_Datetime__c==null){
                                if(railCarMap.containsKey(ARCdist.asset__r.rack_type__c)){
                                    Rail_car_data__mdt rcd = railCarMap.get(ast.rack_type__c);
                                    decimal distance = decimal.valueof(ARCdist.Distance__c);
                                    ast.current_weight__c = calculateCurrentWeight(rcd,distance);
                                }
                                    ast.Distance_Datetime__c = ARCdist.timestamp_Datetime__c != null ? ARCdist.timestamp_Datetime__c :ast.Distance_Datetime__c;
                                    ast.Distance__c = ARCdist.Distance__c != null ? ARCdist.Distance__c :ast.Distance__c;
                                    ast.Distance_Level__c = ARCdist.Distance_Level__c != null ? ARCdist.Distance_Level__c :ast.Distance_Level__c;
                                    ast.async__c = ARCdist.async__c != null ? ARCdist.async__c :ast.async__c;
                                }
                        }
                    }
                }
            }
            catch(Exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_DistanceAHCBatch', 'execute', 'DML Error', null, null, true);
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNl_DistanceAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
            
            try{
                for (API_Response_Childs__c apiRespChild : ARCList) {
                    apiRespChild.Status__c = 'Processed';
                    Asset_History_custom__c ahc = ahcmap.get(apiRespChild.Id);
                    if(ahc != null)
                        apiRespChild.Asset_History__c = ahc.Id;
                }
                
                if(ARCList.size() > 0) {
                    update ARCList;
                }
                if (!scope.isEmpty()) {
                    update scope;
                }
            }
            catch(Exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_DistanceAHCBatch', 'execute', 'DML Error', null, null, true);
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNl_DistanceAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
        }
    }
    
    public void finish(Database.Batchablecontext BC){
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        database.executeBatch(new RedesignNL_CreateEventHistoryBatch(failureAssetIds,BefAssetProcDttime,apiRespRecList),250);

    }
    public static Decimal calculateCurrentWeight(Rail_car_data__mdt record, decimal distance) {
        Decimal loadedWeight = record.Loaded_Weight__c;
        Decimal tareWeight = record.Tare_Weight__c;
        Decimal tareDistance = record.Tare_Distance__c;
        Decimal loadedDistance = record.Loaded_Distance__c;

            Decimal currentWeight = 
                (loadedWeight - tareWeight) * (tareDistance - distance) 
                / (tareDistance - loadedDistance) + tareWeight;

		return currentWeight < tareWeight ? tareWeight : currentWeight;
    }
    
}