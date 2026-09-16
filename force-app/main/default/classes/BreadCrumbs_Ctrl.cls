public with sharing class BreadCrumbs_Ctrl {
    
    @AuraEnabled
    public static User getLanguage() {
        return [
            SELECT Id, Name, Latitude, Longitude, Profile.Name, LanguageLocaleKey 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
    }
    
    @AuraEnabled
    public static List<Asset_history_custom__c> asthis(Date startdate, Date enddate, Id recordid) {
        DateTime StartDate1 = DateTime.newInstance(startdate, Time.newInstance(0, 0, 0, 0));
        DateTime EndDate1 = DateTime.newInstance(enddate, Time.newInstance(23, 59, 59, 59));
        
        return [
            SELECT Id, Name, RecordTypeId, Latitude__c, Asset_Type__c, Current_Location_Address__c, Longitude__c,
            Asset__c, Asset_Account__c, Asset_Name__c, Start_Time__c, End_Time__c, Location__c, 
            Asset_Customer_ID__c, End_Time_12_Hours__c, Start_Time_12_Hours__c,
            Current_Location__r.ShippingLatitude, Current_Location__r.ShippingLongitude
            FROM Asset_History_custom__c
            WHERE RecordTypeId = :Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId()
            AND Asset__c = :recordid
            AND (
                (Start_Time__c > :StartDate1 AND End_Time__c < :EndDate1 AND End_Time__c > :StartDate1 AND Start_Time__c < :EndDate1) OR
                (Start_Time__c > :StartDate1 AND End_Time__c > :EndDate1 AND End_Time__c > :StartDate1 AND Start_Time__c < :EndDate1) OR
                (Start_Time__c < :StartDate1 AND End_Time__c < :EndDate1 AND End_Time__c > :StartDate1 AND Start_Time__c < :EndDate1) OR
                (Start_Time__c < :StartDate1 AND End_Time__c > :EndDate1 AND End_Time__c > :StartDate1 AND Start_Time__c < :EndDate1)
            )
            ORDER BY Start_Time__c ASC
        ];
    }
    
    @AuraEnabled 
    public static List<Asset> fetchAssetIdsWithCustomer(String customerId) {
        String filter = '';
        
        if (!String.isBlank(customerId)) {
            filter += ' WHERE Field2__c = \'' + String.escapeSingleQuotes(customerId) + '\'';
        }
        // Construct the full query
        String query = 'SELECT Id, Name, Field2__c FROM Asset ' + filter + ' ORDER BY Name';
        
        // Execute the query
        List<Asset> assets = Database.query(query);
        
        List<Asset> caseSensitiveAssets = new List<Asset>();
    	for (Asset asset : assets) {
        	if (asset.Field2__c.equals(customerId)) { // Case-sensitive comparison
            	caseSensitiveAssets.add(asset);
        	}
    	}

    	return caseSensitiveAssets;
    }
    
    @AuraEnabled
    public static List<Asset> fetchAssetIds(String searchTerm) {
        String filter = '';
        
        if (!String.isBlank(searchTerm)) {
            filter += ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR ID = :searchTerm)';
        }
        
        // Construct the full query
        String query = 'SELECT Id, Name, Field2__c FROM Asset ' + filter + ' ORDER BY Name';
        
        // Execute the query
        return Database.query(query);
    }
    
    
    @AuraEnabled
    public static List<Asset> fetchCustomerIds(String searchTerm) {
        String filter = 'WHERE Field2__c != null';
        if (!String.isBlank(searchTerm)) {
            filter += ' AND Field2__c LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        
        String query = 'SELECT Id, Name, Field2__c FROM Asset ' + filter + ' ORDER BY Name';
        List<Asset> assetList = Database.query(query);
        
        Map<String, Asset> uniqueAssets = new Map<String, Asset>();
        for (Asset asset : assetList) {
            uniqueAssets.put(asset.Field2__c, asset);
        }
        
        return uniqueAssets.values();
    }
}