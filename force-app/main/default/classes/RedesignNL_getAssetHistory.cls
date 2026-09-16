/*
* Class Name: RedesignNL_ARCCreation
* Created By: Jayesh Khattar
* Description: This class is used to create Location AHC records using wrapper class
* Modified Date  Modified By        Last Change
* Feb 16, 2024: Sandeep : Added Last Known Location Lookup at the place of Last Known Location Id. ADO#268
* Feb 24, 2024: Jayesh  : 356 - Asset History Lookup field are not getting populated in ARC only for Device status
*/
public class RedesignNL_getAssetHistory {
    
    private Static DateTime lastPowerResetTime;
    private Static Boolean lastPowerResetOccurred;
    private Static Decimal lastPowerUpTime;
    private static List<Asset_History_Custom__c> LatestAHCRec;
    private static String latestAPIRespId;
    private static String latestdeviceID;
    private static Api_Response_Childs__c PowerResetArc;
    private static Map<Integer,Map<String,DateTime>> ahcDevMap;
    private static DateTime lastDeviceTS;
    
    public static List<assetHistory> getAllHistoryRecords(Asset assetSumm, String assetId, Datetime StartDT, Datetime EndDT,DateTime devTime, Boolean getDataForMap) {
        lastPowerResetTime = null;
        lastPowerResetOccurred = null;
        lastPowerUpTime = null; 
        lastDeviceTS = null;
        ahcDevMap = new Map<Integer,Map<String,DateTime>>();
        Map<Integer, assetHistory> assetHistoryMap = new Map<Integer, assetHistory>();
        Map<Integer, API_Response_Childs__c> lowDevArcMap = new Map<Integer, API_Response_Childs__c>();
        Map<Integer, API_Response_Childs__c> pickedARCDevMap = new Map<integer,API_Response_Childs__c>();
        
        List<API_Response_Childs__c> apiRespChildLocList = new List<API_Response_Childs__c>();
        Map<Id, API_Response_Childs__c> apiRespChildDevStatMap = new Map<Id, API_Response_Childs__c>();
        Map<Integer, List<API_Response_Childs__c>> AHCDevList = new Map<Integer, List<API_Response_Childs__c>>();
        String query = 'SELECT Id, Name,Asset__c, RecordTypeId, CreatedDate,ARC_External_Id__c, Message_Type__c, Status__c, Alt__c, Timestamp__c,Business_Name__c, Business_Location__Latitude__s, Business_Location__Longitude__s,Business_Place_Id__c,'+
            'HaccRank__c, Location__c, CurrentLocationId__c, Facility_Location__c, Current_Location_Address__c,Current_Country__c ,Current_State__c ,Current_City__c ,Current_Street_Address__c ,Current_Zipcode__c , Timestamp_DateTime__c,Latitude__c,Accuracy_meters__c,'+
            'Battery__c, EstBattPct__c, Network__c, PowerUptime__c, Signal__c,rsrp__c,Timestamp_Date_Time_Device_Status__c, rsrq__c, rssi__c, Longitude__c, RecordType.DeveloperName,'+
            'API_Response__c, Api_Response__r.CreatedDate,Timestamp_Device_Status__c FROM API_Response_Childs__c where Asset__c =: assetId and Status__c NOT IN (\'Google Api Error\',\'FutureTS\', \'BackdatedTS\',\'Pending\',\'Duplicate\')'+
            'and Timestamp_DateTime__c != null and RecordType.DeveloperName in (\'Location\')';
        if(StartDT != null && EndDT != null) {
            query += ' and ((Timestamp_DateTime__c >=: StartDT AND createdDate <=:EndDT) OR (Device_Ts__c like \'1104%\')';    
            
        }
        if(devTime != null){
            System.debug(assetSumm.name +' '+devTime);
            query+=' OR (Timestamp_Date_Time_Device_Status__c >=:DevTime)';
        }
        query += ') order by Timestamp_DateTime__c asc';
        query += ' LIMIT 1000';
        
        List<API_Response_Childs__c> apiRespChildList = Database.query(query);
        Datetime Devicetimets=null;
        Datetime LowDevicets = null;
        Boolean isorderdARC = false;
        Datetime previousDSTime = null;
        Set<Id> allArcIds = new Set<Id>(); 
        for(API_Response_Childs__c arc: apiRespChildList) {
            if(arc.Timestamp_DateTime__c != null && arc.Latitude__c != null && arc.Longitude__c != null && arc.Current_Location_Address__c != null && arc.Timestamp_DateTime__c >= StartDT && arc.createdDate <= EndDt){
                apiRespChildLocList.add(arc);
            }
            allArcIds.add(arc.Id);
            if(arc.Timestamp_Date_Time_Device_Status__c  != null && isorderdARC == false){
                if(previousDSTime != null && previousDSTime > arc.Timestamp_Date_Time_Device_Status__c){
                    isorderdARC = true;
                    apiRespChildDevStatMap = new Map<Id, API_Response_Childs__c>();
                    Devicetimets=null;
                    LowDevicets = null;
                    previousDSTime = null;
                    PowerResetArc = null;
                    latestdeviceID = null;
                }
                if(isorderdARC == false){
                    previousDSTime = arc.Timestamp_Date_Time_Device_Status__c;
                    apiRespChildDevStatMap.put(arc.Id, arc);
                    
                    Devicetimets = arc.Timestamp_Date_Time_Device_Status__c != null && Devicetimets > arc.Timestamp_Date_Time_Device_Status__c  ? Devicetimets : arc.Timestamp_Date_Time_Device_Status__c;
                    if(Devicetimets ==arc.Timestamp_Date_Time_Device_Status__c){ 
                        latestdeviceID=arc.id;
                    }
                    if(arc.Timestamp_Device_Status__c != null && String.valueOf(arc.Timestamp_Device_Status__c).startsWith('1104')){
                        if(LowDevicets == null || LowDevicets > arc.Timestamp_Date_Time_Device_Status__c){
                            LowDevicets = arc.Timestamp_Date_Time_Device_Status__c;
                        }
                    }
                    //System.debug(arc.Timestamp_Device_Status__c); 
                    //LowDevicets = (arc.Timestamp_Device_Status__c != null && String.valueOf(arc.Timestamp_Device_Status__c).startsWith('1104')) && (LowDevicets < arc.Timestamp_Date_Time_Device_Status__c)  ? LowDevicets : arc.Timestamp_Date_Time_Device_Status__c;
                    if(LowDevicets != null && LowDevicets ==arc.Timestamp_Date_Time_Device_Status__c){ 
                        PowerResetArc=arc;
                        //System.debug(arc.Timestamp_Device_Status__c);
                    }
                }
            }
        }
        if(isorderdARC == True){
            List<API_Response_Childs__c> devArcList = [SELECT Id, Name,Asset__c, RecordTypeId, CreatedDate,ARC_External_Id__c, Message_Type__c, Status__c, Alt__c, Timestamp__c,Business_Name__c, Business_Location__Latitude__s, Business_Location__Longitude__s,Business_Place_Id__c,
                                                       HaccRank__c, Location__c, CurrentLocationId__c, Facility_Location__c, Current_Location_Address__c, Timestamp_DateTime__c,Latitude__c,Accuracy_meters__c,Device_Ts__c,
                                                       Battery__c, EstBattPct__c, Network__c, PowerUptime__c, Signal__c,rsrp__c,Timestamp_Date_Time_Device_Status__c, rsrq__c, rssi__c, Longitude__c, RecordType.DeveloperName,
                                                       API_Response__c, Api_Response__r.CreatedDate,Timestamp_Device_Status__c FROM API_Response_Childs__c
                                                       WHERE Id in:allArcIds and Timestamp_Date_Time_Device_Status__c != null
                                                       ORDER BY Timestamp_Date_Time_Device_Status__c asc];
            for(API_Response_Childs__c arc: devArcList) {
                
                if(arc.Timestamp_Date_Time_Device_Status__c  != null){
                    apiRespChildDevStatMap.put(arc.Id, arc);
                    
                    Devicetimets = arc.Timestamp_Date_Time_Device_Status__c != null && Devicetimets > arc.Timestamp_Date_Time_Device_Status__c  ? Devicetimets : arc.Timestamp_Date_Time_Device_Status__c;
                    if(Devicetimets ==arc.Timestamp_Date_Time_Device_Status__c){ 
                        latestdeviceID=arc.id;
                    }
                    if(arc.Timestamp_Device_Status__c != null && String.valueOf(arc.Timestamp_Device_Status__c).startsWith('1104')){
                        if(LowDevicets == null || LowDevicets > arc.Timestamp_Date_Time_Device_Status__c){
                            LowDevicets = arc.Timestamp_Date_Time_Device_Status__c;
                        }
                    }
                    //System.debug(arc.Timestamp_Device_Status__c); 
                    //LowDevicets = (arc.Timestamp_Device_Status__c != null && String.valueOf(arc.Timestamp_Device_Status__c).startsWith('1104')) && (LowDevicets < arc.Timestamp_Date_Time_Device_Status__c)  ? LowDevicets : arc.Timestamp_Date_Time_Device_Status__c;
                    if(LowDevicets != null && LowDevicets ==arc.Timestamp_Date_Time_Device_Status__c){ 
                        PowerResetArc=arc;
                        //System.debug(arc.Timestamp_Device_Status__c);
                    }
                }
            }
        }
        
        List<assetHistory> assetHistoryList = new List<assetHistory>();
        if(apiRespChildLocList.size() > 0 || apiRespChildDevStatMap.size()>0) {
            Map<Integer, API_Response_Childs__c> ApiResChilDevStatMap = new Map<Integer, API_Response_Childs__c>();
            String lastLocation = '';
            string AHLocation = '';
            ID currentLocAHCID = null;
            assetHistory asHis;
            Integer cnt = -1;
            datetime lastconnect;
            datetime Sttime;
            if(apiRespChildLocList.size() > 0) {
                for(API_Response_Childs__c arc : apiRespChildLocList) {
                    Decimal daysTime = 0;
                    string ARLocation = arc.Location__c;
                    string AHCLocAddress='';
                    string ArcLocAddress='';
                    if(lastLocation != '') {
                        AHCLocAddress = lastLocation.replaceAll(',\\s*', '');
                        ArcLocAddress = arc.Current_Location_Address__c.replaceAll(',\\s*', '');
                    }
                    if(lastLocation == '' || lastLocation != '' &&
                       ((currentLocAHCID != null && arc.CurrentLocationId__c != null && arc.CurrentLocationId__c != currentLocAHCID) 
                        ||((AHLocation == 'In Transit' || ARLocation == 'In Transit') &&  AHCLocAddress !=null && ((AHCLocAddress != ArcLocAddress) || (AHLocation != ARLocation))))) {
                            cnt++;
                            asHis = new assetHistory();
                            locationWrapper lw = createLocationWrapper(arc,cnt);
                            asHis.count = cnt;
                            asHis.startTime = arc.Timestamp_DateTime__c;
                            asHis.endTime = arc.Timestamp_DateTime__c;
                            asHis.startTimeTS = arc.Timestamp_DateTime__c;
                            asHis.endTimeTS = arc.Timestamp_DateTime__c;
                            asHis.dwellTime = getDwellTime(arc.Timestamp_DateTime__c, arc.Timestamp_DateTime__c);
                            asHis.Location = arc.Location__c;
                            AHLocation = arc.Location__c;
                            asHis.latitude = arc.Latitude__c;
                            asHis.longitude = arc.Longitude__c;
                            asHis.altitude = arc.Alt__c;
                            ashis.accuracy=arc.Accuracy_meters__c;
                            asHis.messageType = arc.Message_Type__c;
                            asHis.currLocationAddress = arc.Current_Location_Address__c;
                             asHis.currentCountry = arc.Current_Country__c ;
                             asHis.currentCity = arc.Current_City__c ;
                             asHis.currentState = arc.Current_State__c ;
                             asHis.currentStreetAddress = arc.Current_Street_Address__c ;
                             asHis.currentZipcode = arc.Current_Zipcode__c ;
                            asHis.latestAPIRespId = arc.Id;
                            latestAPIRespId = arc.Id;
                            asHis.currentLocationId = arc.CurrentLocationId__c;
                            asHis.facilityLocation = arc.Facility_Location__c;
                            // ==== Addition of battery ===========

                            asHis.battery = arc.Battery__c!=null ? ''+arc.Battery__c : asHis.battery;
                            asHis.estBattPct= arc.EstBattPct__c!=null ? arc.EstBattPct__c+'%' :asHis.estBattPct;

                            //=======================================
                            asHis.locationList.add(lw);
                            daysTime += dwellTime(asHis.startTimeTS, arc.Timestamp_DateTime__c);
                            lastLocation = arc.Current_Location_Address__c;
                            currentLocAHCID = arc.CurrentLocationId__c != null ? arc.CurrentLocationId__c : null;
                            lastconnect = lastconnect > asHis.startTime && asHis.startTime != null ? lastconnect : asHis.startTime;
                            Sttime = Sttime < asHis.startTime && asHis.startTime != null ? Sttime : asHis.startTime;
                            if(arc.Business_Name__c != null){
                                asHis.businessName = arc.Business_Name__c;
                                asHis.businessLat= arc.Business_Location__Latitude__s;
                                asHis.businessLng= arc.Business_Location__Longitude__s;
                                asHis.businessPlaceId = arc.Business_Place_Id__c;
                            }
                            
                            
                            if(arc.Timestamp_Date_Time_Device_Status__c != null){
                                system.debug(cnt +' : '+arc.Timestamp_Date_Time_Device_Status__c);
                                Map<String,Datetime> timeMap = new Map<String,Datetime>();
                                Datetime devStartTime = asHis.startTime;
                                DateTime devEndTime= asHis.endTime;
                                DateTime createdDate = arc.CreatedDate;
                                if(ahcDevMap.containsKey(cnt)){
                                    timeMap = ahcDevMap.get(cnt);
                                    devStartTime = timeMap.containsKey('startTime') ? timeMap.get('startTime') : devStartTime;
                                    devEndTime = timeMap.containsKey('endTime') ? timeMap.get('endTime'): devEndTime;
                                    createdDate = timeMap.containsKey('createdDate') ? timeMap.get('createdDate'): devEndTime;
                                } 
                                devStartTime = (devStartTime == null || devStartTime > arc.Timestamp_Date_Time_Device_Status__c ) ? arc.Timestamp_Date_Time_Device_Status__c : devStartTime;
                                devEndTime = (devEndTime == null || devEndTime < arc.Timestamp_Date_Time_Device_Status__c) ? arc.Timestamp_Date_Time_Device_Status__c : devEndTime;
                                createdDate = (createdDate == null || createdDate < arc.CreatedDate) ? arc.CreatedDate : createdDate;
                                system.debug(cnt+' startTime: '+ devStartTime + 'endTime: '+devEndTime + 'createdDate'+createdDate);
                                timeMap.put('startTime',devStartTime);
                                timeMap.put('endTime',devEndTime);
                                timeMap.put('createdDate',createdDate);
                                ahcDevMap.put(cnt,timeMap);
                            }
                        }
                    else {
                        asHis = assetHistoryMap.get(cnt);
                        locationWrapper lw = createLocationWrapper(arc,cnt);
                        asHis.latitude = arc.Latitude__c != null ? arc.Latitude__c : asHis.latitude;
                        asHis.longitude = arc.Longitude__c != null ? arc.Longitude__c : asHis.longitude;
                        asHis.endTime = arc.Timestamp_DateTime__c != null ? arc.Timestamp_DateTime__c : asHis.endTime;
                        asHis.endTimeTS = arc.Timestamp_DateTime__c != null ? arc.Timestamp_DateTime__c : asHis.endTimeTS;
                        asHis.altitude = arc.Alt__c != null ? arc.Alt__c : asHis.altitude;
                        asHis.Location = arc.Location__c != null ? arc.Location__c : asHis.Location;
                        asHis.messageType = arc.Message_Type__c != null ? arc.Message_Type__c : asHis.messageType;
                        asHis.facilityLocation = arc.Facility_Location__c != null ? arc.Facility_Location__c : asHis.facilityLocation;
                        // ==== Addition of battery ===========

                        asHis.battery = arc.Battery__c!=null ? ''+arc.Battery__c : asHis.battery;
                        asHis.estBattPct= arc.EstBattPct__c!=null ? arc.EstBattPct__c+'%' :asHis.estBattPct;

                        //=======================================
                        asHis.dwellTime = getDwellTime(asHis.startTimeTS, arc.Timestamp_DateTime__c);
                        daysTime = dwellTime(asHis.startTimeTS, arc.Timestamp_DateTime__c);
                        AHLocation = arc.Location__c != null ? arc.Location__c : AHLocation;
                        asHis.accuracy = arc.Accuracy_meters__c != null ? arc.Accuracy_meters__c : asHis.accuracy;
                        asHis.currLocationAddress = arc.Current_Location_Address__c != null ? arc.Current_Location_Address__c : asHis.currLocationAddress;
                         asHis.currentCountry = arc.Current_Country__c != null ? arc.Current_Country__c : asHis.currentCountry;
                         asHis.currentState = arc.Current_State__c != null ? arc.Current_State__c : asHis.currentState;
                         asHis.currentCity = arc.Current_City__c != null ? arc.Current_City__c : asHis.currentCity;
                         asHis.currentStreetAddress = arc.Current_Street_Address__c != null ? arc.Current_Street_Address__c : asHis.currentStreetAddress;
                         asHis.currentZipcode = arc.Current_Zipcode__c != null ? arc.Current_Zipcode__c : asHis.currentZipcode;
                        asHis.latestAPIRespId = arc.Id != null ? arc.Id : asHis.latestAPIRespId;
                        latestAPIRespId = arc.Id != null ? arc.Id : latestAPIRespId;
                        asHis.currentLocationId = arc.CurrentLocationId__c != null ? arc.CurrentLocationId__c : asHis.currentLocationId;
                        lastLocation = arc.Current_Location_Address__c != null ? arc.Current_Location_Address__c : lastLocation;
                        currentLocAHCID = arc.CurrentLocationId__c != null ? arc.CurrentLocationId__c : currentLocAHCID;
                        lastconnect = lastconnect > asHis.startTime && asHis.startTime != null ? lastconnect : asHis.startTime;
                        Sttime = Sttime < asHis.startTime && asHis.startTime != null ? Sttime : asHis.startTime;
                        asHis.locationList.add(lw);
                        asHis.latestAPIRespId = arc.Id;
                        latestAPIRespId = arc.Id;
                        if(arc.Business_Name__c != null){
                            asHis.businessName = arc.Business_Name__c;
                            asHis.businessLat= arc.Business_Location__Latitude__s;
                            asHis.businessLng= arc.Business_Location__Longitude__s;
                            asHis.businessPlaceId = arc.Business_Place_Id__c;
                        }
                        
                        if(arc.Timestamp_Date_Time_Device_Status__c != null){
                            system.debug(cnt +' : '+arc.Timestamp_Date_Time_Device_Status__c);
                            Map<String,Datetime> timeMap = new Map<String,Datetime>();
                            Datetime devStartTime = asHis.startTime;
                            DateTime devEndTime= asHis.endTime;
                            DateTime createdDate = arc.CreatedDate;
                            if(ahcDevMap.containsKey(cnt)){
                                timeMap = ahcDevMap.get(cnt);
                                devStartTime = timeMap.containsKey('startTime') ? timeMap.get('startTime') : devStartTime;
                                devEndTime = timeMap.containsKey('endTime') ? timeMap.get('endTime'): devEndTime;
                                createdDate = timeMap.containsKey('createdDate') ? timeMap.get('createdDate'): devEndTime;
                            } 
                            devStartTime = (devStartTime == null || devStartTime > arc.Timestamp_Date_Time_Device_Status__c ) ? arc.Timestamp_Date_Time_Device_Status__c : devStartTime;
                            devEndTime = (devEndTime == null || devEndTime < arc.Timestamp_Date_Time_Device_Status__c) ? arc.Timestamp_Date_Time_Device_Status__c : devEndTime;
                            createdDate = (createdDate == null || createdDate < arc.CreatedDate) ? arc.CreatedDate : createdDate;
                            system.debug(cnt+' startTime: '+ devStartTime + 'endTime: '+devEndTime + 'createdDate'+createdDate);
                            timeMap.put('startTime',devStartTime);
                            timeMap.put('endTime',devEndTime);
                            timeMap.put('createdDate',createdDate);
                            ahcDevMap.put(cnt,timeMap);
                        }
                    }
                    asHis.days = daysTime;
                    assetHistoryMap.put(cnt, asHis);
                }                 
            }
            else if(apiRespChildDevStatMap.size() > 0) {
                DateTime devStatusDt;
                List<assetHistory> assetHistoryDevStatus = new List<assetHistory>();
                API_Response_Childs__c arcDev;
                for(Id key : apiRespChildDevStatMap.keySet()) {
                    API_Response_Childs__c arc = apiRespChildDevStatMap.get(key);
                    if(devStatusDt == null) {
                        devStatusDt = arc.Timestamp_Date_Time_Device_Status__c; 
                        arcDev = arc;
                    }
                    else if (devStatusDt < arc.Timestamp_Date_Time_Device_Status__c) {
                        devStatusDt = arc.Timestamp_Date_Time_Device_Status__c;                        
                        arcDev = arc;
                    }
                }
                assetHistory ah = new assetHistory();
                ah.updateAssetOnly = true;
                ah.batteryPercent = arcDev.EstBattPct__c!=null ? arcDev.EstBattPct__c+'%' :null;
                ah.cellularSignal = arcDev.Signal__c!=null ? (decimal)arcDev.Signal__c : null;
                ah.battery = arcDev.Battery__c!=null ? ''+arcDev.Battery__c : null;
                ah.estBattPct= arcDev.EstBattPct__c!=null ? arcDev.EstBattPct__c+'%' :null;
                ah.powerUpTime = arcDev.PowerUptime__c!=null ? ''+arcDev.PowerUptime__c :null;
                ah.rsrp = arcDev.rsrp__c!=null ? ''+arcDev.rsrp__c : null;
                ah.Devicetime=arcDev.Timestamp_Date_Time_Device_Status__c !=null ? arcDev.Timestamp_Date_Time_Device_Status__c :null;
                ah.rssi = arcDev.rssi__c!=null ? ''+arcDev.rssi__c : null;
                ah.rsrq = arcDev.rsrq__c!=null ? ''+arcDev.rsrq__c : null;
                //Changes start 356 - Asset History Lookup field are not getting populated in ARC only for Device status
                locationWrapper lw = createLocationWrapper(arcDev,cnt);
                ah.locationList.add(lw);
                //Changes end 356 - Asset History Lookup field are not getting populated in ARC only for Device status
                assetHistoryDevStatus.add(ah);
                return assetHistoryDevStatus;
            }
            
            
            String endTime = '';
            Map<String, String> currentLocMap = getLastKnownLocation(assetId);
            String currentAccLocationId;
            String currentAccLocation;
            if(currentLocMap.size() > 0) {
                currentAccLocationId = (new List<string>(currentLocMap.keySet()))[0];
                currentAccLocation = currentLocMap.get(currentAccLocationId);                
            }
            
            for(Integer key : assetHistoryMap.keySet()) {
                assetHistory assHis = assetHistoryMap.get(key);
                if(getDataForMap == false) {
                    Boolean valueChanged = false;
                    String currentLoc = '';
                    String currentLocId = '';
                    
                    if(assHis.location != 'In Transit') {
                        valueChanged = true;
                        currentLocId = currentAccLocationId;
                        currentLoc = currentAccLocation;
                        currentAccLocation = assHis.location;
                        currentAccLocationId = assHis.currentLocationId;
                    }
                    assHis.lastKnownLocation = valueChanged ? currentLoc : currentAccLocation;
                    assHis.lastKnownLocationId = valueChanged ? currentLocId : currentAccLocationId;
                    
                    assetHistory assHisPrev;
                    if(key > 0) {
                        assHisPrev = assetHistoryMap.get(key - 1);
                        assHisPrev.endTime = assHis.startTime;
                        assHisPrev.endTimeTS = assHis.startTimeTS;
                        assHisPrev.days = dwellTime(assHisPrev.startTimeTS, assHis.startTimeTS);
                        assHisPrev.dwellTime = getDwellTime(assHisPrev.startTimeTS, assHis.startTimeTS);
                    }
                }
                
            }
            if(apiRespChildDevStatMap.keySet().size()>0) {
                Set<Id> arcDevPickedIds = new Set<Id>();
                Set<DateTime> devDTPickedSet = new Set<DateTime>();
                DateTime previousAHCTime = lastDeviceTS != null ? lastDeviceTS : null;
                for(Integer key : assetHistoryMap.keySet()) {
                    assetHistory assHis = assetHistoryMap.get(key);
                    List<API_Response_Childs__c> DevArcList = New List<API_Response_Childs__c>();
                    DateTime deviceStatusTS = null;
                    
                    for(Id arcKey : apiRespChildDevStatMap.KeySet()) {
                        API_Response_Childs__c arc = apiRespChildDevStatMap.get(arcKey);
                        
                        if(ahcDevMap.containsKey(key)){
                            
                            Map<String,Datetime> timeMap = ahcDevMap.get(key);
                            Datetime devStartTime = timeMap.get('startTime');
                            Datetime devEndTime = timeMap.get('endTime');
                            Datetime createdDate =timeMap.get('createdDate');
                            System.debug(Key + 'Starttime: '+timeMap.get('startTime')+ ' EndTime '+ timeMap.get('endTime') + ' createdDate: ' + timeMap.get('createdDate') + ' Last DevTime: '+previousAHCTime);
                            Datetime formattedDevTime = DateTime.newInstanceGmt(arc.Timestamp_Date_Time_Device_Status__c.year(), arc.Timestamp_Date_Time_Device_Status__c.month(), arc.Timestamp_Date_Time_Device_Status__c.day(), arc.Timestamp_Date_Time_Device_Status__c.hour(), arc.Timestamp_Date_Time_Device_Status__c.minute(), 0);
                            Datetime formattedCreatedTime = DateTime.newInstanceGmt(createdDate.year(), createdDate.month(),createdDate.day(), createdDate.hour(), createdDate.minute(), 0);
                            if(((previousAHCTime == null) || (previousAHCTime < arc.Timestamp_Date_Time_Device_Status__c)) &&((formattedDevTime <= formattedCreatedTime )||  (arc.Timestamp_Date_Time_Device_Status__c <= devEndTime)) && !arcDevPickedIds.contains(arc.Id) && !devDTPickedSet.contains(arc.Timestamp_Date_Time_Device_Status__c)){
                                previousAHCTime = ((previousAHCTime == null) || (arc.Timestamp_Date_Time_Device_Status__c > previousAHCTime)) ? arc.Timestamp_Date_Time_Device_Status__c : previousAHCTime;
                                arcDevPickedIds.add(arc.id);
                                devDTPickedSet.add(arc.Timestamp_Date_Time_Device_Status__c);
                                DevArcList.add(arc);
                                API_Response_Childs__c firstDevArc;
                                system.debug(key+' : '+arc.Timestamp_Date_Time_Device_Status__c);
                                if (!lowDevArcMap.containsKey(key)) {
                                    firstDevArc = arc;  // No entry in the map, use arc
                                } else {
                                    API_Response_Childs__c existingArc = lowDevArcMap.get(key);
                                    
                                    if (existingArc != null && existingArc.Timestamp_Date_Time_Device_Status__c < arc.Timestamp_Date_Time_Device_Status__c) {
                                        firstDevArc = existingArc;  // The existing one is newer
                                    } else {
                                        firstDevArc = arc;  // The current arc is newer
                                    }
                                }
                                
                                lowDevArcMap.put(key, firstDevArc);
                                
                                API_Response_Childs__c LastDevArc;
                                if (!ApiResChilDevStatMap.containsKey(key)) {
                                    LastDevArc = arc;  // No entry in the map, use arc
                                } else {
                                    API_Response_Childs__c existingArc = ApiResChilDevStatMap.get(key);
                                    
                                    if (existingArc != null && existingArc.Timestamp_Date_Time_Device_Status__c > arc.Timestamp_Date_Time_Device_Status__c) {
                                        LastDevArc = existingArc;  // The existing one is newer
                                    } else {
                                        LastDevArc = arc;  // The current arc is newer
                                    }
                                }
                                
                                ApiResChilDevStatMap.put(key, LastDevArc);
                            }
                        }
                        if(PowerResetArc != null && PowerResetArc.id == arc.Id){
                            system.debug(key+' : '+arc.Timestamp_Date_Time_Device_Status__c);
                            if(assHis.StartTime == Sttime &&(DevArcList.size() == 0 || !DevArcList.contains(PowerResetArc)) && !arcDevPickedIds.contains(arc.Id) && !devDTPickedSet.contains(arc.Timestamp_Date_Time_Device_Status__c)){
                                previousAHCTime = ((previousAHCTime == null) ||( arc.Timestamp_Date_Time_Device_Status__c > previousAHCTime)) ? arc.Timestamp_Date_Time_Device_Status__c : previousAHCTime;
                                arcDevPickedIds.add(arc.id);
                                devDTPickedSet.add(arc.Timestamp_Date_Time_Device_Status__c);
                                DevArcList.add(PowerResetArc);
                                API_Response_Childs__c LastDevArc;
                                if (!ApiResChilDevStatMap.containsKey(key)) {
                                    LastDevArc = arc;  // No entry in the map, use arc
                                } else {
                                    API_Response_Childs__c existingArc = ApiResChilDevStatMap.get(key);
                                    
                                    if (existingArc != null && existingArc.Timestamp_Date_Time_Device_Status__c > arc.Timestamp_Date_Time_Device_Status__c) {
                                        LastDevArc = existingArc;  // The existing one is newer
                                    } else {
                                        LastDevArc = arc;  // The current arc is newer
                                    }
                                }
                                
                                ApiResChilDevStatMap.put(key, LastDevArc);
                            }
                        }
                        if( ((previousAHCTime == null) ||(previousAHCTime < arc.Timestamp_Date_Time_Device_Status__c)) && lastconnect == assHis.StartTime && arc.Timestamp_Date_Time_Device_Status__c >= assHis.endTime && !arcDevPickedIds.contains(arc.Id) && !devDTPickedSet.contains(arc.Timestamp_Date_Time_Device_Status__c)) {
                            previousAHCTime = ((previousAHCTime == null) || (arc.Timestamp_Date_Time_Device_Status__c > previousAHCTime)) ? arc.Timestamp_Date_Time_Device_Status__c : previousAHCTime;
                            arcDevPickedIds.add(arc.id);
                            devDTPickedSet.add(arc.Timestamp_Date_Time_Device_Status__c);
                            DevArcList.add(arc);
                            API_Response_Childs__c firstDevArc;
                            system.debug(key+' : '+arc.Timestamp_Date_Time_Device_Status__c);
                            if (!lowDevArcMap.containsKey(key)) {
                                firstDevArc = arc;  // No entry in the map, use arc
                            } else {
                                API_Response_Childs__c existingArc = lowDevArcMap.get(key);
                                
                                if (existingArc != null && existingArc.Timestamp_Date_Time_Device_Status__c < arc.Timestamp_Date_Time_Device_Status__c) {
                                    firstDevArc = existingArc;  // The existing one is newer
                                } else {
                                    firstDevArc = arc;  // The current arc is newer
                                }
                            }
                            
                            lowDevArcMap.put(key, firstDevArc);
                            
                            API_Response_Childs__c LastDevArc;
                            if (!ApiResChilDevStatMap.containsKey(key)) {
                                LastDevArc = arc;  // No entry in the map, use arc
                            } else {
                                API_Response_Childs__c existingArc = ApiResChilDevStatMap.get(key);
                                
                                if (existingArc != null && existingArc.Timestamp_Date_Time_Device_Status__c > arc.Timestamp_Date_Time_Device_Status__c) {
                                    LastDevArc = existingArc;  // The existing one is newer
                                } else {
                                    LastDevArc = arc;  // The current arc is newer
                                }
                            }
                            
                            ApiResChilDevStatMap.put(key, LastDevArc);
                        }
                        
                        
                    }
                    if(DevArcList.size()> 0){
                        AHCDevList.put(key,DevArcList);
                        system.debug(AHCDevList);
                    }
                }
            }
            API_Response_Childs__c arcDev;
            assetHistory ahLoc;
            Asset_History_Custom__c tempLoc;
            boolean fromArc;
            Decimal AssetPowerUpTime;
            Boolean powerResetOccurred;
            DateTime powerResetTime;
            
            for(Integer i : assetHistoryMap.KeySet()){ //looping all loc ahc
                if(ApiResChilDevStatMap.containskey(i)){
                    arcDev = ApiResChilDevStatMap.get(i);
                    System.debug(i+' '+ arcDev.Timestamp_Date_Time_Device_Status__c);
                }
                else if(ApiResChilDevStatMap.containskey(i+1)){
                    arcDev = lowDevArcMap.get(i+1);
                    System.debug(i+' '+ arcDev.Timestamp_Date_Time_Device_Status__c);
                    List<API_Response_Childs__c> devARC = new List<API_Response_Childs__c>();
                    devARC.add(arcDev);
                    AHCDevList.put(i,devARC);
                    
                }
                else if(i == 0 && !ApiResChilDevStatMap.containskey(i)) { //take Dev details from last AHC 
                    tempLoc = LatestAHCRec.isEmpty() ? null : LatestAHCRec[0];
                    // System.debug(i+' '+ tempLoc.Device_Status_Time__c);
                }
                ahLoc = assetHistoryMap.get(i);
                assetHistory prevAhc = assetHistoryMap.get(i - 1);
                if(arcDev != null) { //updating the dev Stus details in Loc AssetHistory
                    ahLoc.batteryPercent = arcDev.EstBattPct__c!=null ? arcDev.EstBattPct__c+'%' :null;
                    ahLoc.cellularSignal = arcDev.Signal__c!=null ? (decimal)arcDev.Signal__c : null;
                    ahLoc.battery = arcDev.Battery__c!=null ? ''+arcDev.Battery__c : null;
                    ahloc.estBattPct= arcDev.EstBattPct__c!=null ? arcDev.EstBattPct__c+'%' :null;
                    ahLoc.powerUpTime = arcDev.PowerUptime__c!=null ? ''+arcDev.PowerUptime__c :ahLoc.powerUpTime;
                    ahLoc.rsrp = arcDev.rsrp__c!=null ? ''+arcDev.rsrp__c : null;
                    ahLoc.Devicetime=arcDev.Timestamp_Date_Time_Device_Status__c !=null ? arcDev.Timestamp_Date_Time_Device_Status__c :null;
                    ahLoc.rssi = arcDev.rssi__c!=null ? ''+arcDev.rssi__c : null;
                    ahLoc.rsrq = arcDev.rsrq__c!=null ? ''+arcDev.rsrq__c : null;
                    
                    Integer count = 0;
                    //added from fullcopy
                    if(arcDev.Latitude__c == null && arcDev.Longitude__c == null && arcDev.Current_Location_Address__c == null){
                        locationWrapper devLw = createLocationWrapper(arcDev,Null);
                        ahLoc.locationList.add(devLw);
                    }
                    
                    List<API_Response_Childs__c> devStatLoc = AHCDevList.get(integer.valueof(ahLoc.count));//ApiResChilDevStatMap.get(i);
                    system.debug(devStatLoc);
                    if(devStatLoc != null) {
                        if((i == 0 && count == 0) || AssetPowerUpTime == null) {
                            AssetPowerUpTime = lastPowerUpTime;
                            powerResetOccurred = lastPowerResetOccurred != True ? false : lastPowerResetOccurred;
                            powerResetTime = lastPowerResetTime;
                        }
                        ahLoc = setPowerUpTimeAndBattery(assetSumm, AssetPowerUpTime, powerResetOccurred, powerResetTime, ahLoc, devStatLoc);
                        
                        AssetPowerUpTime = ahLoc.powerUpTime != null ? Decimal.valueOf(ahLoc.powerUpTime) : null;
                        powerResetOccurred = ahLoc.powerResetOccurred;
                        powerResetTime = ahLoc.powerResetTime;
                        count++;
                    }
                    ahLoc.powerUptime = arcDev.PowerUptime__c != null ? string.valueof(arcDev.PowerUptime__c) : null;
                    if(ahLoc.powerResetOccurred == false)
                        ahLoc.batteryPercent = arcDev.EstBattPct__c!=null ? ''+arcDev.EstBattPct__c +'%': null;
                    else if(ahLoc.powerResetOccurred == true && assetSumm.Battery_Replaced_Date__c == null){
                        Decimal percentage = (100 - ((date.newinstance(assetSumm.CreatedDate.year(), assetSumm.CreatedDate.month(), assetSumm.CreatedDate.day()).daysBetween(ahLoc.endTimeTS.date()))* 0.054795));
                        ahLoc.batteryPercent = percentage != null && percentage > 0 ? '' + (100 - ((date.newinstance(assetSumm.CreatedDate.year(), assetSumm.CreatedDate.month(), assetSumm.CreatedDate.day()).daysBetween(ahLoc.endTimeTS.date()))* 0.054795)) +'%' : '' +0 +'%'; 
                    }
                    /*else if (ahLoc.powerResetOccurred == true &&
                     ahLoc.powerResetTime != null &&
                     assetSumm.Battery_Replaced_Date__c == null) {

                   // Start battery drain from power reset time
                    Date startDate = ahLoc.powerResetTime.date();
                    Date endDate   = ahLoc.endTimeTS.date();

                    Integer days = startDate.daysBetween(endDate);

                    Decimal percentage = 100 - (days * 0.054795);

                    ahLoc.batteryPercent =
                    percentage > 0 ? String.valueOf(percentage.setScale(2)) + '%' : '0%';
                 }*/
                    else if(ahLoc.powerResetOccurred == true && ahLoc.powerResetTime != null  && assetSumm.Battery_Replaced_Date__c != null && 
                            assetSumm.Battery_Replaced_Date__c.addDays(7) <  date.newinstance(ahLoc.powerResetTime.year(), ahLoc.powerResetTime.month(), ahLoc.powerResetTime.day())){
                        Decimal percentage = (100 - ((assetSumm.Battery_Replaced_Date__c.daysBetween(ahLoc.endTimeTS.date())) * 0.054795));
                        ahLoc.batteryPercent = percentage != null && percentage > 0 ? '' + (100 - ((assetSumm.Battery_Replaced_Date__c.daysBetween(ahLoc.endTimeTS.date())) * 0.054795)) +'%':''+0 +'%';
                            }
                    else
                        ahLoc.batteryPercent = ''+ arcDev.EstBattPct__c+'%';
                }
                else if(prevAhc != null){
                    ahLoc.batteryPercent = prevAhc.batteryPercent!=null ? prevAhc.batteryPercent+'%' :null;
                    ahLoc.cellularSignal = prevAhc.cellularSignal!=null ? (decimal)prevAhc.cellularSignal : null;
                    ahLoc.battery = prevAhc.battery!=null ?prevAhc.battery : null;
                    ahLoc.powerUpTime = prevAhc.powerUpTime!=null ?prevAhc.powerUpTime : null;
                    ahloc.estBattPct = prevAhc.estBattPct!=null ? prevAhc.estBattPct+'%' :null;
                    ahLoc.rsrp = prevAhc.rsrp!=null ? prevAhc.rsrp : null;
                    ahLoc.Devicetime=prevAhc.Devicetime !=null ? prevAhc.Devicetime :null;
                    ahLoc.rssi = prevAhc.rssi!=null ? prevAhc.rssi : null;
                    ahLoc.rsrq = prevAhc.rsrq!=null ? prevAhc.rsrq : null;
                    ahLoc.powerResetOccurred= prevAhc.powerResetOccurred !=null ? prevAhc.powerResetOccurred : null;
                    ahLoc.powerResetTime = prevAhc.powerResetTime !=null ?prevAhc.powerResetTime : null; 
                } 
                else if(tempLoc != null) { //updating the dev Stus details(Taken from last LocAHC) in Loc AssetHistory 
                    ahLoc.batteryPercent = tempLoc.Est_Remaining_Battery__c!=null ? tempLoc.Est_Remaining_Battery__c+'%' :null;
                    ahLoc.cellularSignal = tempLoc.Cellular_Signal__c!=null ? (decimal)tempLoc.Cellular_Signal__c : null;
                    ahLoc.battery = tempLoc.Battery_Voltage__c!=null ? ''+tempLoc.Battery_Voltage__c : null;
                    ahLoc.powerUpTime = tempLoc.PowerUptime__c!=null ? ''+tempLoc.PowerUptime__c : null;
                    ahloc.estBattPct = tempLoc.estBattPct__c!=null ? tempLoc.estBattPct__c+'%' :null;
                    ahLoc.rsrp = tempLoc.rsrp__c!=null ? ''+tempLoc.rsrp__c : null;
                    ahLoc.Devicetime=tempLoc.Device_Status_Time__c !=null ? tempLoc.Device_Status_Time__c :null;
                    ahLoc.rssi = tempLoc.rssi__c!=null ? ''+tempLoc.rssi__c : null;
                    ahLoc.rsrq = tempLoc.rsrq__c!=null ? ''+tempLoc.rsrq__c : null;
                    ahLoc.powerResetOccurred= tempLoc.Power_Reset_Occurred__c !=null ?tempLoc.Power_Reset_Occurred__c : null;
                    ahLoc.powerResetTime = tempLoc.Power_Reset_Time__c !=null ?tempLoc.Power_Reset_Time__c : null;
                    tempLoc = null;
                }
                arcDev = null;                            
                ahLoc.locationList.sort();
            }
            
            
            
            assetHistoryList = assetHistoryMap.values();
            assetHistoryList.sort();
            
        }
        
        return assetHistoryList;
    }
    
