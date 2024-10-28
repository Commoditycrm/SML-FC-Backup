/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Immutable wrapper class for trigger context data structures
 */
public without sharing class TriggerRecordWrapper {
    /**
     @description trigger context data structures. 
     */
    private List<SObject> triggerNew, triggerOld;
    private Map<Id, SObject> newMap, oldMap;
    /**
     * @description sets class variables
     */
    public TriggerRecordWrapper(
        List<SObject> triggerNew,
        List<SObject> triggerOld,
        Map<Id, SObject> newMap,
        Map<Id, SObject> oldMap
    ) {
        this.triggerNew = triggerNew;
        this.triggerOld = triggerOld;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    /**
     * @description returns Trigger.new
     * @return Trigger.new
     */
    public List<SObject> getTriggerNew() {
        return triggerNew;
    }
    /**
     * @description returns Trigger.old
     * @return Trigger.old
     */
    public List<SObject> getTriggerOld() {
        return triggerOld;
    }
    /**
     * @description returns Trigger.newMap
     * @return Trigger.newMap
     */
    public Map<Id, SObject> getNewMap() {
        return newMap;
    }
    /**
     * @description returns Trigger.oldMap
     * @return Trigger.oldMap
     */
    public Map<Id, SObject> getOldMap() {
        return oldMap;
    }
}