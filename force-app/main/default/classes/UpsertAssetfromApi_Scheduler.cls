global with sharing class UpsertAssetfromApi_Scheduler implements schedulable {
    
    global void execute(SchedulableContext sc) {
        UpsertAssetfromApi_Batch upsertAsset = new UpsertAssetfromApi_Batch();
        database.executebatch(upsertAsset);
    }
}