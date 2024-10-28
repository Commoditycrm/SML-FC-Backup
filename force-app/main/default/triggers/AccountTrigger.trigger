/**
 * @author 		Amanda Bodnovits, RadialSpark
 * @date 		2/8/18
 * @description Trigger on Account
 */
trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerHandler handler = new AccountTriggerHandler(new TriggerRecordWrapper(
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