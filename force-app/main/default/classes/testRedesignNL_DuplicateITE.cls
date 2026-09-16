@istest
public class testRedesignNL_DuplicateITE {
 @testSetup 
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
       
        Asset ast = new Asset();
        ast.Name = 'Testing';
        ast.Device_Id__c = 'dummy-test4';
        ast.AccountId = acc.Id;
        insert ast;
       
        
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-20),
            End_Time__c = Datetime.now().addHours(-15),
            RecordtypeID = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        );
        insert ahc;
        Asset_History_Custom__c ahc7 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-20),
            End_Time__c = Datetime.now().addHours(-15),
            RecordtypeID = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        );
        insert ahc7;
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-5),
            End_Time__c = Datetime.now().addHours(-2),
            RecordtypeID = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        );
        insert ahc1;
        
        Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-15),
            End_Time__c = Datetime.now().addHours(-1),
            RecordtypeID = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        );
        insert ahc2;
    }
    
    
    @isTest 
    public static void ValidateInTransitEverBatch(){
        Test.startTest();
        Database.executeBatch(new RedesignNL_DuplicateITE());
        
        Test.stopTest();
    }
}