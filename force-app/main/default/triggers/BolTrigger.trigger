/**
 * @author Bradley Wong
 * @date 05-11-2018
 * @description Trigger on BOL__c
 */
 trigger BolTrigger on BOL__c (after insert) {
    TriggerHandler handler = new BolTriggerHandler(new TriggerRecordWrapper(
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