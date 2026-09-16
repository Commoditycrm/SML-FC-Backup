@isTest
public class AssetFilterController_Test {
    @testSetup
    static void testDataSetup() {
        // Create a test Account
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.ShippingLatitude = 42.59104532;
        acc.ShippingLongitude = -83.55054479;
        insert acc;
        
        // Create test Assets
        Asset ast1 = new Asset();
        ast1.AccountId = acc.Id;
        ast1.Name = 'Test Asset 1';
        ast1.Rack_Type__c = 'Type A';
        insert ast1;
        
        Asset ast2 = new Asset();
        ast2.AccountId = acc.Id;
        ast2.Name = 'Test Asset 2';
        ast2.Rack_Type__c = 'Type B';
        insert ast2;
        
        // Create a test Asset List
        Asset_List__c astLst = new Asset_List__c();
        astLst.List_view_Name__c = 'Test List View';
        astLst.List_View_Query__c = 'account_unique_id__c = \'A-12345\'';
        insert astLst;
        
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test Contact';
        testContact.AccountId = acc.Id;
        insert testContact;
    }
    
    @isTest
    static void testGetAccounts() {
        Test.startTest();
        Map<String, String> accounts = AssetFilterController.getAccounts();
        Test.stopTest();
    }
    
    @isTest
    static void testCheckListViewEditAccess() {
        Asset_List__c assetList = [SELECT Id FROM Asset_List__c LIMIT 1];
        Test.startTest();
        AssetFilterController.checkListViewEditAccess(assetList.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAssetTypes() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<String> assetTypes = AssetFilterController.getAssetTypes(acc.Id);
        Test.stopTest();       
    }
    
    @isTest
    static void testDeleteAssetList() {
        Asset_List__c assetList = [SELECT Id FROM Asset_List__c LIMIT 1];
        
        Test.startTest();
        String result = AssetFilterController.deleteAssetList(assetList.Id);
        AssetFilterController.deleteAssetList('11345');
        Test.stopTest();
    }
    
    @isTest
    static void testGetFilteredAccounts() {
        Test.startTest();
        List<Account> accounts = AssetFilterController.getFilteredAccounts();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetFilteredAssets() {
        String filterCriteria = 'Test';
        
        Test.startTest();
        List<Asset> filteredAssets = AssetFilterController.getFilteredAssets(filterCriteria);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateAssetList() {
        Asset_List__c assetList = [SELECT Id FROM Asset_List__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, String> fields = new Map<String, String>();
        fields.put('recordId', assetList.Id);
        fields.put('Name__c', 'Updated List View');
        fields.put('Asset_Type__c', 'null, TypeA');
        fields.put('Asset_Type_Operator__c', 'In');
        fields.put('downstream_customer', acc.Id);
        Map<String, String> fields2 = new Map<String, String>();
        fields2.put('recordId', assetList.Id);
        fields2.put('Name__c', 'Updated List View');
        fields2.put('Asset_Type__c', 'null');
        fields2.put('Asset_Type_Operator__c', 'In');
        fields2.put('downstream_customer', acc.Id);
        Map<String, String> fields3 = new Map<String, String>();
        fields3.put('recordId', assetList.Id);
        fields3.put('Name__c', 'Updated List View');
        fields3.put('Asset_Type__c', 'TypeB');
        fields3.put('Asset_Type_Operator__c', 'In');
        fields3.put('downstream_customer', acc.Id);
        
        Test.startTest();
        String result = AssetFilterController.updateAssetList(fields);
        String result2 = AssetFilterController.updateAssetList(fields2);
        String result3 = AssetFilterController.updateAssetList(fields3);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateAssetList() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, String> fields = new Map<String, String>();
        fields.put('Name__c', 'New List View');
        fields.put('Asset_Type__c', 'null, Type B');
        fields.put('Asset_Type_Operator__c', 'In');
        fields.put('downstream_customer', acc.Id);
        Map<String, String> fields2 = new Map<String, String>();
        fields2.put('Name__c', 'Updated List View');
        fields2.put('Asset_Type__c', 'null');
        fields2.put('Asset_Type_Operator__c', 'In');
        fields2.put('downstream_customer', acc.Id);
        Map<String, String> fields3 = new Map<String, String>();
        fields3.put('Name__c', 'Updated List View');
        fields3.put('Asset_Type__c', 'TypeB, TypeA');
        fields3.put('Asset_Type_Operator__c', 'In');
        fields3.put('downstream_customer', acc.Id);
        
        Test.startTest();
        Map<String, String> result1 = AssetFilterController.createAssetList(fields);
        Map<String, String> result2 = AssetFilterController.createAssetList(fields2);
        Map<String, String> result3 = AssetFilterController.createAssetList(fields3);
        Test.stopTest();
        
    }
}