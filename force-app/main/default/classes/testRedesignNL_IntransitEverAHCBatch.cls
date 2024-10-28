@isTest
public class testRedesignNL_IntransitEverAHCBatch {
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
        
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In Transit',
            Start_Time__c = Datetime.now().addDays(-16),
            End_Time__c = Datetime.now().addHours(-1),
            RecordTypeId = locationRecordTypeAhc.Id
        );
        insert ahc;
        
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In range',
            Start_Time__c = Datetime.now().addDays(-16),
            End_Time__c = Datetime.now().addHours(-3),
            RecordTypeId = locationRecordTypeAhc.Id,
            In_Transit_Ever_Check__c = true
        );
        insert ahc1;
        In_Transit_Ever_Daily_Records__c record =new In_Transit_Ever_Daily_Records__c();
                            record.Asset_ID__c=ast.id;
        insert record;
    }
    
    @isTest 
    public static void RedesignNL_InTransitEverAHCBatch(){
        List<Asset> astList = [SELECT Id FROM Asset];
        List<Id> assetIds = new List<Id>();
        
        for(Asset a : astList) {
            assetIds.add(a.Id);
        }
        
        String query = 'SELECT Id,Name,Asset__c, In_Transit_Ever_Check__c , Start_Time__c,End_Time__c,Device_Id__C,API_Response__c,Still_in_transit__c,'+
                    'Total_Dwell_daycheck__c,Location__c, Dwell_Days__c, CreatedDate FROM Asset_History_Custom__c ' +
                    'WHERE Asset__c = :astId AND RecordType.DeveloperName = \'Location\' ';
        // Start the test context
        Test.startTest();
        
        // Instantiate and execute the batch
         Database.executeBatch(new RedesignNL_InTransitEverAHCBatch(false));
        Database.executeBatch(new RedesignNL_InTransitEverAHCBatch()); 
        Database.executeBatch(new RedesignNL_InTransitEverAHCBatch(true)); 
        // Stop the test context
        Test.stopTest();
    }
}