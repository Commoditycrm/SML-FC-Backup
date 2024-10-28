public class Trigger_Helper{
    public static map<id,decimal> msgMap  = new map<id,decimal>(); 
    public static list<Asset_History_Field__mdt> assetFields = [select id,label,DeveloperName,Field_API_Name__c,isLocationField__c from Asset_History_Field__mdt];
    public static map<id,account> accountwithlatlng = new map<id,account>();
    public static Map<string,id> recidmap = new map<string,id>();
    
    // This method will update current address fields and state of pallets based on geo fencing results
    public static void updateAddress(list<asset> astlist, map<id,asset> astoldmap,boolean isinsert,boolean isupdate, boolean isbefore){
        //system.debug('newvalueentering');
        
        map<id,account> accmap = new map<id,account>();
        map<string,id> assetAccIdsmap = new map<string,id>();
        map<id,set<id>> parentchilaccids = new map<id,set<id>>();
        set<id> accids = new set<id>();
        try{
            for(account acc : [select id,GeoFence_Radius_in_Miles__c,shippinglatitude,parentid, shippinglongitude  FROM Account]){
                accmap.put(acc.id,acc);    
            } 
            
            for(asset asst : astlist){
                assetAccIdsmap.put(asst.Device_Id__c,asst.accountid);
                if(asst.accountid != null)
                    parentchilaccids.put(asst.accountid,new set<id>{asst.accountid});
            }
           // system.debug(assetAccIdsmap);
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c IN: assetAccIdsmap.values()]){
                
                if(parentchilaccids.containskey(rc.Source_Account__c)){
                    accids = parentchilaccids.get(rc.Source_Account__c); 
                    accids.add(rc.Related_To__c);
                    accids.add(rc.Source_Account__c);
                    parentchilaccids.put(rc.Source_Account__c,accids); 
                }else{
                    parentchilaccids.put(rc.Source_Account__c,new set<id>{rc.Related_To__c});    
                }
            }
            
            for(asset asst : astlist){
                double result;
                decimal result1;
                //boolean isInnetwork = false;
                string state;
                id locId;
                boolean executeaction;
                executeaction = false;
              //  system.debug(asst);
                if(!isinsert){
                  //  system.debug(asst.Temporary_Latitude__c);
                  //  system.debug(astoldmap.get(asst.id).Temporary_Latitude__c);
                  //  system.debug(asst.Temporary_Longitude__c);
                   // system.debug(astoldmap.get(asst.id).Temporary_Longitude__c);
                    if((asst.Temporary_Latitude__c != null && asst.Temporary_Latitude__c != astoldmap.get(asst.id).Temporary_Latitude__c) 
                       || (asst.Temporary_Longitude__c != null && asst.Temporary_Longitude__c != astoldmap.get(asst.id).Temporary_Longitude__c)){
                           
                           executeaction = true;   
                       }
                }else{
                   // system.debug('in Else Execution---'+asst.Temporary_Latitude__c + '-'+asst.Temporary_Longitude__c );
                    if(asst.Temporary_Latitude__c != null || asst.Temporary_Longitude__c != null){
                        
                        executeaction = true;   
                    }    
                }
              //  system.debug('execution--'+executeaction);
                if(executeaction){
                    
                    decimal cirlat = asst.Temporary_Latitude__c;
                    decimal cirlong = asst.Temporary_Longitude__c;
                  //  system.debug(parentchilaccids);
                  //  system.debug(result);
                   // system.debug(state);
                   // system.debug(locid);
                    if(parentchilaccids.containskey(assetAccIdsmap.get(asst.Device_Id__c))){
                        for(id accid : parentchilaccids.get(assetAccIdsmap.get(asst.Device_Id__c))){
                          //  system.debug(accid);
                            //system.debug(accmap.get(accid).shippinglatitude +'-'+ accmap.get(accid).shippinglongitude);
                            if(accmap.containskey(asst.accountid)){
                                if(accmap.containskey(accid)){
                                    Location loc1 = Location.newInstance(accmap.get(accid).shippinglatitude,accmap.get(accid).shippinglongitude);
                                    Location loc2 = Location.newInstance(cirlat,cirlong);
                                    result = Location.getDistance(loc1, loc2, 'mi');    
                                    
                                  //  system.debug('result--'+result);
                                  //  system.debug('Distance result--'+result);
                                  //  system.debug('Distance in mile result--'+loc1.getDistance(loc2, 'mi'));
                                  //  system.debug('Distance in km result--'+loc1.getDistance(loc2, 'km'));
                                  //  system.debug('Account Geofence Radius--'+accmap.get(accid).GeoFence_Radius_in_Miles__c);
                                    result1 = result;
                                    if(accmap.get(accid).GeoFence_Radius_in_Miles__c != null && result < accmap.get(accid).GeoFence_Radius_in_Miles__c){
                                        locId = accid;
                                        break;
                                    }  
                                }
                            }
                        }    
                    }//If ParentChild
                    if(locId != null && result1 < accmap.get(locId).GeoFence_Radius_in_Miles__c ){
                        state = 'In Network';
                    }else{
                        state = 'out Network';            
                    }
                    
                   // system.debug('result--'+result1);
                   // system.debug(state);
                    if(state == 'In Network'){
                        
                        if(isbefore){
                            asst.State_of_Pallet__c  = 'In Network';
                           // asst.Current_Address__c = '';
                            asst.Current_State__c = '';
                            asst.Current_Street_Address__c = '';
                            asst.Current_City__c = '';
                            asst.Current_Zip_Code__c = '';
                            asst.Current_Location__c = locId;    
                        }
                        
                    }else {
                        if(isbefore){
                            asst.State_of_Pallet__c  = 'In Transit';   
                            asst.Batch_Update__c = true;
                            asst.Current_Location__c = null;
                        }
                        /*if(Utilityclass.canIRun() && asst.Is_NimbeLink_Asset__c){
if((isbefore && isupdate) || (!isbefore && isinsert)){
googleApiCallout.httpreq(cirlat,cirlong,asst.id);   
//asst.Batch_Update__c = false;
}
}
if(isbefore){
asst.Batch_Update__c = true;
asst.Current_Address__c = '';
asst.Current_State__c = '';
asst.Current_Street_Address__c = '';
asst.Current_City__c = '';
asst.Current_Zip_Code__c = '';
asst.State_of_Pallet__c  = 'In Transit'; 
asst.Current_Location__c = null;
}*/
                        
                        
                    }//else part
                }//If Execute Action
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    public static void updateLastconnectedfield(list<asset>astlist){
        try{
            for(asset ast : astlist){
              //  system.debug(ast);
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
               /* boolean checktrackmode=false;
                if(ast.Trackmode__c=='3'){
                    if(ast.Measurement_Period_desired__c == ast.Measurement_Period_Reported__c){
                        checktrackmode=true;
                       // system.debug('1');
                    }else{
                        checktrackmode=false;
                       // system.debug('2');
                    }
                }
                if(ast.Trackmode__c=='2'){
                    if(ast.LocationPeriod__c==ast.Tracking_Location_Period_Desired__c){
                        checktrackmode=true;
                        //system.debug('3');
                    }else{
                        checktrackmode=false;
                       // system.debug('4');
                    }
                }
                if(ast.Trackmode__c =='4'){
                    if(ast.Measurement_Period_desired__c == ast.Measurement_Period_Reported__c &&
                   ast.Tilt_Degrees_Check__c &&
                   ast.Connect_On_Tilt_Check__c &&
                   ast.Log_Every_n_Check__c &&
                   ast.Reference_X_Check__c &&
                   ast.Reference_Y_Check__c &&
                   ast.Reference_Z_Check__c){
                        checktrackmode=true;
                        //system.debug('3');
                    }else{
                        checktrackmode=false;
                       // system.debug('4');
                    }
                }
                
                IF(ast.Accelerometer_Status_Check__c &&
                   ast.ConnectMovementEnd_Check__c &&
                   ast.Trackmode_check__c &&
                   ast.ConnectMovementStart_Check__c &&
                   ast.Location_Sampling_Period_check__c &&
                   ast.Tracking_Locations_per_Check_Ins_check__c &&
                   ast.Location_Status_Check__c &&
                   ast.Use_Gps_check__c &&
                   ast.Use_Cell_Check__c &&
                   ast.Use_Wifi_Check__c &&
                   ast.Temperature_Status_Check__c &&
                   ast.Temperature_Check_in_Period_Check__c &&
                   ast.Network_Check_in_period_chek__c &&
                   checktrackmode)
                    // ast.BLE_Enabled_Chk_F__c == True &
                    // ast.BLE_Sampling_Period_Check__c == True
                {
                    ast.Master_Configuration_Check__c=True;
                }
                else{
                    ast.Master_Configuration_Check__c=False;
                }*/
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    // This method will insert history records whenever change in asset record
    public static list<Asset_History_custom__c> createAssetForInsert(asset ast,string loopvalue){
      //  system.debug('<--------Enters into the method--------->');
      //  system.debug('assetname'+ast.name);
        list<Asset_History_custom__c> inserthistoryList = new list<Asset_History_custom__c>();
        try{
            if(loopvalue == 'non-location' || loopvalue == 'both'){
                for(Asset_History_Field__mdt mdt : assetFields){
                    
                    //Create records for non location fields
                    if(!mdt.isLocationField__c){
                        Asset_History_custom__c ad = new Asset_History_custom__c();
                        ad.Asset__c = ast.id;
                        ad.Changed_Field__c = mdt.label;
                        if(recidmap.containskey('Asset_History_custom__c-other')){
                            ad.RecordTypeId = recidmap.get('Asset_History_custom__c-other');    
                        }
                        
                      //  system.debug('str--'+ast.Message_Types__c);
                        if(mdt.label == 'Message Description' && ast.Message_Types__c != null && msgMap.containskey(ast.Message_Types__c)){
                            
                            if(recidmap.containskey('Asset_History_custom__c-Message_Type')){
                                ad.RecordTypeId = recidmap.get('Asset_History_custom__c-Message_Type'); 
                            }
                            ad.Battery_Current__c = msgMap.get(ast.Message_Types__c);
                            if(ast.Message_Count__c != null){
                                ad.Message_Count__c = ast.Message_Count__c;    
                            }else{
                                ad.Message_Count__c = 1;
                            }
                            ad.Current_Message_Type__c = true;
                            if(ast.Last_Connected__c != null){
                                ad.End_Time__c = ast.Last_Connected__c;
                                if(ast.Start_Time__c != null){
                                    ad.Start_Time__c = ast.Start_Time__c;    
                                }else{
                                    ad.Start_Time__c = ast.Last_Connected__c;
                                }
                            }
                            
                        }
                        if(ast.Battery_Voltage__c!=null){
                            ad.Battery_Voltage__c=ast.Battery_Voltage__c;
                        }
                        //Newly Added 29-10-2021
                        // if(ast.estBattPct__c !=null){
                        System.debug('Calculated Estimated Remaining Battery'+ast.est_Batterycalculate__c);
                        System.debug('API Estimated Remaining Battery'+ast.estBattPct__c);
                        ad.Est_Remaining_Battery__c=ast.est_Batterycalculate__c;
                        //}
                        //Block end 
                        
                        //  ad.BLE_New_Temp__c = string.valueOf(ast.get(mdt.Field_API_Name__c));
                        string st = '';
                       // system.debug('ast.State_of_Pallet__c'+ast.State_of_Pallet__c);
                        if(ast.Current_Location_Name__c != null){
                            st =  ast.Current_Location_Name__c; 
                            ad.Longitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglongitude;
                            ad.Latitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglatitude;
                            if(ast.Current_Location_Address__c!=null){
                                ad.Current_Location_Address__c=ast.Current_Location_Address__c;
                            }
                        } else if(ast.State_of_Pallet__c == 'In Transit'){
                          //  system.debug('ast.State_of_Pallet__c'+ast.State_of_Pallet__c);
                            st =  ast.State_of_Pallet__c; 
                          //  system.debug('lat--->'+ast.Temporary_Latitude__c);
                          //  system.debug('lon--->'+ast.Temporary_Longitude__c);
                            if(ast.Temporary_Latitude__c != null){
                                ad.Latitude__c = ast.Temporary_Latitude__c;    
                            }
                            if(ast.Temporary_Longitude__c != null){
                                ad.Longitude__c = ast.Temporary_Longitude__c;    
                            }
                        }
                        if(st != ''){
                            ad.Location__c = st;    
                        }
                        if(ast.Last_Connected__c != null){
                            ad.Last_Connected_Time__c = ast.Last_Connected__c;    
                        }
                        /*  if(ad.BLE_New_Temp__c != null){
system.debug('assethistory'+ad);
inserthistoryList.add(ad);     
}*/
                        
                    }
                }
            }
            //Create one record for location fields
           // system.debug('check-->'+ast.Current_Location__c+ ' '+ast.State_of_Pallet__c+' '+loopvalue);
            if((ast.Current_Location__c != null || ast.State_of_Pallet__c == 'In Transit') && (loopvalue == 'location' || loopvalue == 'both')){
            //    system.debug('enters--->276');
                Asset_History_custom__c ad = new Asset_History_custom__c();
                ad.Asset__c = ast.id;
                ad.Changed_Field__c = 'Location';
                if(ast.Is_NimbeLink_Asset__c){
                 //   system.debug('msgcount2222--'+ad.Message_Count__c);
                    ad.Message_Count__c = 1;
                    ad.Current_Location_Address__c = ast.Current_Address__c;
                }
                if(recidmap.containskey('Asset_History_custom__c-Location')){
                    ad.RecordTypeId =  recidmap.get('Asset_History_custom__c-Location');
                }
                if(ast.Last_Connected__c != null){
                    ad.End_Time__c = ast.Last_Connected__c;
                    if(ast.Start_Time__c != null){
                        ad.Start_Time__c = ast.Start_Time__c;    
                    }else{
                        ad.Start_Time__c = ast.Last_Connected__c;
                    }
                    
                }
                
                ad.Still_in_this_Location__c = true;
                string st = '';
              //  system.debug('pallett location'+ast.State_of_Pallet__c);
                if(ast.Current_Location_Name__c != null){
                    st =  ast.Current_Location_Name__c;  
                    ad.Longitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglongitude;
                    ad.Latitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglatitude;
                    if(ast.Current_Location_Address__c!=null){
                        ad.Current_Location_Address__c=ast.Current_Location_Address__c;
                    }
                } else if(ast.State_of_Pallet__c == 'In Transit'){
                //    system.debug('entere--->301');
                //    system.debug('lat--->'+ast.Temporary_Latitude__c);
                 //   system.debug('lon--->'+ast.Temporary_Longitude__c);
                    st =  ast.State_of_Pallet__c;
                    if(ast.Temporary_Latitude__c != null){
                        ad.Latitude__c = ast.Temporary_Latitude__c;    
                    }
                    if(ast.Temporary_Longitude__c != null){
                        ad.Longitude__c = ast.Temporary_Longitude__c;    
                    }
                    
                    
                }
                if(st != ''){
                    ad.Location__c = st;    
                }
                
                if(ast.Battery_Voltage__c!=null){
                    ad.Battery_Voltage__c=ast.Battery_Voltage__c;
                }
                if(ast.alt__c!=null){
                    ad.Altitude__c = ast.alt__c;
                }
                if(ast.signal__c!=null){
                    ad.Cellular_Signal__c = ast.signal__c;
                }
                // if(ast.estBattPct__c!=null){
                //  ad.Est_Remaining_Battery__c = ast.estBattPct__c;
                System.debug('Calculated Estimated Remaining Battery Trigger'+ast.est_Batterycalculate__c);
                ad.Est_Remaining_Battery__c = ast.est_Batterycalculate__c; //Changed to capture Formula Field
                // }
                if(ast.Humidity__c !=null){
                    ad.Relative_Humidity__c = ast.Humidity__c;
                }
                if(ast.rsrp__c!=null){
                    ad.rsrp__c = ast.rsrp__c;
                }
                if(ast.rsrq__c!=null){
                    ad.rsrq__c = ast.rsrq__c;
                }
                if(ast.rssi__c!=null){
                    ad.rssi__c = ast.rssi__c;
                }
                if(ast.Temperature__c!=null){
                    ad.Temperature__c = ast.Temperature__c;
                }
                if(ast.eventName__c!=null){
                    ad.Type_Of_Movement__c = ast.eventName__c;
                }
                if(ast.src__c!=null){
                    ad.Message_Type__c = ast.src__c;
                }   
                
               // system.debug('assethistory'+ad);
                inserthistoryList.add(ad);
                
            }       
          //  system.debug('<--------Exits the method--------->');
          //  system.debug('inserthistoryList---->'+inserthistoryList.size());
            return inserthistoryList;  
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex); 
            return null;
        }
    }
    // This method will insert/update history records whenever there is a change in the asset Not Needed 
    public static void createHistoryrec(list<asset>astlist,map<id,asset> astoldmap,boolean isInsert ){
        
        list<Asset_History_custom__c> inserthistoryList = new list<Asset_History_custom__c>();  
        list<Asset_History_custom__c> inserthistoryListfrominsert = new list<Asset_History_custom__c>();  
        list<Asset_History_custom__c> updatedwellList = new list<Asset_History_custom__c>();
        map<id,list<Asset_History_custom__c>> assetMap = new map<id,list<Asset_History_custom__c>>();
        map<id,list<string>> assetMapwithrectype = new map<id,list<string>>();
        set<id> assetids = new set<Id>();
        try{
            for(account acc : [select id,name,shippinglatitude,shippinglongitude,billingaddress from account]){
                accountwithlatlng.put(acc.id,acc);   
            }
            for(recordtype rec : [select id,sobjecttype,developername from recordtype]){
                recidmap.put(rec.sobjecttype+'-'+rec.DeveloperName, rec.id);     
            }
            
            for(Message_Type__c msg : [select id,Battery_Current_Use__c from Message_Type__c]){
                msgMap.put(msg.id,msg.Battery_Current_Use__c);    
            }
            for(asset ast : astlist){
                assetids.add(ast.id);       
            }
            for(asset ast : [select id,(select id,name,Latitude__c,Longitude__c,Start_Time__c,Record_Type_Developer_Name__c,recordtype.developername,Current_Message_Type__c,End_Time__c,Message_Count__c,Changed_Field__c,Still_in_this_Location__c,Asset__c,Location__c from Asset_Dwell_Time__r where (Still_in_this_Location__c = true or Current_Message_Type__c = true)) from asset where id IN : assetids]){
                if(ast.Asset_Dwell_Time__r.size()>0){
                   // system.debug('history'+ast.Asset_Dwell_Time__r.size());
                    assetMap.put(ast.id, ast.Asset_Dwell_Time__r);
                    list<string> recnames = new list<string>();
                    for(Asset_History_custom__c ah : ast.Asset_Dwell_Time__r){
                        if(assetMapwithrectype.containskey(ah.asset__c)){
                            recnames =  assetMapwithrectype.get(ah.asset__c); 
                            recnames.add(ah.Record_Type_Developer_Name__c);
                            assetMapwithrectype.put(ah.asset__c,recnames);
                        }else{
                            assetMapwithrectype.put(ah.asset__c, new list<string>{ah.Record_Type_Developer_Name__c});    
                        }
                    }
                    
                }
            }
          //  system.debug('recmap0--->'+assetMapwithrectype);
            for(asset ast : astlist){
                if(!ast.Track_Full_History__c && !ast.Is_NimbeLink_Asset__c){
                    // While creation of asset create history records for the fields in Asset_History_Field__mdt metadata
                 //   system.debug('inset---'+isInsert);
                    if(isInsert){
                     //   system.debug('Insert Ops--->'+ ast.Device_Id__c);
                        inserthistoryListfrominsert = createAssetForInsert(ast,'both'); 
                        for(Asset_History_custom__c ah : inserthistoryListfrominsert){
                            inserthistoryList.add(ah);      
                        }
                    }
                    // Create record for Asset record update
                    else{
                        for(Asset_History_Field__mdt mdt : assetFields){
                            //Update the message type history record with end time value
                            if(mdt.label == 'Message Description' && !mdt.isLocationField__c && assetMap.containskey(ast.id)){
                                
                                for(Asset_History_custom__c adt : assetMap.get(ast.id)){
                                  //  system.debug('historyRec--'+adt);
                                    if(ast.Last_Connected__c != null && ast.Last_Connected__c != astoldmap.get(ast.id).Last_Connected__c && adt.Changed_Field__c == 'Message Description' && adt.Current_Message_Type__c && ast.get(mdt.Field_API_Name__c) == astoldmap.get(ast.id).get(mdt.Field_API_Name__c) ){
                                    //    system.debug('in if loop');
                                        adt.End_Time__c = ast.Last_Connected__c;
                                     //   system.debug('End_Time__c'+adt.End_Time__c);
                                        if(adt.Location__c=='In Transit' || ast.State_of_Pallet__c=='In Transit'){
                                            if(ast.Temporary_Latitude__c != null){
                                                adt.Latitude__c = ast.Temporary_Latitude__c;
                                            }
                                            if(ast.Temporary_Longitude__c != null){
                                                adt.Longitude__c = ast.Temporary_Longitude__c;
                                            }
                                            adt.Location__c =  ast.State_of_Pallet__c; 
                                        }
                                        
                                        if(ast.Current_Location__c!=null){
                                            adt.Location__c = ast.Current_Location_Name__c; 
                                            adt.Longitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglongitude;
                                            adt.Latitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglatitude;
                                            if(ast.Current_Location_Address__c!=null){
                                                adt.Current_Location_Address__c=ast.Current_Location_Address__c;
                                            }
                                        }
                                      //  system.debug('updateCount@@'+ ast.Last_Connected__c);
                                        if(ast.Message_Count__c != null && adt.Message_Count__c!= null){
                                            adt.Message_Count__c = adt.Message_Count__c + ast.Message_Count__c;
                                        }
                                        if(ast.Battery_Voltage__c!=null && ast.Battery_Voltage__c!=astoldmap.get(ast.id).Battery_Voltage__c){
                                            adt.Battery_Voltage__c=ast.Battery_Voltage__c;
                                        }
                                        //Added On 29-10-2021
                                        //  if(ast.estBattPct__c!=null ){
                                        System.debug('Estimated Battery Calculated'+ast.est_Batterycalculate__c);  
                                        adt.Est_Remaining_Battery__c = ast.est_Batterycalculate__c;//Changed to capture formula field
                                        //    }
                                        //Ended On 29-10-2021
                                        updatedwellList.add(adt); 
                                    } else if( ast.get(mdt.Field_API_Name__c) != astoldmap.get(ast.id).get(mdt.Field_API_Name__c) && adt.Current_Message_Type__c && adt.Changed_Field__c == 'Message Description' ){
                                      //  system.debug('in else if loop');
                                        //adt.End_Time__c = ast.Last_Connected__c;
                                        if(ast.Start_Time__c != null){
                                            adt.End_Time__c = ast.Start_Time__c;    
                                        }else{
                                            adt.End_Time__c = ast.Last_Connected__c;
                                         //   system.debug('End_Time__c'+adt.End_Time__c); 
                                        }
                                        adt.Current_Message_Type__c = false;
                                        updatedwellList.add(adt); 
                                    }
                                    
                                }
                                
                            }
                         //   system.debug('check-->'+ast.get(mdt.Field_API_Name__c)+ ' '+astoldmap.get(ast.id).get(mdt.Field_API_Name__c)+' '+mdt.isLocationField__c+' ' +assetMap.containskey(ast.id));
                            //Create records for non location fields
                            if(ast.get(mdt.Field_API_Name__c) != astoldmap.get(ast.id).get(mdt.Field_API_Name__c) && !mdt.isLocationField__c && assetMap.containskey(ast.id)){
                                
                                inserthistoryListfrominsert = createAssetForInsert(ast,'non-location');
                                /*  for(Asset_History_custom__c ah : inserthistoryListfrominsert){
ah.BLE_New_Temp__c = string.valueOf(ast.get(mdt.Field_API_Name__c));
ah.BLE_Prior_Temp__c = string.valueOf(astoldmap.get(ast.id).get(mdt.Field_API_Name__c));  
inserthistoryList.add(ah);
}*/
                                
                            }
                        }
                        // Check whether the location is changed - If it is changed create a new record
                        for(Asset_History_Field__mdt mdt : assetFields){
                         //   system.debug('check-->'+ast.get(mdt.Field_API_Name__c)+ ' '+astoldmap.get(ast.id).get(mdt.Field_API_Name__c)+' '+mdt.isLocationField__c+' ' +assetMap.containskey(ast.id));
                            if(ast.get(mdt.Field_API_Name__c) != astoldmap.get(ast.id).get(mdt.Field_API_Name__c) && mdt.isLocationField__c && assetMap.containskey(ast.id)){           
                            //    system.debug('enters');
                                for(Asset_History_custom__c adt : assetMap.get(ast.id)){
                                //    system.debug(adt);
                                    if(adt.recordtype.developername == 'Location'){
                                        string st;
                                        if(ast.Current_Location_Name__c != null){
                                            st =  ast.Current_Location_Name__c;   
                                        } else if(ast.State_of_Pallet__c == 'In Transit'){
                                            st =  ast.State_of_Pallet__c;
                                        }
                                      //  system.debug('st--->'+st);
                                      //  system.debug('string**'+adt.Location__c);
                                      //  system.debug('adt.Location__c'+adt.Location__c);
                                      //  system.debug('ast.State_of_Pallet__c'+ast.State_of_Pallet__c);
                                      //  system.debug('check condition'+adt.Location__c + ' '+ast.Current_Location_Name__c+ ' '+ast.State_of_Pallet__c+' '+adt.Longitude__c+' '+ ast.Temporary_Longitude__c+' '+adt.Still_in_this_Location__c);
                                        if(adt.Location__c != null && adt.Location__c == ast.Current_Location_Name__c || (adt.Location__c == ast.State_of_Pallet__c && adt.Latitude__c == ast.Temporary_Latitude__c && adt.Longitude__c == ast.Temporary_Longitude__c ) || (ast.Temporary_Longitude__c == null && ast.Temporary_Latitude__c == null && ast.Current_Location_Name__c == null)  && adt.Still_in_this_Location__c){
                                          //  system.debug('line 447');
                                            adt.End_Time__c = ast.Last_Connected__c;
                                            if(ast.Is_NimbeLink_Asset__c){
                                             //   system.debug('msgcount--'+adt.Message_Count__c);
                                                if(adt.Message_Count__c != null){
                                                    adt.Message_Count__c = adt.Message_Count__c + 1;    
                                                }
                                                
                                                adt.Current_Location_Address__c = ast.Current_Address__c;
                                            }
                                          //  system.debug('battery--'+ ast.Battery_Voltage__c +'-'+astoldmap.get(ast.id).Battery_Voltage__c );
                                            if(ast.Battery_Voltage__c!=null && ast.Battery_Voltage__c!=astoldmap.get(ast.id).Battery_Voltage__c){
                                                adt.Battery_Voltage__c=ast.Battery_Voltage__c;
                                            }
                                            if(ast.alt__c!=null && ast.alt__c!=astoldmap.get(ast.id).alt__c){
                                                adt.Altitude__c = ast.alt__c;
                                            }
                                            if(ast.signal__c!=null && ast.signal__c!=astoldmap.get(ast.id).signal__c){
                                                adt.Cellular_Signal__c = ast.signal__c;
                                            }
                                            // if(ast.estBattPct__c!=null && ast.estBattPct__c!=astoldmap.get(ast.id).estBattPct__c){
                                            // adt.Est_Remaining_Battery__c = ast.estBattPct__c;
                                            //  if(ast.estBattPct__c!=null ){
                                            System.debug('Estimated Battery Calculated'+ast.est_Batterycalculate__c);  
                                            adt.Est_Remaining_Battery__c = ast.est_Batterycalculate__c;//Changed to capture formula field
                                            //}
                                            if(ast.Humidity__c !=null && ast.Humidity__c!=astoldmap.get(ast.id).Humidity__c){
                                                adt.Relative_Humidity__c = ast.Humidity__c;
                                            }
                                            if(ast.rsrp__c!=null && ast.rsrp__c!=astoldmap.get(ast.id).rsrp__c){
                                                adt.rsrp__c = ast.rsrp__c;
                                            }
                                            if(ast.rsrq__c!=null && ast.rsrq__c!=astoldmap.get(ast.id).rsrq__c){
                                                adt.rsrq__c = ast.rsrq__c;
                                            }
                                            if(ast.rssi__c!=null && ast.rssi__c!=astoldmap.get(ast.id).rssi__c){
                                                adt.rssi__c = ast.rssi__c;
                                            }
                                            if(ast.Temperature__c!=null && ast.Temperature__c!=astoldmap.get(ast.id).Temperature__c){
                                                adt.Temperature__c = ast.Temperature__c;
                                            }
                                            if(ast.eventName__c!=null && ast.eventName__c!=astoldmap.get(ast.id).eventName__c){
                                                adt.Type_Of_Movement__c = ast.eventName__c;
                                            }
                                            if(ast.src__c!=null && ast.src__c!=astoldmap.get(ast.id).src__c){
                                                adt.Message_Type__c = ast.src__c;
                                            }
                                            //adt.Latitude__c = ast.Temporary_Latitude__c;    //updated by sabareesh
                                            //adt.Longitude__c = ast.Temporary_Longitude__c;    
                                            updatedwellList.add(adt);
                                        }else if(adt.Still_in_this_Location__c){
                                          //  system.debug('line 452');
                                            adt.Still_in_this_Location__c = false;  
                                            //adt.End_Time__c = ast.Last_Connected__c; 
                                            if(ast.Start_Time__c != null){
                                                adt.End_Time__c = ast.Start_Time__c;    
                                            }else{
                                                adt.End_Time__c = ast.Last_Connected__c;
                                            }
                                            //adt.Latitude__c = ast.Temporary_Latitude__c;    //updated by sabareesh
                                            //adt.Longitude__c = ast.Temporary_Longitude__c;    
                                            updatedwellList.add(adt); 
                                            
                                            Asset_History_custom__c ad = new Asset_History_custom__c();
                                            ad.Asset__c = ast.id;
                                            ad.End_Time__c = ast.Last_Connected__c;
                                            if(ast.Start_Time__c != null){
                                                ad.Start_Time__c = ast.Start_Time__c;    
                                            }else{
                                                ad.Start_Time__c = ast.Last_Connected__c;
                                            }
                                            if(ast.Is_NimbeLink_Asset__c){
                                             //   system.debug('msgcount111--'+adt.Message_Count__c);
                                                ad.Message_Count__c = 1;
                                                ad.Current_Location_Address__c = ast.Current_Address__c;
                                            }
                                            ad.Still_in_this_Location__c = true;
                                            ad.Changed_Field__c = 'Location';
                                            if(recidmap.containskey('Asset_History_custom__c-Location')){
                                                ad.RecordTypeId =  recidmap.get('Asset_History_custom__c-Location');
                                            }
                                            if(ast.Current_Location_Name__c != null){
                                                ad.Location__c = ast.Current_Location_Name__c; 
                                                ad.Longitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglongitude;
                                                ad.Latitude__c = accountwithlatlng.get(ast.Current_Location__c).shippinglatitude;
                                                if(ast.Current_Location_Address__c!=null){
                                                    ad.Current_Location_Address__c=ast.Current_Location_Address__c;
                                                }
                                            }
                                            else if(ast.State_of_Pallet__c == 'In Transit'){
                                                ad.Location__c =  ast.State_of_Pallet__c;
                                                if(ast.Temporary_Latitude__c != null){
                                                    ad.Latitude__c = ast.Temporary_Latitude__c;    
                                                }
                                                if(ast.Temporary_Longitude__c != null){
                                                    ad.Longitude__c = ast.Temporary_Longitude__c;    
                                                }
                                            }
                                            if(ast.Battery_Voltage__c!=null){
                                                ad.Battery_Voltage__c=ast.Battery_Voltage__c;
                                            }
                                            if(ast.alt__c!=null){
                                                ad.Altitude__c = ast.alt__c;
                                            }
                                            if(ast.signal__c!=null){
                                                ad.Cellular_Signal__c = ast.signal__c;
                                            }
                                            //   if(ast.estBattPct__c!=null){
                                            // ad.Est_Remaining_Battery__c = ast.estBattPct__c;
                                            System.debug('Estimated Battery Calculated'+ast.est_Batterycalculate__c);  
                                            ad.Est_Remaining_Battery__c = ast.est_Batterycalculate__c;//Changed to capture the formula field
                                            // }
                                            if(ast.Humidity__c !=null){
                                                ad.Relative_Humidity__c = ast.Humidity__c;
                                            }
                                            if(ast.rsrp__c!=null){
                                                ad.rsrp__c = ast.rsrp__c;
                                            }
                                            if(ast.rsrq__c!=null){
                                                ad.rsrq__c = ast.rsrq__c;
                                            }
                                            if(ast.rssi__c!=null){
                                                ad.rssi__c = ast.rssi__c;
                                            }
                                            if(ast.Temperature__c!=null){
                                                ad.Temperature__c = ast.Temperature__c;
                                            }
                                            if(ast.eventName__c!=null){
                                                ad.Type_Of_Movement__c = ast.eventName__c;
                                            }
                                            if(ast.src__c!=null){
                                                ad.Message_Type__c = ast.src__c;
                                            }
                                            inserthistoryList.add(ad);
                                        }    
                                    } 
                                    
                                }
                                
                                break; 
                            }
                            
                        }
                      //  system.debug('inserthistoryList-->501'+inserthistoryList.size());
                        // Create Initial history records for Already existing asset records
                        if(!assetMap.containskey(ast.id)){
                            inserthistoryList = createAssetForInsert(ast,'both');         
                        }
                       // system.debug('recmap--->'+assetMapwithrectype);
                        if(assetMapwithrectype.containskey(ast.id)){
                            if(!assetMapwithrectype.get(ast.id).contains('Location')){
                                inserthistoryListfrominsert = createAssetForInsert(ast,'location');
                                for(Asset_History_custom__c ah : inserthistoryListfrominsert){
                                    
                                    inserthistoryList.add(ah);
                                }
                            }    
                        }
                        
                    }  
                }
            }
          //  system.debug('New History List---->'+inserthistoryList);
            if(inserthistoryList.size()>0){
                insert inserthistoryList;    
            }
           // system.debug(updatedwellList);
            if(updatedwellList.size()>0){
                update updatedwellList;    
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    public static void updatestartandaendtime(list<Asset_History_custom__c>asthislist){
        try{
            for(Asset_History_custom__c ast : asthislist){
              //  system.debug(ast);
                if(ast.Start_Time__c != null && ast.End_Time__c !=null){
                    Datetime now = ast.Start_Time__c;
                    Datetime now1 = ast.End_Time__c;
                    Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
                    Integer offset1 = TimeZone.getTimeZone('CST').getOffset(now1);
                    ast.Start_Time_Map__c = now.addSeconds(offset/1000);    
                    ast.End_Time_Map__c = now1.addSeconds(offset1/1000);    
                }/*else if(ast.Start_Time__c != null){
Datetime now = ast.Start_Time__c;
Integer offset = TimeZone.getTimeZone('CST').getOffset(now);
ast.Start_Time_Map__c = now.addSeconds(offset/1000);
}*/
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    @auraEnabled
    public static void createandUpdateInventory(){
       // system.debug('in normal method');   
        list<Inventory__c> updatelist = new list<Inventory__c>();
        try{
            for(Inventory__c inv : [select id,Location_Account__c,Is_In_Transit__c,Parent_Account__c,Rack_Type__c,Asset_Count__c from Inventory__c]){
                inv.Asset_Count__c = 0; 
                updatelist.add(inv);
                
            }
            if(updatelist.size()>0){
                update updatelist;    
            }
            
            
            map<string,integer> inventorycombocount = new map<string,integer>();
            
            for(asset ast : [select id,name,Current_Location__c,State_of_Pallet__c,Rack_Type__c,AccountId from asset where Is_Access_Point__c = false and AccountId!=null]){
                integer count;
                //  system.debug(ast);
                if(ast.Current_Location__c != null){
                    
                    if(inventorycombocount.containskey(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c)){
                        
                        count = inventorycombocount.get(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c);
                        count = count + 1;
                        inventorycombocount.put(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c, count); 
                    }else{
                        inventorycombocount.put(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c, 1);    
                    }
                }else if(ast.State_of_Pallet__c == 'In transit'){
                    if(inventorycombocount.containskey(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c)){
                        
                        count = inventorycombocount.get(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c);
                        count = count + 1;
                        inventorycombocount.put(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c, count); 
                    }else{
                        inventorycombocount.put(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c, 1);    
                    }    
                }
            }
           // system.debug('inventorycombocount->'+inventorycombocount.size());
           // system.debug('inventorycombocount->'+inventorycombocount);
            map<string,Inventory__c> inventoryComboMap = new map<string,Inventory__c>();
            list<Inventory__c> upsertlist = new list<Inventory__c>();
            for(Inventory__c inv : [select id,Location_Account__c,Is_In_Transit__c,Parent_Account__c,Rack_Type__c,Asset_Count__c from Inventory__c ]){
                inv.Asset_Count__c = 0;
                if(inv.Is_In_Transit__c){
                    inventoryComboMap.put(inv.Parent_Account__c+'*'+'In transit'+'*'+inv.Rack_Type__c,inv);         
                }else{
                    inventoryComboMap.put(inv.Parent_Account__c+'*'+inv.Location_Account__c+'*'+inv.Rack_Type__c,inv);     
                }
                
                
                
            }
           // system.debug('combomap'+inventoryComboMap);
            
            for(string st : inventorycombocount.keyset()){
                // system.debug(st);
                if(inventoryComboMap.containskey(st)){
                    //   system.debug('in if');
                    Inventory__c inv = new Inventory__c();
                    inv = inventoryComboMap.get(st);
                    inv.Asset_Count__c = inventorycombocount.get(st);
                    upsertlist.add(inv);        
                }else{
                    //  system.debug('in else');
                    Inventory__c inv = new Inventory__c();
                    list<string> strlist = st.split('\\*');
                    //   system.debug(strlist);
                    inv.Parent_Account__c = strlist[0];
                    if(strlist[1] == 'in transit'){
                        inv.Is_In_Transit__c = true;
                    }
                    else{
                        inv.Location_Account__c = strlist[1];   
                    }
                    inv.Rack_Type__c = strlist[2];
                    inv.Asset_Count__c = inventorycombocount.get(st);    
                    upsertlist.add(inv);
                }
            }
           // system.debug('upsertlist'+upsertlist);
            if(upsertlist.size()>0){
                upsert upsertlist;    
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }   
    
    @future
    public static void createandUpdateInventoryNimbelink(){
       // system.debug('in nimbelink method');    
        list<Inventory__c> updatelist = new list<Inventory__c>();
        try{
            for(Inventory__c inv : [select id,Location_Account__c,Is_In_Transit__c,Parent_Account__c,Rack_Type__c,Asset_Count__c from Inventory__c]){
                inv.Asset_Count__c = 0; 
                updatelist.add(inv);
                
            }
            if(updatelist.size()>0){
                update updatelist;    
            }
            
            
            map<string,integer> inventorycombocount = new map<string,integer>();
            
            for(asset ast : [select id,name,Current_Location__c,State_of_Pallet__c,Rack_Type__c,AccountId from asset where Is_Access_Point__c = false and AccountId!=null]){
                integer count;
                //  system.debug(ast);
                if(ast.Current_Location__c != null){
                    
                    if(inventorycombocount.containskey(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c)){
                        
                        count = inventorycombocount.get(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c);
                        count = count + 1;
                        inventorycombocount.put(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c, count); 
                    }else{
                        inventorycombocount.put(ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c, 1);    
                    }
                }else if(ast.State_of_Pallet__c == 'In transit'){
                    if(inventorycombocount.containskey(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c)){
                        
                        count = inventorycombocount.get(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c);
                        count = count + 1;
                        inventorycombocount.put(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c, count); 
                    }else{
                        inventorycombocount.put(ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c, 1);    
                    }    
                }
            }
           // system.debug('inventorycombocount->'+inventorycombocount.size());
          //  system.debug('inventorycombocount->'+inventorycombocount);
            map<string,Inventory__c> inventoryComboMap = new map<string,Inventory__c>();
            list<Inventory__c> upsertlist = new list<Inventory__c>();
            for(Inventory__c inv : [select id,Location_Account__c,Is_In_Transit__c,Parent_Account__c,Rack_Type__c,Asset_Count__c from Inventory__c ]){
                inv.Asset_Count__c = 0;
                if(inv.Is_In_Transit__c){
                    inventoryComboMap.put(inv.Parent_Account__c+'*'+'In transit'+'*'+inv.Rack_Type__c,inv);         
                }else{
                    inventoryComboMap.put(inv.Parent_Account__c+'*'+inv.Location_Account__c+'*'+inv.Rack_Type__c,inv);     
                }
            }
          //  system.debug('combomap'+inventoryComboMap);
            
            for(string st : inventorycombocount.keyset()){
                // system.debug(st);
                if(inventoryComboMap.containskey(st)){
                    //   system.debug('in if');
                    Inventory__c inv = new Inventory__c();
                    inv = inventoryComboMap.get(st);
                    inv.Asset_Count__c = inventorycombocount.get(st);
                    upsertlist.add(inv);        
                }else{
                    //  system.debug('in else');
                    Inventory__c inv = new Inventory__c();
                    list<string> strlist = st.split('\\*');
                    //   system.debug(strlist);
                    inv.Parent_Account__c = strlist[0];
                    if(strlist[1] == 'in transit'){
                        inv.Is_In_Transit__c = true;
                    }else{
                        inv.Location_Account__c = strlist[1];   
                    }
                    inv.Rack_Type__c = strlist[2];
                    inv.Asset_Count__c = inventorycombocount.get(st);    
                    upsertlist.add(inv);
                }
            }
           // system.debug('upsertlist'+upsertlist);
            if(upsertlist.size()>0){
                upsert upsertlist;    
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    
    public static void updatedwelldays(list<Asset> asst , map<id,Asset> assetmap)
    { 
        set<id> assetids = new set<Id>();
        try{
            for(asset ast : asst){
                assetids.add(ast.id);    
            }
            list<Asset_History_custom__c> AstHistorylist = new list<Asset_History_custom__c>();
            list<Asset_History_custom__c> AstHistorylist1 = new list<Asset_History_custom__c>();
            map<id,list<Asset_History_custom__c>> historymap = new map<id,list<Asset_History_custom__c>>();
            
            for(Asset_History_custom__c ast : [select id,Asset__c,Start_Time__c,Consider_for_Dwell__c, Location__c from Asset_History_custom__c where (Consider_for_Dwell__c = true or Still_in_transit__c = true) and  Asset__c IN :assetids ORDER BY Createddate ASC ]){ 
                
                if(historymap.containskey(ast.Asset__c)){
                    AstHistorylist1 = historymap.get(ast.Asset__c);
                    AstHistorylist1.add(ast);
                    historymap.put(ast.Asset__c,AstHistorylist1 );
                }else{
                    historymap.put(ast.Asset__c, new list<Asset_History_custom__c>{ ast});    
                }
                
            } 
            for(Asset ast : asst){
                if(ast.Current_Location__c != assetmap.get(ast.id).Current_Location__c && ast.Current_Location__c != null){
                    
                    if(historymap.containskey(ast.id)){
                        for(Asset_History_custom__c AstHistory : historymap.get(ast.id)){
                            AstHistory.Consider_for_Dwell__c = false;
                            AstHistory.Still_in_transit__c = false;
                          //  system.debug('Still_in_transit__c');
                            
                            AstHistorylist.add(AstHistory);
                            
                        }
                    }
                }      
               // system.debug('hislist'+AstHistorylist); 
                update AstHistorylist;
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    
    public static void updateddwell(list<Asset> assetnewlist, map<id,Asset> assetoldmap){
        
        set<id> assetids = new set<Id>();
        set<id> accids = new set<Id>();
        map<id,string> accMap = new map<id,string>();
        try{
            for(asset ast : assetnewlist){  
                assetids.add(ast.id);
                accids.add(ast.Last_Known_Location__c);
            }
            for(account acc : [select id,name from account where id IN : accids]){
                accMap.put(acc.id,acc.name);
            }
            List<Asset_History_custom__c>insertlst=new list<Asset_History_custom__c>();
           /* for(Asset_History_custom__c ast : [select id,Asset__c,Start_Time__c,Consider_for_Dwell__c, Location__c from Asset_History_custom__c where Consider_for_Dwell__c = true and  Asset__c IN :assetids ORDER BY Createddate ASC limit 1 ]){ 
                historymap.put(ast.Asset__c, ast);
            } */
            Decimal dwelldays = 0;
            integer loopcount = 0;
//            map<id,Asset_History_custom__c> historymap = new map<id,Asset_History_custom__c>();
//            map<id,Asset_History_custom__c> historyLatestmap = new map<id,Asset_History_custom__c>();
            
            for(Asset ast : assetnewlist){
                system.debug('akajakaj'+ast.Total_Dwell_Days__c+'    '+decimal.valueof(system.label.Intransit_Ever)+'      '+assetoldmap.get(ast.id).Total_Dwell_Days__c);
                system.debug('ast = '+ast.Total_Dwell_Days__c);
                system.debug('ast = '+ (assetoldmap.get(ast.id).Total_Dwell_Days__c < decimal.valueof(system.label.Intransit_Ever)));
                if(ast.Total_Dwell_Days__c >=decimal.valueof(system.label.Intransit_Ever) && assetoldmap.get(ast.id).Total_Dwell_Days__c < decimal.valueof(system.label.Intransit_Ever)){
                    DateTime startTime = null;
                    DateTime endTime = null;
                    for(Asset_History_custom__c ahc : [select id,Asset__c,Start_Time__c,End_Time__c ,Time_Difference__c ,Consider_for_Dwell__c, Location__c from Asset_History_custom__c where Consider_for_Dwell__c = true  and Asset__c = :ast.Id ORDER BY Start_Time__c ASC ]){ 
                        if (loopcount == 0) {
                            startTime = ahc.Start_Time__c;
//                            historymap.put(ahc.Asset__c, ahc);
                        } 
                        dwelldays += ahc.Time_Difference__c;
                        if (dwelldays >=14) {
                            endTime = ahc.End_Time__c;
//                            historyLatestmap.put(ahc.Asset__c, ahc);
                            break;
                        } 
                        loopcount ++;
                    }
                    system.debug('Intransit_Ever = ');
                    Asset_History_custom__c asth = new Asset_History_custom__c();
                    asth.Asset__c = ast.id;
                    if(accMap.containskey(ast.Last_Known_Location__c))
                        asth.Last_Known_Location__c = accMap.get(ast.Last_Known_Location__c);
//                    if(historymap.containskey(ast.id))
                        asth.Start_Time__c = startTime;//historymap.get(ast.id).Start_Time__c;
//asth.End_Time__c = ast.Last_Connected__c;
                    
//                    if(historyLatestmap.containskey(ast.id))
                    asth.End_Time__c = endTime;//historyLatestmap.get(ast.id).End_Time__c;
                    
                    system.debug('last connected'+ ast.Last_Connected__c);
                    asth.Still_in_transit__c = true;
                    asth.Location__c = 'In Transit - Ever';
                    asth.Total_Dwell_Days__c = ast.Total_Dwell_Days__c;
                    asth.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDeveloperName().get('Dwell_Time').getRecordTypeId();
                    insertlst.add(asth);
                }
                
            }
            insert insertlst;
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
        
    }
    
    public static void updateFacilityLocation(list<asset> astlist, map<id,asset>astoldMap,boolean isinsert, boolean isupdate){
        map<id,set<id>> idmap = new map<id,set<id>> ();
        for(asset sd:astlist)
        {
            idmap.put(sd.AccountId,new set<id>{sd.AccountId} );
        }
        /*    for(Account downcustom:[SELECT Id, Name,parentid FROM Account where parentid =:idmap.keyset()])
{
if(idmap.containskey(downcustom.parentid))
{
idmap.get(downcustom.parentid).add(downcustom.Id);
}
}*/
        for(Related_Customer__c rc : [SELECT Id, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c in :idmap.keyset()])
        {
            if(idmap.containskey(rc.Source_Account__c))
            {
                idmap.get(rc.Source_Account__c).add(rc.Related_To__c);
                
            }
        }  
        
        List<Nested_Geofence__mdt> mdtlist = new list<Nested_Geofence__mdt>([select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt]);
        try{
            if(isinsert){
                for (Asset ast:astlist){
                    
                    if(ast.Temporary_Latitude__c != null || ast.Temporary_Longitude__c != null){
                        for (Nested_Geofence__mdt mdt:mdtlist){
                            Double result;
                            // if(mdt.Current_Location_Id__c == null)//which is equal to facility having value
                            if(mdt.Facility_Location__c != null)
                            {
                                Location loc1 = Location.newInstance(ast.Temporary_Latitude__c,ast.Temporary_Longitude__c);
                                Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                                result = Location.getDistance(loc1, loc2, 'mi');   
                             //   system.debug('Results'+result);
                                if(result<mdt.Diameter__c && idmap.get(ast.AccountId).contains(mdt.Current_Location_Id__c)){
                                    ast.Facility_Location__c =mdt.Facility_Location__c;  
                                //    system.debug('facility loc'+ast.Facility_Location__c );
                                    break;
                                }
                                else {
                                    ast.Facility_Location__c =null;
                                 //   system.debug('facility loc---'+ast.Facility_Location__c );
                                }
                                
                            }
                            // else if(mdt.Current_Location_Id__c!=null){
                            else if(mdt.Facility_Location__c == null){
                                Location loc1 = Location.newInstance(ast.Temporary_Latitude__c,ast.Temporary_Longitude__c);
                                Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                                result = Location.getDistance(loc1, loc2, 'mi'); 
                                //  if(result<mdt.Diameter__c)
                                if(result < mdt.Diameter__c  && idmap.get(ast.AccountId).contains(mdt.Current_Location_Id__c))
                                {
                                    ast.Current_Location__c = mdt.Current_Location_Id__c;  
                                    break; 
                                } 
                                else {
                                    ast.Facility_Location__c =null;
                                }
                                
                            }  
                        }
                        
                    }
                }  
            }
            if(isupdate){
                for (Asset ast:astlist){
                    
                    if(ast.Temporary_Latitude__c != astoldMap.get(ast.id).Temporary_Latitude__c || ast.Temporary_Longitude__c != astoldMap.get(ast.id).Temporary_Longitude__c){
                        for (Nested_Geofence__mdt mdt:mdtlist){
                          //  system.debug('mdt----'+mdt);
                            Double result;
                            if(mdt.Facility_Location__c != null )
                            {
                                Location loc1 = Location.newInstance(ast.Temporary_Latitude__c,ast.Temporary_Longitude__c);
                                Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                                result = Location.getDistance(loc1, loc2, 'mi');   
                              //  system.debug('result--'+ result);
                              //  system.debug('Results'+result);
                                if(result<mdt.Diameter__c && idmap.get(ast.AccountId).contains(mdt.Current_Location_Id__c))
                                    //  if(result<mdt.Diameter__c && idmap2.get(ast.AccountId).Account_Name__c.contains(mdt.Current_Location__c))
                                {
                                    ast.Facility_Location__c =mdt.Facility_Location__c;  
                                    break;
                                }
                                else {
                                    ast.Facility_Location__c =null;
                                }
                                
                            }
                            else if(mdt.Facility_Location__c == null )
                            {
                                Location loc1 = Location.newInstance(ast.Temporary_Latitude__c,ast.Temporary_Longitude__c);
                                Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                                result = Location.getDistance(loc1, loc2, 'mi');
                              //  system.debug('result--'+ result);
                                //    if(result < mdt.Diameter__c )
                                if(result < mdt.Diameter__c  && idmap.get(ast.AccountId).contains(mdt.Current_Location_Id__c))
                                {
                                    ast.Current_Location__c = mdt.Current_Location_Id__c;  
                                    break;  
                                }  
                                else {
                                    ast.Facility_Location__c =null;
                                }
                                
                                
                            }  
                        }
                        
                    }
                  //  system.debug('currentloc---'+ast.Current_Location__c);
                }      
            }
        }
        catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    }
    public static void updateEstBatteryPercentage(list<asset> newAssetList, map<id,asset> OldAssetMap){
        System.debug('Inside Est. Battery function');
        System.debug('Update Est. Battery Percentage Asset List==>'+newAssetList);
        for(asset ast : newAssetList){
            if(ast.Battery_Replaced_Date__c != null && ast.Power_Reset_Time__c != null && ast.Battery_Replaced_Date__c >= (ast.Power_Reset_Time__c).date() && ast.Power_Reset_Occurred__c){
             //   system.debug('3---');
                ast.Power_Reset_Occurred__c = false;
                ast.Power_Reset_Time__c = null;
            }
        }
    }
    public static void updateLastKnownLocation(list<asset> newAssetList, map<id,asset> OldAssetMap){
        
        for(asset ast : newAssetList){
            if(ast.Current_Location__c != OldAssetMap.get(ast.id).Current_Location__c && OldAssetMap.get(ast.id).Current_Location__c != null )
                ast.Last_Known_Location__c = OldAssetMap.get(ast.id).Current_Location__c;
        }
    } 
    
  /*  public static void checkLastConnected(list<asset> astlist, map<id,asset>astoldMap,boolean isinsert, boolean isupdate){
        if(isupdate){
            for(asset ast : astlist){
              //  system.debug('ast.Last_Connected__c'+ast.Last_Connected__c+' astoldMap.get(ast.Id).Last_Connected__c   '+astoldMap.get(ast.Id).Last_Connected__c);
                if(ast.Last_Connected__c != null && ast.Last_Connected__c < astoldMap.get(ast.Id).Last_Connected__c){
                    //  ast.Last_Connected__c = astoldMap.get(ast.Id).Last_Connected__c;
                    throw new AssetException('Correct Time-'+ astoldMap.get(ast.Id).Last_Connected__c);
                    
                }
            }
            
        }
        
    }*/
}