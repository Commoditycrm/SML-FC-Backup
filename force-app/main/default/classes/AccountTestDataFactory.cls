@isTest
public class AccountTestDataFactory {
    public static Account createParentAccount(
		String name,
		Boolean isInsert
	){
		Account testParentAccount = new Account(
			Name = name,
            External_Location_Id__c = 'TestID',
            //As a part of account restructuring requirement
			//RecordTypeId = getAccountRecordTypeId('Corporate'), 
            Type = 'Other'
		);

		if (isInsert) {
			insert testParentAccount;
		}
		return testParentAccount;
	}
    
    public static Account createParentAccount(
		String name,
        String assetGroupId,
		Boolean isInsert
	){
		Account testParentAccount = new Account(
			Name = name,
            External_Location_Id__c = 'TestID',
            Asset_Group_Id__c = 'assetGroupId',
            //As a part of account restructuring requirement
			//RecordTypeId = getAccountRecordTypeId('Corporate'), 
            Type = 'Other'
		);

		if (isInsert) {
			insert testParentAccount;
		}
		return testParentAccount;
	}

	public static Account createAccount(
		String name,
		String accountRecordType,
		String street,
		String city,
		String state,
		String postalCode,
		Decimal latitude,
		Decimal longitude,
		Id parentId,
		String locationType,
		Boolean isInsert, 
        String externalLocationId
	) {
		
		Account testAccount = new Account(
			Name = name,
            //As a part of account restructuring requirement
			//RecordTypeId = getAccountRecordTypeId(accountRecordType),
			ShippingStreet = street,
			ShippingCity = city,
			ShippingState = state,
			ShippingPostalCode = postalCode,
			ShippingLatitude = latitude,
			ShippingLongitude = longitude,
			ParentId = parentId,
			Location_Type__c = locationType,
			External_Location_Id__c	= externalLocationId, 
            Type = 'Customer'
		);

		if (isInsert) {
			insert testAccount;
		}

		return testAccount;
	}
    
    public static Account createAccount(
		String name,
		String accountRecordType,
		String street,
		String city,
		String state,
		String postalCode,
		Decimal latitude,
		Decimal longitude,
		Id parentId,
		String locationType,
		Boolean isInsert, 
        String externalLocationId,
        String assetGroupId
	) {
		
		Account testAccount = new Account(
			Name = name,
            //As a part of account restructuring requirement
			//RecordTypeId = getAccountRecordTypeId(accountRecordType),
			ShippingStreet = street,
			ShippingCity = city,
			ShippingState = state,
			ShippingPostalCode = postalCode,
			ShippingLatitude = latitude,
			ShippingLongitude = longitude,
			ParentId = parentId,
			Location_Type__c = locationType,
			External_Location_Id__c	= externalLocationId,
            Asset_Group_Id__c = assetGroupId,
            Type = 'Customer'
		);

		if (isInsert) {
			insert testAccount;
		}

		return testAccount;
	}
    
    public static Account createChildAccount(Id parentId, Boolean isInsert) {
        //get picklist option 'Source' for Account.Location_Type__c
       	String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        
        Account acct = new Account();
        acct.Name = 'Test Child';
        //As a part of account restructuring requirement
        //acct.RecordTypeId = getAccountRecordTypeId('Location');
        acct.ParentId = parentId;
        acct.External_Location_Id__c = 'Test Location ID';
        acct.Location_Type__c = sourceLabel;
        acct.Type = 'Customer';
        acct.ShippingStreet = '111 Street';
        acct.ShippingCity = 'City';
        acct.ShippingState = 'AZ';
        acct.ShippingPostalCode = '11111';
        
        if (isInsert) {
            insert acct;
        }
        return acct;
    }

	private static Id getAccountRecordTypeId(String devName) {
		
		RecordType accountRecordType = [
			SELECT Id, DeveloperName 
			FROM RecordType 
			WHERE DeveloperName =: devName
			AND sobjecttype = 'Account'
			LIMIT 1
		];

		return accountRecordType.Id; 
	}
}