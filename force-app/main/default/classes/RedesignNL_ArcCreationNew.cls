global class RedesignNL_ArcCreationNew implements Database.Batchable<sObject>,Database.stateful {
    //BatchLog fields
    //  RedesignNL_ArcCreationNew.convertToUnixTimestamp(ahc.Start_Time__c)
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public String query;
    
    global RedesignNL_ArcCreationNew(String query) {
        this.query = query;
    }

    global RedesignNL_ArcCreationNew() {
    }
	        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';
        this.batchStartTime = System.Now();
        if(String.isBlank(query)) {
	        query = 'SELECT Id, Name FROM Asset';   
        }
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        List<Database.UpsertResult> saveResList;
        List<API_Response_Childs__c> ARCToInsert = new List<API_Response_Childs__c>();
        try{
            Map<String, AHCWrapper> AHCTSsetMap = new Map<String, AHCWrapper>();
            Set<String> AHCTSsetCopy = new Set<String>();

            //add order by
            List<Asset_History_Custom__c> ahcList = [Select Id, Facility_location__c,rssi__c,rsrq__c,rsrp__c,Accuracy_meters__c, Asset__c, Name, 
                                                     Still_in_this_Location__c, Start_Time__c, Asset__r.Name, End_Time__c, Latitude__c, Longitude__c, Location__c, 
                                                     Current_Location_Address__c,Cellular_Signal__c,Altitude__c, Battery_Voltage__c, Est_Remaining_Battery__c, Message_Type__c, PowerUptime__c, 
                                                     Api_response__c,currentLocationId__c FROM Asset_History_custom__c WHERE IsDeleted = False AND Delete_Check__c = true AND RecordType.DeveloperName IN ('Location') AND Asset__c IN :Scope order by Asset__c];
            
            for(Asset_History_Custom__c ahc : ahclist) {
                Long StartTimeTS = convertToUnixTimestamp(ahc.Start_Time__c);
                String StartExternalID = ahc.Asset__c + '~' + StartTimeTS + '~Location';
                AHCTSsetMap.put(StartExternalID, new AHCWrapper(ahc, true));
                AHCTSsetCopy.add(StartExternalID);
                system.debug('StartExternalID---'+StartExternalID);
                if(ahc.Still_in_this_Location__c == true && ahc.Start_time__c != ahc.End_Time__c){
                    Long EndTimeTS = convertToUnixTimestamp(ahc.End_Time__c);
                    String EndExternalID = ahc.Asset__c + '~' + EndTimeTS + '~Location';
                    AHCTSsetMap.put(EndExternalID, new AHCWrapper(ahc, false));
                    AHCTSsetCopy.add(EndExternalID);
                    system.debug('EndExternalID---'+EndExternalID);
                }
            }

            List<API_Response_Childs__c> arcLst = [SELECT Id, ARC_External_Id__c, Timestamp_DateTime__c,Asset__c, Status__c FROM API_Response_Childs__c WHERE ARC_External_Id__c in: AHCTSsetCopy // AND Location__c != null AND Asset__c in: scope
                                                   AND RecordType.DeveloperName IN ('Location')];
            
            Set<String> ahcSetIds = AHCTSsetMap.keySet();
            List<API_Response_Childs__c> updateStatusArcList = new List<API_Response_Childs__c>();
            for(API_Response_Childs__c arc:arcLst) {
                if(ahcSetIds.contains(arc.ARC_External_Id__c)) {
                    if((arc.Status__c == 'New' || arc.Status__c == 'Processed')) 
                        AHCTSsetCopy.remove(arc.ARC_External_Id__c);
                    else if(arc.Status__c != 'Google API Error') {
                        AHCTSsetCopy.remove(arc.ARC_External_Id__c);
                        arc.Status__c = 'Processed';
                        updateStatusArcList.add(arc);
                    }
                }
            }
            for(String externalId : AHCTSsetCopy) {
                AHCWrapper ahcw = AHCTSsetMap.get(externalId);
                List<String> items = externalId.split('~');
                if(items.size() > 0) {
                    ARCToInsert.add(createAPIResponseChildren(ahcw.ahc, ahcw.isStart));
                }
            }
            ARCToInsert.addAll(updateStatusArcList);
            totalRecords += ARCToInsert.size();
            if(ARCToInsert.size() > 0)
                saveResList = Database.upsert(ARCToInsert, true);
        }
        catch(exception e){
            Debug_Logs__c debugLog = RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_ArcCreationNew', 'execute', 'DML Error', null, null, true);
            if(ARCToInsert.size() > 0 && saveResList != null && saveResList.size() > 0) {
                integer cnt = 0;
                for(Database.UpsertResult dbr : saveResList) {
                    if(!dbr.isSuccess()) {
                        API_Response_Childs__c arc = ARCToInsert.get(cnt);
                        RedesignNL_CaptureErrors.createDMLErrorLogs(dbr.getErrors(), debugLog,arc.Asset__r.Name);
                    }
                    cnt++;
                }                
            }
            failureMsgs.add('RedesignNL_ArcCreationNew - Error msg: '+e.getMessage());
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
        RedesignNL_Helper.createBatchDataCustom(bC, null, 'RedesignNL_ArcCreationNew', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);   
    }
    
    public static API_Response_Childs__c createAPIResponseChildren(Asset_History_custom__c ahc, Boolean isStart) {
        API_Response_Childs__c arc1;
        try {
            arc1 = new API_Response_Childs__c();
            arc1.Timestamp_DateTime__c = isStart ? ahc.Start_Time__c : ahc.End_Time__c;
            arc1 = ARCcreateMap(arc1, ahc);
            arc1.Name = ahc.Asset__r.Name + '-' + 'Location';
        } catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_ArcCreationNew', 'createAPIResponseChildren', 'DML Error', ahc.Asset__r.Name, null, true);            
            
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
        arc.Timestamp__c = convertToUnixTimestamp(arc.Timestamp_Datetime__c);
        arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + '~Location';
        System.Debug(arc.ARC_External_Id__c);
        
        return arc;
    }
    public static Long convertToUnixTimestamp(DateTime dateTimeValue) {
        // Convert DateTime to Unix timestamp (milliseconds since January 1, 1970)
        Long unixTimestamp = dateTimeValue.getTime();
        
        // Convert milliseconds to seconds (Unix timestamp is usually represented in seconds)
        unixTimestamp = unixTimestamp / 1000;
        
        return unixTimestamp;
    }
    
    public class AHCWrapper {
        public Asset_History_Custom__c ahc;
        public Boolean isStart;
        public AHCWrapper(Asset_History_Custom__c ahc, Boolean isStart) {
            this.ahc = ahc;
            this.isStart = isStart;
        }
    }
}