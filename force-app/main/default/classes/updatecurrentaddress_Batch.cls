global with sharing class updatecurrentaddress_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts , Database.Stateful
{
     
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords;
    public Integer totalFailureRecords;
    public List<String> failureMsgs;
        
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        
        this.batchName = 'updatecurrentaddress_Batch';
        this.batchStartTime = system.Now();
        this.totalRecords = this.totalFailureRecords = 0;
        this.failureMsgs = new List<String>();
        
        DateTime lastfiveminutes = Datetime.now().addMinutes(-5);
        string state = 'in transit';
       // string devid = 'at6-b1e1b33c1d58';
        // String Query = 'select id,name,Device_Id__c,Last_Connected__c,LastModifiedDate,Temporary_Latitude__c,State_of_Pallet__c,Current_Zip_Code__c,Current_City__c,Current_State__c,Current_Street_Address__c,Current_Address__c,Temporary_Longitude__c from Asset where Temporary_Latitude__c!=null AND';
        //Query += ' Temporary_Longitude__c !=null AND State_of_Pallet__c =:state AND Batch_Update__c = true and Is_NimbeLink_Asset__c = false order by Last_Connected__c asc  limit 99';
        String Query = 'select id,name,Device_Id__c,Last_Connected__c,LastModifiedDate,Temporary_Latitude__c,State_of_Pallet__c,Current_Address__c,Current_Zip_Code__c,Current_City__c,Current_State__c,Current_Street_Address__c,Temporary_Longitude__c from Asset where Temporary_Latitude__c!=null AND';
        Query += ' Temporary_Longitude__c !=null AND State_of_Pallet__c =:state and Batch_Update__c = true order by Last_Connected__c asc  limit 99';
        return Database.getQueryLocator(Query);     
        
    }
    global void execute(Database.BatchableContext bc, List<Asset> getAssetRecords)
    {
        List<Asset_History_custom__c> asstHisList= new List<Asset_History_custom__c>();
        list<asset> updateassetlist = new list<asset>();
       // list<Debug_Logs__c> dllist = new list<Debug_Logs__c>();
        list<Google_API_Data__c> insertAPIData = new list<Google_API_Data__c>();
        
        totalRecords += getAssetRecords.size();
        
        try{
            for(Asset asstRec : getAssetRecords)
            {
                    asstRec.Current_City__c = '';
                    asstRec.Current_Address__c = '';
                    asstRec.Current_State__c = '';
                    asstRec.Current_Street_Address__c = '';
                    asstRec.Current_Zip_Code__c = '';
               /* system.debug(asstRec.Current_City__c );
                system.debug(asstRec.Current_Address__c );
                system.debug(asstRec.Current_State__c);
                system.debug(asstRec.Current_Street_Address__c);
                system.debug(asstRec.Current_Zip_Code__c);*/
                if(!compareGoogleAPIData.performAction(asstRec.Temporary_Latitude__c,asstRec.Temporary_Longitude__c,asstRec)){
                  /*Debug_Logs__c dc = new Debug_Logs__c();
                    dc.Asset_Device_ID__c = asstRec.Device_Id__c;
                    dc.Last_connected_Time__c =asstRec.Last_Connected__c;
                    dc.Latitude__c = asstRec.Temporary_Latitude__c;
                    dc.Last_Modified_Date__c = asstRec.LastModifiedDate; 
                    dc.Longitude__c = asstRec.Temporary_Longitude__c;
                    dllist.add(dc);*/
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(60000);
                    req.setMethod('GET');
                    req.setHeader('content-type','application/x-www-form-urlencoded');
                    req.setHeader('Accept', 'application/json'); 
                    string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+asstRec.Temporary_Latitude__c+'%20'+asstRec.Temporary_Longitude__c+'&sensor=true';
                   // system.debug(endpt);    
                    req.setEndpoint(endpt);
                    HttpResponse res = h.send(req);
                    
                    // Parsing the given response in order to update streetaddress,city,state and zip code
                   // system.debug('response'+res.getBody());
                    Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                   // system.debug(results1);
                    List<Object> mapdetails = (List<Object>) results1.get('results');
                    Map<String,Object> addrvalMap = new map<String,Object>();
                    
                    for(object obj : mapdetails)
                    {
                        addrvalMap = (Map<String,Object>)obj;
                        break;
                       // system.debug(obj);     
                    }
                    List<Object> addressdetails = new List<Object>();
                    if(addrvalMap.containskey('address_components'))
                    {
                        addressdetails = (List<Object>) addrvalMap.get('address_components');    
                    }
                   // system.debug(addressdetails);
                    string types;
                    
                    if(addrvalMap.containskey('formatted_address')){
                       asstRec.Current_Address__c = (string)addrvalMap.get('formatted_address');    
                    }
                   // system.debug('asstRec.Current_Address__c---'+asstRec.Current_Address__c);
                    Map<String,Object> commap = new map<String,Object>();
                    for(object obj : addressdetails)
                    {
                        commap = (Map<String,Object>)obj;
                        if(commap.containskey('types') )
                        {
                            for(object obj1 : (List<Object>) commap.get('types') )
                            {
                              //  system.debug(obj1);
                                if((string)obj1 != 'political')
                                {
                                    types = (string)obj1;     
                                }
                                
                            }    
                        }
                      /*  system.debug('commap----'+commap);
                         system.debug('types----'+types);*/
                        if(commap.containskey('short_name'))
                        {
                            if(types == 'route' || types == 'street_number')
                            {
                                if(asstRec.Current_Street_Address__c != null)
                                {
                                    asstRec.Current_Street_Address__c = asstRec.Current_Street_Address__c+ ' '+ (string)commap.get('short_name');    
                                }
                                else
                                {
                                    asstRec.Current_Street_Address__c = (string)commap.get('short_name');    
                                }   
                            }
                            // system.debug('asstRec.Current_Street_Address__c---'+asstRec.Current_Street_Address__c);
                            if(types.contains('administrative_area_level_1'))
                            {
                                asstRec.Current_State__c = (string)commap.get('short_name');   
                            }
                         //   system.debug('asstRec.Current_State__c---'+asstRec.Current_State__c);
                            if(types.contains('locality'))
                            {
                                asstRec.Current_City__c = (string)commap.get('short_name');   
                            }
                         //   system.debug('asstRec.Current_City__c---'+asstRec.Current_City__c);
                            if(types == 'postal_code'){
                                asstRec.Current_Zip_Code__c = (string)commap.get('short_name');   
                            } 
                         //   system.debug('asstRec.Current_Zip_Code__c---'+asstRec.Current_Zip_Code__c);
                            
                        }//IF Contains Short Name
                    } //For Address Details
                    
                //Added to insert in to Google API    
                    if(!String.isBlank(asstRec.Current_Address__c)){
                        Google_API_Data__c api = new Google_API_Data__c();
                        api.Current_Address__c = asstRec.Current_Address__c;
                        api.Current_City__c = asstRec.Current_City__c;
                        api.Current_State__c = asstRec.Current_State__c;
                        api.Current_Street_Address__c = asstRec.Current_Street_Address__c;
                        api.Current_Zip_Code__c = asstRec.Current_Zip_Code__c;
                        api.Latitude__c = string.valueof(asstRec.Temporary_Latitude__c);
                        api.Longitude__c = string.valueof(asstRec.Temporary_Longitude__c);                    
                        insertAPIData.add(api);
                    }
                    
                }//IF Compare
                if(!String.isBlank(asstRec.Current_Address__c))//asstRec.Current_Address__c != null)
                {
                    asstRec.Current_Location__c = null;
                    for(Asset_History_custom__c asstHis : [Select id,name,Asset__c,Current_Location_Address__c from Asset_History_custom__c where Location__c='In Transit' AND (Still_in_this_Location__c=true OR Current_Message_Type__c=true) AND Asset__c=:asstRec.Id])
                    {
                        asstHis.Current_Location_Address__c=asstRec.Current_Address__c;
                        asstHisList.add(asstHis);
                    }
                    asstRec.Batch_Update__c = false;
                    updateassetlist.add(asstRec);    
                }
                
                //if
            }//for
            if(updateassetlist.size()>0){
                //Utilityclass.stopTrigger();
                update updateassetlist;    
            }
          //  system.debug('asstHisList'+asstHisList.size());
            if(asstHisList.size()>0){
                update asstHisList;
            }
            /*if(label.DebugLogsForAsset == 'true' && dllist.size()>0){
                insert dllist;  
            } */
            
            //Added to insert in to Google API
            if(insertAPIData.size() > 0)
                insert insertAPIData;
                
           /* 
            system.debug(limits.getQueries()+'out of'+limits.getLimitQueries());
            system.debug(limits.getQueryRows()+'out of'+limits.getLimitQueryRows());  
            system.debug(limits.getCallouts()+'out of'+limits.getLimitCallouts()); */
        
        }catch(exception ex){
            failureMsgs.add(ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
        
    }//Global 
    global void finish(Database.BatchableContext bc){
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = this.batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
        batchLog.Status__c = 'Completed';
        batchLog.Total_no_of_records_processed__c = totalRecords;
        insert batchLog;
    }    
    
}