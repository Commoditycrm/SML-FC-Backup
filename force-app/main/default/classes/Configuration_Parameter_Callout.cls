public class Configuration_Parameter_Callout {
    
    @AuraEnabled
    public static string getParameter(Id recordId) {
        try {
            String returnString;
             String batchDataCustomStr = 'SF to NL Config Update Batch';
            List<Batch_Data_Custom__c> batchData = [select Id, Batch_Name__c from Batch_Data_Custom__c where 
                                                    Batch_Name__c = :batchDataCustomStr and Status__c = 'Processing'];
            if(batchData.size() > 0) {
                return 'batch-already-running';
            }
            List<Asset_Configuration__c> accAssetConfigLst = [select id,name, Asset__c,Device_Id__c,Measurement_Period_desired__c, Asset__r.Account.Device_Ownership__c, Asset__r.Account.Account_Unique1_ID__c,
                                                              Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c,
                                                              ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                                                              Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                                                              Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c, 
                                                              Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c
                                                              from Asset_Configuration__c where Asset__c =:recordId and recordType.DeveloperName = 'Asset' LIMIT 1];
            if(accAssetConfigLst.size() > 0){
            String DeviceType = accAssetConfigLst[0].Asset__r.Account.Device_Ownership__c == 'Leased' ? accAssetConfigLst[0].Asset__r.Account.Device_Ownership__c : accAssetConfigLst[0].Asset__r.Account.Account_Unique1_ID__c ;
            string token = Utilityclass.generatetoken(DeviceType);
            string authorize = 'Bearer'+' '+ token;
            RedesignAC_Callout_SF_to_NL.RestAPIResponseResult response = RedesignAC_Callout_SF_to_NL.getParameter(accAssetConfigLst[0], authorize, accAssetConfigLst[0].device_id__c);   
            returnString = response== null ? 'No response From server': response.message;
            }else{
                returnString = 'No Configuration found';
            }
            return returnString;
            
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'Configuration_Parameter_Callout', 'getParameter', null, null, null, true);                        
        }
        return null;
    }
}