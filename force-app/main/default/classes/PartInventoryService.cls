/**
 * @author Connor Zint
 * @date 01/18/2018
 * @description Trigger Service Methods on Part_Inventory__c
 */
public without sharing class PartInventoryService extends TriggerHandler {
	public static final String DUPLICATE_PART_INVENTORY = 'Only one inventory record per Part Type for each Location Account';

	@TestVisible
    private List<Part_Inventory__c> triggerNew;
	@TestVisible
	private Map<Id, Part_Inventory__c> oldMap;
	/**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
    public PartInventoryService(TriggerRecordWrapper records) {
		super(records);
		triggerNew = (List<Part_Inventory__c>)records.getTriggerNew();
		oldMap = (Map<Id, Part_Inventory__c>)records.getOldMap();
    }
	
    public override void doBeforeInsert() {
		// call service methods
		enforceOneInventoryPerPart();
	}

	public override void doBeforeUpdate() {
		// call service method
		enforceOneInventoryPerPart();
	}

    public override void doAfterInsert() {

		// call service methods
		setPartOrderQuantity();
	}


    public override void doAfterUpdate() {

		// call service methods
		setPartOrderQuantity();
    }


	/**
     * @description restrict creation of Part_Inventory to one per Account, per Part_Type
     */
	@TestVisible
	private void enforceOneInventoryPerPart() {

		// initialize a map of account Ids to their Part_Types in trigger new
		Map<Id, Set<Id>> newInvAccToPartType = new Map<Id, Set<Id>>();
		for (Part_Inventory__c partInventory : triggerNew) {

			Part_Inventory__c oldPartInv = (oldMap != null) ? oldMap.get(partInventory.Id) : new Part_Inventory__c();
			
			// if the part_type has changed or the part inventory is being inserted
			if (oldPartInv.Part_Type__c != partInventory.Part_Type__c) {

				// if there is not a key for the part inventories account
				if (!newInvAccToPartType.containsKey(partInventory.Account__c)) {
					// add it with a new list containing the part_type of the part inventory
					newInvAccToPartType.put(partInventory.Account__c, new Set<Id>{partInventory.Part_Type__c});
				} else if (
					// the map does have the account but the part is not in its list value yet
					newInvAccToPartType.containsKey(partInventory.Account__c) &&
					!newInvAccToPartType.get(partInventory.Account__c).contains(partInventory.Part_Type__c)
				) {
					// add the part type to the existing list
					newInvAccToPartType.get(partInventory.Account__c).add(partInventory.Part_Type__c);
				} else {
					// this means there is a duplicate part type for an account in trigger new
					partInventory.addError(DUPLICATE_PART_INVENTORY);
				}
			}
		}

		// get all of the existing inventories of the accounts know
		// we are adding part inventories to
		List<Part_Inventory__c> existingPartInvs = [
			SELECT	
				Id,
				Part_Type__c,
				Account__c
			FROM Part_Inventory__c
			WHERE Account__c IN :newInvAccToPartType.keySet()
		];

		if (!existingPartInvs.isEmpty()) {

			// initialize a map of the accounts ids we queried to the part_types the have inventories of
			Map<Id, Set<Id>> existingAccToPartTypeIds = new Map<Id, Set<Id>>();
			for (Part_Inventory__c pi : existingPartInvs) {

				if (!existingAccToPartTypeIds.containsKey(pi.Account__c)) {
					
					existingAccToPartTypeIds.put(pi.Account__c, new Set<Id>());
				}
				existingAccToPartTypeIds.get(pi.Account__c).add(pi.Part_Type__c);
			}

			for (Part_Inventory__c partInventory : triggerNew) {

				// if there is a part inventory for a part_type on an account in the map with triggerNew values
				// and a part inventory with the same part_type on an existing account
				// add an error
				if (
					newInvAccToPartType.get(partInventory.Account__c).contains(partInventory.Part_Type__c) &&
					existingAccToPartTypeIds.get(partInventory.Account__c).contains(partInventory.Part_Type__c)
				) {

					partInventory.addError(DUPLICATE_PART_INVENTORY);
				}
			}
		}
		
	}


	/**
     * @description create or update related order to have the correct quantity needed
	 * 				(Part_Inventory.Recommended_Quantity - Part_Inventory.Quantity)
     */
	@TestVisible
	private void setPartOrderQuantity() {

		List<Part_Inventory__c> inventoriesBelowThresh = new List<Part_Inventory__c>();
		Set<Id> inventoriesBelowThreshIds = new Set<Id>();

		// Check if quantity changed and is low enough to create an order
		for (Part_Inventory__c newPartInv : triggerNew) {

			Part_Inventory__c oldPartInv = (oldMap != null) ? oldMap.get(newPartInv.Id) : new Part_Inventory__c(Order_Threshold__c = 0);

			if (
				(newPartInv.Quantity__c != oldPartInv.Quantity__c ||
				 newPartInv.Order_Threshold__c != oldPartInv.Order_Threshold__c) &&
				newPartInv.Quantity__c < newPartInv.Order_Threshold__c
			) {
				inventoriesBelowThresh.add(newPartInv);
				inventoriesBelowThreshIds.add(newPartInv.Id);
			}
		}

		// Query to get existing part orders
		List<Part_Order__c> partOrders = [
			SELECT
				Part_Inventory__c,
				Quantity__c
			FROM Part_Order__c
			WHERE Part_Inventory__c IN :inventoriesBelowThreshIds
		];

		// put existing part orders in a map to check against
		// where map key is the inventory Id
		Map<Id, Part_Order__c> partOrdersMap = new Map<Id, Part_Order__c>();

		for (Part_Order__c partOrder : partOrders) {

			partOrdersMap.put(partOrder.Part_Inventory__c, partOrder);
		}

		List<Part_Order__c> partOrdersToUpsert = new List<Part_Order__c>();

		// check if there is an existing order
		// if there is not create a new Part_Order
		for (Part_Inventory__c newPartInv : inventoriesBelowThresh) {

			if (!partOrdersMap.containsKey(newPartInv.Id)) {
				Part_Order__c newPartOrder = new Part_Order__c(
					Quantity__c = newPartInv.Recommended_Quantity__c - newPartInv.Quantity__c,
					Part_Inventory__c = newPartInv.Id,
					Name = 'Generated Order'
				);
				partOrdersToUpsert.add(newPartOrder);	
			}
		}

		upsert partOrdersToUpsert;
	}

}