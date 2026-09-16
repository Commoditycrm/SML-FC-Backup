global class Chorus_AhcBatch implements Database.Batchable<SObject>, Database.Stateful {

public List<API_Response__c> apiRespRecList;
public static String lastKnownLocation;
public static String lastKnownId;
public static DateTime lastKnownTime;
public static String lastKnownCurrLocationAddress;
public static String lastKnownStreet;
public static String lastKnownCity;
public static String lastKnownState;
public static String lastKnownZip;
public static String lastKnownCountry;
public static Decimal lastKnownLat;
public static Decimal lastKnownLon;
public  Set<ID> AssetIDSet = New Set<ID>();
// -----------------------------
// START
// -----------------------------
global Database.QueryLocator start(Database.BatchableContext bc) {
    apiRespRecList = [
        SELECT Id, Name, Asset__c, Status__c, CreatedDate
        FROM API_Response__c
        WHERE (Asset__r.Is_Chorus_Asset__c = true OR Asset__r.Is_M2MD__c = true)
            AND Asset__r.Pause_Job__c = false
            AND Status__c = 'Chorus-New'
        ORDER BY CreatedDate ASC
    ];
    //Set<ID> AssetIDSet = New Set<ID>();
        For(API_Response__c ar : apiRespRecList) {
            AssetIDSet.add(ar.Asset__c);
        }
        
    String query = 'SELECT Id, Name, Facility_Location__c, Last_KNown_Location__c,src__c, Current_Location__c,Latest_Location_AHC__c,Business_Name__c, Business_Location__Longitude__s,Business_Location__Latitude__s,Business_Place_Id__c,'+
            'CreatedDate, Latest_Location_AHC__r.End_Time__c, Current_Location__r.Name, estBattPct__c, Last_Synced_Timestamp__c, '+
            'Power_Reset_Occurred__c, Power_Reset_Time__c, Current_Address__c,Current_City__c ,Current_State__c, Current_Street_Address__c, Current_Zip_Code__c ,Current_country__c,'+
            'Accuracy_meters__c,PowerUp_Time__c,Signal__c,  Temporary_Latitude__c,  Temporary_Longitude__c, Humidity__c,'+ 
            'Start_Time__c, C__c,Temperature__c, rssi__c, device_Id__c, Date_Shipped__c, Last_Connected_Map__c,Account_to_Update__c, '+
            'rsrp__c, rsrq__c, Battery_Voltage__c,Last_Connected2__c,Current_Location_Address__c,LocationId,Battery_Replaced_Date__c,'+
            'Last_Connected__c,State_of_Pallet__c, Product_Name__c, Action_Needed__c, est_Batterycalculate__c From '+
                'Asset WHERE Id in: AssetIDSet';
            ///'Asset where Name =\'at5-t197010c2fe7\'';
    return Database.getQueryLocator(query);
}

// -----------------------------
// EXECUTE
// -----------------------------
global void execute(Database.BatchableContext bc, List<Asset> scope) {

    Map<Id, Api_Response_Childs__c> arcToUpdate = new Map<Id, Api_Response_Childs__c>();
    Map<Id, API_Response__c> apiToUpdateMap = new Map<Id, API_Response__c>();
    Map<Id, Asset> assetsToUpdateMap = new Map<Id, Asset>();
    List<Asset_History_Custom__c> ahcToInsert = new List<Asset_History_Custom__c>();
    List<Asset_History_Custom__c> ahcToUpdate = new List<Asset_History_Custom__c>();
    List<Asset_History_Custom__c> tempAhcToInsert = new List<Asset_History_Custom__c>();
    Map<Id, Asset_History_Custom__c> dwellUpdateAssetIds = new Map<Id, Asset_History_Custom__c>();

    String recTypeId;
    try {
        recTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
    } catch (Exception e) {
        recTypeId = null;
        RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'execute', 'RecType Exception', null, null, true);
    }

    for (Asset ast : scope) {
        lastKnownLocation = null;
        lastKnownId = null;
        lastKnownTime = null;
        lastKnownCurrLocationAddress = null;
        lastKnownStreet = null;
        lastKnownCity = null;
        lastKnownState = null;
        lastKnownZip = null;
        lastKnownCountry = null;
        lastKnownLat = null;
        lastKnownLon = null;
        Map<String, Datetime> resultTS;
        try {
            resultTS = DeleteExistingRecords(ast);
            System.debug('DeleteExistingRecords completed for: ' + ast.Name);
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'DeleteExistingRecords', 'Exception', ast.Device_Id__c, null, true);
            continue;
        }

        if (resultTS == null) {
            resultTS = new Map<String, Datetime>();
        }

        if (resultTS.get('Starttime') == null) {
            System.debug('No valid location response Starttime found for asset: ' + ast.Name + '. Skipping AHC processing for this asset.');
            continue;
        }

        Asset_History_Custom__c openAhc = null;

        List<Asset_History_Custom__c> ahcList = [
            SELECT Id, Asset__c, Still_in_this_Location__c, currentLocationId__c, Current_Location__c,
                   Current_Location__r.Name, Location__c, Current_Location_Address__c,
                   Current_Street_Address__c, Current_City__c, Current_State__c,
                   Current_Zipcode__c, Current_country__c, Latitude__c, Longitude__c,
                   Facility_Location__c, Message_Type__c, Device_Status_Time__c,
                   Accuracy_meters__c, Battery_Voltage__c, estBattPct__c,
                   Est_Remaining_Battery__c, rssi__c, rsrp__c, rsrq__c,
                   Temperature__c, Relative_Humidity__c, Latest_API_Response_Child__c,
                   Start_Time__c, End_Time__c, Last_Known_Location__c,
                   Last_Known_Location_Lookup__c
            FROM Asset_History_Custom__c
            WHERE Asset__c = :ast.Id
            AND Still_in_this_Location__c = true
            ORDER BY End_Time__c DESC, Start_Time__c DESC
            LIMIT 1
        ];

        if (!ahcList.isEmpty()) {
            openAhc = ahcList[0];
        }

        List<Api_Response_Childs__c> arcAll = [
            SELECT Id, Asset__c, Status__c,
                   Timestamp_DateTime__c,
                   currentLocationId__c,
                   Location__c,
                   Battery__c, EstBattPct__c,
                   Timestamp_Date_Time_Device_Status__c,
                   rssi__c, rsrp__c, rsrq__c, Accuracy_Meters__c,
                   Asset__r.Capture_Temperature_Response__c,
                   Latitude__c, Longitude__c,
                   Facility_Location__c, Message_Type__c,
                   Temperature__c, Relative_Humidity__c,
                   Current_Location_Address__c,
                   Current_Country__c, Current_State__c, Current_City__c,
                   Current_Street_Address__c, Current_Zipcode__c
            FROM Api_Response_Childs__c
            WHERE Asset__c = :ast.Id
            AND Status__c NOT IN ('Google Api Error', 'FutureTS', 'BackdatedTS', 'Pending', 'Duplicate')
            AND Timestamp_DateTime__c != null
            AND Timestamp_DateTime__c >= :resultTS.get('Starttime')
            AND RecordType.DeveloperName = 'Location'
            ORDER BY Timestamp_DateTime__c ASC
        ];

        System.debug('arcAll size: ' + arcAll.size() + ' for Asset: ' + ast.Name);

        for (API_Response__c ar : apiRespRecList) {
            if (ar == null || ar.Id == null) continue;
            if (ar.Asset__c != ast.Id) continue;
            ar.Status__c = 'Processed';
            apiToUpdateMap.put(ar.Id, ar);
        }

        List<assetHistory> segments;

        try {
            segments = createWrapperRecords(arcAll, tempAhcToInsert);
            alignFirstSegmentStartToLatestExistingEnd(ast.Id, segments);
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'createWrapperRecords', 'Exception', ast.Device_Id__c, null, true);
            continue;
        }

        if (arcAll.isEmpty()) {
            System.debug('No Location ARC found for asset: ' + ast.Name);
        }

        Asset_History_Custom__c finalOpen;
        try {
            finalOpen = createOrUpdateAhcRecords_NoDml(
                segments,
                openAhc,
                ast.Id,
                recTypeId,
                ahcToInsert,
                ahcToUpdate,
                dwellUpdateAssetIds
            );
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'createOrUpdateAhcRecords', 'Exception', ast.Device_Id__c, null, true);
            continue;
        }

        if (finalOpen == null && openAhc != null) {
            finalOpen = openAhc;
        }

        if (finalOpen != null) {
            //ast.Last_Synced_Timestamp__c = System.now();
            updateAssetSummary(ast, finalOpen);
            assetsToUpdateMap.put(ast.Id, ast);
        } else {
            System.debug('Asset not updated because finalOpen is null for asset: ' + ast.Name);
        }

        for (Api_Response_Childs__c arcRow : arcAll) {
            if (arcRow == null || arcRow.Id == null || arcRow.Status__c == 'Processed') continue;
            arcRow.Status__c = 'Processed';
            arcToUpdate.put(arcRow.Id, arcRow);
        }
    }

    try {

        if(dwellUpdateAssetIds != null && !dwellUpdateAssetIds.isEmpty()) {
            for(Id assetId : dwellUpdateAssetIds.keySet()) {
                RedesignNl_CreateAssetHistoryBatch.updateOldDwellRecords(assetId, dwellUpdateAssetIds.get(assetId));
            }
        }
        if (!apiToUpdateMap.isEmpty()) update apiToUpdateMap.values();
        if (!arcToUpdate.isEmpty()) update arcToUpdate.values();

        Map<Id, Asset_History_Custom__c> uniqueAhcUpdateMap = new Map<Id, Asset_History_Custom__c>();
        for (Asset_History_Custom__c ahc : ahcToUpdate) {
            if (ahc != null && ahc.Id != null) {
                uniqueAhcUpdateMap.put(ahc.Id, ahc);
            }
        }
        if (!uniqueAhcUpdateMap.isEmpty()) update uniqueAhcUpdateMap.values();
        removeDuplicateAhcInsertsNoDelete(ahcToInsert);
        if (!ahcToInsert.isEmpty()) insert ahcToInsert;
        if (!assetsToUpdateMap.isEmpty()) update assetsToUpdateMap.values();
    }catch (Exception e) { RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'execute', 'Exception', null, null, true); }
}

