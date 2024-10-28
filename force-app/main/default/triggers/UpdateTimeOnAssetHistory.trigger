/**
* @author -- Gokulprasath
* @date -- 02/20/2019

**/
trigger UpdateTimeOnAssetHistory on Asset_History_custom__c (before insert, before update) {
    Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
    if( Redesign.Redesign_Toggle__c!= true){
        if(trigger.isbefore){
            Trigger_Helper.updatestartandaendtime(trigger.new);	    
        }
    }
}