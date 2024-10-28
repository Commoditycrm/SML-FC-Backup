@istest
public class storeLocationTrigger_test {
    public TestMethod static void updateAddress()
    {
        list<Location_Record_Ignored__c> lrlist= new list<Location_Record_Ignored__c>();
        account acc=new account();
        acc.Name='test2';
        insert acc;
        asset ast=new asset();
        ast.name='test';
        ast.AccountId=acc.Id;
        insert ast;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Account__c=acc.Id;
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        storeLocationTrigger.updateAddress(lrlist);
        test.stopTest();
        
        
    }
}