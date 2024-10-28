/*
    This batch will be used to check whether any known location ACH record created between In Transit Ever ACH record's Start/End time period.
*/

global class ValidateInTransitEverRecord_Batch implements Database.Batchable<sObject>, Database.stateful {
    
    public Map<Id, Asset> invalidAssetMap; 
    public Integer lastModifiedDays;
    public String assetId;
    public Map<Id, Asset_History_custom__c> invalidITEACHMap;
    public String checkACHRecordsAfter;            // Date in string format 'MM/DD/YYYY'
    
    public ValidateInTransitEverRecord_Batch(Integer lastModifiedDays){
        this.lastModifiedDays = lastModifiedDays;
    }
    
    public ValidateInTransitEverRecord_Batch(String assetId){
        this.assetId = assetId;
    }
    
    public ValidateInTransitEverRecord_Batch(String assetId, String checkACHRecordsAfter){
        this.assetId = assetId;
        this.checkACHRecordsAfter = checkACHRecordsAfter;        
    }
    
    public ValidateInTransitEverRecord_Batch(Integer lastModifiedDays, String checkACHRecordsAfter){
        this.lastModifiedDays = lastModifiedDays;
        this.checkACHRecordsAfter = checkACHRecordsAfter;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        invalidAssetMap = new Map<Id, Asset>();
        invalidITEACHMap = new Map<Id, Asset_History_custom__c>();
        
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
        Map<Id, Asset> assetMap = new Map<Id, Asset>(scope);
        Set<Id> assetIds = assetMap.keySet();
        Date achCreatedDate;
        
        String achQuery = 'SELECT Id, Asset__c, Name, Location__c, CreatedDate, Start_Time__c, End_Time__c, Api_Response__c, Latest_API_Response_Child__c FROM Asset_History_custom__c ' +
                           'WHERE Asset__c IN: assetIds and Location__c != null ' ;
                           
        if(String.IsNotBlank(checkACHRecordsAfter)){
            achCreatedDate = Date.parse(checkACHRecordsAfter);
            achQuery += 'AND CreatedDate >=: achCreatedDate';
        }         
                           
        achQuery += ' order by Start_Time__c asc limit 50000';
        
        // Map<AssetId, Map<'inTransitEver'/'knownLocation', List<Asset_History_custom__c>>>
        Map<Id, Map<String, List<Asset_History_custom__c>>> achByAssetIdMap = new Map<Id, Map<String, List<Asset_History_custom__c>>>();
        
        // Fetching all ACH records in order of Start_Time asc
        for(Asset_History_custom__c ach : Database.Query(achQuery)){
            // Map to store the In-TrnasitEver/knownLocation ACH records by asset Id
            Map<String, List<Asset_History_custom__c>> innerMap = achByAssetIdMap.containsKey(ach.Asset__c) ? achByAssetIdMap.get(ach.Asset__c) : new Map<String, List<Asset_History_custom__c>>();
            
            // storing 'In Transit - Ever' ACH record
            if(ach.Location__c == 'In Transit - Ever' || ach.Location__c == 'In Transit-ever'){
                List<Asset_History_custom__c> lst = innerMap.containsKey('inTransitEver') ? innerMap.get('inTransitEver') : new List<Asset_History_custom__c>();
                lst.add(ach);
                innerMap.put('inTransitEver', lst);
            }else if(ach.Location__c != 'In Transit'){ // 'knownLocation' means known location
                List<Asset_History_custom__c> lst = innerMap.containsKey('knownLocation') ? innerMap.get('knownLocation') : new List<Asset_History_custom__c>();
                lst.add(ach);
                innerMap.put('knownLocation', lst);
            }
            
            achByAssetIdMap.put(ach.Asset__c, innerMap);
        }
        
        //system.debug('###---achByAssetIdMap---'+ achByAssetIdMap);
        
        for(Asset ast : scope){ 
            if(achByAssetIdMap.containsKey(ast.Id) && achByAssetIdMap.get(ast.Id).containsKey('inTransitEver') && !achByAssetIdMap.get(ast.Id).get('inTransitEver').isEmpty() 
                                                   && achByAssetIdMap.get(ast.Id).containsKey('knownLocation')    && !achByAssetIdMap.get(ast.Id).get('knownLocation').isEmpty()){
                for(Asset_History_custom__c ach1 : achByAssetIdMap.get(ast.Id).get('inTransitEver')){ // traversing to 'inTransitEver' ACH records
                    DateTime intransitEverSt = ach1.Start_Time__c;    // start time of inTransitEver ach record
                    DateTime intransitEverEt = ach1.End_Time__c;      // end time of inTransitEver ach record
                    
                    system.debug('###---intransitEverSt---'+ intransitEverSt);
                    system.debug('###---intransitEverEt---'+ intransitEverEt);
                    
                    for(Asset_History_custom__c ach2 : achByAssetIdMap.get(ast.Id).get('knownLocation')){ // traversing to 'knownLocation' ACH records
                        DateTime knownLocSt = ach2.Start_Time__c;  // start time of knowlocation ach record
                        DateTime knownLocEt = ach2.End_Time__c;    // end time of knowlocation ach record
                        
                        system.debug('###---ach2---'+ ach2);
                        system.debug('###---knownLocSt---'+ knownLocSt);
                        system.debug('###---knownLocEt---'+ knownLocEt);
                        //(knownLocSt >= intransitEverSt && intransitEverSt <= knownLocEt) || 
                        //(knownLocSt >= intransitEverEt && intransitEverEt <= knownLocEt)  
                        if ((intransitEverSt < knownLocSt && knownLocSt < intransitEverEt) || (intransitEverSt < knownLocEt && knownLocEt < intransitEverEt)){         // checking whether knownLocation record creating in-between the inTransitEver ach record
                            invalidAssetMap.put(ast.Id, ast);
                            invalidITEACHMap.put(ast.Id, ach1);
                            break;
                        }                        
                    }
                    
                    if(invalidAssetMap.containsKey(ast.Id)){break;}
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bC){
        system.debug('###---invalidAssetMap---'+ invalidAssetMap);
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.toAddresses = new String[] {System.Label.Email_Address};    
        msg.setSubject('Invalid In Transit Ever Records ');
            
        if(!invalidAssetMap.isEmpty()){
            string body = 'Total Asset count '+ invalidAssetMap.size();
            for(Asset ast : invalidAssetMap.Values()){
                body+= '\n'+ ast;
                
                if (invalidITEACHMap.containsKey(ast.Id)){
                    body+= '\n\t\t In Transi Ever ACH record -'+ invalidITEACHMap.get(ast.Id);
                }
                body+= '\n\n';
            }
            msg.setPlainTextBody(body);
        }else {
            msg.setPlainTextBody('Invalid In Transit Ever Records ACH records not found.');
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
    }
}