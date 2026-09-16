/**
 * @author Thomas Wilkins
 * @date 12/17/2017
 * @description Base class for all trigger handlers. Provides default functionality
 * necessary for the dispatcher, which supports focus on implementation of only 
 * relevant functionality and business rules on each individual sObject
 */
public virtual without sharing class TriggerHandler {
    /**
     * @description whether or not the trigger has run yet
     */
    public static Boolean hasRun {
        get {
            if (hasRun == null) hasRun = false;
            return hasRun;
        } set;
    }

    /** 
     * @description wrapper containing all the trigger record data structures
    */
    @TestVisible
    protected TriggerRecordWrapper records;

    /**
     * @description Sets the the trigger record wrapper
     * @param record datastructures from the trigger context
     */
    public TriggerHandler(TriggerRecordWrapper records) {
        this.records = records;
    }

    /**
     * @description whether or not the trigger is active. In this base class, it always 
     * returns true to provide base functionality for those that don't want to implement
     * trigger activation functionality. Child classes can override this if desired
     * @return whether or not the trigger is active
     */
    public virtual Boolean isTriggerActive() {
        return true;
    }
    /**
     * @description default do before Insert -- does nothing unless overriden by a child class
     */
    public virtual void doBeforeInsert() {
        return;
    }
    /**
     * @description default do before update -- does nothing unless overriden by a child class
     */
    public virtual void doBeforeUpdate() {
        return;
    }
    /**
     * @description default do before delete -- does nothing unless overriden by a child class
     */
    public virtual void doBeforeDelete() {
        return;
    }
    /**
     * @description default do after Insert -- does nothing unless overriden by a child class
     */
    public virtual void doAfterInsert() {
        return;
    }
    /**
     * @description default do after update -- does nothing unless overriden by a child class
     */
    public virtual void doAfterUpdate() {
        return;
    }
    /**
     * @description default do after delete -- does nothing unless overriden by a child class
     */
    public virtual void doAfterDelete() {
        return;
    }
    /**
     * @description default do after undelete -- does nothing unless overriden by a child class
     */
    public virtual void doAfterUndelete() {
        return;
    }
}