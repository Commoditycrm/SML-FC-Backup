@IsTest
private class testChorus_Controller {
    
    @testSetup
    static void testDataSetup(){
        Api_Config__c apiCfg = new Api_Config__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = 'Org',
            Endpoint__c = 'https://chorus.example.com'
        );
        insert apiCfg;

        Nimbelink_Sync_Prod_Full_Copy__c syncCfg = new Nimbelink_Sync_Prod_Full_Copy__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = 'OrgDefaults',
            Chorus_minServerProcessingTime__c = System.now().addHours(-1)
        );
        insert syncCfg;
        
        Account acc = new Account(Name='Testing');
        insert acc;

        // Create an Asset that matches batch filter
        Asset ast = new Asset(
            Name = 'A-1',
            AccountId = acc.Id,
            Device_Id__c = 'DEV-AHC-1',
            Is_Chorus_Asset__c = true,
            Pause_Job__c = false,
            Capture_Temperature_Response__c = true
        );
        insert ast;

        // Create parent API_Response__c that batch start() reads
        API_Response__c parent = new API_Response__c(
            Asset__c = ast.Id,
            Status__c = 'Chorus-New'
        );
        insert parent;

        // Ensure RecordType for child exists and get id (same as your other test)
        Id locRtId = getRecordTypeId('API_Response_Childs__c', 'Location');
        Id TempRtId = getRecordTypeId('API_Response_Childs__c', 'Temperature');

        // Create ARC child rows that will form segments
        // Segment 1: LOC-1 (2 rows)
        // Segment 2: LOC-2 (2 rows)
        Datetime t0 = System.now().addMinutes(-20);
        
        Api_Response_Childs__c arc = new Api_Response_Childs__c(
                Name='ARC-1',
                Asset__c=ast.Id,
                ARC_External_Id__c = '5',
                Status__c='Chorus-New',
                RecordTypeId=TempRtId,
                haccRank__c = 0,
                Timestamp_DateTime__c=t0.addMinutes(1),
                Temperature__c=20,
                Relative_Humidity__c=30,
                Accuracy_Meters__c=10
            );
        insert arc;

        List<Api_Response_Childs__c> arcs = new List<Api_Response_Childs__c>{
            new Api_Response_Childs__c(
                Name='ARC-1',
                Asset__c=ast.Id,
                ARC_External_Id__c = '4',
                Status__c='Chorus-New',
                RecordTypeId=locRtId,
                haccRank__c = 0,
                Timestamp_DateTime__c=t0.addMinutes(1),
                currentLocationId__c=acc.Id,
                Location__c='In Network',
                Temperature__c=20,
                Relative_Humidity__c=30,
                Latitude__c='12.3456',
                Longitude__c='77.1234',
                Accuracy_Meters__c=10
            ),
            new Api_Response_Childs__c(
                Name='ARC-2',
                Asset__c=ast.Id,
                ARC_External_Id__c = '3',
                haccRank__c = 0,
                Status__c='Chorus-New',
                RecordTypeId=locRtId,
                Timestamp_DateTime__c=t0.addMinutes(2),
                currentLocationId__c=acc.Id,
                Location__c='In Network',
                Temperature__c=21,
                Relative_Humidity__c=31,
                Latitude__c='13.3457',
                Longitude__c='76.1235',
                Accuracy_Meters__c=9
            ),
            new Api_Response_Childs__c(
                Name='ARC-3',
                Asset__c=ast.Id,
                ARC_External_Id__c = '2',
                haccRank__c = 0,
                Status__c='Chorus-New',
                RecordTypeId=locRtId,
                Timestamp_DateTime__c=t0.addMinutes(3),
                Location__c='In Transit',
                Temperature__c=22,
                Relative_Humidity__c=32,
                Latitude__c='13.0001',
                Longitude__c='78.0001',
                Accuracy_Meters__c=8
            ),
            new Api_Response_Childs__c(
                Name='ARC-4',
                ARC_External_Id__c = '1',
                haccRank__c = 0,
                Asset__c=ast.Id,
                Status__c='Chorus-New',
                RecordTypeId=locRtId,
                Timestamp_DateTime__c=t0.addMinutes(4),
                Location__c='In Transit',
                Temperature__c=23,
                Relative_Humidity__c=33,
                Latitude__c='13.0002',
                Longitude__c='78.0002',
                Accuracy_Meters__c=7
            )
        };
        insert arcs;
		Id AhclocRtId = getRecordTypeId('Asset_History_Custom__c', 'Location');
        // Create an existing open AHC record to exercise "close old open" path
        Asset_History_Custom__c openAhc = new Asset_History_Custom__c(
            Asset__c=ast.Id,
            Still_in_this_Location__c=true,
            currentLocationId__c='LOC-0',
            Start_Time__c=t0.addMinutes(-60),
            End_Time__c=t0.addMinutes(-59),
            Current_Location__c=acc.Id,
			RecordTypeId = AhclocRtId
        );
        insert openAhc;
        
        Asset_History_Custom__c openAhc2 = new Asset_History_Custom__c(
            Asset__c=ast.Id,
            Still_in_this_Location__c=false,
            currentLocationId__c='LOC-0',
            Start_Time__c=t0.addMinutes(-60),
            End_Time__c=t0.addMinutes(5),
            Current_Location__c=acc.Id,
			RecordTypeId = AhclocRtId
        );
        insert openAhc2;
        
        
    }
    @IsTest
    static void testExecute_CreatesRecords() {
         Test.setMock(HttpCalloutMock.class, new ChorusHttpMock());

        Test.startTest();
        Database.executeBatch(new Chorus_Controller(), 200);
        Test.stopTest();
    }

    @IsTest
    static void testScheduler() {
        Test.setMock(HttpCalloutMock.class, new ChorusHttpMock());
        Test.startTest();
        String cron = '0 0 0 1 1 ?';
        System.schedule('Chorus Test Job', cron, new Chorus_Scheduler());
        Test.stopTest();
    }

    // ==========================================================
    // NEW: Tests to cover Chorus_AhcBatch (NO main class changes)
    // ==========================================================

    @IsTest
    static void testChorusAhcBatch_CreatesAndClosesSegments() {  
        
        List<Api_Response_Childs__c> arcs = [SELECT Asset__r.Is_M2MD__c, Asset__r.Is_Loco_Asset__c, Asset__r.Name, Accuracy_meters__c, Alt__c, Api_Response__c, API_Response_ID__c, ARC_External_Id__c, Asset__c, Asset_History__c, AstLastConnect__c, async__c, Battery__c, Business_Location__c, Business_Location__Latitude__s, Business_Location__Longitude__s, Business_Name__c, Business_Place_Id__c, CreatedById, CreatedDate, Current_City__c, Current_Country__c, Current_Location_Address__c, Current_State__c, Current_Street_Address__c, Current_Zipcode__c, CurrentLocationId__c, Device_Timestamp__c, Device_Ts__c, Distance__c, Distance_Level__c, EstBattPct__c, Event_Name__c, Facility_Location__c, HaccRank__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Latitude__c, Location__c, Longitude__c, Message_Type__c, Name, Network__c, OwnerId, PowerUptime__c, RecordTypeId, Relative_Humidity__c, rsrp__c, rsrq__c, rssi__c, Signal__c, Status__c, SystemModstamp, Temperature__c, Timestamp__c, Timestamp_Date_Time_Device_Status__c, Timestamp_DateTime__c, Timestamp_Device_Status__c FROM API_Response_Childs__c];
        Asset ast = [Select name from asset limit 1];
        
                
        Google_API_Data__c gad = new Google_API_Data__c();
        	gad.Latitude__c = arcs[0].Latitude__c;
            gad.Longitude__c = arcs[0].Longitude__c;
        	gad.Business_Name__c = 'xyz';
        insert gad;
        Google_API_Data__c gad2 = new Google_API_Data__c();
        	gad2.Latitude__c = arcs[1].Latitude__c;
            gad2.Longitude__c = arcs[1].Longitude__c;
        	gad2.Business_Name__c = 'xyz';
        insert gad2;
        
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator()); 
        
        Test.startTest();
        Chorus_ArcBatch.createGoogleAPIRecords(arcs, ast.Name);
        Database.executeBatch(new Chorus_AhcBatch(), 1);
        Chorus_AhcBatch.DeleteExistingRecords(ast);
        Test.stopTest();
    }

    // ----------------------------
    // Helper: record type lookup
    // ----------------------------
    
        private class ChorusHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            String body = '{"dataPoints":[{' +
                '"deviceId":"DEV-1",' +
                '"deviceType":"MODEL-1",' +
                '"recordTime":"2025-01-01T10:00:00Z",' +
                '"serverProcessingTime":"2025-01-01T10:00:10Z",' +
                '"isMoving":true,' +
                '"aggregatorDetails":{' +
                    '"aggregatorDeviceId":"FAC-1",' +
                    '"seenTime":"2025-01-01T10:00:05Z",' +
                    '"rssiDbm":-70,' +
                    '"aggregatorLocation":{' +
                        '"accuracyCm":123,' +
                        '"point":{' +
                            '"latitudeMicro":34345678,' +
                            '"longitudeMicro":97765432' +
                        '}' +
                    '}' +
                '},' +
                '"battery":{' +
                    '"batteryVoltMilli":12000,' +
                    '"batterySocPercent":80' +
                '},' +
                '"temperature":{' +
                    '"temperatureCelsiusMilli":25000' +
                '}' +
            '}, {' +
                '"deviceId":"DEV-1",' +
                '"deviceType":"MODEL-1",' +
                '"recordTime":"2025-01-01T10:00:00Z",' +
                '"serverProcessingTime":"2025-01-01T10:00:10Z",' +
                '"isMoving":true,' +
                '"aggregatorDetails":{' +
                    '"aggregatorDeviceId":"FAC-1",' +
                    '"seenTime":"2025-01-01T10:00:05Z",' +
                    '"rssiDbm":-70,' +
                    '"aggregatorLocation":{' +
                        '"accuracyCm":123,' +
                        '"point":{' +
                            '"latitudeMicro":36345678,' +
                            '"longitudeMicro":96765432' +
                        '}' +
                    '}' +
                '},' +
                '"battery":{' +
                    '"batteryVoltMilli":12000,' +
                    '"batterySocPercent":80' +
                '},' +
                '"temperature":{' +
                    '"temperatureCelsiusMilli":25000' +
                '}' +
            '}]}' ;

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(body);
            return res;
        }
    }
        private class MockSuccessHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if(endpoint.contains('nearbysearch')){
                res.setBody('{"results": [{"name": "Starbucks", "geometry": {"location": {"lat": 37.7749, "lng": -122.4194}}, "types": ["restaurant", "establishment"]}]}');
            }
            else{
				res.setBody('{"results":[{"address_components":[{"long_name":"Test Street","short_name":"TS","types":["route"]},{"long_name":"Test City","short_name":"TC","types":["locality","political"]},{"long_name":"California","short_name":"CAS","types":["administrative_area_level_1","political"]},{"long_name":"12345","short_name":"12345","types":["postal_code"]},{"long_name":"United States","short_name":"USA","types":["country","political"]}],"formatted_address":"123 Test Street, Test City, CA, 12345, USA","geometry":{"location":{"lat":37.7749,"lng":-122.4194}},"name":"Test Business","place_id":"ChIJ123456789","types":["establishment","restaurant"]}]}');

            }
            return res;
        }
    }
    private static Id getRecordTypeId(String sobjectName, String developerName) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = :sobjectName AND DeveloperName = :developerName
            LIMIT 1
        ];
        return rt.Id;
    }
}