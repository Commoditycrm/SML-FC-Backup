@isTest
public class AssetLightningController_Test {
    public static user conTest;
    @testSetup
    static void setup() {
        // Create a test account and related records
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.shippinglatitude = 42.59104532;
        acc.shippinglongitude = -83.55054479;
        insert acc;
        contact con1 = New contact();
        con1.lastName = 'TestAccountContact';
        con1.AccountId = acc.id;
        insert con1;
        system.debug('contact created--'+con1.Id);
        
        
        Account acc2 = New Account();
        acc2.Name = 'Testing2';
        insert acc2;
        
        Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'dummy';
        insert con;
        
        Asset asset2 = new Asset(
            Name = 'Test Asset 2',
            AccountId = acc.Id,
            device_id__c = 'Test Asset 2',
            Is_Access_Point__c = true // This asset should not be included in the final list
        );
        insert asset2;
        
        Asset_List__c astlst = new Asset_List__c();
        astlst.list_view_name__c = 'Vitro Glass - 1GS';
        astlst.List_View_Query__c = 'account_unique_id__c !=  null order by name asc nulls first, id asc nulls first';
        astlst.List_View_Developer_Name__c = 'Cardinal_Hudson_All_Racks_002726';
        insert astlst;
    }
    
    @isTest
    static void testAssetListOptions() {
        Test.startTest();
        List<Asset_List__c> assetOptions = AssetLightningController.assetListOptions();
        Test.stopTest();
        
        System.assert(assetOptions.size() > 0, 'Expected asset list options to return results.');
    }
    
    @isTest
    static void testSmuckerUser() {
        user quinton = [SELECT Id FROM User WHERE Name LIKE '%Quinton H%' LIMIT 1];
        Test.startTest();
        System.runAs(quinton) {
            Boolean isSmuckerUser = AssetLightningController.SmuckerUser();
            System.assert(!isSmuckerUser, 'User should not be a Smucker user.');
        }
        Test.stopTest();
    }
    
    @isTest static void testAssetListWithResults() {
        user quinton2 = [select id,contactId from user where username LIKE '%qhouston@vitro.com%' limit 1];
        
        ListView lv = [select id,name,DeveloperName from listview where name = 'Cardinal IG Ocala - B52'];
        Asset_List__c astLst = [select id from Asset_List__c limit 1];
        
        
        Test.startTest();
        
        AssetLightningController.userlatlng();
        AssetLightningController.assetlistView();
        AssetLightningController.assetListViewOption();
        AssetLightningController.assetListOptions();
        AssetLightningController.getAccountByUserId();
        AssetLightningController.fetchAssets(astlst.Id);
        Boolean result = AssetLightningController.ArmsUser();
        String result1 = AssetLightningController.updateuserLang('es');
      
        system.runAs(quinton2){
            AssetLightningController.userlatlng();
            AssetLightningController.assetlistView();
            //AssetLightningController.assetListViewOption();
            AssetLightningController.assetListOptions();
            AssetLightningController.getAccountByUserId();
            AssetLightningController.fetchAssets(astlst.Id);
            Boolean result2 = AssetLightningController.ArmsUser();
            String result3 = AssetLightningController.updateuserLang('es');
        }
        
        Test.stopTest();
        
    }
    
    /*@isTest
    static void testArmsUser() {
        Asset_List__c astLst = [select id from Asset_List__c limit 1];
        user armsuser = [select id,contactId from user where UserRole.name LIKE '%ARMS%' limit 1];
        
        Test.startTest();
        system.runAs(armsuser){
            AssetLightningController.userlatlng();
            AssetLightningController.assetlistView();
            AssetLightningController.assetListViewOption();
            AssetLightningController.assetListOptions();
            AssetLightningController.getAccountByUserId();
            AssetLightningController.fetchAssets(astlst.Id);
            Boolean result2 = AssetLightningController.ArmsUser();
            String result3 = AssetLightningController.updateuserLang('es');
        }
        Test.stopTest();
    }*/
    
    @isTest
    static void testUpdateUserLang() {
        Test.startTest();
        String result = AssetLightningController.updateuserLang('es');
        Test.stopTest();
    }
    
    @isTest
    static void testAssetList1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Test.startTest();
        List<Asset> result = CustomerLightningController.assetlist('Vitro Flat Glass - 1GS');
        Test.stopTest();
        
    }
    
    @isTest
    static void testAssetList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        
        // Call the method being tested
        Test.startTest();
        List<Asset> result = AssetLightningController.assetlist('Vitro Flat Glass - 1GS');
        AssetLightningController.getAccountByUserId();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetDeleteAcc() {
        List<Account> accList = [SELECT Id FROM Account Where Name = 'Testing2' LIMIT 1];
        List<Account> accList2 = [SELECT Id FROM Account Where Name = 'Testing' LIMIT 1];
        
        Test.startTest();
        AssetLightningController.getDeleteAcc(accList);
        AssetLightningController.getDeleteAcc(accList2);
        AssetLightningController.getUserTimeZoneOffset();
        Test.stopTest();
    }
}