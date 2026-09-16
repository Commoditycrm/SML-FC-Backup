global class RedesignAC_Downstream_Config_UpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    public DateTime batchStartTime;
    Public String batchStatus;
    // New entry
    public String batchDataCustomStr = 'SF to NL Config Update Batch';
    public Id batchLogId;
    //==========
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    Public DateTime DeleteDate;
    List<Asset>astList = new List<Asset>();
    Map<Id,Asset> astMap = new Map<Id,Asset>();
    global RedesignAC_Downstream_Config_UpdateBatch(List<Asset>AstList){
        this.astList = AstList;
        this.astMap = new Map<Id,Asset>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Creating batch data custom .
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Batch_Name__c = batchDataCustomStr;
                batchLog.Start_Time__c= system.now();
                batchLog.Status__c = 'Processing'; 
                insert batchLog;
        this.batchLogId = batchLog.Id;
         //===============
        this.batchStatus = 'Processing';
        this.batchStartTime = System.Now();
        Set<ID>astIdSet = new Set<Id>();
        for(Asset ast: astList){
            astMap.put(ast.Id,ast); 
            astIdSet.add(ast.Id);
        }
        String query = 'select id,name,Device_Id__c,Measurement_Period_desired__c, Asset__r.AccountId,'+
            ' Trackmode_Desired__c,Individual_config__c,Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c,'+
            ' ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,'+
            ' Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,'+
            ' Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,'+
            ' Connect_On_Tilt_Desired__c,Asset__c, Log_Every_n_Desired__c,Current_Account_Name__c,Account__c,Configuration_Followed__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c,'+
            ' Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c,'+
            ' Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c,' +
            ' Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c,'+ 
            ' Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c '+
            //' from Asset_Configuration__c where Asset__c in :astIdSet and recordType.DeveloperName = \'Asset\' and Individual_config__c = false AND  NLResponseStatus__c != \'Processing\'';
            ' from Asset_Configuration__c where Asset__c in :astIdSet and recordType.DeveloperName = \'Asset\' and Individual_config__c = false and Asset__r.Account.Ignore_Account_for_Callout__c = false';
          return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Asset_Configuration__c> acList) {
        Set<Id> accSet = new Set<Id>();
        List<Asset_Configuration__c> updateAcList = new List<Asset_Configuration__c>();
        Map<Id,Asset_Configuration__c> acMap = new Map<Id,Asset_Configuration__c>();
        Map<Id,Asset_Configuration__c> defaultMap = new Map<Id,Asset_Configuration__c>();
        Map<Id,Asset_Configuration__c> debugAcMap = new Map<Id,Asset_Configuration__c>();
        Map<Asset_Configuration__c,Asset_Configuration__c> updateAcMap = new Map<Asset_Configuration__c,Asset_Configuration__c>();
        try{
        for(Asset_Configuration__c ac:acList){
            Asset ast= astMap.get(ac.Asset__c);
            // to checkout this if case
            if(ast.State_of_pallet__c == 'In Transit'){
                ac.Current_Account_Name__c = ast.AccountId;
                //ac.Configuration_Followed__c = 'Upstream';
                accSet.add(ast.AccountId);
                updateAcList.add(ac);
                debugAcMap.put(ac.Id,ac);
            }
            else if(ast.State_of_pallet__c == 'In Network'){
                ac.Current_Account_Name__c = ast.Current_Location__c;
                //ac.Configuration_Followed__c = 'Downstream';
                accSet.add(ast.Current_Location__c);
                accSet.add(ast.AccountId);
                updateAcList.add(ac);
                debugAcMap.put(ac.Id,ac);
            }
        }
        List<Asset_Configuration__c> accConfig = new List<Asset_Configuration__c>();
        List<Asset_Configuration__c> defaultConfig = new List<Asset_Configuration__c>();
        if(updateAcList.size()>0){
            accConfig = [SELECT id,name,Measurement_Period_desired__c,
                         Trackmode_Desired__c, Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c,Current_Account_Name__c,Account__c,Configuration_Followed__c,
                         ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                         Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                         Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,
                         Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, 
                         Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                         Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, 
                         Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c, 
                         Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c, LastModifiedDate   
                         FROM Asset_Configuration__c WHERE Account__c in:accSet AND recordType.DeveloperName = 'Account'];
            defaultConfig = [SELECT id,name,Measurement_Period_desired__c,
                         Trackmode_Desired__c, Accelerometer_Status_Desired__c,ConnectMovementStart_Desired__c,Current_Account_Name__c,Account__c,Configuration_Followed__c,
                         ConnectMovementEnd_Desired__c,Tracking_Location_Period_desired__c,Tracking_Locations_per_Check_Ins_Desired__c,
                         Location_Status_Desired__c,Location_Sampling_Period_Desired__c,Use_Cell_Desired__c,Use_GPS_Desired__c,
                         Use_WiFi_Desired__c,Network_Check_in_period_Desired__c,Temperature_Status_Desired__c,Temperature_Check_in_Period_Desired__c,
                         Connect_On_Tilt_Desired__c, Log_Every_n_Desired__c, Tilt_Degrees_Desired__c, Reference_X_Desired__c, Reference_Y_Desired__c, Reference_Z_Desired__c, 
                         Impact_Alert_Desired__c, Max_Impact_Desired__c, Movement_Accuracy_Desired__c, Location_Accuracy_Desired__c, Sensor_Logging_Period_Desired__c, 
                         Tag_Detection_Desired__c, Min_RSSI_Desired__c, Scan_for_Tags_Interval_Desired__c, Missing_Tag_Report_Delay_Desired__c, Listen_Time_Desired__c, 
                         Distance_Status_Desired__c, Distance_Sampling_Period_Desired__c, Connect_on_Alert_Desired__c, Alert_Threshold_Low_Desired__c, Alert_Threshold_High_Desired__c, 
                         Alert_Count_Desired__c, Ignore_Errors_Desired__c, Log_Every_N_Samples_Desired__c, Skip_While_Moving_Desired__c, LastModifiedDate  
                         FROM Asset_Configuration__c WHERE Account__c in:accSet AND recordType.DeveloperName = 'Default'];
            
        }
        for(Asset_Configuration__c ac:accConfig){
            acMap.put(ac.Account__c,ac);
        }
        for(Asset_Configuration__c ac:defaultConfig){
            defaultMap.put(ac.Account__c,ac);
        }
        for(Asset_Configuration__c ac:updateAcList){
            Asset_Configuration__c acc = acMap.get(ac.Current_Account_Name__c);
            Asset_Configuration__c def = defaultMap.get(ac.Current_Account_Name__c);
            if(acc != null){
                ac.Current_Account_Name__c = acc.Account__c == ac.Asset__r.AccountId ? ac.Asset__r.AccountId : acc.Account__c;
                //ac.Configuration_Followed__c = acc.Account__c == ac.Asset__r.AccountId ? 'Upstream' : 'Downstream';
                Asset ast= astMap.get(ac.Asset__c);
                if(ast.State_of_pallet__c == 'In Transit'){
                    ac.Configuration_Followed__c = 'Upstream';
                    if (def != null) {
                        ac = nimbelinkCalloutClass(ac, def);
                    }
                }else{
                    if (acc != null && def != null && acc.LastModifiedDate != null && def.LastModifiedDate != null &&
                        acc.LastModifiedDate > def.LastModifiedDate) {

                        ac.Configuration_Followed__c = 'Downstream';
                        ac = nimbelinkCalloutClass(ac, acc);
                    }else{
                        ac.Configuration_Followed__c = 'Upstream';
                        if (def != null) {
                            ac = nimbelinkCalloutClass(ac, def);
                        }
                    } 
                }
            }else{
                acc = defaultMap.get(ac.Asset__r.AccountId);
                if(acc != null){
                    ac.Current_Account_Name__c = ac.Asset__r.AccountId;
                    ac.Configuration_Followed__c = 'Upstream';
                    ac = nimbelinkCalloutClass(ac,acc); // Use default configuration here
                }
            }
        }
        if(updateAcList.size()> 0){
            List<Database.SaveResult> updateResultList = Database.update(updateAcList, false);
            if(updateResultList.size()>0){
                List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
                for(Database.SaveResult ds : updateResultList){
                    if(!ds.isSuccess()){
                        Debug_Logs__c dl = new Debug_Logs__c();
                        Asset_Configuration__c asd = debugAcMap.get(ds.getId());
                        dl.Asset_Device_ID__c = asd.Name;
                        dl.Asset__c = asd.Asset__c;
                        dl.Class_Name__c='RedesignAC_Downstream_Config_UpdateBatch';
                        dl.Method_Name__c='Update AssetConfig';
                        for(Database.Error err : ds.getErrors()) {
                            dl.Error_Message__c = dl.Error_Message__c == null ? err.getMessage() : dl.Error_Message__c+', '+err.getMessage();
                        }
                        debugLogsToInset.add(dl);
                    }
                }
                if(debugLogsToInset.size()>0) {
                    insert debugLogsToInset;            
                }
            }
        }
    }catch(Exception e){
        RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignAC_Downstream_Config_UpdateBatch', 'execute', 'Exception', null, null, true);
    }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
            // Compleating status of BDC
            Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
                batchLog.Id = batchLogId;
                batchLog.Complete_Time__c = system.now();
                batchLog.Status__c ='Completed';
                update batchLog;
            //==============
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC, null, 'RedesignAC_Downstream_Config_UpdateBatch', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
		runInTransitEverBatch();       
    }
    public static Asset_Configuration__c nimbelinkCalloutClass(Asset_Configuration__c astConfig ,  Asset_Configuration__c accConfig){
        astConfig.Measurement_Period_desired__c = accConfig.Measurement_Period_desired__c;
        astConfig.Trackmode_Desired__c = accConfig.Trackmode_Desired__c;
        astConfig.Accelerometer_Status_Desired__c = accConfig.Accelerometer_Status_Desired__c;
        astConfig.ConnectMovementStart_Desired__c = accConfig.ConnectMovementStart_Desired__c;
        astConfig.ConnectMovementEnd_Desired__c = accConfig.ConnectMovementEnd_Desired__c;
        astConfig.Tracking_Location_Period_desired__c = accConfig.Tracking_Location_Period_desired__c;
        astConfig.Tracking_Locations_per_Check_Ins_Desired__c = accConfig.Tracking_Locations_per_Check_Ins_Desired__c;
        astConfig.Location_Status_Desired__c = accConfig.Location_Status_Desired__c;
        astConfig.Location_Sampling_Period_Desired__c = accConfig.Location_Sampling_Period_Desired__c;
        astConfig.Use_Cell_Desired__c = accConfig.Use_Cell_Desired__c;
        astConfig.Use_GPS_Desired__c = accConfig.Use_GPS_Desired__c;
        astConfig.Use_WiFi_Desired__c = accConfig.Use_WiFi_Desired__c;
        astConfig.Network_Check_in_period_Desired__c = accConfig.Network_Check_in_period_Desired__c;
        astConfig.Temperature_Status_Desired__c = accConfig.Temperature_Status_Desired__c;
        astConfig.Temperature_Check_in_Period_Desired__c = accConfig.Temperature_Check_in_Period_Desired__c;
        astConfig.Connect_On_Tilt_Desired__c = accConfig.Connect_On_Tilt_Desired__c;
        astConfig.Log_Every_n_Desired__c = accConfig.Log_Every_n_Desired__c;
        astConfig.Tilt_Degrees_Desired__c = accConfig.Tilt_Degrees_Desired__c;
        astConfig.Reference_X_Desired__c = accConfig.Reference_X_Desired__c;
        astConfig.Reference_Y_Desired__c = accConfig.Reference_Y_Desired__c;
        astConfig.Reference_Z_Desired__c = accConfig.Reference_Z_Desired__c;
        astConfig.Current_Account_Name__c = accConfig.Account__c;
        astConfig.Impact_Alert_Desired__c = accConfig.Impact_Alert_Desired__c;
        astConfig.Max_Impact_Desired__c = accConfig.Max_Impact_Desired__c;
        astConfig.Movement_Accuracy_Desired__c = accConfig.Movement_Accuracy_Desired__c;
        astConfig.Location_Accuracy_Desired__c = accConfig.Location_Accuracy_Desired__c;
        astConfig.Sensor_Logging_Period_Desired__c = accConfig.Sensor_Logging_Period_Desired__c;
        astConfig.Tag_Detection_Desired__c = accConfig.Tag_Detection_Desired__c;
        astConfig.Min_RSSI_Desired__c = accConfig.Min_RSSI_Desired__c;
        astConfig.Scan_for_Tags_Interval_Desired__c = accConfig.Scan_for_Tags_Interval_Desired__c;
        astConfig.Missing_Tag_Report_Delay_Desired__c = accConfig.Missing_Tag_Report_Delay_Desired__c;
        astConfig.Listen_Time_Desired__c = accConfig.Listen_Time_Desired__c;
        astConfig.Distance_Status_Desired__c = accConfig.Distance_Status_Desired__c;
        astConfig.Distance_Sampling_Period_Desired__c = accConfig.Distance_Sampling_Period_Desired__c;
        astConfig.Connect_On_Alert_Desired__c = accConfig.Connect_On_Alert_Desired__c;
        astConfig.Alert_Threshold_Low_Desired__c = accConfig.Alert_Threshold_Low_Desired__c;
        astConfig.Alert_Threshold_High_Desired__c = accConfig.Alert_Threshold_High_Desired__c;
        astConfig.Alert_Count_Desired__c = accConfig.Alert_Count_Desired__c;
        astConfig.Ignore_Errors_Desired__c = accConfig.Ignore_Errors_Desired__c;
        astConfig.Log_Every_N_Samples_Desired__c = accConfig.Log_Every_N_Samples_Desired__c;
        astConfig.Skip_While_Moving_Desired__c = accConfig.Skip_While_Moving_Desired__c;
        astConfig.NLResponseStatus__c = 'Processing';
        return astConfig;
    }
    global static void scheduleBatch() {
        Redesign_NL__mdt redesign =Redesign_NL__mdt.getInstance('Default');
        List<Api_Response__c> arList =[select Id from Api_Response__c where check_class__c ='Process Data' AND Status__c ='CardinalNew' limit 1];
        list<Account> accCheckList = [select id,UpdateRecords__c, Name, Address__c,Replaced_account__c from Account where Replaced_Account__c != null and UpdateRecords__c = true];
        if(accCheckList.size()>0){
            List<AsyncApexJob> ascJob = [select id from AsyncApexJob where ApexClass.Name IN( 'RedesignNL_UpdateAccForARC','RedesignNL_UpdateAccForAHCAst','RedesignNL_PauseAssetForAccDeletion') and Status IN ('Processing' , 'Preparing','Queued' ,'Holding')];
            if(ascJob.size()==0){
                Database.executeBatch(new RedesignNL_PauseAssetForAccDeletion());
            }
        }
        if(arList.size() == 0){
        if(redesign.Batch_Interval_AHC_mins__c == 0){
            database.executeBatch(New RedesignNL_CreateAssetHistoryBatch(),15);
        }
        else{
            Integer mins = Integer.valueof(redesign.Batch_Interval_AHC_mins__c);
            Datetime sysTime = System.now().addMinutes(mins);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();          
            System.schedule('RedesignNL_CreateAssetHistoryBatch '+ System.now().getTime(), cronExpression, New RedesignNL_CreateAssetHistoryBatch());
            List<API_response__c> apilist = [select id,status__c,Asset__c from API_response__c 
                   where Asset__r.isNew_Asset__C = true and Asset__r.pause_job__c = false and 
                   status__c = 'Pending' Order by createddate asc limit 1];
            if(apilist.size()>0){
                Database.ExecuteBatch(New RedesignNL_updateBulkAPIresponse(),10);

            }
            List<API_response__c> smartPalletsApi = [select id,status__c,Asset__c from API_response__c 
                   where check_class__c='SmartPallet Data' and status__c = 'New' Order by createddate asc limit 1];
            if(smartPalletsApi.size()>0){
                Database.ExecuteBatch(New ProcessOLESmartPalletsData_Batch(),200);
            }
        }
        }
        else{
            Integer mins = Integer.valueof(redesign.Batch_Interval_AHC_mins__c);
            Datetime sysTime = System.now().addMinutes(mins);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();          
            System.schedule('RedesignCardinalUpdateAsset '+ System.now().getTime(), cronExpression, New RedesignCardinalUpdateAsset());

        }
    }
    
    global static void runInTransitEverBatch() {
        Redesign_NL__mdt redesign = Redesign_NL__mdt.getInstance('Default');
        //Intransit-Ever batch validation
        Integer hour = system.now().hour();
        Integer scheduledHour = Integer.valueOf(redesign.In_Transit_Ever_Batch_Runtime__c);
        Integer batchSize = redesign.In_Transit_Ever_Batch_Size__c >0 ? Integer.valueOf (redesign.In_Transit_Ever_Batch_Size__c): 30;
        if(hour == scheduledHour) {
            List<Batch_Data_Custom__c> bdcList = [Select id,createdDate from Batch_Data_Custom__c where CreatedDate=today and Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch' order by createdDate desc limit 1];
            if(bdcList.size() == 0){
                Batch_Data_Custom__c batchLogintransit = new Batch_Data_Custom__c();
                batchLogintransit.Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch';
                batchLogintransit.Status__c = 'Processing';
                insert batchLogintransit;
                database.executeBatch(new RedesignNL_InTransitEverAHCBatch(false),batchSize);
                scheduleBatch();       
            }
            else {
                scheduleBatch();                      
            }
        }
        else if(hour >= scheduledHour) {
            List<Batch_Data_Custom__c> bdcList = [Select id,createdDate from Batch_Data_Custom__c where CreatedDate=today and Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch' order by createdDate desc];
            if(bdcList.size() == 1){
                batchSize = batchSize - 10 >0 ? batchSize - 10 : batchSize;
                database.executeBatch(new RedesignNL_InTransitEverAHCBatch(true),batchSize);
            }
            else
                scheduleBatch();                         
        }
        else {
            Schedulebatch();               
        }        
    }
}