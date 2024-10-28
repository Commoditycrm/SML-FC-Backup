/**
 * @author Connor Zint
 * @date 12/17/2017
 * @description Trigger on Case
 */
 trigger CaseTrigger on Case (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerHandler handler = new CaseTriggerService(new TriggerRecordWrapper(
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