global void finish(Database.BatchableContext bc) {
    Database.executeBatch(new Chorus_TemperatureAhcBatch(AssetIDSet), 10);
}

// =========================================================
// TIME HELPERS (NEW)
// =========================================================
private static Datetime dtMin(Datetime a, Datetime b) {
    if (a == null) return b;
    if (b == null) return a;
    return (a.getTime() <= b.getTime()) ? a : b;
}

private static Datetime dtMax(Datetime a, Datetime b) {
    if (a == null) return b;
    if (b == null) return a;
    return (a.getTime() >= b.getTime()) ? a : b;
}

private static void normalizeAhcTimes(Asset_History_Custom__c ahc) {
    if (ahc == null) return;
    if (ahc.Start_Time__c != null && ahc.End_Time__c != null && ahc.End_Time__c.getTime() < ahc.Start_Time__c.getTime()) {
        // If inverted, fix by swapping (or you could force End = Start)
        Datetime tmp = ahc.Start_Time__c;
        ahc.Start_Time__c = ahc.End_Time__c;
        ahc.End_Time__c = tmp;
    }
}

// =========================================================
// WRAPPER CREATION (FIXED: start=min, end=max always)
// =========================================================
public static List<assetHistory> createWrapperRecords(
    List<Api_Response_Childs__c> arcList,
    //String tempRecTypeId,
    List<Asset_History_Custom__c> tempAhcToInsert
) {
    List<assetHistory> segments = new List<assetHistory>();
    if (arcList == null || arcList.isEmpty()) return segments;

    assetHistory current = new assetHistory();

    for (Api_Response_Childs__c arcDev : arcList) {
        if (arcDev == null) continue;

        try {
            Datetime ts = arcDev.Timestamp_DateTime__c;

            // always keep segment time range sane
            if (ts != null) {
                current.startTime = dtMin(current.startTime, ts);
                current.endTime   = dtMax(current.endTime, ts);
            }

            if (arcDev.Location__c != null) {

                if (current.isLocationFound) {
                    String currentId = current.currentLocationId;
                    String newId     = arcDev.currentLocationId__c;

                    Boolean sameLoc =
                        ((!String.isBlank(currentId) && !String.isBlank(newId) && currentId == newId) ||
                            ((String.isBlank(currentId) || String.isBlank(newId)) &&
                            String.valueOf(current.currLocationAddress) == String.valueOf(arcDev.Current_Location_Address__c)));

                    if (sameLoc) {
                        // end time already max()’d above
                        applyTelemetry(current, arcDev, /*tempRecTypeId,*/ tempAhcToInsert);
                    } else {
                        // close current segment, start a new one
                        segments.add(current);

                        assetHistory nextSeg = new assetHistory();
                        nextSeg.currentLocationId = arcDev.currentLocationId__c;
                        nextSeg.isLocationFound = true;

                        // init times from this row
                        if (ts != null) {
                            nextSeg.startTime = ts;
                            nextSeg.endTime   = ts;
                        }

                        applyTelemetry(nextSeg, arcDev, /*tempRecTypeId,*/ tempAhcToInsert);
                        current = nextSeg;
                    }
                } else {
                    current.currentLocationId = arcDev.currentLocationId__c;
                    current.isLocationFound = true;

                    // times already updated via min/max above
                    applyTelemetry(current, arcDev, /*tempRecTypeId,*/ tempAhcToInsert);
                }

            } else {
                // telemetry-only row: times already min/max’d above
                applyTelemetry(current, arcDev, /*tempRecTypeId,*/ tempAhcToInsert);
            }

        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'createWrapperRecords', 'Exception', null, null, true);
        }
    }

    if (current != null && (current.startTime != null || current.endTime != null || current.isLocationFound)) {
        // final safety: if inverted due to weird data, force end>=start
        if (current.startTime != null && current.endTime != null && current.endTime.getTime() < current.startTime.getTime()) {
            current.endTime = current.startTime;
        }
        segments.add(current);
    }

    return segments;
}

