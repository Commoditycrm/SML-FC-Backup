public without sharing class nimbeLink_CTRL_Prod{
    public static list<Asset_History_custom__c> tempHistoryList = new list<Asset_History_custom__c>();
    public static DateTime assetLastConnected;
    public static String requestBody, deviceId, assetId, respId;
    public static List<long> LocTS;
    public static decimal poweruptime2;

    public static string parseresponse(String apidata) {
        String  result, response, data;
        Boolean CreateApi = false;
        List<Api_Response__c> resplist = new list<Api_Response__c>();
        Rejected_API_Response__c rejectedApiResponse = new Rejected_API_Response__c();
        LocTS = new list<long>();
        
        Asset ast = new asset();
        List<Object> dvcstatus = new List<Object>();
        List<Object> loclist   = new List<Object>();
        Map<String,Object> dvcmap = new Map<String,Object>();
        
        try{
            result = 'No Error';
            requestBody = apidata;
            rejectedApiResponse.Incomming_Message__c = requestBody;
            Api_Response__c resp = new Api_Response__c(Incoming_Messsage__c = requestBody, 
                                                       ResEnteringDttime__c = system.now(), 
                                                       ResEnteringTime__c = (system.now().getTime()/1000),
                                                       Is_Nimbelink_Asset__c = true,
                                                       Status__c = 'PROCESSED',
                                                       UpdateResponseToAsset__c = true);
            
            if(requestBody != null){
                List<Object> templist  = new List<Object>();
                List<Object> eventlist = new List<Object>();
                Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
                
                if(lst_JsonParse.containskey('message')){
                    Map<String, Object> mapdetails = (Map<String, Object>) lst_JsonParse.get('message');
                    
                    if(mapdetails.containskey('data')){
                        data = (String) mapdetails.get('data');    
                        
                        if(data != null){
                            response = EncodingUtil.base64Decode(data).toString();
                            
                            if(response != null){
                                Map<String, Object> lst_JsonParse1 = (Map<String, Object>)Json.deserializeUntyped(response);    
                                
                                if(lst_JsonParse1.containskey('records')){
                                    
                                    Map<String,Object> commap = new Map<String, Object>();
                                    for(object obj : (list<Object>) lst_JsonParse1.get('records')){
                                        commap.putAll((Map<String, Object>)obj);   
                                    }    
                                    
                                    Map<String, Object> datamap = new  Map<String, Object>();
                                    if(commap.containskey('data')){
                                        datamap = (Map<String, Object>)commap.get('data');    
                                    }  
                                    
                                    Map<String, Object> datamap1 = new Map<String, Object>();
                                    if(commap.containskey('base')){
                                        datamap1 = (Map<String, Object>)commap.get('base');    
                                        if(datamap1.containskey('id')){
                                            deviceId = (String)datamap1.get('id');
                                            ast      = getasset(deviceId);
                                            rejectedApiResponse.Asset__c = ast.Id;
                                        }
                                    }
                                    
                                    // creating event list
                                    if(datamap.containskey('events')){
                                        eventlist = (list<Object>)datamap.get('events');
                                    }
                                    
                                    // creating device status list
                                    if(datamap.containskey('deviceStatus')){
                                        dvcstatus = (list<Object>)datamap.get('deviceStatus');
                                    }
                                    
                                    // creating loc list
                                    if(datamap.containskey('loc')){
                                        loclist = (list<Object>)datamap.get('loc');
                                    }
                                    
                                    // creating temp list
                                    if(datamap.containskey('temp')){
                                        templist = (list<Object>)datamap.get('temp');
                                    }
                                    
                                    if(ast.Id == null){
                                        insert ast;
                                        rejectedApiResponse.Asset__c = ast.Id;
                                    }
                                    
                                    // reparing response records
                                    resp.data__c      = String.valueof(datamap);
                                    resp.base__c      = String.valueof(datamap1);
                                    resp.Device_Id__c = deviceId;
                                    resp.device_status__c = String.valueof(dvcstatus);
                                    resp.info__c      = String.valueof(datamap.get('info'));
                                    resp.events__c    = String.valueof(datamap.get('events'));
                                    resp.accel__c     = String.valueof(datamap.get('accel'));
                                    resp.Loc__c       = String.valueof(datamap.get('loc'));
                                    resp.Temp__c      = String.valueof(datamap.get('temp'));                                    
                                    resp.Asset__c     = ast.Id;
                                    assetId           = ast.Id;
                                    resplist.add(resp);
                                    
                                    if(ast.Capture_Movement_Event__c == true && eventlist != null ){
                                        capturingEvents.parseEventDataMethod(eventlist, ast);
                                    }
                                    
                                    if(!String.isBlank(string.valueof(ast.Last_connected__c))){
                                        assetLastConnected = ast.Last_Connected__c;
                                    }
                                    
                                }
                            }
                        }
                    }  
                    
                    resp.BefAssetProcDttime__c = system.now();
                    resp.BefAssetProcTime__c = system.now().getTime()/1000;
                                         poweruptime2 = ast.PowerUp_Time__c;

                    dvcmap = convertListOfObjectToMap(dvcStatus);
                    ast = fillAssetDetails(ast, dvcmap);
                    
                    insert resp;
                    respId = resp.Id; 
                    
                    if(ast != null && !ast.Power_Reset_Occurred__c && checkDeviceStatus(dvcmap, ast)){
                        ast.Power_Reset_Occurred__c = true;
                        ast.Power_Reset_Time__c = system.now();
                        
                        update ast;
                    }
                        
                        Map<decimal,Asset_History_custom__c> asthistoryMap = new Map<decimal,Asset_History_custom__c>();
                        list<Asset_History_custom__c> inserthislist = new list<Asset_History_custom__c>();
                        
                        if(loclist.size() > 0){
                            result = 'updatLocValues';
                            asthistoryMap = updatLocValues(loclist, ast, dvcmap);    
                        }else if(dvcstatus.size()>0){
                            result = 'updateTSFromDeviceStatus';
                            asthistoryMap = updateTSFromDeviceStatus(dvcmap, ast);  
                        }
                        
                        if(!ast.Capture_Temperature_Response__c){
                            inserthislist =  updateTempValues(templist,asthistoryMap,ast);
                        }else{
                            inserthislist = asthistoryMap.values();
                            captureTempResponses(templist,ast);
                        }
                        
                        upsertAsset(ast, inserthislist);   
                        resp.Location_TimeStamp__c = String.join(LocTS, ',');
                        resp.AfterAssetProcDttime__c = system.now();
                        resp.AfterAssetProcTime__c = system.now().getTime()/1000;
                        
                                        
                }
            }
            
            upsert resplist;
            
            return 'succesfully processed';
        } catch(exception ex){
            if(!ex.getMessage().contains('UNABLE_TO_LOCK_ROW'))
            {
            rejectedApiResponse.Error__c = '--Asset ID:--' + deviceId + '\n' + ex.getMessage();
            rejectedApiResponse.Incomming_Message__c=requestBody;
            insert rejectedApiResponse;
            }
            if(ex.getMessage().contains('UNABLE_TO_LOCK_ROW'))
            {
                unableToLockRow(ast, loclist, dvcmap);
                
            }
            sendemail(ex.getMessage()+' -- MethodName : parseresponse()-- '+' -- On Line -- '+ex.getLineNumber()+' -- Type -- '+ 
                      ex.getTypeName()+' -- Cause -- '+ex.getCause()+' -- Stack --'+ ex.getStackTraceString() + '--Asset ID:--' + deviceId + 
                      'Method Name:' + result + 'Raw Message:' + requestBody);
            return null;
            
        }
    }
    
    public static boolean checkDeviceStatus(Map<String, Object> dvcmap, asset ast){
        Boolean result = false;        
        String tsValue = dvcmap.containskey('ts') ? String.valueOf((integer)dvcmap.get('ts'))        : null;
        Decimal powerUpTime = dvcmap.containskey('powerUptime') ? (Decimal)dvcmap.get('powerUptime') : null;
        
        if(tsValue != null && tsValue.startsWith('1104')){
            result =  true;
            ast.PowerUp_Time__c = powerUpTime;
        }else if(powerUpTime < poweruptime2 && (poweruptime2 != null && string.valueOf(powerUpTime).length() < string.valueOf(poweruptime2).length())){
            result =  true;
            ast.PowerUp_Time__c = powerUpTime;
            
            if(dvcmap.containskey('ts')){
                DateTime localTime = utilityTS.convertTS((Integer)dvcmap.get('ts'));
                if(localTime != null){
                    ast.Last_Connected__c = localTime;
                    if(assetLastConnected != null && ast.Last_Connected__c < assetLastConnected){
                        ast.Last_Connected__c = assetLastConnected;
                    } 
                    /*else if (assetLastConnected == null){
                        assetLastConnected  = ast.Last_Connected__c;
                    }*/
                }  
            }
        }
        return result;
    }
    
    // populating asset details.
    public static Asset fillAssetDetails(Asset ast, Map<String,Object> dvcmap){
        if(ast != null){
            ast.Battery_Voltage__c = dvcmap.containskey('battery') ? (decimal)dvcmap.get('battery') : ast.Battery_Voltage__c;
            ast.estBattPct__c      = dvcmap.containskey('estBattPct') ? (decimal)dvcmap.get('estBattPct') : ast.estBattPct__c;
            ast.rsrp__c = dvcmap.containskey('rsrp') ? (decimal)dvcmap.get('rsrp') : ast.rsrp__c;
            ast.rsrq__c = dvcmap.containskey('rsrq') ? (decimal)dvcmap.get('rsrq') : ast.rsrq__c;
            ast.rssi__c = dvcmap.containskey('rssi') ? (decimal)dvcmap.get('rssi') : ast.rssi__c;    
            ast.signal__c = dvcmap.containskey('signal') ? (decimal)dvcmap.get('signal') : ast.signal__c;
            ast.PowerUp_Time__c = dvcmap.containskey('powerUptime') ? (decimal)dvcmap.get('powerUptime') : ast.PowerUp_Time__c;    
            
            if(dvcmap.containskey('ts')){
                DateTime localTime = utilityTS.convertTS((Integer)dvcmap.get('ts')); 
                if(localTime != null && (ast.Last_Connected2__c == null || ast.Last_Connected2__c < localTime)) {
                    ast.Last_Connected2__c = localTime;
                }    
            }
        }
        
        return ast;
    }
    
    public static Map<decimal, Asset_History_custom__c> updatLocValues(list<Object> loclist, Asset ast, Map<String, Object> dvcmap){
        Map<Integer, Map<String,Object>> resultMap = new Map<Integer, Map<String, Object>>();
        list<location_record_ignored__c> lri_list = new list<location_record_ignored__c>();
        
        for(object obj : loclist){
            Map<String, Object> locmap = (Map<String,Object>)obj;
            
            if(locmap.containsKey('haccRank') && locmap.get('haccRank') == 0){
                Datetime checkpastdate = DateTime.parse('01/01/2022, 12:00 AM');
                Datetime locDTM = utilityts.convertTS((long)locmap.get('ts'));
                Boolean futurecheck= utilityts.futueTs(locDTM);
                LocTS.add((long)locmap.get('ts'));
                
                if(!futurecheck && locDTM > checkpastdate){
                    resultMap.put((Integer)locmap.get('ts'), locmap); 
                }else{
                    location_record_ignored__c lri = new location_record_ignored__c();
                    lri.Incoming_Message__c = requestBody;
                    lri.Device_Id__c = deviceId;
                    lri.Asset__c     = assetId;
                    lri.latitude__c  = (decimal)locmap.get('lat');  
                    lri.longitude__c = (decimal)locmap.get('lon');
                    lri.Altitude__c  = (decimal)locmap.get('alt');
                    lri.hacc__c      = (decimal)locmap.get('hacc');
                    lri.haccRank__c  = (integer)locmap.get('haccRank');
                    lri.pdop__c      = (decimal)locmap.get('pdop');
                    lri.requestTs__c = (long)locmap.get('requestTs');  //long
                    lri.ttf__c       = (decimal)locmap.get('ttf');     // decimal
                    lri.Timestamp__c = (long)locmap.get('ts');         // long 
                    lri.Location_Captured_Time__c =  locDTM;           // ts to cst
                    lri.Reason__c    = 'Future TS';
                    
                    if(locmap.containskey('calc')){
                        lri.calc__c = (boolean)locmap.get('calc');
                    }
                    
                    if(locmap.containskey('src')){
                        if((string)locmap.get('src') == 'w'){
                            lri.src__c = 'wifi';
                        }
                        else if((string)locmap.get('src') == 'c'){
                            lri.src__c = 'cellular';
                        }
                        else if((string)locmap.get('src') == 'g'){
                            lri.src__c = 'gps';
                        }
                    }
                    lri_list.add(lri);
                }
            }
        }
        
        Map<Decimal,Asset_History_custom__c> asthisMap = new Map<Decimal,Asset_History_custom__c>();
        list<Asset_History_custom__c> asthis = new list<Asset_History_custom__c>();
        Integer loopcount = 1;
        Decimal tsvalue, lastconnttime, latitude, longitude;
        
        //Changed Asset_History_custom__c oldhis;
        Asset_History_custom__c oldhis = new Asset_History_custom__c();
        Map<Id,Account> accmap = new Map<Id,Account>();
        List<Nested_Geofence__mdt> nestedGeofences = new List<Nested_Geofence__mdt>();
        
        if(ast.id != null){
            for(Asset_History_custom__c ahc : [SELECT id,asset__c,Api_Response__c,start_time__c,Location__c,Account_ID__c,Timestamp__c,Latitude__c,Longitude__c,End_Time__c,Still_in_this_Location__c 
                                               FROM Asset_History_custom__c 
                                               WHERE Asset__c =: ast.id and Still_in_this_Location__c = true order by createddate desc limit 1]){
                                                   oldhis = ahc;
                                                   asthis.add(ahc);
                                               } 
            
            if(oldhis.Account_ID__c != null){
                Set<Id> accids = new Set<Id>();  
                accids.add(oldhis.Account_ID__c);
                for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: oldhis.Account_ID__c]){
                    accids.add(rc.Source_Account__c);
                    accids.add(rc.Related_To__c);
                }
                
                for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
                    accmap.put(acc.id,acc);    
                }
                
                nestedGeofences = [select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids];
            }
        }
        
        decimal newLatitude;
        decimal newLongitude;
        datetime newlastconnecttime;
        boolean updateoldhis = false;
        datetime endtimeforhistoryrecord;
        boolean isexecute = true;
        
        Map<string,id> recidmap = new map<string,id>();
        for(recordtype rec : [select Id,sobjecttype,developername from recordtype]){
            recidmap.put(rec.sobjecttype+'-'+rec.DeveloperName, rec.id);    
        }
        
        Map<string,Asset_History_custom__c> latlngwithHistory = new Map<string,Asset_History_custom__c>();
        Map<String,Object> locmap1 = new map<String,Object>();
        DateTime localTime;
        
        list<Integer> intlist = new list<Integer>(resultMap.keyset());
        intlist.sort();
        for(integer inte : intlist){ // Assuming max 4-5 iteration
            locmap1 = resultMap.get(inte);
            
            if(locmap1.containskey('ts')){
                localTime = utilityTS.convertTS((Integer)locmap1.get('ts')); //localTime - Store the CST time values  
            }
            
            DateTime localTimedvc;
            Decimal timestamp;
            Boolean check= true;
            
            if(ast.id == null || oldhis.End_Time__c == null || oldhis.End_Time__c < localTime || (ast.Last_Connected2__c > localTime &&  oldhis.End_Time__c < localTime)){
                updateoldhis = true;
                localTimedvc = ast.Last_Connected2__c > localTime ? ast.Last_Connected2__c : localTime;
                
                Asset_History_custom__c ah = new Asset_History_custom__c(Api_Response__c=respId);
                String loc = oldhis != null ? oldhis.Location__c : 'NA';
                
                if( oldhis != null && oldhis.Location__c != 'In Transit' && loc != 'NA' && loc == currentLocName(accmap,(decimal)locmap1.get('lat'),(decimal)locmap1.get('lon'), nestedGeofences) && caldistance(accmap,(decimal)locmap1.get('lat'),(decimal)locmap1.get('lon'))){
                    ah    = oldhis;  
                    check = false;
                }else{
                    if(loopcount == 1 && oldhis != null && oldhis.Latitude__c == (decimal)locmap1.get('lat') && oldhis.Longitude__c == (decimal)locmap1.get('lon') ){
                        ah    = oldhis;  
                        check = false;
                    }else if(newLatitude == (decimal)locmap1.get('lat') && newLongitude == (decimal)locmap1.get('lon')){
                        check = false;
                        String key = newLatitude+'-'+newLongitude;
                        if(latlngwithHistory.containskey(key) && latlngwithHistory.get(key).loop_count__c == loopcount - 1){
                            ah = latlngwithHistory.get(key);
                            timestamp = ah.Timestamp__c;  
                        }
                    }  
                }
                
                if(locmap1.containskey('lat')){
                    ah.Latitude__c = (decimal)locmap1.get('lat');
                    newLatitude =  ah.Latitude__c;
                    if(loopcount == intlist.size()){
                        ast.Temporary_Latitude__c = (decimal)locmap1.get('lat');    
                    }
                }
                if(locmap1.containskey('lon')){
                    ah.Longitude__c = (decimal)locmap1.get('lon');
                    newLongitude =  ah.Longitude__c;
                    if(loopcount == intlist.size()){
                        ast.Temporary_Longitude__c = (decimal)locmap1.get('lon');    
                    }
                }
                if(locmap1.containskey('alt')){
                    ah.Altitude__c = (decimal)locmap1.get('alt');
                    if(loopcount == intlist.size()){
                        ast.alt__c = (decimal)locmap1.get('alt');    
                    }
                }
                if(locmap1.containskey('hacc')){
                    ah.Accuracy_meters__c = (decimal)locmap1.get('hacc');
                    if(loopcount == intlist.size()){
                        ast.Accuracy_meters__c = (decimal)locmap1.get('hacc');    
                    }
                }
                if(locmap1.containskey('src')){
                    if((string)locmap1.get('src') == 'w'){
                        ah.Message_Type__c = 'wifi';
                        if(loopcount == intlist.size()){
                            ast.src__c = 'wifi';
                        }
                    }else if((string)locmap1.get('src') == 'c'){
                        ah.Message_Type__c = 'cellular';
                        if(loopcount == intlist.size()){
                            ast.src__c = 'cellular';
                        }
                    }else if((string)locmap1.get('src') == 'g'){
                        ah.Message_Type__c = 'gps';  
                        if(loopcount == intlist.size()){
                            ast.src__c = 'gps';
                        }
                    }
                    
                }
                if(recidmap.containskey('Asset_History_custom__c-Location')){
                    ah.RecordTypeId =  recidmap.get('Asset_History_custom__c-Location');
                }
                if(locmap1.containskey('requestTs')){
                    ah.Timestamp__c = (Integer)locmap1.get('requestTs');    
                }
                if(localTime != null){
                    if(ah.End_Time__c == null ||(ah.End_Time__c < localTime)){
                        ah.End_Time__c =localTime;
                    }
                    if(check){
                        ah.Location__c = 'In Transit';
                        ah.Start_Time__c =localTime;
                        if(isexecute){
                            endtimeforhistoryrecord = localTime;
                            isexecute = false;
                        }
                    }
                    if(loopcount == intlist.size()){
                        ast.Last_Connected__c = localTimedvc;   
                        if(assetLastConnected != null && ast.Last_Connected__c < assetLastConnected){
                            ast.Last_Connected__c = assetLastConnected;
                        }
                        /*else if (assetLastConnected == null){
                            assetLastConnected  = ast.Last_Connected__c;
                        }*/
                    }
                }
                if(loopcount == intlist.size()){
                    ah.Still_in_this_Location__c = true;    
                }
                
                if(timestamp != null){
                    ah.Timestamp__c = timestamp;
                    tsvalue = timestamp;
                    asthisMap.put(timestamp,ah);  
                }else{
                    tsvalue = ah.Timestamp__c;
                    asthisMap.put(ah.Timestamp__c,ah);    
                }
                
                latlngwithHistory.put(ah.Latitude__c+'-'+ah.Longitude__c,ah);
                
                if(ah.Location__c != null && ah.Location__c != 'In Transit'){
                    latlngwithHistory.put(ah.Location__c,ah);
                }
                
                for(Asset_History_custom__c ahis :asthisMap.values()){
                    if(ahis.id == null && ahis.loop_count__c == loopcount-1 ){
                        if(ahis.End_Time__c == null ||(ahis.End_Time__c < localTime)){
                            ahis.End_Time__c = localTime;  
                        }
                    }  
                    
                    tsvalue = timestamp != null ? timestamp : ahis.Timestamp__c;
                    asthisMap.put(tsvalue, ahis); 
                }
                
                ah.loop_count__c = loopcount;
                loopcount ++;
                for(Asset_History_custom__c ahis : asthis){
                    if(check){
                        if(endtimeforhistoryrecord != null){
                            if(ahis.End_Time__c == null ||(ahis.End_Time__c < endtimeforhistoryrecord)){
                                ahis.End_Time__c = endtimeforhistoryrecord;  
                            }
                        }
                        ahis.Still_in_this_Location__c = false;    
                        ahis.Api_Response__c = respId;
                    }                    
                }
            }
            else // to store ignored location records - which has delayed ts
            { 
                location_record_ignored__c lri = new location_record_ignored__c();
                lri.Incoming_Message__c = requestBody;
                lri.Device_Id__c =  deviceId;
                lri.Asset__c =   assetId;
                lri.Account__c = oldhis.Account_ID__c;
                lri.latitude__c = (decimal)locmap1.get('lat');  
                lri.longitude__c = (decimal)locmap1.get('lon');
                lri.Altitude__c = (decimal)locmap1.get('alt');
                if(locmap1.containskey('calc')){
                    lri.calc__c = (boolean)locmap1.get('calc');
                }   
                
                lri.rsri__c = (decimal)dvcmap.get('rssi');
                lri.rsrp__c = (decimal)dvcmap.get('rsrp');
                lri.rsrq__c = (decimal)dvcmap.get('rsrq');
                lri.Accuracy__c=(decimal)locmap1.get('hacc');
                //lri.Device_Status__c=dvcmap;
                lri.voltage__c=(decimal)dvcmap.get('battery');
                lri.cellular_signal__c=(decimal)dvcmap.get('signal');
                lri.hacc__c= (decimal)locmap1.get('hacc');
                lri.haccRank__c = (integer)locmap1.get('haccRank');
                lri.pdop__c = (decimal)locmap1.get('pdop');
                lri.requestTs__c = (long)locmap1.get('requestTs');    
                lri.ttf__c = (Decimal)locmap1.get('ttf');    
                lri.Timestamp__c = (long)locmap1.get('ts');  
                lri.Location_Captured_Time__c =  localTime; // ts to cst
                lri.Reason__c = 'Out of Order TS';
                
                if(locmap1.containskey('src')){
                    if((string)locmap1.get('src') == 'w'){
                        lri.src__c = 'wifi';
                    }
                    else if((string)locmap1.get('src') == 'c'){
                        lri.src__c = 'cellular';
                    }
                    else if((string)locmap1.get('src') == 'g'){
                        lri.src__c = 'gps';  
                    }
                }
                
                lri_list.add(lri);
            }
        }
        
        insert lri_list;
        
        if(asthis.size()>0 && updateoldhis){
            update asthis;
        }
        return asthisMap;
    }
    
    public static Map<String, Object> convertListOfObjectToMap(list<Object> lst){
        Map<String, Object> retMap = new Map<String, Object>();
        for(Object obj : lst){
            retMap.putAll((Map<String,Object>)obj);
        }
        
        return retMap;
    }    
    
    public static String currentLocName(Map<id,account> accMap, decimal lat1,decimal lng1, List<Nested_Geofence__mdt> nestedGeofences){
        String locName;
        
        for(id acc : accMap.KeySet()){
            Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
            Location loc2 = Location.newInstance(lat1,lng1);
            Double result = Location.getDistance(loc1, loc2, 'mi');      
            if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                locName = accmap.get(acc).name;
                break;  
            }
        }
        
        for (Nested_Geofence__mdt mdt: nestedGeofences){
            Location loc1 = Location.newInstance(lat1,lng1);
            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
            Double result = Location.getDistance(loc1, loc2, 'mi');
            if(result < mdt.Diameter__c){
                locName = mdt.Current_Location__c;  
                break;  
            }  
        }
        
        return locName;
    }
    
    public static Boolean caldistance(Map<id,account> accMap, decimal lat1,decimal lng1){
        Boolean res = false;
        Double result;
        
        for(id acc : accMap.KeySet()){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
            }
            if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result < accmap.get(acc).GeoFence_Radius_in_Miles__c){
                res = true;
                break;  
            }
        }    
        
        return res;
    }
    
    public static void sendemail(String response){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toaddress();
            message.subject = 'Error Occured in the Incoming response';
        message.plainTextBody = response ;
       // Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
           // Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
      public static list<string> toaddress(){
        id grpid;
        set<id> usrids = new set<id>();
        list<string> emaillist = new list<string>();
        /*for(group gr : [SELECT id, Name FROM Group where developername = 'developers']){
            grpid = gr.id;    
        }
        for(groupmember gm : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember where GroupId =: grpid ]){
            usrids.add(gm.UserOrGroupId);    
        }
        for(user usr : [select id,email from user where id IN : usrids]){
            emaillist.add(usr.email);
        }*/
        return emaillist;
    }
    
    public static Asset getasset(String deviceId){
        Asset asst = new asset();
        for(Asset ast : [SELECT id,AccountId,Last_Connected_Cached__c,Measurement_Period_desired__c,Measurement_Period_Reported__c,Measurement_Period_Check__c,
                         Last_Known_Location__r.name, Capture_Movement_Event__c, Movement__c, Movement_End__c,Battery_Replaced_Date__c,Power_Reset_Time__c,
                         PowerUp_Time__c,Current_Location__r.name,Capture_Temperature_Response__c,Power_Reset_Occurred__c,Last_Connected2__c,
                         Current_Location_Address__c,name,alt__c,Battery_Voltage__c,signal__c,rsrq__c,src__c,Temperature__c,rssi__c,rsrp__c,estBattPct__c,
                         Humidity__c,Capturing_Response__c,Last_Connected__c, Device_Id__c,est_Batterycalculate__c,CreatedDate 
                         FROM Asset 
                         WHERE Device_Id__c =: deviceId]){
                             asst = ast;
                         }
        
        if(asst.Id == null){
            String accountid;
            for(account acc:[select Id,name from account where name = 'Testing']){
                accountid = acc.Id;
            }
            
            asst.name = deviceId;
            asst.Device_Id__c = deviceId;
            asst.Capturing_Response__c= true;
            asst.accountid = accountid;
        }
        
        return asst;
    }
    
    public static Map<decimal,Asset_History_custom__c> updateTSFromDeviceStatus(Map<String,Object> dvcmap, Asset ast ){
        Map<decimal,Asset_History_custom__c> asthisMap = new Map<decimal,Asset_History_custom__c>();
        Integer lsttime;
        
        if(ast != null){
            if(dvcmap.containskey('ts')){
                lsttime =(Integer)dvcmap.get('ts');    
            }
        }
        
        DateTime localTime;
        localTime = utilityTS.convertTS(lsttime);         
        ast.Last_Connected__c = localTime;
        if(assetLastConnected != null && ast.Last_Connected__c < assetLastConnected){
            ast.Last_Connected__c = assetLastConnected;
        } 
        /*else if (assetLastConnected == null){
            assetLastConnected  = ast.Last_Connected__c;
        }*/
        
        for(Asset_History_custom__c ahc : [select id,start_time__c,Api_Response__c,asset__c,Location__c,Account_ID__c,Timestamp__c,Latitude__c,Longitude__c,End_Time__c,
                                           Still_in_this_Location__c from Asset_History_custom__c 
                                           where asset__c =: ast.id and Still_in_this_Location__c = true order by createddate desc limit 1]){    
                                               if(ahc.End_Time__c == null ||(ahc.End_Time__c < localTime)){
                                                   ahc.End_Time__c =  localTime; 
                                               }
                                               asthisMap.put(lsttime,ahc);
                                           }
        
        return asthisMap;
    }
    
    public static list<Asset_History_custom__c> updateTempValues(list<object> Templist,map<decimal,Asset_History_custom__c> hisMap, Asset ast){
        
        Map<String,Object> Tempmap = new map<String,Object>();
        Map<String,Object> Tempmap1 = new map<String,Object>();
        list<integer> tempfinalinteger = new list<integer>();
        Map<integer,Map<String,Object>> resultMap1 = new map<integer,Map<String,Object>>();
        list<Asset_History_custom__c> historyList = new list<Asset_History_custom__c>();
        
        for(object obj : Templist){
            Tempmap = (Map<String,Object>)obj;
            resultMap1.put((Integer)Tempmap.get('ts'),Tempmap);
        }
        
        list<integer> intlist1 = new list<integer>();
        intlist1.addall(resultMap1.keyset());
        intlist1.sort();
        map<decimal,Asset_History_custom__c> asthisMap1 = new map<decimal,Asset_History_custom__c>();
        
        integer loopcount = 1;
        if(hisMap != null){
            historyList = hisMap.values();    
        }
        
        for(integer inte : intlist1){
            //Tempmap1 =    resultMap1.get(inte);
            if(hisMap.containskey((decimal)resultMap1.get(inte).get('ts'))){
                tempfinalinteger.add(inte);  
            }
        }  
        
        for(integer inte : tempfinalinteger){
            Tempmap1 =  resultMap1.get(inte);
            for(Asset_History_custom__c ah : historyList){
                ah.Api_Response__c = respId;
                if(ah.Timestamp__c == (decimal)Tempmap1.get('ts')){  
                    if(Tempmap1.containskey('c')){
                        ah.Temperature__c = 1.8 * (decimal)Tempmap1.get('c') + 32;  
                        if(loopcount == tempfinalinteger.size()){
                            ast.Temperature__c = 1.8 * (decimal)Tempmap1.get('c') + 32;    
                        }
                    }
                    if(Tempmap1.containskey('rh')){
                        ah.Relative_Humidity__c  = (decimal)Tempmap1.get('rh') ;
                        if(loopcount == tempfinalinteger.size()){
                            ast.Humidity__c = (decimal)Tempmap1.get('rh') ;    
                        }
                    }
                }
            }
            loopcount++;
        }
        
        return historyList;
    }
    
    public static void captureTempResponses(list<object> Templist,asset ast){
        id recid;
        
        for(recordtype rec : [select id,sobjecttype,developername from recordtype where sobjecttype = 'Asset_History_custom__c' and developername = 'temperature']){
            recid = rec.id;    
        }
        
        integer loopcount = 1;
        Map<String,Object> Tempmap = new map<String,Object>();
        Map<String,Object> Tempmap1 = new map<String,Object>();
        Map<integer,Map<String,Object>> resultMap1 = new map<integer,Map<String,Object>>();
        list<Asset_History_custom__c> historyList = new list<Asset_History_custom__c>();
        if(Templist!=null)
            for(object obj : Templist){
                Tempmap = (Map<String,Object>)obj;
                resultMap1.put((Integer)Tempmap.get('ts'),Tempmap);
            }
        
        list<integer> intlist1 = new list<integer>();
        intlist1.addall(resultMap1.keyset());
        intlist1.sort();
        
        for(integer inte : intlist1){
            Tempmap1 = resultMap1.get(inte);
            
            Asset_History_custom__c ah = new Asset_History_custom__c(Api_Response__c=respId);
            if(Tempmap1.containskey('c')){
                ah.Temperature__c = 1.8 * (decimal)Tempmap1.get('c') + 32;  
                ast.Temperature__c = 1.8 * (decimal)Tempmap1.get('c') + 32;    
            }
            if(Tempmap1.containskey('rh')){
                ah.Relative_Humidity__c  = (decimal)Tempmap1.get('rh') ;
                ast.Humidity__c = (decimal)Tempmap1.get('rh') ;    
            }
            integer lsttime;
            if(Tempmap1.containskey('ts')){
                lsttime =(Integer)Tempmap1.get('ts');    
            }
            DateTime localTime;
            localTime = utilityTS.convertTS(lsttime);
            ah.Start_Time__c = localTime;
            if(ah.End_Time__c == null ||(ah.End_Time__c < localTime)){
                ah.End_Time__c = localTime;  
            }
            ah.asset__c = ast.id;
            ah.Changed_Field__c = 'Temperature';
            ah.recordtypeid = recid;
            tempHistoryList.add(ah);
            loopcount++;
        }
    }
    
    public static void upsertAsset(asset ast, list<Asset_History_custom__c> hislist){
        
        list<Asset_History_custom__c> inserthislist = new list<Asset_History_custom__c>();
        list<Asset_History_custom__c> oldhislist = new list<Asset_History_custom__c>();
        map<id,Asset_History_custom__c> asthistmap = new map<id,Asset_History_custom__c>();
        map<string,Asset_History_custom__c> locMap = new map<string,Asset_History_custom__c>();
        string previousLoc;
        datetime previousStartTime;
        integer index = 0;
        
        if(ast != null){
            
            integer loopcountvalue = 0;
            for(Asset_History_custom__c ad : hislist){
                ad.Api_Response__c = respId;
                if(ast.Last_Known_Location__r.name != null){
                    ad.Last_Known_Location__c = ast.Last_Known_Location__r.name;
                }
                
                if(!string.isBlank(previousLoc) && previousLoc == 'In Transit'){
                    if(loopcountvalue == 0){
                        ast.Last_Connected_Cached__c=previousStartTime; 
                        loopcountvalue = 1;
                    } else if(previousStartTime <= ast.Last_Connected_Cached__c && loopcountvalue >= 1 ){
                        ast.Last_Connected_Cached__c=previousStartTime; 
                    }
                }else {
                    ast.Last_Connected_Cached__c=null;
                }  
                
                previousLoc = ad.location__c;
                previousStartTime = ad.Start_Time__c;
            }
            
            ast.Is_NimbeLink_Asset__c = true;
            utilityclass.inventorycheck();
         
            upsert ast;
            
            for(Asset asts:[select id,AccountId,Last_Connected_Cached__c,Battery_Replaced_Date__c,CreatedDate,Measurement_Period_Check__c,Last_Known_Location__r.name,PowerUp_Time__c,Current_Location__c,Accelerometer_Status_Check__c, Last_Connected2__c ,Network_Check_in_period_chek__c,Temperature_Check_in_Period_Check__c,Temperature_Status_Check__c,Use_Wifi_Check__c,Use_Gps_check__c,Use_Cell_Check__c,Location_Status_Check__c,Location_Sampling_Period_check__c,Tracking_Locations_per_Check_Ins_check__c,Tracking_Location_Period_Check__c,ConnectMovementEnd_Check__c,ConnectMovementStart_Check__c,Trackmode_check__c,Device_Id__c,Current_Location__r.name,Current_Location_Address__c, est_Batterycalculate__c from Asset where id=: ast.id FOR UPDATE]){
                for(Asset_History_custom__c ad : hislist){
                    if(asts.Current_Location__c != null){
                        ad.location__c =  asts.Current_Location__r.name;
                        ad.currentLocationId__c=Utilityclass.currentLocId(asts.AccountId,ad.Latitude__c,ad.Longitude__c);
                        ad.Current_Location_Address__c = asts.Current_Location_Address__c;
                    }
                    
                    if(asts.Last_Known_Location__r.name != null){
                        ad.Last_Known_Location__c = asts.Last_Known_Location__r.name;    
                    }
                    
                    if(ad.Asset__c == null){
                        ad.Asset__c = ast.id;  
                        if(ast.Battery_Voltage__c!=null){
                            ad.Battery_Voltage__c = ast.Battery_Voltage__c;
                        }
                        
                        if(ast.alt__c!=null){
                            ad.Altitude__c = ast.alt__c;
                        }
                        if(ast.signal__c!=null){
                            ad.Cellular_Signal__c = ast.signal__c;
                        }
                        
                        if(ast.Power_Reset_Occurred__c == false)
                            ad.Est_Remaining_Battery__c = ast.estBattPct__c;
                        else if(ast.Power_Reset_Occurred__c == True && ast.Battery_Replaced_Date__c == null)
                            ad.Est_Remaining_Battery__c = 100 - ((date.newinstance(ast.CreatedDate.year(), ast.CreatedDate.month(), ast.CreatedDate.day()).daysBetween(System.today()))* 0.054795); 
                        else if(ast.Power_Reset_Occurred__c == True && ast.Power_Reset_Time__c != null  && ast.Battery_Replaced_Date__c != null && ast.Battery_Replaced_Date__c <  date.newinstance(ast.Power_Reset_Time__c.year(), ast.Power_Reset_Time__c.month(), ast.Power_Reset_Time__c.day()))
                            ad.Est_Remaining_Battery__c = (100 - ((ast.Battery_Replaced_Date__c.daysBetween(System.today())) * 0.054795));
                        else
                            ad.Est_Remaining_Battery__c = ast.estBattPct__c;
                        
                        
                        if(ast.rsrp__c!=null){
                            ad.rsrp__c = ast.rsrp__c;
                        }
                        if(ast.rsrq__c!=null){
                            ad.rsrq__c = ast.rsrq__c;
                        }
                        if(ast.rssi__c!=null){
                            ad.rssi__c = ast.rssi__c;
                        }
                        
                        if(asts.Current_Location__c != null){
                            ad.currentLocationId__c=Utilityclass.currentLocId(asts.AccountId,ad.Latitude__c,ad.Longitude__c);
                            ad.location__c =  asts.Current_Location__r.name;
                            ad.Current_Location_Address__c = asts.Current_Location_Address__c;
                        }
                        
                        if(ast.src__c!=null){
                            ad.Message_Type__c = ast.src__c;
                        }
                    }
                    
                    if(!string.isBlank(previousLoc) && previousLoc != 'In Transit' && previousLoc == ad.location__c ){
                        ad.Start_Time__c = previousStartTime;
                        if(inserthislist.size() > 0) {
                            inserthislist.remove(index-1);
                        }
                    }
                    if(ad.id == null){
                        inserthislist.add(ad);    
                    }else{
                        oldhislist.add(ad);
                    }
                    index = inserthislist.size();
                    previousLoc = ad.location__c;
                    previousStartTime = ad.Start_Time__c;
                }
                if(System.Label.getConfigurationNimbeLinkMethod == 'ON'){
                    if(!asts.Accelerometer_Status_Check__c||!asts.Trackmode_check__c||!asts.ConnectMovementStart_Check__c|| !asts.Location_Sampling_Period_check__c||!asts.Location_Status_Check__c||!asts.Use_Gps_check__c||!asts.Use_Cell_Check__c||!asts.Use_Wifi_Check__c||!asts.Temperature_Status_Check__c||!asts.Temperature_Check_in_Period_Check__c||!asts.Network_Check_in_period_chek__c ||!asts.Tracking_Location_Period_Check__c ||  !asts.ConnectMovementEnd_Check__c || !asts.Tracking_Locations_per_Check_Ins_check__c || !asts.Measurement_Period_Check__c){
                        getconfigurationNimbelink.getCofigs2(asts.Device_Id__c);
                    }
                }
            }
            
            for(Asset_History_custom__c asth : oldhislist){
                asthistmap.put(asth.id,asth);      
            }
            
            for(Asset_History_custom__c ast1 : asthistmap.values()){
                inserthislist.add(ast1);    
            }
            
            if(tempHistoryList.size()>0 && tempHistoryList != null){
                inserthislist.addall(tempHistoryList);
            }
            
            upsert inserthislist;
            
            list<Asset_History_custom__c> multipleAssetHistoryList = new list<Asset_History_custom__c>();
            Integer indx = 0;
            for(Asset_History_custom__c ahc : [select id,start_time__c,asset__c,Location__c,Account_ID__c,Timestamp__c,Latitude__c,Longitude__c,End_Time__c,
                                       Still_in_this_Location__c,Api_Response__c  from Asset_History_custom__c 
                                       where asset__c =: ast.id and Still_in_this_Location__c = true order by createddate desc]){    
               if(indx > 0){
                   ahc.Still_in_this_Location__c = false;
                   multipleAssetHistoryList.add(ahc);
               }                   
               indx++;
            }  
            
            if(multipleAssetHistoryList.size()>0 && multipleAssetHistoryList != null){
                update multipleAssetHistoryList;
            }
        } 
    }
    public static void unableToLockRow(asset ast, list<Object> loclist, Map<String, Object> dvcmap){
        Map<String, Object> locmap1=new Map<String, Object>();
        datetime localtime;
        list<location_record_ignored__c> lriList= new list<location_record_ignored__c>();
        Asset_History_custom__c oldhis = new Asset_History_custom__c();
        
        if(ast.id != null){
            for(Asset_History_custom__c ahc : [SELECT id,asset__c,Api_Response__c,start_time__c,Location__c,Account_ID__c,Timestamp__c,Latitude__c,Longitude__c,End_Time__c,Still_in_this_Location__c 
                                               FROM Asset_History_custom__c WHERE Asset__c =: ast.id and Still_in_this_Location__c = true order by createddate desc limit 1]){
                                                   oldhis = ahc;
                                               }
        } 
        
        if(loclist!=null)
            for(object obj : loclist){
                locmap1 = (Map<String,Object>)obj;
                if(locmap1.containsKey('haccRank') && locmap1.get('haccRank') == 0){
                    localtime = utilityts.convertTS((long)locmap1.get('ts'));
                    
                    if(localtime!=null){
                        location_record_ignored__c lri = new location_record_ignored__c();
                        lri.Incoming_Message__c = requestBody;
                        lri.Device_Id__c =  deviceId;
                        lri.Asset__c =   assetId;
                        lri.Account__c = oldhis.Account_ID__c;
                        lri.latitude__c = (decimal)locmap1.get('lat');  
                        lri.longitude__c = (decimal)locmap1.get('lon');
                        lri.Altitude__c = (decimal)locmap1.get('alt');
                        if(locmap1.containskey('calc')){
                            lri.calc__c = (boolean)locmap1.get('calc');
                        }                 
                        lri.rsri__c = (decimal)dvcmap.get('rssi');
                        lri.rsrp__c = (decimal)dvcmap.get('rsrp');
                        lri.rsrq__c = (decimal)dvcmap.get('rsrq');
                        lri.Accuracy__c=(decimal)locmap1.get('hacc');
                        lri.voltage__c=(decimal)dvcmap.get('battery');
                        lri.cellular_signal__c=(decimal)dvcmap.get('signal');
                        lri.hacc__c= (decimal)locmap1.get('hacc');
                        lri.haccRank__c = (integer)locmap1.get('haccRank');
                        lri.pdop__c = (decimal)locmap1.get('pdop');
                        lri.requestTs__c = (long)locmap1.get('requestTs');    
                        lri.ttf__c = (Decimal)locmap1.get('ttf');    
                        lri.Timestamp__c = (long)locmap1.get('ts');  
                        lri.Location_Captured_Time__c =  localTime; // ts to cst
                        lri.Reason__c = 'Unable To Lock Row';
                        
                        if(locmap1.containskey('src')){
                            if((string)locmap1.get('src') == 'w'){
                                lri.src__c = 'wifi';
                            }
                            else if((string)locmap1.get('src') == 'c'){
                                lri.src__c = 'cellular';
                            }
                            else if((string)locmap1.get('src') == 'g'){
                                lri.src__c = 'gps';  
                            }
                        }  
                        lriList.add(lri);
                    }
                }//If End
            }//For end
        insert lriList;
    }
    
}