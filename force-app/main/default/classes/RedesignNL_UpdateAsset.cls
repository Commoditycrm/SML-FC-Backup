global class RedesignNL_UpdateAsset implements Database.Batchable<sObject> {
    public List<String> AssetID;
    
    global RedesignNL_UpdateAsset(List<string> AssetID) {
        this.AssetID = AssetID;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,Name,Power_Reset_Time__c from Asset WHERE Name in: AssetID]);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        
        List<Asset_History_Custom__c> ahcList = [Select Id,Asset__c,Asset__r.Power_Reset_Time__c,Power_Reset_Time__c from Asset_History_Custom__c where Asset__c in:scope AND Power_Reset_Time__c != null];
        for(Asset_History_Custom__c ahc : ahcList){
            if(ahc.Power_Reset_Time__c != ahc.Asset__r.Power_Reset_Time__c){
                ahc.Power_Reset_Time__c = ahc.Asset__r.Power_Reset_Time__c;
                ahc.Power_Reset_Occurred__c = True;
            }
        }
        update ahcList;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}