/**
 * @class AssetEventProcessor
 * @author Radial Spark | Jeffrey Underdown | junderdown@radialspark.com\
 * @description processes Asset IoT events
 * @history
 * 
 */
public class AssetEventProcessor {
    public final String POSITION_SOURCE_GPS = 'GPS';
    public final String POSITION_SOURCE_AP = 'AP';
    public final String POSITION_SOURCE_NONE = 'NONE';
    public final String UNKNOWN_ASSET_PRODUCT = 'Unknown Tag';
    public final String ACCESS_POINT_PRODUCT = 'Access Point';

    // list of events to process
    private List<Pallet_Location_Event__e> eventList;
    // ids to query
    private Set<String> assetGroupIds;
    private Set<String> accessPointDeviceIds;
    // map of device ids to events
    private Map<String, Pallet_Location_Event__e> deviceIdsToEventsMap;
    // list of existing assets, access points
    private List<Asset> existingAssets;
    // map of device id from event to exsiting assets
    private Map<String, Asset> existingDeviceIdToAssetMap;
    // list of accounts
    private List<Account> accounts;
    // map of asset group ids from events to accounts
    private Map<String, Id> assetGroupIdsToAccountIds;
    // map of asset product types to products
    private Map<String, Product2> assetProductTypeToProduct;
    // map of assets to later update access point ids on
    // after new access points are inserted.
    private Map<Asset, Asset> assetsToNewAccessPointsMap;
    // map of airfinder area ids to sf location account ids
    private Map<String, Id> areaIdsToAccountIds;
    private Set<String> areaIds;
    // DML Lists
    private List<Asset> newAccessPointsToInsert;
    private List<Asset> assetsToUpsert;

    /**
     * @description constructor
     * @param {List<Pallet_Location_Event__e>} events
     */
    public AssetEventProcessor(List<Pallet_Location_Event__e> events) {
        this.eventList = events;
        this.newAccessPointsToInsert = new List<Asset>();
        this.assetsToUpsert = new List<Asset>();
        this.assetsToNewAccessPointsMap = new Map<Asset, Asset>();
        this.areaIdsToAccountIds = new Map<String, Id>();
    }

    /**
     * @description processes all events
     */
    public void process() {
        this.collectIdsAndGenerateEventMap();
        this.queryForAccounts();
        this.queryForExistingDeviceIds();
        this.queryForProducts();
        
        boolean execute = false;
        datetime dt = system.now().adddays(-30);
        // generate a list of new assets to upsert
        for (Pallet_Location_Event__e palEvent : this.deviceIdsToEventsMap.values()) {
           system.debug('before For Loop--->');
            // This if condition is handle to the error response which contains Invalid date (01/01/1970)
            if(palEvent.Last_Connected__c > dt){
                system.debug('In For Loop--->');
                Asset thisAsset = this.getDeviceAsset(palEvent);
                thisAsset = this.updateAssetFields(thisAsset, palEvent);
                thisAsset = this.updateAssetPosition(thisAsset, palEvent);
                thisAsset = this.updateAssetProduct(thisAsset, palEvent);
                // add the asset to the list of assets to upsert
                this.assetsToUpsert.add(thisAsset);
                execute = true;
            }
        }
        if(execute){
        	this.insertNewAccessPoints();
            this.updateAssetsWithNewAccessPointIds();
            this.upsertAssets();    
        }
        
    }

    /**
     * @description collects all Ids and maps them to events
     */
    private void collectIdsAndGenerateEventMap() {
        // collect lists of Ids and generate map of device ids to events
        this.assetGroupIds = new Set<String>();
        this.areaIds = new Set<String>();
        this.accessPointDeviceIds = new Set<String>();
        this.deviceIdsToEventsMap = new Map<String, Pallet_Location_Event__e>();
        for (Pallet_Location_Event__e palEvent : this.eventList) {

            // add all asset group ids
            if (!String.isBlank(palEvent.Asset_Group_Id__c)) {
                this.assetGroupIds.add(palEvent.Asset_Group_Id__c);
            }

            // add all asset group ids
            if (!String.isBlank(palEvent.Area_Id__c)) {
                this.areaIds.add(palEvent.Area_Id__c);
            }

            // add all access point device ids
            if (!String.isBlank(palEvent.Access_Point_Id__c)) {
                this.accessPointDeviceIds.add(palEvent.Access_Point_Id__c);
            }

            // map events by their device ids
            if(!String.isBlank(palEvent.Device_Id__c)) {
                this.deviceIdsToEventsMap.put(palEvent.Device_Id__c, palEvent);
            }
        }
    }

