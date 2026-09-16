@isTest
public class downstreamTriggerTest {
	
    static testmethod void testData(){
        
        account acc = new account(name ='acc124');
        insert acc;
        account acc1 = new account(name ='acc1234');
        insert acc1;
        RecordType DefaultRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Default' LIMIT 1];
		Asset_Configuration__c acntConf3 = new Asset_Configuration__c();
        acntConf3.Account__c = acc1.Id;
        acntConf3.RecordTypeId = DefaultRecType.Id;
    	insert acntConf3;
        
        Related_Customer__c rc = new Related_Customer__c(Related_To__c = acc.id,Source_Account__c = acc1.id);
        insert rc;
        
        delete rc;
    }
}