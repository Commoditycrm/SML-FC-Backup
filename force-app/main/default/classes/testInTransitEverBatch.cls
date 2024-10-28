//testInTransitEverTestClass to check any Missing InTransitEver Record Found or Not
@isTest
public class testInTransitEverBatch {
    @testSetup 
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        //Missing InTransitEverRecord
        Asset ast = new Asset();
        ast.Name = 'Testing';
        ast.Device_Id__c = 'dummy-test1';
        ast.AccountId = acc.Id;
        insert ast;
       
        
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit',
            Start_Time__c = Datetime.now().addDays(-20),
            End_Time__c = Datetime.now().addHours(-1)
        );
        insert ahc;
        
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-15),
            End_Time__c = Datetime.now().addHours(-1)
        );
        insert ahc1;
        
        Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In-Network',
            Start_Time__c = Datetime.now().addDays(-15),
            End_Time__c = Datetime.now().addHours(-1)
        );
        insert ahc2;
    }
    
    
    @isTest 
    public static void InTransitEverBatch(){
        List<Asset> astList = [SELECT Id,Name FROM Asset Limit 1];
        List<Id> assetIds = new List<Id>();
        
        for(Asset a : astList) {
            assetIds.add(a.Id);
        }
        
        /*String query = 'SELECT Id, Name, Location__c, Start_Time__c, End_Time__c FROM Asset_History_custom__c ' +
            'WHERE Asset__c =: assetIds and Location__c != null order by Start_Time__c asc limit 50000';*/
        
        Test.startTest();
        Database.executeBatch(new InTransitEver_Batch(assetIds[0]));
        Database.executeBatch(new InTransitEver_Batch(20));
        Test.stopTest();
    }
 
}