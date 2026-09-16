/*
* Class Name: RedesignNL_Controller
* Created By: Jayesh Khattar
* Description: This class is used to process request recieved from Nimbelink and create API Response and API Response Childs
* Modified Date  Modified By  		Last Change
* Jan 18,2024    Murali Krishna    	Changed the Status method which has String variable which return the status of the TS on Line no.171
* Jan 22,2024    Murali Krishna    	Revoked the changes in the Status method 
* Feb 13, 2024   Sandeep 		   	ADO-329 Handle duplicate record creation 
* Feb 17, 2024   Jayesh				ADO - 358 Sorting account by CreatedDate desc Adding (order by createddate asc limit 1) on line 630
* Feb 19, 2024   Sandeep            Added try catch 163, 334
*/  

@RestResource(urlMapping='/Apiresponse/*')
global with sharing class RedesignNL_Controller {
    static Api_Response__c resp;
    
    global static Asset ast;
    //global static Asset_Summary__c AssetSummary;
    global static Map<String, RecordType> apiRespChildRecTMap = new Map<String, RecordType>();
    global static Datetime currentDateTime; 
    global static Decimal poweruptime;
    global static String locationTs;
    global static Redesign_NL__mdt RedesignMetadata = RedesignNL_Helper.getRedesignMetadata('Default');
    global static list<API_Response_Childs__c> failARCList = new list<API_Response_Childs__c>();
    
    @HttpPost
    global static string parseNimbeLinkResponse() {
        String requestBody = RestContext.request.requestBody.toString();
        return parseRequestBody(requestBody, null, false);
    }
    
    public static String parseRequestBody(String requestBody, API_Response__c ar, Boolean fromBatch) {
        String deviceId;
        currentDateTime = System.now().addDays(1);
        List<API_Response_Childs__c> locApiResp;
        List<API_Response_Childs__c> disArclist;
        List<API_Response_Childs__c> tempApiResp;
        List<API_Response_Childs__c> eventApiResp;
        API_Response_Childs__c dvcStatusApiResp;
        Map<string,string> devicecheck;
        
        powerUpTime =null;
        locationTs =null;
        
        datetime BefAssetProcDttime = system.now();
        //Rejected_API_Response__c rejectedApiResp = new Rejected_API_Response__c();
        if(fromBatch) {
            resp = ar;
        }
        else {
            resp = new Api_Response__c(Incoming_Messsage__c = requestBody, 
                                       ResEnteringDttime__c = system.now(), 
                                       ResEnteringTime__c = (system.now().getTime()/1000),
                                       Is_Nimbelink_Asset__c = true,
                                       Status__c = 'NEW');
        }
        try {
            if(requestBody != null){
                List<Object> templist  = new List<Object>();
                List<Object> eventlist = new List<Object>();
                List<Object> dvcstatus = new List<Object>();
                List<Object> loclist   = new List<Object>();
                List<Object> distlist   = new List<Object>();
                
                Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
                                
                if(lst_JsonParse.containskey('message')){
                    Map<String, Object> mapDetails = (Map<String, Object>) lst_JsonParse.get('message');
                    Map<String, Object> MessageID = new Map<String, Object>();
                    if (mapDetails.containsKey('messageId')) {
                        MessageID.put('messageId', mapDetails.get('messageId'));
                        System.debug('MessageID: ' + MessageID);
                    }
                    if(mapdetails.containskey('data')){
                        String data = (String) mapdetails.get('data');    
                        
                        if(data != null){
                            String dataResponse = EncodingUtil.base64Decode(data).toString();
                            
                            if(dataResponse != null){
                                Map<String, Object> parse_DataResp = (Map<String, Object>)Json.deserializeUntyped(dataResponse);    
                                
                                if(parse_DataResp.containskey('records')){
                                    
                                    Map<String,Object> respMap = new Map<String, Object>();
                                    for(object obj : (list<Object>) parse_DataResp.get('records')){
                                        respMap.putAll((Map<String, Object>)obj);   
                                    }
                                    
                                    
                                    Map<String, Object> dataMap = new  Map<String, Object>();
                                    if(respMap.containskey('data')){
                                        dataMap = (Map<String, Object>)respMap.get('data');    
                                    }
                                    
                                    // creating event list
                                    if(datamap.containskey('events')){
                                        eventlist = (list<Object>)datamap.get('events');
                                    }
                                    
                                    if(dataMap.containskey('deviceStatus')){
                                        dvcstatus = (list<Object>)dataMap.get('deviceStatus');
                                    }
                                    System.debug('dvcstatus--'+dvcstatus);
                                    
                                    Map<String, Object> baseMap = new Map<String, Object>();
                                    if(respMap.containskey('base')){
                                        baseMap = (Map<String, Object>)respMap.get('base'); 
                                         System.debug('baseMap--'+baseMap);
                                        deviceId = String.valueOf(baseMap.get('id'));
                                         System.debug('deviceId--'+deviceId);
                                    }
                                    
                                    if(datamap.containskey('loc')){
                                        loclist = (list<Object>)datamap.get('loc');
                                    }
                                    if(datamap.containskey('dist')){
                                        distlist = (list<Object>)datamap.get('dist');
                                    }
                                    if(distlist!=null && distlist.size()>0){
                                        disArclist = createDistRecords(distlist);
                                    }
                                    if(datamap.containskey('temp')){
                                        templist = (list<Object>)datamap.get('temp');
                                    }
                                    DateTime now = System.now();
                                    
                                    //Chandru - combine dev with loc
                                    if ((dvcstatus != null && dvcstatus.size() > 0) || (loclist != null && loclist.size() > 0)) {
                                        locApiResp = createLocAndDevStsRecords(loclist, dvcstatus);
                                    }
                                    
                                    //Set address of location records with In Transit
                                    if(locApiResp != null && locApiResp.size() > 0)
                                        createGoogleAPIRecords(locApiResp, deviceId);                        
                                    //get Asset and Asset Summary for the device Id
                                    getAssetSummary(deviceId); 
                                    //List of API Response Child for Temperature records
                                    if(templist != null && templist.size() > 0) {
                                        tempApiResp = createTempRecords(templist);
                                    }
                                    //List of API Response Child for Event records  
                                    if(eventlist != null && eventlist.size() > 0) {                             
                                        eventApiResp = createEventRecords(eventlist);
                                    }
                                    if(!fromBatch) {
                                        // reparing response records
                                        resp.data__c      = String.valueof(dataMap);
                                        resp.base__c      = String.valueof(baseMap);
                                        resp.Device_Id__c = deviceId;
                                        resp.Asset__c = ast.id;
                                        resp.device_status__c = String.valueof(dvcstatus);
                                         resp.accel__c     = String.valueof(datamap.get('accel'));
                                        resp.info__c      = String.valueof(datamap.get('info'));
                                        resp.events__c    = String.valueof(datamap.get('events'));
                                        resp.Loc__c       = String.valueof(datamap.get('loc'));
                                        resp.Temp__c      = String.valueof(datamap.get('temp'));
                                        resp.dist__c      = String.valueof(datamap.get('dist'));
                                        resp.Message_ID__c = String.valueOf(MessageID.get('messageId'));
                                        resp.Location_TimeStamp__c = locationTs !=null ? locationTs : null;
                                        resp.ResEnteringDttime__c = system.now();
                                        
                                    }
                                    resp.Redesigned_Processed__c = true;
                                    if(!ast.isNew_Asset__c){
                                    resp.Status__c= resp.Status__c.equalsIgnoreCase('PROCESSED') ? resp.Status__c : 'New'; 
                                    }else{
                                        resp.Status__c = 'Pending';
                                    }
                                    resp.Asset__c = ast.Id;
                                }   
                            }
                        }
                    }  
                }
            }
            try{
                upsert resp; 
            }catch (DmlException er) {
                RedesignNL_CaptureErrors.createErrorLogs(er, 'RedesignNL_Controller', 'parseRequestBody', 'API Error', deviceId, requestBody, false);
            }
            
            Resp = [Select Id, Name, Status__c from API_Response__c where Id =: resp.Id];
            List<String> ExternalAHCInLoop = new List<String>();
            Boolean DeviceStCheck = False;
            API_Response_Childs__c deviceStArc;
            if(locApiResp != null) {
                Integer j = 0;
                for(API_Response_Childs__c arc : locApiResp) {
                    arc.API_Response__c = resp.Id;
                    arc.API_Response_ID__c = resp.Id;
                    arc.Asset__c = ast.id;
                    arc.Name = resp.Name + '-' + RedesignNL_Helper.ArcLocationRecordtype;
                    arc.Asset__c = ast.id;
                    if(arc.Status__c != 'Google Api Error'){
                        arc.Status__c = setARCStatus(arc, resp);
                    }
                    if(arc.Status__c == 'New' && arc.Timestamp_Date_Time_Device_Status__c != null){
                        DeviceStCheck = True;
                    }
                    if(DeviceStCheck == False && arc.Status__c == 'BackdatedTS' && arc.Timestamp_Date_Time_Device_Status__c != null && ((ast.Last_connected2__c != null && arc.Timestamp_Date_Time_Device_Status__c > ast.Last_connected2__c) || String.valueof(arc.Timestamp_Device_Status__c).startsWith('1104'))){
                        deviceStArc = createDevStsRecords(arc);
                    }
                    arc.ARC_External_Id__c = arc.Asset__c + arc.ARC_External_Id__c;
                    if(ExternalAHCInLoop.contains(arc.ARC_External_Id__c)){
                        arc.ARC_External_Id__c += '~Duplicate' + j + resp.Id;
                        arc.Status__c = 'Duplicate';
                    }else{
                        ExternalAHCInLoop.add(arc.ARC_External_Id__c);
                    }
                    j++;
                }
                //insert locApiResp;    
                // ADO# 329: Sandeep ====================================================================================================
                try {
                    if(deviceStArc != null){
                        insert deviceStArc;
                    }
                    insert locApiResp;
                } catch (DmlException e) {
                    system.debug(e);
                    API_Response_Childs__c deviceArc = New API_Response_Childs__c();
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        system.debug(e.getDmlMessage(i));
                        if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id') || Test.IsRunningTest()) {
                            API_Response_Childs__c failedRecord = locApiResp[e.getDmlIndex(i)];
                            failedRecord.Status__c = 'Duplicate';
                            failedRecord.ARC_External_Id__c += '~Duplicate'+ system.now()+integer.valueof(Math.random() * 999);
                            system.debug(failedRecord.ARC_External_Id__c);
                            failARCList.add(failedRecord);
                            if(failedRecord != null && failedRecord.Timestamp_Device_Status__c != null){
                                deviceArc = createDevStsRecords(failedRecord);
                            }
                        }
                    }
                    try {
                        upsert locApiResp;
                        if(deviceArc != null && deviceArc.Timestamp_Device_Status__c != null){
                            
                            try {
                                insert deviceArc;
                            }catch (DmlException dev) {
                                deviceArc.Status__c = 'Duplicate';
                                deviceArc.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                                upsert deviceArc;                            
                                
                                
                            }
                        }
                    } catch (DmlException ex) {
                        RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                    }
                }//=========================================================================================================
                /*Schema.SObjectField ftoken = Account.Fields.Account_Unique_Number__c;
                Database.UpsertResult[] srList = Database.upsert(acclist,ftoken,false);
                for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                // Operation was successful
                }
                else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                System.debug('fields that affected this error: ' + err.getFields());
                
                }
                }
                }*/
            }
            
            if(tempApiResp != null) {
                integer k = 0;
                for(API_Response_Childs__c arc : tempApiResp) {
                    arc.API_Response__c = resp.Id;
                    arc.Asset__c = ast.id;
                    arc.Name = resp.Name + '-' + RedesignNL_Helper.ArcTemperatureRecordtype;
                    arc.Status__c = setARCStatus(arc, resp);
                    system.debug(arc.status__c);
                    arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + 'Temp';
                    if(ExternalAHCInLoop.contains(arc.ARC_External_Id__c)){
                        arc.ARC_External_Id__c += '~Duplicate' + k + resp.Id;
                        arc.Status__c = 'Duplicate';
                    }else{
                        ExternalAHCInLoop.add(arc.ARC_External_Id__c);
                    }
                    k++;
                }
                //insert tempApiResp;
                //ADO# 329: Sandeep ====================================================================================================
                try {
                    insert tempApiResp;
                } catch (DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
                            API_Response_Childs__c failedRecord = tempApiResp[e.getDmlIndex(i)];
                            failedRecord.Status__c = 'Duplicate';
                            failedRecord.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                            try {
                                insert failedRecord;
                            } catch (DmlException ex) {
                                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                            }
                        }
                    }
                }//=========================================================================================================
            }
            
            if(eventApiResp != null && ast.Capture_Movement_Event__c == true) {
                //Murali - Set Lookup values on API Response Child for API Response and Asset Summary
                integer l =0;
                for(API_Response_Childs__c arc : eventApiResp) {
                    arc.API_Response__c = resp.Id;
                    arc.Asset__c = ast.id;
                    arc.Name = resp.Name + '-' + RedesignNL_Helper.ArcEventsRecordtype;
                    arc.Status__c = setARCStatus(arc, resp);
                    arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + 'Event';
                    if(ExternalAHCInLoop.contains(arc.ARC_External_Id__c)){
                        arc.ARC_External_Id__c += '~Duplicate' + l + resp.Id;
                        arc.Status__c = 'Duplicate';
                    }else{
                        ExternalAHCInLoop.add(arc.ARC_External_Id__c);
                    }
                    l++;
                }
                //insert eventApiResp;
                //ADO# 329: Sandeep ====================================================================================================
                try {
                    insert eventApiResp;
                } catch (DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
                            API_Response_Childs__c failedRecord = eventApiResp[e.getDmlIndex(i)];
                            failedRecord.Status__c = 'Duplicate';
                            failedRecord.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                            try {
                                insert failedRecord;
                            } catch (DmlException ex) {
                                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                            }
                        }
                    }
                }//=======================================================================================================
            }
            
            if(disArclist != null ) {
                integer d = 0;
                for(API_Response_Childs__c arc : disArclist) {
                    arc.API_Response__c = resp.Id;
                    arc.Asset__c = ast.id;
                    arc.Name = resp.Name + '-' + RedesignNL_Helper.ArcDistanceRecordtype;
                    arc.Status__c = setARCStatus(arc, resp);
                    arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + '~' + 'Distance';
                    if(ExternalAHCInLoop.contains(arc.ARC_External_Id__c)){
                        arc.ARC_External_Id__c += '~Duplicate' + d + resp.Id;
                        arc.Status__c = 'Duplicate';
                    }else{
                        ExternalAHCInLoop.add(arc.ARC_External_Id__c); 
                    }
                    d++;
                }
                try {
                    insert disArclist;
                } catch (DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
                            API_Response_Childs__c failedRecord = disArclist[e.getDmlIndex(i)];
                            failedRecord.Status__c = 'Duplicate';
                            failedRecord.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                            try {
                                insert failedRecord;
                            } catch (DmlException ex) {
                                RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                            }
                        }
                    }
                }//========================================================================================================
            }
            
            return 'sucessfull';
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'parseRequestBody', 'API Error', deviceId, requestBody, true);
            //Added for 320
            if(resp != null) {
                resp.Status__c = 'Pending';
                try{
                    update resp; 
                }catch (DmlException er) {
                    RedesignNL_CaptureErrors.createErrorLogs(er, 'RedesignNL_Controller', 'parseRequestBody', 'Exception', deviceId, null, false);
                }
                
            }
        }
        return null;
    }
        
    public static void getAssetSummary(String deviceId) {
        List<Asset> assetLst = [Select Id, Name,AccountId,Capture_Movement_Event__c,Capture_Distance_Records__c , Dormant_Days__c,Last_Connected__c,Last_connected2__c, device_id__c,isNew_Asset__c  from Asset where device_id__c =: deviceId];
        if(assetLst.size()>0) {
            ast = assetLst[0];
        }
        else {
            List<Account> accList = [Select Id, Name from Account where Name = 'Testing'];
            if(accList.size() > 0) {
                ast = new Asset();
                ast.AccountId = accList[0].Id;
                ast.Device_Id__c = deviceId;
                ast.Name = deviceId;
                insert ast;
            }
        }
    }
    
    public static List<API_Response_Childs__c> createDistRecords(list<object> distlist){
        List<API_Response_Childs__c> distArcList = new List<API_Response_Childs__c>();
        for(object dist : distlist){
            Map<string,object> dsitRecMap = (Map<string,object>)dist;
            if(dsitRecMap.containskey('m')){
               Double dis = (Double)dsitRecMap.get('m');
                if(dis!=null && dis > 0){
                    API_Response_Childs__c distarc = new API_Response_Childs__c();
                    distarc.RecordtypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcDistanceRecordtype);
                    distarc.async__c = dsitRecMap.containsKey('async') ? (boolean)dsitRecMap.get('async') :false;
                    //distarc.Distance_Timestamp__c = dsitRecMap.containsKey('ts') ? (long)dsitRecMap.get('ts') :null;
                    //distarc.Distance_Datetime__c = dsitRecMap.containsKey('ts') ? TimestampConverter.convertUnixTimestampToGMT((Long)dsitRecMap.get('ts')) : null;
                    distarc.timestamp__c = dsitRecMap.containsKey('ts') ? (long)dsitRecMap.get('ts') :null;
                    distarc.timestamp_Datetime__c = dsitRecMap.containsKey('ts') ? TimestampConverter.convertUnixTimestampToGMT((Long)dsitRecMap.get('ts')) : null;
                    distarc.Distance__c = String.valueof((decimal)dsitRecMap.get('m'));
                    integer disLvl = dsitRecMap.containsKey('lvl') ?  (integer)dsitRecMap.get('lvl') : null;
                    if(disLvl == 0){
                        distarc.Distance_Level__c = 'Unknown';
                    }else if(disLvl == 2){
                        distarc.Distance_Level__c = 'Low';
                    } else if(disLvl == 4){
                        distarc.Distance_Level__c = 'High';
                    }
                    distArcList.add(distarc);
                }
            }
            
        }
        return distArcList;
    }
    
    public static list<API_Response_Childs__c> createTempRecords(list<object> Templist) {
        List<API_Response_Childs__c> TempApiRespList = new List<API_Response_Childs__c>();
        for(Object obj : Templist) {
            Map<String, Object> tempMap = (Map<String,Object>)obj;
            API_Response_Childs__c tempApiResp = new API_Response_Childs__c();
            tempApiResp.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcTemperatureRecordtype);
            tempApiResp.Temperature__c = tempMap.containskey('c') ? 1.8 * (decimal)tempMap.get('c') + 32 : null;
            tempApiResp.Relative_Humidity__c = tempMap.containskey('rh') ?  (decimal)tempMap.get('rh') : null;
            tempApiResp.Timestamp__c = (Long)tempMap.get('ts');
            tempApiResp.Timestamp_DateTime__c = TimestampConverter.convertUnixTimestampToGMT((Long)tempMap.get('ts'));
            TempApiRespList.add(tempApiResp);
        }
        return TempApiRespList;        
    }
    
    //Chandru - combine dev with loc
    public static API_Response_Childs__c createDevStsRecords(API_Response_Childs__c arc) {
        API_Response_Childs__c deviceArc = new API_Response_Childs__c();
        deviceArc.Battery__c = arc.Battery__c;
        deviceArc.EstBattPct__c = arc.EstBattPct__c;
        deviceArc.Network__c = arc.Network__c;
        deviceArc.PowerUptime__c = arc.PowerUptime__c;
        deviceArc.rsrp__c = arc.rsrp__c;
        deviceArc.rsrq__c = arc.rsrq__c;
        deviceArc.rssi__c = arc.rssi__c;
        deviceArc.Signal__c = arc.Signal__c;
        deviceArc.Timestamp__c=arc.Timestamp_Device_Status__c;
        deviceArc.Timestamp_DateTime__c=arc.Timestamp_Date_Time_Device_Status__c;
        deviceArc.Timestamp_Device_Status__c = arc.Timestamp_Device_Status__c;
        deviceArc.Timestamp_Date_Time_Device_Status__c = arc.Timestamp_Date_Time_Device_Status__c;
        deviceArc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp_Device_Status__c + '~DS';
        deviceArc.API_Response__c = resp.Id;
        deviceArc.Asset__c = ast.id;
        deviceArc.Name = resp.Name + '-' + RedesignNL_Helper.ArcLocationRecordtype;
        deviceArc.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
        deviceArc.Status__c = setARCStatus(deviceArc, resp);
        deviceArc.ARC_External_Id__c = '~' + deviceArc.Timestamp__c + '~dev';  
              return deviceARC;
    }
    
    public static List<API_Response_Childs__c> createLocAndDevStsRecords(List<Object> loclist,List<Object> dvsStatuslist) {
        //Storing the dev data 
        Map<String, Object> dvcMap;
        if(dvsStatuslist.size() > 0){
            dvcMap = (Map<String,Object>)dvsStatuslist[0];
        }
        
        List<API_Response_Childs__c> locApiRespLst = new List<API_Response_Childs__c>();
        if(loclist.size() > 0) {
            for(Object obj : locList) {
                Map<String, Object> locMap = (Map<String,Object>)obj;
                if((Decimal)locMap.get('haccRank') == 0) {
                    API_Response_Childs__c locApiResp = new API_Response_Childs__c();
                    locApiResp.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
                    locApiResp.haccRank__c = (Decimal)locMap.get('haccRank') != null?(Decimal)locMap.get('haccRank') : null;
                    locApiResp.Accuracy_meters__c= (decimal)locmap.get('hacc') != null ? (decimal)locmap.get('hacc') : null;
                    locApiResp.Timestamp_DateTime__c = TimestampConverter.convertUnixTimestampToGMT((Long)locMap.get('ts'))!= null ? TimestampConverter.convertUnixTimestampToGMT((Long)locMap.get('ts')) : null;
                    locApiResp.Latitude__c = String.valueof(locmap.get('lat'))!= null ? String.valueof(locmap.get('lat')) : null;//((Decimal)locMap.get('lat')).left(7);//.setScale(4);
                    locApiResp.Longitude__c = String.valueof(locmap.get('lon'))!= null ? String.valueof(locmap.get('lon')) : null;//((Decimal)locMap.get('lon')).left(7);//.setScale(4); 
                    locApiResp.Timestamp__c = (long)locMap.get('ts')!= null ? (long)locMap.get('ts') : null;
                    locApiResp.Alt__c = (Decimal)locMap.get('alt')!= null ?  (Decimal)locMap.get('alt') : null;
                    locApiResp.ARC_External_Id__c = '~' + locApiResp.Timestamp__c + '~Location';
                    // Check if there is a second string to add
                    if (Locationts != null) {
                        // Add ', ' and the second string to Locationts
                        Locationts += ', ' + String.valueOf(locApiResp.Timestamp__c);
                    }else{
                        Locationts = String.valueOf(locApiResp.Timestamp__c);                        
                    }
                    
                    if(locMap.containskey('src')) {
                        if((string)locMap.get('src') == 'w'){
                            locApiResp.Message_Type__c = 'wifi';
                        }else if((string)locMap.get('src') == 'c'){
                            locApiResp.Message_Type__c = 'cellular';
                        }else if((string)locMap.get('src') == 'g'){
                            locApiResp.Message_Type__c = 'gps';  
                        }   
                    }
                    //If dev data present, filling the dev data in loc arc
                    if(dvcMap!=null){
                        locApiResp.Battery__c = (Decimal)dvcMap.get('battery') != null ? (Decimal)dvcMap.get('battery'):null;
                        locApiResp.EstBattPct__c = (Decimal)dvcMap.get('estBattPct');
                        locApiResp.Network__c = (String)dvcMap.get('network');
                        locApiResp.PowerUptime__c = (Decimal)dvcMap.get('powerUptime');
                        locApiResp.rsrp__c = (Decimal)dvcMap.get('rsrp');
                        locApiResp.rsrq__c = (Decimal)dvcMap.get('rsrq');
                        locApiResp.rssi__c = (Decimal)dvcMap.get('rssi');
                        locApiResp.Signal__c = (Decimal)dvcMap.get('signal');
                        locApiResp.Timestamp_Device_Status__c = (long)dvcMap.get('ts');
                        locApiResp.Timestamp_Date_Time_Device_Status__c = TimestampConverter.convertUnixTimestampToGMT((Long)dvcMap.get('ts'));
                        
                        powerUpTime = locApiResp.PowerUptime__c;
                        
                        locApiRespLst.add(locApiResp);
                    }else{
                        locApiRespLst.add(locApiResp);
                    }
                }
            }
        }
        else{
            if(dvcMap!=null) {
                API_Response_Childs__c locApiResp = new API_Response_Childs__c();
                locApiResp.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
                locApiResp.Battery__c = (Decimal)dvcMap.get('battery');
                locApiResp.EstBattPct__c = (Decimal)dvcMap.get('estBattPct');
                locApiResp.Network__c = (String)dvcMap.get('network');
                locApiResp.PowerUptime__c = (Decimal)dvcMap.get('powerUptime');
                locApiResp.rsrp__c = (Decimal)dvcMap.get('rsrp');
                locApiResp.rsrq__c = (Decimal)dvcMap.get('rsrq');
                locApiResp.rssi__c = (Decimal)dvcMap.get('rssi');
                locApiResp.Signal__c = (Decimal)dvcMap.get('signal');
                locApiResp.Timestamp__c = (long)dvcMap.get('ts')!= null ? (long)dvcMap.get('ts') : null;
                locApiResp.Timestamp_DateTime__c = TimestampConverter.convertUnixTimestampToGMT((Long)dvcMap.get('ts'))!= null ? TimestampConverter.convertUnixTimestampToGMT((Long)dvcMap.get('ts')) : null;
                locApiResp.Timestamp_Device_Status__c = (long)dvcMap.get('ts');
                locApiResp.Timestamp_Date_Time_Device_Status__c = TimestampConverter.convertUnixTimestampToGMT((Long)dvcMap.get('ts'));
                locApiResp.ARC_External_Id__c = '~' + locApiResp.Timestamp__c + '~dev';
                
                powerUpTime = locApiResp.PowerUptime__c;
                
                locApiRespLst.add(locApiResp);
            }
        }
        return locApiRespLst;
    }
    Public static List<API_Response_Childs__c> createEventRecords(List<Object> eventlist) {
        List<API_Response_Childs__c> EventApiRespList = new List<API_Response_Childs__c>();
        for(Object obj : eventlist) {
            Map<String, Object> EventMap = (Map<String,Object>)obj;
            API_Response_Childs__c EventApiRespChild = new API_Response_Childs__c();
            EventApiRespChild.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcEventsRecordtype);
            EventApiRespChild.Event_Name__c = (String)EventMap.get('eventName');
            EventApiRespChild.Timestamp__c = (Decimal)EventMap.get('ts');
            EventApiRespChild.Timestamp_Datetime__c=TimestampConverter.convertUnixTimestampToGMT((Long)EventMap.get('ts'));
            EventApiRespList.add(EventApiRespChild);
        }
        
        return EventApiRespList;
    }
    
    public static void createGoogleAPIRecords(List<API_Response_Childs__c> locApiResp, String deviceId){
        if (!Test.isRunningTest() && Limits.getDmlStatements() > 0) {
            if (locApiResp != null) {
                for (API_Response_Childs__c loc : locApiResp) {
                    if (loc == null) continue;
                    loc.Location__c = 'In Transit';
                    loc.Current_Location_Address__c = 'Address Pending';
                    loc.Status__c = 'Google Api Error';
                }
            }
            return;
        }
        List<String> IncludeList = RedesignNL_Helper.getIncludeList();
        List<String> excludeList = RedesignNL_Helper.getexludeList();
        integer APIcount= 0;
        Map<integer,List<string>> ApidebugLogMap = New Map<integer,List<string>>();
        Map<id,Google_Api_Data__c> gadInsertMap = new Map<id,Google_Api_Data__c>();
        List<Google_API_Data__c> GADlistToInsert = new List<Google_API_Data__c>();
        Boolean accUniqId= False;
        List<Asset> assetLst = [Select Id, Name,AccountId, device_id__c,Account_Unique_Id__c,Account.Capture_Business_Name__c from Asset where device_id__c =: deviceId];
        String accountId;
        if(assetLst.size() > 0) {
            accountId = assetLst[0].AccountId;  
            accUniqId= assetLst[0].Account.Capture_Business_Name__c;
        }
        else {
            List<Account> accList = [Select Id, Name,Account_ID__c,Capture_Business_Name__c from Account where Name = 'Testing'];
            accountId = accList[0].Id;            
            accUniqId= accList[0].Capture_Business_Name__c;
        }
        
        Map<String,List<String>> latLonMap = new Map<String,List<String>>();   
        for(API_Response_Childs__c loc : locApiResp) {
            if(loc.haccRank__c == 0 && loc.Latitude__c != null && loc.Longitude__c != null) {
                Boolean isGeofenceFound = checkGeofence(accountId, loc);
                if(isGeofenceFound == false) { 
                    string latfull = loc.Latitude__c;
                    string lngfull = loc.Longitude__c;
                    String lat = loc.Latitude__c.left(7);
                    String lon = loc.Longitude__c.left(7);
                    if( lat !='0' && lon !='0'){
                        if(latLonMap == null || !latLonMap.containsKey(lat) || (latLonMap != null & latLonMap.containsKey(lat) & !latLonMap.get(lat).contains(lon))) {
                            List<Google_API_Data__c> GADlist = [select id,Current_City__c,Current_State__c,Current_Address__c,Current_country__c,Current_Street_Address__c,Business_Name__c,Business_Place_Id__c,Business_Location__Longitude__s,Business_Location__Latitude__s,Captured_Business_Name__c,Likely_Business_Name_Types__c,
                                                                Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                                where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lon+'%'  order by createddate desc limit 1];
                            system.debug('###--GADlist--'+ GADlist);
                            if(GADlist== null || (GADlist!=null && GADlist.isEmpty())){
                                Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=latfull, Longitude__c=lngfull);
                                if((RedesignMetadata.Capture_Business_Name__c == True && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True) || Test.isRunningTest() ){
                                    List<string> debuglogs=new List<string>();
                                    debuglogs = getBusinessName(deviceId, latfull, lngfull, gadRec, loc, IncludeList, excludeList);
                                    if(RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                        APIcount = APIcount+1;
                                        ApidebugLogMap.put(APIcount,debuglogs);
                                    }
                                    //getBusinessName(deviceId, latfull, lngfull, gadRec, loc, IncludeList, excludeList);
                                }
                                if (RedesignMetadata.Redesign_Api_Response_Toggle__c == true) {
                                    Http h = new Http();
                                    HttpRequest req = new HttpRequest();
                                    req.setTimeout(60000);
                                    req.setMethod('GET');
                                    req.setHeader('content-type','application/x-www-form-urlencoded');
                                    req.setHeader('Accept', 'application/json'); 
                                    string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+Decimal.valueOf(latfull)+'%20'+Decimal.valueOf(lngfull)+'&sensor=true';
                                    system.debug(endpt);    
                                    req.setEndpoint(endpt);
                                    HttpResponse res = h.send(req);
                                    if(res.getStatusCode() == 200){  
                                        //create Debug log to count google Address API  callouts
                                        if(RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                            List<String> apidebuglogs = new List<String>{ 'RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), String.valueof(Decimal.valueOf(res.getStatusCode())), res.getStatus(), deviceId, lat, lon, 'Address API callout count record','Count'};
                                            APIcount = APIcount+1;
                                            ApidebugLogMap.put(APIcount,apidebuglogs);
                                        }
                                        Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        system.debug(results1);
                                        List<Object> mapGADdetails = (List<Object>) results1.get('results');
                                        Integer i=0;
                                        Map<String,Object> addrvalMap = new map<String,Object>();
                                        Map<integer , Map<string,string>> addressMap = New Map<integer , Map<string,string>>(); //Integer,Actual Address  Map
                                        Map<integer , Map<string,string>> plusCodeAddressMap = New Map<integer , Map<string,string>>(); //Integer,PlusCode Address  Map
                                        for(object obj : mapGADdetails){
                                            Map<string,string> fullAdressMap = New Map<string,string>(); //Actual AddressMap
                                            Map<string,string> plusCodeFullAdressMap = New Map<string,string>(); //Pluscode AddressMap
                                            string streetAddress = '';
                                            addrvalMap = (Map<String,Object>)obj;
                                            List<Object> addressdetails = new List<Object>();
                                            if(addrvalMap.containskey('address_components')){
                                                addressdetails = (List<Object>) addrvalMap.get('address_components');    
                                            }  
                                            Map<String,Object> comGADmap = new map<String,Object>();
                                            //string types;
                                            //List<string> types = New List<String>();
                                            for(object obj1 : addressdetails){
                                                comGADmap = (Map<String,Object>)obj1;
                                                 List<string> types = New List<String>();
                                                
                                               if(comGADmap.containskey('types')){
                                                  // types = (List<string>) comGADmap.get('types');
                                                   for(object obj2 : (List<Object>) comGADmap.get('types') ){
                                                       if((string)obj2 != 'political'){
                                                           //types = (string)obj2;  
                                                           types.add((string)obj2);       
                                                       }
                                                   }    
                                                }
                                                system.debug('types for Address-'+types);
                                                if(comGADmap.containskey('short_name') || comGADmap.containskey('long_name')){
                                                    string value = null;
                                                    string shortName = (string)comGADmap.get('short_name'); 
                                                    string longName = (string)comGADmap.get('long_name'); 
                                                    if (shortName.length() > 0 && shortName != 'NULL' &&  shortName != 'null' && shortName != '' && shortName!=null) {
                                                        value = shortName;
                                                    }else if (longName.length() > 0 && longName != 'NULL' &&  longName != 'null' && longName != ''  && longName!=null) {
                                                        value = longName;
                                                    }
                                                    if(types.contains('street_number')){       
                                                        if(value != null && !value.contains('+')){
                                                            fullAdressMap.put('streetNumber',value);
                                                        }else if(value != null){
                                                            plusCodeFullAdressMap.put('streetNumber',value);
                                                        }
                                                    }
                                                    if(types.contains('route') ){
                                                         if(value != null && !value.contains('+')){
                                                            fullAdressMap.put('streetName',value);
                                                        }else if(value != null){
                                                            plusCodeFullAdressMap.put('streetName',value);
                                                        }
                                                    }
                                                    if(types.contains('locality')){
                                                        if(value != null && !value.contains('+')){
                                                            fullAdressMap.put('city',value);
                                                        }
                                                    }
                                                    if(types.contains('administrative_area_level_1')){
                                                         if(value != null && !value.contains('+')){
                                                             if(value.length()>2){
                                                                 string str = value.replace(' ', '_'); //replacing empty space with _ to get metadata
                                                                 Us_States__mdt  uss = Us_States__mdt.getInstance(str); //getting short name for us states
                                                                 if(uss!=null){
                                                                     fullAdressMap.put('state',uss.Short_Name__c);
                                                                 }else{
                                                                     fullAdressMap.put('state',value);
                                                                 }
                                                             }else{
                                                                  fullAdressMap.put('state',value);
                                                             }
                                                        }
                                                    }
                                                    
                                                    if(types.contains('postal_code')){
                                                         if(value != null && !value.contains('+')){
                                                            fullAdressMap.put('zipCode',value);
                                                        }
                                                    }
                                                    if(types.contains('country')){
                                                        if(value != null && !value.contains('+')){
                                                            if(value.length()>2){
                                                                 string str = value.replace(' ', '_'); //replacing empty space with _ to get metadata
                                                                 Us_States__mdt  uss = Us_States__mdt.getInstance(str); //getting short name for us states
                                                                 if(uss!=null){
                                                                     fullAdressMap.put('country',uss.Short_Name__c);
                                                                 }else{
                                                                     fullAdressMap.put('country',value);
                                                                 }
                                                            }else{
                                                                fullAdressMap.put('country',value);
                                                            }
                                                        }
                                                    }
                                                }//IF Contains Short Name
                                            } //For Address Details
                                            addressMap.put(i,fullAdressMap);
                                            plusCodeAddressMap.put(i,plusCodeFullAdressMap);
                                            i++;
                                        }
                                        Integer adDetailsMaxSize = 0;
                                        Map<String, String> mostDetailedAddress = null;
                                        
                                        // finding the most detailed address
                                        for (Integer key : addressMap.keySet()) {
                                            Map<String, String> adMap = addressMap.get(key);
                                            if (adMap.size() > adDetailsMaxSize) {
                                                adDetailsMaxSize = adMap.size();
                                                mostDetailedAddress = adMap;
                                            }
                                        }
                                        
                                        // Checking and updating the state if missing
                                        if (mostDetailedAddress != null) {
                                            List<String> addressFields = new List<String>{ 'streetNumber', 'streetName', 'city', 'state', 'zipCode', 'country' };
                                                // Iterate over the fields and fill missing values
                                                for (String field : addressFields) {
                                                    if (!mostDetailedAddress.containsKey(field) || String.isEmpty(mostDetailedAddress.get(field))) {
                                                        // Searching for the field in other addresses
                                                        for (Integer key : addressMap.keySet()) {
                                                            Map<String, String> adMap = addressMap.get(key);
                                                            if (adMap.containsKey(field) && !String.isEmpty(adMap.get(field))) {
                                                                mostDetailedAddress.put(field, adMap.get(field));
                                                                break;
                                                            }
                                                        }
                                                        
                                                        // If still missing, fallback to a +code or default value for street Address
                                                        if(field == 'streetNumber' || field == 'streetName'){
                                                            if (!mostDetailedAddress.containsKey(field) || String.isEmpty(mostDetailedAddress.get(field))) {
                                                                for (Integer key : plusCodeAddressMap.keySet()) {
                                                                    Map<String, String> adMap = plusCodeAddressMap.get(key);
                                                                    if (adMap.containsKey(field) && !String.isEmpty(adMap.get(field))) {
                                                                        mostDetailedAddress.put(field, adMap.get(field));
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                        }
                                        
                                        // Assigning values to fields
                                       if (mostDetailedAddress != null) {
                                           String fullAddress = '';
                                           
                                           //  address components with safe fallbacks
                                           String streetNumber = mostDetailedAddress.containsKey('streetNumber') ? mostDetailedAddress.get('streetNumber') : '';
                                           String streetName = mostDetailedAddress.containsKey('streetName') ? mostDetailedAddress.get('streetName') : '';
                                           String city = mostDetailedAddress.containsKey('city') ? mostDetailedAddress.get('city') : '';
                                           String state = mostDetailedAddress.containsKey('state') ? mostDetailedAddress.get('state') : '';
                                           String zipCode = mostDetailedAddress.containsKey('zipCode') ? mostDetailedAddress.get('zipCode') : '';
                                           String country = mostDetailedAddress.containsKey('country') ? mostDetailedAddress.get('country') : '';
                                           string streetAddress ='';
                                           string stateAndZip = '';
                                           if(!String.isEmpty(streetNumber) && !String.isEmpty(streetName)) {
                                               streetAddress = streetNumber+' '+streetName;
                                           }else{
                                               streetAddress = streetNumber!='' ? streetNumber : streetName;
                                           }
                                           if(!String.isEmpty(state) && !String.isEmpty(zipCode)) {
                                               stateAndZip = state+' '+zipCode;
                                           }else{
                                               stateAndZip = state!='' ? state : zipCode;
                                           }
                                         
                                           // Assign individual values to gadRec record
                                           gadRec.Current_Street_Address__c = streetAddress;
                                           gadRec.Current_City__c = city;
                                           gadRec.Current_State__c = state;
                                           gadRec.Current_Zip_Code__c = zipCode;
                                           gadRec.Current_Country__c = country;
                                           gadRec.Device_Id__c = deviceId;
                                           gadRec.Vendor__c = loc.Asset__r.Is_Loco_Asset__c ? 'Loco' : 'Airgain';
                                           
                                           List<String> addressParts = new List<String>();
                                            if (!String.isEmpty(streetAddress) && streetAddress!='')
                                               addressParts.add(streetAddress);
                                           
                                           if (!String.isEmpty(city) && city!='') 
                                               addressParts.add(city);
                                            if (!String.isEmpty(stateAndZip) && stateAndZip!='')
                                               addressParts.add(stateAndZip);
                                           if (!String.isEmpty(country) && country!='') 
                                               addressParts.add(country);
                                           
                                           fullAddress = String.join(addressParts, ', ');
                                           
                                           gadRec.Current_Address__c = fullAddress;
                                       }
    
                                        if(!String.isBlank(gadRec.Current_Address__c)){
                                            if(!GADlistToInsert.Contains(gadRec)){
                                                GADlistToInsert.add(gadRec); 
                                            }
                                            if(latLonMap.containsKey(lat)){
                                                if(!latLonMap.get(lat).contains(lon)){
                                                    latLonMap.get(lat).add(lon);
                                                } 
                                            }else{
                                                latLonMap.put(lat,new List<String> {lon});
                                            }  
                                            loc.Location__c = 'In Transit';
                                            loc.Current_Location_Address__c = gadRec.Current_Address__c;
                                            loc.Current_Street_Address__c  = gadRec.Current_Street_Address__c;
                                            loc.Current_City__c  = gadRec.Current_City__c;
                                            loc.Current_State__c  = gadRec.Current_State__c;
                                            loc.Current_Zipcode__c   = gadRec.Current_Zip_Code__c;
                                            loc.Current_Country__c =  gadRec.Current_Country__c ;
                                        }
                                        
                                        if(String.isBlank(gadRec.Current_Address__c)){
                                            loc.Location__c = 'In Transit';
                                            loc.Current_Location_Address__c = 'Address Pending';
                                            loc.Status__c = 'Google Api Error';
                                        }
                                        
                                    }
                                    else{
                                        try {
                                            RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), String.valueof(Decimal.valueOf(res.getStatusCode())), res.getStatus(), deviceId, lat, lon, 'Address Callout API Error log','Error');            
                                        }
                                        catch(Exception ex) {
                                            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);
                                        }
                                        loc.Location__c = 'In Transit';
                                        loc.Current_Location_Address__c = 'Address Pending';
                                        loc.Status__c = 'Google Api Error';
                                    }
                                }
                                else{
                                    try {
                                        RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', 'Redesign 3.0 Toggle False - But Address Pending', null, null, deviceId, lat, lon, 'No callout Error log', 'Error');
                                    }
                                    catch(Exception ex) {
                                        RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);                                       
                                    }
                                    loc.Location__c = 'In Transit';
                                    loc.Current_Location_Address__c = 'Address Pending';
                                    loc.Status__c = 'Google Api Error';
                                }
                                
                            }
                            else {
                                loc.Location__c = 'In Transit';
                                loc.Current_Location_Address__c = GADlist[0].Current_Address__c; 
                                loc.Current_Street_Address__c  = GADlist[0].Current_Street_Address__c;
                                loc.Current_City__c  = GADlist[0].Current_City__c;
                                loc.Current_State__c  = GADlist[0].Current_State__c;
                                loc.Current_Zipcode__c   = GADlist[0].Current_Zip_Code__c;
                                loc.Current_Country__c   = GADlist[0].current_country__c;
                                String BusinessName = null;
                                if(GADlist[0].Business_Name__c != null){
                                    loc.Business_Name__c = GADlist[0].Business_Name__c;
                                    loc.Business_Location__Latitude__s =  GADlist[0].Business_Location__Latitude__s;
                                    loc.Business_Location__Longitude__s = GADlist[0].Business_Location__Longitude__s;
                                    loc.Business_Place_Id__c = GADlist[0].Business_Place_Id__c;
                                }
                                else if(RedesignMetadata.Capture_Business_Name__c == True && RedesignMetadata.Capture_BuiName_for_OldRec__c == true && GADlist[0].Business_Name__c == null && GADlist[0].Captured_Business_Name__c == False && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True){
                                    List<string> debuglist = New List<string>();
                                     debuglist = getBusinessName(deviceId, latfull, lngfull, GADlist[0], loc, IncludeList, excludeList);
                                    if(RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                        APIcount = APIcount+1;
                                        ApidebugLogMap.put(APIcount,debuglist);
                                    }
                                    //getBusinessName(deviceId, latfull, lngfull, GADlist[0], loc, IncludeList, excludeList);
    
                                    BusinessName = GADlist[0].Business_Name__c != null ? GADlist[0].Business_Name__c : null; 
                                    if(BusinessName != null && !GADlistToInsert.contains(GADlist[0]) && !gadInsertMap.containsKey(GADlist[0].Id)){
                                        GADlistToInsert.add(GADlist[0]);
                                        gadInsertMap.put(GADlist[0].Id,GADlist[0]);
                                    }
                                }
                            }
                        }
                        //Changes for 353 - Google API Error in ARC start
                        else if(latLonMap != null & latLonMap.containsKey(lat) & latLonMap.get(lat).contains(lon)) {
                            for(Google_API_Data__c gad : GADlistToInsert) {
                                if(gad.Latitude__c.contains(lat) && gad.Longitude__c.contains(lon)) {
                                    loc.Location__c = 'In Transit';
                                    loc.Current_Location_Address__c = gad.Current_Address__c;
                                    loc.Current_Street_Address__c  = gad.Current_Street_Address__c;
                                    loc.Current_City__c  = gad.Current_City__c;
                                    loc.Current_State__c  = gad.Current_State__c;
                                    loc.Current_Zipcode__c   = gad.Current_Zip_Code__c;
                                    loc.current_country__c = gad.current_country__c;
                                    if(gad.Business_Name__c != null){
                                        loc.Business_Name__c = gad.Business_Name__c;
                                        loc.Business_Location__Latitude__s =  gad.Business_Location__Latitude__s;
                                        loc.Business_Location__Longitude__s = gad.Business_Location__Longitude__s;
                                        loc.Business_Place_Id__c = gad.Business_Place_Id__c;
                                    }                                
                                    break;
                                }
                            }
                        }
                        //Changes for 353 - Google API Error in ARC end
                        else {
                            loc.Location__c = 'In Transit';
                            loc.Current_Location_Address__c = 'Address Pending';
                            loc.Status__c = 'Google Api Error';
                        }
                    }
                }   
            }
        }
        
        system.debug('###--GADlistToInsert--'+ GADlistToInsert);
        if(!GADlistToInsert.isEmpty()){
            upsert GADlistToInsert;  
        }
        
        if(APIcount>0 && RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
            for(integer key :ApidebugLogMap.keyset()){
                    List<string> debuglist = new List<string>();
                    debuglist =ApidebugLogMap.get(key);
                    RedesignNL_CaptureErrors.createGoogleErrorLogs(debuglist[0], debuglist[1], debuglist[2], debuglist[3], debuglist[4], debuglist[5], debuglist[6], debuglist[7], debuglist[8],debuglist[9]);
                    
            }
        }
    }
    
    public static Boolean checkGeofence(String accId, API_Response_Childs__c loc) {
        boolean flag = false;
        map<id,account> accmap = new map<id,account>();
        Set<id> accids = new Set<id>();
        
        if(accId != null){
            accids.add(accId );

            List<Related_Customer__c> rcList = [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accId order by createddate desc];
            
            
            for(Related_Customer__c rc : rcList){
                accids.add(rc.Related_To__c);
            }
            //ADO - 358 Sorting account by CreatedDate desc Adding (order by createddate asc limit 1) on next line
            
            accmap = new Map<ID, Account>([select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c,isCustom_Geofence__c, is_Custom_Geofence__c FROM Account where id IN : accids order by createddate desc]);
            Decimal lat = Decimal.valueOf(loc.Latitude__c);
            Decimal lon = Decimal.valueOf(loc.Longitude__c);
            
            Location loc2 = Location.newInstance(lat, lon); //response
            Double shortestDistance = 999;
            Double NestedshortDistance = 999;
            String Name = null;
            boolean isinside;
            for(id acc :accids ){
                if(accMap.containskey(acc)) {
                    system.debug(acc);
                    if(accmap.get(acc).isCustom_Geofence__c){
                        isinside = isPointInsideGeofence(accmap.get(acc).id,Decimal.valueOf(loc.Latitude__c),Decimal.valueOf(loc.Longitude__c));
                        if(isinside){
						flag = true;
                        loc.Location__c = accmap.get(acc).name;
                        loc.CurrentLocationId__c = acc;
                        Name = accmap.get(acc).name;
                        loc.Current_Location_Address__c = accmap.get(acc).Address__c;
                        break;
                        }
                    }else{
                    Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude); //
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    system.debug('accmap.get(acc).GeoFence_Radius_in_Miles__c---'+accmap.get(acc).GeoFence_Radius_in_Miles__c);
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c && shortestDistance > result && (Name == null || Name != accmap.get(acc).name)) {
                        shortestDistance = result;
                        loc.Location__c = accmap.get(acc).name;
                        loc.CurrentLocationId__c = acc;
                        Name = accmap.get(acc).name;
                        loc.Current_Location_Address__c = accmap.get(acc).Address__c;
                        flag = true;
                        system.debug('###--acc--'+ acc + ' = ' + accmap.containskey(acc));
                        //  break;
                        }
                    }
                }
            } 
            List<Nested_Geofence__mdt> mdtList = Nested_Geofence__mdt.getall().values();
            for(Nested_Geofence__mdt mdt:mdtList) {
                if(accmap.containskey(mdt.Current_Location_Id__c)){
                    Location loc1 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    if(result < mdt.Diameter__c && NestedshortDistance > result){
                        NestedshortDistance = result;
                        loc.Location__c = accmap.get(mdt.Current_Location_Id__c).name;
                        loc.CurrentLocationId__c = mdt.Current_Location_Id__c;
                        loc.Current_Location_Address__c = accmap.get(mdt.Current_Location_Id__c).Address__c;
                        loc.Facility_Location__c = mdt.Facility_Location__c;
                        flag = true;
                    }  
                }
            }
        }
        return flag ;
    }
    public static String setARCStatus(API_Response_Childs__c arc, API_Response__c resp) {
        if(ast.isNew_Asset__c){
            return 'Pending';
        }
        if(utilityTS.futueTs(arc.Timestamp_Datetime__c)) {
            return 'FutureTS';
        }
        else if(String.valueof(arc.Timestamp__c).startsWith('1104') && arc.PowerUptime__c != null && arc.Latitude__c == null ){
            return 'New';
        }
        else if(Ast.Dormant_Days__c == true & arc.Timestamp_Datetime__c < currentDateTime) {
            if(Ast.Last_Connected__c > arc.Timestamp_Datetime__c)
                return 'BackdatedTS';
            else {
                if(resp != null && resp.Status__c != null)
                    return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed': 'New' ;                
                return 'New';
            }
        }                  
        else if(Ast.Dormant_Days__c == false & arc.Timestamp_Datetime__c < currentDateTime) {
            Integer daysDifference = currentDateTime.date().daysBetween(arc.Timestamp_Datetime__c.date());
            daysDifference = Math.abs(daysDifference); // This will make daysDifference positive
            Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
            Integer dormantDays = Integer.valueOf(Redesign.Dormant_Days__c);
            if (daysDifference > dormantDays) {
                return 'BackdatedTS';
            }else{
                if(resp != null && resp.Status__c != null)
                    return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed': 'New' ;                
                return 'New';
            }
        }
        else
            return 'Pending';
    }  
    public Static List<string> getBusinessName(String deviceId, String latfull, String lngfull, Google_Api_Data__c GadRec, Api_Response_childs__c loc,List<String> IncludeList ,List<String> excludeList){
        List<String> apidebuglogs = new List<String>();
        if (RedesignMetadata.Capture_Business_Name__c || Test.IsRunningTest()) {
            Set<String> excludeType = new Set<String>();
            
            if (System.Label.Exclude_Business_types != null) {
                excludeType.addAll(System.Label.Exclude_Business_types.split(', '));
                
            }
            Set<String> priorityType = new Set<String>();
            
            if (System.Label.Priority_Business_Types != null) {
                priorityType.addAll(System.Label.Priority_Business_Types.split(', '));
            }
            Http http1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setTimeout(60000);
            req1.setMethod('GET');
            req1.setHeader('content-type', 'application/x-www-form-urlencoded');
            req1.setHeader('Accept', 'application/json');
            
            String endpt = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' + Decimal.valueOf(latfull) + ',' + Decimal.valueOf(lngfull) + '&radius=100&key=' + system.label.googleAPIKey;
            req1.setEndpoint(endpt);
            
            HttpResponse res1 = http1.send(req1);
            
            // Filter by 'establishment' type and calculate distance
            if (res1.getStatusCode() == 200) {
                apidebuglogs = new List<String>{ 'RedesignNL_Controller', 'getBusinessName', res1.getBody(), String.valueOf(Decimal.valueOf(res1.getStatusCode())), res1.getStatus(), deviceId, latfull, lngfull, 'Likely Business callout count record','Count'};
                //ApidebugLogMap.put(APIcount,apidebuglogs);
                //Create Debug to count likely Business Callouts
                /*try{
                    RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'getBusinessName', res1.getBody(), String.valueOf(Decimal.valueOf(res1.getStatusCode())), res1.getStatus(), deviceId, latfull, lngfull, 'Likely Business callout count record','Count');            
                }catch(Exception ex) {
                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'getBusinessName', 'Exception', deviceId, null, false);                                       
                }*/
                gadRec.Captured_Business_Name__c = True;
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
                List<Object> results = (List<Object>) jsonResponse.get('results');
                String nearestloc;
                Location assetLocation = Location.newInstance(Decimal.valueOf(latfull), Decimal.valueOf(lngfull));
                
                // This will store business names and their data
                Map<String, Map<String, Object>> businessData = new Map<String, Map<String, Object>>();
                
                // This will store the distances
                List<Decimal> distancesSet = new List<Decimal>();
                String selectedBusinessName = null;
                Decimal selectedBusinessDistance = null;
                String SelectedMapObj = null;
                // First, filter by 'establishment' type
                for (Object resultObj : results) {
                    Set<String> excludeTypeCPY = new Set<String>(excludeType);
                    Map<String, Object> result = (Map<String, Object>) resultObj;
                    
                    // Assuming result.get('types') is a List<Object>
                    List<Object> typesAsObjects = (List<Object>) result.get('types');
                    
                    // Convert List<Object> to List<String>
                    List<String> types = new List<String>();
                    for (Object obj : typesAsObjects) {
                        types.add(String.valueOf(obj)); // Convert each Object to String and add to the list
                    }
                    
                    // Now typesAsStrings is a List<String>
                    
                    String businessName = String.valueOf(result.get('name'));
                    String PlaceId = String.valueOf(result.get('place_id'));
                    excludeTypeCPY.removeAll(types);
                    boolean typecheck= excludeType.size() != excludeTypeCPY.size();
                    // Ensure the result has types and contains 'establishment'
                    if (types != null && types.contains('establishment') && typecheck == false) {
                        // Get location from geometry
                        Map<String, Object> geometry = (Map<String, Object>) result.get('geometry');
                        Map<String, Object> locationData = (Map<String, Object>) geometry.get('location');
                        Decimal geolat = (Decimal) locationData.get('lat');
                        Decimal lng = (Decimal) locationData.get('lng');
                        Set<String> priorityTypeCPY = new Set<String>(priorityType);
                        priorityTypeCPY.removeAll(types);
                        boolean priorTypecheck= priorityType.size() != priorityTypeCPY.size();
                        // Create Location instance for the result
                        Location businessLocation = Location.newInstance(geolat, lng);
                        
                        // Calculate the distance in miles between the two locations
                        Decimal distance = Location.getDistance(businessLocation, assetLocation, 'mi');
                        
                        System.debug('Distance to ' + businessName + ' is: ' + distance + ' miles');
                        // Add the distance to the set
                        distancesSet.add(distance);
                        // Store the business data with its distance and types
                        businessData.put(businessName, new Map<String, Object>{'distance' => distance, 'types' => types,'lat'=> geolat,'lng'=>lng,'PlaceId'=> PlaceId});
                        
                        //Newly added BusinessName for top Priority types
                        if(priorTypecheck){
                            String smallbusinessName = businessName.toLowerCase();
                            boolean captureBusinessName = false;
                            boolean isexcludename = false;
                            String selectedBuiword = null;
                            for(String word : excludeList){
                                word = word.toLowerCase();
                                if(smallbusinessName.contains(word)){
                                    if(SelectedMapObj == businessName){
                                        selectedBusinessName = null;
                                        SelectedMapObj = null;
                                        selectedBusinessDistance = null;
                                        System.debug('eclude '+ businessName);
                                    }
                                    
                                    break;
                                }
                            }
                            if(isexcludename == false){
                                for(String word : IncludeList){
                                    String reword = word.toLowerCase();
                                    if(smallbusinessName.contains(reword)){
                                        if(selectedBusinessDistance == null || selectedBusinessDistance > distance){
                                            selectedBuiword = word;
                                            System.debug('include'+ word+' ' + businessName);
                                            captureBusinessName = true;
                                        }
                                    }else {
                                        if(selectedBusinessDistance == null || selectedBusinessDistance > distance){
                                            captureBusinessName = true;
                                            System.debug('include' + businessName);
                                        }
                                    }
                                }
                            }
                            if(captureBusinessName){
                                system.debug('sekected  '+ businessName);
                                selectedBusinessName = selectedBuiword != null ? selectedBuiword : businessName;
                                selectedMapObj = businessName;
                                selectedBusinessDistance = distance;
                            }
                        }
                    }
                }
                // Sort the distances
                distancesSet.sort();
                System.debug('/n after sorted /n');
                // Create a new sorted map to store businesses by their distance
                Map<String, Map<String, Object>> sortedBusinessData = new Map<String, Map<String, Object>>();
                
                // Iterate over the sorted distances and map them to the business data
                for (Decimal distance : distancesSet) {
                    
                    for (String businessName : businessData.keySet()) {
                        // Check if the distance matches
                        if ((Decimal) businessData.get(businessName).get('distance') == distance) {
                            // Add to the sorted business data map
                            sortedBusinessData.put(businessName, businessData.get(businessName));
                            // Once we find a match, we break out of the inner loop
                        }
                    }
                }
                
                
                // Now check for common words in business names (sorted by distance)
                for (String businessName : sortedBusinessData.keySet()) {
                    boolean containsExclude = false;
                    System.debug(businessName);
                    String smallbusinessName = businessName.toLowerCase();
                    if(selectedBusinessName != null){
                        System.debug('exhgchclude' + businessName);
                        break;
                    }
                    for(String word : excludeList){
                        word = word.toLowerCase();
                        if(smallbusinessName.contains(word)){
                            selectedBusinessName = null;
                            SelectedMapObj = null;
                            containsExclude = true;
                            System.debug('exclude' + businessName);
                            break;
                        }
                    }
                    if(containsExclude == false){
                        system.debug('inside includelist');
                        system.debug(IncludeList.size());
                        for(String word: IncludeList){
                            String reword = word.toLowerCase();
                            if(smallbusinessName.contains(reword) ){
                                selectedBusinessName = word;
                                SelectedMapObj = businessName;
                                System.debug('include ' +word +' '+ businessName);
                                break;
                            }
                        }
                        if(selectedBusinessName == null) {
                            selectedBusinessName = businessName;
                            SelectedMapObj = businessName;
                            System.debug('include ' + businessName);
                            break;
                        }
                    }
                    
                }
                
                System.debug('Selected business: ' + selectedBusinessName);
                if(selectedBusinessName != null){
                    Map<String, Object> businessObj = businessData.get(SelectedMapObj);
                    List<String> typeslst =(List<String>) businessObj.get('types');
                    loc.Business_Name__c = selectedBusinessName;
                    gadRec.Business_Name__c = selectedBusinessName;
                    gadRec.Business_Location__Latitude__s = (Decimal) businessObj.get('lat');
                    gadRec.Business_Location__Longitude__s =(Decimal) businessObj.get('lng');
                    gadRec.Likely_Business_Name_Types__c =String.join(typeslst,' , ');
                    loc.Business_Location__Latitude__s = (Decimal) businessObj.get('lat');
                    loc.Business_Location__Longitude__s =(Decimal) businessObj.get('lng');
                    loc.Business_Place_Id__c = (String) businessObj.get('PlaceId');
                    gadRec.Business_Place_Id__c = (String) businessObj.get('PlaceId');
                }
            } else { 
                System.debug('Error: ' + res1.getStatusCode());
                
                apidebuglogs = new List<String>{ 'RedesignNL_Controller', 'getBusinessName', res1.getBody(), String.valueOf(Decimal.valueOf(res1.getStatusCode())), res1.getStatus(), deviceId, latfull, lngfull, 'Likely Business callout Error log','Error'};
                /*try{
                RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'getBusinessName', res1.getBody(), String.valueOf(Decimal.valueOf(res1.getStatusCode())), res1.getStatus(), deviceId, latfull, lngfull, 'Likely Business callout Error log','Error');            
                }catch(Exception ex) {
                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'getBusinessName', 'Exception', deviceId, null, false);                                       
                }*/
            }   
        }
        return apidebuglogs;

}

       public static Boolean isPointInsideGeofence(id accId, Decimal latitude, Decimal longitude) {
        Account acc = [SELECT Geofence_data__c FROM Account WHERE Id = :accId LIMIT 1];
        if (String.isEmpty(acc.Geofence_data__c)) {
            return false; // No geofence data
        }

        List<Object> geofencePoints = (List<Object>) JSON.deserializeUntyped(acc.Geofence_data__c);
        List<List<Decimal>> polygon = new List<List<Decimal>>();

        for (Object pointObj : geofencePoints) {
            Map<String, Object> pointMap = (Map<String, Object>) pointObj;
            List<Decimal> point = new List<Decimal>{ 
                (Decimal) pointMap.get('lat'), 
                (Decimal) pointMap.get('lng') 
            };
            polygon.add(point);
        }

        return isPointInPolygon(latitude, longitude, polygon);
    }
    
    private static Boolean isPointInPolygon(Decimal lat, Decimal lng, List<List<Decimal>> polygon) {
        Integer numPoints = polygon.size();
        Integer j = numPoints - 1;
        Boolean inside = false;

        for (Integer i = 0; i < numPoints; i++) {
            Decimal xi = polygon[i][0], yi = polygon[i][1];
            Decimal xj = polygon[j][0], yj = polygon[j][1];

            Boolean intersect = ((yi > lng) != (yj > lng)) && 
                (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
            
            if (intersect) {
                inside = !inside;
                //return inside;
            }
            j = i;
        }
        return inside;        
    }
    
}