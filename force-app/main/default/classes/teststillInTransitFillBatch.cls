@istest
public class teststillInTransitFillBatch {
 @testSetup 
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'Testing';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;  
        ast.State_of_Pallet__c ='In Transit';
        insert ast;
        
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test';
        objAPIResponse.Asset__c = ast.Id;
        objAPIResponse.Status__c='NEW';
        insert objAPIResponse;
        
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1]; 
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.today();
        apc.Asset__c = ast.Id;
        apc.Status__c = 'New';
        apc.RecordTypeId = locationRecordType.Id;
          apc.ARC_External_Id__c='Test1';
        insert apc;
         Batch_Data_Custom__c batchLogintransit = new Batch_Data_Custom__c();
                batchLogintransit.Batch_Name__c = 'RedesignNL_InTransitEverAHCBatch';
                batchLogintransit.Status__c = 'Processing';
                insert batchLogintransit;
        
         RecordType locationRecordTypeAhc = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_Custom__c' AND DeveloperName = 'Location' LIMIT 1];
        String recordType = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype);
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit',
            Start_Time__c = Datetime.now().addDays(-116),
            End_Time__c = Datetime.now().addHours(-11),
            Still_in_this_Location__c = true,
            Consider_for_Dwell__c = true,
            RecordTypeId = locationRecordTypeAhc.Id
        );
        insert ahc;
        Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit - Ever',
            Start_Time__c = Datetime.now().addDays(-16),
            End_Time__c = Datetime.now().addHours(-1),
            RecordTypeId = recordType
        );
        insert ahc2;
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In range',
            Start_Time__c = Datetime.now().addDays(-1640),
            End_Time__c = Datetime.now().addHours(-3400),
            RecordTypeId = locationRecordTypeAhc.Id,
            In_Transit_Ever_Check__c = true
        );
        insert ahc1;
        
        In_Transit_Ever_Daily_Records__c record =new In_Transit_Ever_Daily_Records__c();
                            record.Asset_ID__c=ast.id;
        insert record;
        
    }
     @isTest 
    public static void testBatch(){
        List<Asset> astList = [SELECT Id,State_of_Pallet__c,Total_Dwell_Days__c,Max_LKL_End_time__c FROM Asset];
        
         Test.startTest();
        Database.executeBatch(new stillInTransitFillBatch());
        // Stop the test context
        Test.stopTest();
    }
    
}