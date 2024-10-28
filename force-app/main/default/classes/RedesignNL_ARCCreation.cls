/*
 * Class Name: RedesignNL_ARCCreation
 * Created By: Murali Krishna
 * Description: This class is used to recreate API Response Childs records from Asset History Custom which doesn't have ARC records
 * Modified Date  Modified By  		Last Change
 *  Jan 14, 2024   Jayesh Khattar   converted the Class to Batch Class
 *  Jan 16, 2024   Murali Krishna   added CurrentLocationID,Altitude,Signal.Added the Batch Data Custom,errorlog method and modified the RecordtypeID
 */  
global class RedesignNL_ARCCreation implements Database.Batchable<sObject> {
    
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public static String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchStatus = 'Processing';
        String query = 'SELECT Id, Name FROM Asset';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Asset> scope) {
        Set<Id> assetIds = new Set<Id>();
        for(Asset ast : scope) {
            assetIds.add(ast.Id);
        }
        
        List<Asset_History_Custom__c> ahcList = [Select Id, Facility_location__c,rssi__c,rsrq__c,rsrp__c,Accuracy_meters__c, Asset__c, Name, 
                                                 Still_in_this_Location__c, Start_Time__c, Asset__r.Name, End_Time__c, Latitude__c, Longitude__c, Location__c, 
                                                 Current_Location_Address__c,Cellular_Signal__c,Altitude__c, Battery_Voltage__c, Est_Remaining_Battery__c, Message_Type__c, PowerUptime__c, 
                                                 Api_response__c,currentLocationId__c from Asset_History_Custom__c where 
                                                 Asset__c in :assetIds and End_time__c = Last_N_Days:35 AND RecordType.DeveloperName ='Location'];
        
        Map<Id, AHCWrapper> assetAhcTimeMap = new Map<Id, AHCWrapper>();
        Map<Id, Asset_History_Custom__c> assetAhcMap = new Map<Id, Asset_History_Custom__c>();
        
        for(Asset_History_Custom__c agr : ahcList) {
            AHCWrapper ahcw = new AHCWrapper();
            ahcw.startTime = agr.Start_Time__c;
            ahcw.endTime = agr.End_Time__c;
            assetAhcTimeMap.put(agr.Asset__c, ahcw);
            assetAhcMap.put(agr.Asset__c, agr);
        }
        
        Map<Id, Asset_History_Custom__c> startTimeArcMap = new Map<Id, Asset_History_Custom__c>();
        Map<Id, Asset_History_Custom__c> endTimeArcMap = new Map<Id, Asset_History_Custom__c>();
        
        for(Id ast : assetAhcTimeMap.keySet()) {
            AHCWrapper ahcw = assetAhcTimeMap.get(ast);
            List<API_Response_Childs__c> arcChildStartRes = [Select Id, Name, Timestamp_DateTime__c from API_Response_Childs__c where Asset__c = :ast and 
                                                             Timestamp_DateTime__c = :ahcw.startTime AND Recordtype.DeveloperName = 'Location' LIMIT 1];
            List<API_Response_Childs__c> arcChildEndRes = [Select Id, Name, Timestamp_DateTime__c from API_Response_Childs__c where Asset__c = :ast and 
                                                           Timestamp_DateTime__c = :ahcw.endTime AND Recordtype.DeveloperName = 'Location' LIMIT 1];
            if(arcChildStartRes.size() == 0)
                startTimeArcMap.put(ast, assetAhcMap.get(ast));
            if(arcChildEndRes.size() == 0)
                endTimeArcMap.put(ast, assetAhcMap.get(ast));
        }
        List<API_Response_childs__c> arcToInsertList = new List<API_Response_childs__c>();
        for(Id ast : startTimeArcMap.keySet()) {
            arcToInsertList.add(createAPIResponseChildren(startTimeArcMap.get(ast),true));
        }
        for(Id ast : endTimeArcMap.keySet()) {
            arcToInsertList.add(createAPIResponseChildren(endTimeArcMap.get(ast),false));
        }
        if(arcToInsertList.size() > 0)
            insert arcToInsertList;
    }
    
    global void finish(Database.BatchableContext bc) {
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
        if(batchStatus == 'Processing'){
            batchLog.Status__c = 'Completed';
        }
        else{
            batchLog.status__c=batchStatus;
        }
        batchLog.Total_no_of_records_processed__c = totalRecords;
        insert batchLog;        
    }

    public static API_Response_Childs__c createAPIResponseChildren(Asset_History_custom__c ahc, Boolean isStart) {
        API_Response_Childs__c arc1;
        try {
            arc1 = new API_Response_Childs__c();
            arc1.Timestamp_DateTime__c = isStart ? ahc.Start_Time__c : ahc.End_Time__c;
            arc1 = ARCcreateMap(arc1, ahc);
            arc1.Name = ahc.Asset__r.Name + '-' + 'Location';
        } catch(Exception ex) {
            batchStatus = 'Processing';
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_ARCCreation', 'createAPIResponseChildren', 'DML Error', ahc.Asset__r.Name, null, true);            

        }
        return arc1;
    }
    private static API_Response_Childs__c ARCcreateMap(API_Response_Childs__c arc, Asset_History_custom__c ahc) {
        arc.Asset_History__c = ahc.Id;
        arc.Latitude__c = String.valueOf(ahc.Latitude__c);
        arc.Longitude__c = String.valueOf(ahc.Longitude__c);
        arc.Location__c = ahc.Location__c;
        arc.Current_Location_Address__c = ahc.Current_Location_Address__c;
        arc.CurrentLocationId__c = ahc.currentLocationId__c != null ? ahc.currentLocationId__c :null;
        arc.Accuracy_meters__c = ahc.Accuracy_meters__c;
        arc.Asset__c = ahc.Asset__c;
        arc.Alt__c = ahc.Altitude__c;
        arc.Status__c = 'Processed';
        arc.Signal__c = ahc.Cellular_Signal__c;
        arc.Battery__c = ahc.Battery_Voltage__c;
        arc.EstBattPct__c = ahc.Est_Remaining_Battery__c;
        arc.Message_Type__c = String.valueOf(ahc.Message_Type__c);
        arc.PowerUptime__c = ahc.PowerUptime__c;
        arc.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
        arc.Accuracy_meters__c = ahc.Accuracy_meters__c;
        arc.Facility_Location__c = ahc.Facility_Location__c;
        arc.rsrp__c = ahc.rsrp__c;
        arc.rsrq__c = ahc.rsrq__c;
        arc.rssi__c = ahc.rssi__c;
        arc.ARC_External_Id__c = ahc.Asset__c + '~' + arc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';

        
        return arc;
    }
    
    private class AHCWrapper {
        private DateTime startTime;
        private DateTime endTime;
    }
    
}