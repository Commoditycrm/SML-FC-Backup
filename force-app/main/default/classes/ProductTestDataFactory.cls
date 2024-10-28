@isTest
public class ProductTestDataFactory {
	private static Id palletTypeId;
	private static Id repairPartTypeId;
	
	public static Product2 createProduct(
		String name,
		String productRecordTypeName,
		Boolean isInsert
	) {
		
		Product2 product = new Product2(
			Name = name,
			RecordTypeId = getProductRecordTypeId(productRecordTypeName)
		);

		if (isInsert) {
			insert product;
		}
		return product;
	}

	public static List<Product2> createRepairPartProducts(
		String name,
		String productRecordTypeName,
		Integer numProducts,
		Boolean isInsert
	) {
		List<Product2> productList = new List<Product2>();
		for(Integer i = 0; i < numProducts; i++) {

			Product2 product = new Product2(
				Name = name + Math.random(),
				RecordTypeId = getRepairPartRecordTypeId()
			);
			productList.add(product);
		}
		
		if(isInsert) {
			insert productList;
		}
		return productList;

	}

	public static List<Product2> createPalletProducts(
		String name,
		String productRecordTypeName,
		Integer numProducts,
		Boolean isInsert
	) {
		List<Product2> productList = new List<Product2>();
		for(Integer i = 0; i < numProducts; i++) {

			Product2 product = new Product2(
				Name = name + Math.random(),
				RecordTypeId = getPalletRecordTypeId()
			);
			productList.add(product);
		}
		
		if(isInsert) {
			insert productList;
		}
		return productList;

	}

	public static Set<Id> getProductIds(List<Product2> products) {
		Set<Id> prodIds = new Set<Id>();

		for (Product2 prod : products) {
			prodIds.add(prod.Id);
		}
		return prodIds;
	}

	private static Id getProductRecordTypeId(String devName) {
		
		RecordType productRecordType = [
			SELECT Id, DeveloperName 
			FROM RecordType 
			WHERE DeveloperName =: devName
			AND sobjecttype = 'Product2'
			LIMIT 1
		];

		return productRecordType.Id;
	}

	private static Id getPalletRecordTypeId() {
		if(palletTypeId == null) {
			RecordType palletRecordType = [
				SELECT Id, DeveloperName 
				FROM RecordType 
				WHERE DeveloperName = 'Pallet'
				AND sobjecttype = 'Product2'
				LIMIT 1
			];
			palletTypeId = palletRecordType.Id;
		}
		return palletTypeId;
	}

	private static Id getRepairPartRecordTypeId() {
		if(repairPartTypeId == null) {
			RecordType palletRecordType = [
				SELECT Id, DeveloperName 
				FROM RecordType 
				WHERE DeveloperName = 'Repair_Part'
				AND sobjecttype = 'Product2'
				LIMIT 1
			];
			repairPartTypeId = palletRecordType.Id;
		}
		return repairPartTypeId;
	}
}