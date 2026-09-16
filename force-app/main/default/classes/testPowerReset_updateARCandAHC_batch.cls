@isTest
public class testPowerReset_updateARCandAHC_batch {
    @testSetup
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.shippinglatitude = 42.59104532;
        acc.shippinglongitude = -83.55054479;
        acc.Capture_Business_Name__c = true;
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Last_Connected2__c = System.now().adddays(-2);
        insert ast;
        
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().adddays(-1);
        apc.Asset__c = ast.Id;
        apc.RecordTypeId = locationRecordType.Id;
        apc.ARC_External_Id__c = 'dummy1';
        insert apc;
        
        Asset_history_custom__c ahc = new Asset_history_custom__c();
        ahc.Start_Time__c = System.now().adddays(-4);
        ahc.End_Time__c = System.now().addhours(-1);
        ahc.Asset__c = ast.Id;
        ahc.Still_in_this_Location__c = true;
	insert ahc;
        
    }
   
    @isTest
    public static void testPowerReset_updateARCandAHC(){
        
        Test.startTest();
        database.executeBatch(new PowerReset_updateARCandAHC_batch(), 30);
        Test.stopTest();
    }
}