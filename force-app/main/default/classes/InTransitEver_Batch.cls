/*
    This batch will be used to check whether In Transit Ever records are created correctly.
*/
global class InTransitEver_Batch implements Database.Batchable<sObject>, Database.stateful {
    
    public static Integer IN_TRANSIT_EVER_INTERVAL = 14;
    public Integer lastModifiedDays;
    public Map<Id, List<String>> missingACHErrorMap; // Map to store asset Id with custom message which includes the start/end time
    public Map<Id, Asset> missingInTransitEverAssets; // Map of asset
    public String assetId;
    
    public InTransitEver_Batch(Integer lastModifiedDays){
        this.lastModifiedDays = lastModifiedDays;
    }
    
    public InTransitEver_Batch(String assetId){
        this.assetId = assetId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        missingInTransitEverAssets = new Map<Id, Asset>();
        missingACHErrorMap = new Map<Id, List<String>>();
        
        lastModifiedDays = lastModifiedDays != null ? lastModifiedDays : 30;
        String query ='SELECT Id, Name FROM Asset ';
        
        if(String.IsNotBlank(assetId)){
            query += 'WHERE Id =: assetId';
        }else {
            query += 'WHERE LastModifiedDate = LAST_N_DAYS:' + lastModifiedDays;
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<asset> scope){            
        String assetId = scope[0].Id;
        String achQuery = 'SELECT Id, Name, Location__c, CreatedDate, Start_Time__c, End_Time__c FROM Asset_History_custom__c ' +
                          'WHERE Asset__c =: assetId and Location__c != null order by Start_Time__c asc limit 50000';
                          
        Integer inTransitEverRecordCount = 0;
        Asset_History_custom__c knowLocationAch = null;
        List<Asset_History_custom__c> inTransitAchRecords = new List<Asset_History_custom__c>();
        
        // For scenario 2,3
        DateTime inTransitEverStartDate = null;
        List<Asset_History_custom__c> achRecords = new List<Asset_History_custom__c>();
        Map<Datetime, Datetime> inTransitEverTimeMap = new Map<Datetime, Datetime>();
        
        List<Asset_History_custom__c> allACHRecords = new List<Asset_History_custom__c>();
        
        for(Asset_History_custom__c ach : Database.Query(achQuery)){
            // For scenario 1 -  to chech whether there are multiple IntransitEver record created between two known location
            if(ach.Location__c != null && ach.Location__c != 'In Transit' && ach.Location__c != 'In Transit - Ever'){
                if(knowLocationAch == null){
                    knowLocationAch = ach;
                }else if(!inTransitAchRecords.isEmpty()){
                    
                    Decimal numberDaysDue = dwellTime(inTransitAchRecords[0].Start_Time__c, inTransitAchRecords[inTransitAchRecords.size()-1].End_Time__c);
                    
                    if(numberDaysDue >= IN_TRANSIT_EVER_INTERVAL && inTransitEverRecordCount != 1){
                        missingInTransitEverAssets.put(assetId, scope[0]);
                        
                        List<String> tempList = missingACHErrorMap.containsKey(assetId) ? missingACHErrorMap.get(assetId) : new List<String>();
                        tempList.add('Strat Time - '+ inTransitAchRecords[0].Start_Time__c.format('MM/dd/yyyy hh:mm:ss a') + ' , End Time - '+ inTransitAchRecords[inTransitAchRecords.size()-1].End_Time__c.format('MM/dd/yyyy hh:mm:ss a'));
                        missingACHErrorMap.put(assetId, tempList);
                        break;
                    }
                }
                knowLocationAch = null;
                inTransitAchRecords = new List<Asset_History_custom__c>(); // remove previously stored In Transit ACH records
                inTransitEverRecordCount = 0;
            }else if(ach.Location__c == 'In Transit'){
                inTransitAchRecords.add(ach);
            }else if(ach.Location__c == 'In Transit - Ever'){
                inTransitEverRecordCount = inTransitEverRecordCount + 1;
            }
            
            // For scenario 2, 3 - to check continues 'In Transit' records
            if(ach.Location__c == 'In Transit'){
                inTransitEverStartDate = inTransitEverStartDate == null ? ach.Start_Time__c : inTransitEverStartDate;
                achRecords.add(ach);                
            }else if(ach.Location__c == 'In Transit - Ever'){
                inTransitEverTimeMap.put(ach.Start_Time__c, ach.End_Time__c);
            }else {
                if(!achRecords.isEmpty()){
                    DateTime inTransitEverEndDate = achRecords[achRecords.size()-1].End_Time__c;
                    Decimal numberDaysDue = dwellTime(inTransitEverStartDate, achRecords[achRecords.size()-1].End_Time__c);                    
                    
                    Boolean isInTransitEverCreated = (inTransitEverTimeMap.containsKey(inTransitEverStartDate) && inTransitEverEndDate >= inTransitEverTimeMap.get(inTransitEverStartDate));
                    if (numberDaysDue >= IN_TRANSIT_EVER_INTERVAL && ach.Location__c != 'In Transit - Ever' && !isInTransitEverCreated){
                        missingInTransitEverAssets.put(assetId, scope[0]);
                        
                        List<String> tempList = missingACHErrorMap.containsKey(assetId) ? missingACHErrorMap.get(assetId) : new List<String>();
                        tempList.add('Strat Time - '+ achRecords[0].Start_Time__c.format('MM/dd/yyyy hh:mm:ss a') + ' , End Time - '+ 
                                      achRecords[achRecords.size()-1].End_Time__c.format('MM/dd/yyyy hh:mm:ss a'));
                        missingACHErrorMap.put(assetId, tempList);
                        break;
                    }
                }
                
                inTransitEverStartDate = null;
                achRecords = new List<Asset_History_custom__c>();
            }
        }
        
        // To check whether all ACH are in 'In Transt' and reach to the time dwell days time limit
        if(allACHRecords.size() > 0 && achRecords.size() > 0 && allACHRecords.size() == achRecords.size()){
            Decimal numberDaysDue = dwellTime(achRecords[0].Start_Time__c, achRecords[achRecords.size()-1].End_Time__c);
            
            if (numberDaysDue >= IN_TRANSIT_EVER_INTERVAL){
                system.debug('===B=');
                missingInTransitEverAssets.put(assetId, new Asset(Id=assetId));
                List<String> tempList = missingACHErrorMap.containsKey(assetId) ? missingACHErrorMap.get(assetId) : new List<String>();
                tempList.add('Strat Time - '+ achRecords[0].Start_Time__c.format('MM/dd/yyyy hh:mm:ss a') + ' , End Time - '+ achRecords[achRecords.size()-1].End_Time__c.format('MM/dd/yyyy hh:mm:ss a'));
                missingACHErrorMap.put(assetId, tempList);
            }
        }
    }
    
    global void finish(Database.BatchableContext bC){
        //system.debug('###---missingInTransitEverAssets---'+ missingInTransitEverAssets);
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.toAddresses = new String[] {System.Label.Email_Address};       
        msg.setSubject('Missing In Transit Ever');
                
        if(!missingInTransitEverAssets.isEmpty()){
            
            string body = 'Total Asset count '+ missingInTransitEverAssets.size();
            
            for(Asset ast : missingInTransitEverAssets.Values()){
                body+= '\n'+ ast;
                
                if (missingACHErrorMap.containsKey(ast.Id)){
                    body+= '\n\t\t Missing In-transit between '+ missingACHErrorMap.get(ast.Id);
                }
                body+= '\n';
            }
            msg.setPlainTextBody(body);
        } else {
            msg.setPlainTextBody('No error found in In Transit Ever ACH records.');
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        
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
}