/*
* Class Name: RedesignNL_TemperatureAHCBatch
* Created By: Murali Krishna
* Description: This class is used to Create Temperature AHC records and update Asset
* Modified Date  Modified By        Last Change
* Jan 22,2024    Murali Krishna     Added the Try catch method on line no.81 and 127
* Feb 12,2024    Murali Krishna    Passing the Batch Job to Helper class to Insert the values in the BDC from Apexjob
* Feb 13,2024    Murali Krishna    Added FailureAstIds list to not Process Batch for Asset having Exception on Unable to Lock Row
* 
*/
Global class RedesignNL_TemperatureAHCBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String assetId;
    public static String recType = '';
    public String query='';
    public Datetime BefAssetProcDttime;
    public List<API_Response__c> apiRespRecList;
    //Murali:Added the failureAst for unable to lock row line no:19
    public List<Id> failureAssetIds;
    
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public String batchstatus;
    
    public RedesignNL_TemperatureAHCBatch() {
        //Initializing for BatchLogs
        this.batchName='RedesignNL_TemperatureAHCBatch';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime= system.now();
        
    }
    
    public RedesignNL_TemperatureAHCBatch(String query) {
        //Initializing for BatchLogs
        this.batchName='RedesignNL_TemperatureAHCBatch';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime= system.now();
        this.query = query;
    }
    
    //contructor for chaining batch - Chandru
    Public RedesignNL_TemperatureAHCBatch(List<ID>failureAssetIds,Datetime BefAssetProcDttime, List<API_Response__c> apiRespRecList){ 
        //Initializing for BatchLogs
        this.batchName='RedesignNL_TemperatureAHCBatch';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime = BefAssetProcDttime;      
        this.apiRespRecList = apiRespRecList;
        //Murali:Added the failureAst for unable to lock row line no:53
        this.failureAssetIds =failureAssetIds;
    }
    
    Public Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';
        if(String.isBlank(query)) {
            SET<ID> AssetIDSet = New SET<ID>();
            For(API_Response__c ar : apiRespRecList) {
               //Murali:Added the failureAst for unable to lock row line no:61
               if(!failureAssetIds.contains(ar.Asset__c)) 
                 AssetIDSet.add(ar.Asset__c);
            }
            //Murali - Add the flag here for capture temperature response
            query = 'SELECT Id, Name, Latest_Temp_AHC__c, Humidity__c, Temperature__c, Capture_Temperature_Response__c, Last_Connected__c, Latest_Temp_ahc__r.Start_Time__c ' + 
                'FROM Asset WHERE Id IN :AssetIDSet';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope) {
        
        totalRecords += scope.size();
        Map<String, Asset_History_custom__c> assetLatestTempMap = new Map<String, Asset_History_custom__c>();
        Map<String, API_Response_Childs__c> assetLatestARCMap = new Map<String, API_Response_Childs__c>();
        
        List<API_Response_Childs__c> ARCList = [SELECT Id, Asset__c, Temperature__c, Relative_Humidity__c, Timestamp_DateTime__c, 
                                                Status__c,Asset__r.Capture_Temperature_Response__c 
                                                FROM API_Response_Childs__c 
                                                WHERE Asset__c = :scope and Temperature__c != null 
                                                and RecordType.DeveloperName = 'Temperature' 
                                                AND Status__c = 'New' order by Asset__c, createddate asc];
        if(ARCList.size()>0){
            Map<String, Asset_History_custom__c> ahcmap = new Map<String, Asset_History_custom__c>();
            recType = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCTemperatureRecordtype);
            // Create Asset_History_custom__c records using the data FROM API_Response_Childs__c records
            try{
                For(API_Response_Childs__c arc:ARCList){
                    if(arc.Asset__r.Capture_Temperature_Response__c == True){
                        Asset_History_custom__c ahc = New Asset_History_custom__c();
                        ahc.Asset__c = arc.Asset__c;
                        ahc.RecordTypeId = recType;
                        ahc.Start_Time__c = arc.Timestamp_DateTime__c;
                        ahc.End_Time__c = arc.Timestamp_DateTime__c;
                        ahc.Temperature__c = arc.Temperature__c;
                        ahc.Relative_Humidity__c = arc.Relative_Humidity__c;
                        ahc.Latest_API_Response_Child__c = arc.Id;
                        ahcmap.put(arc.id,ahc);
                        Asset_History_custom__c latestAHC = null;
                        if(!assetLatestTempMap.containsKey(arc.Asset__c)) 
                            latestAHC = ahc;
                        else {
                            latestAHC = assetLatestTempMap.get(arc.Asset__c);
                            if(latestAHC.Start_Time__c < ahc.Start_Time__c)
                                latestAHC = ahc;                
                        }
                        assetLatestTempMap.put(arc.Asset__c, latestAHC);
                    }
                    else{
                        API_Response_Childs__c latestARC = null;
                        if(!assetLatestARCMap.containsKey(arc.Asset__c)) 
                            latestARC = arc;
                        else {
                            latestARC = assetLatestARCMap.get(arc.Asset__c);
                            if(latestARC.Timestamp_DateTime__c < arc.Timestamp_DateTime__c)
                                latestARC = arc;                
                        }
                        if(latestARC != null)
                            assetLatestARCMap.put(arc.Asset__c, latestARC);
                    }
                }
                
                if (!ahcmap.values().isEmpty()) {
                    insert ahcmap.values();
                }
            }
            catch(Exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_TemperatureAHCBatch', 'execute', 'DML Error', null, null, true);
                //                RedesignNL_Helper.sendemail('RedesignNL_TemperatureAHCBatchError'+ '\n' + ' Error while Inserting AHC records-  '+ '\n' + 'error msg'+ex.getMessage()+'-Line-'+ex.getLineNumber()+'-Type-'+ ex.getTypeName());
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNL_TemperatureAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
            try{
                for(Asset ast : scope) {
                    Asset_History_custom__c AHCTemp = assetLatestTempMap.get(ast.Id);
                    if(AHCTemp !=null){
                       if(ast.Latest_Temp_AHC__c == null || (AHCTemp.Start_Time__c >= ast.Latest_Temp_ahc__r.Start_Time__c)) {
                        	ast.Latest_Temp_AHC__c = AHCTemp.Id;
                            ast.Temperature__c = AHCTemp.Temperature__c == null ? ast.Temperature__c :AHCTemp.Temperature__c;
                            ast.Humidity__c=AHCTemp.Relative_Humidity__c == null ? ast.Humidity__c : AHCTemp.Relative_Humidity__c;
                        }
                    }
                    else{
                        API_Response_Childs__c ARCTemp = assetLatestARCMap.get(ast.Id);
                        if(ARCTemp !=null){
                                ast.Temperature__c = ARCTemp.Temperature__c == null ? ast.Temperature__c :ARCTemp.Temperature__c;
                                ast.Humidity__c=ARCTemp.Relative_Humidity__c == null ? ast.Humidity__c : ARCTemp.Relative_Humidity__c;
                            }
                        }
                    }
                }
            catch(Exception ex){
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_TemperatureAHCBatch', 'execute', 'DML Error', null, null, true);
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNL_TemperatureAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
                //            RedesignNL_Helper.sendemail('RedesignNL_TemperatureAHCBatch'+ '\n' + 'Error occured in TemperatureBatch -  '+ '\n' + 'error msg'+ex.getMessage()+'-Line-'+ex.getLineNumber()+'-Type-'+ ex.getTypeName());            
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
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_TemperatureAHCBatch', 'execute', 'DML Error', null, null, true);
                this.batchStatus='Failed';
                failureMsgs.add('RedesignNL_TemperatureAHCBatch- Error msg: '+ex.getMessage());
                totalFailureRecords = totalFailureRecords + 1;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        //Murali:Passing  the bC to insert values from AsyncApexJob line no:194
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);

        //Murali:Added the failureAst for unable to lock row line no:213
        database.executeBatch(new RedesignNL_CreateEventHistoryBatch(failureAssetIds,BefAssetProcDttime,apiRespRecList),250);
        List<Asset> batterylst=[SELECT Id, Battery_Replaced_Date__c, Power_Reset_Occurred__c, Power_Reset_Time__c 
                                FROM Asset 
                                WHERE battery_check__c=true and Power_Reset_Occurred__c =true];
        if(batterylst.size()>0){
            for(asset ast:batterylst){
                ast.Power_Reset_Occurred__c=false;
                ast.Power_Reset_Time__c=null;
            }
            update batterylst;
        }
    }
}