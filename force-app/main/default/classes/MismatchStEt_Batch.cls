public class MismatchStEt_Batch implements Database.Batchable<sobject>,Database.Stateful {
    
    public Map<String, List<String>> achNamesByAsset;
    public String astQuery;
    public String achQueryFilter;
    public Set<String> assetIds = new Set<String>();
    public Integer totalMisMatchCount;
        
    public MismatchStEt_Batch(String achQueryFilter){
        this.achQueryFilter = achQueryFilter;
        this.totalMisMatchCount = 0;
        this.achNamesByAsset = new Map<String, List<String>>();
        
        for(Asset_History_custom__c obj : DataBase.Query(achQueryFilter)){
            assetIds.add(obj.Asset__c);
        }       
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        astQuery = 'Select Id, Name from Asset Where Id IN:assetIds';
        System.debug('Asset Size'+assetIds.size());
        return database.getQueryLocator(astQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){   
        
        String qry = achQueryFilter + ' AND Asset__c IN: assets' + ' ORDER BY start_time__c asc';
        System.debug('qry='+ qry);
        
        
        List<Asset_History_custom__c> achList = DataBase.Query(qry);
         System.debug('list size='+ achList.size());
   
         for(Integer i=1; i<achList.size(); i++){
            if(achList[i-1].End_Time__c != achList[i].Start_Time__c ){
                totalMisMatchCount = totalMisMatchCount + 1;
                
                List<String> temp = achNamesByAsset.containsKey(assets[0].Name) ? achNamesByAsset.get(assets[0].Name) : new List<String>();
                temp.add(achList[i-1].Name);
                temp.add(achList[i].Name);
                achNamesByAsset.put(assets[0].Name, temp);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'commodityccrm@gmail.com' };
        msg.setSubject('ACH MisMatch Start/End Time Reports');
        string body = 'Overall Mismatched : '+totalMisMatchCount + '\n';
        
        for(String astName : achNamesByAsset.keySet()){
            body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ',') + '\n';
        }
        
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
    }
}