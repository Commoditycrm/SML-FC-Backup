@isTest
private class updateCurrentLocationAddress_Test {
    
    @isTest
    static void test_updateAssetddress() {
        // Insert test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Insert test Asset
        Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            Device_Id__c = 'device123',
            Temporary_Latitude__c = 32.7767,
            Temporary_Longitude__c = -96.7970
        );
        insert asset;

        // Insert related Asset_History_custom__c
        Asset_History_custom__c assetHistory = new Asset_History_custom__c(
       
            Asset__c = asset.Id,
            Location__c = 'In Transit',
            Still_in_this_Location__c = true
        );
        insert assetHistory;

        Test.startTest();
        updateCurrentLocationAddress.updateAssetddress(new List<Asset>{asset});
        Test.stopTest();

        
    }
    
    @isTest
    static void test_updateACHAddress() {
        // Insert main Account
        List<Nested_Geofence__mdt> nestedGeofence = [select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,
                                                         Current_Location_Id__c from Nested_Geofence__mdt ];
                
        Account acc = new Account(
            Name = 'Main Account',
            ShippingLatitude = 32.7767,
            ShippingLongitude = -96.7970,
            GeoFence_Radius_in_Miles__c = 5
        );
        insert acc;

        // Insert related Account
        Account relatedAcc = new Account(Name = 'Related Account');
        insert relatedAcc;

        // Insert Related Customer mapping
        Related_Customer__c rel = new Related_Customer__c(
            Source_Account__c = acc.Id,
            Related_To__c = relatedAcc.Id
        );
        insert rel;

        // Insert Asset linked to main account
        Asset asset = new Asset(
            Name = 'Test Asset',AccountId=acc.Id
        );
        insert asset;

        // Insert Asset History
        Asset_History_custom__c assetHistory = new Asset_History_custom__c(
            Asset__c = asset.Id,
            Latitude__c = 32.7767,
            Longitude__c = -96.7970,
            Current_Location_Address__c ='test Address'
        );
        insert assetHistory;
        assetHistory.Current_Location_Address__c=null;
        update assetHistory;
		List<Asset_History_custom__c> ahclist = [select id,Asset__c,Asset__r.AccountId,Latitude__c,Longitude__c,Current_Location_Address__c from Asset_History_custom__c where id=:assetHistory.id];
        Test.startTest();
        updateCurrentLocationAddress.updateACHAddress(ahclist);
        assetHistory.Current_Location_Address__c=null;
        update assetHistory;
        asset.AccountId = nestedGeofence[0].Current_Location_Id__c;
        update asset;
        List<Asset_History_custom__c> ahclist1 = [select id,Asset__c,Asset__r.AccountId,Latitude__c,Longitude__c,Current_Location_Address__c from Asset_History_custom__c where id=:assetHistory.id];

        updateCurrentLocationAddress.updateACHAddress(ahclist1);
        Test.stopTest();

        //assetHistory = [SELECT Current_Location_Address__c, location__c FROM Asset_History_custom__c WHERE Id = :assetHistory.Id];
        ///System.assertNotEquals(null, assetHistory);
    }


}