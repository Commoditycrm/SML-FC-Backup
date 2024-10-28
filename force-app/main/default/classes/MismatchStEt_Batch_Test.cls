@isTest
public class MismatchStEt_Batch_Test {

    @isTest
    public static void testMismatchStEt_Batch(){
        account acc=new account();
        acc.name='test';
        insert acc;
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        List<asset_history_custom__c> ahcs = new List<asset_history_custom__c>();
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today()+2;
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='Test';
        ahcs.add(ah);
        asset_history_custom__c ah2=new asset_history_custom__c();
        ah2.Asset__c=ast.Id;
        ah2.Start_Time__c=system.today()+2;
        ah2.End_Time__c=system.today()+4;
        ah2.Latitude__c=44.37994355;
        ah2.Longitude__c=-92.03575066;
        ah2.Location__c='Test';
        ahcs.add(ah2);
        asset_history_custom__c ah3=new asset_history_custom__c();
        ah3.Asset__c=ast.Id;
        ah3.Start_Time__c=system.today()+4;
        ah3.End_Time__c=system.today()+5;
        ah3.Latitude__c=44.37994355;
        ah3.Longitude__c=-92.03575066;
        ah3.Location__c='In Transit';
        ahcs.add(ah3);
        insert ahcs;
        
        Test.startTest();
        String qry = 'SELECT Id, Name,device_id__c,Asset__c,Start_Time__c, End_Time__c, CreatedDate, Record_Type_Developer_Name__c FROM Asset_History_custom__c where Id != null  ';
        Database.executeBatch(new MismatchStEt_Batch(qry), 1);
        Test.stopTest();
        system.assertEquals(system.today()+4, [SELECT Id,End_Time__c FROM asset_history_custom__c][1].End_Time__c);
        
    }
}