private static void applyTelemetry(
    assetHistory ah,
    Api_Response_Childs__c arcDev,
    //String tempRecTypeId,
    List<Asset_History_Custom__c> tempAhcToInsert
) {
    if (ah == null || arcDev == null) return;

    if (arcDev.Timestamp_Date_Time_Device_Status__c != null) ah.Devicetime = arcDev.Timestamp_Date_Time_Device_Status__c;
    if (arcDev.Location__c != null) ah.location = arcDev.Location__c;
    if (arcDev.Message_Type__c != null) ah.messageType = arcDev.Message_Type__c;
    if (arcDev.Battery__c != null) ah.battery = arcDev.Battery__c;
    if (arcDev.EstBattPct__c != null) ah.estBattPct = arcDev.EstBattPct__c;
    if (arcDev.rssi__c != null) ah.rssi = String.valueOf(arcDev.rssi__c);
    if (arcDev.rsrp__c != null) ah.rsrp = String.valueOf(arcDev.rsrp__c);
    if (arcDev.rsrq__c != null) ah.rsrq = String.valueOf(arcDev.rsrq__c);
    if (arcDev.Accuracy_Meters__c != null) ah.accuracy = arcDev.Accuracy_Meters__c;

    if (arcDev.Latitude__c != null) ah.latitude = String.valueOf(arcDev.Latitude__c);
    if (arcDev.Longitude__c != null) ah.longitude = String.valueOf(arcDev.Longitude__c);

    if (arcDev.Facility_Location__c != null) ah.facilityLocation = arcDev.Facility_Location__c;

    /*if ((arcDev.Temperature__c != null || arcDev.Relative_Humidity__c != null) && arcDev.Asset__r.Capture_Temperature_Response__c == True) {
        createTemperatureAHC_NoDml(arcDev, tempRecTypeId, tempAhcToInsert);
    }
    if (arcDev.Temperature__c != null) ah.temperature = String.valueOf(arcDev.Temperature__c);
    if (arcDev.Relative_Humidity__c != null) ah.humidity = String.valueOf(arcDev.Relative_Humidity__c);*/
    
    if (arcDev.Current_Location_Address__c != null) ah.currLocationAddress = arcDev.Current_Location_Address__c;
    if (arcDev.Current_Country__c != null) ah.currentCountry = arcDev.Current_Country__c;
    if (arcDev.Current_State__c != null) ah.currentState = arcDev.Current_State__c;
    if (arcDev.Current_City__c != null) ah.currentCity = arcDev.Current_City__c;
    if (arcDev.Current_Street_Address__c != null) ah.currentStreetAddress = arcDev.Current_Street_Address__c;
    if (arcDev.Current_Zipcode__c != null) ah.currentZipcode = arcDev.Current_Zipcode__c;

    if (arcDev.Id != null) ah.latestAPIRespId = (String) arcDev.Id;
}