    /**
     * @description queries for accounts
     */
    private void queryForAccounts() {
        // query for all accounts with matching asset group ids
        this.accounts = [
            SELECT
                Id,
                Asset_Group_Id__c,
                Area_Id__c
            FROM Account
            WHERE Asset_Group_Id__c IN :this.assetGroupIds
            OR Area_Id__c IN :this.areaIds
        ];

        // create a map of all asset group ids to account ids
        this.assetGroupIdsToAccountIds = new Map<String, Id>();
        for (Account a : accounts) {
            if (this.assetGroupIds.contains(a.Asset_Group_Id__c)) {
                this.assetGroupIdsToAccountIds.put(a.Asset_Group_Id__c, a.Id);
            }
            if (this.areaIds.contains(a.Area_Id__c)) {
              this.areaIdsToAccountIds.put(a.Area_Id__c, a.Id);
            }
        }
    }

    /**
     * @description queries for exisint device id and generates map of device Ids
     * to Assets
     */
    private void queryForExistingDeviceIds() {
        // query a list to check for existing devices with matching device ids
        Set<String> allDeviceIds = new Set<String>(this.deviceIdsToEventsMap.keySet());
        allDeviceIds.addAll(this.accessPointDeviceIds);
        this.existingAssets = new List<Asset>();
        if (!allDeviceIds.isEmpty()) {
            this.existingAssets = [
                SELECT
                    Id,
                    AccountId,
                    Device_Id__c,
                    Access_Point__c,
                    Last_Access_Point__c,
                    Is_Access_Point__c,
                    Current_Location__c,
                    Last_Known_Location__c,
                    Temperature__c,
                    Temporary_Latitude__c,
                    Temporary_Longitude__c,
                    Pallet_Type__r.Airfinder_Name__c
                FROM
                    Asset
                WHERE Device_Id__c IN :allDeviceIds
            ];
        }

        //  Create a map of device id to existing device asset id
        this.existingDeviceIdToAssetMap = new Map<String, Asset>();
        for (Asset asst : existingAssets) {
            this.existingDeviceIdToAssetMap.put(asst.Device_Id__c.toLowerCase(), asst);
        }
    }

    /**
     * @description queries for Product2s for Assets
     */
    private void queryForProducts() {
        // query for products to relate to new assets
        List<Product2> assetProductList;
        try {
            assetProductList = [
                SELECT
                    Id,
                    Airfinder_Name__c,
                    Threshold_For_Low_Battery__c
                FROM
                    Product2
            ];
        } catch (System.QueryException e) {
            throw new IotEventException(e.getMessage());
        }

        if (assetProductList.isEmpty()) {
            throw new IotEventException('Asset Product List Empty');
        }

        // build map of all products to asset event product names
        this.assetProductTypeToProduct = new Map<String, Product2>();
        for (Product2 p : assetProductList) {
            this.assetProductTypeToProduct.put(p.Airfinder_Name__c, p);
        }
    }

    /**
     * @description gets the access point for the event
     * @param {Pallet_Location_Event__e} palEvent the event
     * @return {Asset} the access point
     */
    private Asset getAccessPoint(Pallet_Location_Event__e palEvent) {
        Asset ap;
        if (
            palEvent.Access_Point_Id__c != null
        ) {
            ap = this.existingDeviceIdToAssetMap.get(palEvent.Access_Point_Id__c.toLowerCase());
            if (ap == null) {
                ap = new Asset(
                    Name = palEvent.Zone_Name__c,
                    AccountId = this.assetGroupIdsToAccountIds.get(palEvent.Asset_Group_Id__c),
                    Device_Id__c = palEvent.Access_Point_Id__c,
                    Is_Access_Point__c = true,
                    Product2Id = this.assetProductTypeToProduct.get(ACCESS_POINT_PRODUCT).Id,
                    Current_Location__c = this.areaIdsToAccountIds.get(palEvent.Area_Id__c)
                    // TODO set Temporary_Latitude__c and Temporary_Longitude__c
            	);
            	this.newAccessPointsToInsert.add(ap);
            }
        }
        return ap;
    }

    /**
     * @description gets the asset record for the event
     * @param {Pallet_Location_Event__e} palEvent the event
     * @return {Asset} the asset record
     */
    private Asset getDeviceAsset(Pallet_Location_Event__e palEvent) {
        Asset deviceAsset = this.existingDeviceIdToAssetMap.get(palEvent.Device_Id__c.toLowerCase());
        // check if asset exists in system already
        if (deviceAsset == null) {
            // if not generate a new asset record for it.
            deviceAsset = new Asset(
                Name = palEvent.Device_Id__c,
                Device_Id__c = palEvent.Device_Id__c.toLowerCase()
            );
        }
        return deviceAsset;
    }

