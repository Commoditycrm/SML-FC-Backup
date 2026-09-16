global class RedesignAC_UpdateConfigBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Id accId;
    private Boolean individualConfig;
    private Asset_Configuration__c acntConfVal;

    public RedesignAC_UpdateConfigBatch(Id accId, Boolean individualConfig) {
        this.accId = accId;
        this.individualConfig = individualConfig;

        List<Asset_Configuration__c> defaultAcntConfLst = [
            SELECT Accelerometer_Status_Desired__c, Config_Change__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                   ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Account__c, 
                   Log_Every_n_Desired__c, Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, 
                   Reference_Y_Desired__c, Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, 
                   Tilt_Degrees_Desired__c, Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, 
                   Trackmode_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c, Use_WiFi_Desired__c, Impact_Alert_Desired__c, 
                   Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                   Tag_Detection_Desired__c, Min_RSSI_Desired__c, Missing_Tag_Report_Delay_Desired__c, 
                   Scan_for_Tags_Interval_Desired__c, Listen_Time_Desired__c, Distance_Status_Desired__c, 
                   Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, 
                   Alert_Threshold_High_Desired__c, Alert_Count_Desired__c, Ignore_Errors_Desired__c, LastModifiedDate, 
                   Log_Every_n_Samples_Desired__c, Skip_While_Moving_Desired__c, RecordType.DeveloperName 
            FROM Asset_Configuration__c 
            WHERE Account__c = :accId AND RecordType.DeveloperName = 'Default'
            LIMIT 1
        ];
        List<Asset_Configuration__c> IndividualAcntConfLst = [
            SELECT Accelerometer_Status_Desired__c, Config_Change__c, Connect_On_Tilt_Desired__c, ConnectMovementEnd_Desired__c, 
                   ConnectMovementStart_Desired__c, Location_Sampling_Period_Desired__c, Location_Status_Desired__c, Account__c, 
                   Log_Every_n_Desired__c, Measurement_Period_desired__c, Network_Check_in_period_Desired__c, Reference_X_Desired__c, 
                   Reference_Y_Desired__c, Reference_Z_Desired__c, Temperature_Check_in_Period_Desired__c, Temperature_Status_Desired__c, 
                   Tilt_Degrees_Desired__c, Tracking_Location_Period_desired__c, Tracking_Locations_per_Check_Ins_Desired__c, 
                   Trackmode_Desired__c, Use_Cell_Desired__c, Use_GPS_Desired__c, Use_WiFi_Desired__c, Impact_Alert_Desired__c, 
                   Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                   Tag_Detection_Desired__c, Min_RSSI_Desired__c, Missing_Tag_Report_Delay_Desired__c, 
                   Scan_for_Tags_Interval_Desired__c, Listen_Time_Desired__c, Distance_Status_Desired__c, 
                   Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, 
                   Alert_Threshold_High_Desired__c, Alert_Count_Desired__c, Ignore_Errors_Desired__c, LastModifiedDate, 
                   Log_Every_n_Samples_Desired__c, Skip_While_Moving_Desired__c, RecordType.DeveloperName 
            FROM Asset_Configuration__c 
            WHERE Account__c = :accId AND RecordType.DeveloperName = 'Account'
            LIMIT 1
        ];

        List<Asset_Configuration__c> acntConfLst;

        if(!IndividualAcntConfLst.isEmpty()) {
            acntConfLst = defaultAcntConfLst[0].LastModifiedDate > IndividualAcntConfLst[0].LastModifiedDate ? defaultAcntConfLst : IndividualAcntConfLst;
        } else {
            acntConfLst = defaultAcntConfLst;
        }
        if (!acntConfLst.isEmpty()) {
            acntConfVal = acntConfLst[0];
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        List<Asset_Configuration__c> astConList = [SELECT Id FROM Asset_Configuration__c WHERE Asset__r.Current_Location__c = :accId AND RecordType.DeveloperName = 'Asset' LIMIT 1];
        /*if (!astConList.isEmpty()) {
            query = 'SELECT Id FROM Asset_Configuration__c WHERE Asset__r.AccountId = :accId AND RecordType.DeveloperName = \'Asset\'';
        }else {
            query = 'SELECT Id FROM Asset_Configuration__c WHERE Asset__r.Current_Location__c = :accId AND RecordType.DeveloperName = \'Asset\'';
        }*/
        if(acntConfVal.RecordType.DeveloperName == 'Default') {
            query = 'SELECT Id FROM Asset_Configuration__c WHERE (Asset__r.AccountId = :accId OR Asset__r.Current_Location__c = :accId) AND RecordType.DeveloperName = \'Asset\' AND Configuration_Followed__c = \'Upstream\'';
        } else {
            query = 'SELECT Id FROM Asset_Configuration__c WHERE Asset__r.Current_Location__c = :accId AND RecordType.DeveloperName = \'Asset\'';
        }
        if (individualConfig == false) {
            query += ' AND Individual_Config__c = false';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset_Configuration__c> scope) {
        for (Asset_Configuration__c astCon : scope) {
            astCon.Accelerometer_Status_Desired__c = acntConfVal.Accelerometer_Status_Desired__c;
            astCon.Config_Change__c = acntConfVal.Config_Change__c;
            astCon.Connect_On_Tilt_Desired__c = acntConfVal.Connect_On_Tilt_Desired__c;
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
            astCon.Individual_Config__c = false;
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
            astCon.Skip_While_Moving_Desired__c = acntConfVal.Skip_While_Moving_Desired__c;
            astCon.Configuration_Followed__c = acntConfVal.RecordType.DeveloperName == 'Account' ? 'Downstream' : 'Upstream';
            astCon.Current_Account_Name__c = acntConfVal.Account__c;
            astCon.NLResponseStatus__c = 'Pending';
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: log or notify
    }
}