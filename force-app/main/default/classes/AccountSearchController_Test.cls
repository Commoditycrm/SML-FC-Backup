/*@IsTest
public class AccountSearchController_Test {
    
@IsTest
    static void testGetAssetsByAccountId() {
        // Create a test account and assets
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
         Test.startTest();
        string Status ='Activate';
        List<Account>acc= AccountSearchController.searchAccounts('test');
        List<Account>acc2= AccountSearchController.getAcc();
        Asset testAsset1 = new Asset(Name='Test Asset 1', AccountId=testAccount.Id);
        Asset testAsset2 = new Asset(Name='Test Asset 2', AccountId=testAccount.Id);
        insert new List<Asset>{testAsset1, testAsset2};
        

        // Call the method being tested with the ID of the test account
        List<Asset> result = AccountSearchController.getAssetsByAccountId(testAccount.Id);
        List<Asset> result2 = AccountSearchController.getAllAssets();
        Integer AssetCount =AccountSearchController.getTotalAssets();
        List<Id> astId = new List<Id>();
        for (Asset resultID :result){
            astId.add(resultId.Id);
        }
        
        AccountSearchController.calloutActivateDeactivate(astId, Status);
        Test.stopTest();
       
    }

}*/

@IsTest
public class AccountSearchController_Test {
    @IsTest
    static void testGetAssetsByAccountId() {
        // Set the mock callout
        
        // Start the test
        Test.startTest();
        
        // Create a test account and assets
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        String Status = 'Activate';
        List<Account> acc = AccountSearchController.searchAccounts('test');
        List<Account> acc2 = AccountSearchController.getAcc(false);
        
        // Create and insert test assets
        Asset testAsset1 = new Asset(Name='Test Asset 1', AccountId=testAccount.Id);
        Asset testAsset2 = new Asset(Name='Test Asset 2', AccountId=testAccount.Id);
        insert new List<Asset>{testAsset1, testAsset2};
        
        // Test getting assets by AccountId
        List<Asset> result = AccountSearchController.getAssetsByAccountId(testAccount.Id,false);
        List<Asset> result2 = AccountSearchController.getAllAssets();
        Integer AssetCount = AccountSearchController.getTotalAssets();
        
        // Collect asset names to pass to calloutActivateDeactivate
        List<String> assetNames = new List<String>();
        for (Asset asset : result) {
            assetNames.add(asset.Name);
        }
        
        // Call the method that makes an HTTP callout
       
        
        // Stop the test
        Test.stopTest();
        
        // Assert that the method returns the expected assets
        System.assertEquals(2, result.size());
        System.assertEquals('Test Asset 1', result[0].Name);
        System.assertEquals('Test Asset 2', result[1].Name);
    }
    
      @isTest
    static void testAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
        string Status = 'Activate';
        List<String> assetNames = New  List<String>();
        assetNames.add('at12-test1');
         assetNames.add('at12-test2');
        assetNames.add('at12-test3');
        // Call the method being tested
        Test.startTest();
        AccountSearchController.calloutActivateDeactivate(assetNames, Status);
        Test.stopTest();
        
    }
}