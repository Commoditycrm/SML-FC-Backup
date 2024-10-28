global class AC_Monthly_Cleaner_Batch implements Database.Batchable<sObject>, Database.Stateful , schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String Query = 'Select id from Asset_Config_Monthly_Batch__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Asset_Config_Monthly_Batch__c> scope) {
        for(Asset_Config_Monthly_Batch__c acm: scope){
            delete acm;
        }
    }
    global void finish(Database.BatchableContext bC) {
        
    }
    global void execute(SchedulableContext sc){
    }
}