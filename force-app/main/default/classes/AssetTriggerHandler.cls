/**
 * @author RadialSpark, Amanda Bodnovits
 * @date 02/03/18
 * @description Asset Trigger Handler
 * @history
 * 		11/21/2018 | Bradley Wong | Added updateAssetCountOnRelatedAccount process
 * 		11/27/2018 | Jeffrey Underdown | Moved all location assignment to AssetEventProcessor
 * 		11/28/2018 | Jeffrey Underdown | Added updateAccessPointType process
 */
public without sharing class AssetTriggerHandler extends TriggerHandler {
	public static final String PALLET_STATIONARY = 'Stationary';
	public static final String PALLET_READY = 'Ready for Pickup';
	public static final String PALLET_TRANSIT = 'In Transit';
	public static final String TRANSIT_LOCATION_ERROR = 'A pallet in Transit cannot have a current location set';
	public static final String NO_ACCOUNT_FOUND = 'An Account cannot have a status of "Stationary" or "Ready for Pickup" '+ 
												  'if it\'s location coordinates are not within it\'s current location\'s vicinity';
	public static final String INVALID_LOCATION = 'Invalid location coordinates';
	public static final String PALLET_OUT_OF_VICINITY = 'Pallet coordinates are out of the vicinity of the current location';

	@TestVisible private List<Asset> triggerNew;
	@TestVisible private Map<Id, Asset> oldMap;
	@TestVisible private Map<Id, Asset> newMap;

    /**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
    public AssetTriggerHandler(TriggerRecordWrapper records) {
        super(records);
		triggerNew = (List<Asset>)records.getTriggerNew();
		newMap = (Map<Id, Asset>)records.getNewMap();
		oldMap = (Map<Id, Asset>)records.getOldMap();
    }
	

    public override void doBeforeInsert() {
        setIdtoName();
        updateAccessPointType();
	}

    public override void doBeforeUpdate() {
        setIdtoName();
        updateAccessPointType();
    }

	public override void doAfterInsert() {
		updateAssetCountOnRelatedAccount();
	}

	public override void doAfterUpdate() {
		updateAssetCountOnRelatedAccount();		
	}

	public override void doAfterDelete() {
		updateAssetCountOnRelatedAccount();		
	}

	/**
     * @description Set the Asset Name to the Device Id
     */
	@TestVisible
	private void setIdtoName() {
		for(Asset asst : triggerNew) {
			if(String.isBlank(asst.Name)) {
				asst.Name = asst.Device_Id__c;
			}
		}
	}
    
    @TestVisible
    private void updateAccessPointType() {
        Set<Id> accessPointIds = new Set<Id>();
        for(Asset asst : triggerNew) {
            if (asst.Access_Point__c != null) {
				accessPointIds.add(asst.Access_Point__c);                
            }
		}
        if (!accessPointIds.isEmpty()) {
            Map<Id, Asset> accessPointMap = new Map<Id, Asset>([
                SELECT
                    Id,
                    Access_Point_Type__c
                FROM Asset
                WHERE Id IN :accessPointIds
            ]);
            for(Asset asst : triggerNew) {
                if(asst.Access_Point__c != null && !asst.Is_Access_Point__c) {
                    asst.Access_Point_Type__c = accessPointMap.get(asst.Access_Point__c).Access_Point_Type__c;
                }
            }
        }
    }

	/**
	 * @description Finds the related Account and updates the field Account.IoT_Asset_Count__c
	 */
	private void updateAssetCountOnRelatedAccount() {
		//collect account ids for accounts whose iot asset counts should be updated
		Set<Id> accIdsToUpdate = new Set<Id>();
		//to handle cases: isInsert ==> oldMap == null; isDelete ==> newMap == null
		Map<Id, Asset> assetMap = newMap != null ? newMap : oldMap;
		//loop through assets in the trigger
		for (Id assetId : assetMap.keySet()) {
			//get the old and new Current_Location__c ids
			Id oldAccountId = oldMap != null ? oldMap.get(assetId).Current_Location__c : null;
			Id newAccountId = newMap != null ? newMap.get(assetId).Current_Location__c : null;
			//if the Current_Location_Ids have changed ==> send to collection
			if (oldAccountId != newAccountId) {
				if (oldAccountId != null) accIdsToUpdate.add(oldAccountId);
				if (newAccountId != null) accIdsToUpdate.add(newAccountId);
			}
		}
		//quantify the number of assets related to each account
		List<Account> updatedAccounts = queryAndUpdateRelatedAccount(accIdsToUpdate);
		//update accounts
		update updatedAccounts;
	}

	/**
	 * @description Helper method for updateAssetCountOnRelatedAccount(); queries for Asset count for specific accounts
	 *  and updates the field Account.IoT_Asset_Count__c
	 */
	private List<Account> queryAndUpdateRelatedAccount(Set<Id> accIds) {
		//query & count the number of assets per relevant Current_Location_Id
		Map<Id, AggregateResult> accAggregate = new Map<Id, AggregateResult>([
			SELECT
				Current_Location__c Id, 
				COUNT(Id) assetCount
			FROM Asset
			WHERE Current_Location__c IN :accIds
            AND Is_Access_Point__c != true
			GROUP BY Current_Location__c
		]);

		//collect accounts with updated IoT_Asset_Count__c values
		List<Account> updatedAccounts = new List<Account>();
		//loop through all the updated account ids
		for(Id accId : accIds) {
			//set the IoT_Asset_Count__c values
			updatedAccounts.add(
				new Account(
					Id = accId,
					IoT_Asset_Count__c = accAggregate.containsKey(accId) ? (Decimal)accAggregate.get(accId).get('assetCount') : 0
				)
			);
		}
		//return the updated accounts
		return updatedAccounts;
	}
}