    public static String getDwellTime(DateTime t1, DateTime t2) {
        Long dt1Long = t1.getTime();
        Long dt2Long = t2.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;
        minutes = Math.mod(minutes,60);
        hours = Math.mod(hours,24);
        String dwellTs = '';
        if(days > 0)
            dwellTs += days + ' days ';
        if(hours > 0)
            dwellTs += hours+' hours ';
        dwellTs += minutes+' min ';
        return dwellTs;
    }
    
    public static Decimal dwellTime(DateTime t1, DateTime t2) {
        Decimal dt1Long = t1.getTime();
        Decimal dt2Long = t2.getTime();
        Decimal milliseconds = dt2Long - dt1Long;
        Decimal seconds = milliseconds / 1000;
        Decimal minutes = seconds / 60;
        Decimal hours = minutes / 60;
        Decimal days = hours.divide(24, 2);
        return days;
    }
    
    public static locationWrapper createLocationWrapper(API_Response_Childs__c arc,Integer cnt) {
        locationWrapper lw = new locationWrapper();
        lw.locationId = arc.Id;
        lw.locationName = arc.Name;
        lw.loctimestampDT = arc.Timestamp_DateTime__c;
        lw.islocation = true;
        lw.locTimestamp = arc.Timestamp__c;
        lw.apiRespId = arc.Api_Response__c;
        lw.count = cnt;
        return lw;
    }
    