// =========================================================
// CREATE/UPDATE AHCs (FIXED: End only moves forward)
// =========================================================
public static Asset_History_Custom__c createOrUpdateAhcRecords_NoDml(
List<assetHistory> segments,
Asset_History_Custom__c oldOpenAhc,
Id assetId,
String recTypeId,
List<Asset_History_Custom__c> toInsert,
List<Asset_History_Custom__c> toUpdate,
Map<Id, Asset_History_Custom__c> dwellUpdateAssetIds
) {
if (segments == null || segments.isEmpty()) return oldOpenAhc;

Asset_History_Custom__c open = oldOpenAhc;

for (assetHistory seg : segments) {
    if (seg == null) continue;

    // normalize segment times
    if (seg.startTime != null && seg.endTime != null && seg.endTime.getTime() < seg.startTime.getTime()) {
        seg.endTime = seg.startTime;
    }

    if (open == null) {
        open = buildNewAhc(assetId, null, seg, recTypeId, dwellUpdateAssetIds);
        normalizeAhcTimes(open);
        continue;
    }

    Boolean telemetryOnly = String.isBlank(seg.currentLocationId) && String.isBlank(seg.currLocationAddress);

    Boolean sameLoc = (!String.isBlank(open.currentLocationId__c) && open.currentLocationId__c == seg.currentLocationId);
    Boolean sameAddr = (String.isBlank(open.currentLocationId__c) || String.isBlank(seg.currentLocationId))
        && !String.isBlank(open.Current_Location_Address__c)
        && !String.isBlank(seg.currLocationAddress)
        && open.Current_Location_Address__c == seg.currLocationAddress;

    if (telemetryOnly || sameLoc || sameAddr) {
        mergeTelemetryIntoAhc(open, seg);

        // Same location response: only extend the current AHC End_Time__c.
        // Do NOT move Start_Time__c backward; this caused incorrect backfilled history.
        if (seg.endTime != null) open.End_Time__c = dtMax(open.End_Time__c, seg.endTime);
        if (open.Start_Time__c == null && seg.startTime != null) open.Start_Time__c = seg.startTime;

        open.Still_in_this_Location__c = true;
        normalizeAhcTimes(open);
        continue;
    }

    // =========================================================
    // Location changed.
    // Required rule:
    // Previous AHC keeps/uses its End_Time__c as the boundary.
    // New AHC Start_Time__c must equal Previous AHC End_Time__c.
    // New AHC End_Time__c remains the response/segment End_Time__c.
    // =========================================================
    Datetime boundary = open.End_Time__c;

    if (boundary == null) {
        boundary = seg.startTime;
    }

    if (boundary == null || seg.endTime == null) {
        continue;
    }

    // If the response is not after the previous AHC end, do not create a duplicate/invalid AHC.
    if (seg.endTime.getTime() <= boundary.getTime()) {
        continue;
    }

    open.Still_in_this_Location__c = false;
    normalizeAhcTimes(open);

    // persist closed record. End_Time__c is not changed here unless normalizeAhcTimes fixes an inverted row.
    if (open.Id != null) toUpdate.add(open);
    else toInsert.add(open);

    // New AHC starts exactly at previous AHC End_Time__c.
    seg.startTime = boundary;

    // create new open AND backfill missing fields
    open = buildNewAhc(assetId, open, seg, recTypeId, dwellUpdateAssetIds);
    normalizeAhcTimes(open);
}

if (open != null) {
    open.Still_in_this_Location__c = true;
    normalizeAhcTimes(open);
    if (open.Id != null) toUpdate.add(open);
    else toInsert.add(open);
}

return open;
}


private static Asset_History_Custom__c buildNewAhc(
    Id assetId,
    Asset_History_Custom__c prev,
    assetHistory seg,
    String recTypeId,
    Map<Id, Asset_History_Custom__c> dwellUpdateAssetIds
) {
    Asset_History_Custom__c ahc = new Asset_History_Custom__c();
    ahc.Asset__c = assetId;
    if (!String.isBlank(recTypeId)) ahc.RecordTypeId = recTypeId;

    ahc.currentLocationId__c = seg.currentLocationId;

    if (!String.isBlank(seg.currentLocationId) && (seg.currentLocationId.length() == 15 || seg.currentLocationId.length() == 18)) {
        try { ahc.Current_Location__c = (Id)seg.currentLocationId; } catch (Exception ignore) {}
    }

    if (prev != null) {
        ahc.Last_Known_Location_Lookup__c = prev.currentLocationId__c != null ? (Id) prev.currentLocationId__c : prev.Last_Known_Location_Lookup__c;
        ahc.Last_Known_Location__c = ahc.Last_Known_Location_Lookup__c != null ? ahc.Last_Known_Location_Lookup__r.Name : prev.Last_Known_Location__c;

        ahc.Location__c = String.isBlank(seg.location) ? prev.Location__c : seg.location;

        if (String.isBlank(seg.currLocationAddress)) ahc.Current_Location_Address__c = prev.Current_Location_Address__c;
        else ahc.Current_Location_Address__c = seg.currLocationAddress;

        if (String.isBlank(seg.currentStreetAddress)) ahc.Current_Street_Address__c = prev.Current_Street_Address__c;
        else ahc.Current_Street_Address__c = seg.currentStreetAddress;

        if (String.isBlank(seg.currentCity)) ahc.Current_City__c = prev.Current_City__c;
        else ahc.Current_City__c = seg.currentCity;

        if (String.isBlank(seg.currentState)) ahc.Current_State__c = prev.Current_State__c;
        else ahc.Current_State__c = seg.currentState;

        if (String.isBlank(seg.currentZipcode)) ahc.Current_Zipcode__c = prev.Current_Zipcode__c;
        else ahc.Current_Zipcode__c = seg.currentZipcode;

        if (String.isBlank(seg.currentCountry)) ahc.Current_country__c = prev.Current_country__c;
        else ahc.Current_country__c = seg.currentCountry;

        if (String.isBlank(seg.latitude) && prev.Latitude__c != null) ahc.Latitude__c = prev.Latitude__c;
        if (!String.isBlank(seg.latitude)) ahc.Latitude__c = Decimal.valueOf(seg.latitude);

        if (String.isBlank(seg.longitude) && prev.Longitude__c != null) ahc.Longitude__c = prev.Longitude__c;
        if (!String.isBlank(seg.longitude)) ahc.Longitude__c = Decimal.valueOf(seg.longitude);

    } else {
        ahc.Location__c = !String.isBlank(seg.location) ? seg.location : lastKnownLocation;
        ahc.Last_Known_Location__c = lastKnownLocation;
        ahc.Last_Known_Location_Lookup__c = lastKnownId;

        ahc.Current_Location_Address__c =
            !String.isBlank(seg.currLocationAddress) ? seg.currLocationAddress : lastKnownCurrLocationAddress;

        ahc.Current_Street_Address__c =
            !String.isBlank(seg.currentStreetAddress) ? seg.currentStreetAddress : lastKnownStreet;

        ahc.Current_City__c =
            !String.isBlank(seg.currentCity) ? seg.currentCity : lastKnownCity;

        ahc.Current_State__c =
            !String.isBlank(seg.currentState) ? seg.currentState : lastKnownState;

        ahc.Current_Zipcode__c =
            !String.isBlank(seg.currentZipcode) ? seg.currentZipcode : lastKnownZip;

        ahc.Current_country__c =
            !String.isBlank(seg.currentCountry) ? seg.currentCountry : lastKnownCountry;

        if (!String.isBlank(seg.latitude)) {
            ahc.Latitude__c = Decimal.valueOf(seg.latitude);
        } else {
            ahc.Latitude__c = lastKnownLat;
        }

        if (!String.isBlank(seg.longitude)) {
            ahc.Longitude__c = Decimal.valueOf(seg.longitude);
        } else {
            ahc.Longitude__c = lastKnownLon;
        }
    }

    ahc.Consider_for_Dwell__c = (ahc.Location__c == 'In Transit') ? true : false;

    ahc.Start_Time__c = seg.startTime;
    ahc.End_Time__c   = seg.endTime;

    mergeTelemetryIntoAhc(ahc, seg);

    ahc.Still_in_this_Location__c = true;

    // FIX: normalize times before downstream logic
    normalizeAhcTimes(ahc);

    if (ahc.Location__c != 'In Transit') {
        ahc.Consider_for_Dwell__c = false;
        //RedesignNl_CreateAssetHistoryBatch.updateOldDwellRecords(assetId, ahc);
        dwellUpdateAssetIds.put(assetId, ahc);
    }
    return ahc;
}

