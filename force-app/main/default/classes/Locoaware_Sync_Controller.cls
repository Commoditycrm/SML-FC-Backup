public class Locoaware_Sync_Controller {

    public static Datetime currentDateTime = System.now().addDays(1);
    public static Asset ast;

    public static void createARCFromSync(API_Response__c ar) {

        if (ar == null || String.isBlank(ar.Incoming_Messsage__c)) {
            return;
        }

        try {

            String requestBody = ar.Incoming_Messsage__c;
            String deviceId = ar.Device_Id__c;

            if (String.isBlank(deviceId)) {
                return;
            }

            ast = createAsset(deviceId);

            if (ast == null) {
                return;
            }

            Map<String, Object> location =
                new Map<String, Object>();

            Map<String, Object> deviceData =
                new Map<String, Object>();

            if (String.isNotBlank(ar.Loc__c)) {
                location = parseMapString(ar.Loc__c);
            }

            if (String.isNotBlank(ar.Device_Status__c)) {
                deviceData = parseMapString(ar.Device_Status__c);
            }

            List<API_Response_Childs__c> locApiResp =
                CreateLocApi(
                    deviceData,
                    location,
                    ar.Location_TimeStamp__c,
                    ar
                );

            if (locApiResp == null || locApiResp.isEmpty()) {
                return;
            }

            if (!Test.isRunningTest()) {

                utilityClass_Controller.createGoogleAPIRecords(
                    locApiResp,
                    deviceId,
                    ast
                );
            }

            try {

                insert locApiResp;

            } catch (DmlException e) {

                for (Integer i = 0; i < e.getNumDml(); i++) {

                    String errorMessage = e.getDmlMessage(i);

                    if (
                        errorMessage != null &&
                        errorMessage.containsIgnoreCase(
                            'duplicate value found: ARC_External_Id__c duplicates value on record with id'
                        )
                    ) {

                        Integer failedIndex = e.getDmlIndex(i);

                        if (
                            failedIndex != null &&
                            failedIndex >= 0 &&
                            failedIndex < locApiResp.size()
                        ) {

                            API_Response_Childs__c failedRecord =
                                locApiResp[failedIndex];

                            failedRecord.Status__c = 'Duplicate';

                            String existingExternalId =
                                failedRecord.ARC_External_Id__c;

                            if (existingExternalId == null) {
                                existingExternalId = '';
                            }

                            failedRecord.ARC_External_Id__c =
                                existingExternalId +
                                '~Duplicate' +
                                String.valueOf(System.now().getTime()) +
                                '~' +
                                String.valueOf(
                                    Integer.valueOf(
                                        Math.random() * 999
                                    )
                                );

                            try {

                                insert failedRecord;

                            } catch (DmlException duplicateException) {

                                RedesignNL_CaptureErrors.createErrorLogs(
                                    duplicateException,
                                    'LocoAware_Sync_Controller',
                                    'Duplicate',
                                    'Exception',
                                    deviceId,
                                    null,
                                    false
                                );
                            }
                        }
                    }
                }
            }

        } catch (Exception ex) {

            RedesignNL_CaptureErrors.createErrorLogs(
                ex,
                'LocoAware_Sync_Controller',
                'createARCFromSync',
                'API Error',
                ar != null ? ar.Device_Id__c : null,
                ar != null ? ar.Incoming_Messsage__c : null,
                false
            );
        }
    }

    public static List<API_Response_Childs__c> CreateLocApi(
        Map<String, Object> devStatus,
        Map<String, Object> locData,
        String devts,
        Api_Response__c resp
    ) {

        List<API_Response_Childs__c> locArc =
            new List<API_Response_Childs__c>();

        if (locData == null) {
            locData = new Map<String, Object>();
        }

        if (devStatus == null) {
            devStatus = new Map<String, Object>();
        }

        if (ast == null || ast.Id == null) {
            return locArc;
        }

        API_Response_Childs__c arc =
            new API_Response_Childs__c();

        arc.Asset__c = ast.Id;

        Map<String, Schema.RecordTypeInfo> recordTypes =
            Schema.SObjectType.API_Response_Childs__c
                .getRecordTypeInfosByName();

        if (
            recordTypes != null &&
            recordTypes.containsKey('Location')
        ) {

            Schema.RecordTypeInfo locationRecordType =
                recordTypes.get('Location');

            if (locationRecordType != null) {

                arc.RecordTypeId =
                    locationRecordType.getRecordTypeId();
            }
        }

        if (
            locData.containsKey('time') &&
            locData.get('time') != null
        ) {

            Decimal locationTimestamp =
                toDecimal(
                    locData.get('time')
                );

            Long locationTimestampLong =
                toLong(
                    locData.get('time')
                );

            if (locationTimestamp != null) {

                arc.Timestamp__c =
                    locationTimestamp;
            }

            if (locationTimestampLong != null) {

                arc.Timestamp_DateTime__c =
                    DateTime.newInstance(
                        locationTimestampLong
                    );
            }
        }

        if (
            locData.containsKey('lat') &&
            locData.get('lat') != null
        ) {

            arc.Latitude__c =
                String.valueOf(
                    locData.get('lat')
                );

            arc.haccRank__c = 0;
        }

        if (
            locData.containsKey('lon') &&
            locData.get('lon') != null
        ) {

            arc.Longitude__c =
                String.valueOf(
                    locData.get('lon')
                );
        }

        if (
            locData.containsKey('cep') &&
            locData.get('cep') != null
        ) {

            arc.Accuracy_meters__c =
                toDecimal(
                    locData.get('cep')
                );
        }

        if (arc.Timestamp__c != null) {

            arc.ARC_External_Id__c =
                String.valueOf(arc.Asset__c) +
                '~' +
                String.valueOf(arc.Timestamp__c) +
                '~Location';
        }
         
        Boolean locationHasTime =
            locData.containsKey('time') &&
            locData.get('time') != null &&
            String.isNotBlank(
                String.valueOf(
                    locData.get('time')
                )
            );

        if (!locationHasTime) {

            if (String.isNotBlank(devts)) {

                Decimal deviceTimestamp =
                    toDecimal(devts);

                Long deviceTimestampLong =
                    toLong(devts);

                if (deviceTimestamp != null) {

                    arc.Timestamp__c =
                        deviceTimestamp;

                    arc.ARC_External_Id__c =
                        String.valueOf(arc.Asset__c) +
                        '~' +
                        String.valueOf(arc.Timestamp__c) +
                        '~dev';
                }

                if (deviceTimestampLong != null) {

                    arc.Timestamp_DateTime__c =
                        DateTime.newInstance(
                            deviceTimestampLong
                        );
                }
            }
        }

        arc.PowerUptime__c = 0;

        if (
            devStatus.containsKey('batteryVoltage') &&
            devStatus.get('batteryVoltage') != null
        ) {

            arc.Battery__c =
                toDecimal(
                    devStatus.get(
                        'batteryVoltage'
                    )
                );
        }

        if (String.isNotBlank(devts)) {

            Decimal deviceStatusTimestamp =
                toDecimal(devts);

            Long deviceStatusTimestampLong =
                toLong(devts);

            if (deviceStatusTimestamp != null) {

                arc.Timestamp_Device_Status__c =
                    deviceStatusTimestamp;
            }

            if (deviceStatusTimestampLong != null) {

                arc.Timestamp_Date_Time_Device_Status__c =
                    DateTime.newInstance(
                        deviceStatusTimestampLong
                    );
            }
        }


        /*
         * =====================================================
         * SIGNAL / RSSI
         * =====================================================
         */
        if (
            devStatus.containsKey('signal') &&
            devStatus.get('signal') != null &&
            ast.Product_Name__c == 'LTP-HGC4-1-0'
        ) {

            Decimal signal =
                toDecimal(
                    devStatus.get('signal')
                );

            if (signal != null) {

                arc.rssi__c =
                    signal * (-1);

                if (arc.rssi__c >= -2) {

                    arc.rssi__c = 0;
                }
            }
        }

        if (
            devStatus.containsKey('batteryLevel') &&
            devStatus.get('batteryLevel') != null
        ) {

            arc.EstBattPct__c =
                toDecimal(
                    devStatus.get(
                        'batteryLevel'
                    )
                );
        }

        if (
            devStatus.containsKey('orientation') &&
            devStatus.get('orientation') != null &&
            devStatus.get('orientation') instanceof Map<String, Object>
        ) {

            Map<String, Object> orientation =
                (Map<String, Object>)
                    devStatus.get('orientation');

            Decimal orientationX =
                toDecimal(
                    orientation.get('x')
                );

            Decimal orientationY =
                toDecimal(
                    orientation.get('y')
                );

            Decimal orientationZ =
                toDecimal(
                    orientation.get('z')
                );

        }
        arc.Status__c = setARCStatus(arc, resp);


        locArc.add(arc);

        return locArc;
    }

    public static String setARCStatus(
        API_Response_Childs__c arc,
        API_Response__c resp
    ) {

        if (arc == null) {
            return 'Pending';
        }

        if (
            utilityTS.futueTs(
                arc.Timestamp_Datetime__c
            )
        ) {

            return 'FutureTS';
        }
        else if (
            arc.Timestamp__c != null &&
            String.valueOf(
                arc.Timestamp__c
            ).startsWith('1104') &&
            arc.PowerUptime__c != null &&
            arc.Latitude__c == null
        ) {

            return 'New';
        }

        else if (
            ast != null &&
            ast.Dormant_Days__c == true &&
            arc.Timestamp_Datetime__c != null &&
            arc.Timestamp_Datetime__c < currentDateTime
        ) {

            if (
                ast.Last_Connected__c != null &&
                ast.Last_Connected__c >
                    arc.Timestamp_Datetime__c
            ) {

                return 'BackdatedTS';
            }

            else {

                if (
                    resp != null &&
                    resp.Status__c != null
                ) {

                    return resp.Status__c
                        .equalsIgnoreCase(
                            'PROCESSED'
                        )
                        ? 'Processed'
                        : 'New';
                }

                return 'New';
            }
        }

        else if (
            ast != null &&
            ast.Dormant_Days__c == false &&
            arc.Timestamp_Datetime__c != null &&
            arc.Timestamp_Datetime__c < currentDateTime
        ) {

            Integer daysDifference =
                currentDateTime
                    .date()
                    .daysBetween(
                        arc.Timestamp_Datetime__c
                            .date()
                    );

            daysDifference =
                Math.abs(
                    daysDifference
                );

            Redesign_NL__mdt redesign =
                RedesignNL_Helper.getRedesignMetadata(
                        'Default'
                    );

            Integer dormantDays = 0;

            if (
                redesign != null &&
                redesign.Dormant_Days__c != null
            ) {

                dormantDays =
                    Integer.valueOf(
                        redesign.Dormant_Days__c
                    );
            }

            if (
                daysDifference >
                dormantDays
            ) {

                return 'BackdatedTS';
            }

            else {

                if (
                    resp != null &&
                    resp.Status__c != null
                ) {

                    return resp.Status__c
                        .equalsIgnoreCase(
                            'PROCESSED'
                        )
                        ? 'Processed'
                        : 'New';
                }

                return 'New';
            }
        }

        else {

            return 'Pending';
        }
    }

    public static Asset createAsset(
        String deviceId
    ) {

        if (String.isBlank(deviceId)) {
            return null;
        }

        Asset assetRecord;

        List<Asset> assetList = [
            SELECT
                Id,
                Device_Id__c,
                Product_Name__c,
                Dormant_Days__c,
                Last_Connected__c
            FROM Asset
            WHERE Device_Id__c = :deviceId
            LIMIT 1
        ];

        if (!assetList.isEmpty()) {

            assetRecord =
                assetList[0];

            return assetRecord;
        }

        List<Account> accList = [
            SELECT Id
            FROM Account
            WHERE Name = 'Testing'
            LIMIT 1
        ];

        if (accList.isEmpty()) {

            return null;
        }

        assetRecord =
            new Asset();

        assetRecord.AccountId =
            accList[0].Id;

        assetRecord.Device_Id__c =
            deviceId;

        assetRecord.Name =
            deviceId;

        assetRecord.AssetProvidedById =
            accList[0].Id;

        assetRecord.Is_Loco_Asset__c =
            true;

        insert assetRecord;

        assetRecord = [
            SELECT
                Id,
                Device_Id__c,
                Product_Name__c,
                Dormant_Days__c,
                Last_Connected__c
            FROM Asset
            WHERE Id = :assetRecord.Id
            LIMIT 1
        ];

        return assetRecord;
    }

    public static Map<String, Object> parseMapString(
        String input
    ) {

        Map<String, Object> result =
            new Map<String, Object>();

        if (String.isBlank(input)) {
            return result;
        }

        String cleaned =
            input.trim();

        if (
            cleaned.startsWith('{')
        ) {

            cleaned =
                cleaned.substring(1);
        }

        if (
            cleaned.endsWith('}')
        ) {

            cleaned =
                cleaned.substring(
                    0,
                    cleaned.length() - 1
                );
        }


        if (String.isBlank(cleaned)) {
            return result;
        }

        List<String> pairs =
            splitTopLevel(cleaned);


        for (String pair : pairs) {

            if (String.isBlank(pair)) {
                continue;
            }

            Integer equalsIndex =
                findTopLevelEquals(pair);

            if (equalsIndex <= 0) {
                continue;
            }


            String key =
                pair.substring(
                    0,
                    equalsIndex
                ).trim();


            String value =
                pair.substring(
                    equalsIndex + 1
                ).trim();


            if (String.isBlank(key)) {
                continue;
            }

            if (
                String.isBlank(value) ||
                value.equalsIgnoreCase(
                    'null'
                )
            ) {

                result.put(
                    key,
                    null
                );

                continue;
            }

            if (
                value.startsWith('{') &&
                value.endsWith('}')
            ) {

                result.put(
                    key,
                    parseMapString(value)
                );

                continue;
            }

            result.put(
                key,
                value
            );
        }


        return result;
    }

    private static List<String> splitTopLevel(
        String input
    ) {

        List<String> result =
            new List<String>();

        if (String.isBlank(input)) {
            return result;
        }


        Integer braceDepth = 0;
        Integer bracketDepth = 0;

        Integer startIndex = 0;


        for (
            Integer i = 0;
            i < input.length();
            i++
        ) {

            String character =
                input.substring(
                    i,
                    i + 1
                );


            if (character == '{') {

                braceDepth++;

            }

            else if (character == '}') {

                braceDepth--;

            }

            else if (character == '[') {

                bracketDepth++;

            }

            else if (character == ']') {

                bracketDepth--;

            }

            else if (
                character == ',' &&
                braceDepth == 0 &&
                bracketDepth == 0
            ) {

                result.add(
                    input.substring(
                        startIndex,
                        i
                    ).trim()
                );

                startIndex =
                    i + 1;
            }
        }

        if (
            startIndex <
            input.length()
        ) {

            result.add(
                input.substring(
                    startIndex
                ).trim()
            );
        }


        return result;
    }

    private static Integer findTopLevelEquals(
        String input
    ) {

        if (String.isBlank(input)) {
            return -1;
        }


        Integer braceDepth = 0;
        Integer bracketDepth = 0;


        for (
            Integer i = 0;
            i < input.length();
            i++
        ) {

            String character =
                input.substring(
                    i,
                    i + 1
                );


            if (character == '{') {

                braceDepth++;

            }

            else if (character == '}') {

                braceDepth--;

            }

            else if (character == '[') {

                bracketDepth++;

            }

            else if (character == ']') {

                bracketDepth--;

            }

            else if (
                character == '=' &&
                braceDepth == 0 &&
                bracketDepth == 0
            ) {

                return i;
            }
        }


        return -1;
    }

    private static Decimal toDecimal(
        Object value
    ) {

        if (value == null) {
            return null;
        }


        String valueString =
            String.valueOf(
                value
            ).trim();


        if (
            String.isBlank(valueString) ||
            valueString.equalsIgnoreCase(
                'null'
            )
        ) {

            return null;
        }


        try {

            return Decimal.valueOf(
                valueString
            );

        }

        catch (Exception ex) {

            return null;
        }
    }

    private static Long toLong(
        Object value
    ) {

        if (value == null) {
            return null;
        }


        String valueString =
            String.valueOf(
                value
            ).trim();


        if (
            String.isBlank(valueString) ||
            valueString.equalsIgnoreCase(
                'null'
            )
        ) {

            return null;
        }


        try {

            Decimal decimalValue =
                Decimal.valueOf(
                    valueString
                );

            return decimalValue.longValue();

        }

        catch (Exception ex) {

            return null;
        }
    }

    private static Boolean toBoolean(
        Object value
    ) {

        if (value == null) {
            return null;
        }


        String valueString =
            String.valueOf(
                value
            ).trim();


        if (
            valueString.equalsIgnoreCase(
                'true'
            )
        ) {

            return true;
        }


        if (
            valueString.equalsIgnoreCase(
                'false'
            )
        ) {

            return false;
        }


        return null;
    }
}