    public static Map<String, String> getLastKnownLocation(String assetSummId) {
        Map<String, String> returnMap = new Map<String, String>();
        String lastKnownLocation = '', lastKnownLocationId = '';
        LatestAHCRec = [Select Asset__c,Asset__r.Power_Reset_Time__c,Asset__r.Power_Reset_Occurred__c, End_Time__c, Location__c, Power_Reset_Occurred__c,
                        Power_Reset_Time__c, PowerUpTime__c, Last_Known_Location__c, 
                        currentLocationId__c,Est_Remaining_Battery__c,estBattPct__c, Last_Known_Location_Lookup__c,
                        Cellular_Signal__c,Battery_Voltage__c,Device_Status_Time__c,rsrp__c,rssi__c,rsrq__c from Asset_History_Custom__c 
                        where Asset__c = :assetSummId and Recordtype.developerName = 'Location' 
                        order by End_Time__c desc limit 1];
        Map<string, String> assetSumMap = new Map<String, String>();
        for(Asset_History_Custom__c ag: LatestAHCRec) {
            lastPowerResetTime = ag.Power_Reset_Time__c;
            lastPowerResetOccurred = ag.Power_Reset_Occurred__c;
            lastPowerUpTime = ag.PowerUpTime__c;
            if(ag.Location__c != 'In Transit') {
                lastKnownLocation = ag.Location__c;
                lastKnownLocationId = ag.currentLocationId__c;
            }
            else {
                lastKnownLocation = ag.Last_Known_Location__c;
                lastKnownLocationId = ag.Last_Known_Location_Lookup__c;
            }
            if(ag.Device_Status_Time__c != null && ahcDevMap.containsKey(0)){
                lastDeviceTS = ag.Device_Status_Time__c;
            }
        }
        if(lastKnownLocationId != ''){
            returnMap.put(lastKnownLocationId,lastKnownLocation); 
        }        
        return returnMap;
    }
    
