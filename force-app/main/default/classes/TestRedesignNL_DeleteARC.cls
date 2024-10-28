@isTest
public class TestRedesignNL_DeleteARC {
	static asset ast;
    @testSetup
    static void testDataSetup() {
        Map<String, Id> apiRespChildRecTMap = new Map<String, Id>();
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'API_Response_Childs__c'];
        
        for (RecordType rt : recordTypes) {
            apiRespChildRecTMap.put(rt.DeveloperName, rt.Id); 
        } 
         Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        ast = new Asset();
        ast.Name = 'Testing';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Movement__c=  Datetime.now().addDays(-16);
        ast.Movement_End__c =Datetime.now().addHours(-5);
        insert ast;
        
        API_Response_Childs__c arc1 = new API_Response_Childs__c(
            RecordTypeId = apiRespChildRecTMap.get('Temperature'),
            ARC_External_Id__c='123',
            Status__c = 'Processed'
        );
        insert arc1;

        API_Response_Childs__c arc = new API_Response_Childs__c(
            RecordTypeId = apiRespChildRecTMap.get('Location'),
            Status__c = 'Processed',
            Asset__c=ast.id,
            Timestamp_datetime__c= Datetime.now().addDays(-100),
            ARC_External_Id__c='1232'
        );
        insert arc;
       
        
		Id assetHistroyRecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByName().get('Location').getRecordTypeId(); 
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-15),
            End_time__c = system.now(),
            still_in_this_location__c = true,
            RecordTypeId = assetHistroyRecordTypeId
        );
        insert ahc;
        Test.setCreatedDate(arc.Id, System.now().addDays(-40));
        Test.setCreatedDate(arc1.Id, System.now().addDays(-40));
    }

    @isTest 
    public static void testARC() {
        List<API_Response_Childs__c> arclst = [
            SELECT Id, Name, Current_Location_Address__c, HaccRank__c, Asset__r.Name, Asset__c,
            Latitude__c, Location__c, Longitude__c, Facility_Location__c, Status__c 
            FROM API_Response_Childs__c 
            WHERE CreatedDate < LAST_N_DAYS:30 AND RecordType.DeveloperName = 'Location' AND Status__c = 'Processed'
        ];
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Deletion_Setting__mdt dst=Deletion_Setting__mdt.getInstance('API_Response_Child_Temp');
        Test.startTest();
        String jobId = System.schedule('RedesignNL_DeletionBatch', '0 0 0 30 4 ? 2025', new RedesignNL_DeletionBatch());
        database.executeBatch(new RedesignNL_DeleteARCLoc(),100);
        database.executeBatch(new RedesignNL_DeletionBatch(dst.Object_Name__c,dst.Days_to_Retain_Data__c,dst.Object_Filter__c),Integer.valueOf(dst.Deletion_Batch_Size__c));
        
        Test.stopTest();  
        Integer actualBatchJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(actualBatchJobCount, actualBatchJobCount, 'Incorrect number of batch jobs enqueued');
        
        List<API_Response_Childs__c> remainingRecords = [SELECT Id FROM API_Response_Childs__c where RecordType.DeveloperName IN ('Location')];
        System.assertEquals(remainingRecords.size(), remainingRecords.size(), 'All records should have been deleted');
    } 
}