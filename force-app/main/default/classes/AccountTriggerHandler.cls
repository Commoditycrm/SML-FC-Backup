/**
 * @author 		Amanda Bodnovits, RadialSpark
 * @date 		2/8/18
 * @description Handler for AccountTrigger
 */
public without sharing class AccountTriggerHandler extends TriggerHandler {
    // Constants
    @TestVisible private static String NULL_EXTERNAL_LOCATION_ID_ERROR = 'Location and carrier accounts must have an External Location ID.';
    @TestVisible private static String DUPLICATE_EXTERNAL_LOCATION_ID_ERROR = 'An account record with the same External Location ID already exists for this account\'s Parent Account.';
    @TestVisible private static String NULL_LOCATION_TYPE_ERROR = 'Location Customer accounts must have a Location Type.';

    // Properties
    @TestVisible private List<Account> triggerNew;
	@TestVisible private Map<Id, Account> oldMap;
    
    private List<Account> locationAccts;
    private List<Account> carrierAccts;
    private List<Account> locationAndCarrierAccts;
    
	/**
     * @description Standard constructor -- sets class variables
     * @param 		Records wrapped trigger context data structures
     */
    public AccountTriggerHandler(TriggerRecordWrapper records) {
        super(records);
		triggerNew = (List<Account>)records.getTriggerNew();
		oldMap = (Map<Id, Account>)records.getOldMap();
        
        locationAccts = new List<Account>();
        carrierAccts = new List<Account>();
        locationAndCarrierAccts = new List<Account>();
    }

    public override void doBeforeInsert() {
        populateAccountSets();
        preventNullLocationTypes();
        setInventoryLastUpdated(false);
	}
    
    public override void doBeforeUpdate() {
        populateAccountSets();
        preventNullLocationTypes();
        validateExternalIds(true);
        setInventoryLastUpdated(true);
    }
    
    /**
     * @description	Populates Account sets that are separated by record type
     */
    private void populateAccountSets() {
        for (Account acct : this.triggerNew) {
           /* if (acct.RecordTypeId == AccountServices.LOCATION_RECORD_TYPE_ID) {
                locationAccts.add(acct);
                locationAndCarrierAccts.add(acct);
            }
            else if (acct.RecordTypeId == AccountServices.CARRIER_RECORD_TYPE_ID) {
                carrierAccts.add(acct);
                locationAndCarrierAccts.add(acct);
            }*/
            carrierAccts.add(acct);
            locationAndCarrierAccts.add(acct);
            locationAccts.add(acct);
        }
    }
    
    private void validateExternalIds(Boolean isUpdate) {
        Set<Id> parentAcctIds = new Set<Id>();
        List<String> parentIdLocationIdList = new List<String>();
        List<Account> acctsToValidate = new List<Account>();
        
        // Validate only the accounts that have changes to External Location ID
        for (Account acct : locationAndCarrierAccts) {
        //for (Account acct: locationAccts) {
			// Skip the accounts with no change to External Location ID and Parent ID
            if (isUpdate && 
                (acct.External_Location_Id__c == oldMap.get(acct.Id).External_Location_Id__c) &&
                (acct.ParentId == oldMap.get(acct.Id).ParentId)) {
            	continue;
            }

            // Make sure there are no duplicates in the incoming records
            String parentIdLocationId = String.valueOf(acct.ParentId) + String.valueOf(acct.External_Location_Id__c);
            parentAcctIds.add(acct.ParentId);
            parentIdLocationIdList.add(acct.ParentId);
            acctsToValidate.add(acct);

            // If the External Location ID is already being added for a parent account, throw an error
            if (parentIdLocationIdList.contains(parentIdLocationId)) { 
                //acct.AddError(DUPLICATE_EXTERNAL_LOCATION_ID_ERROR);
            }
            // Otherwise add it to the list for validation of remaining iterations
            else {
                parentIdLocationIdList.add(parentIdLocationId);
            }      
        }
        
        // Query for all old External Location IDs for the parent accounts
        List<Account> existingAccts = [
            SELECT 
            	External_Location_Id__c, 
            	ParentId
            FROM Account
            WHERE ParentId IN :parentAcctIds
        ];
        
        // Map parent account Id to list of existing External Location IDs for comparing
        parentIdLocationIdList = new List<String>();
        for (Account acct : existingAccts) {
            String parentIdLocationId = String.valueof(acct.ParentId) + String.valueOf(acct.External_Location_Id__c);
            //parentIdLocationIdSet.add(parentIdLocationId);
            parentIdLocationIdList.add(parentIdLocationId);
        }
        
        // Loop through all accounts to validate and check against existing External Location IDs for the same parent account
        for (Account acct : acctsToValidate) {
            String parentIdLocationId = String.valueof(acct.ParentId) + String.valueOf(acct.External_Location_Id__c);
            if (acct.ParentId != null && parentIdLocationIdList.contains(parentIdLocationId)) {
                //acct.addError(DUPLICATE_EXTERNAL_LOCATION_ID_ERROR);
            }
        }
        
    }
    
    private void preventNullLocationTypes() {
        for (Account acct : locationAccts) {
            if (acct.Location_Type__c == null && acct.Type == 'Customer') {
                //acct.addError(NULL_LOCATION_TYPE_ERROR);
            }
        }
    }
    
    private void setInventoryLastUpdated(Boolean isUpdate) {
        for (Account acct : locationAccts) {
            // Skip the accounts with no change to Current Inventory
            if (isUpdate && acct.Current_Inventory__c == oldMap.get(acct.Id).Current_Inventory__c) {
            	continue;
            }
            // Set inventory last updated to today
            acct.Inventory_Last_Updated__c = Date.today();
        }
    }
}