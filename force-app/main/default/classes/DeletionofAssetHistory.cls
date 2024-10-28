global with sharing class DeletionofAssetHistory implements Database.Batchable<sObject>, Database.Stateful 
{
    global integer count = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        string num=string.valueof(system.label.Asset_History_Deletion_Date);
        String val = num; 
        DateTime date1 = (DateTime)Json.deserialize('"'+val+'"', DateTime.class);
        System.debug(date1);// 2018-12-29 10:00:00
        String convertedDate = date1.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'.000+0000\'');
        system.debug(convertedDate);
        return Database.getQueryLocator('SELECT Id,createddate FROM Asset_History_custom__c WHERE Still_in_this_Location__c = False and createddate <'+convertedDate+'');
        
    }
    global void execute(Database.BatchableContext BC, List<	Asset_History_custom__c> AHList) {
        try{
            system.debug('enter');
            //Database.deleteResult[] ds =  Database.delete(apiList,false);
            List<Database.DeleteResult> ds =  Database.delete(AHList,false);
            system.debug('Testok');
            for(Database.deleteResult d : ds){
                system.debug('Test1'+d);
                if(d.issuccess()){
                    count++;
                    system.debug('Test2'+count);
                }
            }
            system.debug('Test3'+count);
            
        }
        catch(exception e){
            system.debug('delete failed');
        } 
    } 
    global void finish(Database.BatchableContext BC) {
        system.debug('count'+count);
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit storageSpace = limitsMap.get('DataStorageMB');
        System.debug('Limit Name: ' + storageSpace.getName());
        System.debug('Usage Value: ' + storageSpace.getValue());
        System.debug('Maximum Limit: ' + storageSpace.getLimit());
        decimal getValue = storageSpace.getValue();
        decimal getLimit = storageSpace.getLimit();
        decimal percentage = (getValue/getLimit) * 100;
        integer Finalpercentage = percentage.intvalue();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {'commodityccrm@gmail.com'};
            //system.debug('apexJob.CreatedBy.Email : '+apexJob.CreatedBy.Email);
            mail.setToAddresses(toAddress);
        mail.setSubject('Api Records Deleted - Batch Process Completed');
        mail.setPlainTextBody('Total Records '+count+' deleted sucessfully. ' +' After deletion storage space now at '+ Finalpercentage +' %. ');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}