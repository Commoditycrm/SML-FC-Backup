/*
 * @author Connor Zint
 * @date 2/26/2018
 * @description Trigger on Order__c
 */
 trigger OrderCustomTrigger on Order__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerHandler handler = new OrderTriggerHandler(new TriggerRecordWrapper(
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