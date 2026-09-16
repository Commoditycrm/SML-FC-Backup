@isTest
public class testRedesignNL_AssetTriggerHandler {
    
 @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
     
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
     
     	Product2 prd = new Product2();
     	prd.name = 'AT2';
     	insert prd;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
     
     ast.Product2Id = prd.Id;
     update ast;
     
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
        Id AssetRecType = Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByDeveloperName().get('Asset').getRecordTypeId();
      
        Asset ast = [Select id from Asset limit 1];
        Account Acc = [Select id from Account limit 1];
        Asset_Configuration__c asconfig = [select id,recordtypeId,Asset__c from Asset_Configuration__c where Account__c =:Acc.id limit 1];
        asconfig.RecordTypeId = AssetRecType;
        asconfig.Asset__c = ast.id;
        asconfig.Account__c = null;
        update  asconfig;
        Map<id,Asset> oldMap = New Map<id,Asset>();
        oldMap.put(ast.id,ast);
        
        Map<id,Asset> newMap = New Map<id,Asset>();
        oldMap.put(ast.id,ast);
        List<Asset> astList = new List<Asset>{ast};
        Test.startTest();
        RedesignNL_AssetTriggerHandler.createAssetConfiguationRecord(astList);
        RedesignNL_AssetTriggerHandler.updateAssetConfig(oldMap,newMap);
        Test.stopTest();
    }
      @isTest
    static void testCreateAssetConfiguationRecord1() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Source_Account__c = 'SA-12345'
        );
        insert testAccount;

        Asset testAsset = new Asset(
            Name = 'Test Asset',
            AccountId = testAccount.Id
        );
        insert testAsset;

        Asset_Configuration__c existingConfig = new Asset_Configuration__c(
            Account__c = testAccount.Id,
            RecordTypeId = Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
            Accelerometer_Status_Desired__c = 'true',
            Use_Cell_Desired__c = 'true'
        );
        insert existingConfig;

        // Call the method to test
        Test.startTest();
        RedesignNL_AssetTriggerHandler.createAssetConfiguationRecord(new List<Asset>{ testAsset });
        //updateAssetConfiguration batchInstance = new updateAssetConfiguration();
        //Database.executeBatch(batchInstance, 5); //
        Test.stopTest();

    }

    @isTest
    static void testUpdateAssetConfig() {
        // Create test data
        Account oldAccount = new Account(
            Name = 'Old Account',
            Source_Account__c = 'SA-Old123'
        );
        insert oldAccount;

        Account newAccount = new Account(
            Name = 'New Account',
            Source_Account__c = 'SA-New123'
        );
        insert newAccount;

        Asset testAsset = new Asset(
            Name = 'Test Asset',
            AccountId = oldAccount.Id
        );
        insert testAsset;

        Asset_Configuration__c testConfig = new Asset_Configuration__c(
            Asset__c = testAsset.Id,
            Account_Unique_ID__c = oldAccount.Account_ID__c,
            Account_Source_ID__c = oldAccount.Source_Account__c
        );
        insert testConfig;

        // Simulate an update
        testAsset.AccountId = newAccount.Id;

        Test.startTest();
        Map<Id, Asset> oldMap = new Map<Id, Asset>{ testAsset.Id => testAsset };
        Map<Id, Asset> newMap = new Map<Id, Asset>{ testAsset.Id => testAsset };
        RedesignNL_AssetTriggerHandler.updateAssetConfig(oldMap, newMap);
        Test.stopTest();

    }
}