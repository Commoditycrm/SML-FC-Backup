global class NimbeLink_CTRL_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, schedulable {
    
    public List<Id> assetIDs = new List<Id>();
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords;
    public Integer totalFailureRecords;
    public List<String> failureMsgs;
    public Set<String> accountIds;
    public String getMsg;
    public NimbeLink_CTRL_Batch(String batchName){
        this.batchName=batchName;
        this.batchStartTime = system.Now();
        this.totalRecords = this.totalFailureRecords = 0;
        this.failureMsgs = new List<String>();
        this.accountIds  = new Set<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Incoming_Messsage__c, Status__c, Device_Id__c, CreatedDate, Asset__c,Asset__r.AccountId,Asset__r.Account.ParentId FROM Api_Response__c WHERE Status__c = \'NEW\' '+ 
                       'AND (Asset__r.Account.Batch_Name__c=:batchName) order by CreatedDate asc';
        // 'AND (Asset__r.Account.Batch_Name__c=:batchName) order by Production_Created_Date__c asc'; 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Api_response__c> scope) {
        string state = 'in transit'; 
        totalRecords += scope.size();
        
        try{
            for(Api_response__c api : scope){
               // Id assetId = nimbeLink_CTRL_Helper.parseresponse(new Api_response__c(Id=api.Id, Incoming_Messsage__c=api.Incoming_Messsage__c, Status__c=api.Status__c), api.CreatedDate);
               NimbeLink_CTRL_Helper.parseresponse(api);
                Id assetId = api.Asset__c;
                if(!String.isBlank(assetId)){
                    this.assetIDs.add(assetId);
                
                    String astQuery = 'select id,name,Device_Id__c,AccountId ,Last_Connected__c,LastModifiedDate,Temporary_Latitude__c,State_of_Pallet__c,Current_Address__c,'+
                                   'Current_Zip_Code__c,Current_City__c,Current_State__c,Current_Street_Address__c,Temporary_Longitude__c From Asset '+ 
                                   'WHERE Id =: assetId AND Temporary_Latitude__c!=null AND '+ 
                                   'Temporary_Longitude__c !=null AND State_of_Pallet__c =:state ';
                    updateCurrentLocationAddress.updateAssetddress(Database.Query(astQuery));
                    
                    /*String achQuery = 'select Asset__c,Asset__r.AccountId, Asset__r.Device_Id__c,Start_Time__c,LastModifiedDate,End_Time__c,Location__c,Latitude__c,Longitude__c,'+
                                      'Last_Connected_Time__c,Current_Location_Address__c from Asset_History_custom__c where Asset__c=: assetId AND Latitude__c != null and '+
                                      'Longitude__c != null and location__c =:state and Current_Location_Address__c =null order by createdDate desc';
                    updateCurrentLocationAddress.updateACHAddress(Database.Query(achQuery));*/
                }
            }
        } catch(Exception exp) {
            failureMsgs.add(exp.getMessage());
            getMsg = exp.getMessage();
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        Batch_Data_Custom__c batchLog = new Batch_Data_Custom__c();
        batchLog.Batch_Name__c = this.batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
      //  batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Error_msg__c = getMsg;
        batchLog.Failure_records__c = totalFailureRecords ;
        batchLog.Status__c = 'Completed';
        batchLog.Total_no_of_records_processed__c = totalRecords;
        insert batchLog; 
        if(!Test.isRunningTest()){ 
            if(assetIDs.size() > 0){ 
                if(System.Label.getConfigurationNimbeLinkMethod == 'ON'){
                    Database.executeBatch(new updateNimbelinkconfiguration_batch(this.assetIDs,this.batchName),1);  
                }else{
                    Database.executeBatch(new storeLocationRecord(this.assetIDs,this.batchName),1);
                }
            }else{
                Integer mins = 5;
                Datetime sysTime = System.now().addMinutes(mins);
                String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();          
                System.schedule('Nimbelink '+this.batchName+' '+ System.now().getTime(), cronExpression, new NimbeLink_CTRL_Batch(this.batchName));
            }
        }
    }
    
    // ----------- For Scheduler -----------
    global void execute(SchedulableContext sc){
        database.executebatch(new NimbeLink_CTRL_Batch(this.batchName),1);
    }
}