    /**
     * @description updates field information on Asset with event information
     * @param {Asset} assetToUpdate the asset to update
     * @param {Pallet_Location_Event__e} palEvent the event
     * @return {Asset} the updated Asset
     */
    private Asset updateAssetFields(Asset assetToUpdate, Pallet_Location_Event__e palEvent) {
        // update asset fields
        // temperature
        if (palEvent.Temperature__c != null) {
            assetToUpdate.Temperature__c = palEvent.Temperature__c;
        }

        // humidity
        if (palEvent.Humidity__c != null) {
            assetToUpdate.Humidity__c = palEvent.Humidity__c;
        }

        // shock
        if (palEvent.Shock_Threshold__c != null) {
            assetToUpdate.Shock_Threshold__c = palEvent.Shock_Threshold__c;
        }
        if (palEvent.Shock_Count__c != null) {
            assetToUpdate.Shock_Count__c = palEvent.Shock_Count__c;
        }
        if (palEvent.Shock_Max__c != null) {
            assetToUpdate.Shock_Max__c = palEvent.Shock_Max__c;
        }
        if (palEvent.Shock_Max_Time__c != null) {
            assetToUpdate.Shock_Max_Time__c = palEvent.Shock_Max_Time__c;
        }

        // field1
        if (palEvent.Field1__c != null) {
            assetToUpdate.Field1__c = palEvent.Field1__c;
       }

        // field2
        if (palEvent.Field2__c != null) {
            assetToUpdate.Field2__c = palEvent.Field2__c;
        }

        //set battery voltage and battery low status on asset
        if (palEvent.Battery_Level__c != null) {
            Decimal batteryLevel = palEvent.Battery_Level__c;
            assetToUpdate.Battery_Voltage__c = batteryLevel;

            if (assetToUpdate.Pallet_Type__r.Airfinder_Name__c != null) {
                Product2 thisProduct = this.assetProductTypeToProduct.get(assetToUpdate.Pallet_Type__r.Airfinder_Name__c);

                if (thisProduct != null) assetToUpdate.Battery_Low__c = batteryLevel <= thisProduct.Threshold_For_Low_Battery__c;
            }
        }

        // account
        Id acctId = assetGroupIdsToAccountIds.get(palEvent.Asset_Group_Id__c);
        if (assetToUpdate.AccountId == null || acctId != null) {
            assetToUpdate.AccountId = acctId;
        }

        // last connected time
        //assetToUpdate.Last_Connected__c = palEvent.CreatedDate;
		system.debug('last Connected before update----'+palEvent.Last_Connected__c); 
		if(palEvent.Last_Connected__c != null){
				assetToUpdate.Last_Connected__c = palEvent.Last_Connected__c;
		}
        system.debug('BeforeMsgtype---');
        if(palEvent.Msg_Type__c != null){
            integer msgtype = integer.valueof(palEvent.Msg_Type__c);
            system.debug('integer'+ msgtype);               
            for(Message_Type__c msg : [select id,name,Description__c from Message_Type__c where name = : string.valueof(msgtype)]){
            	system.debug('msg---'+ msg);
                assetToUpdate.Message_Types__c = msg.id;    
            }
			
		}
		system.debug('lastConnectTime'+ assetToUpdate.Last_Connected__c);
        return assetToUpdate;
    }

