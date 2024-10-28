trigger Nimbelink_AssetHistory on Asset_History_custom__c (after insert) {
    Public boolean RedesignToggle;
    Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
    if(Redesign.Redesign_Toggle__c != true){
        for(Asset_History_custom__c asst : Trigger.new){
            
            if(Trigger.isInsert){
                
                //  if(asst.Is_Nimbelink_AssetHistory__c == true && asst.Current_Location_Address__c != null && asst.Latitude__c != null && asst.Longitude__c != null && asst.Location__c == 'In Transit'){
                // System.debug('Asset History Trigger called');
                
                if(asst.Is_Nimbelink_AssetHistory__c == true && asst.Current_Location_Address__c == null && asst.Latitude__c != null && asst.Longitude__c != null && asst.Location__c == 'In Transit' && asst.Inserted_From__c == null){
                    System.debug('Asset History Trigger Inside if loop');   
                    if(System.isBatch() == false){
                        googleApiCallout.httpreq1(asst.Latitude__c, asst.Longitude__c, asst.id); 
                    }              
                }
            }
        }
    }
}