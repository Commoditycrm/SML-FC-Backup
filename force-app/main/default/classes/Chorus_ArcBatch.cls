global class Chorus_ArcBatch implements Database.Batchable<sObject>,
                                       Database.Stateful,
                                       Database.AllowsCallouts {

    // ======================= ERROR BUFFER =======================

    private List<ErrorBuffer> bufferedErrors = new List<ErrorBuffer>();

    private class ErrorBuffer {
        public Exception ex;
        public String className;
        public String methodName;
        public String typeName;
        public String deviceId;
        public String payload;
        public Boolean sendEmail;

        public ErrorBuffer(
            Exception ex,
            String className,
            String methodName,
            String typeName,
            String deviceId,
            String payload,
            Boolean sendEmail
        ) {
            this.ex = ex;
            this.className = className;
            this.methodName = methodName;
            this.typeName = typeName;
            this.deviceId = deviceId;
            this.payload = payload;
            this.sendEmail = sendEmail;
        }
    }

    private void bufferError(
        Exception ex,
        String className,
        String methodName,
        String typeName,
        String deviceId,
        String payload,
        Boolean sendEmail
    ) {
        bufferedErrors.add(
            new ErrorBuffer(ex, className, methodName, typeName, deviceId, payload, sendEmail)
        );
    }

    private void flushBufferedErrors() {
        if (bufferedErrors.isEmpty()) return;

        for (ErrorBuffer err : bufferedErrors) {
            try {
                RedesignNL_CaptureErrors.createErrorLogs(err.ex, err.className, err.methodName, err.typeName, err.deviceId, err.payload, err.sendEmail);
            } catch (Exception ignoreEx) {
            }
        }
        bufferedErrors.clear();
    }

    // ======================= START =======================

    global Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            return Database.getQueryLocator([
                SELECT Id,
                       Name,
                       Status__c,
                       Device_Id__c,
                       Incoming_Messsage__c,
                       Location_TimeStamp__c,
                       Asset__c
                FROM Api_Response__c
                WHERE Status__c = 'Chorus-New'
                  AND Asset__r.Is_Chorus_Asset__c = true
                ORDER BY Location_TimeStamp__c ASC
            ]);
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_ArcBatch', 'start', 'Exception', null, null, true);
            return Database.getQueryLocator([SELECT Id FROM Api_Response__c WHERE Id = null]);
        }
    }

    // ======================= EXECUTE =======================

    global void execute(Database.BatchableContext bc, List<Api_Response__c> scope) {
        if (scope == null || scope.isEmpty()) return;

        Datetime currentDateTime = Datetime.now();
        Redesign_NL__mdt redesignMeta;

        try {
            redesignMeta = RedesignNL_Helper.getRedesignMetadata('Default');
        } catch (Exception e) {
            bufferError(e, 'Chorus_ArcBatch', 'execute', 'Exception', null, null, true);
            flushBufferedErrors();
            return;
        }

        // ----- 1) Parse JSON + collect parent/asset ids -----
        Map<Id, Api_Response__c> parentsById = new Map<Id, Api_Response__c>(scope);
        Map<Id, Map<String, Object>> dpByParentId = new Map<Id, Map<String, Object>>();
        Set<Id> assetIds = new Set<Id>();

        for (Api_Response__c parent : scope) {
            try {
                if (parent == null || String.isBlank(parent.Incoming_Messsage__c)) continue;

                Map<String, Object> dp =
                    (Map<String, Object>) JSON.deserializeUntyped(parent.Incoming_Messsage__c);

                dpByParentId.put(parent.Id, dp);

                if (parent.Asset__c != null) assetIds.add(parent.Asset__c);
            } catch (Exception e) {
                bufferError(e, 'Chorus_ArcBatch', 'execute - JSON parse', 'Exception', null, null, true);
            }
        }

        if (dpByParentId.isEmpty() || assetIds.isEmpty()) {
            flushBufferedErrors();
            return;
        }

        // ----- 2) Bulk-load Assets used in this scope -----
        Map<Id, Asset> assetsById = new Map<Id, Asset>();
        try {
            for (Asset a : [
                SELECT Id, Name, Device_Id__c, Dormant_Days__c, Last_Connected__c
                FROM Asset
                WHERE Id IN :assetIds
            ]) {
                assetsById.put(a.Id, a);
            }
        } catch (Exception e) {
            bufferError(e, 'Chorus_ArcBatch', 'execute - load assets', 'Exception', null, null, true);
            flushBufferedErrors();
            return;
        }

        // ----- 3) Build ARCs (temperature + location/status) -----
        List<API_Response_Childs__c> arcs = new List<API_Response_Childs__c>();
        Map<Id, List<API_Response_Childs__c>> locArcsByAsset = new Map<Id, List<API_Response_Childs__c>>();

        for (Api_Response__c parent : scope) {
            Asset ast = null;
            String assetDeviceId = null;

            try {
                Map<String, Object> dp = dpByParentId.get(parent.Id);
                if (dp == null) continue;

                ast = assetsById.get(parent.Asset__c);
                if (ast == null) continue;
                assetDeviceId = ast.Device_Id__c;

                String recordTimeIso = (String) dp.get('recordTime');
                String serverTimeIso = (String) dp.get('serverProcessingTime');
                Boolean isMoving = (Boolean) dp.get('isMoving');

                Map<String, Object> agg = (Map<String, Object>) dp.get('aggregatorDetails');
                Map<String, Object> battery = (Map<String, Object>) dp.get('battery');
                Map<String, Object> temp = (Map<String, Object>) dp.get('temperature');
                Map<String, Object> loc = (Map<String, Object>) dp.get('ownLocation');
                Map<String, Object> humidity = (Map<String, Object>) dp.get('humidity');

                Datetime recordDt = parseIso(recordTimeIso);
                Decimal tsDecimal = (recordDt != null)
                    ? Decimal.valueOf(recordDt.getTime() / 1000)
                    : null;

                Datetime serverDt = parseIso(serverTimeIso);
                Decimal serverTsDec = (serverDt != null)
                    ? Decimal.valueOf(serverDt.getTime() / 1000)
                    : null;

                if ((temp != null && temp.containsKey('temperatureCelsiusMilli')) ||
                    (humidity != null && humidity.containsKey('humidityPercentMilli'))) {

                    API_Response_Childs__c tempArc = createTemperatureArc(
                        temp,
                        humidity,
                        ast,
                        recordDt,
                        tsDecimal
                    );

                    if (tempArc != null) {
                        tempArc.API_Response__c = parent.Id;
                        arcs.add(tempArc);
                    }
                }

                if (agg != null || battery != null || loc != null) {
                    API_Response_Childs__c locStatusArc = createLocationAndStatusArc(
                        agg,
                        loc,
                        battery,
                        isMoving,
                        ast,
                        recordDt,
                        tsDecimal,
                        serverDt,
                        serverTsDec,
                        locArcsByAsset
                    );

                    if (locStatusArc != null) {
                        locStatusArc.API_Response__c = parent.Id;
                        arcs.add(locStatusArc);
                    }
                }

            } catch (Exception e) {
                bufferError(e,'Chorus_ArcBatch','execute - ARC creation','Exception',assetDeviceId,null,true);
            }
        }

        // ----- 4) Google Address resolution (bulk per asset) -----
            for (Id assetId : locArcsByAsset.keySet()) {
                Asset a = assetsById.get(assetId);
                if (a == null) continue;

                List<API_Response_Childs__c> locList = locArcsByAsset.get(assetId);
                if (locList == null || locList.isEmpty()) continue;

                try {
                    if (!Test.isRunningTest()) {
                        createGoogleAPIRecords(locList, a.Device_Id__c);
                    }
                } catch (Exception e) {
                    bufferError(e,'Chorus_ArcBatch','execute - Google API','Exception',(a != null ? a.Device_Id__c : null),null,true);
                }
            }

        // IMPORTANT: flush error logs only AFTER callouts are complete
        flushBufferedErrors();

        if (arcs.isEmpty()) return;

        // ----- 5) Set Name + Status__c on ARCs, dedupe based on Asset + TS + RT -----
        Set<String> dedup = new Set<String>();

        for (API_Response_Childs__c arc : arcs) {
            try {
                Api_Response__c parentMatch = parentsById.get(arc.API_Response__c);

                if (parentMatch != null) {
                    RecordTypeInfo rti = null;
                    if (arc.RecordTypeId != null) {
                        rti = Schema.SObjectType.API_Response_Childs__c
                            .getRecordTypeInfosById()
                            .get(arc.RecordTypeId);
                    }
                    String rtDeveloperName = (rti != null) ? rti.getDeveloperName() : 'UnknownType';
                    arc.Name = parentMatch.Name + '-' + rtDeveloperName;
                }

                String key = arc.Asset__c + '~' + arc.Timestamp__c + '~' + arc.RecordTypeId;
                if (dedup.contains(key)) {
                    arc.Status__c = 'Duplicate';
                } else {
                    dedup.add(key);

                    Asset assetForArc = assetsById.get(arc.Asset__c);
                    arc.Status__c = getArcStatus(
                        arc,
                        parentMatch,
                        assetForArc,
                        currentDateTime,
                        redesignMeta
                    );
                }
            } catch (Exception e) {
                Asset a = assetsById.get(arc.Asset__c);
                bufferError(e,'Chorus_ArcBatch','execute - status/name','Exception',(a != null ? a.Device_Id__c : null),null,true);
            }
        }

        // Safe to flush here too, before DML block if needed
        flushBufferedErrors();

        // ----- 6) Insert ARCs + handle duplicate ARC_External_Id__c -----
        try {
            insert arcs;
        } catch (DmlException e) {
            List<API_Response_Childs__c> duplicatesToInsert = new List<API_Response_Childs__c>();

            for (Integer i = 0; i < e.getNumDml(); i++) {
                if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c') || Test.IsRunningTest()) {
                    API_Response_Childs__c failed = arcs[e.getDmlIndex(i)];
                    failed.Status__c = 'Duplicate';
                    failed.ARC_External_Id__c += '~Duplicate' + System.now().getTime();
                    duplicatesToInsert.add(failed);
                }
            }

            if (!duplicatesToInsert.isEmpty()) {
                try {
                    insert duplicatesToInsert;
                } catch (Exception ex) {
                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'Chorus_ArcBatch', 'execute - duplicate ARC insert', 'Exception', null, null, true);
                }
            }
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_ArcBatch', 'execute - ARC insert', 'Exception', null, null, true);
        }
    }

    // ======================= FINISH (CHAIN) =======================

    global void finish(Database.BatchableContext bc) {
               Database.executeBatch(new Chorus_AhcBatch(), 10);
    }

    // ======================= HELPERS =======================

    private static Datetime parseIso(String iso) {
        if (String.isBlank(iso)) return null;
        try {
            return (Datetime) JSON.deserialize('"' + iso + '"', Datetime.class);
        } catch (Exception e) {
            System.debug('parseIso failed for ' + iso + ': ' + e.getMessage());
            return null;
        }
    }

    private static API_Response_Childs__c createTemperatureArc(
        Map<String, Object> temp,
        Map<String, Object> humidity,
        Asset ast,
        Datetime recordDt,
        Decimal tsDecimal
    ) {
        Decimal tempMilliC = null;
        Decimal humidityMilliPercent = null;

        if (temp != null && temp.containsKey('temperatureCelsiusMilli')) {
            tempMilliC = (Decimal) temp.get('temperatureCelsiusMilli');
        }
        if (humidity != null && humidity.containsKey('humidityPercentMilli')) {
            humidityMilliPercent = (Decimal) humidity.get('humidityPercentMilli');
        }

        if (tempMilliC == null && humidityMilliPercent == null) return null;

        API_Response_Childs__c arcTemp = new API_Response_Childs__c();
        arcTemp.Asset__c = ast.Id;
        arcTemp.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(
            RedesignNL_Helper.ArcTemperatureRecordtype
        );

        arcTemp.Temperature__c = (tempMilliC != null)
            ? (tempMilliC / 1000) * 9/5 + 32
            : null;

        arcTemp.Relative_Humidity__c = (humidityMilliPercent != null)
            ? (humidityMilliPercent / 1000)
            : null;

        arcTemp.Timestamp__c = tsDecimal;
        arcTemp.Timestamp_DateTime__c = recordDt;
        arcTemp.ARC_External_Id__c =
            ast.Id + '~' + String.valueOf(tsDecimal) + '~Temp';

        return arcTemp;
    }

    private static API_Response_Childs__c createLocationAndStatusArc(
        Map<String, Object> agg,
        Map<String, Object> loc,
        Map<String, Object> battery,
        Boolean isMoving,
        Asset ast,
        Datetime recordDt,
        Decimal recordTsDecimal,
        Datetime serverDt,
        Decimal serverTsDecimal,
        Map<Id, List<API_Response_Childs__c>> locArcsByAsset
    ) {
        Map<String, Object> agLoc = null;
        Map<String, Object> point = null;
        Boolean hasLocation = false;

        Decimal lat = null;
        Decimal lon = null;
        Decimal accuracyM = null;

        Datetime locDt = null;
        Decimal locTsDecimal = null;

        if (loc != null && loc.containsKey('point')) {
            agLoc = loc;
            point = (Map<String, Object>) agLoc.get('point');
        } else if (agg != null && agg.containsKey('aggregatorLocation')) {
            agLoc = (Map<String, Object>) agg.get('aggregatorLocation');
            if (agLoc != null) point = (Map<String, Object>) agLoc.get('point');
        }

        if (point != null) {
            Decimal latMicro = (Decimal) point.get('latitudeMicro');
            Decimal lonMicro = (Decimal) point.get('longitudeMicro');

            lat = (latMicro == null ? null : latMicro / 1000000);
            lon = (lonMicro == null ? null : lonMicro / 1000000);

            Decimal accuracyCm = (agLoc != null) ? (Decimal) agLoc.get('accuracyCm') : null;
            accuracyM = (accuracyCm == null ? null : accuracyCm / 100);

            locDt = recordDt;
            if (locDt != null) {
                locTsDecimal = Decimal.valueOf(locDt.getTime() / 1000);
            }
            hasLocation = true;
        }

        if (!hasLocation) {
            locDt = (recordDt != null ? recordDt : serverDt);
            locTsDecimal = (recordTsDecimal != null ? recordTsDecimal : serverTsDecimal);
        }

        API_Response_Childs__c locArc = new API_Response_Childs__c();
        locArc.Asset__c = ast.Id;
        locArc.RecordTypeId = Schema.SObjectType.API_Response_Childs__c
            .getRecordTypeInfosByName()
            .get('Location')
            .getRecordTypeId();

        if (hasLocation) {
            locArc.Latitude__c = (lat != null ? String.valueOf(lat) : null);
            locArc.Longitude__c = (lon != null ? String.valueOf(lon) : null);
            locArc.Accuracy_meters__c = accuracyM;
            locArc.Message_Type__c = agLoc != null && agLoc.containsKey('source') ? String.valueOf(agLoc.get('source')) : null;
            locArc.haccRank__c = 0;
        }

        if (agg != null && agg.containsKey('aggregatorDeviceId')) {
            locArc.Facility_Location__c = (String) agg.get('aggregatorDeviceId');
        }

        if (battery != null) {
            if (battery.containsKey('batteryVoltMilli') && battery.get('batteryVoltMilli') != null) {
                Decimal mv = (Decimal) battery.get('batteryVoltMilli');
                locArc.Battery__c = (mv != null ? mv / 1000 : null);
            }
            if (battery.containsKey('batterySocPercent') && battery.get('batterySocPercent') != null) {
                locArc.EstBattPct__c = (Decimal) battery.get('batterySocPercent');
            } else {
                locArc.EstBattPct__c = null;
            }
        }

        if (agg != null && agg.containsKey('rssiDbm')) {
            locArc.rssi__c = (Decimal) agg.get('rssiDbm');
        }

        locArc.Timestamp__c = locTsDecimal;
        locArc.Timestamp_DateTime__c = locDt;
        locArc.Timestamp_Device_Status__c = (locTsDecimal != null ? locTsDecimal : serverTsDecimal);
        locArc.Timestamp_Date_Time_Device_Status__c = (locDt != null ? locDt : serverDt);
        locArc.PowerUptime__c = 0;

        locArc.ARC_External_Id__c =
            ast.Id + '~' + String.valueOf(locTsDecimal) + '~Location';

        if (!locArcsByAsset.containsKey(ast.Id)) {
            locArcsByAsset.put(ast.Id, new List<API_Response_Childs__c>());
        }
        locArcsByAsset.get(ast.Id).add(locArc);

        return locArc;
    }

    public static void createGoogleAPIRecords(List<API_Response_Childs__c> locApiResp, String deviceId){
        List<List<String>> googleErrorLogsToInsert = new List<List<String>>();
        List<String> IncludeList = RedesignNL_Helper.getIncludeList();
        List<String> excludeList = RedesignNL_Helper.getexludeList();
        integer APIcount= 0;
        Map<integer,List<string>> ApidebugLogMap = New Map<integer,List<string>>();
        Map<id,Google_Api_Data__c> gadInsertMap = new Map<id,Google_Api_Data__c>();
        List<Google_API_Data__c> GADlistToInsert = new List<Google_API_Data__c>();
        List<Batch_Data_Custom__c> skippedCalloutLogs = new List<Batch_Data_Custom__c>();
        Set<String> skippedLatLonSet = new Set<String>();
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
                Boolean isGeofenceFound = RedesignNL_Controller.checkGeofence(accountId, loc);
                /*if (isGeofenceFound == true) {
                    addSkippedCalloutLog(skippedCalloutLogs, skippedLatLonSet, loc.Latitude__c, loc.Longitude__c, deviceId, null, loc.timestamp_DateTime__c);
                }*/
                if(isGeofenceFound == false) { 
                    system.debug('geofence found: false');
                    string latfull = loc.Latitude__c;
                    string lngfull = loc.Longitude__c;
                    String lat = loc.Latitude__c.left(6);
                    String lon = loc.Longitude__c.left(6);
                    if( lat !='0' && lon !='0'){
                        if(latLonMap == null || !latLonMap.containsKey(lat) || (latLonMap != null & latLonMap.containsKey(lat) & !latLonMap.get(lat).contains(lon))) {
                            List<Google_API_Data__c> GADlist = [select id,Current_City__c,Current_State__c,Current_Address__c,Current_country__c,Current_Street_Address__c,Business_Name__c,Business_Place_Id__c,Business_Location__Longitude__s,Business_Location__Latitude__s,Captured_Business_Name__c,Likely_Business_Name_Types__c,
                                                                Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                                where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lon+'%'  order by createddate desc limit 1];
                            system.debug('###--GADlist--'+ GADlist);
                            if(GADlist== null || GADlist.isEmpty()){
                                Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=latfull, Longitude__c=lngfull);
                                if(RedesignNl_Controller.RedesignMetadata.Capture_Business_Name__c == True && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True ){
                                    List<string> debuglogs=new List<string>();
                                    //debuglogs = RedesignNl_Controller.getBusinessName(deviceId, latfull, lngfull, gadRec, loc, IncludeList, excludeList);
                                    if(RedesignNl_Controller.RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                        APIcount = APIcount+1;
                                        ApidebugLogMap.put(APIcount,debuglogs);
                                    }
                                    //getBusinessName(deviceId, latfull, lngfull, gadRec, loc, IncludeList, excludeList);
                                }
                                if (RedesignNl_Controller.RedesignMetadata.Redesign_Api_Response_Toggle__c == true) {
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
                                       /* if(RedesignNl_Controller.RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                            List<String> apidebuglogs = new List<String>{ 'RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), String.valueof(Decimal.valueOf(res.getStatusCode())), res.getStatus(), deviceId, lat, lon, 'Address API callout count record','Count'};
                                                APIcount = APIcount+1;
                                            ApidebugLogMap.put(APIcount,apidebuglogs);
                                        }*/
                                        Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        system.debug('result1: ' + results1);
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
                                            gadRec.Vendor__c = loc.Asset__r.Is_M2MD__c ? 'M2MD': 'Chorus';
                                            
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
                                        googleErrorLogsToInsert.add(new List<String>{
                                            'RedesignNL_Controller','createGoogleAPIRecords',res.getBody(),String.valueOf(res.getStatusCode()),res.getStatus(),deviceId,lat,lon,'Address Callout API Error log','Error'
                                        });
                                        //RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), String.valueof(Decimal.valueOf(res.getStatusCode())), res.getStatus(), deviceId, lat, lon, 'Address Callout API Error log','Error');            
                                        loc.Location__c = 'In Transit';
                                        loc.Current_Location_Address__c = 'Address Pending';
                                        loc.Status__c = 'Google Api Error';
                                    }
                                }
                                else{
                                    googleErrorLogsToInsert.add(new List<String>{'RedesignNL_Controller','createGoogleAPIRecords','Redesign 3.0 Toggle False - But Address Pending',null,null,deviceId,lat,lon,'No callout Error log','Error'});
                                    //RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', 'Redesign 3.0 Toggle False - But Address Pending', null, null, deviceId, lat, lon, 'No callout Error log', 'Error');
                                    loc.Location__c = 'In Transit';
                                    loc.Current_Location_Address__c = 'Address Pending';
                                    loc.Status__c = 'Google Api Error';
                                }
                            }
                            else {
                                addSkippedCalloutLog( skippedCalloutLogs, skippedLatLonSet, latfull, lngfull, deviceId, GADlist[0], loc.timestamp_DateTime__c);
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
                                else if(RedesignNl_Controller.RedesignMetadata.Capture_Business_Name__c == True && RedesignNl_Controller.RedesignMetadata.Capture_BuiName_for_OldRec__c == true && GADlist[0].Business_Name__c == null && GADlist[0].Captured_Business_Name__c == False && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True){
                                    List<string> debuglist = New List<string>();
                                    //debuglist = RedesignNl_Controller.getBusinessName(deviceId, latfull, lngfull, GADlist[0], loc, IncludeList, excludeList);
                                    /*if(RedesignNl_Controller.RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
                                        APIcount = APIcount+1;
                                        ApidebugLogMap.put(APIcount,debuglist);
                                    }*/
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
                            //addSkippedCalloutLog(skippedCalloutLogs, skippedLatLonSet, latfull, lngfull);
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
        if (!skippedCalloutLogs.isEmpty()) {
            insert skippedCalloutLogs;
        }
        if (!googleErrorLogsToInsert.isEmpty()) {
            for (List<String> logRow : googleErrorLogsToInsert) {
                RedesignNL_CaptureErrors.createGoogleErrorLogs(logRow[0],logRow[1],logRow[2],logRow[3],logRow[4],logRow[5],logRow[6],logRow[7],logRow[8],logRow[9]);
            }
        }
        
        /*if(APIcount>0 && RedesignNl_Controller.RedesignMetadata.Capture_Google_API_callout_debuglogs__c){
            for(integer key :ApidebugLogMap.keyset()){
                List<string> debuglist = new List<string>();
                debuglist =ApidebugLogMap.get(key);
                RedesignNL_CaptureErrors.createGoogleErrorLogs(debuglist[0], debuglist[1], debuglist[2], debuglist[3], debuglist[4], debuglist[5], debuglist[6], debuglist[7], debuglist[8],debuglist[9]);
                
            }
        }*/
    }

    private static void addSkippedCalloutLog(
        List<Batch_Data_Custom__c> skippedCalloutLogs,
        Set<String> skippedLatLonSet,
        String latfull,
        String lngfull,
        String deviceId,
        Google_API_Data__c gadRec,
        Datetime responseDateTime
    ) {
        try{
            if (String.isBlank(latfull) || String.isBlank(lngfull)) return;
    
            String skippedLatLon = latfull + ',' + lngfull;
        
            if (!skippedLatLonSet.contains(skippedLatLon)) {
                skippedLatLonSet.add(skippedLatLon);
        
                if (skippedCalloutLogs.isEmpty()) {
                    skippedCalloutLogs.add(new Batch_Data_Custom__c(
                        Batch_Name__c = 'Skipped Callout',
                        Skipped_Lat_Long__c = skippedLatLon,
                        Device_Id__c = deviceId,
                        Google_API_Data__c = gadRec != null ? gadRec.Id : null,
                        Response_Date_Time__c = responseDateTime
                    ));
                } else {
                    Batch_Data_Custom__c logRec = skippedCalloutLogs[0];
                    logRec.Skipped_Lat_Long__c = String.isBlank(logRec.Skipped_Lat_Long__c) ? skippedLatLon : logRec.Skipped_Lat_Long__c + '\n' + skippedLatLon;
                    logRec.Device_Id__c = String.isBlank(logRec.Device_Id__c) ? deviceId : logRec.Device_Id__c + '\n' + deviceId;
                    logRec.Google_API_Data__c = gadRec != null ? gadRec.Id : null;
                    logRec.Response_Date_Time__c = responseDateTime;
                }
            }
        }catch(Exception e){
            System.debug('addSkippedCalloutLog error: ' + e.getMessage());
           //RedesignNL_CaptureErrors.createErrorLogs(e,'Chorus_ArcBatch','addSkippedCalloutLog','Exception',deviceId,null,true);
        }
    }

    private static String getArcStatus(
        API_Response_Childs__c arc,
        Api_Response__c resp,
        Asset ast,
        Datetime currentDateTime,
        Redesign_NL__mdt redesignMeta
    ) {
        try {
            if (arc == null || ast == null || arc.Timestamp_DateTime__c == null) return 'Pending';

            if (utilityTS.futueTs(arc.Timestamp_DateTime__c)) {
                return 'FutureTS';
            }
            else if (ast.Dormant_Days__c == true && arc.Timestamp_DateTime__c < currentDateTime) {
                if (ast.Last_Connected__c != null && ast.Last_Connected__c > arc.Timestamp_DateTime__c) {
                    return 'BackdatedTS';
                } else {
                    if (resp != null && resp.Status__c != null) {
                        return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed' : 'Chorus-New';
                    }
                    return 'Chorus-New';
                }
            }
            else if (ast.Dormant_Days__c == false && arc.Timestamp_DateTime__c < currentDateTime) {

            Long diffMillis = currentDateTime.getTime() - arc.Timestamp_DateTime__c.getTime();
            Decimal diffHours = diffMillis / (1000.0 * 60 * 60);

            if (diffHours > 1) {
                return 'BackdatedTS';
                 } else {
                    if (resp != null && resp.Status__c != null) {
                        return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed' : 'Chorus-New';
                    }
                    return 'Chorus-New';
                }
            }
            else {
                return 'Pending';
            }
        } catch (Exception e) {
            System.debug('getArcStatus error: ' + e.getMessage());
            return 'Pending';
        }
    }
}