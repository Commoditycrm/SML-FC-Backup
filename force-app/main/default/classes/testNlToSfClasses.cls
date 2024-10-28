@isTest
public class testNlToSfClasses {
@testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
            
            Asset ast = new Asset();
        ast.Name = 'at5-t16ee4491f50'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        insert ast;

        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Asset__c = ast.Id;
        astCon.RecordTypeId = AssetRecType.Id;
  		astCon.Master_Configuration_Check__c=true;
        	astCon.Accelerometer_Status_Reported__c = 'true';
            astCon.Connect_On_Tilt_Reported__c      = 'true';
            astCon.ConnectMovementEnd_Reported__c = 'true';
        	astCon.ConnectMovementStart_Reported__c = 'false';
        	astCon.Location_Sampling_Period_Reported__c = '86400';
        	astCon.Location_Status_Reported__c = 'true';
        	astCon.Log_Every_n_Reported__c = 0;
        	astCon.Measurement_Period_Reported__c = '900';
        	astCon.Network_Check_in_period_Reported__c = '86400';
        	astCon.Reference_X_Reported__c = 0;
        	astCon.Reference_Y_Reported__c = 0;
        	astCon.Reference_Z_Reported__c = 0;
        	astCon.Temperature_Check_in_Period_Reported__c = '86400';
        	astCon.Temperature_Status_Reported__c = 'true';
        	astCon.Tilt_Degrees_Reported__c = 15;
        	astCon.Tracking_Location_Period_desired__c = '7200';
        	astCon.Tracking_Locations_per_Check_Ins_Reporte__c = '1';
        	astCon.Trackmode_Reported__c = '3';
        	astCon.Use_Cell_Reported__c = 'true';
        	astCon.Use_GPS_Reported__c = 'false';
        	astCon.Use_WiFi_Reported__c = 'true';
        insert astCon;
            }
            @IsTest
            Public Static Void testRedesignAC_SyncAssetConfig(){
                  Asset ast = [Select Id from Asset];
                  RedesignAC_SyncAssetConfig.request testRequest = new RedesignAC_SyncAssetConfig.request();
                  testRequest.recordId = ast.Id;                    
                  List<RedesignAC_SyncAssetConfig.request> testRequestList = new List<RedesignAC_SyncAssetConfig.request>();
                  testRequestList.add(testRequest);
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                List<RedesignAC_SyncAssetConfig.result> res = RedesignAC_SyncAssetConfig.SyncAssetConfigForSingleRecord(testRequestList);
                Test.stopTest();
            }
            @isTest
            Public Static Void testDailyAndMonthlyScheduler(){
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                RedesignAC_NL_to_SF_DailyScheduler dailySchedulerInstance = new RedesignAC_NL_to_SF_DailyScheduler();
                dailySchedulerInstance.execute(null);
                RedesignAC_NL_to_SF_MonthlyScheduler monthlySchedulerInstance = new RedesignAC_NL_to_SF_MonthlyScheduler();
                monthlySchedulerInstance.execute(null);
                String qry='select id, Name, Accelerometer_Status_Desired__c,Accelerometer_Status_Reported__c, Account__c, Asset__c, ConnectMovementEnd_Desired__c, ConnectMovementEnd_Reported__c, ConnectMovementStart_Desired__c,ConnectMovementStart_Reported__c, Individual_config__c, Location_Sampling_Period_Desired__c, Location_Sampling_Period_Reported__c, Location_Status_Desired__c, Location_Status_Reported__c, Master_Configuration_Check__c, Measurement_Period_desired__c, Measurement_Period_Reported__c, Network_Check_in_period_Desired__c, Network_Check_in_period_Reported__c, NLResponseStatus__c,Temperature_Check_in_Period_Desired__c, Temperature_Check_in_Period_Reported__c,Temperature_Status_Desired__c, Temperature_Status_Reported__c, Tilt_Degrees_Desired__c, Tilt_Degrees_Reported__c, Tracking_Location_Period_desired__c, Tracking_Location_Period_Reported__c,Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Locations_per_Check_Ins_Reporte__c, Trackmode_Desired__c, Trackmode_Reported__c, Use_Cell_Desired__c, Use_Cell_Reported__c, Use_GPS_Desired__c,Use_GPS_Reported__c, Use_WiFi_Desired__c, Use_Wifi_Reported__c  from Asset_Configuration__c';
                Boolean forTest = true;
                database.executeBatch(new RedesignAC_NL_to_SF_CalloutBatch(qry,forTest),100);

                Test.stopTest();
            }
            private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"config":{"desired": {"location": {"useGPS": false,"sampling_period": 86400,"enabled": true,"useCell": true,\n"useWiFi": true\n},\n"network": {\n"period": 86400\n},\n"accelerometer": {\n"enabled": true,\n"mode": 3,\n"measurement_period": 86400,\n"tracking": {\n"bucket_size": 100,\n"bucket_fill_time": 50,\n"connect_on_movement_start": true,\n"locations_per_checkin": 1,\n"inactivity_before_movement_end": 900,\n"location_period": 14400,\n"connect_on_movement_end": true,\n"lower_accel_threshold": 50\n},\n"tilt": {\n"degrees": 15,\n"connect_on_tilt": false,\n"log_every_n": 0,\n"reference_z": 0.01,\n"reference_x": 0.01,\n"reference_y": 0\n}\n},\n"temperature": {\n"enabled": false,\n"sampling_period": 86400\n},\n"ble": {\n"enabled": false,\n"sampling_period": 300\n}\n},\n"reported": {\n"accelerometer": {\n"enabled": true,\n"mode": 3,\n"measurement_period": 86400,\n"tracking": {\n"lower_accel_threshold": 50,\n"bucket_size": 100,\n"bucket_fill_time": 50,\n"inactivity_before_movement_end": 900,\n"location_period": 14400,\n"locations_per_checkin": 1,\n"connect_on_movement_start": true,\n"connect_on_movement_end": true\n},\n"tilt": {\n"degrees": 15,\n"connect_on_tilt": false,\n"log_every_n": 0,\n"reference_x": 0,\n"reference_y": 0,\n"reference_z": 0\n}\n},\n"ble": {\n"enabled": false,\n"sampling_period": 300,\n"scan_duration": 6\n},\n"location": {\n"enabled": true,\n"sampling_period": 86400,\n"useCell": true,\n"useWiFi": true\n},\n"network": {\n"external_location_rise": false,\n"period": 86400\n},\n"temperature": {\n"enabled": false,\n"sampling_period": 86400,\n"low2": 19,\n"low1": 20,\n"high1": 22,\n"high2": 23,\n"alert_connect_mask": 0,\n"log_every_n_samples": 1\n}\n}\n},"deviceId": "at5-t16ee4491f50"}');
            return res;
        }
    }
}