global with sharing class InventoryBatch_Scheduler implements schedulable {
    
    global void execute(SchedulableContext sc) {
        InventoryBatch ib = new InventoryBatch();
        database.executebatch(ib);
    }
}