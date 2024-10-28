@isTest
public class testRedesignNL_AssetTriggerHandler {
 @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
     
     RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
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
        insert acntConf;
 }
    @isTest
    static void testCreateAssetConfiguationRecord(){
        Asset ast = [Select id from Asset limit 1];
        List<Asset> astList = new List<Asset>{ast};
        Test.startTest();
        RedesignNL_AssetTriggerHandler.createAssetConfiguationRecord(astList);
        Test.stopTest();
    }
    
    @isTest
    static void testDuplicateConfig(){
        Asset ast = [Select id from Asset limit 1];
        List<Asset> astList = new List<Asset>{ast};
        Test.startTest();
        RedesignNL_AssetTriggerHandler.createAssetConfiguationRecord(astList);
        Test.stopTest();
    }
}