@istest
public class AssetListTriggerHelper_Test {
    public TestMethod static void AssetListview(){
    
        Asset_List__c record = new Asset_List__c();
        record.List_view_Name__c='All Assets';
        insert record;
        
        test.startTest();
            AssetListTriggerHelper.getListViewQuery(record.Id);
        test.stopTest();        
        
        List<Asset_List__c> assetlist = [select Id,List_view_Name__c,List_View_Query__c,List_View_Developer_Name__c from Asset_List__c Where Id =: record.Id AND List_View_Developer_Name__c != null];
        system.assertEquals(1, assetlist.size()); 
    }
    
}