    public static assetHistory setPowerUpTimeAndBattery(Asset ast,Decimal assetPowerUpTime,Boolean powerResetOccurred,
                                                        DateTime powerResetTime,assetHistory ah, List<API_Response_Childs__c> devStatLoc) {
                                                            powerResetOccurred = powerResetOccurred != True ? False : True;
                                                            Decimal DevStatusPowerUpTime = assetPowerUpTime;
                                                            DateTime createdDate = powerResetTime;
                                                            
                                                            // system.debug(ast);
                                                            // system.debug(devStatLoc);
                                                            
                                   
                                                            if(ast != null && ast.Battery_Replaced_Date__c > powerResetTime) {
                                                                ah.powerResetOccurred = false;
                                                                powerResetOccurred = false;
                                                                ah.powerResetTime = null;
                                                             // return ah;//ADDED
                                                            }
                                                            /*if (powerResetOccurred == true) {
                                                             ah.powerResetOccurred = true;
                                                             ah.powerResetTime = powerResetTime;
                                                             return ah;
                                                            }*///ADDED
                                                            
                                                            if(powerResetOccurred == false) { // commenting if-else conditions cause these condition are causing power reset occured to true for upcoming AHC once actualhy power reset occures
                                                                for(API_Response_Childs__c arc: devStatLoc){
                                                                    Date arcTimestampDate = arc.Timestamp_DateTime__c.Date();
                                                                    if(((DevStatusPowerUpTime != null && arc.PowerUptime__c != null && DevStatusPowerUpTime > arc.PowerUptime__c &&
                                                                        String.valueOf(DevStatusPowerUpTime).length() > String.valueOf(arc.PowerUptime__c).length() )
                                                                       || (arc.Timestamp_Device_Status__c != null && String.valueOf(arc.Timestamp_Device_Status__c).startsWith('1104')) )
                                                                       && (ast.Battery_Replaced_Date__c==null || ast.Battery_Replaced_Date__c.addDays(7) < arcTimestampDate))  {
                                                                           ah.powerResetOccurred = true;
                                                                           ah.powerResetTime = arc.CreatedDate;
                                                                           DevStatusPowerUpTime = arc.PowerUptime__c;
                                                                           createdDate = arc.CreatedDate;
                                                                           break;
                                                                       }
                                                                    DevStatusPowerUpTime = arc.PowerUptime__c;
                                                                    createdDate = arc.CreatedDate;
                                                                }
                                                            }
                                                            else {
                                                                ah.powerResetOccurred = powerResetOccurred;
                                                                ah.powerResetTime = powerResetTime;
                                                            }
                                                            
                                                            createdDate = powerResetTime != null ? powerResetTime : createdDate;
                                                            //Calculating
                                                            
                                                            return ah;                                                            
                                                        }
    
