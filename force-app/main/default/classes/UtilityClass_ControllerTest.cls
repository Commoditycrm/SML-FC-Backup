@isTest
public class UtilityClass_ControllerTest {

    @testSetup
    static void testDataSetup() {
        // Create Account, Asset, and Redesign Metadata
        Account acc = new Account(Name = 'Testing', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 40.748817, shippinglongitude = -73.985428);
        insert acc;
        
        Asset ast = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            Device_Id__c = '72308628872194290',
            Is_Loco_Asset__c = true
        );
        insert ast;

        // Mocking a basic API Response record
        Api_Response__c resp = new Api_Response__c(
            Incoming_Messsage__c = 'eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjMzNjU5NTAwMTA3MTY4NzY3MjI5Mjg0NjYxMDY3Nzk0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNzEyNDUwNjkyOCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAgImV2ZW50cyI6IFsgeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNzA4MTQ4MDk5fSx7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE3MDgxNDgwOTl9LHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTcwODE0ODA5OX1dfX1dfQ==', 
            ResEnteringDttime__c = system.now(), 
            ResEnteringTime__c = (system.now().getTime()/1000),
            Is_Nimbelink_Asset__c = true,
            Status__c = 'NEW'
        );
        insert resp;

        // Create API_Response_Childs__c record with mocked data
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c = 5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Api_Response__c = resp.id;
        apc.Location__c = 'testingAccoubt';
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = 'test';
        apc.PowerUptime__c = 12345;
        apc.RecordTypeId = locationRecordType.Id;
        apc.HaccRank__c = 0;
        apc.ARC_External_Id__c = 'dummy1';
        apc.Accuracy_meters__c = 15;
        apc.Message_Type__c = 'wifi';
        insert apc;
    }

    @isTest
    public static void testCreateGoogleAPIRecords() {
        List<API_Response_Childs__c> arcLst = [SELECT Id, Name, HaccRank__c, Asset__c, Latitude__c, Longitude__c, Timestamp__c, Timestamp_DateTime__c, Accuracy_meters__c, 
                                                Battery__c, API_Response__c, EstBattPct__c, Network__c, PowerUptime__c, rsrp__c, rsrq__c, rssi__c, Signal__c,
                                                Timestamp_Device_Status__c, Timestamp_Date_Time_Device_Status__c, Message_Type__c
                                                FROM API_Response_Childs__c];

        Asset ast = [SELECT id FROM Asset LIMIT 1];
        
        // Set up mock for HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockSuccessCalloutResponseGenerator());
        
        // Start the test
        Test.startTest();
        UtilityClass_Controller.createGoogleAPIRecords(arcLst, '72308628872194290', ast);
        UtilityClass_Controller.createGoogleAPIRecords(arcLst, 'Test Asset', ast);
        Test.stopTest();
    }
    private class MockSuccessCalloutResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{' +
            '"results": [' +
                '{' +
                    '"name": "Test Business",' +
                    '"place_id": "ChIJSa7b4wqwYjURp6t4t6TMEjQ",' +
                    '"types": ["establishment", "point_of_interest", "street_number", "route"],' +
                    '"geometry": {' +
                        '"location": {' +
                            '"lat": 40.748817,' +
                            '"lng": -73.985428' +
                        '}' +
                    '},' +
                    '"address_components": [' +
                        '{' +
                            '"long_name": "350 5th Ave",' +
                            '"short_name": "350 5th Ave",' +
                            '"types": ["street_address", "route"]' +
                        '},' +
                        '{' +
                            '"long_name": "New York",' +
                            '"short_name": "NY",' +
                            '"types": ["locality", "political","street_address", "route"]' +
                        '},' +
                        '{' +
                            '"long_name": "New York",' +
                            '"short_name": "NY",' +
                            '"types": ["administrative_area_level_1", "political","street_address", "route"]' +
                        '},' +
                        '{' +
                            '"long_name": "10001",' +
                            '"short_name": "10001",' +
                            '"types": ["postal_code","street_address", "route"]' +
                        '},' +
                        '{' +
                            '"long_name": "United States",' +
                            '"short_name": "US",' +
                            '"types": ["country", "political", "street_address", "route"]' +
                        '}' +
                    ']' +
                '}' +
            ']' +
        '}');
            return res;
        }
    }
}