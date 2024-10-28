@istest
public class testRedesignNL_AccountCheck {
    static testmethod void nimbeLink_CTRL1(){
        account acc=new account();
        acc.name='Testing';
        acc.ShippingLatitude = 1.1;
        acc.ShippingLongitude = 1.4;
        insert acc;
        account acc1=new account();
        acc1.name='Testing';
        acc1.ShippingLatitude = 1.1;
        acc1.ShippingLongitude = 1.4;
        insert acc1;
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc.Id;
        rc.Related_To__c = acc1.id;
        insert rc;
        
        // List<Account>
        Test.startTest();
        List<Related_Customer__c> rccList =[SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c  order by CreatedDate asc];
        List<Account> accList =[select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c FROM Account  order by createddate asc ];
        Database.ExecuteBatch(new RedesignNL_AccountCheck(),1);
        Database.ExecuteBatch(new RedesignNL_AccountCheck(true),1);
        
        Test.stopTest();  
        
    }
}