private static void mergeTelemetryIntoAhc(Asset_History_Custom__c target, assetHistory seg) {
    if (target == null || seg == null) return;

    try {
        if (!String.isBlank(seg.facilityLocation)) target.Facility_Location__c = seg.facilityLocation;
        if (!String.isBlank(seg.messageType) && seg.messageType != null) target.Message_Type__c = seg.messageType;
        if (seg.Devicetime != null) target.Device_Status_Time__c = seg.Devicetime;

        if (seg.accuracy != null) target.Accuracy_meters__c = seg.accuracy;
        if (seg.battery != null) target.Battery_Voltage__c = seg.battery;
        if (seg.estBattPct != null) {
            target.estBattPct__c = seg.estBattPct;
            target.Est_Remaining_Battery__c = seg.estBattPct;
        }

        if (!String.isBlank(seg.rssi)) target.rssi__c = Decimal.valueOf(seg.rssi);
        if (!String.isBlank(seg.rsrp)) target.rsrp__c = Decimal.valueOf(seg.rsrp);
        if (!String.isBlank(seg.rsrq)) target.rsrq__c = Decimal.valueOf(seg.rsrq);
        if (!String.isBlank(seg.temperature)) target.Temperature__c = Decimal.valueOf(seg.temperature);
        if (!String.isBlank(seg.humidity)) target.Relative_Humidity__c = Decimal.valueOf(seg.humidity);

        if (String.isNotBlank(seg.latitude)) target.Latitude__c = Decimal.valueOf(seg.latitude);
        if (String.isNotBlank(seg.longitude)) target.Longitude__c = Decimal.valueOf(seg.longitude);

        if (!String.isBlank(seg.location)) target.Location__c = seg.location;

        if (!String.isBlank(seg.currLocationAddress)) target.Current_Location_Address__c = seg.currLocationAddress;
        if (!String.isBlank(seg.currentStreetAddress)) target.Current_Street_Address__c = seg.currentStreetAddress;
        if (!String.isBlank(seg.currentCity)) target.Current_City__c = seg.currentCity;
        if (!String.isBlank(seg.currentState)) target.Current_State__c = seg.currentState;
        if (!String.isBlank(seg.currentZipcode)) target.Current_Zipcode__c = seg.currentZipcode;
        if (!String.isBlank(seg.currentCountry)) target.Current_country__c = seg.currentCountry;

        if (!String.isBlank(seg.latestAPIRespId)) target.Latest_API_Response_Child__c = seg.latestAPIRespId;

    } catch (Exception ex) {
        RedesignNL_CaptureErrors.createErrorLogs(ex, 'Chorus_AhcBatch', 'mergeTelemetryIntoAhc', 'Exception', null, null, true);
    }
}

