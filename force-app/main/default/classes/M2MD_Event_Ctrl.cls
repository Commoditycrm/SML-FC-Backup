@RestResource(urlMapping='/ProcessM2MDEvents/*')
global class M2MD_Event_Ctrl {

    @HttpPost
    global static String receiveM2MDEvent() {

        String requestBody = RestContext.request.requestBody.toString();

        try {
            Map<String, Object> rootMap =
                (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            Map<String, Object> dataMap =
                (Map<String, Object>) rootMap.get('data');

            if (dataMap == null) return 'Error: missing data node';

            if (dataMap.containsKey('bleScan')) dataMap.remove('bleScan');

            String deviceId = String.valueOf(dataMap.get('id'));
            
            //USED M2MD `tstamp` INSTEAD OF System.now()
             Long ts;
            if (rootMap.get('tstamp') != null) {
                ts = Long.valueOf(String.valueOf(rootMap.get('tstamp')));
            }

            Datetime deviceDateTime =
                ts != null ? Datetime.newInstance(ts) : System.now();

            
            Api_Response__c apires = new Api_Response__c();
            apires.Status__c = 'Chorus-New';
            apires.Device_Id__c = deviceId;
            apires.Incoming_Messsage__c = requestBody;
            apires.ResEnteringDttime__c = System.now();
            apires.ResEnteringTime__c = System.now().getTime() / 1000;

            apires.loc__c = (dataMap.containsKey('location') && dataMap.get('location') != null)
                ? JSON.serialize(dataMap.get('location'))
                : null;

            apires.Location_TimeStamp__c = apires.loc__c == null ? null : ts + '';

            apires.device_status__c = (rootMap.containsKey('data') && rootMap.get('data') != null)
                ? JSON.serialize(rootMap.get('data'))
                : null;

            //apires.Asset__c = ast.Id;


            API_Response_Childs__c arc = createLocAndDevStsRecordFromM2MD(
                requestBody,
                deviceId
            );

            Asset ast = createAsset(deviceId);
            apires.Asset__c = ast.Id;
            insert apires;

            if (arc != null) {
                Api_Response__c apiResponse = [
                    SELECT Id, Name, ResEnteringTime__c, ResEnteringDttime__c, Location_TimeStamp__c
                    FROM Api_Response__c
                    WHERE Id = :apires.Id
                    LIMIT 1
                ];
            arc.ARC_External_Id__c =
                ast.Id + '~' + apiResponse.ResEnteringTime__c + '~M2MD';
            arc.Timestamp__c = apiResponse.Location_TimeStamp__c != null
                ? ts
                : apiResponse.ResEnteringTime__c;
            arc.Timestamp_DateTime__c = apiResponse.Location_TimeStamp__c != null
                ? deviceDateTime : apiResponse.ResEnteringDttime__c;
            arc.Timestamp_Device_Status__c = apiResponse.Location_TimeStamp__c != null || ts != null
                ? ts
                : apiResponse.ResEnteringTime__c;
            arc.Timestamp_Date_Time_Device_Status__c = apiResponse.Location_TimeStamp__c != null || deviceDateTime != null
                ? deviceDateTime : apiResponse.ResEnteringDttime__c;
            arc.Asset__c = ast.Id;            
            arc.API_Response__c = apiResponse.Id; 
            arc.Name = apiResponse.Name + '-Location';
            arc.Status__c = 'Chorus-New';
            
                insert arc;
            }

            return 'Successful!';

        } catch (Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(
                ex, 'M2MD_Event_Ctrl', 'receiveM2MDEvent', 'API Error', null, requestBody, false
            );
            return 'Error: ' + ex.getMessage();
        }
    }

    public static API_Response_Childs__c createLocAndDevStsRecordFromM2MD(
        String requestBody,
        String assetId) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Map<String, Object> data = (Map<String, Object>) root.get('data');
        if (data == null) return null;

        Api_Response_Childs__c arcLocation = new Api_Response_Childs__c();
       List<API_Response_Childs__c> arc = new List<API_Response_Childs__c>();
       arc.add(arcLocation);
        arc[0].RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);

        // rsrp / rsrq
        Map<String, Object> cell = (Map<String, Object>) data.get('cell');
        if (cell != null) {
            Map<String, Object> rsrp = (Map<String, Object>) cell.get('rsrp');
            if (rsrp != null && rsrp.get('val') != null) {
                arc[0].rsrp__c = Decimal.valueOf(String.valueOf(rsrp.get('val')));
            }

            Map<String, Object> rsrq = (Map<String, Object>) cell.get('rsrq');
            if (rsrq != null && rsrq.get('val') != null) {
                arc[0].rsrq__c = Decimal.valueOf(String.valueOf(rsrq.get('val')));
            }
        }

        /*battery (optional)*/
        Map<String, Object> battery = (Map<String, Object>) data.get('battery');
        if (battery != null && battery.get('voltage') != null) {
            arc[0].Battery__c = Decimal.valueOf(String.valueOf(battery.get('voltage')));
        }
        if( battery != null && battery.get('charge') != null) {
            arc[0].EstBattPct__c = Decimal.valueOf(String.valueOf(battery.get('charge')));
        }

         //location (optional)
        Map<String, Object> location = (Map<String, Object>) data.get('location');
        if (location != null) {

          if (location.get('latitude') != null) {
                Decimal rawLat = Decimal.valueOf(String.valueOf(location.get('latitude')));
                Decimal lat = rawLat.divide(10000000, 8); // 8 decimal places (GPS-safe)
                arc[0].Latitude__c = String.valueOf(lat);
            }

            if (location.get('longitude') != null) {
                Decimal rawLon = Decimal.valueOf(String.valueOf(location.get('longitude')));
                Decimal lon = rawLon.divide(10000000, 8);
                arc[0].Longitude__c = String.valueOf(lon);
            }


            if (location.get('horizontalAccuracy') != null) {
                arc[0].Accuracy_meters__c = Decimal.valueOf(String.valueOf(location.get('horizontalAccuracy')));
            }

            if (location.get('source') != null) {
                arc[0].Message_Type__c = String.valueOf(location.get('source'));
            }
            arc[0].haccRank__c = 0;
            
			if(!test.isRunningTest())
            	RedesignNL_Controller.createGoogleAPIRecords(arc, assetId);
        }
        return arc[0];
    }

        public static Asset createAsset(String deviceId){
            Asset ast;
            List<Asset> assetList = [
                SELECT Id
                FROM Asset
                WHERE Device_Id__c = :deviceId
                LIMIT 1
            ];

            if (!assetList.isEmpty()) {
                ast = assetList[0];
            } else {
                List<Account> accList = [
                    SELECT Id
                    FROM Account
                    WHERE Name = 'Testing'
                    LIMIT 1
                ];

                ast = new Asset();
                ast.AccountId    = accList[0].Id;
                ast.Device_Id__c = deviceId;
                ast.Name         = deviceId;
                ast.Is_M2MD__c  = true;
                insert ast;
            }
            return ast;
        }

}