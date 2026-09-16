public class MismatchStEt_Batch implements Database.Batchable<sobject>,Database.Stateful, Schedulable {
    
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
    
     public MismatchStEt_Batch(/*String achQueryFilter, Boolean isAsset*/){
        /*this.achQueryFilter = achQueryFilter;
        this.totalMisMatchCount = 0;
        this.achNamesByAsset = new Map<String, List<String>>();*/      
    }
    
     public MismatchStEt_Batch(String achQueryFilter, String astQuery){
        this.achQueryFilter = achQueryFilter;
         this.astQuery = astQuery;
        this.totalMisMatchCount = 0;
        this.achNamesByAsset = new Map<String, List<String>>();      
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(astQuery == null)
            astQuery = 'Select Id, Name from Asset Where Id IN:assetIds';
        return database.getQueryLocator(astQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){   
        
        String qry = achQueryFilter + ' AND Asset__c IN: assets' + ' ORDER BY start_time__c desc Limit 50000';
        System.debug('qry='+ qry);
        
        
        List<Asset_History_custom__c> achList = DataBase.Query(qry);
         System.debug('list size='+ achList.size());
   
         for(Integer i=1; i<achList.size(); i++){
            if(achList[i-1].Start_Time__c != achList[i].End_Time__c ){
                totalMisMatchCount = totalMisMatchCount + 1;
                
                List<String> temp = achNamesByAsset.containsKey(assets[0].Name) ? achNamesByAsset.get(assets[0].Name) : new List<String>();
                temp.add(achList[i-1].Name);
                temp.add(achList[i].Name);
                achNamesByAsset.put(assets[0].Name, temp);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        if(totalMisMatchCount == 0){
            system.debug('No Mismatches found');
            return;
        }
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { System.label.Email_Address, 'Kacey@SmartLogisticsInc.com' };
        msg.setSubject('ACH MisMatch Start/End Time Reports');
        string body = 'Overall Mismatched : '+totalMisMatchCount + '\n';
        
        for(String astName : achNamesByAsset.keySet()){
            body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ',') + '\n';
        }
        
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
    }

     public void execute(SchedulableContext sc){

        String ahcQueryFilter =
            'SELECT Asset__c, End_Time__c, Start_Time__c, Name, Id ' +
            'FROM Asset_History_custom__c ' +
            'WHERE RecordType.DeveloperName = \'location\' AND CreatedDate = YESTERDAY ' +
            'AND Location__c != \'In Transit - Ever\'';

        String assetQuery =
            'SELECT Id, Name ' +
            'FROM Asset ' +
            'WHERE Account.Account_ID__c IN (\'A-000666\', \'A-000088\', \'A-007716\', \'A-007726\')';

        Database.executeBatch(
            new MismatchStEt_Batch(
                ahcQueryFilter,
                assetQuery
            ),
            1
        );
    }
}