public class RedesignNL_UpdateAccForAHCAst implements Database.Batchable<SObject>,Database.stateful {
    
    //BatchLog fields
    public String batchName;
    public String batchStatus;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public Datetime BefAssetProcDttime;    
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    // Define any state you need for the batch
    boolean check;
    public List<Account> accList = new List<Account>();
    Map<Id,Account> deleteAccIds = new  Map<Id,Account>();
    // Constructor to pass in the accIdMap
    public RedesignNL_UpdateAccForAHCAst(List<Account> accList) {
        this.batchName='RedesignNL_UpdateAccForAHCAst';
        this.batchStartTime = system.Now(); 
        this.accList= accList;
        this.check = true;
        this.deleteAccIds = new  Map<Id,Account>()  ;
    }
    public RedesignNL_UpdateAccForAHCAst() {
        this.batchName='RedesignNL_UpdateAccForAHCAst';
        this.batchStartTime = system.Now(); 
        this.accList= new List<Account>();
        this.check = false;
        this.deleteAccIds = new  Map<Id,Account>()  ;
    }
    
    // Start method to query Assets
    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.batchStatus = 'Processing';
        BefAssetProcDttime = system.now();
        // Query assets that you want to process, assuming that Asset__c is the relationship
        try{
            accList = this.check == True? accList :[Select Id, Name, Address__c,Replaced_account__c from Account Where Replaced_account__c != null Limit 10000];
                if(accList.size()>0){
                    for(Account loopVar : accList){
                        deleteAccIds.put(loopVar.Id,loopVar);
                        System.debug(loopVar.Name);
                    }
                }
            String query = 'SELECT Current_Address__c,Id,Name, Current_Location__c, Last_Known_Location__c,Latest_Location_AHC__r.CurrentLocationId__c,Latest_Location_AHC__r.Last_Known_Location__c,Latest_Location_AHC__r.Last_Known_Location_Lookup__c,State_of_Pallet__c,Pause_Job__c FROM Asset WHERE Pause_Job__c = true';
            return Database.getQueryLocator(query);
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_UpdateAccForAHCAst', 'start', null, null, null, true);            
        }
        return null;
    }
    
    // Execute method to process Asset records and query related Asset_History_custom__c records
    public void execute(Database.BatchableContext bc, List<Asset> assetList) {
        try{
            List<Asset> assetsToUpdate = new List<Asset>();
            List<Asset_History_custom__c> updateAhcList  = new List<Asset_History_custom__c>();
            // Loop through each Asset
            Map<Id,Asset_History_custom__c> LatestRecMap = new Map<Id,Asset_History_custom__c>();
            Map<Id,Asset> astMap =New Map<Id,Asset>();
            for (Asset ast : assetList) {
                astMap.put(ast.Id,ast);
                System.debug(ast.Name);
                // Step 1: Query the first AHC record where Start_time__c is the earliest
                List<Asset_History_custom__c> firstahcList = [
                    SELECT Id, Start_time__c, End_time__c, CurrentLocationId__c
                    FROM Asset_History_custom__c
                    WHERE Asset__c = :ast.Id
                    AND (CurrentLocationId__c IN :deleteAccIds.keyset() OR Last_Known_Location_Lookup__c IN :deleteAccIds.keyset())
                    ORDER BY Start_time__c ASC
                    LIMIT 1
                ];
                
                if (!firstahcList.isEmpty()) {
                    Asset_History_custom__c firstAHC = firstahcList[0];
                    
                    // Store the first End_time__c value
                    DateTime firstEndTime = firstAHC.Start_Time__c;
                    
                    // Step 2: Query subsequent AHC records where End_time__c is greater than or equal to the first End_time__c
                    List<Asset_History_custom__c> ahcList = [
                        SELECT Id, Start_time__c, End_time__c, Asset__c ,Still_in_this_Location__c,Location__c, Current_Location_Address__c, currentLocationId__c,Current_Location__c, Last_Known_Location__c, Last_Known_Location_Lookup__c
                        FROM Asset_History_custom__c
                        WHERE Asset__c = :ast.Id
                        AND End_time__c >= :firstEndTime
                        ORDER BY Start_time__c ASC
                    ];
                    
                    // Loop through the subsequent records to find the "last known location"
                    Asset_History_custom__c previousAhc = new Asset_History_custom__c();
                    
                    for (Asset_History_custom__c history : ahcList) {
                        if(ahcList[0].id != history.id){
                            //Account acc;
                            System.debug(history.currentLocationId__c);
                            System.debug(history.Last_Known_Location__c);
                            //acc = deleteAccIds.get(history.currentLocationId__c);
                            if(deleteAccIds.containsKey(history.currentLocationId__c)){
                                System.debug(history.currentLocationId__c);
                                history.currentLocationId__c = null;
                                history.Current_Location__c = null;
                                history.Location__c = 'In Transit';
                                updateAhcList.add(history);
                            }
                            if(deleteAccIds.containsKey(history.Last_Known_Location_Lookup__c)){
                                
                                history.Last_Known_Location_Lookup__c = previousAhc.Location__c == 'In Transit' ? previousAhc.Last_Known_Location_Lookup__c : previousAhc.Current_Location__c;
                                history.Last_Known_Location__c = previousAhc.Location__c == 'In Transit' ? previousAhc.Last_Known_Location__c : previousAhc.currentLocationId__c;
                                updateAhcList.add(history);
                            }
                            
                            
                        }previousAhc = history;
                        if(history.Still_in_this_Location__c){
                            LatestRecMap.put(history.Asset__c,history);
                        }
                    }
                }
            }
            if(updateAhcList.size()>0){
                
                List<Database.SaveResult> updateResultAhcList = Database.update(updateAhcList, false);
                if(updateResultAhcList.size()>0){
                    List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
                    for(Database.SaveResult ds : updateResultAhcList){
                        if(!ds.isSuccess()){
                            Debug_Logs__c dl = new Debug_Logs__c();
                            dl.Class_Name__c='RedesignNL_UpdateAccForAHCAst';
                            dl.Method_Name__c='Update AHC';
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
                
                for(Asset ast:assetList){
                    Asset_History_custom__c ahc = LatestRecMap.get(ast.id);
                    ast.Current_Location__c = ahc.CurrentLocationId__c != null ? ahc.CurrentLocationId__c : null;
                    ast.Last_Known_Location__c = ahc.Last_Known_Location_Lookup__c != null ? ahc.Last_Known_Location_Lookup__c : null;
                    ast.State_of_Pallet__c = ast.Current_Location__c != null ? 'In Network' : 'In Transit';
                    System.debug(ast.State_of_Pallet__c);
                    ast.Pause_Job__c = false;
                    assetsToUpdate.add(ast);
                }
            }        
            // Update the list of assets with the last known location
            if (!assetsToUpdate.isEmpty()) {
                // delete accList;
                List<Database.SaveResult> updateResultList = Database.update(assetsToUpdate, false);
                if(updateResultList.size()>0){
                    List<Debug_Logs__c> debugLogsToInsert = new List<Debug_Logs__c>();
                    for(Database.SaveResult ds : updateResultList){
                        if(!ds.isSuccess()){
                            Debug_Logs__c dl = new Debug_Logs__c();
                            dl.Class_Name__c='RedesignNL_UpdateAccForAHCAst';
                            dl.Method_Name__c='Update Asset';
                            Asset asd = astMap.get(ds.getId());
                            dl.Asset_Device_ID__c = asd.Name;
                            dl.Asset__c = asd.id;
                            for(Database.Error err : ds.getErrors()) {
                                dl.Error_Message__c = dl.Error_Message__c == null ? err.getMessage() : dl.Error_Message__c+', '+err.getMessage();
                            }
                            debugLogsToInsert.add(dl);
                        }
                    }
                    if(debugLogsToInsert.size()>0) {
                        insert debugLogsToInsert;            
                    }
                }
            }
        }catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex,'RedesignNL_UpdateAccForAHCAst', 'execute', null, null, null, true);  
            failureMsgs.add('RedesignNL_UpdateAccForAHCAst - DeleteExistingRecords. Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    // Finish method, if you need to do post-processing
    public void finish(Database.BatchableContext bc) {
        Delete accList;
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        } //Murali:Passing  the bC to insert values from AsyncApexJob line no:130
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        
        // You can implement logic here to notify users or log information
        //  RedesignAC_Downstream_Config_UpdateBatch.scheduleBatch();
    }
}