/**
 * @author Connor Zint
 * @date 12/17/2017
 * @description Trigger on Part_Order__c
 */
trigger PartOrderTrigger on Part_Order__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerHandler handler = new PartOrderService(new TriggerRecordWrapper(
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