@isTest
public class downstreamTriggerTest {
	
    static testmethod void testData(){
        
        account acc = new account(name ='acc124');
        insert acc;
        account acc1 = new account(name ='acc1234');
        insert acc1;
        Related_Customer__c rc = new Related_Customer__c(Related_To__c = acc.id,Source_Account__c = acc1.id);
        insert rc;
    }
}