    /**
    * @description updates position information on Asset with event
    * @param {Asset} assetToUpdate the asset to update
    * @param {Pallet_Location_Event__e} palEvent the event
    * @return {Asset} the updated Asset
    */
    private Asset updateAssetPosition(Asset assetToUpdate, Pallet_Location_Event__e palEvent) {
        
        if (palEvent.Position_Source__c == POSITION_SOURCE_NONE) {
          return assetToUpdate;
        }

        // check if the access point asset exists in the system.
        Asset accessPoint = this.getAccessPoint(palEvent);

        if (palEvent.Position_Source__c == POSITION_SOURCE_GPS) {
            
            system.debug('Latlng---'+ palEvent.Latitude__c + '-'+palEvent.Longitude__c);
            // latitude
            if (palEvent.Latitude__c != null) {
                assetToUpdate.Temporary_Latitude__c = palEvent.Latitude__c;
            }

            // longitude
            if (palEvent.Longitude__c != null) {
                assetToUpdate.Temporary_Longitude__c = palEvent.Longitude__c;
            }
        } else {
            //assetToUpdate.Temporary_Longitude__c = assetToUpdate.Temporary_Latitude__c = null;
        }

        if (palEvent.Position_Source__c == POSITION_SOURCE_AP && accessPoint != null) {
            // in network
            system.debug('Accesspoint--'+ accessPoint );
            assetToUpdate.Temporary_Longitude__c = assetToUpdate.Temporary_Latitude__c = null;
            if (assetToUpdate.Access_Point__c != accessPoint.Id) {
                assetToUpdate.Last_Access_Point__c = assetToUpdate.Access_Point__c;
                if (accessPoint.Id != null) {
                  assetToUpdate.Access_Point__c = accessPoint.Id;
                } else { // update the id on asset after the new access point is inserted and has an id
                  this.assetsToNewAccessPointsMap.put(assetToUpdate, accessPoint);
                }
            }
            system.debug('AssetLoc'+assetToUpdate.Current_Location__c);
            system.debug('AccessptLoc'+accessPoint.Current_Location__c);    
            // Added current location not equal to null condition in order to prevent update of null values in Asset's current location
            if (assetToUpdate.Current_Location__c != accessPoint.Current_Location__c && accessPoint.Current_Location__c != null ) {
                assetToUpdate.Last_Known_Location__c = assetToUpdate.Current_Location__c;
                assetToUpdate.Current_Location__c = accessPoint.Current_Location__c;
            }

            // copy over lat/long from access point if the asset is not reporting
            if (assetToUpdate.Temporary_Latitude__c == null || assetToUpdate.Temporary_Longitude__c == null) {
                assetToUpdate.Temporary_Latitude__c = accessPoint.Temporary_Latitude__c;
                assetToUpdate.Temporary_Longitude__c = accessPoint.Temporary_Longitude__c;
            }
        } else {
          // moved out of network or missing access point in SF org
          
            if (assetToUpdate.Access_Point__c != null) {
                assetToUpdate.Last_Access_Point__c = assetToUpdate.Access_Point__c;
                assetToUpdate.Access_Point__c = null;
            }

            if (assetToUpdate.Current_Location__c != null) {
                assetToUpdate.Last_Known_Location__c = assetToUpdate.Current_Location__c;
                //assetToUpdate.Current_Location__c = null;
            }
        }
        
        if (assetToUpdate.Access_Point__c == null && assetToUpdate.Is_Access_Point__c != true) {
            assetToUpdate.Access_Point_Type__c = null;
        }
        system.debug('Aseetupdate--'+ assetToUpdate );
        return assetToUpdate;
    }

    /**
     * @description updates product on Asset with event information
     * @param {Asset} assetToUpdate the asset to update
     * @param {Pallet_Location_Event__e} palEvent the event
     * @return {Asset} the updated Asset
     */
    private Asset updateAssetProduct(Asset assetToUpdate, Pallet_Location_Event__e palEvent) {
        // set asset product
        Product2 thisProduct = this.assetProductTypeToProduct.get(palEvent.Asset_Product__c);

        if (thisProduct != null) {
            assetToUpdate.Product2Id = thisProduct.Id;
        }
        else {
            assetToUpdate.Product2Id = this.assetProductTypeToProduct.get(UNKNOWN_ASSET_PRODUCT).Id;
        }
        return assetToUpdate;
    }

    /**
     * @description updates access point lookup id s on Assets whose access point
     * was not yet in the system and therefore did not yet ahve an Id
     */
    private void updateAssetsWithNewAccessPointIds() {
      for (Asset assetToUpdate : this.assetsToNewAccessPointsMap.keySet()) {
        assetToUpdate.Access_Point__c = this.assetsToNewAccessPointsMap.get(assetToUpdate).Id;
      }
    }

    /**
     * @description insert list of new access point assets
     */
    private void insertNewAccessPoints() {
      if (!this.newAccessPointsToInsert.isEmpty()) {
          insert this.newAccessPointsToInsert;
      }
    }

    /**
     * @description upsert list of assets with incoming events processed
     */
    private void upsertAssets() {
        System.debug('before upsert assetsToUpsert = ' + assetsToUpsert);
        if (!this.assetsToUpsert.isEmpty()) {
                upsert this.assetsToUpsert;
            System.debug([SELECT Id, Current_Location__c FROM Asset WHERE Id = :this.assetsToUpsert[0].Id]);
        }
        System.debug('after upsert assetsToUpsert = ' + assetsToUpsert);
    }
}