@isTest
public class AssetLightningController_Test {
    
    @isTest
    static void testAssetListOptions() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(AccountId=testAccount.Id, LastName='Test Contact');
        insert testContact;
        
        User testUser = new User(
            Alias = 'standt', 
            Email='standarduser@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Tester', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Customer User' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser'+DateTime.now().getTime()+'@test.com',
            ContactId = testContact.Id,
            IsActive = True
        );
        insert testUser;
          Asset_List__c astlst = new Asset_List__c();
        astlst.list_view_name__c = 'Vitro Glass - 1GS';
        astlst.List_View_Query__c = 'account_unique_id__c !=  null order by name asc nulls first, id asc nulls first';
        astlst.List_View_Developer_Name__c = 'Cardinal_Hudson_All_Racks_002726';
        insert astlst;
        System.runAs(testUser) {
            Test.startTest();
            List<Asset_List__c> options = AssetLightningController.assetListOptions();
                    AssetLightningController.assetlistView();
            AssetLightningController.getAccountByUserId();

            Test.stopTest();
            System.debug(options.size());
            // Assertions to ensure the method returns the expected results
            System.assertEquals(0, options.size(), 'The assets list is expected to be empty, but it is not.');
            // Additional assertions based on expected behavior
        } 
    }
      @isTest
    static void testAssetListOptions1() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(AccountId=testAccount.Id, LastName='Test Contact',Asset_List_Views_Shared__c = 'test');
        insert testContact;
        
        User testUser = new User(
            Alias = 'standt', 
            Email='standarduser@test.com',
            EmailEncodingKey='UTF-8',
            LastName='Tester', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Customer User' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser'+DateTime.now().getTime()+'@test.com',
            ContactId = testContact.Id,
            IsActive = True
        );
        insert testUser;
        System.runAs(testUser) {
            Test.startTest();
                                AssetLightningController.assetlistView();
            AssetLightningController.getAccountByUserId();

            List<Asset_List__c> options = AssetLightningController.assetListOptions();
            Test.stopTest();
            System.debug(options.size());
            // Assertions to ensure the method returns the expected results
            System.assertEquals(0, options.size(), 'The assets list is expected to be empty, but it is not.');
            // Additional assertions based on expected behavior
        } 
    }
    @isTest static void testAssetListWithResults() {
        // Setup test data
        ListView lv = [select id,name,DeveloperName from listview where name = 'Cardinal IG Ocala - B52'];
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.shippinglatitude = 42.59104532;
        acc.shippinglongitude = -83.55054479;
        insert acc;
                
        Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
        
        Asset_List__c astlst = new Asset_List__c();
        astlst.list_view_name__c = 'Vitro Glass - 1GS';
        astlst.List_View_Query__c = 'account_unique_id__c !=  null order by name asc nulls first, id asc nulls first';
        astlst.List_View_Developer_Name__c = 'Cardinal_Hudson_All_Racks_002726';
        insert astlst;
        
        AssetLightningController.userlatlng();
        AssetLightningController.assetlistView();
        AssetLightningController.assetListViewOption();
        AssetLightningController.assetListOptions();
        AssetLightningController.getAccountByUserId();
        AssetLightningController.fetchAssets(astlst.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        
        // Replace 'Test ListView' with the actual name of the ListView you're testing, if applicable
      //List<Asset> result = AssetLightningController.assetlist('Cardinal IG Ocala - B52');
        
        //Test.stopTest();
        
        // Asserts
      /*  System.assertNotEquals(null, result, 'The result should not be null.');
       System.assertEquals(1, result.size(), 'Expected 1 asset in the result list.'); */
        
    }
    
   @isTest
    static void testAssetList() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Asset asset1 = new Asset(
            Name = 'Test Asset 1',
            AccountId = acc.Id,
            device_id__c = 'Test Asset 1',
            Is_Access_Point__c = false
        );
        insert asset1;

        Asset_Configuration__c ac = new Asset_Configuration__c();
        ac.Account__c = acc.Id;
        insert ac;
        
        Asset asset2 = new Asset(
            Name = 'Test Asset 2',
            AccountId = acc.Id,
            device_id__c = 'Test Asset 2',
            Is_Access_Point__c = true // This asset should not be included in the final list
        );
        insert asset2;

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());

        // Call the method being tested
        Test.startTest();
        List<Asset> result = AssetLightningController.assetlist('Vitro Flat Glass - 1GS');
        AssetLightningController.getAccountByUserId();
        Test.stopTest();

        // Assert the results
      /*  System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain only one asset');
        System.assertEquals(asset1.Id, result[0].Id, 'Returned asset should match the created asset');*/
    }
    
}