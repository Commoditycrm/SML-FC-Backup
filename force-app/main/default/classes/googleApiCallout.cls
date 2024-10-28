/**
 * @author -- Gokulprasath
 * @date -- 02/20/2019
 * @description -- This Class will make a callout to GoogleAPI and get the address based on the provided latitude,longitude.
 **/
public class googleApiCallout {
      
    // This method will make Google API callout and update the asset address fields based on the response.
    
    @future(callout=true)
    public static void httpreq(decimal cirlat, decimal cirlong, id assetid){
        List<Asset_History_custom__c> asstHisList = new List<Asset_History_custom__c>();
        //list<Debug_Logs__c> dllist = new list<Debug_Logs__c>();
        list<Google_API_Data__c> insertAPIData = new list<Google_API_Data__c>();
        try{
            Asset astrec = [select id,Device_Id__c,Current_Zip_Code__c,Current_Street_Address__c,Current_State__c,Current_City__c,Current_Address__c,Last_Connected__c,Temporary_Latitude__c,Temporary_Longitude__c,LastModifiedDate from asset where id=: assetid limit 1];
            if(!compareGoogleAPIData.performAction(cirlat,cirlong,astrec)){
                   /* Debug_Logs__c dc = new Debug_Logs__c();
                    dc.Asset_Device_ID__c = astrec.Device_Id__c;
                    dc.Last_connected_Time__c =astrec.Last_Connected__c;
                    dc.Latitude__c = decimal.valueof(string.valueof(astrec.Temporary_Latitude__c).left(7));
                    dc.Longitude__c = decimal.valueof(string.valueof(astrec.Temporary_Longitude__c).left(7));
                    dc.Last_Modified_Date__c = astrec.LastModifiedDate; 
                    dllist.add(dc);*/
                //Google API Calling
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setMethod('GET');
                req.setHeader('content-type','application/x-www-form-urlencoded');
                req.setHeader('Accept', 'application/json'); 
                string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+cirlat+'%20'+cirlong+'&sensor=true';
              //  system.debug(endpt);    
                req.setEndpoint(endpt);
                HttpResponse res;
                res= h.send(req);
                // Parsing the given response in order to update streetaddress,city,state and zip code
                //system.debug('response'+res.getBody());
                Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
              //  system.debug(results1);
                List<Object> mapdetails = (List<Object>) results1.get('results');
                Map<String,Object> addrvalMap = new map<String,Object>();
                
                for(object obj : mapdetails){
                    addrvalMap = (Map<String,Object>)obj;
                    break;
                  //  system.debug(obj);     
                }
                List<Object> addressdetails = new List<Object>();
                if(addrvalMap.containskey('address_components')){
                    addressdetails = (List<Object>) addrvalMap.get('address_components');    
                }
              //  system.debug(addressdetails);
                string types;
               
                if(addrvalMap.containskey('formatted_address')){
                    astrec.Current_Address__c = (string)addrvalMap.get('formatted_address');    
                }
                
                Map<String,Object> commap = new map<String,Object>();
                for(object obj : addressdetails){
                    commap = (Map<String,Object>)obj;
                    if(commap.containskey('types') ){
                        for(object obj1 : (List<Object>) commap.get('types') ){
                       // system.debug(obj1);
                        if((string)obj1 != 'political'){
                            types = (string)obj1;     
                        }
                      }    
                    }
                    
                    if(commap.containskey('short_name')){
                      if(types == 'route' || types == 'street_number'){
                          if(astrec.Current_Street_Address__c != null){
                            astrec.Current_Street_Address__c = astrec.Current_Street_Address__c+ ' '+ (string)commap.get('short_name');    
                           }else{
                            astrec.Current_Street_Address__c = (string)commap.get('short_name');    
                               }   
                    }//IF Route
                    if(types.contains('administrative_area_level_1')){
                        astrec.Current_State__c = (string)commap.get('short_name');   
                    }
                    if(types.contains('locality')){
                        astrec.Current_City__c = (string)commap.get('short_name');   
                    }
                    if(types == 'postal_code'){
                        astrec.Current_Zip_Code__c = (string)commap.get('short_name');   
                    } 
                  }//IF ConMap
                }
                if(!String.isBlank(astrec.Current_Address__c) ||
                  !String.isBlank(astrec.Current_City__c) ||
                  !String.isBlank(astrec.Current_State__c) ||
                  !String.isBlank(astrec.Current_Street_Address__c)){
                    Google_API_Data__c api = new Google_API_Data__c();
                    api.Current_Address__c = astrec.Current_Address__c;
                    api.Current_City__c = astrec.Current_City__c;
                    api.Current_State__c = astrec.Current_State__c;
                    api.Current_Street_Address__c = astrec.Current_Street_Address__c;
                    api.Current_Zip_Code__c = astrec.Current_Zip_Code__c;
                    api.Latitude__c = string.valueof(astrec.Temporary_Latitude__c).left(7);
                    api.Longitude__c = string.valueof(astrec.Temporary_Longitude__c).left(7);
                    insertAPIData.add(api);
                }

            }
            if(astrec != null){
                if(astrec.Current_Address__c != null){
                    astrec.Current_Location__c = null;
                    for(Asset_History_custom__c asstHis : [Select id,name,Asset__c,Current_Location_Address__c from Asset_History_custom__c where Location__c='In Transit' AND (Still_in_this_Location__c=true OR asset__r.Track_Full_History__c = true) AND Asset__c=:assetid order by createddate desc limit 1]){
                        asstHis.Current_Location_Address__c=astrec.Current_Address__c;
                        asstHisList.add(asstHis);
                    }
                }
               // system.debug('asset@@---'+astrec);
                Utilityclass.stopTrigger();
                update astrec;
                /*if(label.DebugLogsForAsset == 'true' && dllist.size()>0){
                    insert dllist;
                }*/
            }
            if(asstHisList.size()>0){
                update asstHisList;
            }
            if(insertAPIData.size()>0){
                insert insertAPIData;
            }
            
        //If any exceptions occur, send an email to the developers with error information.
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
        }
    
    }
    
