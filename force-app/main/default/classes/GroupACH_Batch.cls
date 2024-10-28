public class GroupACH_Batch implements Database.Batchable<sobject>,Database.Stateful {
    
    String astQuery;
    String achQueryFilter;
    Set<String> assetIds = new Set<String>();
    Map<String, Integer> ahcDeletedCountForAsset = new Map<String, Integer>();
    Map<String, Integer> ahcUpdatedCountForAsset = new Map<String, Integer>();
    Map<String, Integer> ahcTotalCountForAsset = new Map<String, Integer>();
    Integer overallTotal,overallUpdated,overallDeleted;
    public GroupACH_Batch(String astQuery, String achQueryFilter){
        this.achQueryFilter = achQueryFilter;
        overallTotal = 0;
        overallUpdated = 0;
        overallDeleted = 0;   
        for(Asset_History_custom__c obj : DataBase.Query(astQuery)){
            assetIds.add(obj.Asset__c);
        }       
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        astQuery = 'Select Id from Asset Where Id IN:assetIds';
        System.debug('Asset Size'+assetIds.size());
        return database.getQueryLocator(astQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){   
        //String achQuery = 'Select Id,Name,Current_Location_Address__c,Device_Id__c,Start_Time__c,End_Time__c,Location__c,Asset__c from Asset_History_custom__c Where Asset__c IN: assets ';
        /*if(String.IsNotBlank(achQueryFilter)){
            achQuery += achQueryFilter;
        }else {
            //achQuery += ' order by Device_Id__c,Start_Time__c desc';
            achQuery += ' order by Start_Time__c desc';
        }*/
        //achQuery = 'Select Id,Name,Current_Location_Address__c,Device_Id__c,Start_Time__c,End_Time__c,Location__c,Asset__c from Asset_History_custom__c Where Asset__c IN: assets AND Start_Time__c > 2023-04-11T00:00:00.000+0000 and Start_Time__c <= 2023-04-15T00:00:00.000+0000 order by Start_Time__c desc';
        List<Asset_History_custom__c> updateACH = new List<Asset_History_custom__c>();
        Map<Id, Asset_History_custom__c> deleteACH = new Map<Id, Asset_History_custom__c>();
        
        List<Asset_History_custom__c> achRecords = DataBase.Query(achQueryFilter);
        system.debug('achRecords.size()--'+achRecords.size());
        for(Integer i=0; i<achRecords.size(); i++){
            overallTotal += 1;
            if(ahcTotalCountForAsset.containsKey(achRecords[i].Device_Id__c)){
                ahcTotalCountForAsset.put(achRecords[i].Device_Id__c,ahcTotalCountForAsset.get(achRecords[i].Device_Id__c)+1); 
            }
            else{
                ahcTotalCountForAsset.put(achRecords[i].Device_Id__c,1); 
            }
            if(!ahcDeletedCountForAsset.containsKey(achRecords[i].Device_Id__c)){
                ahcDeletedCountForAsset.put(achRecords[i].Device_Id__c,0); 
            }
            if(!ahcUpdatedCountForAsset.containsKey(achRecords[i].Device_Id__c)){
                ahcUpdatedCountForAsset.put(achRecords[i].Device_Id__c,0); 
            }
            if(!deleteACH.containsKey(achRecords[i].Id)){
                Boolean flag = false;
                for(Integer j=(i+1); j<achRecords.size(); j++){
                    //String trimmedLocation = achRecords[i].Location__c.trim();
                    if(achRecords[i].Location__c != 'In Transit' && achRecords[i].Location__c == achRecords[j].Location__c.trim()){
                        achRecords[i].Start_Time__c = achRecords[j].Start_Time__c;
                        flag = true;
                        system.debug('achRecords[j].Name--'+achRecords[j].Name);
                        deleteACH.put(achRecords[j].Id, achRecords[j]);
                        ahcDeletedCountForAsset.put(achRecords[j].Device_Id__c,ahcDeletedCountForAsset.get(achRecords[j].Device_Id__c)+1);
                        overallDeleted += 1;
                    }else{
                        break;
                    }
                }            
                if(flag){
                    updateACH.add(achRecords[i]);
                    ahcUpdatedCountForAsset.put(achRecords[i].Device_Id__c,ahcUpdatedCountForAsset.get(achRecords[i].Device_Id__c)+1); 
                    overallUpdated += 1;
                }
            } 
        }
        system.debug('deleteACH.size()--'+deleteACH.size());
        if(!deleteACH.isEmpty()){
            delete deleteACH.values();
        }
        system.debug('updateACH.size()--'+updateACH.size());
        if(!updateACH.isEmpty()){
            update updateACH;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'commodityccrm@gmail.com' };
        //msg.toAddresses = new String[] { 'prashanthrajashaker@gmail.com' };
        msg.setSubject('ACH Grouping Reports');
        string body = 'Details: Overall Tot:'+overallTotal+' upd:'+overallUpdated+' del:'+overallDeleted;
        for(String key: ahcTotalCountForAsset.keySet()){
            body+= ' '+key+'-Tot:'+ ahcTotalCountForAsset.get(key)+' ';
            body+= 'upd:'+ ahcUpdatedCountForAsset.get(key)+' ';
            body+= 'del:'+ ahcDeletedCountForAsset.get(key)+' ';
            system.debug('body--'+body);
        }
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
    }
}