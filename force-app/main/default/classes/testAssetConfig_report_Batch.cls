@istest
public class testAssetConfig_report_Batch {
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'sfdxtest';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'at5-df'; 
        ast.Device_Id__c = 'at5-df';
        ast.AccountId = acc.Id;
        insert ast;
        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
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
        // Add more field assignments as needed
    	insert astCon;
        Asset_Config_Monthly_Batch__c astCon1 = new Asset_Config_Monthly_Batch__c();
        astCon1.Asset_Configuration__c = astCon.Id;
        astCon1.Master_Configuration_Check__c = true;
        astCon1.Location_Sampling_Period__c = '86421';
        insert astCon1;
    }
    @IsTest
    Public Static Void testRedesignAC_UpdateConfigFromFlow(){
       
        Asset_Configuration__c scope = [select id, Name, Accelerometer_Status_Desired__c,Accelerometer_Status_Reported__c, Account__c, Asset__c, ConnectMovementEnd_Desired__c, ConnectMovementEnd_Reported__c, ConnectMovementStart_Desired__c,
                                              ConnectMovementStart_Reported__c, Individual_config__c, Location_Sampling_Period_Desired__c, Location_Sampling_Period_Reported__c, Location_Status_Desired__c, Location_Status_Reported__c,
                                              Master_Configuration_Check__c, Measurement_Period_desired__c, Measurement_Period_Reported__c, Network_Check_in_period_Desired__c, Network_Check_in_period_Reported__c, NLResponseStatus__c,Temperature_Check_in_Period_Desired__c, Temperature_Check_in_Period_Reported__c,
                                              Temperature_Status_Desired__c, Temperature_Status_Reported__c, Tilt_Degrees_Desired__c, Tilt_Degrees_Reported__c, Tracking_Location_Period_desired__c, Tracking_Location_Period_Reported__c,
                                              Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Locations_per_Check_Ins_Reporte__c, Trackmode_Desired__c, Trackmode_Reported__c, Use_Cell_Desired__c, Use_Cell_Reported__c, Use_GPS_Desired__c,
                                              Use_GPS_Reported__c, Use_WiFi_Desired__c, Use_Wifi_Reported__c  from Asset_Configuration__c limit 1];
        
        Asset_Config_Monthly_Batch__c query1 =[select id,Asset_Configuration__c, Name, Accelerometer_Status__c,Accelerometer_Status_Reported__c, Account_Name__c, Asset_Name__c, ConnectMovementEnd__c, 
                                                     ConnectMovementEnd_Reported__c, ConnectMovementStart__c,ConnectMovementStart_Reported__c, Individual_config__c, Location_Sampling_Period__c, 
                                                     Location_Sampling_Period_Reported__c, Location_Status__c, Location_Status_Reported__c,Master_Configuration_Check__c, Measurement_Period__c, Measurement_Period_Reported__c, Network_Check_in_period__c, Network_Check_in_period_Reported__c, NL_Response_Status__c ,Temperature_Check_in_Period__c, 
                                                     Temperature_Check_in_Period_Reported__c,Temperature_Status__c, Temperature_Status_Reported__c, Tilt_Degrees__c, Tilt_Degrees_Reported__c, Tracking_Location_Period__c, Tracking_Location_Period_Reported__c,
                                                     Tracking_Locations_per_Check_Ins__c, Tracking_Locations_per_Check_Ins_Reporte__c, Trackmode__c, Trackmode_Reported__c, Use_Cell__c, Use_Cell_Reported__c, Use_GPS__c,
                                                     Use_GPS_Reported__c, Use_WiFi__c, Use_Wifi_Reported__c  from Asset_Config_Monthly_Batch__c where Latest_AC_history__c = true and Asset_Configuration__c =: scope.Id limit 1];
        Test.startTest();
        Database.ExecuteBatch(new AssetConfig_report_Batch());
        
        Test.stopTest();
    }
}