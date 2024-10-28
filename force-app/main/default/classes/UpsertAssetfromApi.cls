public class UpsertAssetfromApi {
    public final String POSITION_SOURCE_GPS = 'GPS';
    public final String POSITION_SOURCE_AP = 'AP';
    public final String POSITION_SOURCE_NONE = 'NONE';
    public final String UNKNOWN_ASSET_PRODUCT = 'Unknown Tag';
    public final String ACCESS_POINT_PRODUCT = 'Access Point';
    
    // list of events to process
    private List<Api_Response__c> eventList;
    // ids to query
    private Set<String> assetGroupIds;
    private Set<String> accessPointDeviceIds;
    // map of device ids to events
    private Map<String, Api_Response__c> deviceIdsToEventsMap;
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
    private Map<String, Id> msgtypeidMap;
    private Set<String> areaIds;
    // DML Lists
    private List<Asset> newAccessPointsToInsert;
    private List<Asset> assetsToUpsert;
    
    /**
    * @description constructor
    * @param {List<Pallet_Location_Event__e>} events
	*/
    public void AssetEventProcessor(List<Api_Response__c> response) {
        system.debug(response.size());
        this.eventList = response;
        this.newAccessPointsToInsert = new List<Asset>();
        this.assetsToUpsert = new List<Asset>();
        this.assetsToNewAccessPointsMap = new Map<Asset, Asset>();
        this.areaIdsToAccountIds = new Map<String, Id>();
        this.collectIdsAndGenerateEventMap();
        this.queryForAccounts();
        this.queryForExistingDeviceIds();
        this.queryForProducts();
        this.queryMessageType();
        list<Api_Response__c> updateApilist = new list<Api_Response__c>();
        boolean execute = false;
        datetime dt = system.now().adddays(-30);
        // generate a list of new assets to upsert
        for (Api_Response__c palEvent : this.deviceIdsToEventsMap.values()) {
            system.debug('before For Loop--->'+palEvent.Last_Connected__c);
            // This if condition is handle to the error response which contains Invalid date (01/01/1970)
            if(palEvent.Last_Connected__c > dt){
                system.debug('In For Loop--->');
                Asset thisAsset = this.getDeviceAsset(palEvent);
                if(thisAsset.Last_Connected__c == null || thisAsset.Last_Connected__c < palEvent.Last_Connected__c ){
                    system.debug('in UpdateIF--->');
                	thisAsset = this.updateAssetFields(thisAsset, palEvent);
                    thisAsset = this.updateAssetPosition(thisAsset, palEvent);
                    thisAsset = this.updateAssetProduct(thisAsset, palEvent);
                    // add the asset to the list of assets to upsert
                    this.assetsToUpsert.add(thisAsset);
                    execute = true;	    
                }else{
                	palEvent.Unprocessed_Response__c = true;   
                    updateApilist.add(palEvent);
                }
                
            }
        }
        system.debug('AssetlistSize'+assetsToUpsert.size());
        if(execute){
            system.debug('Execute--->');
            this.insertNewAccessPoints();
            this.updateAssetsWithNewAccessPointIds();
            this.upsertAssets();    
        }
        
        if(updateApilist.size()>0){
          	update updateApilist;  
        }
            
            
    }
    
    private void queryMessageType(){
    	
        msgtypeidMap = new map<string,id>();
        for(Message_Type__c msg : [select id,name,Description__c from Message_Type__c]){
        	msgtypeidMap.put(msg.name,msg.Id);    
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
        this.deviceIdsToEventsMap = new Map<String, Api_Response__c>();
        for (Api_Response__c palEvent : this.eventList) {
            
            // add all asset group ids
            if (!String.isBlank(palEvent.Asset_Group_Id__c)) {
                this.assetGroupIds.add(palEvent.Asset_Group_Id__c);
            }
            
            // add all asset group ids
            if (!String.isBlank(palEvent.Area_Id__c)) {
                this.areaIds.add(palEvent.Area_Id__c);
            }
            
            // add all access point device ids
            system.debug(palEvent.Access_Point_Id__c);
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
        system.debug(allDeviceIds);
        this.existingAssets = new List<Asset>();
        if (!allDeviceIds.isEmpty()) {
            this.existingAssets = [
                SELECT
                Id,
                AccountId,
                Device_Id__c,
                Last_Connected__c,
                Access_Point__c,
                Last_Access_Point__c,
                Is_Access_Point__c,
                Current_Location__c,
                Last_Known_Location__c,
                Temperature__c,
                Message_Count__c,
                Start_Time__c,
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
            system.debug(asst);
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
    private Asset getAccessPoint(Api_Response__c palEvent) {
        Asset ap;
        if (
            palEvent.Access_Point_Id__c != null
        ) {
            ap = this.existingDeviceIdToAssetMap.get(palEvent.Access_Point_Id__c.toLowerCase());
            system.debug('ap'+ap);
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
    private Asset getDeviceAsset(Api_Response__c palEvent) {
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
    private Asset updateAssetFields(Asset assetToUpdate, Api_Response__c palEvent) {
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
        // Update Message count from response
        if(palEvent.Message_Count__c != null){
           
        	assetToUpdate.Message_Count__c =  palEvent.Message_Count__c; 
        }
        if(palEvent.Start_Time__c != null){
           
        	assetToUpdate.Start_Time__c =  palEvent.Start_Time__c; 
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
            /*
            system.debug('integer'+ msgtype);               
            for(Message_Type__c msg : [select id,name,Description__c from Message_Type__c where name = : string.valueof(msgtype)]){
                system.debug('msg---'+ msg);
                    
            }*/
            integer msgtype = integer.valueof(palEvent.Msg_Type__c);
            if(msgtypeidMap.containsKey(string.valueof(msgtype))){
            	assetToUpdate.Message_Types__c = msgtypeidMap.get(string.valueof(msgtype));    
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
    private Asset updateAssetPosition(Asset assetToUpdate, Api_Response__c palEvent) {
        
        if (palEvent.Position_Source__c == POSITION_SOURCE_NONE) {
            return assetToUpdate;
        }
        
        // check if the access point asset exists in the system.
        Asset accessPoint = this.getAccessPoint(palEvent);
        system.debug(accessPoint);
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
                    system.debug('accessPoint.Id'+accessPoint.Id);
                assetToUpdate.Last_Access_Point__c = assetToUpdate.Access_Point__c;
                if (accessPoint.Id != null) {
                    system.debug('accessPoint.Id'+accessPoint.Id);
                    assetToUpdate.Access_Point__c = accessPoint.Id;
                } else { // update the id on asset after the new access point is inserted and has an id
                    system.debug('enter else');
                    this.assetsToNewAccessPointsMap.put(assetToUpdate, accessPoint);
                }
            }
            system.debug('AssetLoc'+assetToUpdate.Current_Location__c);
            system.debug('AccessptLoc'+accessPoint.Current_Location__c);    
            // Added current location not equal to null condition in order to prevent update of null values in Asset's current location
            
            if (assetToUpdate.Current_Location__c != accessPoint.Current_Location__c && accessPoint.Current_Location__c != null ) {
                assetToUpdate.Last_Known_Location__c = assetToUpdate.Current_Location__c;
                assetToUpdate.Current_Location__c = accessPoint.Current_Location__c;
                assetToUpdate.State_of_Pallet__c = 'In Network';
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
    private Asset updateAssetProduct(Asset assetToUpdate, Api_Response__c palEvent) {
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
    * @description insert list of new access point assets
    */
    private void insertNewAccessPoints() {
        system.debug('accesspointSize'+ newAccessPointsToInsert.size());
        if (!this.newAccessPointsToInsert.isEmpty()) {
            insert this.newAccessPointsToInsert;
        }
    }
    
     /**
    * @description updates access point lookup id s on Assets whose access point
    * was not yet in the system and therefore did not yet ahve an Id
    */
    private void updateAssetsWithNewAccessPointIds() {
        for (Asset assetToUpdate : this.assetsToNewAccessPointsMap.keySet()) {
            //system.debug('enters-->'+this.assetsToNewAccessPointsMap.get(assetToUpdate).Id);
            //if(this.assetsToNewAccessPointsMap.get(assetToUpdate).Id!=null){
            	assetToUpdate.Access_Point__c = this.assetsToNewAccessPointsMap.get(assetToUpdate).Id;
            //}
        }
    }
    
    /**
    * @description upsert list of assets with incoming events processed
    */
    private void upsertAssets() {
        System.debug(assetsToUpsert.size()+'-'+ 'before upsert assetsToUpsert = ' + assetsToUpsert);
        if (!this.assetsToUpsert.isEmpty()) {
            upsert this.assetsToUpsert;
            List<asset> assetList = new List<asset>();
            List<Api_Response__c> apiList = new List<Api_Response__c>();
            for(Api_Response__c apires : this.eventList){
                
                apires.UpdateResponseToAsset__c=true;
                apiList.add(apires);
                    
            }
            if(apiList.size()>0){
            update apiList;
        	}
            
           
        }
        System.debug('after upsert assetsToUpsert = ' + assetsToUpsert);
        system.debug(limits.getQueries()+'out of'+limits.getLimitQueries());
        system.debug(limits.getQueryRows()+'out of'+limits.getLimitQueryRows());    
        
    }
        
        
}