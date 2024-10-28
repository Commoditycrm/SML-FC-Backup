public class UpdateStillInLoc_batch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        Integer count = Integer.ValueOf(Label.Still_in_location_count);
        return Database.getQueryLocator([SELECT Id FROM Asset WHERE Still_in_Location_Count__c > :count]);
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<Asset> astList = (List<Asset>)scope;
        List<Id> assetId = new List<Id>();
        for(Asset ast : astList) {
            assetId.add(ast.Id);
        }
        List<Asset_History_custom__c> ahcList = [SELECT Id, asset__c, CreatedDate, Still_in_this_Location__c FROM Asset_History_custom__c WHERE asset__c IN :assetId AND Still_in_this_Location__c = true ORDER BY Asset__c, createddate DESC];
        Map<Id, List<Asset_History_custom__c>> assetMap = new Map<Id, List<Asset_History_custom__c>>();
        for(Asset_History_custom__c ahc : ahcList) {
            List<Asset_History_custom__c> ahcl;
            if(assetMap.containsKey(ahc.asset__c)) {
                ahcl = assetMap.get(ahc.asset__c);
            }
            else
                ahcl = new List<Asset_History_custom__c>();
            ahcl.add(ahc);                
            assetMap.put(ahc.asset__c,ahcl);
        }
        List<Asset_History_custom__c> asll = new List<Asset_History_custom__c>();
        for(Id asset : assetMap.keySet()) {
            List<Asset_History_custom__c> ahcl = assetMap.get(asset);
            asll.add(ahcl.get(0));
            for(integer i=1;i< ahcl.size();i++) {
                ahcl.get(i).Still_in_this_Location__c = false;
                asll.add(ahcl.get(i));
            }
        }
        update asll;
    }

    public void finish(Database.BatchableContext context) {
        // Add any post-processing logic here
    }
}