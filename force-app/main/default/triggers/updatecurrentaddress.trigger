/**
* @author -- Gokulprasath
* @date -- 02/20/2019

**/

trigger updatecurrentaddress on Asset (before update,before insert, after insert, after update) {
    boolean RedesignToggle;
    Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default'); 
    if(Redesign.Redesign_Toggle__c != True){
    if(Utilityclass.canIenter()){ 
        // This will update the address fields based on state of pallet.
        if(trigger.isbefore || (trigger.isafter && trigger.isinsert)){
            Trigger_Helper.updateAddress(trigger.new,trigger.oldmap,trigger.isInsert,trigger.isupdate, trigger.isbefore);
        }
        if(trigger.isbefore || (trigger.isafter && trigger.isinsert)){
            //Trigger_Helper.updateAddressNimbelink(trigger.new,trigger.oldmap,trigger.isInsert, trigger.isupdate, trigger.isbefore);    
        }
        if(trigger.isafter)
        {
            //Trigger_Helper.updateAccfields(trigger.new);
            //  Trigger_Helper.createHistoryrec(trigger.new, trigger.oldmap,trigger.isinsert); //Uncomment on 29-10-2021
            
            if(Utilityclass.canIRun()){
                //Trigger_Helper.createandUpdateInventory();    
            }
            if(Utilityclass.executeInventory()){
                //Trigger_Helper.createandUpdateInventoryNimbelink();    
            }
            if(trigger.isUpdate)
            { 
                if(utilityclass.dwelldays){
                    system.debug('utilityclass dwelldays'+utilityclass.dwelldays);
                    Trigger_Helper.updateddwell(trigger.new,trigger.oldmap);
                }
                Trigger_Helper.updatedwelldays(trigger.new,trigger.oldmap);
                system.debug('Enter Update History-->');
                
                if(Utilityclass.canIRun()){
                    //Comment 08-03-2021 Trigger_Helper.updateAssetHistory(trigger.new);  
                }
                
            }
            
            //Trigger_Helper.trackAllHistory(trigger.new, trigger.oldmap,trigger.isinsert);
        }
        if(trigger.isbefore){
            Trigger_Helper.updateLastconnectedfield(trigger.new);
            Trigger_Helper.updateFacilityLocation(trigger.new,trigger.oldmap,trigger.isInsert,trigger.isupdate); 
            if(trigger.isUpdate){ 
                Trigger_Helper.updateLastKnownLocation(trigger.new,trigger.oldmap); 
                Trigger_Helper.updateEstBatteryPercentage(trigger.new,trigger.oldmap);
              // Trigger_Helper.checkLastConnected(trigger.new,trigger.oldmap,trigger.isInsert,trigger.isupdate);
              
            }         
            
        }
        
    }
    }
}