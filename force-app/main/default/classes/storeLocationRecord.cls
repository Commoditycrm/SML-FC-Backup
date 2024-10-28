global with sharing class storeLocationRecord implements Database.Batchable<sObject> 
{
    Exception[] errors = new Exception[0];
    public List<Id> assetIDs = new List<Id>();
    public String batchName;
    
    public DateTime batchStartTime;
    public Integer totalRecords;
    public Integer totalFailureRecords;
    public List<String> failureMsgs;
    
    public storeLocationRecord(List<Id> assetIDs,String batchName){
        this.assetIDs = assetIDs;
        this.batchName = batchName;
        
        this.batchStartTime = system.Now();
        this.totalRecords = this.totalFailureRecords = 0;
        this.failureMsgs = new List<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> reasons = new Set<String>();
        reasons.add('Out of Order TS');
        reasons.add('Unable To Lock Row');
        
        string query='SELECT Id,rsri__c,rsrp__c,rsrq__c,voltage__c, Api_Response__c ,Accuracy__c,cellular_signal__c,src__c,Latitude__c,'+
            'Altitude__c,Location__c,Account_Name__c,Longitude__c,Reason__c,Location_Captured_Time__c,Asset__c,Processed__c '+ 
            'FROM Location_Record_Ignored__c where Reason__c IN: reasons AND Processed__c=false';
        //'FROM Location_Record_Ignored__c where Asset__c = \'02iEk0000002sVlIAI\' AND Reason__c IN: reasons ';
        
        query+=' AND Asset__c=:assetIDs';  
        
        query+=' order by Location_Captured_Time__c asc';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Location_Record_Ignored__c> getlocationRecords){
        totalRecords += getlocationRecords.size();
        Map<string,string> locIdByName = new Map<string,string>();
        Boolean isGroupByTopAch = false;
        try{
            utilityclass.dwelldays=false;
            string currentLocName;
            string unabletolockrow=' ';
            Map<Id, Asset> updateassetMap = new Map<Id, Asset>();
            
            //  system.debug('execute'+getlocationRecords);       
            map<id,datetime> locmap=new map<id,datetime>();
            map<id,list<datetime>> locmap22=new map<id,list<datetime>>();        
            map<id,Location_Record_Ignored__c> locmap2=new map<id,Location_Record_Ignored__c>();
            list<Location_Record_Ignored__c> loclist=new list<Location_Record_Ignored__c>();
            
            map<id,list<Asset_History_custom__c>> ahhisMap=new map<id,list<Asset_History_custom__c>>();
            list<Asset_History_custom__c> upsertAhHisList=new list<Asset_History_custom__c>();
            //  system.debug('###--getlocationRecords--'+ getlocationRecords);
            
            for(Location_Record_Ignored__c Lr:getlocationRecords){
                locmap.put(lr.Asset__c,lr.Location_Captured_Time__c);
                locmap2.put(lr.Asset__c,lr);
                unabletolockrow = Lr.Reason__c;
            }
            list <Id> astid = new list <Id>();
            if(unabletolockrow != 'Unable To Lock Row'){
                
                for(Asset ast:[SELECT Id,name,AccountId,Temporary_Latitude__c,Last_Known_Location__c,Temporary_Longitude__c,Current_Location_Address__c,estBattPct__c,Accuracy_meters__c,createddate,Power_Reset_Time__c,Power_Reset_Occurred__c,Battery_Replaced_Date__c,(SELECT Id,Message_Type__c,Accuracy_meters__c,Still_in_this_Location__c,Est_Remaining_Battery__c,Start_Time__c,Account_ID__c,Current_Location_Address__c,End_Time__c,Latitude__c,Altitude__c,Longitude__c,Asset__c,Location__c,Last_Known_Location__c,rsrp__c,Battery_Voltage__c,rsrq__c,rssi__c,cellular_signal__c FROM Asset_Dwell_Time__r where Asset__c IN:locmap.keySet() and Start_Time__c <:locmap.values() and End_Time__c >:locmap.values()) FROM Asset where id IN: locmap.keySet()]) {
                    List<Related_Customer__c> relatedCustomerList = [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: ast.AccountId];
                    Set<Id> accIds = new Set<Id>();
                    if (ast.AccountId!= null) accIds.add(ast.AccountId);
                    for(Related_Customer__c rc : relatedCustomerList) {
                        accIds.add(rc.Source_Account__c);
                        accIds.add(rc.Related_To__c);
                    }
                    List<account> accList = [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accIds];
                    List<Nested_Geofence__mdt> geoFenceList = [select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accIds];
                    
                    Map<string,string> locNew = Utilityclass.currentLocDetail(accids,locmap2.get(ast.id).Latitude__c,locmap2.get(ast.id).Longitude__c, accList, geoFenceList);
                    string lat = string.valueof(locmap2.get(ast.id).Latitude__c).left(7);
                    string lng = string.valueof(locmap2.get(ast.id).Longitude__c).left(7);
                    
                    string intransitAddress;
                    for (google_api_data__c lri : [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,
                                                   Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                   where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lng+'%' ])
                    {
                        if (lri.id != null) intransitAddress = lri.current_address__c;
                    }
                    for(Asset_History_custom__c ahHisList:ast.Asset_Dwell_Time__r) {
                        String lriadd = '';
                        if(ahHisList.Location__c!='In Transit' && locNew.containsKey('locName')){
                            currentLocName = locNew.get('locName');
                        } else if(ahHisList.Location__c == 'In Transit') { 
                            lriadd = intransitAddress;
                        }
                        
                        if(ahHisList.location__c != currentLocName && ahHisList.Latitude__c!=null && ahHisList.Longitude__c!=null && lriadd != ahHisList.Current_Location_Address__c  && ahHisList.Start_Time__c < locmap.get(ast.Id) && ahHisList.End_Time__c > locmap.get(ast.Id) ) {
                            Boolean isStillInLocation = false;
                            
                            Asset_History_custom__c ahhisnew=new Asset_History_custom__c();
                            ahhisnew.Api_Response__c = locmap2.get(ast.Id).Api_Response__c;
                            if(ahHisList.Still_in_this_Location__c){
                                //    ahHisList.Still_in_this_Location__c=false;
                                //    ahhisnew.Still_in_this_Location__c=true;
                                isStillInLocation = true;
                            }
                            if(locmap2.get(ast.Id).rsrp__c!=null){
                                ahhisnew.rsrp__c = locmap2.get(ast.Id).rsrp__c;
                                
                            }else{
                                ahhisnew.rsrp__c = ahHisList.rsrp__c;
                            }
                            if(locmap2.get(ast.Id).rsrq__c!=null){
                                ahhisnew.rsrq__c = locmap2.get(ast.Id).rsrq__c;
                            }else{
                                ahhisnew.rsrq__c = ahHisList.rsrq__c;
                            }
                            if(locmap2.get(ast.Id).rsri__c!=null){
                                ahhisnew.rssi__c = locmap2.get(ast.Id).rsri__c;
                                
                            }else{
                                ahhisnew.rssi__c = ahHisList.rssi__c;
                            }
                            if(locmap2.get(ast.Id).voltage__c!=null){
                                ahhisnew.Battery_Voltage__c = locmap2.get(ast.Id).voltage__c;
                                
                            }else{
                                ahhisnew.Battery_Voltage__c = ahHisList.Battery_Voltage__c;
                            }//voltage__c
                            if(locmap2.get(ast.Id).cellular_signal__c!=null){
                                ahhisnew.Cellular_Signal__c = locmap2.get(ast.Id).cellular_signal__c;
                                
                            }else{
                                ahhisnew.Cellular_Signal__c = ahHisList.Cellular_Signal__c;
                            }
                            if(locmap2.get(ast.Id).Accuracy__c!=null){
                                ahhisnew.Accuracy_meters__c = locmap2.get(ast.Id).Accuracy__c;
                                
                            }else{
                                ahhisnew.Accuracy_meters__c = ahHisList.Accuracy_meters__c;
                            }
                            if(locmap2.get(ast.Id).Altitude__c!=null){
                                ahhisnew.Altitude__c = locmap2.get(ast.Id).Altitude__c;
                                
                            }else{
                                ahhisnew.Altitude__c = ahHisList.Altitude__c;
                            }
                            if(locmap2.get(ast.Id).src__c!=null){
                                ahhisnew.Message_Type__c = locmap2.get(ast.Id).src__c;
                                
                            }else{
                                ahhisnew.Message_Type__c = ahHisList.Message_Type__c;
                            }
                            if(ahHisList.Location__c=='In Transit'){
                                ahhisnew.Last_Known_Location__c=ahHisList.Last_Known_Location__c;
                            }
                            else if(ahHisList.Location__c != 'In Transit'){
                                ahhisnew.Last_Known_Location__c = ahHisList.Location__c;
                            }
                            
                            if(ast.Power_Reset_Occurred__c == false){
                                ahhisnew.Est_Remaining_Battery__c = ast.estBattPct__c;
                                
                            }
                            else if(ast.Power_Reset_Occurred__c == True && ast.Battery_Replaced_Date__c == null){
                                ahhisnew.Est_Remaining_Battery__c = 100 - ((date.newinstance(ast.CreatedDate.year(), ast.CreatedDate.month(), ast.CreatedDate.day()).daysBetween(System.today()))* 0.054795); 
                                
                            }
                            else if(ast.Power_Reset_Occurred__c == True && ast.Power_Reset_Time__c != null  && ast.Battery_Replaced_Date__c != null && ast.Battery_Replaced_Date__c <  date.newinstance(ast.Power_Reset_Time__c.year(), ast.Power_Reset_Time__c.month(), ast.Power_Reset_Time__c.day())){
                                ahhisnew.Est_Remaining_Battery__c = (100 - ((ast.Battery_Replaced_Date__c.daysBetween(System.today())) * 0.054795));
                            }
                            else{
                                ahhisnew.Est_Remaining_Battery__c = ast.estBattPct__c;
                            }
                            
                            ahhisnew.Start_Time__c=locmap.get(ast.Id);
                            ahhisnew.End_Time__c=ahHisList.End_Time__c;
                            ahhisnew.Asset__c=ahHisList.Asset__c;
                            ahhisnew.Latitude__c=locmap2.get(ast.Id).Latitude__c;
                            ahhisnew.Longitude__c=locmap2.get(ast.Id).Longitude__c;
                            ahhisnew.Inserted_From__c = 'Location Record';
                            ahhisnew.Location_Record_Ignored__c = locmap2.get(ast.Id).Id;
                            ahhisnew.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Location').getRecordTypeId();                       
                            upsertAhHisList.add(ahhisnew);
                            
                            Map<string,string> locNew2 = Utilityclass.currentLocDetail(accids,ahhisnew.Latitude__c, ahhisnew.Longitude__c, accList, geoFenceList);
                            
                            // system.debug('###--locNew2--'+ locNew2);//location of lri (null if in transit)
                            //Scenario 1/2
                            if(isStillInLocation){
                                ahHisList.Still_in_this_Location__c=false;
                                ahhisnew.Still_in_this_Location__c=false;
                                
                                Asset_History_custom__c ahhisnew2 = ahhisnew.clone(false, true);
                                ahhisnew2.Start_Time__c = ahHisList.End_Time__c;
                                ahhisnew2.End_Time__c = ahHisList.End_Time__c;
                                ahhisnew2.Still_in_this_Location__c = true;
                                ahhisnew2.Location__c = ahHisList.Location__c;
                                ahhisnew2.Current_Location_Address__c = ast.Current_Location_Address__c;
                                ahhisnew2.Latitude__c = ast.Temporary_Latitude__c;
                                ahhisnew2.Longitude__c = ast.Temporary_Longitude__c;
                                ahhisnew2.Inserted_From__c=' ';
                                ahhisnew2.Updated_From__c = 'Location Record';
                                
                                
                                
                                if (locNew2.containsKey('locName') && locNew2.get('locName') != null){
                                    ahhisnew2.Last_Known_Location__c = locNew2.get('locName');
                                    ast.Last_Known_Location__c = locNew2.get('locId');
                                    updateassetMap.put(ast.Id, ast);
                                } 
                                else 
                                {
                                    //Map<string,string> locNew1 = Utilityclass.currentLocDetail(ast.AccountId, ahHislist.Latitude__c, ahHislist.Longitude__c);
                                    Map<string,string> locNew1 = Utilityclass.currentLocDetail(accids,ahHislist.Latitude__c, ahHislist.Longitude__c, accList, geoFenceList);
                                    if (locNew1.containsKey('locName') && locNew1.get('locName') != null)
                                    {
                                        ahhisnew2.Last_Known_Location__c = locNew1.get('locName');
                                        ast.Last_Known_Location__c = locNew1.get('locId');
                                        updateassetMap.put(ast.Id, ast);
                                    }
                                }
                                upsertAhHisList.add(ahhisnew2);
                                
                            }
                            
                            
                            
                            ahHisList.End_Time__c=locmap.get(ast.Id);
                            ahHisList.Updated_From__c='Location Record';
                            upsertAhHisList.add(ahHisList);
                            astid.add(ast.id);
                        }
                        
                        
                    }
                }
                
                // system.debug('###--upsertAhHisList--'+ upsertAhHisList);   
                // system.debug('###--upsertAhHisList--'+upsertAhHisList);
                if (upsertAhHisList.size() > 0)
                    upsert upsertAhHisList;
                
                string state = 'in transit'; 
                list<Asset_History_custom__c> achList = [select Asset__c,Asset__r.AccountId,Asset__r.Device_Id__c,Start_Time__c,LastModifiedDate,End_Time__c,Location__c,Latitude__c,Longitude__c, 
                                                         Last_Connected_Time__c,Current_Location_Address__c from Asset_History_custom__c where Id IN: upsertAhHisList AND Latitude__c != null and  
                                                         Longitude__c != null and location__c =:state and Current_Location_Address__c =null order by createdDate];
                updateCurrentLocationAddress.updateACHAddress(achList);
                
                
                
                if (astid.size()>0) {checkForDwelDays(astid);}
                
                //  system.debug('===updateassetMap==='+ updateassetMap);
                if (updateassetMap.size()  > 0){
                    update updateassetMap.Values();
                }
                
                
                //  system.debug('upsertlisr'+upsertAhHisList);
                for(Location_Record_Ignored__c Lr2:locmap2.values()){
                    lr2.Processed__c=true;
                    loclist.add(lr2);
                }
                //  system.debug('locmap'+locmap);
                if (loclist.size()  > 0){
                    update loclist;
                }
            }
            
            
            
        } catch(Exception exp) {
            system.debug('###--Exception --'+ exp.getMessage());
            system.debug('###--getStackTraceString--'+ exp.getStackTraceString());
            system.debug('###--getLineNumber--'+ exp.getLineNumber());
            
            failureMsgs.add(exp.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    // checking dwell days scenario
    public static void checkForDwelDays(List<Id> assetIDs){
        // for updating the Consider_for_Dwell__c = false, if new ACH are created for a location
        DateTime maxStartTime = null;
        String astId = null;
        list<Asset_History_custom__c> updateDwellDays = new list<Asset_History_custom__c>();
        for (id assetid :assetIDs) 
        {
            for (Asset_History_custom__c obj :[Select Id, Asset__c,start_time__c,location__c from Asset_History_custom__c 
                                               where Asset__c=:assetid and location__c !='In Transit'and recordtype.name='Location' order by start_time__c desc Limit 1]){
                                                   if (obj.Id != null){
                                                       astId = obj.Asset__c;
                                                       maxStartTime = obj.start_time__c;
                                                   }
                                               }//getting recent known location record if any
            
            if(astId != null && maxStartTime != null ){
                
                for(Asset_History_custom__c obj2 : [Select Id, Consider_for_Dwell__c, start_time__c from Asset_History_custom__c 
                                                    where Asset__c =: astId AND Consider_for_Dwell__c = true  
                                                    AND  Start_Time__c <=: maxStartTime]){
                                                        obj2.Consider_for_Dwell__c = false;
                                                        updateDwellDays.add(obj2);
                                                    }
            }
        } 
        if(!updateDwellDays.isEmpty()) {
            update updateDwellDays;
        }
    } // END
    
    global void finish(Database.BatchableContext bc)
    {
        if(!errors.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
        updateBatchNameOnAccount(this.batchName);
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = this.batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
        batchLog.Status__c = 'Completed';
        batchLog.Total_no_of_records_processed__c = totalRecords;
        insert batchLog;
        
        if(Label.Execute_Nimblink_Batch_Process == 'YES'){
            Integer mins = 10;
            if(Label.Nimblink_Batch_Interval != null){
                mins = Integer.ValueOf(Label.Nimblink_Batch_Interval);
            }
            Datetime sysTime = System.now().addMinutes(mins);         
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            if(!Test.isRunningTest()){
                System.schedule('Nimbelink '+this.batchName+' '+ System.now().getTime(), cronExpression, new NimbeLink_CTRL_Batch(this.batchName));
            }
        }
    }
    public static void updateBatchNameOnAccount(String batchName) {
        List<Account> accountsToUpdate = [SELECT Id, Name, Batch_Name__c, Batch_Name_to_Update__c FROM Account WHERE Batch_Name__c = :batchName AND Batch_Name_Mismatch__c  = true];
        List<Asset> AssetstoUpdate = [SELECT Id, Name, Batch_Name__c,Account_to_Update__c,AccountId  FROM Asset WHERE Batch_Name__c = :batchName AND Account_to_Update__c != null];
        for (Account acc : accountsToUpdate) {
            acc.Batch_Name__c = acc.Batch_Name_to_Update__c;
            acc.Batch_Name_to_Update__c = null;
        }
        Update accountstoUpdate;
        for (Asset asset : AssetstoUpdate) {
            asset.AccountId = asset.Account_to_Update__c;
            asset.Account_to_Update__c = null;
        }
        Update AssetstoUpdate;
    }
    
    
}