@isTest
public class GeofenceControllerTest {
    
    // Test method for `getGeofence` method
    @isTest
    static void testGetGeofence() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account', Geofence_data__c = '[{"id":1,"lat":40.7128,"lng":-74.0060}]',Geofence_Type__c='Custom_Geofence',is_Custom_Geofence__c =True);
        insert testAccount;

        // Test getGeofence method
        Test.startTest();
        String geofenceData = GeofenceController.getGeofence(testAccount.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, geofenceData, 'Geofence data should not be null');
        System.assert(geofenceData.contains('40.7128'), 'Geofence data should contain lat value');
        System.assert(geofenceData.contains('-74.0060'), 'Geofence data should contain lng value');
    }

    // Test method for `getGeofenceRadius` method
    @isTest
    static void testGetGeofenceRadius() {
        // Create test Account with Geofence Radius
        Account testAccount = new Account(Name = 'Test Account', GeoFence_Radius_in_Miles__c = 1);
        insert testAccount;

        // Test getGeofenceRadius method
        Test.startTest();
        Decimal radius = GeofenceController.getGeofenceRadius(testAccount.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, radius, 'Geofence radius should be 100');
    }

    // Test method for `saveGeofence` method
    @isTest
    static void testSaveGeofence() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test geofence data
        String geofenceData = '[{"id":1,"lat":40.7128,"lng":-74.0060}]';

        // Test saveGeofence method
        Test.startTest();
        GeofenceController.saveGeofence(testAccount.Id, geofenceData);
        Test.stopTest();

        // Retrieve the saved geofence data
        Account updatedAccount = [SELECT Geofence_data__c FROM Account WHERE Id = :testAccount.Id];
        
        // Verify the result
        System.assertNotEquals(null, updatedAccount.Geofence_data__c, 'Geofence data should be saved');
        System.assert(updatedAccount.Geofence_data__c.contains('40.7128'), 'Saved geofence data should contain lat value');
        System.assert(updatedAccount.Geofence_data__c.contains('-74.0060'), 'Saved geofence data should contain lng value');
    }
    
    @isTest
    static void testGetLocation() {
        // Create a test Account with ShippingLatitude and ShippingLongitude
        Account testAccount = new Account(
            Name = 'Test Account', 
            ShippingLatitude = 40.7128, 
            ShippingLongitude = -74.0060
        );
        insert testAccount;

        // Test getLocation method
        Test.startTest();
        Map<String, Object> location = GeofenceController.getLocation(testAccount.Id);
        Test.stopTest();
        
        // Verify that the latitude and longitude values are correct
        System.assertNotEquals(null, location, 'Location map should not be null');
        System.assertEquals(40.7128, location.get('latitude'), 'Latitude should be 40.7128');
        System.assertEquals(-74.0060, location.get('longitude'), 'Longitude should be -74.0060');
    }

    // Test method for `saveGeofenceRadius` method
    @isTest
    static void testSaveGeofenceRadius() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test saveGeofenceRadius method
        Test.startTest();
        GeofenceController.saveGeofenceRadius(testAccount.Id, 200);
        Test.stopTest();

        // Retrieve the saved geofence radius
        Account updatedAccount = [SELECT GeoFence_Radius_in_Miles__c FROM Account WHERE Id = :testAccount.Id];
        
        // Verify the result
        System.assertEquals(200, updatedAccount.GeoFence_Radius_in_Miles__c, 'Geofence radius should be updated to 200');
    }

    // Test method for `isCustomGeofence` method
    @isTest
    static void testIsCustomGeofence() {
        // Create test Account with custom geofence flag
        Account testAccount = new Account(Name = 'Test Account', Geofence_Type__c='Custom_Geofence',is_Custom_Geofence__c =True);
        insert testAccount;

        // Test isCustomGeofence method
        Test.startTest();
        Boolean result = GeofenceController.isCustom(testAccount.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(true, result, 'Account should have a custom geofence');
    }
}