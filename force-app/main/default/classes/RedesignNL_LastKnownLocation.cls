/*
* Class Name: RedesignNL_LastKnownLocation
* Created By: Jayesh Khattar
* Description: This is a batch class used to update Asset History Location record's Last Known Location ID
* Change Log:
* Modified Date  Modified By  		Last Change
* Jan 16, 2024   Murali Krishna    Added try catch block and error log
* Jan 22,2024    Murali Krishna    Added the Try catch block on the line no 74
* Jan 28,2024    Jayesh Khattar    Added the code for running the batch only for dormant assets with configurable params
* Jan 28,2024    Murali Krishna    Added the Batch Data Custom record is inserted
*/  
global with sharing class RedesignNL_LastKnownLocation implements Database.Batchable<sObject>, Database.Stateful {
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public String batchstatus;
    
    
    public static Account acc;
    public Integer daysOldUpdateData = 45;
    
    public Boolean runOnlyDormant = false;
    public Integer dormantAssetsUpdateData = 365;
    
    public RedesignNL_LastKnownLocation(Integer daysOldUpdateData) {
        this.daysOldUpdateData = daysOldUpdateData;
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }

    public RedesignNL_LastKnownLocation(Boolean runOnlyDormant, Integer dormantAssetsUpdateData) {
        this.runOnlyDormant = runOnlyDormant;
        this.dormantAssetsUpdateData = dormantAssetsUpdateData;
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }

    public RedesignNL_LastKnownLocation() {
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(runOnlyDormant == true) {
            query = 'SELECT Id, AccountId, Name, Dormant_Days__c FROM Asset Where Dormant_Days__c = true';
        }
        else
	        query = 'SELECT Id, AccountId, Name, Dormant_Days__c FROM Asset' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset> assets) {
        batchStatus = 'Processing';
        Set<ID> AccIds = New Set<ID>();
        Set<ID> dormantAssetIds = new Set<ID>();
        Set<ID> nonDormantAssetIds = new Set<ID>();
        Map<String,Nested_Geofence__mdt> metadataMap=New Map<String,Nested_Geofence__mdt>();
        for(Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt]) {
            metadataMap.put(mdt.Current_Location__c,mdt);
        } 
        
        for(asset ass : assets) {
            if(ass.dormant_days__c == true)
                dormantAssetIds.add(ass.Id);
            else
                nonDormantAssetIds.add(ass.Id);
        }
        Map<String, Id> lastKnownLocationIdMap = new Map<String, Id>();
        List<Asset_History_Custom__c> ahcList = new List<Asset_History_Custom__c>();
        if(nonDormantAssetIds.size() > 0 && runOnlyDormant == false) {
            String query = 'SELECT Id, Still_in_this_Location__c, Asset__r.AccountId, Asset__c, Last_Known_Location__c, Location__c, currentLocationId__c, Last_Known_Location_Lookup__c FROM Asset_History_custom__c WHERE Asset__c in :nonDormantAssetIds and End_Time__c = LAST_N_DAYS:'+daysOldUpdateData+' ORDER BY Start_Time__c ASC';
            List<Asset_History_Custom__c>  ahcListNotDormant = Database.query(query);
            if(ahcListNotDormant.size () > 0) 
                ahcList.addAll(ahcListNotDormant);
        }
        if(dormantAssetIds.size() > 0) {
            String query = 'SELECT Id, Still_in_this_Location__c, Asset__r.AccountId, Asset__c, Last_Known_Location__c, Location__c, currentLocationId__c, Last_Known_Location_Lookup__c FROM Asset_History_custom__c WHERE ';
            if(runOnlyDormant == true) {
                List<AggregateResult> aggRes = [Select Asset__c from Asset_History_custom__c WHERE Asset__c in :dormantAssetIds and Last_Known__c = true group by Asset__c];
                List<Id> assetIds = new List<Id>();
                For(AggregateResult agr : aggRes) {
                    assetIds.add((String)agr.get('Asset__c'));
                }
                if(assetIds.size() > 0)
	                query += 'Asset__c in :assetIds and End_Time__c = LAST_N_DAYS:'+dormantAssetsUpdateData+' ORDER BY Start_Time__c ASC';                
                else 
                    return;
            }
            else 
                query += 'Asset__c in :dormantAssetIds and End_Time__c = LAST_N_DAYS:180 ORDER BY Start_Time__c ASC';
            List<Asset_History_Custom__c> ahcListDormant = Database.query(query);
            if(ahcListDormant.size () > 0) 
                ahcList.addAll(ahcListDormant);
        }
        
        for (Asset ast : assets) {
            AccIds.add(ast.AccountID);
        }
        
        Map<Id, Set<Account>> accRelatedCustomerMap = new Map<Id, Set<Account>>();
        
        List<Account> accList = [Select Id, Name from Account where Id in : AccIds];
        for(Account acc : accList) {
            Set<Account> accSet = new Set<Account>();
            accSet.add(acc);
			accRelatedCustomerMap.put(acc.Id, accSet);
        }
        
        List<Related_Customer__c> cuslst = [SELECT Id, Source_Account__r.Name, Source_Account__c, Related_To__r.Name, Related_To__c FROM Related_Customer__c WHERE Source_Account__c in :AccIds];
        
        for (Related_Customer__c customer : cuslst) {
            Account sourceAcc = new Account(Id = customer.Source_Account__c, Name = customer.Source_Account__r.Name);
            Account childAcc =  new Account(Id = customer.Related_To__c, Name = customer.Related_To__r.Name);
            Set<Account> childAccList;
            if(accRelatedCustomerMap.containsKey(sourceAcc.Id)) {
                childAccList = accRelatedCustomerMap.get(sourceAcc.Id);
            }
            else {
                childAccList = new Set<Account>();
                childAccList.add(sourceAcc);
            }
            childAccList.add(childAcc);
            accRelatedCustomerMap.put(sourceAcc.Id, childAccList);
        }
        try{
            for(Asset_History_custom__c ahc : ahcList) {
                if (ahc.Last_Known_Location_Lookup__c == null && ahc.Last_Known_Location__c != null) {
                    Set<Account> childAccList;
                    if(accRelatedCustomerMap.containsKey(ahc.Asset__r.AccountId)) {
                        childAccList = accRelatedCustomerMap.get(ahc.Asset__r.AccountId);
                        //add the if condition over here to check with metadata also
                        if(childAccList != Null){
                        for(Account acc : childAccList) {
                            if(acc.Name == ahc.Last_Known_Location__c) {
                                ahc.Last_Known_Location_Lookup__c = acc.Id;
                                ahc.New_Value__c = 'Can be updated - ahc.Last_Known_Location_Lookup__c = '+acc.Id;
                                break;                        
                            }
                        }
                        }
                       
                    }else if(metadataMap.containskey(ahc.Last_Known_Location__c)){
                         Nested_Geofence__mdt mdt =metadataMap.get(ahc.Last_Known_Location__c);
                         ahc.Last_Known_Location_Lookup__c = mdt.Current_Location_Id__c;
                         ahc.New_Value__c = 'Can be updated - ahc.Last_Known_Location_Lookup__c = '+mdt.Current_Location_Id__c;
                    }
                    else {
                        
                        ahc.New_Value__c = 'won\'t update';
                    }
                }
            }
            if (!ahcList.isEmpty()) {
                update ahcList;
            }
        }
        catch(Exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_LastKnownLocation', 'execute', 'Exception', null, null, true);
            batchStatus='Failed';
            failureMsgs.add('RedesignNL_LastKnownLocation- Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Any post-batch processing logic can be added here
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
        batchLog.Total_no_of_records_processed__c = totalRecords;
        if(batchStatus == 'Processing')
            batchLog.Status__c = 'Completed';
        insert batchLog;
    }
    
}