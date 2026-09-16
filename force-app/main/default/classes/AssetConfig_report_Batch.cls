global class AssetConfig_report_Batch implements Database.Batchable<sObject>, Database.Stateful,schedulable{
    
    //BatchLog fields
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    Public DateTime DeleteDate;
    public  boolean afterRun;
    public String addQuery;
    global AssetConfig_report_Batch(){
        this.addQuery=' where Master_Configuration_Check__c = true Order by CreatedDate desc';
        this.afterRun= True;
    }
    global AssetConfig_report_Batch(date Curdt){
        String dtValue = string.valueOf(Curdt);
        this.addQuery=' where callout_date__c = '+ dtValue +' Order by CreatedDate desc ';
        this.afterRun= False;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';
        this.batchStartTime = System.Now();
        String query = 'select id, Name, Accelerometer_Status_Desired__c,Accelerometer_Status_Reported__c, Account__c, Asset__c, ConnectMovementEnd_Desired__c, ConnectMovementEnd_Reported__c, ConnectMovementStart_Desired__c,'+
            ' ConnectMovementStart_Reported__c, Individual_config__c, Location_Sampling_Period_Desired__c, Location_Sampling_Period_Reported__c, Location_Status_Desired__c, Location_Status_Reported__c,'+
            ' Master_Configuration_Check__c, Measurement_Period_desired__c, Measurement_Period_Reported__c, Network_Check_in_period_Desired__c, Network_Check_in_period_Reported__c, NLResponseStatus__c,Temperature_Check_in_Period_Desired__c, Temperature_Check_in_Period_Reported__c,'+
            ' Temperature_Status_Desired__c, Temperature_Status_Reported__c, Tilt_Degrees_Desired__c, Tilt_Degrees_Reported__c, Tracking_Location_Period_desired__c, Tracking_Location_Period_Reported__c,'+
            ' Tracking_Locations_per_Check_Ins_Desired__c, Tracking_Locations_per_Check_Ins_Reporte__c, Trackmode_Desired__c, Trackmode_Reported__c, Use_Cell_Desired__c, Use_Cell_Reported__c, Use_GPS_Desired__c,'+
            ' Use_GPS_Reported__c, Use_WiFi_Desired__c, Use_Wifi_Reported__c  from Asset_Configuration__c ';
        if(this.addQuery != null)
            query+= addQuery;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset_Configuration__c> scope) {
        List<Asset_Config_Monthly_Batch__c> asstConfig = new List<Asset_Config_Monthly_Batch__c>();
        List<Asset_Config_Monthly_Batch__c> assetConfigBatch_Rec = new List<Asset_Config_Monthly_Batch__c>();
        Map<id,Asset_Config_Monthly_Batch__c>achMap =new Map<id,Asset_Config_Monthly_Batch__c>();
        try{ string query ='select id,Asset_Configuration__c, Name, Accelerometer_Status__c,Accelerometer_Status_Reported__c, Account_Name__c, Asset_Name__c, ConnectMovementEnd__c, ConnectMovementEnd_Reported__c, ConnectMovementStart__c,'+
            ' ConnectMovementStart_Reported__c, Individual_config__c, Location_Sampling_Period__c, Location_Sampling_Period_Reported__c, Location_Status__c, Location_Status_Reported__c,'+
            ' Master_Configuration_Check__c, Measurement_Period__c, Measurement_Period_Reported__c, Network_Check_in_period__c, Network_Check_in_period_Reported__c, NL_Response_Status__c ,Temperature_Check_in_Period__c, Temperature_Check_in_Period_Reported__c,'+
            ' Temperature_Status__c, Temperature_Status_Reported__c, Tilt_Degrees__c, Tilt_Degrees_Reported__c, Tracking_Location_Period__c, Tracking_Location_Period_Reported__c,'+
            ' Tracking_Locations_per_Check_Ins__c, Tracking_Locations_per_Check_Ins_Reporte__c, Trackmode__c, Trackmode_Reported__c, Use_Cell__c, Use_Cell_Reported__c, Use_GPS__c,'+
            ' Use_GPS_Reported__c, Use_WiFi__c, Use_Wifi_Reported__c  from Asset_Config_Monthly_Batch__c where Latest_AC_history__c = true and Asset_Configuration__c in: scope';
            assetConfigBatch_Rec = database.query(query);
           }
        catch(exception e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'AssetConfig_report_Batch', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('AssetConfig_report_Batch - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            this.batchStatus = 'Failed';
        }
        for (Asset_Config_Monthly_Batch__c ach :assetConfigBatch_Rec){
            achMap.put(ach.Asset_Configuration__c,ach);
        }
        
        for (Asset_Configuration__c asst_config : scope){
            Asset_Config_Monthly_Batch__c asst = new Asset_Config_Monthly_Batch__c();
            Asset_Config_Monthly_Batch__c achRec = new Asset_Config_Monthly_Batch__c();
            boolean flag =False;
            if (achMap.containsKey(asst_config.Id)){
            achRec=achMap.get(asst_config.Id);
            flag=RecordCheck(achRec,asst_config);
            }
            else flag=True;
            if(flag==True){
                asst.Asset_Name__c = asst_config.Asset__c ;
                asst.Account_Name__c = asst_config.Account__c ;
                asst.Asset_Configuration__c = asst_config.id ;
                asst.Master_Configuration_Check__c = asst_config.Master_Configuration_Check__c ;
                asst.Individual_config__c = asst_config.Individual_config__c ;
                asst.NL_Response_Status__c = asst_config.NLResponseStatus__c ;
                asst.Accelerometer_Status__c = asst_config.Accelerometer_Status_Desired__c  ;
                asst.Accelerometer_Status_Reported__c = asst_config.Accelerometer_Status_Reported__c ;
                asst.ConnectMovementStart__c = asst_config.ConnectMovementStart_Desired__c  ;
                asst.ConnectMovementStart_Reported__c = asst_config.ConnectMovementStart_Reported__c ;
                asst.ConnectMovementEnd__c = asst_config.ConnectMovementEnd_Desired__c  ;
                asst.ConnectMovementEnd_Reported__c= asst_config.ConnectMovementEnd_Reported__c ;
                asst.Location_Sampling_Period__c = asst_config.Location_Sampling_Period_Desired__c  ;
                asst.Location_Sampling_Period_Reported__c = asst_config.Location_Sampling_Period_Reported__c ;
                asst.Location_Status__c = asst_config.Location_Status_Desired__c ;
                asst.Location_Status_Reported__c = asst_config.Location_Status_Reported__c ;
                asst.Measurement_Period__c = asst_config.Measurement_Period_desired__c  ;
                asst.Measurement_Period_Reported__c = asst_config.Measurement_Period_Reported__c ;
                asst.Network_Check_in_period__c = asst_config.Network_Check_in_period_Desired__c ;
                asst.Network_Check_in_period_Reported__c = asst_config.Network_Check_in_period_Reported__c ;
                asst.Temperature_Check_in_Period__c = asst_config.Temperature_Check_in_Period_Desired__c  ;
                asst.Temperature_Check_in_Period_Reported__c = asst_config.Temperature_Check_in_Period_Reported__c ;
                asst.Temperature_Status__c = asst_config.Temperature_Status_Desired__c  ;
                asst.Temperature_Status_Reported__c = asst_config.Temperature_Status_Reported__c ;
                asst.Tilt_Degrees__c = asst_config.Tilt_Degrees_Desired__c	 ;
                asst.Tilt_Degrees_Reported__c = asst_config.Tilt_Degrees_Reported__c ;
                asst.Tracking_Location_Period__c = asst_config.Tracking_Location_Period_desired__c  ;
                asst.Tracking_Location_Period_Reported__c = asst_config.Tracking_Location_Period_Reported__c ;
                asst.Tracking_Locations_per_Check_Ins__c = asst_config.Tracking_Locations_per_Check_Ins_Desired__c  ;
                asst.Tracking_Locations_per_Check_Ins_Reporte__c = asst_config.Tracking_Locations_per_Check_Ins_Reporte__c ;
                asst.Trackmode__c = asst_config.Trackmode_Desired__c  ;
                asst.Trackmode_Reported__c = asst_config.Trackmode_Reported__c ;
                asst.Use_Cell__c = asst_config.Use_Cell_Desired__c  ;
                asst.Use_Cell_Reported__c = asst_config.Use_Cell_Reported__c ;
                asst.Use_GPS__c = asst_config.Use_GPS_Desired__c  ;
                asst.Use_GPS_Reported__c = asst_config.Use_GPS_Reported__c ;
                asst.Use_WiFi__c = asst_config.Use_WiFi_Desired__c  ;
                asst.Use_Wifi_Reported__c = asst_config.Use_Wifi_Reported__c;
                asstConfig.add(asst);
            }
        }
        try{
            insert asstConfig;
        }
        catch(exception e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'AssetConfig_report_Batch', 'execute', 'DML Error', null, null, true);
            failureMsgs.add('AssetConfig_report_Batch - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            this.batchStatus = 'Failed';
        }
    }
    global void finish(Database.BatchableContext bC) { 
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC, null, 'RedesignNL_DeleteARCLoc', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        if(afterRun == True){
        	Database.ExecuteBatch(new RedesignAC_NL_to_SF_CalloutBatch('MonthQuery'),95);
        }
        //Add the AHC execute line here
    }
    global boolean RecordCheck(Asset_Config_Monthly_Batch__c asst_rec,Asset_Configuration__c asst_config_rec){
    if (asst_rec.Master_Configuration_Check__c != asst_config_rec.Master_Configuration_Check__c ||asst_rec.Individual_config__c != asst_config_rec.Individual_config__c ||asst_rec.Accelerometer_Status__c != asst_config_rec.Accelerometer_Status_Desired__c || asst_rec.Accelerometer_Status_Reported__c != asst_config_rec.Accelerometer_Status_Reported__c ||asst_rec.ConnectMovementStart__c != asst_config_rec.ConnectMovementStart_Desired__c ||asst_rec.ConnectMovementStart_Reported__c != asst_config_rec.ConnectMovementStart_Reported__c ||asst_rec.ConnectMovementEnd__c != asst_config_rec.ConnectMovementEnd_Desired__c ||asst_rec.ConnectMovementEnd_Reported__c != asst_config_rec.ConnectMovementEnd_Reported__c ||asst_rec.Location_Sampling_Period__c != asst_config_rec.Location_Sampling_Period_Desired__c ||asst_rec.Location_Sampling_Period_Reported__c != asst_config_rec.Location_Sampling_Period_Reported__c ||asst_rec.Location_Status__c != asst_config_rec.Location_Status_Desired__c ||asst_rec.Location_Status_Reported__c != asst_config_rec.Location_Status_Reported__c ||asst_rec.Measurement_Period__c != asst_config_rec.Measurement_Period_desired__c ||asst_rec.Measurement_Period_Reported__c != asst_config_rec.Measurement_Period_Reported__c ||asst_rec.Network_Check_in_period__c != asst_config_rec.Network_Check_in_period_Desired__c ||asst_rec.Network_Check_in_period_Reported__c != asst_config_rec.Network_Check_in_period_Reported__c ||asst_rec.Temperature_Check_in_Period__c != asst_config_rec.Temperature_Check_in_Period_Desired__c ||asst_rec.Temperature_Check_in_Period_Reported__c != asst_config_rec.Temperature_Check_in_Period_Reported__c ||asst_rec.Temperature_Status__c != asst_config_rec.Temperature_Status_Desired__c ||asst_rec.Temperature_Status_Reported__c != asst_config_rec.Temperature_Status_Reported__c ||asst_rec.Tilt_Degrees__c != asst_config_rec.Tilt_Degrees_Desired__c ||asst_rec.Tilt_Degrees_Reported__c != asst_config_rec.Tilt_Degrees_Reported__c ||asst_rec.Tracking_Location_Period__c != asst_config_rec.Tracking_Location_Period_desired__c ||
        asst_rec.Tracking_Location_Period_Reported__c != asst_config_rec.Tracking_Location_Period_Reported__c ||asst_rec.Tracking_Locations_per_Check_Ins__c != asst_config_rec.Tracking_Locations_per_Check_Ins_Desired__c || asst_rec.Tracking_Locations_per_Check_Ins_Reporte__c != asst_config_rec.Tracking_Locations_per_Check_Ins_Reporte__c ||asst_rec.Trackmode__c != asst_config_rec.Trackmode_Desired__c ||asst_rec.Trackmode_Reported__c != asst_config_rec.Trackmode_Reported__c ||
        asst_rec.Use_Cell__c != asst_config_rec.Use_Cell_Desired__c ||asst_rec.Use_Cell_Reported__c != asst_config_rec.Use_Cell_Reported__c ||asst_rec.Use_GPS__c != asst_config_rec.Use_GPS_Desired__c || asst_rec.Use_GPS_Reported__c != asst_config_rec.Use_GPS_Reported__c || asst_rec.Use_WiFi__c != asst_config_rec.Use_WiFi_Desired__c || asst_rec.Use_Wifi_Reported__c != asst_config_rec.Use_Wifi_Reported__c||asst_rec.Asset_Name__c != asst_config_rec.Asset__c ||asst_rec.Account_Name__c != asst_config_rec.Account__c|| asst_rec.Asset_Configuration__c != asst_config_rec.Id) {
        return true;
    } else {
        return false;
    }
    }
     // ----------- For Scheduler -----------
    global void execute(SchedulableContext sc){
        database.executebatch(new AssetConfig_report_Batch(),1000);
    }
}