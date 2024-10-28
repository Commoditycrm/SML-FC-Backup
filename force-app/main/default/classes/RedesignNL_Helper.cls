/*
* Class Name: RedesignNL_ARCCreation
* Created By: Murali Krishna
* Description: This class is used as Helper class to get Record ID,Custom Metadata record and mail regarding error
* Modified Date  Modified By  		Last Change
* Jan 19, 2024   Murali Krishna    Added the new method to pass metadata record from line no 29 to 31
* Feb 12,2024    Murali Krishna    Passing the Batch Job to Helper class to Insert the values in the BDC from Apexjob
*/
global class RedesignNL_Helper {
    
    Public Static Final String ArcLocationRecordtype = 'Location'; 
    Public Static Final String ArcTemperatureRecordtype = 'Temperature'; 
    Public Static Final String ArcEventsRecordtype = 'Events'; 
    Public Static Final String AHCLocationRecordtype = 'Location'; 
    Public Static Final String AHCTemperatureRecordtype = 'Temperature'; 
    Public Static Final String AHCEventsRecordtype = 'Events';
    Public Static Final String AHCDwellRecordtype = 'Dwell Time';
    
    Public static ID getAPIChildRecordTypeID(String RecordTypeName) {
        Id RecordType = Schema.SObjectType.API_Response_Childs__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        return RecordType;
    }
    Public static ID getAHCRecTypes(String RecordTypeName){
        Id RecordType = Schema.SObjectType.Asset_History_Custom__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        return RecordType;
    }
    Public static Redesign_NL__mdt getRedesignMetadata(String DeveloperName){
        return Redesign_NL__mdt.getInstance(DeveloperName);
    }
    /*Public static Deletion_Setting__mdt getdeleteMetadata(String DeveloperName){
        return Deletion_Setting__mdt.getInstance(DeveloperName);
    }*/
    //----------------------------Email method--------------------------------------------------------------------
    public static void sendemail(String errorMessage){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toaddress();
        message.subject = 'SML--fcbackup ';
        message.plainTextBody = errorMessage;
       // Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
          //  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    // preparing toAddress to send email to
    public static list<string> toaddress(){
        set<id> usrids = new set<id>();
        list<string> emaillist = new list<string>();
        /*for(groupmember gm : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember where Group.DeveloperName = 'developers' ]){
            usrids.add(gm.UserOrGroupId);    
        }
        for(user usr : [select id,email from user where id IN : usrids]){
            emaillist.add(usr.email);
        }*/
        
        
        return emaillist;
    }
    
    public static Batch_Data_Custom__c createBatchDataCustom(Database.BatchableContext bC, Batch_Data_Custom__c bdc, String batchName, DateTime batchStartTime, List<String> failureMsgs, Integer totalFailureRecords, String status, Integer totalRecords) {
        Batch_Data_Custom__c batchLog = (bdc == null) ? new Batch_Data_Custom__c() : bdc;
        batchLog.Batch_Name__c = batchName;
        batchLog.Start_Time__c= batchStartTime;
        batchLog.Complete_Time__c = system.now();
        batchLog.Error_msg__c = String.join(failureMsgs, '\n');
        batchLog.Failure_records__c = totalFailureRecords ;
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
        upsert batchLog;
        return batchLog;
    }
    
    //----------------------------wrapper class for RedesignNL_Controller-----------------------------------------
    
   /* public class temp{
        public Decimal relativehumidity{get;set;}
        public decimal temperature{get;set;}
        public long ts{get;set;}
        public Datetime Timets{get;set;}
    }
    
    
    
    public class loc{
        public Decimal Accuracy{get;set;}
        public String lon{get;set;}
        public Decimal pdop{get;set;}
        public String lat{get;set;}
        public Decimal alt{get;set;}
        public Decimal haccRank{get;set;}
        public Decimal hacc{get;set;}
        public long requestTs{get;set;}
        public Decimal speed{get;set;}
        public String src{get;set;}
        public String heading{get;set;}
        public long ts{get;set;}
        public Boolean calc{get;set;}
        public Decimal battery{get;set;}
        public Decimal signal{get;set;}     
        public Decimal estBattPct{get;set;}
        public Decimal rssi{get;set;}
        public Decimal rsrq{get;set;}
        public long powerUptime{get;set;}
        public Decimal rsrp{get;set;}
        public String MessageType{get;set;}
        public String network{get;set;}
        public long devicets{get;set;}
        public Datetime devicetime{get;set;}
        public Datetime Timets{get;set;}
        public String Poweruptimelist{get;set;}
        public String loctslist{get;set;}
    }
    
    
    public class events{
        //public eventData eventData{get;set;}
        public String eventName{get;set;}
        public long ts{get;set;}
        public Datetime Timets{get;set;}
    }
    */
    
    
}