@isTest
public class getconfigurationNimbelinkTest {
	
    
    @TestSetup
static void makeData(){
    account acc=new account();
    acc.Name='test';
    insert acc;
	 asset ast = new asset(name = 'at-atp2bbef1c017f',Device_id__c = 'at-atp2bbef1c017f',accountid=acc.Id);
        insert ast;
}
    static testmethod void getconfigs(){
        
       asset ast = [select id,name,Device_id__c from asset limit 1];
         Test.setMock(HttpCalloutMock.class, new MockGetConfigClass());
        test.startTest();
        getconfigurationNimbelink.getCofigs(ast.Device_id__c);
        test.stopTest();
    }
     static testmethod void getconfigs2(){
        
       asset ast = [select id,name,Device_id__c from asset limit 1];
         Test.setMock(HttpCalloutMock.class, new MockGetConfigClass());
        test.startTest();
        getconfigurationNimbelink.getCofigs(ast.Device_id__c);
        test.stopTest();
    }
}