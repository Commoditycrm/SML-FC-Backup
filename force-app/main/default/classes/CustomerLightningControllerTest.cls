@IsTest
public class CustomerLightningControllerTest {
    @testSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;


        // Create a Contact
        Contact cnt = new Contact(
            AccountId = acc.Id,
            LastName = 'Test User',
            Asset_List_Views_Shared__c = 'Sample'
        );
        insert cnt;

        // Create an Asset List
        Asset_List__c astList = new Asset_List__c(
            List_view_Name__c = 'Sample',
            List_View_Developer_Name__c = 'Sample_002',
            List_View_Query__c = 'account_unique_id__c = \'a-000589\' and field2__c = \'3899\' order by name asc nulls first, id asc nulls first'
        );
        insert astList;
    }

    @IsTest
    static void testAssetList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());

        Test.startTest();
        List<Asset> result = CustomerLightningController.assetlist(null);
        Test.stopTest();
    }

    @IsTest
    static void testAssetListViewOption() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
            Test.startTest();
            List<String> result = CustomerLightningController.assetListViewOption();
            Test.stopTest();
    }

    @IsTest
    static void testAssetListOptions() {
        Asset_List__c astList = [SELECT Id FROM Asset_List__c LIMIT 1];

        Test.startTest();
            List<Asset_List__c> options = CustomerLightningController.assetListOptions();
            List<Asset> ast = CustomerLightningController.fetchAssets(astList.Id);
        Test.stopTest();
    }

    @IsTest
    static void testAssetListView() {
        Test.startTest();
            List<String> result = CustomerLightningController.assetlistView();
        Test.stopTest();
    }

    @IsTest
    static void testGetAccountByUserId() {

        Test.startTest();
            Account result = CustomerLightningController.getAccountByUserId();
        CustomerLightningController.userlatlng();
        CustomerLightningController.getUserTimeZoneOffset();
        Test.stopTest();
    }
}