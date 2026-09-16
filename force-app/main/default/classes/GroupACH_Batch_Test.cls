@isTest
public class GroupACH_Batch_Test {
    @isTest
    public static void testGroupACH_Batch(){
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
        ah.Current_Location_Address__c='123';
        ah.RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
        ahcs.add(ah);
        asset_history_custom__c ah2=new asset_history_custom__c();
        ah2.Asset__c=ast.Id;
        ah2.Start_Time__c=system.today()+2;
        ah2.End_Time__c=system.today()+4;
        ah2.Latitude__c=44.37994355;
        ah2.Longitude__c=-92.03575066;
        ah2.Location__c='Test';
        ah2.Current_Location_Address__c = '123';
        ah2.RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
        ahcs.add(ah2);
        asset_history_custom__c ah3=new asset_history_custom__c();
        ah3.Asset__c=ast.Id;
        ah3.Start_Time__c=system.today()+4;
        ah3.End_Time__c=system.today()+5;
        ah3.Latitude__c=44.37994355;
        ah3.Longitude__c=-92.03575066;
        ah3.Location__c='In Transit';
        ah3.Current_Location_Address__c = '123';
        ah3.RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
        ahcs.add(ah3);
        asset_history_custom__c ah4=new asset_history_custom__c();
        ah4.Asset__c=ast.Id;
        ah4.Start_Time__c=system.today()+4;
        ah4.End_Time__c=system.today()+5;
        ah4.Latitude__c=44.37994355;
        ah4.Longitude__c=-92.03575066;
        ah4.Location__c='In Transit';
        ah4.Current_Location_Address__c = '123';
        ah4.RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
        ahcs.add(ah4);
        insert ahcs;
        Test.startTest();
        Database.ExecuteBatch(new RedesignNL_LocationMismatch(),1000);
        Test.stopTest();
        //system.assertEquals(system.today()+4, [SELECT Id,End_Time__c FROM asset_history_custom__c][1].End_Time__c);
        
    }
}