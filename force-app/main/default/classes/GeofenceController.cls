public with sharing class GeofenceController {
    @AuraEnabled(cacheable=true)
    public static String getGeofence(Id accountId) {
        Account acc = [SELECT id,Geofence_data__c FROM Account WHERE Id = :accountId LIMIT 1];
        return acc.Geofence_data__c;
    }

    @AuraEnabled
public static void saveGeofence(Id accountId, String geofenceData) {
    if (String.isEmpty(accountId)) {
        throw new AuraHandledException('Invalid Account ID');
    }

    // Query the Account safely
    List<Account> accList = [SELECT Id, Geofence_data__c,is_Custom_Geofence__c FROM Account WHERE Id = :accountId LIMIT 1];

    if (accList.isEmpty()) {
        throw new AuraHandledException('Account not found with ID: ' + accountId);
    }

    Account acc = accList[0];
    acc.Geofence_data__c = geofenceData;
    acc.is_Custom_Geofence__c = true;
    update acc;
}
@AuraEnabled
    public static Decimal getGeofenceRadius(Id accId) {
        Account acc = [SELECT GeoFence_Radius_in_Miles__c FROM Account WHERE Id = :accId LIMIT 1];
        return acc.GeoFence_Radius_in_Miles__c	;
    }

    @AuraEnabled
    public static void saveGeofenceRadius(Id accId, Decimal radius) {
        Account acc = [SELECT Id, GeoFence_Radius_in_Miles__c	 FROM Account WHERE Id = :accId LIMIT 1];
        acc.GeoFence_Radius_in_Miles__c	 = radius;
        update acc;
    }

    @AuraEnabled
public static  Map<String, Object> getLocation(id accId ) {
    Account acc =[SELECT id, ShippingLatitude, ShippingLongitude FROM Account WHERE Id = :accId LIMIT 1];

    Map<String, Object> result = new Map<String, Object>();
    result.put('latitude', acc.ShippingLatitude);
    result.put('longitude', acc.ShippingLongitude);

    return result;
}

@AuraEnabled
public Static Boolean isCustom(Id accid){
    Account acc = [SELECT id,Geofence_Type__c  FROM Account WHERE Id = :accid LIMIT 1];
    if(acc.Geofence_Type__c.contains('Custom'))
    {
        return true;
    }else{
        return false;
    }
    
    }   
}