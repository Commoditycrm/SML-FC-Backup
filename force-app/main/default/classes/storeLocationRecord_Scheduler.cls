global with sharing class storeLocationRecord_Scheduler implements schedulable
{
    global void execute(SchedulableContext sc) {
        storeLocationRecordProd createAssetHistory=new storeLocationRecordProd();
        database.executeBatch(createAssetHistory,1);
    }
}