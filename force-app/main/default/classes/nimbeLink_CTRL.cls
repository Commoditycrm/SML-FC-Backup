@RestResource(urlMapping='/oldApiresponse/*')
global with sharing class nimbeLink_CTRL {
    public static decimal poweruptime2;
    public static DateTime assetLastConnected;
    Public static boolean RedesignresponseToggle;
        
    @HttpPost
    //Murali:changed the method from void to string
    global static string handleApiResponse() {
        Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
        RedesignresponseToggle = Redesign.Redesign_Api_Response_Toggle__c;
        
        if (RedesignresponseToggle == true) {
           
           RedesignNL_Controller.parseNimbeLinkResponse();
        }
        else {
              parseresponse();
            }
        //Murali:added Return
        return 'Successfull';
    }
    global static string parseresponse() {
         String deviceId;
         List<Google_API_Data__c> GADlistToInsert = new List<Google_API_Data__c>();
         List<Api_Response__c> respLst = new List<Api_Response__c>();
         Asset ast = new Asset();
         String  requestBody = RestContext.request.requestBody.toString();
         //not a future callout anymore
         //String respToUAT = ProdToUATNimblelink.basicAuthCallout(requestBody);
         Api_Response__c resp = new Api_Response__c(Incoming_Messsage__c = requestBody, 
                                                    ResEnteringDttime__c = system.now(), 
                                                    ResEnteringTime__c = (system.now().getTime()/1000),
                                                    Is_Nimbelink_Asset__c = true,
                                                    UpdateResponseToAsset__c = true,
                                                    Status__c = 'NEW');
         
         try{
             if(Label.Execute_Nimblink_Batch_Process == 'YES'){
               List<Object> templist  = new List<Object>();
               List<Object> eventlist = new List<Object>();
               List<Object> dvcstatus = new List<Object>();
               List<Object> loclist   = new List<Object>();
    
                Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
                
                if(lst_JsonParse.containskey('message')){
                    Map<String, Object> mapdetails = (Map<String, Object>) lst_JsonParse.get('message');
                    
                    if(mapdetails.containskey('data')){
                        String data = (String) mapdetails.get('data');    
                        
                        if(data != null){
                            String response = EncodingUtil.base64Decode(data).toString();
                            
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
                                    
                                    if(datamap.containskey('deviceStatus')){
                                        dvcstatus = (list<Object>)datamap.get('deviceStatus');
                                    }
                                    
                                    Map<String, Object> datamap1 = new Map<String, Object>();
                                    if(commap.containskey('base')){
                                        datamap1 = (Map<String, Object>)commap.get('base'); 
                                        deviceId = (String)datamap1.get('id');
                                    }
                                    
                                    ast = getasset(deviceId);
                                   
                                    
                                  
                                                                      
                                    // reparing response records
                                    resp.data__c      = String.valueof(datamap);
                                    resp.base__c      = String.valueof(datamap1);
                                    resp.Device_Id__c = deviceId;
                                    resp.device_status__c = JSON.serialize(dvcstatus);
                                    resp.info__c      = String.valueof(datamap.get('info'));
                                    resp.events__c    = String.valueof(datamap.get('events'));
                                    resp.accel__c     = String.valueof(datamap.get('accel'));
                                    resp.Loc__c       = String.valueof(datamap.get('loc'));
                                    resp.Temp__c      = String.valueof(datamap.get('temp'));  
                                   // resp.Asset__c     = ast.Id;
                                    //respLst.add(resp);
                                    system.debug('###--datamap--'+ datamap);
                                    if(datamap.containskey('loc')){
                                       system.debug('###--createGooleAPIRecords--');
                                       createGooleAPIRecords(datamap, ast);
                                        
                                    }
                                     
                                    if(ast.Id == null){
                                        upsert ast device_id__c;
                                    }
                                        resp.asset__c = ast.id;
                                         respLst.add(resp);
                                    
                                }
                            }
                        }
                    }
                }
                
                if(ast != null){
                    insert respLst;
                }
                                
           }else if(requestBody != null && Label.Execute_Nimblink_Batch_Process == 'NO'){
            //   nimbeLink_CTRL_Prod.parseresponse(requestBody);
           }
       } catch(exception ex){
           if(ast.Id == null)
           {upsert ast device_id__c;} 
            resp.Asset__c=ast.Id;
           respLst.add(resp);
            if(ast != null){
                    insert respLst;
                }
            nimbeLink_CTRL_Helper.sendemail(ex.getMessage()+' -- MethodName : parseresponse()-- '+' -- On Line -- '+ex.getLineNumber()+' -- Type -- '+ 
                    ex.getTypeName()+' -- Cause -- '+ex.getCause()+' -- Stack --'+ ex.getStackTraceString()+'Asset:'+ast.Id+'ResponseId:'+resp.id+resp.Incoming_Messsage__c);
       }
        Redesign_NL__mdt Redesign= RedesignNL_Helper.getRedesignMetadata('Default');
        if(Redesign.Capture_Child_Response__c == true) {
           // String result = RedesignNL_Controller.parseRequestBody(respLst[0].Incoming_Messsage__c, respLst[0], true);
        }
        return 'sucessfull';
    }
    
   public static void createGooleAPIRecords(Map<String, Object> datamap, Asset ast){
        List<Google_API_Data__c> GADlistToInsert = new List<Google_API_Data__c>();
        
        Map<String,List<String>> latLonMap = new Map<String,List<String>>();   
        for(Object loc : (list<Object>) datamap.get('loc')){
            Map<String, Object> locmap = (Map<String,Object>) loc;
            if(locmap!=null && locmap.containsKey('haccRank') && locmap.get('haccRank') == 0 && locmap.containsKey('lat') && locmap.containsKey('lon')){
                string latfull = string.valueOf(locmap.get('lat'));
                string lngfull = string.valueOf(locmap.get('lon'));
                string lat = string.valueof(locmap.get('lat')).left(7);
                string lng = string.valueof(locmap.get('lon')).left(7);
                
                Boolean isGeofenceFound = checkGeofence(ast.AccountId, Decimal.valueOf(latfull), Decimal.valueOf(lngfull));
                system.debug('###--lat--'+ lat);
                system.debug('###--lng--'+ lng);
                
                if(isGeofenceFound == false){
                if(latLonMap == null || !latLonMap.containsKey(lat) || (latLonMap!=null & latLonMap.containsKey(lat) & !latLonMap.get(lat).contains(lng))){
                    List<Google_API_Data__c> GADlist = [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,
                                                        Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                        where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lng+'%' ];
                                                        
                    system.debug('###--GADlist--'+ GADlist);
                    if(GADlist== null || (GADlist!=null && GADlist.isEmpty())){
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
                        system.debug('###--res.getBody()--'+ res.getBody());
                        
                      
                    if(res.getStatusCode() == 200){    
                        Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=latfull, Longitude__c=lngfull);
                        system.debug(results1);
                        List<Object> mapGADdetails = (List<Object>) results1.get('results');
                        
                        Map<String,Object> addrvalMap = new map<String,Object>();
                        for(object obj : mapGADdetails){
                            addrvalMap = (Map<String,Object>)obj;
                            break;    
                        }
                        
                        List<Object> addressdetails = new List<Object>();
                        if(addrvalMap.containskey('address_components')){
                            addressdetails = (List<Object>) addrvalMap.get('address_components');    
                        }
                        
                        if(addrvalMap.containskey('formatted_address')){
                            gadRec.Current_Address__c = (string)addrvalMap.get('formatted_address');    
                        }
                        
                        Map<String,Object> comGADmap = new map<String,Object>();
                        string types;
                        for(object obj : addressdetails){
                            comGADmap = (Map<String,Object>)obj;
                            if(comGADmap.containskey('types')){
                                for(object obj1 : (List<Object>) comGADmap.get('types') ){
                                    system.debug(obj1);
                                    if((string)obj1 != 'political'){
                                        types = (string)obj1;     
                                    }
                                }    
                            }
                            
                            if(comGADmap.containskey('short_name')){
                                if(types == 'route' || types == 'street_number'){       
                                    gadRec.Current_Street_Address__c = (string)comGADmap.get('short_name');        
                                }
                                if(types.contains('administrative_area_level_1')){
                                    gadRec.Current_State__c = (string)comGADmap.get('short_name');   
                                }
                                if(types.contains('locality')){
                                    gadRec.Current_City__c = (string)comGADmap.get('short_name');   
                                }
                                if(types == 'postal_code'){
                                    gadRec.Current_Zip_Code__c = (string)comGADmap.get('short_name');   
                                }
                            }//IF Contains Short Name
                        } //For Address Details
                        
                        if(!String.isBlank(gadRec.Current_Address__c)){
                            GADlistToInsert.add(gadRec); 
                             if(latLonMap.containsKey(lat)){
                                if(!latLonMap.get(lat).contains(lng)){
                                latLonMap.get(lat).add(lng);
                                } 
                            }else{
                            latLonMap.put(lat,new List<String> {lng});
                            } 
                        }
                        
                    }
                        else{
                            nimbeLink_CTRL_Helper.sendemail('Google Api Response Failed - '+ 'Asset - '+ ast.Id + '\n' + endpt + '\n' + res.getBody());
                        }                 
                    }
                }
                }
            }
        }
        
        system.debug('###--GADlistToInsert--'+ GADlistToInsert);
        if(!GADlistToInsert.isEmpty()){
            insert GADlistToInsert;  
        }
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
        // Create new Asset if asset not available
        if(asst.Id == null){
            String accountid;
            for(account acc:[select Id,name from account where name = 'Testing']){
                accountid = acc.Id;
            }
            
            asst.name = deviceId;
            asst.Device_Id__c = deviceId;
            asst.Capturing_Response__c= true;
            asst.accountid = accountid;
            
            //insert asst;
        }
        
        return asst;
    }
    
    public static Boolean checkGeofence(String accId, decimal lat, decimal lng){
        Boolean flag = false;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        
        if(accId != null){
            accids.add(accId );
        
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accId ]){
                
                accids.add(rc.Source_Account__c);
                accids.add(rc.Related_To__c);
            }
            
            for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
                accmap.put(acc.id,acc);    
            }
            
            for(id acc :accids ){
                if(accmap.containskey(acc)){
                    Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                    Location loc2 = Location.newInstance(lat, lng);
                    Double result = Location.getDistance(loc1, loc2, 'mi');      
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                        flag = true;
                        system.debug('###--acc--'+ acc + ' = ' + accmap.containskey(acc));
                        break;  
                    }
                }
            } 
            
            if(flag == false){
                for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){
                
                    Location loc1 = Location.newInstance(lat, lng);
                    Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    //system.debug('result--'+ result);
                    if(result < mdt.Diameter__c){
                        flag = true;
                        system.debug('###--mdt--'+ mdt);
                        
                        break;  
                    }  
                }
            }
        }
        
        return flag ;
    }
}