    @future(callout=true)
    public static void httpreq1(decimal cirlat, decimal cirlong, id assethisid){
        doProcess(cirlat, cirlong, assethisid);
    }
    
    public static void doProcess(decimal cirlat, decimal cirlong, id assethisid){
        //Newly Added 
        List<Asset_History_custom__c> asstHisList = new List<Asset_History_custom__c>();
      //list<Debug_Logs__c> dllist = new list<Debug_Logs__c>();
        list<Google_API_Data__c> insertAPIData = new list<Google_API_Data__c>();
                String Current_Street_Address;
                String Current_State;
                String Current_City;
                String Current_Zip_Code;
        //END
        try{
            Asset_History_custom__c astrec = [select id,Latitude__c,Longitude__c,Asset__c,LastModifiedDate,Last_connected_Time__c,Current_Location_Address__c from Asset_History_custom__c where id=: assethisid limit 1];
            //System.debug('Google API Call out FROM httpreq1');
            if(!compareGoogleAPIData.performAction(cirlat,cirlong,astrec)){
                   /* Debug_Logs__c dc = new Debug_Logs__c();
                    dc.Asset_Device_ID__c = astrec.Asset__c;
                    dc.Last_connected_Time__c =astrec.Last_connected_Time__c;
                    dc.Latitude__c = decimal.valueof(string.valueof(astrec.Latitude__c).left(7));
                    dc.Longitude__c = decimal.valueof(string.valueof(astrec.Longitude__c).left(7));
                    dc.Last_Modified_Date__c = astrec.LastModifiedDate; 
                    dllist.add(dc);*/
             
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setTimeout(60000);
            req.setMethod('GET');
            req.setHeader('content-type','application/x-www-form-urlencoded');
            req.setHeader('Accept', 'application/json'); 
            string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+cirlat+'%20'+cirlong+'&sensor=true';
          //  system.debug(endpt);    
            req.setEndpoint(endpt);
            HttpResponse res;
            res= h.send(req);
            //system.debug('response'+res.getBody());
            Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
          //  system.debug(results1);
            List<Object> mapdetails = (List<Object>) results1.get('results');
            Map<String,Object> addrvalMap = new map<String,Object>();
            
            for(object obj : mapdetails){
                addrvalMap = (Map<String,Object>)obj;
                break;
             //   system.debug(obj);     
            }
            List<Object> addressdetails = new List<Object>();
            if(addrvalMap.containskey('address_components')){
                addressdetails = (List<Object>) addrvalMap.get('address_components');    
            }
          //  system.debug(addressdetails);
            string types;
           
            astrec.id = assethisid;
            if(addrvalMap.containskey('formatted_address')){
                astrec.Current_Location_Address__c = (string)addrvalMap.get('formatted_address');    
            }
              
            Map<String,Object> commap = new map<String,Object>();
            for(object obj : addressdetails){
               commap = (Map<String,Object>)obj;
               if(commap.containskey('types') ){
                     for(object obj1 : (List<Object>) commap.get('types') ){
                        //    system.debug(obj1);
                        if((string)obj1 != 'political'){
                            types = (string)obj1;     
                        }
                    }    
                 }
                
               if(commap.containskey('short_name')){
                        if(types == 'route' || types == 'street_number'){
                             Current_Street_Address = (string)commap.get('short_name');    
                          }
                    if(types.contains('administrative_area_level_1')){
                        Current_State = (string)commap.get('short_name');   
                    }
                    if(types.contains('locality')){
                        Current_City = (string)commap.get('short_name');   
                    }
                    if(types == 'postal_code'){
                        Current_Zip_Code = (string)commap.get('short_name');   
                    } 
                 }//If ComMap
                }//Object      
                
                //Google API DATA Insert
                if(!String.isBlank(astrec.Current_Location_Address__c)){
                    Google_API_Data__c api = new Google_API_Data__c();
                    api.Current_Address__c = astrec.Current_Location_Address__c;
                    api.Current_City__c = Current_City;
                    api.Current_State__c = Current_State;
                    api.Current_Street_Address__c = Current_Street_Address;
                    api.Current_Zip_Code__c = Current_Zip_Code;
                    api.Latitude__c = string.valueof(astrec.Latitude__c).left(7);
                    api.Longitude__c = string.valueof(astrec.Longitude__c).left(7);
                    insertAPIData.add(api);
                }
                //  system.debug('asset@@---'+astrec);
                
                 update astrec;
            }//IF Compare
            /*if(label.DebugLogsForAssetHistory == 'true' && dllist.size()>0){
                insert dllist;    
            }*/
            insert insertAPIData;
       }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
       }
    }//function
}//class