// -----------------------------
// Asset update (UNCHANGED)
// -----------------------------
private static void updateAssetSummary(Asset ast, Asset_History_Custom__c ahc) {
    try {
        if (ast.Account_to_Update__c != Null) {
            ast.AccountId = ast.Account_to_Update__c;
            ast.Account_to_Update__c = null;
        }

        ast.Temperature__c = ahc.Temperature__c == null ? ast.Temperature__c : ahc.Temperature__c;
        ast.Humidity__c = ahc.Relative_Humidity__c == null ? ast.Humidity__c : ahc.Relative_Humidity__c;
        ast.Accuracy_meters__c = ahc.Accuracy_meters__c == null ? ast.Accuracy_meters__c : ahc.Accuracy_meters__c;

        ast.Current_Address__c = String.isBlank(ahc.Current_Location_Address__c) ? ast.Current_Address__c : ahc.Current_Location_Address__c;
        ast.Current_City__c = String.isBlank(ahc.Current_City__c) ? null : ahc.Current_City__c;
        ast.Current_State__c = String.isBlank(ahc.Current_State__c) ? null : ahc.Current_State__c;
        ast.Current_country__c = String.isBlank(ahc.Current_country__c) ? null : ahc.Current_country__c;
        ast.Current_Street_Address__c = String.isBlank(ahc.Current_Street_Address__c) ? null : ahc.Current_Street_Address__c;
        ast.Current_Zip_Code__c = String.isBlank(ahc.Current_Zipcode__c) ? null : ahc.Current_Zipcode__c;

        String location = String.isBlank(ahc.Location__c) ? '' : ahc.Location__c;
        ast.Temporary_Longitude__c = ahc.Longitude__c == null ? ast.Temporary_Longitude__c : ahc.Longitude__c;
        ast.Temporary_Latitude__c = ahc.Latitude__c == null ? ast.Temporary_Latitude__c : ahc.Latitude__c;

        ast.Start_Time__c = ahc.Start_Time__c == null ? ast.Start_Time__c : ahc.Start_Time__c;
        ast.rssi__c = ahc.rssi__c == null ? ast.rssi__c : ahc.rssi__c;
        ast.rsrp__c = ahc.rsrp__c == null ? ast.rsrp__c : ahc.rsrp__c;
        ast.rsrq__c = ahc.rsrq__c == null ? ast.rsrq__c : ahc.rsrq__c;

        ast.Battery_Voltage__c = ahc.Battery_Voltage__c == null ? ast.Battery_Voltage__c : ahc.Battery_Voltage__c;
        ast.estBattPct__c = ahc.estBattPct__c == null ? ast.estBattPct__c : ahc.estBattPct__c;

        ast.Last_Known_Location__c = ahc.Last_Known_Location_Lookup__c != null ? ahc.Last_Known_Location_Lookup__c : null;
        if (location == 'In Transit') {
            ast.State_of_Pallet__c = 'In Transit';
            //ast.Last_Known_Location__c = ast.Current_Location__c == null ? ast.Last_Known_Location__c : ast.Current_Location__c;
            ast.Current_Location__c = null;
        } else if (location != '' && location != 'In Transit') {
            ast.State_of_Pallet__c = 'In Network';
            ast.Current_Location__c = ahc.currentLocationId__c != null ? (ID)ahc.currentLocationId__c : ast.Current_Location__c;
        }

        ast.src__c = ahc.Message_Type__c != null ? ahc.Message_Type__c : ast.src__c;
        ast.Facility_Location__c = ahc.Facility_Location__c;

        ast.Last_Connected2__c = (ast.Last_Connected2__c == null) ||
                (ahc.Device_Status_Time__c != null && ast.Last_Connected2__c < ahc.Device_Status_Time__c)
            ? ahc.Device_Status_Time__c
            : ast.Last_Connected2__c;

        Datetime lastconnect = (ast.Last_Connected2__c == null) ||
                (ahc.End_Time__c != null && ast.Last_Connected2__c < ahc.End_Time__c)
            ? ahc.End_Time__c
            : ast.Last_Connected2__c;

        ast.Last_Connected__c = (ast.Last_Connected__c == null) ||
                (lastconnect != null && ast.Last_Connected__c < lastconnect)
            ? lastconnect
            : ast.Last_Connected__c;

        ast = updateLastConnectedMapFields(ast);

    } catch (Exception ex) {
        RedesignNL_CaptureErrors.createErrorLogs(ex, 'Chorus_AhcBatch', 'updateAssetSummary', 'Exception', ast.Device_Id__c, null, true);
    }
}

public static Asset updateLastConnectedMapFields(Asset ast) {
    try {
        if (ast.Last_Connected__c != null) {
            Datetime now = ast.Last_Connected__c;
            Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
            ast.Last_Connected_Map__c = now.addSeconds(offset / 1000);
        }
        if (ast.Date_Shipped__c != null) {
            Datetime now = ast.Date_Shipped__c;
            Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
            ast.Last_Scan_Map__c = now.addSeconds(offset / 1000);
        }
        return ast;
    } catch (Exception ex) {
        RedesignNL_CaptureErrors.createErrorLogs(ex, 'Chorus_AhcBatch', 'updateLastConnectedMapFields', 'Exception', ast.Id, null, true);
    }
    return null;
}


// =========================================================
// PREVIOUS AHC END ALIGNMENT HELPERS
// For the first newly-created AHC, use the latest existing
// Location AHC End_Time__c before the new response end time.
// This prevents new AHC Start_Time__c from using previous
// Start_Time__c by mistake.
// =========================================================
private static Datetime getLatestExistingAhcEndBeforeNewEnd(Id assetId, Datetime newSegmentEndTime) {
    if (assetId == null || newSegmentEndTime == null) {
        return null;
    }

    List<Asset_History_Custom__c> previousAhcList = [
        SELECT Id, End_Time__c
        FROM Asset_History_Custom__c
        WHERE Asset__c = :assetId
        AND RecordType.DeveloperName = 'Location'
        AND End_Time__c != null
        AND End_Time__c < :newSegmentEndTime
        ORDER BY End_Time__c DESC
        LIMIT 1
    ];

    return previousAhcList.isEmpty() ? null : previousAhcList[0].End_Time__c;
}

private static void alignFirstSegmentStartToLatestExistingEnd(
    Id assetId,
    List<assetHistory> segments
) {
    if (assetId == null || segments == null || segments.isEmpty()) {
        return;
    }

    assetHistory firstSeg = segments[0];

    if (firstSeg == null || firstSeg.endTime == null) {
        return;
    }

    Datetime previousEndTime = getLatestExistingAhcEndBeforeNewEnd(assetId, firstSeg.endTime);

    if (previousEndTime == null) {
        return;
    }

    // Required rule:
    // first new AHC Start_Time__c = latest existing previous AHC End_Time__c.
    firstSeg.startTime = previousEndTime;

    if (
        firstSeg.endTime != null &&
        firstSeg.startTime != null &&
        firstSeg.endTime.getTime() < firstSeg.startTime.getTime()
    ) {
        firstSeg.endTime = firstSeg.startTime;
    }
}


