@isTest
public class testSfToNlClasses {
@testSetup static void testDataSetup(){
        Account acc = new Account();
        	acc.Name = 'Testing';
        insert acc;
    	Account acc2 = new Account();
			acc2.Name = 'Location1';
    		acc2.Source_Account__c = acc.Id;
    	insert acc2;
            
            Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
    	ast.Current_Location__c = acc.Id;
    	ast.Is_Loco_Asset__c = true;
        insert ast;
    
            Asset locoAst = new Asset();
        locoAst.Name = 'Test'; 
        locoAst.Device_Id__c = 'Test';
        locoAst.AccountId = acc.Id;
        locoAst.Current_Location__c = acc.Id;
        insert locoAst;

        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        RecordType DefaultRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Default' LIMIT 1];
    
    	Asset_Configuration__c acntConf3 = new Asset_Configuration__c();
        acntConf3.Account__c = acc2.Id;
        acntConf3.RecordTypeId = DefaultRecType.Id;
    	insert acntConf3;
    
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Asset__c = ast.Id;
        astCon.RecordTypeId = AssetRecType.Id;
        astCon.Accelerometer_Status_Desired__c = 'true';
            astCon.Connect_On_Tilt_Desired__c      = 'true';
            astCon.ConnectMovementEnd_Desired__c = 'true';
        	astCon.ConnectMovementStart_Desired__c = 'false';
        	astCon.Location_Sampling_Period_Desired__c = '86400';
        	astCon.Location_Status_Desired__c = 'true';
        	astCon.Log_Every_n_Desired__c = 0;
        	astCon.Measurement_Period_desired__c = '900';
        	astCon.Network_Check_in_period_Desired__c = '86400';
        	astCon.Reference_X_Desired__c = 0;
        	astCon.Reference_Y_Desired__c = 0;
        	astCon.Reference_Z_Desired__c = 0;
        	astCon.Temperature_Check_in_Period_Desired__c = '86400';
        	astCon.Temperature_Status_Desired__c = 'true';
        	astCon.Tilt_Degrees_Desired__c = 15;
        	astCon.Tracking_Location_Period_desired__c = '7200';
        	astCon.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        	astCon.Trackmode_Desired__c = '3';
        	astCon.Use_Cell_Desired__c = 'true';
        	astCon.Use_GPS_Desired__c = 'false';
        	astCon.Use_WiFi_Desired__c = 'true';
    		astCon.Impact_Alert_Desired__c = 'true';
        	astCon.Max_Impact_Desired__c = 10;
        	astCon.Location_Accuracy_Desired__c = 5;
        	astCon.Movement_Accuracy_Desired__c = 5;
        	astCon.Sensor_Logging_Period_Desired__c = 50;
        insert astCon;
            
            Asset_Configuration__c LocoAstCon = new Asset_Configuration__c();
        LocoAstCon.Asset__c = LocoAst.Id;
        LocoAstCon.RecordTypeId = AssetRecType.Id;
        LocoAstCon.Accelerometer_Status_Desired__c = 'true';
            LocoAstCon.Connect_On_Tilt_Desired__c      = 'true';
            LocoAstCon.ConnectMovementEnd_Desired__c = 'true';
        	LocoAstCon.ConnectMovementStart_Desired__c = 'false';
        	LocoAstCon.Location_Sampling_Period_Desired__c = '86400';
        	LocoAstCon.Location_Status_Desired__c = 'true';
        	LocoAstCon.Log_Every_n_Desired__c = 0;
        	LocoAstCon.Measurement_Period_desired__c = '900';
        	LocoAstCon.Network_Check_in_period_Desired__c = '86400';
        	LocoAstCon.Reference_X_Desired__c = 0;
        	LocoAstCon.Reference_Y_Desired__c = 0;
        	LocoAstCon.Reference_Z_Desired__c = 0;
        	LocoAstCon.Temperature_Check_in_Period_Desired__c = '86400';
        	LocoAstCon.Temperature_Status_Desired__c = 'true';
        	LocoAstCon.Tilt_Degrees_Desired__c = 15;
        	LocoAstCon.Tracking_Location_Period_desired__c = '7200';
        	LocoAstCon.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        	LocoAstCon.Trackmode_Desired__c = '3';
        	LocoAstCon.Use_Cell_Desired__c = 'true';
        	LocoAstCon.Use_GPS_Desired__c = 'false';
        	LocoAstCon.Use_WiFi_Desired__c = 'true';
    		LocoAstCon.Individual_config__c = false;
    		LocoAstCon.NLResponseStatus__c = 'Pending';
    		LocoAstCon.Impact_Alert_Desired__c = 'true';
        	LocoAstCon.Max_Impact_Desired__c = 10;
        	LocoAstCon.Location_Accuracy_Desired__c = 5;
        	LocoAstCon.Movement_Accuracy_Desired__c = 5;
        	LocoAstCon.Sensor_Logging_Period_Desired__c = 50;
        insert LocoAstCon;
        Asset_Configuration__c acntConf = new Asset_Configuration__c();
        acntConf.Account__c = acc.Id;
        acntConf.RecordTypeId = AccountRecType.Id;
        acntConf.Accelerometer_Status_Desired__c = 'true';
            acntConf.Connect_On_Tilt_Desired__c      = 'true';
            acntConf.ConnectMovementEnd_Desired__c = 'true';
        	acntConf.ConnectMovementStart_Desired__c = 'false';
        	acntConf.Location_Sampling_Period_Desired__c = '86400';
        	acntConf.Location_Status_Desired__c = 'true';
        	acntConf.Log_Every_n_Desired__c = 0;
        	acntConf.Measurement_Period_desired__c = '900';
        	acntConf.Network_Check_in_period_Desired__c = '86400';
        	acntConf.Reference_X_Desired__c = 0;
        	acntConf.Reference_Y_Desired__c = 0;
        	acntConf.Reference_Z_Desired__c = 0;
        	acntConf.Temperature_Check_in_Period_Desired__c = '86400';
        	acntConf.Temperature_Status_Desired__c = 'true';
        	acntConf.Tilt_Degrees_Desired__c = 15;
        	acntConf.Tracking_Location_Period_desired__c = '7200';
        	acntConf.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        	acntConf.Trackmode_Desired__c = '3';
        	acntConf.Use_Cell_Desired__c = 'true';
        	acntConf.Use_GPS_Desired__c = 'false';
        	acntConf.Use_WiFi_Desired__c = 'true';
    		acntConf.Impact_Alert_Desired__c = 'true';
        	acntConf.Max_Impact_Desired__c = 10;
        	acntConf.Location_Accuracy_Desired__c = 5;
        	acntConf.Movement_Accuracy_Desired__c = 5;
        	acntConf.Sensor_Logging_Period_Desired__c = 50;
        insert acntConf;
    
    Asset_Configuration__c acntConf2 = new Asset_Configuration__c();
        acntConf2.Account__c = acc.Id;
        acntConf2.RecordTypeId = DefaultRecType.Id;
        acntConf2.Accelerometer_Status_Desired__c = 'true';
            acntConf2.Connect_On_Tilt_Desired__c      = 'true';
            acntConf2.ConnectMovementEnd_Desired__c = 'true';
        	acntConf2.ConnectMovementStart_Desired__c = 'false';
        	acntConf2.Location_Sampling_Period_Desired__c = '86400';
        	acntConf2.Location_Status_Desired__c = 'true';
        	acntConf2.Log_Every_n_Desired__c = 0;
        	acntConf2.Measurement_Period_desired__c = '900';
        	acntConf2.Network_Check_in_period_Desired__c = '86400';
        	acntConf2.Reference_X_Desired__c = 0;
        	acntConf2.Reference_Y_Desired__c = 0;
        	acntConf2.Reference_Z_Desired__c = 0;
        	acntConf2.Temperature_Check_in_Period_Desired__c = '86400';
        	acntConf2.Temperature_Status_Desired__c = 'true';
        	acntConf2.Tilt_Degrees_Desired__c = 15;
        	acntConf2.Tracking_Location_Period_desired__c = '7200';
        	acntConf2.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        	acntConf2.Trackmode_Desired__c = '3';
        	acntConf2.Use_Cell_Desired__c = 'true';
        	acntConf2.Use_GPS_Desired__c = 'false';
        	acntConf2.Use_WiFi_Desired__c = 'true';
    		acntConf2.Impact_Alert_Desired__c = 'true';
        	acntConf2.Max_Impact_Desired__c = 10;
        	acntConf2.Location_Accuracy_Desired__c = 5;
        	acntConf2.Movement_Accuracy_Desired__c = 5;
        	acntConf2.Sensor_Logging_Period_Desired__c = 50;
        insert acntConf2;
    
    Batch_Data_Custom__c bdc = new Batch_Data_Custom__c(Batch_Name__c = 'SF to NL Config Update Batch', Status__c = 'Completed', Account_ID__c = acc.Id);
    insert bdc;
    
            }
            @IsTest
            Public Static Void testAccount_Asset_ConfigError(){
                Account acnt = [Select Id from Account Limit 1];
                Test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockErrorHttpResponseGenerator());
                Configuration_Parameter_Callout.getParameter(null);
                String result = RedesignAC_AccountBtn_to_NL_Controller.getAccountId(acnt.ID);
                Test.stopTest();
            }
			@IsTest
			 Static Void testAccount_Asset_ConfigSuccess(){
                Account acnt = [Select Id from Account Limit 1];
                 Asset ast = [Select Id from Asset Where Name != 'Test' Limit 1];
                 Asset ast1 = [Select Id from Asset Where Name = 'Test' Limit 1];
                Test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator());
                Configuration_Parameter_Callout.getParameter(ast.Id);
                Configuration_Parameter_Callout.getParameter(ast1.Id);
                RedesignAC_AccountBtn_to_NL_Batch res = new RedesignAC_AccountBtn_to_NL_Batch(acnt.Id, acnt.Id);
                Test.stopTest();
            }
			private class MockErrorHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('OK');
			res.setBody('{"error": "MockError"}');
            return res;
        }
    }
	private class MockSuccessHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
			res.setBody('{"config":{"desired": {"location": {"useGPS": false,"sampling_period": 86400,"enabled": true,"useCell": true,\n"useWiFi": true\n},\n"network": {\n"period": 86400\n},\n"accelerometer": {\n"enabled": true,\n"mode": 3,\n"measurement_period": 86400,\n"tracking": {\n"bucket_size": 100,\n"bucket_fill_time": 50,\n"connect_on_movement_start": true,\n"locations_per_checkin": 1,\n"inactivity_before_movement_end": 900,\n"location_period": 14400,\n"connect_on_movement_end": true,\n"lower_accel_threshold": 50\n},\n"tilt": {\n"degrees": 15,\n"connect_on_tilt": false,\n"log_every_n": 0,\n"reference_z": 0,\n"reference_x": 0,\n"reference_y": 0\n}\n},\n"temperature": {\n"enabled": false,\n"sampling_period": 86400\n},\n"ble": {\n"enabled": false,\n"sampling_period": 300\n}\n}}');
            return res;
        }
    }
}