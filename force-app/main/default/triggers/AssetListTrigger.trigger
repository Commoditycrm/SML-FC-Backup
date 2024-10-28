trigger AssetListTrigger on Asset_List__c (after insert) {
    
    for(Asset_List__c obj : Trigger.New){
        if(obj.List_View_Query__c == null){
            AssetListTriggerHelper.getListViewQuery(obj.Id); 
        }
    }
    
}