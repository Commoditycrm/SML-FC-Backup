public class updateStillInLoc {
    public void getHistoryRecords() {
        Integer count;
       	count = Integer.ValueOf(Label.Still_in_location_count);
        List<asset> astList = [select id from asset where Still_in_Location_Count__c > :count];
        system.debug('All asset List'+astList);
							//id in ('02iEk0000000TA5IAM','02iEk0000000TBhIAM','02iEk0000000X0nIAE')];
        List<Id> assetId = new List<Id>();
        for(Asset ast : astList) {
            assetId.add(ast.Id);
        }
        List<Asset_History_custom__c> ahcList = [select Id, asset__c, CreatedDate, Still_in_this_Location__c from Asset_History_custom__c where asset__c in: assetId and Still_in_this_Location__c = true order by Asset__c, createddate desc];
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
}