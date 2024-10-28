/**
 * @author 		RadialSpark, Amanda Bodnovits
 * @date 		02/03/18
 * @description Asset test data factory
 */
@isTest
public with sharing class AssetTestDataFactory {

	/**
     * @description Create multiple Assets
	 * @param  		Id of an Account (pallet's current location)
	 * @param  		Picklist value for State_of_Pallet__c
	 * @param  		Latitude of pallets location
	 * @param  		Number of pallets to create
	 * @return 		List<Asset>
     */
	public static List<Asset> createPalletList(
		Id accountId,
		String stateOfPallet,
		Decimal lat,
		Decimal lon,
		Id palletType,
		Integer numPallets
	){
		List<Asset> palletList = new List<Asset>();

		for(Integer i = 0; i < numPallets; i++) {
			
			Asset pallet = createPallet(
				accountId, stateOfPallet, lat,
				lon, null, null, null, null, palletType
			);

			palletList.add(pallet);
		}
		
		return palletList;
	}

	/**
     * @description Create multiple Assets
	 * @param  		Id of an Account (pallet's current location)
	 * @param  		Picklist value for State_of_Pallet__c
	 * @param  		Latitude of pallets location
	 * @param  		longitude of pallets location
	 * @param  		Id of an Account (pallet's last known location)
	 * @param  		Number indicating pallet's temperature
	 * @param  		DateTime of pallets last connection
	 * @param  		String of pallets unique device id
	 * @param  		Number of pallets to create
	 * @return 		List<Asset>
     */	
	public static List<Asset> createPalletList(
		ID accountId,
		String stateOfPallet,
		Decimal lat,
		Decimal lon,
		Id lastKnownLocation,
		Decimal temp,
		DateTime lastConnected,
		String deviceId,
		Id palletType,
		Integer numPallets
	){
		List<Asset> palletList = new List<Asset>();

		for(Integer i = 0; i < numPallets; i++) {
			
			Asset pallet = createPallet(
				accountId, stateOfPallet, lat,
				lon, lastKnownLocation, temp,
				lastConnected, palletType, deviceId
			);

			palletList.add(pallet);
		}
		
		return palletList;
	}

	/**
     * @description Create Assets
	 * @param  		Id of an Account (pallet's current location)
	 * @param  		Picklist value for State_of_Pallet__c
	 * @param  		Latitude of pallets location
	 * @param  		longitude of pallets location
	 * @param  		Id of an Account (pallet's last known location)
	 * @param  		Number indicating pallet's temperature
	 * @param  		DateTime of pallets last connection
	 * @param  		String of pallets unique device id
	 * @return 		Asset
     */
	public static Asset createPallet(
		ID accountId,
		String stateOfPallet,
		Decimal lat,
		Decimal lon,
		Id lastKnownLocation,
		Decimal temp,
		DateTime lastConnected,
		String deviceId,
		ID palletType
	) {
		// Quick fix because asset requires an account or contact
		Account dummyAccount = new Account(Name='dummyAcc', External_Location_Id__c	= 'fakeExternal', Type='Other');
		insert dummyAccount;

		Asset pallet = new Asset(
			Current_Location__c = accountId,
			State_of_Pallet__c = stateOfPallet,
			Temporary_Latitude__c = lat,
			Temporary_Longitude__c = lon,
			Last_Known_Location__c = lastKnownLocation,
			Temperature__c = temp,
			Last_Connected__c = lastConnected,
			Device_Id__c = deviceId,
			Product2Id = palletType,
			Name = 'Pallet',
			AccountId = dummyAccount.Id
		);
		return pallet;
	}

	/**
     * @description get a list of Ids for previously inserted pallets
	 * @param  		List<Asset>
	 * @return 		List<Id>
     */
	public static List<Id> getPalletIds(List<Asset> pallets){

		List<Id> palletIds = new List<Id>();
		for(Integer i = 0; i < pallets.size(); i++) {
			palletIds.add(pallets[i].Id);
		}
		return palletIds;
	}
}