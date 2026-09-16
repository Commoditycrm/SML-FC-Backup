public class ProdToUATNimblelinkBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public String objectType;
    public String token;
    public Datetime maxProcessedDate;

    public ProdToUATNimblelinkBatch(String objectType) {
        this.objectType = objectType;
    }

    
        public Database.QueryLocator start(Database.BatchableContext bc) {
    
        
        Nimbelink_Sync_Prod_Full_Copy__c sync = 
            Nimbelink_Sync_Prod_Full_Copy__c.getOrgDefaults();
    
        Datetime lastSyncTime;
    
        if(objectType == 'API') {
            lastSyncTime = sync.Last_Timestamp__c;
        } else {
            lastSyncTime = sync.Last_Timestamp_Google_API__c;
        }
    
       
        if(objectType == 'API') {
            return Database.getQueryLocator([
                SELECT Name, CreatedDate, Incoming_Messsage__c, ResEnteringDttime__c,
                       ResEnteringTime__c, Is_Nimbelink_Asset__c, data__c, base__c,
                       Device_Id__c, device_status__c, Accel__c, info__c, events__c,
                       Loc__c, Temp__c, Status__c, asset__c, Api_Callouts__c
                FROM Api_Response__c
                WHERE CreatedDate > :lastSyncTime
                AND Api_Callouts__c = 'Nimbelink'
                ORDER BY CreatedDate ASC
            ]);
        } else {
            return Database.getQueryLocator([
                SELECT Id, CreatedDate, Current_City__c, Current_State__c,
                       Current_Address__c, Current_Street_Address__c,
                       Current_Zip_Code__c, Current_Country__c,
                       Latitude__c, Longitude__c, Business_Name__c,
                       Business_Place_Id__c
                FROM Google_API_Data__c
                WHERE CreatedDate > :lastSyncTime
                ORDER BY CreatedDate ASC
            ]);
        }
    }

    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        
            
            if(token == null){
                token = ProdToUATNimblelink.basicAuthCallout();
            }

            String response;

            if(objectType == 'API') {
                List<Api_Response__c> records = (List<Api_Response__c>) scope;
                response = ProdToUATNimblelink.httpApiCallout(token, JSON.serialize(records));
            } else {
                List<Google_API_Data__c> records = (List<Google_API_Data__c>) scope;
                response = ProdToUATNimblelink.httpGoogleCallout(token, JSON.serialize(records));
            }

           
            if(response != 'SUCCESS'){
                return;
            }

            
            for(SObject s : scope){
                Datetime created = (Datetime)s.get('CreatedDate');
                if(maxProcessedDate == null || created > maxProcessedDate){
                    maxProcessedDate = created;
                }
            }

        } 
    

    
    public void finish(Database.BatchableContext bc) {

        if(maxProcessedDate == null) return;

        Nimbelink_Sync_Prod_Full_Copy__c sync = 
            Nimbelink_Sync_Prod_Full_Copy__c.getOrgDefaults();

        if(objectType == 'API') {
            sync.Last_Timestamp__c = maxProcessedDate;
        } else {
            sync.Last_Timestamp_Google_API__c = maxProcessedDate;
        }

        update sync;
    }

}