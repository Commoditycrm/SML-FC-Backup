/**
 * @author Connor Zint
 * @date 01/18/2018
 * @description Trigger on Part_Inventory__c
 */
 trigger PartInventoryTrigger on Part_Inventory__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerHandler handler = new PartInventoryService(new TriggerRecordWrapper(
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