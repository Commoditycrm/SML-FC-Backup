/**
 * @author 		RadialSpark, Amanda Bodnovits
 * @date 		02/03/18
 * @description Unit tests for AssetTriggerHandler
 * @history
 * 			11/27/2018 | Jeffrey Underdown | Removed old unit tests relating to location assingment
 */

@isTest
public with sharing class AssetTriggerHandlerTest {
	private static Account testAccount;
	private static Account testAccount1;
	private static List<Asset> pallets;
	private static Map<Id, Asset> palletOldMap;
	private static TriggerRecordWrapper records;
	private static Product2 testProduct;
	
	private static void init() {
        //get picklist option 'Source' for Account.Location_Type__c
       	String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        
		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);

		testAccount = AccountTestDataFactory.createAccount(
			'coffeeShop',
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

		testProduct = ProductTestDataFactory.createProduct('Test Product', 'Pallet', true);

		pallets = AssetTestDataFactory.createPalletList(testAccount.Id, 'In Transit', 33.5837301, -111.9244083, testProduct.Id, 5);
		insert pallets;
		List<Id> palletIds = AssetTestDataFactory.getPalletIds(pallets);
		palletOldMap = new Map<Id, Asset>(
			[SELECT 
				Id,
				Current_Location__c,
				Temporary_Latitude__c,
				Temporary_Longitude__c,
				State_of_Pallet__c,
				AccountId
				FROM Asset 
				WHERE Id IN :palletIds]
		);
	}

	/**
	 *@description unit tests don't actually update the pallets, get update coverage here
	 */	
	@isTest
	public static void cover_update() {
		init();
		
		System.Test.startTest();
		update pallets;
		System.Test.stopTest();
	}

	/**
	 *@description unit tests don't actually delete the pallets, get delete coverage here
	 */	
	@isTest
	public static void cover_delete() {
		init();

		System.Test.startTest();
		delete pallets;
		System.Test.stopTest();
	}
}