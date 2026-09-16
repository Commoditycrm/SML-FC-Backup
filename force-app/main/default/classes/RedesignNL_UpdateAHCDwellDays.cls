global class RedesignNL_UpdateAHCDwellDays implements Database.Batchable<SObject>, Database.Stateful {
    public String batchName;
    public String batchStatus;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public Datetime BefAssetProcDttime;    
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    // Constructor to accept a dynamic query
    public RedesignNL_UpdateAHCDwellDays() {
        this.batchName='RedesignNL_UpdateAHCDwellDays';
        this.batchStartTime = system.Now(); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.batchStatus = 'Processing';
        BefAssetProcDttime = system.now();
        // Use the passed asset query to fetch Asset records
        String query = 'SELECT Current_Address__c,Id,Name, Current_Location__c, Last_Known_Location__c,Max_LKL_End_time__c, Latest_Location_AHC__r.CurrentLocationId__c,Latest_Location_AHC__r.Last_Known_Location__c,Latest_Location_AHC__r.Last_Known_Location_Lookup__c,State_of_Pallet__c,Pause_Job__c FROM Asset WHERE Pause_Job__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset> assetList) {
        try { 
            for(Asset ast : assetList) {
                ast.Pause_Job__c = false;
                
                // Query related Asset_History_custom__c records using Asset IDs
                List<Asset_History_custom__c> ahcList = [
                    SELECT Id, Start_time__c, End_time__c, Asset__c, Consider_for_Dwell__c, Still_in_transit__c ,Still_in_this_Location__c,Location__c, Current_Location_Address__c, currentLocationId__c,Current_Location__c, Last_Known_Location__c, Last_Known_Location_Lookup__c
                    FROM Asset_History_custom__c
                    WHERE Asset__c = :ast.Id
                    AND End_time__c >= :ast.Max_LKL_End_time__c AND Recordtype.DeveloperName IN ('Location','Dwell_Time')
                    ORDER BY Start_time__c Desc
                ];
                
                
                
                List<Asset_History_custom__c> recordsToUpdate = new List<Asset_History_custom__c>();
                
                // Process AHC records in reverse order and apply the specified logic
                for ( Asset_History_custom__c ahc : ahcList) {
                    if (ahc.Location__c == 'In Transit') {
                        ahc.Consider_for_Dwell__c = true;
                        recordsToUpdate.add(ahc);
                    } else if(ahc.Location__c == 'In Transit - Ever') {
                        ahc.Still_in_transit__c = true;recordsToUpdate.add(ahc);
                        // Stop processing further if Location__c is not 'In Transit'
                        
                    }else {
                        break;
                    }
                }
                
                // Update records if there are any modifications
                if (!recordsToUpdate.isEmpty()) {
                    List<Database.SaveResult> updateResultAhcList = Database.update(recordsToUpdate, false);
                    if(updateResultAhcList.size()>0){
                        List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
                        for(Database.SaveResult ds : updateResultAhcList){
                            if(!ds.isSuccess()){
                                Debug_Logs__c dl = new Debug_Logs__c();dl.Class_Name__c='RedesignNL_UpdateAHCDwellDays';dl.Method_Name__c='Update AHC';
                                for(Database.Error err : ds.getErrors()) {dl.Error_Message__c = dl.Error_Message__c == null ? err.getMessage() : dl.Error_Message__c+', '+err.getMessage();
                                }debugLogsToInset.add(dl);
                            }
                        }if(debugLogsToInset.size()>0) {insert debugLogsToInset;}
                    }
                }
                
            }
            update assetList;
        } catch (Exception ex) {
            // Log the error
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_UpdateAHCDwellDays', 'execute', null, null, null, true);  
            failureMsgs.add('RedesignNL_UpdateAHCDwellDays - update rec. Error msg: '+ex.getMessage());totalFailureRecords = totalFailureRecords + 1;
            // Optionally, you could use a custom object or email alert to track errors for better visibility
        }
        
        
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional: Any post-processing or logging
        System.debug('Asset History Update Batch Completed');
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){batchStatus = 'Failed';} //Murali:Passing  the bC to insert values from AsyncApexJob line no:130
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        
    }
}