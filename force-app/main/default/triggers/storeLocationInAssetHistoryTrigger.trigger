trigger storeLocationInAssetHistoryTrigger on Asset_History_custom__c (before insert) {
    boolean RedesignToggle;
    Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
    RedesignToggle = Redesign.Redesign_Toggle__c;
    
    
    if(RedesignToggle != True){
        storeLocationInAssetHistory.updateAddress(trigger.new);
    }
}