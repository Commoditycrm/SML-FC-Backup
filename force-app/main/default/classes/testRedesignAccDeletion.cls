@isTest
private class testRedesignAccDeletion {
    @isTest
    static void testCreateAssetHistoryCustomRecords() {
        // Step 1: Create an Account record
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.ShippingLatitude = 42.59104532;
        acc.ShippingLongitude = -83.55054479;
        acc.Capture_Business_Name__c = true;
        acc.Replaced_Account__c = 'In Transit';
        acc.UpdateRecords__c = true;
        insert acc;
        // Step 1.1: Create an Account record
        Account acc1 = new Account();
        acc1.Name = 'Testing1';
        acc1.GeoFence_Radius_in_Miles__c = 20;
        acc1.ShippingLatitude = 42.59104532;
        acc1.ShippingLongitude = -83.55054479;
        acc1.Capture_Business_Name__c = true;
        insert acc1;

        // Step 2: Create Asset Configuration record type
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        
        // Step 3: Create Asset Configuration record
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Account__c = acc.Id;
        astCon.RecordTypeId = AccountRecType.Id;
        astCon.Accelerometer_Status_Desired__c = 'true';
        astCon.Connect_On_Tilt_Desired__c = 'true';
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
        insert astCon;

        // Step 4: Create an Asset record
        Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc1.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;

        // Step 5: Create Related Customer record
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc1.Id;
        rc.Related_To__c = acc.id;
        insert rc;

        // Step 6: Create Asset_History_Custom__c records based on provided data
        List<Asset_History_Custom__c> assetHistoryRecords = new List<Asset_History_Custom__c>();

        // Example data based on screenshot, each record represents a row in the data
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            Location__c = 'In Transit - Ever',
            currentLocationId__c = acc.Id,
            In_Transit_Ever_Check__c = false,
            Still_in_transit__c = true,
            Last_Known_Location_Lookup__c = acc.Id,
            Consider_for_Dwell__c = false,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        ));

        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            Location__c = 'In Transit',
            currentLocationId__c = acc.Id,
            Still_in_this_Location__c = true,
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = false,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));
        
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 10, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            Location__c = 'In Transit',
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = false,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc1.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 10, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            Location__c = 'hi',
            currentLocationId__c = acc1.Id,
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = true,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc1.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));

        // Repeat similar creation for each record in the screenshot

        insert assetHistoryRecords;
		 RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = 'test';
        apc.CurrentLocationId__c = acc.Id;
        apc.Location__c = acc.Name;
        apc.PowerUptime__c = 12345;
        apc.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc.RecordTypeId = locationRecordType.Id;
        insert apc;
        // Assertions can be added here to verify the inserted records
    
        Database.ExecuteBatch(new RedesignNL_PauseAssetForAccDeletion(),1);
    }
    
    @isTest
    static void testCreateAssetHistoryCustomRecords1() {
        // Step 1: Create an Account record
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.ShippingLatitude = 42.59104532;
        acc.ShippingLongitude = -83.55054479;
        acc.Capture_Business_Name__c = true;
        acc.Replaced_Account__c = 'In Transit';
        acc.UpdateRecords__c = true;
        insert acc;
        // Step 1.1: Create an Account record
        Account acc1 = new Account();
        acc1.Name = 'Testing1';
        acc1.GeoFence_Radius_in_Miles__c = 20;
        acc1.ShippingLatitude = 42.59104532;
        acc1.ShippingLongitude = -83.55054479;
        acc1.Capture_Business_Name__c = true;
        insert acc1;

        // Step 2: Create Asset Configuration record type
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        
        // Step 3: Create Asset Configuration record
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Account__c = acc.Id;
        astCon.RecordTypeId = AccountRecType.Id;
        astCon.Accelerometer_Status_Desired__c = 'true';
        astCon.Connect_On_Tilt_Desired__c = 'true';
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
        insert astCon;

        // Step 4: Create an Asset record
        Asset ast = new Asset();
        ast.Name = 'at5-sd4-testing'; 
        ast.Device_Id__c = 'at5-sd4-testing';
        ast.AccountId = acc1.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;

        // Step 5: Create Related Customer record
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc1.Id;
        rc.Related_To__c = acc.id;
        insert rc;

        // Step 6: Create Asset_History_Custom__c records based on provided data
        List<Asset_History_Custom__c> assetHistoryRecords = new List<Asset_History_Custom__c>();

        // Example data based on screenshot, each record represents a row in the data
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            Location__c = 'In Transit - Ever',
            currentLocationId__c = acc.Id,
            In_Transit_Ever_Check__c = false,
            Still_in_transit__c = true,
            Last_Known_Location_Lookup__c = acc.Id,
            Consider_for_Dwell__c = false,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype)
        ));

        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 30, 4, 38, 36),
            Location__c = 'In Transit',
            currentLocationId__c = acc.Id,
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = false,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));
        
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 10, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            Location__c = 'In Transit',
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = false,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc1.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.newInstance(2024, 10, 10, 4, 38, 36),
            End_Time__c = Datetime.newInstance(2024, 10, 15, 4, 38, 36),
            Location__c = 'hi',
            currentLocationId__c = acc1.Id,
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = true,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc1.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));
        
        assetHistoryRecords.add(new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now(),
            Location__c = 'hi',
            currentLocationId__c = acc1.Id,
            In_Transit_Ever_Check__c = true,
            Still_in_transit__c = true,
            Still_in_this_Location__c = true,
            Last_Known_Location__c= 'hi',
            Last_Known_Location_Lookup__c = acc1.Id,
            Consider_for_Dwell__c = true,
            RecordTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype)
        ));

        // Repeat similar creation for each record in the screenshot

        insert assetHistoryRecords;
		 RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = 'test';
        apc.CurrentLocationId__c = acc.Id;
        apc.Location__c = acc.Name;
        apc.PowerUptime__c = 12345;
        apc.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc.RecordTypeId = locationRecordType.Id;
        insert apc;
        // Assertions can be added here to verify the inserted records
    
        Database.ExecuteBatch(new RedesignNL_UpdateAccForAHCAst(),1);
    }
    
}