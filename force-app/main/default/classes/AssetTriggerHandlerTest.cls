@isTest
public with sharing class AssetTriggerHandlerTest {
    private static Account testAccount1;
    private static Account testAccount2;
    private static Product2 testProduct;
    private static List<Asset> testAssets;

    // Initializes test data
    private static void initTestData() {
        // Create a parent account to avoid validation rule conflicts
        Account parentAccount = new Account(
            Name = 'Parent Account'
        );
        insert parentAccount;

        // Create test accounts
        testAccount1 = new Account(
            Name = 'Test Account 1',
            ParentId = parentAccount.Id
        );
        insert testAccount1;

        testAccount2 = new Account(
            Name = 'Test Account 2',
            ParentId = parentAccount.Id
        );
        insert testAccount2;

        // Create a test product
        testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Family = 'Pallet'
        );
        insert testProduct;

        // Create test assets
        testAssets = new List<Asset>();
        for (Integer i = 0; i < 3; i++) {
            testAssets.add(new Asset(
                Name = 'null'+i,
                AccountId = i==0 ?testAccount1.Id : i==1 ? testAccount2.Id : parentAccount.Id
            ));
        }
        insert testAssets;
    }

    /*@isTest
    public static void testDoBeforeInsert() {
        initTestData();

        Asset ast = new Asset();
        ast.Name = null;

        System.Test.startTest();
        insert ast;
        System.Test.stopTest();

    }*/

    @isTest
    public static void testDoBeforeUpdate() {
        initTestData();

        // Assign Access_Point__c to test assets
        for (Integer i = 0; i < testAssets.size(); i++) {
    if (i > 0) {
        testAssets[i].Access_Point__c = testAssets[i - 1].Id; // Reference the previous asset
    } else {
        testAssets[i].Access_Point__c = null; // First asset has no access point
    }
}

        System.Test.startTest();
        update testAssets;
        System.Test.stopTest();

    }

   /* @isTest
    public static void testDoAfterInsert() {
        initTestData();
        Asset ast = new Asset();
        ast.Name = 'sample ast';
        ast.AccountId = testAccount1.Id;

        System.Test.startTest();
        insert ast;
        System.Test.stopTest();

        // Validate IoT_Asset_Count__c for testAccount1
        Account updatedAccount = [SELECT IoT_Asset_Count__c FROM Account WHERE Id = :testAccount1.Id];
        System.debug('updatedAccount + '+ updatedAccount);
        //System.assertEquals(3, updatedAccount.IoT_Asset_Count__c, 'IoT_Asset_Count__c should be updated after insert');
    }

    @isTest
    public static void testDoAfterUpdate() {
        initTestData();

        // Move assets to testAccount2
        for (Asset asset : testAssets) {
            asset.Current_Location__c = testAccount2.Id;
        }

        System.Test.startTest();
        update testAssets;
        System.Test.stopTest();
    }

    @isTest
    public static void testDoAfterDelete() {
        initTestData();

        System.Test.startTest();
        delete testAssets;
        System.Test.stopTest();

        // Validate IoT_Asset_Count__c is updated
        Account updatedAccount = [SELECT IoT_Asset_Count__c FROM Account WHERE Id = :testAccount1.Id];
        System.assertEquals(0, updatedAccount.IoT_Asset_Count__c, 'IoT_Asset_Count__c should be 0 after delete');
    }

    @isTest
    public static void testErrorHandling() {
        initTestData();

        // Attempt to move a pallet in transit
        Asset asset = testAssets[0];
        asset.State_of_Pallet__c = AssetTriggerHandler.PALLET_TRANSIT;
        asset.Current_Location__c = testAccount2.Id;

            System.Test.startTest();
            update asset;
            System.Test.stopTest();
    }*/
}