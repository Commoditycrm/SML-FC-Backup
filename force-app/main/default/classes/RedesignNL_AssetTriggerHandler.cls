public class RedesignNL_AssetTriggerHandler {

    private static Boolean isUpdatingActionNeeded = false;
    
    Public static void createAssetConfiguationRecord(List<Asset> assetList) {
        try {
            String assetId = '';
            string AccountId = '';
            for(Asset st : assetList) {
                updateAssetCount(null, st.AccountId);
                if(st.Is_Chorus_Asset__c || st.Is_M2MD__c)
                    return;
                if(st.Product_Name__c != 'Tag-e4bl-1-0')
                	assetId = st.Id;
                AccountId = st.AccountId;
            }
            List<Account> acLIst = [select id,Account_ID__c ,Source_Account__c  from Account where id=:AccountId];
            List<Asset_Configuration__c> acntConfLst = [SELECT Id, Name, Accelerometer_Status_Desired__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                                                        ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Log_Every_n_Desired__c,
                                                        Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c,
                                                        Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Tilt_Degrees_Desired__c,
                                                        Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Trackmode_Desired__c, Use_Cell_Desired__c,
                                                        Use_GPS_Desired__c, Use_WiFi_Desired__c, Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c,
                                                        Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, Tag_Detection_Desired__c, Min_RSSI_Desired__c,
                                                        Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, Distance_Status_Desired__c,
                                                        Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c,
                                                        Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_n_Samples_Desired__c, Account__c 
                                                        FROM Asset_Configuration__c 
                                                        WHERE Account__r.Name = 'Testing' 
                                                        AND RecordType.DeveloperName = 'Account'];
            Asset_Configuration__c acntConfVal = (acntConfLst.size()!=0 ? acntConfLst[0] : null);
            system.debug(acntConfVal);
            Asset_Configuration__c astCon = new Asset_Configuration__c();
            astCon.Asset__c = assetId;
            astCon.RecordTypeId=Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
            astCon.Accelerometer_Status_Desired__c = acntConfVal.Accelerometer_Status_Desired__c;
            astCon.Connect_On_Tilt_Desired__c      = acntConfVal.Connect_On_Tilt_Desired__c;
            astCon.ConnectMovementEnd_Desired__c = acntConfVal.ConnectMovementEnd_Desired__c;
            astCon.ConnectMovementStart_Desired__c = acntConfVal.ConnectMovementStart_Desired__c;
            astCon.Location_Sampling_Period_Desired__c = acntConfVal.Location_Sampling_Period_Desired__c;
            astCon.Location_Status_Desired__c = acntConfVal.Location_Status_Desired__c;
            astCon.Log_Every_n_Desired__c = acntConfVal.Log_Every_n_Desired__c;
            astCon.Measurement_Period_desired__c = acntConfVal.Measurement_Period_desired__c;
            astCon.Network_Check_in_period_Desired__c = acntConfVal.Network_Check_in_period_Desired__c;
            astCon.Reference_X_Desired__c = acntConfVal.Reference_X_Desired__c;
            astCon.Reference_Y_Desired__c = acntConfVal.Reference_Y_Desired__c;
            astCon.Reference_Z_Desired__c = acntConfVal.Reference_Z_Desired__c;
            astCon.Temperature_Check_in_Period_Desired__c = acntConfVal.Temperature_Check_in_Period_Desired__c;
            astCon.Temperature_Status_Desired__c = acntConfVal.Temperature_Status_Desired__c;
            astCon.Tilt_Degrees_Desired__c = acntConfVal.Tilt_Degrees_Desired__c;
            astCon.Tracking_Location_Period_desired__c = acntConfVal.Tracking_Location_Period_desired__c;
            astCon.Tracking_Locations_per_Check_Ins_Desired__c = acntConfVal.Tracking_Locations_per_Check_Ins_Desired__c;
            astCon.Trackmode_Desired__c = acntConfVal.Trackmode_Desired__c;
            astCon.Use_Cell_Desired__c = acntConfVal.Use_Cell_Desired__c;
            astCon.Use_GPS_Desired__c = acntConfVal.Use_GPS_Desired__c;
            astCon.Use_WiFi_Desired__c = acntConfVal.Use_WiFi_Desired__c;
            astCon.Individual_config__c = false;
            astCon.Impact_Alert_Desired__c = acntConfVal.Impact_Alert_Desired__c;
            astCon.Max_Impact_Desired__c = acntConfVal.Max_Impact_Desired__c;
            astCon.Movement_Accuracy_Desired__c = acntConfVal.Movement_Accuracy_Desired__c;
            astCon.Location_Accuracy_Desired__c = acntConfVal.Location_Accuracy_Desired__c;
            astCon.Sensor_Logging_Period_Desired__c = acntConfVal.Sensor_Logging_Period_Desired__c;
            astCon.Tag_Detection_Desired__c = acntConfVal.Tag_Detection_Desired__c;
            astCon.Min_RSSI_Desired__c = acntConfVal.Min_RSSI_Desired__c;
            astCon.Missing_Tag_Report_Delay_Desired__c = acntConfVal.Missing_Tag_Report_Delay_Desired__c;
            astCon.Scan_for_Tags_Interval_Desired__c = acntConfVal.Scan_for_Tags_Interval_Desired__c;
            astCon.Listen_Time_Desired__c = acntConfVal.Listen_Time_Desired__c;
            astCon.Distance_Status_Desired__c = acntConfVal.Distance_Status_Desired__c;
            astCon.Distance_Sampling_Period_Desired__c = acntConfVal.Distance_Sampling_Period_Desired__c;
            astCon.Connect_on_Alert_Desired__c = acntConfVal.Connect_on_Alert_Desired__c;
            astCon.Alert_Threshold_Low_Desired__c = acntConfVal.Alert_Threshold_Low_Desired__c;
            astCon.Alert_Threshold_High_Desired__c = acntConfVal.Alert_Threshold_High_Desired__c;
            astCon.Alert_Count_Desired__c = acntConfVal.Alert_Count_Desired__c;
            astCon.Ignore_Errors_Desired__c = acntConfVal.Ignore_Errors_Desired__c;
            astCon.Log_Every_n_Samples_Desired__c = acntConfVal.Log_Every_n_Samples_Desired__c;
            astCon.NLResponseStatus__c = 'Pending';
            astCon.Configuration_followed__c = 'Upstream';
            astCon.Current_Account_Name__c = acntConfVal.Account__c;
            astCon.Account_Source_ID__c =  acLIst.size()>0 ? acLIst[0].Source_Account__c : null;
            astCon.Account_Unique_ID__c = acLIst.size()>0 ? acLIst[0].Account_ID__c : null;
            insert astCon;
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_AssetTriggerHandler', 'createAssetConfiguationRecord', null, null, null, false);
        }
    }
    public static void updateAssetConfig(Map<id,Asset> oldMap,Map<id,Asset> NewMap){
        try {
            List<id> assIdList = New  List<id>();
            for (Id assetId : NewMap.keySet()) {
                id newParentAcc = NewMap.get(assetId).AccountId ;
                id oldParentAcc = oldMap.get(assetId).AccountId ;
                if(newParentAcc !=oldParentAcc){
                    updateAssetCount(oldParentAcc, newParentAcc);
                    assIdList.add(assetId);
                }
            }
            if(assIdList.size()>0){
                Map<id,Asset> AssetMapdata = New Map<id,Asset>( [select id,Account.Account_ID__c ,Account.Source_Account__c  from Asset where Id IN :assIdList]);
                List<Asset_Configuration__c> AssetconfigList = [select id,Asset__c,Account_Source_ID__c , Account_Unique_ID__c , Account_UniqueID_formula__c from  Asset_Configuration__c
                                                                where Asset__c IN :assIdList];
                if(AssetconfigList.size()>0){
                    for(Asset_Configuration__c acL : AssetconfigList){
                        acL.Account_Source_ID__c = AssetMapdata.keyset().contains(acL.Asset__c) ? AssetMapdata.get(acL.Asset__c).Account.Source_Account__c : null;
                        acL.Account_Unique_ID__c = AssetMapdata.keyset().contains(acL.Asset__c) ? AssetMapdata.get(acL.Asset__c).Account.Account_ID__c :  null;
                    }
                    update AssetconfigList;
                }
            }
        } catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_AssetTriggerHandler', 'createAssetConfiguationRecord', null, null, null, false);
        }
    }

    public static void updateActionNeededAfterUpdate(List<Asset> newList) {
        if (isUpdatingActionNeeded) return;
        isUpdatingActionNeeded = true;

        List<Asset> toUpdate = new List<Asset>();

        for (Asset ast : newList) {
            // Only evaluate for AT2 / AT5 assets, and skip hard-stopped states
            if (ast.Product_Name__c == null) continue;
            if (!(ast.Product_Name__c.contains('AT2') || ast.Product_Name__c.contains('AT5'))) continue;
            if (ast.Action_Needed__c == 'Tag Destroyed' || ast.Action_Needed__c == 'RMA to SMART' || ast.Action_Needed__c == 'Confirm RA#') continue;

            String desired = computeActionNeeded(ast);

            // Only add to DML if value actually changes (null-safe compare)
            if ((desired == null && ast.Action_Needed__c == 'Replace Batteries') ||
                (desired == 'Replace Batteries' && desired != ast.Action_Needed__c)) {
                toUpdate.add(new Asset(Id = ast.Id, Action_Needed__c = desired));
            }
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (Exception ex) {
                RedesignNL_CaptureErrors.createErrorLogs(
                    ex, 'RedesignNL_AssetTriggerHandler', 'updateActionNeededAfterUpdate',
                    null, null, null, false
                );
            }
        }

        isUpdatingActionNeeded = false;
    }

    private static String computeActionNeeded(Asset ast) {
        Boolean lowEstPct      = (ast.est_Batterycalculate__c != null && ast.est_Batterycalculate__c < 15);
        Boolean lowVoltage     = (ast.Battery_Voltage__c      != null && ast.Battery_Voltage__c      < 5.9);
        Boolean scanMinusConn  = false;
        Boolean todayMinusConn = false;

        if (ast.Date_Shipped__c != null && ast.Last_connected__c != null) {
            Integer diff1 = ast.Last_connected__c.date().daysBetween(ast.Date_Shipped__c.date());
            scanMinusConn = diff1 > 30;
        }
        if (ast.Last_connected__c != null) {
            Integer diff2 = ast.Last_connected__c.date().daysBetween(Date.today());
            todayMinusConn = diff2 > 365;
        }

        if (lowEstPct || lowVoltage || scanMinusConn || todayMinusConn) {
            return 'Replace Batteries';
        }
        return null;
    }

    // Account Default config==
    Public static void createAccountConfiguationRecord(List<Related_Customer__c> accountList) {
        try {
            String sourceId = '';
            string relatedId = '';
            for(Related_Customer__c st : accountList) {
                	sourceId = st.Source_Account__c;
                relatedId = st.Related_To__c;
            }
            List<Account> acLIst = [select id,Account_ID__c ,Source_Account__c  from Account where id=:relatedId];
            List<Asset_Configuration__c> acntConfLst = [SELECT Id, Name, Accelerometer_Status_Desired__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                                                        ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Log_Every_n_Desired__c,
                                                        Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c,
                                                        Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Tilt_Degrees_Desired__c,
                                                        Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Trackmode_Desired__c, Use_Cell_Desired__c,
                                                        Use_GPS_Desired__c, Use_WiFi_Desired__c, Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c,
                                                        Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, Tag_Detection_Desired__c, Min_RSSI_Desired__c,
                                                        Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, Distance_Status_Desired__c,
                                                        Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c,
                                                        Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_n_Samples_Desired__c, Account__c 
                                                        FROM Asset_Configuration__c 
                                                        WHERE Account__c = :sourceId 
                                                        AND RecordType.DeveloperName = 'Default'];
            Asset_Configuration__c acntConfVal = (acntConfLst.size()!=0 ? acntConfLst[0] : null);
            system.debug(acntConfVal);
            if(acntConfVal == null) {

                Asset_Configuration__c locationConfig = [SELECT Id, Name, Accelerometer_Status_Desired__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                                                        ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Log_Every_n_Desired__c,
                                                        Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c,
                                                        Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Tilt_Degrees_Desired__c,
                                                        Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Trackmode_Desired__c, Use_Cell_Desired__c,
                                                        Use_GPS_Desired__c, Use_WiFi_Desired__c, Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c,
                                                        Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, Tag_Detection_Desired__c, Min_RSSI_Desired__c,
                                                        Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, Distance_Status_Desired__c,
                                                        Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c,
                                                        Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_n_Samples_Desired__c, Account__c 
                                                        FROM Asset_Configuration__c 
                                                        WHERE Account__c = :sourceId 
                                                        AND RecordType.DeveloperName = 'Account'];

                if(locationConfig != null){
                acntConfVal = new Asset_Configuration__c();
                acntConfVal.Account__c = sourceId;
                acntConfVal.Account_Unique_ID__c = acLIst.size()>0 ? acLIst[0].Account_ID__c : null;
                configSchema(acntConfVal, locationConfig);
                insert acntConfVal;
                acntConfVal.Account__c = relatedId;
                acntConfVal.Id = null;
                acntConfVal.Account_Unique_ID__c = acLIst.size()>0 ? acLIst[0].Account_ID__c : null;
                acntConfVal.Account_Source_ID__c =  acLIst.size()>0 ? acLIst[0].Source_Account__c : null;
                insert acntConfVal;
                }
            }else{
                Asset_Configuration__c astCon = new Asset_Configuration__c();
                astCon.Account__c = relatedId;
                configSchema(astCon, acntConfVal);
                astCon.Account_Source_ID__c =  acLIst.size()>0 ? acLIst[0].Source_Account__c : null;
                astCon.Account_Unique_ID__c = acLIst.size()>0 ? acLIst[0].Account_ID__c : null;
                insert astCon;
            }
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_AssetTriggerHandler', 'createAccountConfiguationRecord', null, null, null, false);
        }
    }

    private static void configSchema(Asset_Configuration__c targetConfig, Asset_Configuration__c sourceConfig) {
        targetConfig.RecordTypeId=Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        targetConfig.Accelerometer_Status_Desired__c = sourceConfig.Accelerometer_Status_Desired__c;
        targetConfig.Connect_On_Tilt_Desired__c      = sourceConfig.Connect_On_Tilt_Desired__c;
        targetConfig.ConnectMovementEnd_Desired__c = sourceConfig.ConnectMovementEnd_Desired__c;
        targetConfig.ConnectMovementStart_Desired__c = sourceConfig.ConnectMovementStart_Desired__c;
        targetConfig.Location_Sampling_Period_Desired__c = sourceConfig.Location_Sampling_Period_Desired__c;
        targetConfig.Location_Status_Desired__c = sourceConfig.Location_Status_Desired__c;
        targetConfig.Log_Every_n_Desired__c = sourceConfig.Log_Every_n_Desired__c;
        targetConfig.Measurement_Period_desired__c = sourceConfig.Measurement_Period_desired__c;
        targetConfig.Network_Check_in_period_Desired__c = sourceConfig.Network_Check_in_period_Desired__c;
        targetConfig.Reference_X_Desired__c = sourceConfig.Reference_X_Desired__c;
        targetConfig.Reference_Y_Desired__c = sourceConfig.Reference_Y_Desired__c;
        targetConfig.Reference_Z_Desired__c = sourceConfig.Reference_Z_Desired__c;
        targetConfig.Temperature_Check_in_Period_Desired__c = sourceConfig.Temperature_Check_in_Period_Desired__c;
        targetConfig.Temperature_Status_Desired__c = sourceConfig.Temperature_Status_Desired__c;
        targetConfig.Tilt_Degrees_Desired__c = sourceConfig.Tilt_Degrees_Desired__c;
        targetConfig.Tracking_Location_Period_desired__c = sourceConfig.Tracking_Location_Period_desired__c;
        targetConfig.Tracking_Locations_per_Check_Ins_Desired__c = sourceConfig.Tracking_Locations_per_Check_Ins_Desired__c;
        targetConfig.Trackmode_Desired__c = sourceConfig.Trackmode_Desired__c;
        targetConfig.Use_Cell_Desired__c = sourceConfig.Use_Cell_Desired__c;
        targetConfig.Use_GPS_Desired__c = sourceConfig.Use_GPS_Desired__c;
        targetConfig.Use_WiFi_Desired__c = sourceConfig.Use_WiFi_Desired__c;
        targetConfig.Impact_Alert_Desired__c = sourceConfig.Impact_Alert_Desired__c;
        targetConfig.Max_Impact_Desired__c = sourceConfig.Max_Impact_Desired__c;
        targetConfig.Movement_Accuracy_Desired__c = sourceConfig.Movement_Accuracy_Desired__c;
        targetConfig.Location_Accuracy_Desired__c = sourceConfig.Location_Accuracy_Desired__c;
        targetConfig.Sensor_Logging_Period_Desired__c = sourceConfig.Sensor_Logging_Period_Desired__c;
        targetConfig.Tag_Detection_Desired__c = sourceConfig.Tag_Detection_Desired__c;
        targetConfig.Min_RSSI_Desired__c = sourceConfig.Min_RSSI_Desired__c;
        targetConfig.Missing_Tag_Report_Delay_Desired__c = sourceConfig.Missing_Tag_Report_Delay_Desired__c;
        targetConfig.Scan_for_Tags_Interval_Desired__c = sourceConfig.Scan_for_Tags_Interval_Desired__c;
        targetConfig.Listen_Time_Desired__c = sourceConfig.Listen_Time_Desired__c;
        targetConfig.Distance_Status_Desired__c = sourceConfig.Distance_Status_Desired__c;
        targetConfig.Distance_Sampling_Period_Desired__c = sourceConfig.Distance_Sampling_Period_Desired__c;
        targetConfig.Connect_on_Alert_Desired__c = sourceConfig.Connect_on_Alert_Desired__c;
        targetConfig.Alert_Threshold_Low_Desired__c = sourceConfig.Alert_Threshold_Low_Desired__c;
        targetConfig.Alert_Threshold_High_Desired__c = sourceConfig.Alert_Threshold_High_Desired__c;
        targetConfig.Alert_Count_Desired__c = sourceConfig.Alert_Count_Desired__c;
        targetConfig.Ignore_Errors_Desired__c = sourceConfig.Ignore_Errors_Desired__c;
        targetConfig.Log_Every_n_Samples_Desired__c = sourceConfig.Log_Every_n_Samples_Desired__c;
        targetConfig.NLResponseStatus__c = 'Pending';
        targetConfig.Configuration_followed__c = 'Upstream';
        targetConfig.Current_Account_Name__c = sourceConfig.Account__c;
    }

    public static void updateAssetCount(Id oldParent, Id newParent) {
        if (oldParent != null) {
            Decimal oldCount = [SELECT Asset_Count__c FROM Account WHERE Id = :oldParent].Asset_Count__c;
            update new Account(Id = oldParent, Asset_Count__c = oldCount - 1);
        }
        if (newParent != null) {
            Decimal newCount = [SELECT Asset_Count__c FROM Account WHERE Id = :newParent].Asset_Count__c;
            update new Account(Id = newParent, Asset_Count__c = newCount + 1);
        }

    }
    
}