    public class assetHistory implements Comparable {
        public Boolean updateAssetOnly = false;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public Datetime startTime;
        @AuraEnabled
        public Datetime endTime;
        public String currentLocationId;
        @AuraEnabled
        public String lastKnownLocation;
        @AuraEnabled
        public String lastKnownLocationId;
        public DateTime startTimeTS;
        public DateTime endTimeTS;
        @AuraEnabled
        public String latestAPIRespId;
        @AuraEnabled
        public String dwellTime;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String latitude;
        @AuraEnabled
        public String businessPlaceId;
        @AuraEnabled
        public String longitude;
        @AuraEnabled
        public String businessName;
        @AuraEnabled
        public String currLocationAddress;
        @AuraEnabled
        public String currentCountry;
        @AuraEnabled
        public String currentState;
        @AuraEnabled
        public String currentCity;
        @AuraEnabled
        public String currentStreetAddress;
        @AuraEnabled
        public String currentZipcode;
        @AuraEnabled
        public List<LocationWrapper> locationList = new List<LocationWrapper>();
        @AuraEnabled
        public Decimal altitude;
        @AuraEnabled
        public String batteryPercent;
        @AuraEnabled
        public String estBattPct;
        @AuraEnabled
        public decimal cellularSignal;
        @AuraEnabled
        public decimal accuracy;
        @AuraEnabled
        public decimal businessLat;
        @AuraEnabled
        public decimal businessLng;
        @AuraEnabled
        public String messageType;
        @AuraEnabled
        public String c;
        @AuraEnabled
        public Boolean powerResetOccurred = false;
        @AuraEnabled
        public DateTime powerResetTime;
        @AuraEnabled
        public String battery;
        @AuraEnabled
        public String rsrp = '';
        @AuraEnabled
        public String rssi = '';
        @AuraEnabled
        public String rsrq = '';
        @AuraEnabled
        public String typeOfMovement;
        @AuraEnabled
        public String powerUpTime;
        @AuraEnabled
        public String facilityLocation;
        @AuraEnabled
        public Datetime DeviceTime;
        @AuraEnabled
        public Decimal days = 0;
        @AuraEnabled
        public Boolean expandRow = false;
        public Boolean stillInLocation = false;
        public Integer compareTo(Object otherAsset) {
            AssetHistory y = (AssetHistory)otherAsset;
            Integer ct = y.count;
            if(this.count > ct)
                return -1;
            return 1;
        }
        
    }
    
    public class locationWrapper implements Comparable {
        @AuraEnabled
        public String locationId;
        @AuraEnabled
        public String locationName;
        public String apiRespId;
        public Decimal locTimestamp;
        @AuraEnabled
        public datetime loctimestampDT;
        @AuraEnabled
        public Boolean islocation=false;
        
        @AuraEnabled
        Public Integer count;
        public Integer compareTo(Object otherlocation) {
            locationWrapper y = (locationWrapper)otherlocation;
            Decimal ct = y.locTimestamp;
            if(this.locTimestamp > ct)
                return -1;
            return 1;            
        }
    }
}