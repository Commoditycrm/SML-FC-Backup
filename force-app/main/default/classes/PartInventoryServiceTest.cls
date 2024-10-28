/**
 * @author Connor Zint
 * @date 01/18/2018
 * @description Test methods for PartInventoryService
 */
@isTest
private class PartInventoryServiceTest {
	private static Account testAccount;
	private static Part_Inventory__c partInventory;
	private static List<Part_Inventory__c> testPartInventoriesList;
	private static Part_Order__c testPartOrder;
	private static Product2 testProduct;
	private static List<Product2> testProductList;
	private static Set<Id> testProductListIds;
	private static TriggerRecordWrapper records;
	
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
            'Test Location'
		);

		testProduct = ProductTestDataFactory.createProduct('Test Product', 'Repair_Part', true);
		testProductList = ProductTestDataFactory.createRepairPartProducts('test product', 'Repair_Part', 5, true);
		testProductListIds = ProductTestDataFactory.getProductIds(testProductList);

		partInventory = PartInventoryTestDataFactory.createPartInventory(testProduct.Id, 10, testAccount.Id, 5, 10, false);
		testPartInventoriesList = PartInventoryTestDataFactory.createPartInventories(20, 10, 20, testProductListIds, testAccount.Id, true); 

		testPartOrder = new Part_Order__c(
        	Tracking_Number__c = 'Test Tracking Number',
            Expected_Arrival__c = date.newInstance(2018, 1, 1)
        );
	}

	/**
	 * @description verify that part inventory is save when there is not yet a part inventory
	 *				with the same account and part type
	 */
	@isTest
	public static void enforceOneInventoryPerPart_successOnInsert() {
		init();

		// verify there are no existing part inventories
		System.assert([SELECT Id, Account__c FROM Part_Inventory__c WHERE Account__c =: testAccount.Id AND Part_Type__c =: testProduct.Id].isEmpty());

		// attach part inventory to account
		partInventory.Account__c = testAccount.Id;

		System.Test.startTest();
		insert partInventory;
		System.Test.stopTest();

		// verify that part inventory was saved to the account
		System.assertEquals(1, [SELECT Id, Account__c FROM Part_Inventory__c WHERE Account__c =: testAccount.Id AND Part_Type__c =: testProduct.Id].size());
	}

	/**
	 * @description verify that part inventory is not save when there is a part inventory
	 *				with the same account and part type that already exists
	 */
	@isTest
	public static void enforceOneInventoryPerPart_failOnInsert() {
		init();

		// save part inventory
		insert partInventory;

		List<Part_Inventory__c> partInventoryList = new List<Part_Inventory__c>{partInventory};
		records = new TriggerRecordWrapper(
			partInventoryList,
			null,
			null,
			null // this should be trigger old
		);

		System.Test.startTest();

		// Verify that exception is thrown because of the duplicate part inventory
		PartInventoryService pis = new PartInventoryService(records);
		try {
			pis.EnforceOneInventoryPerPart(); 
		} catch (Exception e) {
			System.assert(e.getMessage().contains(PartInventoryService.DUPLICATE_PART_INVENTORY));
		}

		System.Test.stopTest();
	}

	/**
	 * @description  verify when a part inventory is updated and there is already a part order for it
	 * 				 that there is not another part order created
	 */
	@isTest
	public static void setPartOrderQuantity_successOnUpdate_existingOrder() {
		init();
		
		insert partInventory;
		testPartOrder.Part_Inventory__c = partInventory.Id;
		insert testPartOrder;
		
		// Verify there is a part order for the part Inventory
		System.assert(![SELECT Id FROM Part_Order__c WHERE Part_Inventory__c =: partInventory.Id].isEmpty());
		
		// Create triggerNew
		List<Part_Inventory__c> partInvTriggerNew = new List<Part_Inventory__c>{partInventory};

		// clone triggerNew and create oldMap
		List<Part_Inventory__c> partInvList = partInvTriggerNew.deepClone();
		partInvList[0].Id = partInventory.Id;
		Map<Id, Part_Inventory__c> partInvOldMap = new Map<Id, Part_Inventory__c>();
		partInvOldMap.put(partInvList[0].Id, partInvList[0]);

		// Lower Part Inventory Quantity in List to update 
		// to where a part order would be created if it doesn't exist
		partInvTriggerNew[0].Quantity__c = 3;

		List<Part_Inventory__c> partInventoryList = new List<Part_Inventory__c>{partInventory};
		records = new TriggerRecordWrapper(
			partInvTriggerNew,
			null,
			null,
			partInvOldMap // this should be trigger old
		);
		PartInventoryService pis = new PartInventoryService(records);

		System.Test.startTest();
		// run update method
		pis.setPartOrderQuantity();
		System.Test.stopTest();

		List<Part_Order__c> partOrders = [SELECT Id, Quantity__c FROM Part_Order__c WHERE Part_Inventory__c =: partInventory.Id];

		// verify there was not a new part order created
		System.assert(partOrders.size() == 1);
	}

	/**
	 * @description verify that when a part inventory quantity drops below it's threshold that
	 * 				a part order is created with a quantity that when added to the part inventory
	 *				quantity will equal the part inventory recommended quantity
	 */
	@isTest
	public static void setPartOrderQuantity_successOnInsert_noExistingOrder() {
		init();
		
		// Verify there are no Part Orders for Part Inventory
		System.assert([SELECT Id FROM Part_Order__c WHERE Part_Inventory__c =: partInventory.Id].isEmpty());

		// Change inventory quantity to below the order threshold
		// this should cause a part order to be created when the
		// record is updated
		partInventory.Quantity__c = 3;

		List<Part_Inventory__c> partInventoryList = new List<Part_Inventory__c>{partInventory};
		records = new TriggerRecordWrapper(
			partInventoryList,
			null,
			null,
			null // this should be trigger old
		);
		
		PartInventoryService pis = new PartInventoryService(records);

		System.Test.startTest();
		// run insert method
		pis.setPartOrderQuantity(); 
		System.Test.stopTest();

		Part_Order__c partOrder = [SELECT Id, Quantity__c FROM Part_Order__c WHERE Part_Inventory__c =: partInventory.Id];

		// verify the part order was created and
		// the order quantity is equal to
		// Part_Inventory__c.Recommended_Quantity - Part_Inventory__c.Quantity
		System.assertNotEquals(null, partOrder);
		System.assertEquals(7, partOrder.Quantity__c);
		System.assertEquals(partOrder.Quantity__c, partInventory.Recommended_Quantity__c - partInventory.Quantity__c);
	}

	@isTest
	public static void setPartOrderQuantity_successOnUpdate_changeThreshold() {
		init();

		// lower the part inventory quantity
		// still above threshold
		partInventory.Quantity__c = 6;
		insert partInventory;
		
		// verify there was no order created
		System.assert([
			SELECT Id, Quantity__c 
			FROM Part_Order__c 
			WHERE Part_Inventory__c =: partInventory.Id]
			.isEmpty()
		);

		// now when we change the threshold to above the part inventories quantity
		partInventory.Order_Threshold__c = 7;

		List<Part_Inventory__c> partInventoryList = new List<Part_Inventory__c>{partInventory};
		records = new TriggerRecordWrapper(
			partInventoryList,
			null,
			null,
			null
		);
		PartInventoryService pis = new PartInventoryService(records);

		System.Test.startTest();
		pis.setPartOrderQuantity();
		System.Test.stopTest();

		// an order should have been created with the correct quantity
		List<Part_Order__c> partOrders = [
			SELECT Id, Quantity__c 
			FROM Part_Order__c 
			WHERE Part_Inventory__c =: partInventory.Id
		];

		System.assertEquals(1, partOrders.size());
		System.assertEquals(4, partOrders[0].Quantity__c);
	}
}