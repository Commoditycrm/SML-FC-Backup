/**
 * @author 		Bradley Wong, RadialSpark
 * @date 		3/1/18
 * @description Tests for PalletLocationEventTrigger (required to successfully deploy)
 */

@isTest
public with sharing class PalletLocationEventTriggerTest {
    private static Pallet_Location_Event__e testPallet;
    private static Account parentAccount;
    private static Account testAccount;
    private static Account testAccount1;
    private static Product2 testProduct;
    private static Asset pallet;
    
    private static void init() {
        //create testPallet
        testPallet = new Pallet_Location_Event__e(Device_Id__c='0', Asset_Group_Id__c='TestAssetGroupId');
        
        //get picklist option 'Source' for Account.Location_Type__c
       	String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        
		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
            'TestAssetGroupId',
			true
		);

		testAccount = AccountTestDataFactory.createAccount(
			'SMART',
			'Location',
			'7366 E Shea Blvd',
			'Scottsdale',
			'AZ',
			'85260',
			33.5837301,
			-111.9244083,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 0'
		);

		testAccount1 = AccountTestDataFactory.createAccount(
			'radialSpark',
			'Location',
			'5710 W Chandler Blvd',
			'Chandler',
			'AZ',
			'85226',
			33.307501,
			-111.9421107,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 1'
		);

		testProduct = ProductTestDataFactory.createProduct('Tag Generic', 'Pallet', true);

		pallet = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.307501, 
            -111.9421107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test device Id', 
            testProduct.Id
        );
	}

    private static testMethod void afterTrigger_NoAssets() {
        init();
        
        System.Test.startTest();
        Database.SaveResult result = EventBus.publish(testPallet);
        System.Test.stopTest();
        
		List<Asset> findPallet = [SELECT Id FROM Asset];
        //System.assertEquals(1, findPallet.size());
    }
    
    private static testMethod void afterTrigger_WithAssets() {
		init();
        insert pallet;
        
        testPallet.Device_Id__c = 'test device Id';
        
        System.Test.startTest();
        Database.SaveResult result = EventBus.publish(testPallet);
        System.Test.stopTest();
        
		List<Asset> findPallet = [SELECT Id FROM Asset];
        //System.assertEquals(1, findPallet.size());
    }
	
}