private static void removeDuplicateAhcInsertsNoDelete(List<Asset_History_Custom__c> ahcToInsert) {
    if (ahcToInsert == null || ahcToInsert.isEmpty()) return;

    Set<Id> assetIds = new Set<Id>();
    Datetime minStart;
    Datetime maxEnd;

    for (Asset_History_Custom__c ahc : ahcToInsert) {
        if (ahc == null || ahc.Asset__c == null) continue;

        assetIds.add(ahc.Asset__c);
        if (ahc.Start_Time__c != null) minStart = dtMin(minStart, ahc.Start_Time__c);
        if (ahc.End_Time__c != null) maxEnd = dtMax(maxEnd, ahc.End_Time__c);
    }

    if (assetIds.isEmpty() || minStart == null || maxEnd == null) return;

    Set<String> existingKeys = new Set<String>();

    for (Asset_History_Custom__c existingAhc : [
        SELECT Id, Asset__c, Start_Time__c, End_Time__c
        FROM Asset_History_Custom__c
        WHERE Asset__c IN :assetIds
        AND RecordType.DeveloperName = 'Location'
        AND Start_Time__c != null
        AND End_Time__c != null
        AND Start_Time__c >= :minStart
        AND End_Time__c <= :maxEnd
    ]) {
        existingKeys.add(buildAhcTimeKey(existingAhc));
    }

    Set<String> newKeys = new Set<String>();
    List<Asset_History_Custom__c> cleaned = new List<Asset_History_Custom__c>();

    for (Asset_History_Custom__c ahc : ahcToInsert) {
        String key = buildAhcTimeKey(ahc);

        if (String.isBlank(key)) {
            cleaned.add(ahc);
            continue;
        }

        if (existingKeys.contains(key)) {
            System.debug('Skipping duplicate AHC insert because existing AHC has same Asset/Start/End: ' + key);
            continue;
        }

        if (newKeys.contains(key)) {
            System.debug('Skipping duplicate AHC insert within same transaction: ' + key);
            continue;
        }

        newKeys.add(key);
        cleaned.add(ahc);
    }

    ahcToInsert.clear();
    ahcToInsert.addAll(cleaned);
}

private static String buildAhcTimeKey(Asset_History_Custom__c ahc) {
    if (ahc == null || ahc.Asset__c == null || ahc.Start_Time__c == null || ahc.End_Time__c == null) {
        return null;
    }

    return String.valueOf(ahc.Asset__c) + '|' + String.valueOf(ahc.Start_Time__c.getTime()) + '|' + String.valueOf(ahc.End_Time__c.getTime());
}

/* public static void createTemperatureAHC_NoDml(Api_Response_Childs__c arcDev, String tempRecTypeId, List<Asset_History_Custom__c> tempAhcToInsert) {
    if (arcDev == null) return;
    if (arcDev.Temperature__c == null && arcDev.Relative_Humidity__c == null) return;

    Asset_History_Custom__c tempAhc = new Asset_History_Custom__c();
    tempAhc.Asset__c = arcDev.Asset__c;
    if (!String.isBlank(tempRecTypeId)) tempAhc.RecordTypeId = tempRecTypeId;

    tempAhc.Start_Time__c = arcDev.Timestamp_DateTime__c;
    tempAhc.End_Time__c   = arcDev.Timestamp_DateTime__c;
    tempAhc.Temperature__c = arcDev.Temperature__c;
    tempAhc.Relative_Humidity__c = arcDev.Relative_Humidity__c;
    tempAhc.Still_in_this_Location__c = false;

    tempAhcToInsert.add(tempAhc);
}*/

