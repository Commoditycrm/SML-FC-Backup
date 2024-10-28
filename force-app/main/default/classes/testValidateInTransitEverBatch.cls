//testInTransitEverTestClass to check any Missing InTransitEver Record Found or Not
@isTest
public class testValidateInTransitEverBatch {
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
            Location__c = 'In Transit',
            Start_Time__c = Datetime.now().addDays(-20),
            End_Time__c = Datetime.now().addHours(-15)
        );
        insert ahc;
        
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-5),
            End_Time__c = Datetime.now().addHours(-2)
        );
        insert ahc1;
        
        Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'Cardinal Glass Hudson',
            Start_Time__c = Datetime.now().addDays(-15),
            End_Time__c = Datetime.now().addHours(-1)
        );
        insert ahc2;
    }
    
    
    @isTest 
    public static void ValidateInTransitEverBatch(){
        List<Asset> astList = [SELECT Id,Name FROM Asset Limit 1];
        List<Id> assetIds = new List<Id>();
        
        for(Asset a : astList) {
            assetIds.add(a.Id);
        }
        
        Test.startTest();
        Database.executeBatch(new ValidateInTransitEverRecord_Batch(assetIds[0]));
        Database.executeBatch(new ValidateInTransitEverRecord_Batch(20));
        Database.executeBatch(new ValidateInTransitEverRecord_Batch(assetIds[0],'02/21/2024'));
        Database.executeBatch(new ValidateInTransitEverRecord_Batch(20,'02/21/2024'));
        Test.stopTest();
    }
 
}