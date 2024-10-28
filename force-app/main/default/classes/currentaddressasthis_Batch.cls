global with sharing class currentaddressasthis_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords;
    public Integer totalFailureRecords;
    public List<String> failureMsgs;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        this.batchName = 'currentaddressasthis_Batch';
        this.batchStartTime = system.Now();
        this.totalRecords = this.totalFailureRecords = 0;
        this.failureMsgs = new List<String>();
        
        DateTime lastfiveminutes=Datetime.now().addMinutes(-5);
        string state = 'in transit';   
        String Query = 'select Asset__c,Asset__r.Device_Id__c,Start_Time__c,LastModifiedDate,End_Time__c,Location__c,Latitude__c,Longitude__c,Last_Connected_Time__c,Current_Location_Address__c from Asset_History_custom__c where Latitude__c != null and Longitude__c != null and location__c =:state and Current_Location_Address__c =null order by createddate desc limit 100' ;
        return Database.getQueryLocator(Query);     

    }
    global void execute(Database.BatchableContext bc, List<Asset_History_custom__c> getAssetRecords){
        //system.debug('asset records'+ getAssetRecords.size());
        List<Asset_History_custom__c> asstHisList= new List<Asset_History_custom__c>();
        //list<Debug_Logs__c> dllist = new list<Debug_Logs__c>();
        list<Google_API_Data__c> insertAPIData = new list<Google_API_Data__c>();
        String currentcity;
        String currentstate;
        String currentpostal;
        String currentstreet;
        
        totalRecords += getAssetRecords.size();
        
        try{
            for(Asset_History_custom__c asstRec : getAssetRecords){
                
                if(!compareGoogleAPIData.performAction(asstRec.Latitude__c,asstRec.Longitude__c,asstRec)){
               /* Debug_Logs__c dc = new Debug_Logs__c();
                dc.Asset_Device_ID__c = asstRec.Asset__r.Device_Id__c;
                dc.Latitude__c = asstRec.Latitude__c;
                 DC.Longitude__c = asstRec.Longitude__c;
                 dc.Last_Modified_Date__c = asstRec.LastModifiedDate; 
                dllist.add(dc);*/
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setMethod('GET');
                req.setHeader('content-type','application/x-www-form-urlencoded');
                req.setHeader('Accept', 'application/json'); 
                string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+asstRec.Latitude__c+'%20'+asstRec.Longitude__c+'&sensor=true';
               // system.debug(endpt);    
                req.setEndpoint(endpt);
                HttpResponse res = h.send(req);
                
                // Parsing the given response in order to update streetaddress,city,state and zip code
               // system.debug('response'+res.getBody());
                Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
               // system.debug(results1);
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
                
                
                if(addrvalMap.containskey('formatted_address'))
                    asstRec.Current_Location_Address__c = (string)addrvalMap.get('formatted_address');    
                    
                 //   system.debug('asstRec.Current_Address__c---'+asstRec.Current_Location_Address__c);
                    Map<String,Object> commap = new map<String,Object>();
                    for(object obj : addressdetails)
                    {
                        commap = (Map<String,Object>)obj;
                        if(commap.containskey('types') )
                        {
                            for(object obj1 : (List<Object>) commap.get('types') )
                            {
                             //   system.debug(obj1);
                                if((string)obj1 != 'political')
                                {
                                    types = (string)obj1;     
                                }
                                
                            }    
                        }
                    /*    system.debug('commap----'+commap);
                         system.debug('types----'+types); */
                        if(commap.containskey('short_name'))
                        {
                            if(types == 'route' || types == 'street_number')
                            {
                                
                                    CurrentStreet = (string)commap.get('short_name');    
                               
                            }
                          //   system.debug('asstRec.Current_Street_Address__c---'+CurrentStreet);
                            if(types.contains('administrative_area_level_1'))
                            {
                                currentstate = (string)commap.get('short_name');   
                            }
                          //  system.debug('asstRec.Current_State__c---'+CurrentState);
                            if(types.contains('locality'))
                            {
                                currentcity = (string)commap.get('short_name');   
                            }
                         //   system.debug('asstRec.Current_City__c---'+CurrentCity);
                            if(types == 'postal_code'){
                                currentpostal = (string)commap.get('short_name');   
                            } 
                          //  system.debug('asstRec.Current_Zip_Code__c---'+Currentpostal);
                            
                        }//IF Contains Short Name
                    } //For Address Details
                    
                    //Added to insert in to Google API    
                    if(!String.isBlank(asstRec.Current_Location_Address__c)){
                        Google_API_Data__c api = new Google_API_Data__c();
                        api.Current_Address__c = asstRec.Current_Location_Address__c;
                        api.Current_City__c = currentcity;
                        api.Current_State__c = currentstate;
                        api.Current_Street_Address__c = currentstreet;
                        api.Current_Zip_Code__c = currentpostal;
                        api.Latitude__c = string.valueof(asstRec.Latitude__c);
                        api.Longitude__c = string.valueof(asstRec.Longitude__c);                   
                        insertAPIData.add(api); 
                    }
                     
                    
                }//IF Compare
                asstHisList.add(asstRec);
                
            }//For             
                     
          /* system.debug(limits.getCallouts()+'out of'+ limits.getLimitCallouts());
            system.debug(limits.getQueries()+'out of'+limits.getLimitQueries());
            system.debug(limits.getQueryRows()+'out of'+limits.getLimitQueryRows());  
            system.debug(limits.getCallouts()+'out of'+limits.getLimitCallouts());*/
    
           /* if(label.DebugLogsForAssetHistory == 'true' && dllist.size()>0){
                insert dllist;  
            }  */
            if(asstHisList.size()>0){
                update asstHisList;   
            }
            if(insertAPIData.size() > 0)
                insert insertAPIData;
                
                
        }catch(exception ex){
            failureMsgs.add(ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }//Function
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