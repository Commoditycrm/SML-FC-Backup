global class DeleteApiResponseBatch implements Database.Batchable<sObject>, Database.Stateful 
{
    global integer count = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records to be passed to execute       
        return Database.getQueryLocator('SELECT Id,createddate FROM Api_Response__c  WHERE createddate < LAST_N_DAYS:7');
    }
    global void execute(Database.BatchableContext BC, List<Api_Response__c> apiList) {
        try{
            List<Database.DeleteResult> ds =  Database.delete(apiList,false);
                for(Database.deleteResult d : ds){
                    if(d.issuccess()){
                        count++;
                }
            }
        }
        catch(exception e){
        } 
    } 
    global void finish(Database.BatchableContext BC) {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit storageSpace = limitsMap.get('DataStorageMB');
        /*System.debug('Limit Name: ' + storageSpace.getName());
        System.debug('Usage Value: ' + storageSpace.getValue());
        System.debug('Maximum Limit: ' + storageSpace.getLimit());*/
        decimal getValue = storageSpace.getValue();
        decimal getLimit = storageSpace.getLimit();
        decimal percentage = (getValue/getLimit) * 100;
        integer Finalpercentage = percentage.intvalue();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {'commodityccrm@gmail.com'};
        mail.setToAddresses(toAddress);
        mail.setSubject('Api Records Deleted - Batch Process Completed');
        mail.setPlainTextBody('Total Records '+count+' deleted sucessfully. ' +' After deletion storage space now at '+ Finalpercentage +' %. ');
       // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}