public static  Map<String,Datetime> DeleteExistingRecords(Asset ast) {
    String query, query1;
    query = 'SELECT Id, name,ARC_External_Id__c, Timestamp_DateTime__c, CreatedDate '+
        'From API_Response_Childs__c WHERE Asset__c =\''+ ast.Id+'\' AND status__c = \'Chorus-New\' '+
        'AND Timestamp_DateTime__c != null AND Recordtype.DeveloperName = \'Location\' '+
        'ORDER BY Timestamp_DateTime__c asc limit 1';
    query1 = 'SELECT Id, name,ARC_External_Id__c, Timestamp_DateTime__c, CreatedDate '+
        'From API_Response_Childs__c WHERE Asset__c =\''+ ast.Id+'\' AND status__c IN (\'Chorus-New\', \'Processed\') '+
        'AND Timestamp_DateTime__c != null AND Recordtype.DeveloperName = \'Location\' '+
        'ORDER BY CreatedDate desc limit 1';
    List<API_Response_Childs__c> apiRespList = Database.query(query);
    List<API_Response_Childs__c> apiRespList1 = Database.query(query1);
    Datetime earlistTS = null;
    Map<String,DateTime> endTimeList = new Map<String,DateTime>();
    Datetime devDT = null;
    if(apiRespList.size()>0) {
        //Murali--Assigning the value to earliestTS which is used in ahclist query
        earlistTS= apiRespList[0].Timestamp_DateTime__c;
        endTimeList.put('Starttime',apiRespList[0].Timestamp_DateTime__c);
        endTimeList.put('Endtime',apiRespList1[0].CreatedDate);
        List<Asset_History_Custom__c> ahcList = [SELECT Id, Name, Start_Time__c, Current_Location_Address__c, Location__c, Still_in_this_Location__c,
                                                    Last_known_location_Lookup__c, Last_Known_Location_Lookup__r.Name, Last_Known_Location__c, Device_Status_Time__c,
                                                    Current_Street_Address__c, Current_City__c, Current_State__c, Current_Zipcode__c,
                                                    Current_country__c, Latitude__c, Longitude__c
                                                    From Asset_History_Custom__c 
                                                    WHERE Asset__c =: ast.Id 
                                                    AND Delete_Check__c = true
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
                        lastKnownLocation= obj.Last_Known_Location_Lookup__r.Name;
                        lastKnownId = obj.Last_known_location_Lookup__c;
                        lastKnownCurrLocationAddress = obj.Current_Location_Address__c;
                        lastKnownStreet = obj.Current_Street_Address__c;
                        lastKnownCity = obj.Current_City__c;
                        lastKnownState = obj.Current_State__c;
                        lastKnownZip = obj.Current_Zipcode__c;
                        lastKnownCountry = obj.Current_country__c;
                        lastKnownLat = obj.Latitude__c;
                        lastKnownLon = obj.Longitude__c;
                        
                    }
                    if(initialDate != null && initialDate > obj.Start_Time__c){
                        initialDate = obj.Start_Time__c;
                        lastKnownTime= obj.Start_Time__c;
                        lastKnownLocation= obj.Last_Known_Location_Lookup__r.Name;
                        lastKnownId = obj.Last_known_location_Lookup__c;
                        lastKnownCurrLocationAddress = obj.Current_Location_Address__c;
                        lastKnownStreet = obj.Current_Street_Address__c;
                        lastKnownCity = obj.Current_City__c;
                        lastKnownState = obj.Current_State__c;
                        lastKnownZip = obj.Current_Zipcode__c;
                        lastKnownCountry = obj.Current_country__c;
                        lastKnownLat = obj.Latitude__c;
                        lastKnownLon = obj.Longitude__c;
                        
                    }
                    if(devDT == null || devDT >= obj.Device_Status_Time__c){
                        devDT= obj.Device_Status_Time__c;
                        endTimeList.put('DevTime',devDT);
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
                /*failureAst.add(ast.Id);
                failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - DeleteExistingRecords. Error msg: '+e.getMessage());
                totalFailureRecords = totalFailureRecords + 1;*/
                
            }
            return endTimeList;
        }
        else{
            List<Asset_History_Custom__c> stillInLocation = [SELECT Id, Name, Start_Time__c, Asset__c, Still_in_this_Location__c,Current_Location_Address__c, Location__c,
                                                                Last_known_location_Lookup__c, Last_Known_Location_Lookup__r.Name, Last_Known_Location__c, Device_Status_Time__c,
                                                                Current_Street_Address__c, Current_City__c, Current_State__c, Current_Zipcode__c,
                                                                Current_country__c, Latitude__c, Longitude__c
                                                                FROM Asset_History_Custom__c
                                                                WHERE Asset__c =: ast.Id 
                                                                AND Recordtype.developerName = 'Location' 
                                                                AND Still_in_this_Location__c = true 
                                                                ORDER BY start_Time__c ASC];
            if(stillInLocation.size() > 0) {
                earlistTS = stillInLocation[0].Start_Time__c;
                Endtimelist.put('Starttime',earlistTS);
                endTimeList.put('DevTime',stillInLocation[0].Device_Status_Time__c);
                try{
                    lastKnownTime = stillInLocation[0].Start_Time__c;
                    lastKnownLocation= stillInLocation[0].Last_Known_Location_Lookup__r.Name;
                    lastKnownId = stillInLocation[0].Last_known_location_Lookup__c;
                    lastKnownCurrLocationAddress = stillInLocation[0].Current_Location_Address__c;
                    lastKnownStreet = stillInLocation[0].Current_Street_Address__c;
                    lastKnownCity = stillInLocation[0].Current_City__c;
                    lastKnownState = stillInLocation[0].Current_State__c;
                    lastKnownZip = stillInLocation[0].Current_Zipcode__c;
                    lastKnownCountry = stillInLocation[0].Current_country__c;
                    lastKnownLat = stillInLocation[0].Latitude__c;
                    lastKnownLon = stillInLocation[0].Longitude__c;
                    //   RedesignNL_ARCCreation.ahclist(stillInLocation,assetSumm);                       
                    Database.delete(stillInLocation, true);
                }
                catch (DMLException e) {
                    RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_CreateAssetHistoryBatch', 'DeleteExistingRecords', 'DML Error', ast.device_Id__c, null, true);
                    //Murali:Added the failureAst for unable to lock row
                    /*failureAst.add(ast.Id);
                    failureMsgs.add('RedesignNL_CreateAssetHistoryBatch - DeleteExistingRecords. Error msg: '+e.getMessage());
                    totalFailureRecords = totalFailureRecords + 1;*/
                    
                }
                return endTimeList;
            }
            else
                return endTimeList;
        }
    }
    else
        return endTimeList;
}

// =========================================================
// WRAPPER
// =========================================================
public class assetHistory implements Comparable {
    @AuraEnabled public Boolean  isLocationFound = false;
    @AuraEnabled public Datetime startTime;
    @AuraEnabled public Datetime endTime;

    public String currentLocationId;

    @AuraEnabled public String  latestAPIRespId;
    @AuraEnabled public String  location;

    @AuraEnabled public String  latitude;
    @AuraEnabled public String  longitude;

    @AuraEnabled public String  currLocationAddress;
    @AuraEnabled public String  currentCountry;
    @AuraEnabled public String  currentState;
    @AuraEnabled public String  currentCity;
    @AuraEnabled public String  currentStreetAddress;
    @AuraEnabled public String  currentZipcode;

    @AuraEnabled public Decimal estBattPct;
    @AuraEnabled public Decimal accuracy;

    @AuraEnabled public String  messageType;
    @AuraEnabled public Decimal battery;

    @AuraEnabled public String  rssi = '';
    @AuraEnabled public String  rsrp = '';
    @AuraEnabled public String  rsrq = '';
    @AuraEnabled public String  facilityLocation;

    @AuraEnabled public String  humidity;
    @AuraEnabled public String  temperature;

    @AuraEnabled public Datetime Devicetime;

    public Integer compareTo(Object otherAsset) { return 1; }
}
}