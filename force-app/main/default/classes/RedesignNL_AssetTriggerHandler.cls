public class RedesignNL_AssetTriggerHandler {
    
    Public static void createAssetConfiguationRecord(List<Asset> assetList) {
        try {
            String assetId = '';
            for(Asset st : assetList) {
                assetId = st.Id;
            }
            List<Asset_Configuration__c> acntConfLst = [Select Id, Name, Accelerometer_Status_Desired__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                                                        ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Log_Every_n_Desired__c,
                                                        Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c,
                                                        Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, Tilt_Degrees_Desired__c,
                                                        Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, Trackmode_Desired__c, Use_Cell_Desired__c,
                                                        Use_GPS_Desired__c, Use_WiFi_Desired__c 
                                                        from Asset_Configuration__c 
                                                        where Account__r.Name = 'Testing' 
                                                        and RecordType.DeveloperName = 'Account'];
            Asset_Configuration__c acntConfVal = (acntConfLst.size()!=0 ? acntConfLst[0] : null);
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
            astCon.NLResponseStatus__c = 'Pending';
            insert astCon;
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_AssetTriggerHandler', 'createAssetConfiguationRecord', null, null, null, false);
        }
    }
    
}