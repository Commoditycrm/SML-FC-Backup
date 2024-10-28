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
        List<API_Response_Childs__c> tempApiResp;
        List<API_Response_Childs__c> eventApiResp;
        API_Response_Childs__c dvcStatusApiResp;
        Map<string,string> devicecheck;
        
        powerUpTime =null;
        locationTs =null;
        
        datetime BefAssetProcDttime = system.now();
        Rejected_API_Response__c rejectedApiResp = new Rejected_API_Response__c();
        if(fromBatch) {
            resp = ar;
        }
        else {
            resp = new Api_Response__c(Incoming_Messsage__c = requestBody, 
                                       ResEnteringDttime__c = system.now(), 
                                       ResEnteringTime__c = (system.now().getTime()/1000),
                                       Is_Nimbelink_Asset__c = true,
                                       UpdateResponseToAsset__c = true,
                                       Status__c = 'NEW');
        }
        try {
            if(requestBody != null){
                List<Object> templist  = new List<Object>();
                List<Object> eventlist = new List<Object>();
                List<Object> dvcstatus = new List<Object>();
                List<Object> loclist   = new List<Object>();
                
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
                                        deviceId = (String)baseMap.get('id');
                                    }
                                    
                                    if(datamap.containskey('loc')){
                                        loclist = (list<Object>)datamap.get('loc');
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
                                        resp.device_status__c = String.valueof(dvcstatus);
                                        resp.info__c      = String.valueof(datamap.get('info'));
                                        resp.events__c    = String.valueof(datamap.get('events'));
                                        resp.accel__c     = String.valueof(datamap.get('accel'));
                                        resp.Loc__c       = String.valueof(datamap.get('loc'));
                                        resp.Temp__c      = String.valueof(datamap.get('temp'));
                                        resp.Message_ID__c = String.valueOf(MessageID.get('messageId'));
                                        resp.Powerup_Time__c = powerUpTime !=null ? powerUpTime : null;
                                        resp.Location_TimeStamp__c = locationTs !=null ? locationTs : null;
                                        resp.ResEnteringDttime__c = system.now();
                                        
                                    }
                                    resp.Redesigned_Processed__c = true;
                                    resp.Status__c= resp.Status__c.equalsIgnoreCase('PROCESSED') ? resp.Status__c : 'New'; 
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
                    if(arc.Status__c != 'Google Api Error'){
                        arc.Status__c = setARCStatus(arc, resp);
                    }
                    if(arc.Status__c == 'New' && arc.Timestamp_Date_Time_Device_Status__c != null){
                        DeviceStCheck = True;
                    }
                    if(DeviceStCheck == False && arc.Status__c == 'BackdatedTS' && arc.Timestamp_Date_Time_Device_Status__c != null && ((ast.Last_connected2__c != null && arc.Timestamp_Date_Time_Device_Status__c > ast.Last_connected2__c) || String.valueof(arc.Timestamp_Device_Status__c).startsWith('1104'))){
                        deviceStArc = createDevStsRecords(arc);
                    }
                    arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + '~Location';
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
                        if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
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
                }//=========================================================================================================
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
        List<Asset> assetLst = [Select Id, Name,AccountId,Capture_Movement_Event__c,Dormant_Days__c,Last_Connected__c,Last_connected2__c, device_id__c from Asset where device_id__c =: deviceId];
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
        
        List<Google_API_Data__c> GADlistToInsert = new List<Google_API_Data__c>();
        List<Asset> assetLst = [Select Id, Name,AccountId, device_id__c from Asset where device_id__c =: deviceId];
        String accountId;
        if(assetLst.size() > 0) {
            accountId = assetLst[0].AccountId;  
        }
        else {
            List<Account> accList = [Select Id, Name from Account where Name = 'Testing'];
            accountId = accList[0].Id;            
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
                    if(latLonMap == null || !latLonMap.containsKey(lat) || (latLonMap != null & latLonMap.containsKey(lat) & !latLonMap.get(lat).contains(lon))) {
                        List<Google_API_Data__c> GADlist = [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,Business_Name__c,
                                                            Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                            where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lon+'%' ];
                        system.debug('###--GADlist--'+ GADlist);
                        if(GADlist== null || (GADlist!=null && GADlist.isEmpty())){
                            Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=latfull, Longitude__c=lngfull);
                            if (RedesignMetadata.Capture_Business_Name__c) {
                                Http http1 = new Http();
                                HttpRequest req1 = new HttpRequest();
                                req1.setTimeout(60000);
                                req1.setMethod('GET');
                                req1.setHeader('content-type', 'application/x-www-form-urlencoded');
                                req1.setHeader('Accept', 'application/json');
                                
                                String endpt = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' + Decimal.valueOf(latfull) + ',' + Decimal.valueOf(lngfull) + '&radius=100&key=' + system.label.googleAPIKey;
                                req1.setEndpoint(endpt);
                                
                                HttpResponse res1 = http1.send(req1);
                                
                                if (res1.getStatusCode() == 200) {
                                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
                                    List<Object> results = (List<Object>) jsonResponse.get('results');
                                    
                                    // Prepare variables to store the closest business data
                                    Decimal closestDistance = 9999;
                                    String selectedBusinessName = null;
                                    Integer maxTypes = 0;
                                    String nearestName = null;
                                    String MaxTypeName = null;
                                    // Asset location for distance calculation
                                    Location assetLocation = Location.newInstance(Decimal.valueOf(latfull), Decimal.valueOf(lngfull));
                                    
                                    // A map to store business names and their respective closest distances, types, and common words count
                                    Map<String, Map<String, Object>> businessData = new Map<String, Map<String, Object>>();
                                    
                                    // First, filter by 'establishment' type
                                    for (Object resultObj : results) {
                                        Map<String, Object> result = (Map<String, Object>) resultObj;
                                        List<Object> types = (List<Object>) result.get('types');
                                        String businessName = String.valueOf(result.get('name'));
                                        
                                        // Ensure the result has types and contains 'establishment'
                                        if (types != null && types.contains('establishment')) {
                                            // Get location from geometry
                                            Map<String, Object> geometry = (Map<String, Object>) result.get('geometry');
                                            Map<String, Object> locationData = (Map<String, Object>) geometry.get('location');
                                            Decimal geolat = (Decimal) locationData.get('lat');
                                            Decimal lng = (Decimal) locationData.get('lng');
                                            
                                            // Create Location instance for the result
                                            Location businessLocation = Location.newInstance(geolat, lng);
                                            
                                            // Calculate the distance in miles between the two locations
                                            Decimal distance = Location.getDistance(businessLocation, assetLocation, 'mi');
                                            
                                            // Count the number of types for this business
                                            Integer numTypes = types.size();
                                            if(maxTypes == 0 || numTypes > maxTypes){
                                                maxTypes = numTypes;
                                                MaxTypeName = businessName;
                                            }
                                            if(closestDistance > distance){
                                                nearestName = businessName;
                                                closestDistance = distance;
                                            }
                                            
                                            System.debug('Distance to ' + businessName + ' is: ' + distance + ' miles ' + numTypes + ' type');
                                            // Store the business data
                                            businessData.put(businessName, new Map<String, Object>{'distance' => distance, 'types' => numTypes});
                                        }
                                    }
                                    Integer currentCommonWordCount = 0;
                                    // Now we have filtered businesses with 'establishment', let's check for common words
                                    String previousName = null;
                                    for (String businessName : businessData.keySet()) {
                                        Map<String, Object> businessDetails = businessData.get(businessName);
                                        Integer numTypes = (Integer) businessDetails.get('types');
                                        Decimal distance = (Decimal) businessDetails.get('distance');
                                        
                                        List<String> businessWords = businessName.split(' ');
                                        List<String> selectedWords = previousName != null ? previousName.split(' ') : new List<String>();
                                        
                                        // Check for common words
                                        
                                        for (String word : businessWords) {
                                            if (selectedWords.contains(word)) {
                                                currentCommonWordCount++;
                                                System.debug(currentCommonWordCount);
                                                break;
                                            }
                                        }
                                        previousName = businessName;
                                    }
                                    // Apply the updated rules
                                    if (currentCommonWordCount > 0){
                                        selectedBusinessName = MaxTypeName;
                                    }else if(nearestName != null){
                                        selectedBusinessName = nearestName;
                                    }
                                    
                                    // Assign the closest business name or the one with most common words/types
                                    if (selectedBusinessName != null) {
                                        System.debug('Selected business: ' + selectedBusinessName);
                                        loc.Business_Name__c = selectedBusinessName;
                                        gadRec.Business_Name__c = selectedBusinessName;
                                    } else {
                                        System.debug('No establishment found in results.');
                                    }
                                } else {
                                    System.debug('Error: ' + res1.getStatusCode());
                                }
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
                                system.debug('###--res--'+ res);
                                //    system.debug('###--res.getBody()--'+ res.getBody());
                                if(res.getStatusCode() == 200){    
                                    Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                    
                                    system.debug(results1);
                                    List<Object> mapGADdetails = (List<Object>) results1.get('results');
                                    
                                    Map<String,Object> addrvalMap = new map<String,Object>();
                                    for(object obj : mapGADdetails){
                                        String street = '';
                                        String state = '';
                                        String zipCode = '';
                                        String city = '';
                                        string fullAddress;
                                        addrvalMap = (Map<String,Object>)obj;
                                        List<Object> addressdetails = new List<Object>();
                                        if(addrvalMap.containskey('formatted_address')){
                                            fullAddress = (string)addrvalMap.get('formatted_address');
                                        }
                                        if(addrvalMap.containskey('address_components')){
                                            addressdetails = (List<Object>) addrvalMap.get('address_components');    
                                        }  
                                        Map<String,Object> comGADmap = new map<String,Object>();
                                        string types;
                                        for(object obj1 : addressdetails){
                                            comGADmap = (Map<String,Object>)obj1;
                                            if(comGADmap.containskey('types')){
                                                for(object obj2 : (List<Object>) comGADmap.get('types') ){
                                                    if((string)obj2 != 'political'){
                                                        types = (string)obj2;     
                                                    }
                                                }    
                                            }
                                            
                                            if(comGADmap.containskey('short_name')){
                                                if(types == 'route' || types == 'street_number'){       
                                                    street = (string)comGADmap.get('short_name');        
                                                }
                                                if(types.contains('administrative_area_level_1')){
                                                    state = (string)comGADmap.get('short_name');   
                                                }
                                                if(types.contains('locality')){
                                                    city = (string)comGADmap.get('short_name');   
                                                }
                                                if(types == 'postal_code'){
                                                    zipCode = (string)comGADmap.get('short_name');   
                                                }
                                            }//IF Contains Short Name
                                        } //For Address Details
                                        
                                        if(zipcode.length() >0 && state.length() > 0 && fullAddress.length()< 250){
                                            gadRec.Current_Address__c = fullAddress;
                                            gadRec.Current_Street_Address__c = street;        
                                            gadRec.Current_State__c = state;   
                                            gadRec.Current_City__c = city;   
                                            gadRec.Current_Zip_Code__c = zipCode; 
                                            if(!String.isBlank(gadRec.Current_Address__c)){
                                                GADlistToInsert.add(gadRec); 
                                                if(latLonMap.containsKey(lat)){
                                                    if(!latLonMap.get(lat).contains(lon)){
                                                        latLonMap.get(lat).add(lon);
                                                    } 
                                                }else{
                                                    latLonMap.put(lat,new List<String> {lon});
                                                }  
                                            }
                                            loc.Location__c = 'In Transit';
                                            loc.Current_Location_Address__c = fullAddress;      
                                            break;
                                        } //For Address Details
                                        
                                        
                                    }
                                    if(String.isBlank(gadRec.Current_Address__c)){
                                        loc.Location__c = 'In Transit';
                                        loc.Current_Location_Address__c = 'Address not in Google API data';
                                        loc.Status__c = 'Google Api Error';
                                    }
                                    
                                }
                                else{
                                    try {
                                        RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), Decimal.valueOf(res.getStatusCode()), res.getStatus(), deviceId, lat, lon);            
                                    }
                                    catch(Exception ex) {
                                        RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);
                                    }
                                    loc.Location__c = 'In Transit';
                                    loc.Current_Location_Address__c = 'Address not in Google API data';
                                    loc.Status__c = 'Google Api Error';
                                }
                            }
                            else{
                                try {
                                    RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', 'Redesign 3.0 Toggle False - But Address not in Google API data', null, null, deviceId, lat, lon);
                                }
                                catch(Exception ex) {
                                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);                                       
                                }
                                loc.Location__c = 'In Transit';
                                loc.Current_Location_Address__c = 'Address not in Google API data';
                                loc.Status__c = 'Google Api Error';
                            }
                            
                        }
                        else {
                            loc.Location__c = 'In Transit';
                            loc.Current_Location_Address__c = GADlist[0].Current_Address__c; 
                            loc.Business_Name__c = GADlist[0].Business_Name__c != null ? GADlist[0].Business_Name__c : null;
                        }
                    }
                    //Changes for 353 - Google API Error in ARC start
                    else if(latLonMap != null & latLonMap.containsKey(lat) & latLonMap.get(lat).contains(lon)) {
                        for(Google_API_Data__c gad : GADlistToInsert) {
                            if(gad.Latitude__c.contains(lat) && gad.Longitude__c.contains(lon)) {
                                loc.Location__c = 'In Transit';
                                loc.Current_Location_Address__c = gad.Current_Address__c;
                                loc.Business_Name__c = gad.Business_Name__c != null ? gad.Business_Name__c : null;                                
                                break;
                            }
                        }
                    }
                    //Changes for 353 - Google API Error in ARC end
                    else {
                        loc.Location__c = 'In Transit';
                        loc.Current_Location_Address__c = 'Address not in Google API data';
                        loc.Status__c = 'Google Api Error';
                    }
                }   
            }
        }
        
        system.debug('###--GADlistToInsert--'+ GADlistToInsert);
        if(!GADlistToInsert.isEmpty()){
            insert GADlistToInsert;  
        }
    }
    
    public static Boolean checkGeofence(String accId, API_Response_Childs__c loc) {
        boolean flag = false;
        map<id,account> accmap = new map<id,account>();
        Set<id> accids = new Set<id>();
        
        if(accId != null){
            accids.add(accId );
            
            
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accId]){
                accids.add(rc.Related_To__c);
            }
            //ADO - 358 Sorting account by CreatedDate desc Adding (order by createddate asc limit 1) on next line
            
            accmap = new Map<ID, Account>([select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c FROM Account where id IN : accids order by createddate asc]);
            Decimal lat = Decimal.valueOf(loc.Latitude__c);
            Decimal lon = Decimal.valueOf(loc.Longitude__c);
            
            Location loc2 = Location.newInstance(lat, lon); //response
            Double shortestDistance = 999;
            Double NestedshortDistance = 999;
            String Name = null;
            for(id acc :accids ){
                if(accMap.containskey(acc)) {
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
}