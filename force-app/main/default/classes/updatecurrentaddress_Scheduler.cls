global with sharing class updatecurrentaddress_Scheduler implements schedulable {
    
    global void execute(SchedulableContext sc) {
        updatecurrentaddress_Batch updateAsset = new updatecurrentaddress_Batch();
        database.executebatch(updateAsset,1);
    }
}