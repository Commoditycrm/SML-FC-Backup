@isTest
public class testRedesignNL_AccountDeletionHelper {
    @isTest
    static void testGetDeleteAcc() {
         Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.ShippingLatitude = 42.59104532;
        acc.ShippingLongitude = -83.55054479;
        acc.Capture_Business_Name__c = true;
        acc.Replaced_Account__c = 'In Transit';
        acc.UpdateRecords__c = true;
        insert acc;
        // Step 1.1: Create an Account record
        Account acc1 = new Account();
        acc1.Name = 'Testing2';
        acc1.GeoFence_Radius_in_Miles__c = 20;
        acc1.ShippingLatitude = 42.59104532;
        acc1.ShippingLongitude = -83.55054479;
        acc1.Capture_Business_Name__c = true;
        acc1.Replaced_Account__c = 'In Transit';
        acc1.UpdateRecords__c = true;
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Testing3';
        acc2.GeoFence_Radius_in_Miles__c = 20;
        acc2.ShippingLatitude = 42.59104532;
        acc2.ShippingLongitude = -83.55054479;
        acc2.Capture_Business_Name__c = true;
        acc2.Replaced_Account__c = 'In Transit';
        acc2.UpdateRecords__c = true;
        insert acc2;
         Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc.Id;
        rc.Related_To__c = acc1.Id;
        insert rc;
        
        List<Account> accList = [SELECT Id FROM Account Where Name = 'Testing2' LIMIT 1];
        List<Account> accList2 = [SELECT Id FROM Account Where Name = 'Testing' LIMIT 1];
        List<Account> accList3 = [SELECT Id FROM Account Where Name = 'Testing3' LIMIT 1];
        
        Test.startTest();
        RedesignNL_AccountDeletionHelper.getDeleteAcc(accList);
        RedesignNL_AccountDeletionHelper.getDeleteAcc(accList2);
        RedesignNL_AccountDeletionHelper.getDeleteAcc(accList3);
        Test.stopTest();
    }
}