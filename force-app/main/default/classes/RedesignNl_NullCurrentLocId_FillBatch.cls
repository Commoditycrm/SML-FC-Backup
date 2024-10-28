global with sharing class RedesignNl_NullCurrentLocId_FillBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static Integer totalFailureRecords = 0;
    public List<String> failureMsgs = new List<String>();
    public Map<String,Nested_Geofence__mdt> metadataMap = New Map<String,Nested_Geofence__mdt>();
    public DateTime batchStartTime;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //add a record type check and order by asset__c
        //run the batch for 2000 AHC's
        batchStartTime = system.now();
        for(Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt]) {
            metadataMap.put(mdt.Current_Location__c,mdt);
        } 
        String query = 'SELECT Id, Asset__r.AccountId, Asset__c, Location__c, currentLocationId__c FROM Asset_History_custom__c WHERE currentLocationId__c = null and location__c != \'In Transit\' and RecordType.DeveloperName = \'Location\' order by Asset__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset_History_custom__c> ahcList) {
        Set<ID> AccIds = New Set<ID>();
        //do this in start method so you don't have to create this map everytime
        
        Map<String, Id> lastKnownLocationIdMap = new Map<String, Id>();
        
        for (Asset_History_custom__c ahc : ahcList) {
            AccIds.add(ahc.Asset__r.AccountId);
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
                Set<Account> childAccList;
                if(accRelatedCustomerMap.containsKey(ahc.Asset__r.AccountId)) {
                    childAccList = accRelatedCustomerMap.get(ahc.Asset__r.AccountId);
                    if(childAccList != null) {
                        for(Account acc : childAccList) {
                            if(acc.Name == ahc.Location__c) {
                                ahc.currentLocationId__c = acc.Id;
                                ahc.New_Value__c = 'Can be updated - ahc.currentLocationId__c = '+acc.Id;
                                break;                        
                            }
                        }
                    }
                } else if(metadataMap.containskey(ahc.Location__c)) {
                    Nested_Geofence__mdt mdt =metadataMap.get(ahc.Location__c);
                    ahc.currentLocationId__c = mdt.Current_Location_Id__c;
                    ahc.New_Value__c = 'Can be updated - ahc.currentLocationId__c = '+mdt.Current_Location_Id__c;
                }
                else {
                    ahc.New_Value__c = 'won\'t update';
                }
            }
            if (!ahcList.isEmpty()) {
                update ahcList;
            }
        }
        catch(Exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_NullCurrentLocId_FillBatch', 'execute', 'Exception', null, null, true);
            failureMsgs.add('RedesignNl_NullCurrentLocId_FillBatch- Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
       Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
            batchLog.Batch_Name__c = 'RedesignNl_NullCurrentLocId_FillBatch';
            batchLog.Start_Time__c = batchStartTime;
            batchLog.Complete_Time__c = System.now();
            batchLog.Error_msg__c = 'No error';
            batchLog.Failure_records__c = 0;
            batchLog.Status__c = 'Completed';
        if(totalFailureRecords>0){
              batchLog.Error_msg__c = String.join(failureMsgs, '\n');
            batchLog.Failure_records__c = totalFailureRecords;
            batchLog.Status__c = 'Failed';
        }
        insert batchLog;
            
        //create batch data custom method
        
    }
    
}