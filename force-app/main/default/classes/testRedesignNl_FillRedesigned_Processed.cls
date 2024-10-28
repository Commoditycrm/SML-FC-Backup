@isTest
public class testRedesignNl_FillRedesigned_Processed {
@testSetup 
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
         Asset ast = new Asset();
        ast.Name = 'at5-t16ee4491f50';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Movement__c=  Datetime.now().addDays(-16);
        ast.Movement_End__c =Datetime.now().addHours(-5);
        insert ast;
        
        Api_Response__c ar = new Api_Response__c();
        ar.Redesigned_Processed__c = false;
        ar.Asset__c = ast.Id;
        insert ar;
        
        Api_Response_Childs__c arc = new Api_Response_Childs__c();
        arc.api_response__c = ar.Id;
        arc.ARC_External_Id__c = 'dummy id';
        arc.Asset__c = ast.Id;
        insert arc;
    }
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        RedesignNl_FillRedesigned_ProcessedBatch batchInstance = new RedesignNl_FillRedesigned_ProcessedBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
    }
}