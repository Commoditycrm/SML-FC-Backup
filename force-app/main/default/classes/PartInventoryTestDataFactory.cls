@isTest
public class PartInventoryTestDataFactory {

	public static Part_Inventory__c createPartInventory(
		Id partTypeId,
		Integer recommendedQuantity,
		Id accountId,
		Integer orderThreshold,
		Integer quantity,
		Boolean isInsert
	) {

		Part_Inventory__c partInventory = new Part_Inventory__c(
			Part_Type__c = partTypeId,
			Recommended_Quantity__c = recommendedQuantity,
			Account__c = accountId,
			Order_Threshold__c = orderThreshold,
			Quantity__c = quantity
		);

		if (isInsert) {
			insert partInventory;
		}
		return partInventory;
	}

	public static List<Part_Inventory__c> createPartInventories(
		Integer recommendedQuantity,
		Integer orderThreshold,
		Integer quantity,
		Set<Id> partTypeIds,
		Id accountId,
		Boolean isInsert
	) {
		List<Part_Inventory__c> partInventoryList = new List<Part_Inventory__c>(); 

		for (Id partType : partTypeIds) {
			
			Part_Inventory__c partInventory = new Part_Inventory__c(
				Recommended_Quantity__c = recommendedQuantity,
				Order_Threshold__c = orderThreshold,
				Quantity__c = quantity,
				Part_Type__c = partType,
				Account__c = accountId
			);

			partInventoryList.add(partInventory);
		}

		if (isInsert) {
			insert partInventoryList;
		}
		return partInventoryList;
	}
}