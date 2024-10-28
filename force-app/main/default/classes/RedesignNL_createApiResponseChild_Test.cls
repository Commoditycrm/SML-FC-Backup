@isTest
public class RedesignNL_createApiResponseChild_Test {
    @isTest
    static void testCreateApiResponseChild() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.Id, Device_Id__c = 'Test Device ID');
        insert asset;
        
        RedesignNL_createApiResponseChild.wrapper testWrapper = new RedesignNL_createApiResponseChild.wrapper();
        testWrapper.recordid = asset.Id;
        testWrapper.latitude = '10.123';
        testWrapper.longitude = '20.456';
        testWrapper.timestamp = DateTime.now();
        
        List<RedesignNL_createApiResponseChild.wrapper> testWrappers = new List<RedesignNL_createApiResponseChild.wrapper>();
        testWrappers.add(testWrapper);
        
        Test.startTest();
        
        RedesignNL_createApiResponseChild.createApiResponseChild(testWrappers);
        
        Test.stopTest();
        
    }
}