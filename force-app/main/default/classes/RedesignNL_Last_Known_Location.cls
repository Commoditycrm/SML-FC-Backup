global class RedesignNL_Last_Known_Location implements Database.Batchable<sObject> {
     //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public String batchstatus;
    public static Account acc;
    public Integer daysOldUpdateData = 45;
    public Boolean dormant = false;
    public String query;
    public Boolean runOnlyDormant = false;
    public Integer dormantAssetsUpdateData = 365;
    
    global RedesignNL_Last_Known_Location(String query) {
        this.query = query;
    }
    public RedesignNL_Last_Known_Location(Integer daysOldUpdateData) {
        this.daysOldUpdateData = daysOldUpdateData;
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }

    public RedesignNL_Last_Known_Location(Boolean runOnlyDormant, Integer dormantAssetsUpdateData) {
        this.runOnlyDormant = runOnlyDormant;
        this.dormantAssetsUpdateData = dormantAssetsUpdateData;
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }

    public RedesignNL_Last_Known_Location() {
        this.batchName='RedesignNL_LastKnownLocation';
        this.batchStartTime = system.Now();
    }
    public RedesignNL_Last_Known_Location(Boolean dormant) {
        this.batchName='RedesignNL_LastKnownLocation';
        this.dormant = dormant;
        this.batchStartTime = system.Now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
       if(String.isBlank(query)) {
            query = 'SELECT Id, AccountId, Name, Dormant_Days__c FROM Asset' ;
        if(dormant == True)
            query += ' where dormant_days__c = True';
          }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset> assets) {
        batchStatus = 'Processing';
        Set<ID> AccIds = New Set<ID>();
        Map<String,Nested_Geofence__mdt> metadataMap=New Map<String,Nested_Geofence__mdt>();
        for(Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt]) {
            metadataMap.put(mdt.Current_Location__c,mdt);
        }
        Set<ID> nonDormantAsset = New Set<ID>();
        List<Asset_History_custom__c> ahcList = new List<Asset_History_custom__c>();
        for(Asset ast:assets){
            AccIds.add(ast.AccountID);
            if(ast.dormant_days__c == True){
                ahcList.addAll([Select Id, Still_in_this_Location__c, Asset__r.AccountId, Asset__c, Last_Known_Location__c, Location__c, currentLocationId__c, Last_Known_Location_Lookup__c,New_Value__c  from Asset_History_custom__c 
                                where Asset__c=:ast.Id AND Last_Known_Location__c != null AND Recordtype.developerName = 'Location' AND Last_Known_Location_Lookup__c = null 
                                order by End_Time__c  desc Limit 2]);
            }
            else
                nonDormantAsset.add(ast.Id);
                
        }
        if(NonDormantAsset.size()>0){
                         String query = 'Select Id, Still_in_this_Location__c, Asset__r.AccountId, Asset__c, Last_Known_Location__c, Location__c, currentLocationId__c, Last_Known_Location_Lookup__c,New_Value__c' 
                                         +' from Asset_History_custom__c'
                                         +' where Asset__c in :nonDormantAsset AND Recordtype.developerName = \'Location\' AND Last_Known_Location__c != null AND Last_Known_Location_Lookup__c = null AND delete_check__c = true '//End_Time__c = LAST_N_DAYS:'+daysOldUpdateData
                                         +' order by Asset__c';
            
            List<Asset_History_Custom__c> ahcListNonDormant = Database.query(query);
            ahcList.addAll(ahcListNonDormant);
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