@isTest
public class testRedesignNL_UpdateAPIResponse {
        public static List<Id> failureAssetIds = new List<Id>();
    @testSetup static void testDataSetup(){
        
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test'; 
        ast.Capture_Movement_Event__c = true;
        insert ast;
        
/*        Asset_Summary__c objSummary = new Asset_Summary__c();
        objSummary.Asset__c = ast.Id;
        insert objSummary;*/
        
       API_Response_Childs__c apc = new API_Response_Childs__c();
       apc.Timestamp__c =5658878;
       apc.Timestamp_DateTime__c = System.today();
       apc.Status__c ='Pending';
        apc.ARC_External_Id__c='123';
       insert apc;
        
       API_Response_Childs__c apc1 = new API_Response_Childs__c();
       apc1.Timestamp__c =5658878;
       apc1.Timestamp_DateTime__c = System.today();
       apc1.Status__c ='Google Api Error';
         apc1.ARC_External_Id__c='1223';
       insert apc1;        
        
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test1';
        objAPIResponse.Asset__c = ast.Id;
        objAPIResponse.Status__c ='New';
        insert objAPIResponse;

        API_Response__c objPending = new API_Response__c();
        objPending.Incoming_Messsage__c ='test2';
        objPending.Asset__c = ast.Id;
        objPending.Status__c ='Pending';
        insert objPending;
       
    }
    
    @isTest
    static void testBatchProcessing() {
        Asset objAsset =[select id from Asset limit 1];
        
        List<String> assetIdList = new List<String>();
        assetIdList.add(objAsset.id);
        
        DateTime previousHour = system.now();
        
        List<API_Response__c> apiRespRecList = [select Id, Status__c, AfterAssetProcDttime__c, BefAssetProcTime__c, AfterAssetProcTime__c, Incoming_Messsage__c,Asset__c from API_Response__c where Status__c ='New'];
        RedesignNL_UpdateAPIResponse obj = new RedesignNL_UpdateAPIResponse('');
        
        RedesignNL_UpdateAPIResponse objParameterised = new RedesignNL_UpdateAPIResponse(failureAssetIds, system.now(), apiRespRecList);
        
        Test.startTest();
        obj.previousHour = system.now();
        	Database.executeBatch(objParameterised);
        Test.stopTest();
        
        
 /*       
        List<String> assetIdList = new List<String>{'Asset1', 'Asset2'};
            DateTime previousHour = DateTime.now().addHours(-1);
        Datetime BefAssetProcDttime = Datetime.now().addMinutes(-30);
        List<API_Response__c> apiRespRecList = new List<API_Response__c>();

        insert apiRespRecList;
        
        Test.startTest();
        RedesignNL_UpdateAPIResponse batchInstance = new RedesignNL_UpdateAPIResponse(assetIdList, previousHour, BefAssetProcDttime, apiRespRecList);
        Database.executeBatch(batchInstance);
        Test.stopTest();
        
        List<API_Response__c> updatedRecords = [SELECT Id, Status__c FROM API_Response__c WHERE Id IN :apiRespRecList];
        System.assertEquals('PROCESSED', updatedRecords[0].Status__c, 'Status should be updated to PROCESSED');
*/
    }
    
    // Add more test methods as needed for different scenarios
}