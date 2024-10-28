global class RedesignNL_InTransitEverAHCBatch implements Database.Batchable<sObject>, Database.Stateful ,Schedulable{
    public string query;
    public List<Id> assetIds;
    public DateTime endDate;
    //Batch Log fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public Datetime lastTime;
    global static Datetime Startdtime;
    public String batchNumber;
    public String jobId;
    public Boolean isInsertAHC = false;
    Public String batchStatus;
    public static List<Asset_History_Custom__c> existingEverRecord = new List<Asset_History_Custom__c>();
    
    
    public RedesignNL_InTransitEverAHCBatch(List<Id> assetIds){//, Datetime endDate) {
        endDate = Date.today().addMonths(-3);
        this.assetIds = assetIds;
        this.endDate = endDate;
        //Initializing for BatchLogs
        this.batchName='RedesignNL_InTransitEverAHCBatch';
        this.batchStartTime = system.Now();
    }
    public RedesignNL_InTransitEverAHCBatch(){
        //Initializing for BatchLogs
        this.batchName='RedesignNL_InTransitEverAHCBatch';
        this.batchStartTime = system.Now();
    }
    public RedesignNL_InTransitEverAHCBatch(String batchNumber) {
        //Initializing for BatchLogs
        this.batchName='RedesignNL_InTransitEverAHCBatch';
        this.batchStartTime = system.Now();
        this.batchNumber = batchNumber;
    }
    public RedesignNL_InTransitEverAHCBatch(Boolean isInsertAHC) {
        this.isInsertAHC = isInsertAHC;
        this.batchName='RedesignNL_InTransitEverAHCBatch';
        this.batchStartTime = system.Now();
    }
    
    private String astID;
    private Map<Integer, Asset_History_Custom__c> AHCMap = new Map<Integer, Asset_History_Custom__c>();
    private List<Asset_History_Custom__c> insertRecords = new List<Asset_History_Custom__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(String.isBlank(query)) {
            if(isInsertAHC == true) {
                List<In_Transit_Ever_Daily_Records__c> inTransitEverList = [Select Asset_ID__c from In_Transit_Ever_Daily_Records__c 
                                                                            where CreatedDate = TODAY];
                Set<Id> assetIDList = new Set<Id>();
                for(In_Transit_Ever_Daily_Records__c ite : inTransitEverList) {
                    assetIDList.add(ite.Asset_Id__c);
                }
                query = 'SELECT Id, Name FROM Asset WHERE Id in:assetIDList';
            }
            else {
                // query = 'SELECT Id, Name FROM Asset WHERE LastModifiedDate  = YESTERDAY AND Last_Connected__c = LAST_N_DAYS:90 and Total_Dwell_Days__c <= 14';
                query = 'SELECT Id, Name FROM Asset WHERE Last_Synced_Timestamp__c  >= YESTERDAY';
            }
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Asset> scope) {
        jobId = bc.getJobId();
        totalRecords += scope.size();
        String recordType = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype);
        
        for(Asset ast: scope) {
            String astId = ast.Id;
            Boolean alreadyInTransit = false;
            DateTime StartTimeToQuery = null;
            DateTime InTransitLocST = null;
            existingEverRecord = getExistingEverRecord(astId);
            List<In_Transit_Ever_Daily_Records__c> intransitDailyRecordsInsertLst = new List<In_Transit_Ever_Daily_Records__c>();
            if(endDate == null)
                endDate = Date.today().addMonths(-3);
            system.debug('endDate--'+endDate);
            // Below query to pick lowest endtime record from newly created AHC records which are not yet picked by Intransitever Batch
            List<Asset_History_Custom__c> tempAHCNotMarked = [Select Id, Name, Start_Time__c, End_Time__c from Asset_History_Custom__c where In_Transit_Ever_Check__c = false and
                                                              RecordType.DeveloperName = 'Location' and Asset__c = :astId and End_Time__c = LAST_90_DAYS order by Start_time__c asc LIMIT 1];
            
            if(tempAHCNotMarked.size() > 0) {
                endDate = tempAHCNotMarked[0].End_Time__c;
                //    StartTimeToQuery = tempAHCNotMarked[0].Start_Time__c;
                //This query used to get the Min and Max values of Endtime  AHC recods which are grouped with Location
                //this query takes All older AHC records Which are already processed in Intransit Batch
                //In that list of old ahc records we group ahc based on AHC location(either in transit or Known Location)  
                //In between the minimum endtime and maximum endtime of Intransit record there shouldn't be any known location record
                List<AggregateResult> LocationAggResTempAHC = [SELECT MAX(End_Time__c) Maxendtime, MIN(End_Time__c) Minendtime, Location__c FROM Asset_History_Custom__c WHERE Asset__c = :astId 
                                                               AND End_Time__c < :endDate AND RecordType.DeveloperName = 'Location' GROUP BY Location__c];
                
                List<AggregateResult> DwellTimeAggTempAHC = new List<AggregateResult>();
                Map<String, DateTime> locationTimeMap = new Map<String, DateTime>();
                //    if(LocationAggResTempAHC.size() > 0) {
                for(AggregateResult ag : LocationAggResTempAHC) {
                    if((String)ag.get('location__c') != 'In Transit') {
                        if(ag.get('Maxendtime') != null)//use alias name
                            locationTimeMap.put((String)ag.get('location__c'),(datetime) ag.get('Maxendtime'));
                    }
                    else {
                        if(ag.get('Minendtime') != null)
                            InTransitLocST = (datetime) ag.get('Minendtime');                            
                    }
                }
                // }
                Datetime Dwellchecktime = InTransitLocST !=null ? InTransitLocST : endDate;
                
                DwellTimeAggTempAHC = [SELECT MAX(End_Time__c) Maxendtime FROM Asset_History_Custom__c WHERE Asset__c = :astId 
                                       AND End_Time__c <= :Dwellchecktime AND RecordTypeId = :recordType];
                
                for(AggregateResult ag : DwellTimeAggTempAHC) {
                    if(ag.get('Maxendtime') != null)
                        locationTimeMap.put('in-transit-ever',(datetime) ag.get('Maxendtime'));
                }                    
                if(locationTimeMap.size() > 0) {
                    DateTime locationDT = null;
                    DateTime inTransitEverDT = null;
                    for(String lt : locationTimeMap.keySet()) {
                        locationDT = (locationDT == null ? locationTimeMap.get(lt) : (locationDT < locationTimeMap.get(lt) ? locationTimeMap.get(lt) : locationDT));
                        inTransitEverDT = lt == 'in-transit-ever' ? locationTimeMap.get(lt) : null;
                        
                    }
                    if(locationDT != null) {
                        endDate = locationDT;
                        alreadyInTransit = false;                                
                    }
                    else if(inTransitEverDT != null) {
                        alreadyInTransit = true;
                    }
                }
                
                if(locationTimeMap.size() == 0 && InTransitLocST != null) {
                    endDate = InTransitLocST;
                }
                
                String query = 'SELECT Id,Name,Asset__c, In_Transit_Ever_Check__c ,Last_Known_Location__c, Start_Time__c,End_Time__c,Device_Id__C,API_Response__c,Still_in_transit__c,'+
                    'Total_Dwell_days__c,Location__c, Dwell_Days__c,Last_Known_Location_Lookup__c, CreatedDate FROM Asset_History_Custom__c ' +
                    'WHERE Asset__c = :astId AND RecordType.DeveloperName = \'Location\' ';
                query += 'AND End_Time__c >= : endDate ORDER BY Start_time__c ASC';
                
                //System.debug('query--'+query);
                List<Asset_History_Custom__c> tempAHCRecords = Database.query(query);
                
                // Create a map of Temporary AHC records using an incrementing key
                Map<Integer, Asset_History_Custom__c> AHCMap = new Map<Integer, Asset_History_Custom__c>();
                Integer key = 0;
                for (Asset_History_Custom__c tempAHC : tempAHCRecords) {
                    AHCMap.put(key, tempAHC);
                    tempAHC.In_Transit_Ever_Check__c  = true;
                    key++;
                }
                List<Asset_History_Custom__c> InTransitAHCList = createInTransitRecords(recordType, AHCMap, alreadyInTransit);
                List<Asset_History_Custom__c> tempAHCDeleteList = new List<Asset_History_Custom__c>();
                /* if(isInsertAHC ==true) {
if(startdtime !=null){
tempAHCDeleteList = [SELECT Id, Name, Dwell_Days__c, Record_Type_Developer_Name__c
FROM Asset_History_Custom__c
WHERE Record_Type_Developer_Name__c = 'Dwell_Time'
AND Asset__c = :astId
AND End_Time__c >=:Startdtime and End_Time__c !=: Startdtime
ORDER BY Start_time__c asc
];
}
}*/
                try{
                    if(isInsertAHC ==true) {
                        
                        if(tempAHCRecords.size() > 0){
                            /*Database.SaveResult[] AHCRecords= database.update(tempAHCRecords,false);
List<Id> successfulRecords = new List<Id>();
List<Database.Error> failedRecordsErrors = new List<Database.Error>();

// Iterate over the save results
for (Database.SaveResult saveResult : AHCRecords) {
if (saveResult.isSuccess()) {

} else {
// Record failed to insert/update
failedRecordsErrors.addAll(saveResult.getErrors());
}
}

// Output the error messages of failed records
for (Database.Error error : failedRecordsErrors) {
failureMsgs.add('Failed Record Error: ' + error.getMessage());
//sendemail('Failed Record Error: ' + error.getMessage());
}*/
                            update tempAHCRecords;
                        }
                        if (!InTransitAHCList.isEmpty()) {
                            insert InTransitAHCList;
                        }
                    }
                    else {
                        
                        for (Asset_History_Custom__c ahc : InTransitAHCList) {
                            In_Transit_Ever_Daily_Records__c record =new In_Transit_Ever_Daily_Records__c();
                            record.Asset_ID__c=ahc.Asset__c;
                            // Create new In_Transit_Ever_Daily_Records__c records without setting the Id
                            intransitDailyRecordsInsertLst.add(record);
                        }
                        if (!intransitDailyRecordsInsertLst.isEmpty()) {
                            insert intransitDailyRecordsInsertLst;
                        }
                    }
                }
                catch(Exception e){
                    // System.debug('The'+e.getMessage()+' exception has occurred: ');
                    RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_InTransitEverAHCBatch', 'execute', 'DML Error', null, null, true);
                    failureMsgs.add('RedesignNL_InTransitEverAHCBatch errormsg - '+e.getMessage());
                    totalFailureRecords = totalFailureRecords + 1;
                    this.batchStatus = 'Failed'; 
                }
                
            }
        }           
    }   
    public static Decimal dwellTime(DateTime t1, DateTime t2) {
        Decimal dt1Long = t1.getTime();
        Decimal dt2Long = t2.getTime();
        Decimal milliseconds = dt2Long - dt1Long;
        Decimal seconds = milliseconds / 1000;
        Decimal minutes = seconds / 60;
        Decimal hours = minutes / 60;
        Decimal days = hours.divide(24, 2);
        return days;
    }
    
    
    public static List<Asset_History_Custom__c> createInTransitRecords(String recordType, Map<Integer, Asset_History_Custom__c> tempAHCDetails, Boolean alreadyInTransit) {
        
        Decimal inTransitDays = 0;
        DateTime InTransStartTime = null;
        String lastknownloc = null;
        Id lastknownlocID = null;
        DateTime InTransEndTime =null;
        Boolean inTransitCreated = false;
        String lastLocation = '';
        List<Asset_History_Custom__c> tempAHCList = new List<Asset_History_Custom__c>();
        
        for (Integer key : tempAHCDetails.keySet()) {
            Asset_History_Custom__c tempAHC = tempAHCDetails.get(key);
            if (String.isNotBlank(tempAHC.Location__c)) {
                lastLocation = tempAHC.Location__c;
                if (alreadyInTransit == true && !lastLocation.equalsIgnoreCase('In Transit')) {
                    alreadyInTransit = false;
                }
                else if(alreadyInTransit == false && lastLocation.equalsIgnoreCase('In Transit')) {                        
                    if (inTransitCreated == false) {
                        if(inTransStartTime == null){
                            InTransStartTime = tempAHC.Start_Time__c;
                            lastknownlocID = tempAHC.Last_Known_Location_Lookup__c != null ? tempAHC.Last_Known_Location_Lookup__c : null;
                            lastknownloc = tempAHC.Last_Known_Location__c != null ? tempAHC.Last_Known_Location__c : null;
                        }
                        inTransitDays = dwellTime(InTransStartTime, tempAHC.End_Time__c); // 4 , 16.07 
                        //  System.debug('intransit after-' + inTransitDays);
                        InTransEndTime = tempAHC.End_Time__c;
                        if (inTransitDays >= Decimal.valueOf(Label.Intransit_Ever)) { 
                            Boolean checkExistingEver = checkExistingRecord(InTransStartTime, InTransEndTime, inTransitDays);
                            if(!checkExistingEver){
                                Asset_History_Custom__c tempAHCInTransit = new Asset_History_Custom__c();
                                tempAHCInTransit.Start_Time__c = InTransStartTime;
                                tempAHCInTransit.End_Time__c = InTransEndTime;
                                tempAHCInTransit.Asset__c =tempAHC.Asset__c;
                                tempAHCInTransit.Total_Dwell_days__c = inTransitDays;
                                tempAHCInTransit.Location__c = 'In Transit - Ever';
                                tempAHCInTransit.RecordTypeId = recordType;
                                inTransitCreated = true;
                                tempAHCInTransit.Still_in_transit__c = true;
                                tempAHCInTransit.Last_Known_Location_Lookup__c = lastknownlocID != null ? lastknownlocID : null;
                                tempAHCInTransit.Last_Known_Location__c = lastknownloc != null ? lastknownloc : null;
                                tempAHCList.add(tempAHCInTransit);
                                if(Startdtime == null ||Startdtime >InTransStartTime)
                                    Startdtime= InTransStartTime;
                            }
                        }
                    }
                } else {
                    inTransitCreated = false;
                    inTransitDays = 0;
                    InTransStartTime = null;
                    InTransEndTime = null;
                    lastknownloc = null;
                    lastknownlocID = null;
                }
            }
        }
        return tempAHCList;
    }
    
    public static List<Asset_History_Custom__c> getExistingEverRecord(Id astId){
        List<Asset_History_Custom__c> obj = [SELECT Id, Start_time__c, End_Time__c, Total_Dwell_days__c 
                                             FROM Asset_History_Custom__c WHERE Record_Type_Developer_Name__c = 'Dwell_Time'
                                             AND Asset__c = :astId];
        return obj;       
    }
    
    public static Boolean checkExistingRecord(Datetime Startdtime, Datetime EndTime, Decimal transitDay){
        Boolean IsTransitRecordExists = false;
        if(existingEverRecord.size() > 0){
            for(Asset_History_Custom__c data : existingEverRecord){
                if(data.Start_Time__c == Startdtime || data.End_Time__c == EndTime){
                       IsTransitRecordExists = true;
                        
                    }
                    else if((data.Start_Time__c >= Startdtime && data.Start_Time__c <= EndTime) || (data.End_Time__c >= Startdtime && data.End_Time__c <= EndTime)){
                        IsTransitRecordExists = true;
                    }
                    else if(data.Start_Time__c >= Startdtime && data.End_Time__c <= EndTime){
                       IsTransitRecordExists = true;
                    }
            }
        }
        return IsTransitRecordExists;
    }
    
    global void finish(Database.BatchableContext bc) {
        Batch_Data_Custom__c batchLog = [SELECT ID, Batch_Name__c, Start_Time__c, Complete_Time__c, Error_msg__c, Status__c, Total_no_of_records_processed__c 
                                         FROM Batch_Data_Custom__c 
                                         WHERE Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch' AND CreatedDate = TODAY 
                                         ORDER BY CreatedDate ASC LIMIT 1];
        
        // Check if a record was found
        if (isInsertAHC==true) {
            // Create a new record
            batchLog = new Batch_Data_Custom__c();
            batchLog.Batch_Name__c = batchName;
            batchLog.Start_Time__c = batchStartTime;
            batchLog.Complete_Time__c = System.now();
            batchLog.Error_msg__c = String.join(failureMsgs, '\n');
            batchLog.Failure_records__c = totalFailureRecords;
            if(batchStatus == 'Processing'){
                batchLog.Status__c = 'Completed';
            }
            else if(totalFailureRecords >0 || this.batchStatus == 'Failed'){
                batchLog.status__c=batchStatus;
            }
            batchLog.Total_no_of_records_processed__c = totalRecords;
             if(bC != null){
                //Murali: Querying AsyncApexJob for insert the values to new three fields
                List<AsyncApexJob> job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
                if(job.size()>0){
                    batchLog.Apex_Batch_Failures__c = job[0].NumberOfErrors;
                    batchLog.Apex_Batch_Processed__c = job[0].JobItemsProcessed;
                    batchLog.Total_Apex_Batch_Processed__c = job[0].TotalJobItems;
                }
            }
            
            // Insert the new record
            insert batchLog;
        } else {
            // Update the existing record
            batchLog.Batch_Name__c = batchName;
            batchLog.Start_Time__c = batchStartTime;
            batchLog.Complete_Time__c = System.now();
            batchLog.Error_msg__c = String.join(failureMsgs, '\n');
            batchLog.Failure_records__c = totalFailureRecords;
            batchLog.Status__c = 'Completed';
            batchLog.Total_no_of_records_processed__c = totalRecords;
             if(bC != null){
                //Murali: Querying AsyncApexJob for insert the values to new three fields
                List<AsyncApexJob> job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
                if(job.size()>0){
                    batchLog.Apex_Batch_Failures__c = job[0].NumberOfErrors;
                    batchLog.Apex_Batch_Processed__c = job[0].JobItemsProcessed;
                    batchLog.Total_Apex_Batch_Processed__c = job[0].TotalJobItems;
                }
            }
            // Upsert the existing record
            upsert batchLog;
        }
        
        List<Batch_Data_Custom__c> bdcList = [SELECT Id, CreatedDate FROM Batch_Data_Custom__c WHERE CreatedDate = TODAY AND Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch' ORDER BY CreatedDate DESC LIMIT 20];
        
        if (bdcList.size() == 2 && isInsertAHC==true) {
            //we have to replace the deletion batch here if we are going to chain the deletion batch
            //RedesignNL_DeletionBatch
              database.executeBatch(new RedesignNL_CreateAssetHistoryBatch(), 15);
        }
        
        
    }
    
    global void execute(SchedulableContext sc){
        database.executebatch(new RedesignNL_InTransitEverAHCBatch(),30);
    }
    
    
}//batch class endse