/**
 * @author Amanda Bodnovits
 * @date 02/03/18
 * @description Trigger on Asset
 */
trigger AssetTrigger on Asset (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
                TriggerHandler handler = new AssetTriggerHandler(new TriggerRecordWrapper(
                    Trigger.new,
                    Trigger.old,
                    Trigger.newMap,
                    Trigger.oldMap
                ));
                TriggerDispatcher dispatcher = new TriggerDispatcher(
                    Trigger.isBefore,
                    Trigger.isAfter,
                    Trigger.isExecuting,
                    Trigger.isInsert,
                    Trigger.isUpdate,
                    Trigger.isDelete,
                    Trigger.isUndelete,
                    Trigger.size,
                    handler
                );
                dispatcher.dispatch();
            
    }
    if(Trigger.isInsert && Trigger.isAfter) {
        RedesignNL_AssetTriggerHandler.createAssetConfiguationRecord(Trigger.New);
    }
}