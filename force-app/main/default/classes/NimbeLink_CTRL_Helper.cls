public without sharing class NimbeLink_CTRL_Helper{

    // downstream customer attributes
    public static List<Nested_Geofence__mdt> nestedGeofences;
    public static Map<Id,Account> accmap;
    public static Map<String, String> srcMap;
    public static decimal poweruptime2;

    public static void parseresponse(Api_Response__c resp) {
        String deviceId;

        try{
            // initilize default response attributes 
            resp.Is_Nimbelink_Asset__c = true;
            resp.UpdateResponseToAsset__c = true;
            resp.Status__c    = 'PROCESSED';
            resp.BefAssetProcDttime__c = system.now(); 
            resp.BefAssetProcTime__c = (system.now().getTime()/1000);

            Asset asset = new Asset();
            accmap = new Map<Id,Account>();
            nestedGeofences = new List<Nested_Geofence__mdt>();    
            String requestBody = resp.Incoming_Messsage__c;

            srcMap = new Map<String, String>{'w' => 'wifi', 'c' => 'cellular', 'g' => 'gps'};

            if(requestBody != null){
                Map<String, Object> resMap = (Map<String, Object>)Json.deserializeUntyped(requestBody);

                if(resMap.containskey('message')){
                    Map<String, Object> msgMap = (Map<String, Object>) resMap.get('message');

                    if(msgMap.containskey('data') && msgMap.get('data') != null){
                        String jsonData = EncodingUtil.base64Decode((String) msgMap.get('data')).toString();    
                        NimblinkResponse resObj = (NimblinkResponse) JSON.deserialize(jsonData, NimblinkResponse.Class); 
                        //system.debug('###--resObj--'+ resObj); 

                        if(resObj.records != null && !resObj.records.isEmpty() && resObj.records[0].data != null){
                            deviceId = resObj.records[0].base.id;
                            asset = getasset(deviceId);

                            // updating device status
                             poweruptime2 =  asset.PowerUp_Time__c;
                            if(resObj.records[0].data.deviceStatus != null && !resObj.records[0].data.deviceStatus.isEmpty()){
                                asset = fillAssetDetails(asset, resObj.records[0].data.deviceStatus[0], resp);

                                // checking power reset occurred, IF true then update asset attributes
                               /* if(asset != null && !asset.Power_Reset_Occurred__c && resObj.records[0].data.deviceStatus[0].ts != null){
                                    asset = checkPowerResetOccured(resObj.records[0].data.deviceStatus[0], asset);
                                }*/
                            }    
                            
                            if(asset.Capture_Movement_Event__c == true && resObj.records[0].data.events != null && !resObj.records[0].data.events.isEmpty()){
                                capturingEvents.parseEventDataMethodNimblink(resObj.records[0].data.events, asset, resp.CreatedDate);
                            }

                            // processing loc and device status data
                            List<Asset_History_custom__c> achList = new List<Asset_History_custom__c>();
                            if(resObj.records[0].data.loc != null && !resObj.records[0].data.loc.isEmpty()){
                                achList = updateLocValues(resp, resObj.records[0].data.loc, asset, resObj.records[0].data.deviceStatus);    
                            }

                            // processing temperature data
                            list<Asset_History_custom__c> tempHistoryList = new list<Asset_History_custom__c>();    // list of ACH for storing temperature response
                            if(!asset.Capture_Temperature_Response__c && resObj.records[0].data.temp != null && !resObj.records[0].data.temp.isEmpty()){
                                achList =  updateTempValues(resObj.records[0].data.temp, achList, asset);
                            }else{
                                tempHistoryList = captureTempResponses(resp, resObj.records[0].data.temp, asset);
                            }

                            asset.Is_NimbeLink_Asset__c = true;
                            utilityclass.inventorycheck();  
                            if (!achList.isEmpty())
                            {upsert achList;
                              // checking for DwelDays scenario
                                checkForDwelDays(asset);                   
                            
                            }
                            update asset;   // updating asset
                            
                            asset x = new asset();
                   x  = [select id ,createddate,last_known_location__r.name,rsrp__c,rsrq__c,rssi__c,battery_voltage__c,src__c,signal__c ,
                          Battery_replaced_date__c,Power_reset_occurred__c,power_reset_time__c ,estbattpct__c ,powerup_time__c from Asset where id =: asset.id ];
                    if (!achList.isEmpty())
                        	 {if (achList[0].still_in_this_location__c == true)
                                {
                                  achList[0].last_known_location__c = x.Last_Known_Location__r.name;
                                  achList[0].battery_voltage__c = x.Battery_Voltage__c;
             					  achList[0].rsrp__c=x.rsrp__c;
             					  achList[0].rsrq__c = x.rsrq__c;
             					  achList[0].rssi__c = x.rssi__c;
             					  achList[0].message_type__c = x.src__c;
             					  achList[0].cellular_signal__c = x.signal__c;
                                  if(x.Power_Reset_Occurred__c == True && x.Battery_Replaced_Date__c == null)
                       {
                        achList[0].Est_Remaining_Battery__c = 100 - ((date.newinstance(x.CreatedDate.year(), x.CreatedDate.month(), x.CreatedDate.day()).daysBetween(System.today()))* 0.054795); 
                        } 
                                 else 
                         if(x.Power_Reset_Occurred__c == True && x.Power_Reset_Time__c != null  && x.Battery_Replaced_Date__c != null && x.Battery_Replaced_Date__c <  date.newinstance(x.Power_Reset_Time__c.year(), x.Power_Reset_Time__c.month(), x.Power_Reset_Time__c.day()))
                     {
                        achList[0].Est_Remaining_Battery__c = (100 - ((x.Battery_Replaced_Date__c.daysBetween(System.today())) * 0.054795));
                     } 
                                 else
                     {
                        achList[0].Est_Remaining_Battery__c = x.estBattPct__c;
                      }
                              }
                              else 
                                if (achList.size()>1)
                            {for (integer i=1;i<achList.size();i++)
          					    {achList[i].last_known_location__c = x.Last_Known_Location__r.name;
                                 achList[i].battery_voltage__c = x.Battery_Voltage__c;
             					 achList[i].rsrp__c=x.rsrp__c;
             					 achList[i].rsrq__c = x.rsrq__c;
             					 achList[i].rssi__c = x.rssi__c;
             					 achList[i].message_type__c = x.src__c;
             					 achList[i].cellular_signal__c = x.signal__c;
                                  if(x.Power_Reset_Occurred__c == True && x.Battery_Replaced_Date__c == null)
                    {
                        achList[i].Est_Remaining_Battery__c = 100 - ((date.newinstance(x.CreatedDate.year(), x.CreatedDate.month(), x.CreatedDate.day()).daysBetween(System.today()))* 0.054795); 
                    } else 
                        if(x.Power_Reset_Occurred__c == True && x.Power_Reset_Time__c != null  && x.Battery_Replaced_Date__c != null && x.Battery_Replaced_Date__c <  date.newinstance(x.Power_Reset_Time__c.year(), x.Power_Reset_Time__c.month(), x.Power_Reset_Time__c.day()))
                    {
                        achList[i].Est_Remaining_Battery__c = (100 - ((x.Battery_Replaced_Date__c.daysBetween(System.today())) * 0.054795));
                    } 
                       else 
                       {achList[i].Est_Remaining_Battery__c = x.estBattPct__c;}               
                    }
             				 }
                           upsert achList; 
                             }
                            
                               
                
                            // updating ACH for temperature 
                           // system.debug('###--tempHistoryList--'+ tempHistoryList);
                            if(!tempHistoryList.isEmpty()){
                                upsert tempHistoryList;
                            }                            
                        }
                    
                    } // End 'data'

                } // End 'message'
            } 
            
            resp.AfterAssetProcDttime__c = system.now();
            resp.AfterAssetProcTime__c = system.now().getTime()/1000;
            update resp;
            //Changes by Jayesh: (Jan 14, 2024) ADO#224
            //Adding code to update status of API Response Child from 3.0 to processed when API Response is processed in 2.0
            //Changes Start 
            List<API_Response_Childs__c> arcList = [Select Id, Name, Status__c, API_Response__c from API_Response_Childs__c where API_Response__c = :resp.Id];
            if(arcList.size() > 0) {
                for(API_Response_Childs__c arc : arcList) {
                    if(arc.Status__c == 'New') {
                        arc.Status__c = 'Processed';
                    }
                }
                update arcList;
            }
            //Changes End

        } catch(exception ex){
           // system.debug('###--Exception --'+ ex.getMessage());
           // system.debug('###--getStackTraceString--'+ ex.getStackTraceString());
           // system.debug('###--getLineNumber--'+ ex.getLineNumber());

            Rejected_API_Response__c rejectedApiResponse = new Rejected_API_Response__c(Asset__c=resp.Asset__c, Incomming_Message__c= resp.Incoming_Messsage__c);
            rejectedApiResponse.Error__c = '--Asset ID:--' + deviceId + '\n' + ex.getMessage();
            insert rejectedApiResponse;
            
            sendemail(ex.getMessage()+' -- MethodName : parseresponse()-- '+' -- On Line -- '+ex.getLineNumber()+' -- Type -- '+ 
                      ex.getTypeName()+' -- Cause -- '+ex.getCause()+' -- Stack --'+ ex.getStackTraceString() + '--Asset ID:--' + deviceId + 
                      'Response Id:' + resp.Id + ',Raw Message:' + resp.Incoming_Messsage__c);
        }
    }

    // checking dwell days scenario
    public static void checkForDwelDays(Asset ast){
        Asset_History_custom__c latestKnowLocACH = null;
        for (Asset_History_custom__c obj :[Select Id, Asset__c,start_time__c,location__c,latitude__c,longitude__c from Asset_History_custom__c 
                                       where Asset__c=: ast.Id and location__c !='In Transit'and latitude__c!=null and longitude__c !=null order by start_time__c desc Limit 1]){
            latestKnowLocACH = obj;
        }
            
        if(ast.Id != null && latestKnowLocACH != null){
            list<Asset_History_custom__c> updateDwellDays = new list<Asset_History_custom__c>();
            for(Asset_History_custom__c obj2 : [Select Id, Consider_for_Dwell__c, Latitude__c,longitude__c ,start_time__c from Asset_History_custom__c 
                                                    where Asset__c =: ast.Id AND latitude__c!=null AND longitude__c != null AND Consider_for_Dwell__c = true  
                                                    AND  Start_Time__c <: latestKnowLocACH.Start_Time__c]){
                obj2.Consider_for_Dwell__c = false;
                updateDwellDays.add(obj2);
            }
                
            if(!updateDwellDays.isEmpty()) {
                update updateDwellDays;
            }
        } 
    } 

    // creating new ACH records if they are applicable
    // Grouping the oldAch if applicable
    // updating asset attributes with latest response
    public static List<Asset_History_custom__c> updateLocValues(Api_Response__c resp, list<loc> loclist, Asset ast, list<deviceStatus> dvcStatus){
        List<Asset_History_custom__c> newAchList = new list<Asset_History_custom__c>();    // List ACH which need to be create/updated
        list<location_record_ignored__c> lrilist = new list<location_record_ignored__c>(); // List of LRI records to be created.
        List<long> LocTS = new list<long>();        // List of timestamp from loc data where haccRank = 0
        List<loc> locByTsAsc = new List<loc>();     // List of location records
        
        Asset_History_custom__c oldAch = fetchOldAch(ast);
        if(oldAch != null){ newAchList.add(oldAch); } //    adding old ACH at first
        
        loclist.sort();     // sorting all locations by TS in asccending order
        for(loc obj : loclist){
            if(obj.haccRank == 0){
                Datetime checkpastdate = DateTime.parse('01/01/2022, 12:00 AM');
                Datetime locDTM = utilityts.convertTS(obj.ts);
                Boolean futurecheck= locDTM > resp.CreatedDate.AddDays(1);
                LocTS.add(obj.ts);
                
                if(!futurecheck && locDTM > checkpastdate){
                    locByTsAsc.add(obj);
                }else{
                    lrilist.add(createLRI(resp, obj, 'Future TS'));
                }   
            }
        }

        if(!LocTS.isEmpty()){ resp.Location_TimeStamp__c = String.join(LocTS, ','); } 
        if(!locByTsAsc.isEmpty()){
            Id locationRTId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
            fetchDownstreamCustomer(ast, oldAch);   // preparing downstream customers data
            for(loc lc : locByTsAsc){
                DateTime localTime = utilityTS.convertTS(lc.ts);
                
                if(oldAch == null || oldAch.Id == null || oldAch.End_Time__c == null || oldAch.End_Time__c < localTime || (ast.Last_Connected2__c > localTime && oldAch.End_Time__c < localTime)){
                    String locNameByAch = currentLocName(accmap, lc.lat, lc.lon, nestedGeofences);
                    // creating new ACH records
                    Asset_History_custom__c ah = new Asset_History_custom__c();
                    ah.Asset__c = ast.Id;
                    ah.Api_Response__c = resp.Id;
                    ah.RecordTypeId = locationRTId != null ? locationRTId : null;
                    ah.Timestamp__c = lc.ts;        // ls.requestTs
                    ah.Location__c = locNameByAch != null ? locNameByAch  : 'In Transit';
                    ah.Start_Time__c = localTime;
                    ah.End_Time__c  = localTime; 
                    ah.Latitude__c  = lc.lat;
                    ah.Longitude__c = lc.lon;
                    ah.Altitude__c  = lc.alt;
                    ah.Accuracy_meters__c = lc.hacc;
                    if (lc.src != null){
                                if(lc.src == 'w'){ast.src__c = 'wifi';}
                           else if(lc.src == 'c'){ast.src__c = 'cellular';}
                           else if(lc.src == 'g'){ast.src__c = 'gps';}
                           }
                    ah.Last_Known_Location__c = ast.Last_Known_Location__r.name != null ? ast.Last_Known_Location__r.name : ah.Last_Known_Location__c;
                    ah.Battery_Voltage__c = ast.Battery_Voltage__c != null ? ast.Battery_Voltage__c : ah.Battery_Voltage__c;
                    ah.Altitude__c = ast.alt__c != null ? ast.alt__c : ah.Altitude__c;
                    ah.Cellular_Signal__c = ast.signal__c != null ? ast.signal__c : ah.Cellular_Signal__c;
                    ah.rsrp__c = ast.rsrp__c != null ? ast.rsrp__c : ah.rsrp__c;
                    ah.rsrq__c = ast.rsrq__c != null ? ast.rsrq__c : ah.rsrq__c;
                    ah.rssi__c = ast.rssi__c != null ? ast.rssi__c : ah.rssi__c;
                    ah.Message_Type__c = ast.src__c != null ? ast.src__c : ah.Message_Type__c;
                    //ah.Message_Type__c = srcMap.containsKey(ast.src__c) ? srcMap.get(lc.src) : ah.Message_Type__c;
                    ah.Est_Remaining_Battery__c = ast.Power_Reset_Occurred__c == false ? ast.estBattPct__c : ah.Est_Remaining_Battery__c;

                    if(ast.Power_Reset_Occurred__c == True && ast.Battery_Replaced_Date__c == null){
                        ah.Est_Remaining_Battery__c = 100 - ((date.newinstance(ast.CreatedDate.year(), ast.CreatedDate.month(), ast.CreatedDate.day()).daysBetween(System.today()))* 0.054795); 
                    } else if(ast.Power_Reset_Occurred__c == True && ast.Power_Reset_Time__c != null  && ast.Battery_Replaced_Date__c != null && ast.Battery_Replaced_Date__c <  date.newinstance(ast.Power_Reset_Time__c.year(), ast.Power_Reset_Time__c.month(), ast.Power_Reset_Time__c.day())){
                        ah.Est_Remaining_Battery__c = (100 - ((ast.Battery_Replaced_Date__c.daysBetween(System.today())) * 0.054795));
                    } else {
                        ah.Est_Remaining_Battery__c = ast.estBattPct__c;
                    }

                    // fetching geofence 
                    if(ah.Latitude__c != null && ah.Longitude__c != null){
                        ah = checkGeoFence(ah);
                    }
                    
                    // Last knowlocation check
                    /*if(newAchList.size() > 0 && ah.Location__c == 'In Transit' && ah.Last_Known_Location__c == null && newAchList[newAchList.size() - 1].Location__c != 'In Transit' && 
                       newAchList[newAchList.size() - 1].Location__c != null){
                        ah.Last_Known_Location__c = newAchList[newAchList.size() - 1].Location__c;
                    }*/
                    
                    newAchList.add(ah);
                } else {    // to store ignored location records - which has delayed ts
                    lrilist.add(createLRI(resp, lc, 'Out of Order TS'));
                }
            }
            
          //  system.debug('###--newAchList--'+ newAchList);
            if(!newAchList.isEmpty()){
                
                // grouping the ACH by lat/lng
                // newAchList contains the list of ACH in ascending order of timestamp
                list<Asset_History_custom__c> tempAchList = new list<Asset_History_custom__c>();
                Integer prevIndx = 0;
                for(Integer i=0; i<newAchList.size(); i++){
                    
                    // grouping based on lat/lng
                    if(i > 0 && newAchList[i].latitude__c == tempAchList[prevIndx].Latitude__c && newAchList[i].longitude__c == tempAchList[prevIndx].longitude__c){
                        tempAchList[prevIndx].End_Time__c = newAchList[i].End_Time__c;
                        tempAchList[prevIndx].Timestamp__c = newAchList[i].Timestamp__c;
                        tempAchList[prevIndx].Api_Response__c = resp.Id;
                    } 
                    // grouping base on geofence / nested geofence
                    else if (i > 0 && tempAchList[prevIndx].Location__c == newAchList[i].Location__c && caldistance(accmap, newAchList[i].Latitude__c, newAchList[i].Longitude__c)){
                        tempAchList[prevIndx].End_Time__c = newAchList[i].End_Time__c;
                        tempAchList[prevIndx].Latitude__c = newAchList[i].Latitude__c;
                        tempAchList[prevIndx].Longitude__c = newAchList[i].Longitude__c;
                        tempAchList[prevIndx].Timestamp__c = newAchList[i].Timestamp__c;
                        tempAchList[prevIndx].Api_Response__c = resp.Id;
                    } 
                    // grouping base on location and Current_Location_Address
                    else if (i > 0 && tempAchList[prevIndx].Location__c == newAchList[i].Location__c && tempAchList[prevIndx].Current_Location_Address__c == newAchList[i].Current_Location_Address__c){
                        tempAchList[prevIndx].End_Time__c = newAchList[i].End_Time__c;
                        tempAchList[prevIndx].Latitude__c = newAchList[i].Latitude__c;
                        tempAchList[prevIndx].Longitude__c = newAchList[i].Longitude__c;
                        tempAchList[prevIndx].Timestamp__c = newAchList[i].Timestamp__c;
                        tempAchList[prevIndx].Api_Response__c = resp.Id;
                    } else {
                        tempAchList.add(newAchList[i]);
                        prevIndx = tempAchList.size() - 1;
                    }
                }
                newAchList = tempAchList;
                
               // system.debug('###--tempAchList size--'+ tempAchList);
                // updating start time and end time in sequence
                for(Integer i=1; i<newAchList.size(); i++){
                    newAchList[i-1].End_Time__c = newAchList[i].Start_Time__c;
                }
                
               // system.debug('###--tempAchList size--'+ tempAchList.size());
                // updating Still_in_this_Location
                if(newAchList.size() > 1){
                    for(Integer i=0; i<newAchList.size(); i++){
                        newAchList[i].Still_in_this_Location__c = i == (newAchList.size() - 1);
                    }
                } else if(newAchList.size() == 1 && oldACH == null){
                    newAchList[0].Still_in_this_Location__c = true;
                }

                // checking Last_Connected2 is still greater then asset's Last_Connected
                ast.Last_Connected__c = ast.Last_Connected2__c > ast.Last_Connected__c ? ast.Last_Connected2__c : ast.Last_Connected__c;
                if(ast.Last_Connected__c != null && ast.Last_Connected__c < newAchList[newAchList.size() - 1].End_Time__c){
                    ast.Last_Connected__c = newAchList[newAchList.size() - 1].End_Time__c;
                }

                // update assets attributes with top most ACH ...
                if(!newAchList.isEmpty()){
                    ast.Temporary_Latitude__c = newAchList[newAchList.size() - 1].Latitude__c;
                    ast.Temporary_Longitude__c = newAchList[newAchList.size() - 1].Longitude__c;
                    ast.alt__c = newAchList[newAchList.size() - 1].Altitude__c != null ? newAchList[newAchList.size() - 1].Altitude__c : ast.alt__c;
                    ast.Accuracy_meters__c = newAchList[newAchList.size() - 1].Accuracy_meters__c != null ? newAchList[newAchList.size() - 1].Accuracy_meters__c : ast.Accuracy_meters__c;
                    //ast.src__c = srcMap.containsKey(newAchList[newAchList.size() - 1].src) ? srcMap.get(newAchList[newAchList.size() - 1].src) : ast.src__c;
                }
            }
        }

      //  system.debug('updateLocValue ###--newAchList--'+ newAchList);
       // system.debug('updateLocValue ###--lrilist--'+ lrilist);

        insert lrilist;       

        return newAchList;
    }    

    // checking the geofence and updating current location 
    public static Asset_History_custom__c checkGeoFence(Asset_History_custom__c ast){
        for(id acc : accmap.keySet()){
            Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
            Location loc2 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
            Double result = Location.getDistance(loc1, loc2, 'mi');     
             
            if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                ast.location__c =  accmap.get(acc).name;
                ast.currentLocationId__c = accmap.get(acc).Id;
                ast.Current_Location_Address__c = ast.Current_Location_Address__c;
                 
                if(ast.Current_Location_Address__c == null){
                    Account accRec = accmap.get(acc);
                    ast.Current_Location_Address__c = accRec.shipaddformula__c;
                } 
                
                break;  
            }
        } 
              
       if(ast.Current_Location_Address__c == null){
            for (Nested_Geofence__mdt mdt : nestedGeofences){
                if(ast.Asset__r.AccountId == mdt.Current_Location_Id__c){
                    Location loc1 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
                    Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    if(result <= mdt.Diameter__c){
                        ast.location__c =  accmap.get(ast.Asset__r.AccountId).name;
                        ast.currentLocationId__c = ast.Asset__r.AccountId;  
                        ast.Current_Location_Address__c = mdt.Current_Location__c; 
                        break;
                    } 
                } 
            }
        }
        
        if(ast.Current_Location_Address__c == null){
            compareGoogleAPIData.performAction(ast.Latitude__c, ast.Longitude__c,ast);
        }
        
        return ast;
    }

    // creating temperature response ACH
    public static list<Asset_History_custom__c> captureTempResponses(Api_Response__c resp, List<temp> tempList, Asset ast){
        list<Asset_History_custom__c> tempHistoryList = new list<Asset_History_custom__c>();
        id recid = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDeveloperName().get('Temperature').getRecordTypeId();
       
        for(temp obj : templist){
            Asset_History_custom__c ah = new Asset_History_custom__c();
            ah.Api_Response__c = resp.Id;

            if(obj.c != null){
                ah.Temperature__c = 1.8 * obj.c + 32;  
                ast.Temperature__c = 1.8 * obj.c + 32;    
            }
            
            if(obj.rh != null){
                ah.Relative_Humidity__c  = obj.rh;
                ast.Humidity__c = obj.rh;    
            }

            DateTime localTime = utilityTS.convertTS(obj.ts);
            ah.Start_Time__c = localTime;
            if(ah.End_Time__c == null ||(ah.End_Time__c < localTime)){
                ah.End_Time__c = localTime;  
            }
            ah.asset__c = ast.id;
            ah.Changed_Field__c = 'Temperature';
            ah.recordtypeid = recid;
            tempHistoryList.add(ah);
        }

        return tempHistoryList;
    }

    // updating asset attribute based on temperatue response
    public static list<Asset_History_custom__c> updateTempValues(List<temp> tempList, List<Asset_History_custom__c> achList, Asset ast){
        for(temp obj : Templist){
            for(Asset_History_custom__c ah : achList){
                if(ah.Timestamp__c == obj.ts){  
                    if(obj.c != null){
                        ah.Temperature__c = 1.8 * obj.c + 32;  
                        ast.Temperature__c = 1.8 * obj.c + 32;    
                    }
                    if(obj.rh != null){
                        ah.Relative_Humidity__c  = obj.rh;
                        ast.Humidity__c = obj.rh;
                    }
                }
            }
        }
        
        return achList;
    }

    // preparing downstream customes
    public static void fetchDownstreamCustomer(Asset ast, Asset_History_custom__c oldACH){
        Set<Id> accids = new Set<Id>(); 
        accids.add(ast.accountId); 

        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c IN: accids]){
            accids.add(rc.Source_Account__c);
            accids.add(rc.Related_To__c);
        }
        
        for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude, 
                            ShippingStreet,ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,shipaddformula__c FROM Account where id IN : accids]){
            accmap.put(acc.id,acc);    
        }
        
        nestedGeofences = [select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids];
    }

    // fetching the old ACh record where Still_in_this_Location__c = true
    public static Asset_History_custom__c fetchOldAch(Asset ast){
        Asset_History_custom__c record = null; 
        for(Asset_History_custom__c ahc : [SELECT id,asset__c,start_time__c,Location__c,Account_ID__c,Timestamp__c,Latitude__c,Longitude__c,End_Time__c,
                                           Current_Location_Address__c, Still_in_this_Location__c ,Altitude__c, Accuracy_meters__c,
                                           Last_Known_Location__c  
                                           FROM Asset_History_custom__c 
                                           WHERE Asset__c =: ast.id and Still_in_this_Location__c = true order by createddate desc limit 1]){
            record = ahc;
        } 

        return record;
    }

    // preparing LRI record
    public static location_record_ignored__c createLRI(Api_Response__c resp, loc location, String reason){
        location_record_ignored__c lri = new location_record_ignored__c();
        lri.Api_Response__c = resp.Id;
        lri.Incoming_Message__c = resp.Incoming_Messsage__c;
        lri.Device_Id__c = resp.Device_Id__c;
        lri.Asset__c     = resp.Asset__c;
        lri.Account__c   = resp.Asset__r.AccountId;
        lri.latitude__c  = location.lat;
        lri.longitude__c = location.lon;
        lri.Altitude__c  = location.alt;
        lri.hacc__c      = location.hacc;
        lri.haccRank__c  = location.haccRank;
        lri.pdop__c      = location.pdop;
        lri.requestTs__c = location.requestTs;
        lri.ttf__c       = location.ttf;
        lri.Timestamp__c = location.ts;
        lri.Location_Captured_Time__c =  utilityts.convertTS((long)location.ts);           // ts to cst
        lri.Reason__c    = reason;
        lri.calc__c = (location.calc == true);

        lri.rsri__c = location.rssi;
        lri.rsrp__c = location.rsrp;
        lri.rsrq__c = location.rsrq;
        lri.Accuracy__c = location.hacc;
        lri.voltage__c = location.battery;
        lri.cellular_signal__c = location.signal;

        if(location.src == 'w'){
            lri.src__c = 'wifi';
        }else if(location.src == 'c'){
            lri.src__c = 'cellular';
        }else if(location.src == 'g'){
            lri.src__c = 'gps';
        }

       return lri;
    }

    // check for power reset.
    /*public static Asset checkPowerResetOccured(deviceStatus dvcStatus, Asset ast){
        String tsValue = dvcStatus.ts != null ? String.valueOf(dvcStatus.ts) : null;
        Decimal powerUpTime = dvcStatus.powerUptime != null  ? dvcStatus.powerUptime : null;
        Decimal poweruptime3 = ast.PowerUp_Time__c;

        if(tsValue != null && tsValue.startsWith('1104')){
            ast.PowerUp_Time__c = powerUpTime;
            ast.Power_Reset_Occurred__c = true;
            ast.Power_Reset_Time__c = system.now();
        }else if(powerUpTime < poweruptime3 && (poweruptime3 != null && string.valueOf(powerUpTime).length() < string.valueOf(poweruptime3).length())){
            ast.PowerUp_Time__c = powerUpTime;
            ast.Power_Reset_Occurred__c = true;
            ast.Power_Reset_Time__c = system.now();            
        }

        return ast;
    } */

    // populating asset details.
    public static Asset fillAssetDetails(Asset asset, deviceStatus obj, Api_Response__c resp){
  
        if(asset != null){
            
            String tsValue = obj.ts != null ? String.valueOf(obj.ts) : null;
            Decimal powerUpTime = obj.powerUptime != null  ? obj.powerUptime : null;
            asset.rsrp__c = obj.rsrp != null ? (decimal)obj.rsrp : asset.rsrp__c;
            asset.rsrq__c = obj.rsrq != null ? (decimal)obj.rsrq : asset.rsrq__c;
            asset.rssi__c = obj.rssi != null ? (decimal)obj.rssi : asset.rssi__c;    
            asset.signal__c = obj.signal != null ? (decimal)obj.signal : asset.signal__c;
            asset.Battery_Voltage__c = obj.battery != null ? (decimal)obj.battery : asset.Battery_Voltage__c;
            asset.estBattPct__c      = obj.estBattPct != null ? (decimal)obj.estBattPct : asset.estBattPct__c;
            asset.PowerUp_Time__c    = obj.powerUptime != null ? (decimal)obj.powerUptime : asset.PowerUp_Time__c;    
            resp.Powerup_Time__c  = obj.powerUptime != null ? (decimal)obj.powerUptime : asset.PowerUp_Time__c; 
           // system.debug('Asset Power up time' + asset.powerUp_time__c);
          //  system.debug('old power up time '+ poweruptime2);
           // system.debug('device_status__c'+obj.powerUptime);
            if (obj.ts != null)  {
                DateTime localTime = utilityTS.convertTS((Integer)obj.ts); 
                if(localTime != null && (asset.Last_Connected2__c == null || asset.Last_Connected2__c < localTime)) {
                    asset.Last_Connected2__c = localTime;
                }    

                if(localTime != null && (asset.Last_Connected__c == null || asset.Last_Connected__c < localTime)) {
                    asset.Last_Connected__c = localTime;
                }
                
            }
            if ((!asset.Power_Reset_Occurred__c) && (obj.ts != null ))
            {
             if(tsValue != null && tsValue.startsWith('1104')){
            //asset.PowerUp_Time__c = powerUpTime;
            asset.Power_Reset_Occurred__c = true;
            asset.Power_Reset_Time__c = resp.CreatedDate;
        }else if(powerUpTime < poweruptime2 && (poweruptime2 != null && string.valueOf(powerUpTime).length() < string.valueOf(poweruptime2).length())){
           // asset.PowerUp_Time__c = powerUpTime;
            asset.Power_Reset_Occurred__c = true;
            asset.Power_Reset_Time__c = resp.CreatedDate;            
        }
                
            }
        }
        
        return asset;
    }   

    // fetch asset detail based on device id
    public static Asset getasset(String deviceId){
        Asset asst = new asset();
        for(Asset ast : [SELECT id,AccountId,Last_Connected_Cached__c,Measurement_Period_desired__c,Measurement_Period_Reported__c,Measurement_Period_Check__c,
                         Last_Known_Location__r.name, Capture_Movement_Event__c, Movement__c, Movement_End__c,Battery_Replaced_Date__c,Power_Reset_Time__c,
                         PowerUp_Time__c,Current_Location__r.name,Capture_Temperature_Response__c,Power_Reset_Occurred__c,Last_Connected2__c,
                         Temporary_Latitude__c, Temporary_Longitude__c, Accuracy_meters__c,
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

            insert asst;
        }
        
        return asst;
    }

    // get current location name
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

    // check cardinal distancce
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

    // Sending exception email
    public static void sendemail(String response){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toaddress();
        message.subject = 'Error Occured in the Incoming response';
        message.plainTextBody = response ;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    // preparing toAddress to send email to
    public static list<string> toaddress(){
        set<id> usrids = new set<id>();
        list<string> emaillist = new list<string>();
        /*for(groupmember gm : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember where Group.DeveloperName = 'developers' ]){
            usrids.add(gm.UserOrGroupId);    
        }
        for(user usr : [select id,email from user where id IN : usrids]){
            emaillist.add(usr.email);
        }*/
        
        
        return emaillist;
    }

    // ----------------------------------------- Wrapper Classes -------------------------------------------------
    public class NimblinkResponse{
        public list<records> records{get;set;}
    }

    public class temp{
        public Decimal rh{get;set;}
        public Integer lvl{get;set;}
        public Decimal c{get;set;}
        public Integer tc{get;set;}
        public Integer ts{get;set;}
    }

    public class records{
        public data data{get;set;}
        public base base{get;set;}
    }

    public class loc implements Comparable {
        public Decimal ttf{get;set;}
        public Decimal lon{get;set;}
        public Decimal pdop{get;set;}
        public Decimal lat{get;set;}
        public Decimal alt{get;set;}
        public Integer haccRank{get;set;}
        public Decimal hacc{get;set;}
        public long requestTs{get;set;}
        public Decimal speed{get;set;}
        public String src{get;set;}
        public String heading{get;set;}
        public long ts{get;set;}
        public Boolean calc{get;set;}
        public Decimal rssi{get;set;}
        public Decimal rsrp{get;set;}
        public Decimal rsrq{get;set;}
        public Decimal battery{get;set;}
        public Decimal signal{get;set;}

        public Integer compareTo(Object compareTo) {
            loc compareToEmp = (loc)compareTo;
            if (ts == compareToEmp.ts) return 0;
            if (ts > compareToEmp.ts) return 1;
            return -1;        
        }
    }

    public class info{
        public long ts{get;set;}
        public details details{get;set;}
        public String description{get;set;}
    }

    public class events{
        //public eventData eventData{get;set;}
        public String eventName{get;set;}
        public long ts{get;set;}
    }

    public class deviceStatus{
        public Decimal estBattPct{get;set;}
        public Decimal rssi{get;set;}
        public Integer signal{get;set;}
        public Decimal rsrq{get;set;}
        public Integer powerUptime{get;set;}
        public Decimal rsrp{get;set;}
        public Decimal battery{get;set;}
        public String network{get;set;}
        public long ts{get;set;}
    }

    public class details{
        public long requestTs{get;set;}
    }

    public class data{
        public list<loc> loc{get;set;}
        public list<temp> temp{get;set;}
        public list<deviceStatus> deviceStatus{get;set;}
        public list<events> events{get;set;}
        public list<info> info{get;set;}
        public list<accel> accel{get;set;}
    }

    public class base{
        public String msgId{get;set;}
        public String division{get;set;}
        public String org{get;set;}
        public long tss{get;set;}
        public String deviceType{get;set;}
        public String schemaVer{get;set;}
        public String id{get;set;}
    }

    public class accel{
        public long ts{get;set;}
        public Decimal y{get;set;}
        public Decimal z{get;set;}
        public Decimal x{get;set;}
    }
}