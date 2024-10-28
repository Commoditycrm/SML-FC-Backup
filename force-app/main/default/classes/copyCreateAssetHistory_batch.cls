global class copyCreateAssetHistory_batch implements Database.Batchable<sObject>, Database.Stateful{
    
    public string query;
    public Datetime now;
    public static String lastKnownLocation;
    public static String lastKnownId;
    public static DateTime lastKnownTime;
    
    public static map<String,String> assetLastLocationMap = new map<String,String>();
    public Datetime BefAssetProcDttime;    
    public List<API_Response__c> apiRespRecList;
    //Murali:Added the failureAst for unable to lock row line no:25,26
    public  List<Id> failureAssetIds = new List<Id>();
    public static List<Id> failureAst = new List<Id>();
    Public static boolean Locationcheck;
    
    //BatchLog fields
    public String batchName;
    public String batchStatus;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    
    public Boolean runBatchWithlimited = false;
    
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    public copyCreateAssetHistory_batch(String query) {//, Datetime endTime) {
        this.query = query;
        //Initializing for BatchLogs
        this.batchName='RedesignNL_CreateAssetHistoryBatch';
        this.batchStartTime = system.Now();        
    }
    
    public copyCreateAssetHistory_batch() {       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        this.batchStatus = 'Processing';
        BefAssetProcDttime = system.now();
        query = 'SELECT Id, Name, Facility_Location__c, Last_KNown_Location__c,src__c, Current_Location__c,Latest_Location_AHC__c, '+
                'CreatedDate, Latest_Location_AHC__r.End_Time__c, Current_Location__r.Name, estBattPct__c, Last_Synced_Timestamp__c, '+
                'Power_Reset_Occurred__c, Power_Reset_Time__c, Current_Address__c,'+
                'Accuracy_meters__c,PowerUp_Time__c,Signal__c,  Temporary_Latitude__c,  Temporary_Longitude__c,'+ 
                'Start_Time__c, C__c,Temperature__c, rssi__c, device_Id__c, Date_Shipped__c, Last_Connected_Map__c,Account_to_Update__c, '+
                'rsrp__c, rsrq__c,alt__c, Battery_Voltage__c,Last_Connected2__c,Current_Location_Address__c,LocationId,Battery_Replaced_Date__c,'+
                'Last_Connected__c,State_of_Pallet__c,Current_State__c From '+
               'Asset WHERE Name = \'at5-t143d9523848\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        totalRecords += scope.size();
        String rectypeid = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
        List<String> assetIds = new List<string>();
        Map<ID,Asset> astMap = new Map<Id,Asset>();
        List<Asset_History_Custom__c> insertAHCList = new List<Asset_History_Custom__c>();
        for(Asset ast : scope) {
            astMap.put(ast.ID,ast);
            locationcheck=false;
            assetIds.add(ast.id);
            DateTime now = System.now();
            lastKnownLocation = null;
            lastKnownId = null;
            Map<String,Datetime> resultTS= DeleteExistingRecords(ast);
            //Murali:Added the failureAst for unable to lock row line no:84,88
            if(failureAst.size()> 0 && failureAst.contains(ast.id)){
                failureAssetIds.add(ast.id);
            }
            if(resultTS.size()>0 && resultTS.get('Endtime') != null && resultTS.get('Starttime') != null && !failureAst.contains(ast.id)) {
                List<RedesignNL_getAssetHistory.AssetHistory> assHistList = RedesignNL_getAssetHistory.getAllHistoryRecords(ast, String.valueOf(ast.Id), resultTS.get('Starttime'), resultTS.get('Endtime'), false);
                List<Asset_History_Custom__c> ahcList = createAHCRecords(ast, assHistList, rectypeid);
                if(ahcList.size() > 0){
                    //system.debug(lastKnownLocation);
                    //system.debug(lastKnownId);
                    ast.Last_Synced_Timestamp__c = System.now();
                    ast = updateAssetSummary(ast,ahcList[0]);
                    //update arc status From endTime to down records  
                    updateArcStatus(resultTS.get('Endtime'),ast.id);
                    //system.debug(ast.Last_Known_Location__c);
                }
                
            }
        } 
        //added from fullcopyØ
        //update scope; 
        List<Database.SaveResult> updateResultList = Database.update(scope, false);
        if(updateResultList.size()>0){
            List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
            for(Database.SaveResult ds : updateResultList){
                if(!ds.isSuccess()){
                    Debug_Logs__c dl = new Debug_Logs__c();
                    Asset asd = astMap.get(ds.getId());
                    dl.Asset_Device_ID__c = asd.Name;
                    dl.Asset__c = asd.id;
                    dl.Class_Name__c='RedesignNL_CreateAssetHistoryBatch';
                    dl.Method_Name__c='Update Asset';
                    for(Database.Error err : ds.getErrors()) {
                        dl.Error_Message__c = dl.Error_Message__c == null ? err.getMessage() : dl.Error_Message__c+', '+err.getMessage();
                    }
                    debugLogsToInset.add(dl);
                }
                //RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'parseRequestBody', 'DML Error', deviceId, requestBody, true);            
            }
            if(debugLogsToInset.size()>0) {
                insert debugLogsToInset;            
            }
        }
        //added from fullcopy
    }
    global void finish(Database.BatchableContext bC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        } //Murali:Passing  the bC to insert values from AsyncApexJob line no:130
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        //Murali:Added the failureAst for unable to lock row line no:132
        //database.executeBatch(New RedesignNL_TemperatureAHCBatch(failureAssetIds,BefAssetProcDttime,apiRespRecList),250);
        
    }
    
    public static  Map<String,Datetime> DeleteExistingRecords(Asset ast) {
        String query, query1;
        query = 'SELECT Id, name,ARC_External_Id__c, Timestamp_DateTime__c, CreatedDate '+
            'From API_Response_Childs__c WHERE Asset__c =\''+ ast.Id+'\' AND status__c = \'New\' '+
            'AND Timestamp_DateTime__c != null AND Recordtype.DeveloperName = \'Location\' '+
            'ORDER BY Timestamp_DateTime__c asc limit 1';
        query1 = 'SELECT Id, name,ARC_External_Id__c, Timestamp_DateTime__c, CreatedDate '+
            'From API_Response_Childs__c WHERE Asset__c =\''+ ast.Id+'\' AND status__c IN (\'New\', \'Processed\') '+
            'AND Timestamp_DateTime__c != null AND Recordtype.DeveloperName = \'Location\' '+
            'ORDER BY CreatedDate desc limit 1';
        List<API_Response_Childs__c> apiRespList = Database.query(query);
        List<API_Response_Childs__c> apiRespList1 = Database.query(query1);
        Datetime earlistTS = null;
        Map<String,DateTime> endTimeList = new Map<String,DateTime>();
        
        if(apiRespList.size()>0) {
            //Murali--Assigning the value to earliestTS which is used in ahclist query
            earlistTS= apiRespList[0].Timestamp_DateTime__c;
            endTimeList.put('Starttime',apiRespList[0].Timestamp_DateTime__c);
            endTimeList.put('Endtime',apiRespList1[0].CreatedDate);
            List<Asset_History_Custom__c> ahcList = [SELECT Id, Name, Start_Time__c,Current_Location_Address__c , Location__c,Still_in_this_Location__c,
                                                     Last_known_location_Lookup__c,Last_Known_Location__c
                                                     From Asset_History_Custom__c 
                                                     WHERE Asset__c =: ast.Id 
                                                     //Murali: only pick records which has End_time__c <= last 30 days
                                                     //AND Delete_Check__c = true
                                                     AND Recordtype.DeveloperName  in ('Location','Dwell_Time')
                                                     AND End_Time__c >=: earlistTS 
                                                     ORDER by start_Time__c ASC];
            
            if(ahcList.size() > 0) {
                try{
                    
                    Datetime initialDate = null;
                    for(Asset_History_Custom__c obj : ahcList){
                        if(initialDate == null && obj.Location__c != 'In Transit - Ever'){
                            initialDate = obj.Start_Time__c;
                            lastKnownTime = obj.Start_Time__c;
                            lastKnownLocation= obj.Last_Known_Location__c;
                            lastKnownId = obj.Last_known_location_Lookup__c;
                            //system.debug(lastKnownLocation);
                            //system.debug(lastKnownId);
                            
                        }
                        if(initialDate != null && initialDate > obj.Start_Time__c){
                            initialDate = obj.Start_Time__c;
                            lastKnownTime= obj.Start_Time__c;
                            lastKnownLocation= obj.Last_Known_Location__c;
                            lastKnownId = obj.Last_known_location_Lookup__c;
                            //system.debug(lastKnownLocation);
                            //system.debug(lastKnownId);
                            
                        }
                    }
                    
                    //  RedesignNL_ARCCreation.ahclist(ahclist,assetSumm);
                    //  earlistTS = ahcList[0].Start_Time__c;
                    if(initialDate != null){
                        earlistTS = initialDate;
                        endTimeList.put('Starttime',earlistTS);
                    }
                    Database.delete(ahcList, false);
                }
                catch (DMLException e) {
                    RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'DeleteExistingRecords', 'DML Error', ast.device_Id__c, null, true);
                    //Murali:Added the failureAst for unable to lock row
                    failureAst.add(ast.Id);
                    failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - DeleteExistingRecords. Error msg: '+e.getMessage());
                    totalFailureRecords = totalFailureRecords + 1;
                    
                }
                return endTimeList;
            }
            else{
                List<Asset_History_Custom__c> stillInLocation = [SELECT Id, Name,Last_known_location_Lookup__c, Start_Time__c,Last_Known_Location__c, Asset__c, Still_in_this_Location__c,Current_Location_Address__c 
                                                                 From Asset_History_Custom__c
                                                                 WHERE Asset__c =: ast.Id 
                                                                 AND Recordtype.developerName = 'Location' 
                                                                 AND Still_in_this_Location__c = true 
                                                                 ORDER BY start_Time__c ASC];
                if(stillInLocation.size() > 0) {
                    earlistTS = stillInLocation[0].Start_Time__c;
                    Endtimelist.put('Starttime',earlistTS);
                    try{
                        lastKnownTime = stillInLocation[0].Start_Time__c;
                        lastKnownLocation= stillInLocation[0].Last_Known_Location__c;
                        lastKnownId = stillInLocation[0].Last_known_location_Lookup__c;
                        //system.debug(lastKnownLocation);
                        //system.debug(lastKnownId);
                        //   RedesignNL_ARCCreation.ahclist(stillInLocation,assetSumm);                       
                        Database.delete(stillInLocation, true);
                    }
                    catch (DMLException e) {
                        RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'DeleteExistingRecords', 'DML Error', ast.device_Id__c, null, true);
                        //Murali:Added the failureAst for unable to lock row
                        failureAst.add(ast.Id);
                        failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - DeleteExistingRecords. Error msg: '+e.getMessage());
                        totalFailureRecords = totalFailureRecords + 1;
                        
                    }
                    return Endtimelist;
                }
                else
                    return Endtimelist;
            }
        }
        else
            return Endtimelist;
    }
    public static Asset updateAssetSummary(Asset ast,Asset_History_Custom__c ahc) {
        try {
            if(ast.Account_to_Update__c != Null){
                ast.AccountId= ast.Account_to_Update__c;
                ast.Account_to_Update__c= null;
            }
            ast.Accuracy_meters__c = ahc.Accuracy_meters__c == null ? ast.Accuracy_meters__c : ahc.Accuracy_meters__c;
            ast.Current_Address__c = String.isBlank(ahc.Current_Location_Address__c) ? ast.Current_Address__c : ahc.Current_Location_Address__c;
            String location = String.isBlank(ahc.Location__c) ? '' : ahc.Location__c;
            ast.Current_State__c = ast.Current_Address__c != null ? RedesignNL_AddressParser.getState(ast.Current_Address__c): null;
            ast.Temporary_Longitude__c= ahc.Longitude__c == null ? ast.Temporary_Longitude__c : ahc.Longitude__c;
            ast.Start_Time__c=ahc.Start_Time__c == null ? ast.Start_Time__c : ahc.Start_Time__c;
            ast.Temporary_Latitude__c =ahc.Latitude__c == null ? ast.Temporary_Latitude__c : ahc.Latitude__c;
            ast.rssi__c=ahc.rssi__c == null ? ast.rssi__c : ahc.rssi__c;
            ast.Last_Known_Location__c = String.isBlank(ahc.Last_known_location_Lookup__c) ? null : ahc.Last_known_location_Lookup__c;
            ast.rsrp__c=ahc.rsrp__c == null ? ast.rsrp__c : ahc.rsrp__c;
            ast.rsrq__c=ahc.rsrq__c == null ? ast.rsrq__c : ahc.rsrq__c;
            ast.Signal__c=ahc.Cellular_Signal__c == null ? ast.Signal__c : ahc.Cellular_Signal__c;
            ast.Battery_Voltage__c=ahc.Battery_Voltage__c == null ? ast.Battery_Voltage__c : ahc.Battery_Voltage__c;
            ast.alt__c = ahc.Altitude__c == null ? ast.alt__c : ahc.Altitude__c;
            ast.PowerUp_Time__c=ahc.PowerUptime__c == null ? ast.PowerUp_Time__c : ahc.PowerUptime__c;
            ast.estBattPct__c=ahc.estBattPct__c == null ? ast.estBattPct__c : ahc.estBattPct__c;
            if(ast.Latest_Location_AHC__c == null || ahc.End_Time__c >= ast.Latest_Location_AHC__r.End_Time__c) {
                ast.Latest_Location_AHC__c = ahc.Id;
            }
            system.debug(location);
            if (location == 'In Transit') {
                ast.State_of_Pallet__c = 'In Transit';
            } else if (location != '' && location != 'In Transit') {
                ast.State_of_Pallet__c = 'In Network';
            }
            ast.Current_Location__c = String.isBlank(assetLastLocationMap.get(ast.Id)) ?  ast.Current_Location__c :assetLastLocationMap.get(ast.Id);
            if(ast.State_of_Pallet__c == 'In Transit') {
                ast.Current_Location__c = null;
            }
            ast.src__c = ahc.Message_Type__c != null ? ahc.Message_Type__c : ast.src__c;
            
           // condition for power reset update in ast.
                if(ast.Power_Reset_Occurred__c == false && ahc.Power_Reset_Occurred__c == true){
                ast.Power_Reset_Occurred__c = true;
                ast.Power_Reset_Time__c = ahc.Power_Reset_Time__c;
            }else if(ahc.Power_Reset_Occurred__c == false && ast.Power_Reset_Occurred__c == true && ast.Battery_Replaced_Date__c != null && ast.Battery_Replaced_Date__c > ast.Power_Reset_Time__c){
                ast.Power_Reset_Occurred__c = false;
                ast.Power_Reset_Time__c = null;
            }
            //ast.Deleted_AHC__c = false;
            ast.Facility_Location__c = ahc.Facility_Location__c;
            ast.Last_Connected2__c = (ast.Last_Connected2__c == null) ||(ahc.Device_Status_Time__c != null && ast.Last_Connected2__c < ahc.Device_Status_Time__c)?   ahc.Device_Status_Time__c : ast.Last_Connected2__c;
            datetime lastconnect = (ast.Last_Connected2__c == null) ||(ahc.End_Time__c != null && ast.Last_Connected2__c < ahc.End_Time__c)?   ahc.End_Time__c : ast.Last_Connected2__c;
            ast.Last_Connected__c  = (ast.Last_Connected__c == null) ||(lastconnect != null && ast.Last_Connected__c < lastconnect)?   lastconnect : ast.Last_Connected__c;
            ast = updateLastConnectedMapFields(ast);
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_CreateAssetHistoryBatch', 'updateAssetSummary', 'Exception', ast.device_Id__c, null, true);
            failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - updateAssetSummary. Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            
        }
        return ast;
    }
    
    public static List<Asset_History_Custom__c> createAHCRecords(Asset ast, List<RedesignNL_getAssetHistory.AssetHistory> assetHistoryList, String rectypeid) {
        Map<Integer, Asset_History_Custom__c> ahcListMap = New Map<Integer, Asset_History_Custom__c>();
        integer i=0;
        String currentLoc = '';
        Boolean ConsiderForDwell = true;
        Map<Integer, List<String>> apiResponseUpdateMap = new Map<Integer, List<String>>();
        Asset_history_custom__c knownlocation = new Asset_history_custom__c();
        try{  //removed 354 and added here
            for(RedesignNL_getAssetHistory.AssetHistory ahw : assetHistoryList) {
                Asset_History_Custom__c ahc = new Asset_History_Custom__c();
                ahc.Asset__c = ast.Id;
                currentLoc = String.isBlank(currentLoc) ? ahw.currentLocationId : currentLoc;
                ahc.Last_known_location__c = ahw.lastKnownLocation;
                ahc.Last_known_location_Lookup__c = ahw.lastKnownLocationId != null ? Id.valueof(ahw.lastKnownLocationId) : null;
                
                system.debug('lastKnownLocation'+ahw.lastKnownLocationId +'->'+ ahc.Last_known_location_Lookup__c );
                ahc.currentLocationId__c = ahw.currentLocationId;
                ahc.current_Location__c = ahw.currentLocationId;
                ahc.RecordTypeId = rectypeid;
                ahc.Start_Time__c = ahw.startTime;
                ahc.End_Time__c =ahw.endTime;
                ahc.Location__c = ahw.location;
                ahc.Facility_Location__c = ahw.facilityLocation;
                if(ConsiderForDwell == true && ahc.location__c == 'In Transit') {
                    ahc.Consider_for_Dwell__c = true;
                }
                else if(ahc.location__c != 'In Transit'){
                    ahc.Consider_for_Dwell__c = false;
                    ConsiderForDwell = false;
                    if((Knownlocation.End_Time__c == null & ahc.location__c != 'In Transit')||( knownlocation.End_Time__c < ahc.End_Time__c &ahc.location__c != 'In Transit'))
                        knownlocation = ahc;
                }
                //system.debug(Knownlocation.location__c);
                //system.debug(ahc.location__c);
                ahc.Still_in_this_Location__c = (i == 0) ? true : false;
                //system.debug(lastKnownLocation);
                //system.debug(lastKnownId);
                if(ahc.Last_Known_Location_Lookup__c == null && lastKnownLocation != null &&
                   (ahc.Last_Known_Location__c == null || ahc.Last_Known_Location__c == lastKnownLocation)
                   && ahc.Start_Time__c >= lastKnownTime) {
                       ahc.Last_Known_Location__c= lastKnownLocation;
                       ahc.Last_Known_Location_Lookup__c = lastKnownId;
                   }
                // ahc.Api_Response__c = ahw.latestAPIRespId;
                ahc.Latitude__c = ahw.latitude != null ? decimal.valueOf(ahw.latitude) : null;
                if(ahc.latitude__c !=null)
                    locationcheck=true;
                ahc.Current_Location_Address__c = ahw.currLocationAddress;
                ahc.Altitude__c = ahw.altitude;
                List<String> apiRespUpdateList = new List<String>();
                for(RedesignNL_getAssetHistory.locationWrapper lwc : ahw.locationList) {
                    if(String.isNotBlank(lwc.locationId) && !apiRespUpdateList.contains(lwc.locationId))
                        apiRespUpdateList.add(lwc.locationId);
                }
                if(apiRespUpdateList.size()>0)
                    apiResponseUpdateMap.put(i, apiRespUpdateList);
                ahc.Message_Type__c = ahw.messageType;
                ahc.Latest_API_Response_Child__c=ahw.latestAPIRespId;
                ahc.Battery_Voltage__c =  ahw.battery != null ? Decimal.valueOf(ahw.battery) : null;
                ahc.Type_Of_Movement__c = ahw.typeOfMovement;
                ahc.PowerUptime__c =  ahw.PowerUptime != null? decimal.valueOf(ahw.powerUpTime):null;              
                ahc.Longitude__c = ahw.longitude !=null ? decimal.valueOf(ahw.longitude):null;
                ahc.rsrq__c = (String.isNotBlank(ahw.rsrq) && ahw.rsrq != 'null') ? Decimal.valueOf(ahw.rsrq) : null;
                ahc.Cellular_Signal__c = ahw.cellularSignal != null ? ahw.cellularSignal : null;
                ahc.Device_Status_Time__c=ahw.Devicetime != null ? ahw.Devicetime : null;
                ahc.estBattPct__c=(String.isNotBlank(ahw.estBattPct) && ahw.estBattPct != 'null') ? Decimal.valueOf(ahw.estBattPct.substringBefore('%')) : null;
                ahc.Est_Remaining_Battery__c = (String.isNotBlank(ahw.batteryPercent) && ahw.batteryPercent != 'null') ? Decimal.valueOf(ahw.batteryPercent.substringBefore('%')) : null;
                ahc.rsrp__c = (String.isNotBlank(ahw.rsrp) && ahw.rsrp != 'null') ? Decimal.valueOf(ahw.rsrp) : null;
                ahc.rssi__c = (String.isNotBlank(ahw.rssi) && ahw.rssi != 'null') ? Decimal.valueOf(ahw.rssi) : null;
                ahc.Accuracy_meters__c = ahw.accuracy != null? ahw.accuracy:null;
                if(ahw.powerResetOccurred == true){
                    ahc.Power_Reset_Occurred__c = true;
                }else if(ahw.powerResetOccurred == false){
                    ahc.Power_Reset_Occurred__c = false;
                }
                ahc.Power_Reset_Time__c = ahw.powerResetTime;
                ahcListMap.put(i, ahc);
                i++;
            }
            
            if(ahcListMap.values().size()>0 && locationcheck == true) {
                insert ahcListMap.values();
                if(Knownlocation.Location__c != null){
                    updateOldDwellRecords(ast.Id, knownlocation);
                }
                Map<Id,API_Response_Childs__c> updateARCMap = new Map<Id,API_Response_Childs__c>();
                for(Integer key : ahcListMap.keySet()) {
                    Id temporaryAHCRecId = ahcListMap.get(key).Id;
                    List<String> apiRespUpdateList = apiResponseUpdateMap.get(key);
                    if(apiRespUpdateList != null) {
                        for(String arcId : apiRespUpdateList) {
                            API_Response_Childs__c arc = new API_Response_Childs__c(Id = arcId);
                            arc.Asset_History__c = temporaryAHCRecId;
                            if(!updateARCMap.containskey(arcId))
                                updateARCMap.put(arcId,arc);
                        }
                    }
                }
                if(updateARCMap.values().size() > 0)
                    update updateARCMap.values();
            }
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'createAHCRecords', 'Exception', ast.device_Id__c, null, true);
            //            RedesignNL_Helper.sendemail('RedesignNL_CreateAssetHistoryBatch '+ '\n' + 'Error occured while insert the AHC List -  '+ '\n' + 'error msg'+e.getMessage()+'-Line-'+e.getLineNumber()+'-Type-'+ e.getTypeName());
            failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - createAHCRecords. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            
        }
        assetLastLocationMap.put(ast.Id,currentLoc);
        return ahcListMap.values();
    }
    public static void updateOldDwellRecords(String ast,  Asset_History_Custom__c latestAHC) {
        List<Asset_History_Custom__c> oldDwellRecords = [SELECT Id, Asset__c, Location__c, In_Transit_Ever_Check__c,Still_in_transit__c,Consider_for_Dwell__c
                                                         FROM Asset_History_Custom__c
                                                         WHERE  Asset__c = :ast AND End_time__c <=: latestAHC.Start_Time__c
                                                         AND ((Consider_for_Dwell__c = true AND RecordType.DeveloperName = 'Location') OR (Still_in_transit__c = true AND RecordType.DeveloperName = 'Dwell_Time'))
                                                         ORDER BY Asset__c, Start_Time__c];
        try{// Murali: Added try block here
            for (Asset_History_Custom__c dwellRecord : oldDwellRecords) {
                if(latestAHC.Consider_for_Dwell__c == false){
                    dwellRecord.Consider_for_Dwell__c = false;
                    dwellRecord.Still_in_transit__c = false; 
                }
            }
            
            if (!oldDwellRecords.isEmpty()) {
                update oldDwellRecords;
            }
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'updateOldDwellRecords', 'Exception', ast, null, true);
            //            RedesignNL_Helper.sendemail('RedesignNL_CreateAssetHistoryBatch '+ '\n' + 'Error occured while insert the AHC List -  '+ '\n' + 'error msg'+e.getMessage()+'-Line-'+e.getLineNumber()+'-Type-'+ e.getTypeName());
            failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - createAHCRecords. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            
        }
    }
    
    
    
    Public Static void updateArcStatus(DateTime endTime, String astId){
        List<Api_response_childs__c> arcToUpdate = New List<Api_response_childs__c>();
        For(Api_response_childs__c arc : [SELECT id, status__c 
                                          From Api_response_childs__c 
                                          WHERE createdDate <=: endTime 
                                          AND asset__c =:astId 
                                          AND status__c = 'New' 
                                          AND recordType.developerName = 'Location']){
                                              arc.status__c = 'Processed';
                                              arcToUpdate.add(arc);
                                          }
        try{//Murali: Added try catch here
            update arcToUpdate;
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'updateArcStatus', 'Exception', astId, null, true);
            //            RedesignNL_Helper.sendemail('RedesignNL_CreateAssetHistoryBatch '+ '\n' + 'Error occured while insert the AHC List -  '+ '\n' + 'error msg'+e.getMessage()+'-Line-'+e.getLineNumber()+'-Type-'+ e.getTypeName());
            failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - createAHCRecords. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    public static Asset updateLastConnectedMapFields(Asset ast) {
        try{
            if(ast.Last_Connected__c != null){
                Datetime now = ast.Last_Connected__c;
                Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
                ast.Last_Connected_Map__c = now.addSeconds(offset/1000);    
            }
            if(ast.Date_Shipped__c!= null){
                Datetime now = ast.Date_Shipped__c;
                Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
                ast.Last_Scan_Map__c = now.addSeconds(offset/1000);    
            }
            return ast;
        }catch(exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_CreateAssetHistoryBatch', 'updateLastConnectedMapFields', 'Exception', ast.Id, null, true);
        }
        return null;
    }
}