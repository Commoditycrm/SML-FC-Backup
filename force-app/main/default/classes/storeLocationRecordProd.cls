global with sharing class storeLocationRecordProd implements Database.Batchable<sObject> , Database.Stateful
{
    Exception[] errors = new Exception[0];
    
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords;
    public Integer totalFailureRecords;
    public List<String> failureMsgs;
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        
        this.batchName = 'storeLocationRecordProd';
        this.batchStartTime = system.Now();
        this.totalRecords = this.totalFailureRecords = 0;
        this.failureMsgs = new List<String>();
        
        string reason='Out of Order TS';
        Integer num=Integer.valueof(system.label.limits);
        string query='SELECT Id,rsri__c,rsrp__c,rsrq__c,voltage__c, Api_Response__c ,Accuracy__c,cellular_signal__c,src__c,Latitude__c,Altitude__c,Location__c,Account_Name__c,Longitude__c,Reason__c,Location_Captured_Time__c,Asset__c,Processed__c FROM Location_Record_Ignored__c where Reason__c=\'' + String.escapeSingleQuotes(reason)+'\'and Processed__c=false order by Location_Captured_Time__c asc ';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Location_Record_Ignored__c> getlocationRecords)
    {
        utilityclass.dwelldays=false;
        string currentLocName;
        
        totalRecords += getlocationRecords.size();
        system.debug('utilityglass dwelldays'+ utilityclass.dwelldays);
        try{
            system.debug('execute'+getlocationRecords);       
            map<id,datetime> locmap=new map<id,datetime>();
            map<id,list<datetime>> locmap22=new map<id,list<datetime>>();
            
            map<id,Location_Record_Ignored__c> locmap2=new map<id,Location_Record_Ignored__c>();
            list<Location_Record_Ignored__c> loclist=new list<Location_Record_Ignored__c>();
            
            map<id,list<Asset_History_custom__c>> ahhisMap=new map<id,list<Asset_History_custom__c>>();
            list<Asset_History_custom__c> upsertAhHisList=new list<Asset_History_custom__c>();
            for(Location_Record_Ignored__c Lr:getlocationRecords){
                locmap.put(lr.Asset__c,lr.Location_Captured_Time__c);
                locmap2.put(lr.Asset__c,lr);
                system.debug('newvalue'+locmap2);
            }
            system.debug('locmap '+locmap);
            for(Asset ast:[SELECT Id,name,AccountId,Current_Location_Address__c,estBattPct__c,Accuracy_meters__c,createddate,Power_Reset_Time__c,Power_Reset_Occurred__c,Battery_Replaced_Date__c,(SELECT Id,Message_Type__c,Accuracy_meters__c,Still_in_this_Location__c,Est_Remaining_Battery__c,Start_Time__c,Account_ID__c,Current_Location_Address__c,End_Time__c,Latitude__c,Altitude__c,Longitude__c,Asset__c,Location__c,Last_Known_Location__c,rsrp__c,Battery_Voltage__c,rsrq__c,rssi__c,cellular_signal__c FROM Asset_Dwell_Time__r where Asset__c IN:locmap.keySet() and Start_Time__c <:locmap.values() and End_Time__c >:locmap.values()) FROM Asset where id IN: locmap.keySet()]){
                for(Asset_History_custom__c ahHisList:ast.Asset_Dwell_Time__r){
                    system.debug('entering method');
                    if(ahHisList.Location__c!='In Transit'){
                        currentLocName = Utilityclass.currentLocName(ast.AccountId,locmap2.get(ast.id).Latitude__c,locmap2.get(ast.id).Longitude__c);
                        
                    }
                    
                    if(ahHisList.location__c != currentLocName && ahHisList.Latitude__c!=null && ahHisList.Latitude__c!=locmap2.get(ast.id).Latitude__c && ahHisList.Longitude__c!=locmap2.get(ast.id).Longitude__c && ahHisList.Longitude__c!=null  && ahHisList.Start_Time__c < locmap.get(ast.Id) && ahHisList.End_Time__c > locmap.get(ast.Id) ) {
                        system.debug('entering2');
                        Asset_History_custom__c ahhisnew=new Asset_History_custom__c();
                        ahhisnew.Api_Response__c = locmap2.get(ast.Id).Api_Response__c;
                        if(ahHisList.Still_in_this_Location__c){
                            ahHisList.Still_in_this_Location__c=false;
                            ahhisnew.Still_in_this_Location__c=true;
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
                            system.debug('entering5');
                            
                            ahhisnew.Last_Known_Location__c=ahHisList.Last_Known_Location__c;
                            system.debug('last known loc1');
                        }
                        else if(ahHisList.Location__c!='In Transit'){
                            ahhisnew.Last_Known_Location__c=ahHisList.Location__c;
                            system.debug('last known loc2');
                            
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
                        
                        system.debug('entering 6');
                        ahhisnew.Start_Time__c=locmap.get(ast.Id);
                        ahhisnew.End_Time__c=ahHisList.End_Time__c;
                        ahhisnew.Asset__c=ahHisList.Asset__c;
                        ahhisnew.Latitude__c=locmap2.get(ast.Id).Latitude__c;
                        ahhisnew.Longitude__c=locmap2.get(ast.Id).Longitude__c;
                        ahhisnew.Inserted_From__c='Location Record';
                        ahhisnew.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Location').getRecordTypeId();                       
                        upsertAhHisList.add(ahhisnew);
                        system.debug('upsert+ '+upsertAhHisList);                
                        
                        
                        ahHisList.End_Time__c=locmap.get(ast.Id);
                        ahHisList.Updated_From__c='Location Record';
                        upsertAhHisList.add(ahHisList);
                        
                    }
                }
            }
            
            if (upsertAhHisList.size()  > 0)
            {
                upsert upsertAhHisList;
            }
            
            system.debug('upsertlisr'+upsertAhHisList);
            for(Location_Record_Ignored__c Lr2:locmap2.values()){
                lr2.Processed__c=true;
                loclist.add(lr2);
            }
            system.debug('locmap'+locmap);
            if (loclist.size()  > 0){
                
                update loclist;
                
            } 
        }
        catch(exception ex){
            errors.add(ex);
            failureMsgs.add(ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        if(!errors.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }  
        
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