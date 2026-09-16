@isTest
public class testRedesignNL_AHCDeletionBatch {
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'at5-t16ee4491f50'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        insert ast;
        Asset_History_custom__c ahc = new Asset_History_custom__c();
        ahc.Still_in_this_Location__c = false;
        ahc.Preserve_for_EA__c = false;
        ahc.Asset__c = ast.Id;
        insert ahc;
    }
    @IsTest
    Public Static Void testRedesignNL_AHCDeletionBatchDelete(){
        String query = 'Select Id from Asset_History_custom__c where Still_in_this_Location__c = false ';
        Test.startTest();
        database.executeBatch(new RedesignNL_AHCDeletionBatch(query, true), 150);
        Test.stopTest();
    }
    @IsTest
    Public Static Void testRedesignNL_AHCDeletionBatchUpdate(){
        String query = 'Select Id from Asset_History_custom__c where Still_in_this_Location__c = false ';
        Test.startTest();
        database.executeBatch(new RedesignNL_AHCDeletionBatch(query, false), 150);
        Test.stopTest();
    }
    
}