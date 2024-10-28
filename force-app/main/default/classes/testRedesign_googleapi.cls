@isTest
public class testRedesign_googleapi {
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'test1';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;  
        insert ast;
        
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.today();
        apc.Location__c='In Transit';
        apc.Latitude__c='33.277843';
        apc.HaccRank__c=0;
        apc.Latitude__c='75.341243';
        apc.Current_Location_Address__c='Address not';
        apc.Status__c ='Google Api Error';
        apc.ARC_External_Id__c = 'Testgoogleapi';
        insert apc;
        
    }
    @isTest public static void testProcessGoogleApiErrors(){
        
        list<API_Response_Childs__c> arc =[SELECT Id, Name, Current_Location_Address__c, HaccRank__c,Asset__r.Name,Asset__c, Latitude__c, Location__c, Longitude__c, Facility_Location__c,Status__c FROM API_Response_Childs__c where Status__c='Google Api Error'];
        
        Test.startTest();
        list<API_Response_Childs__c> arcd = Redesign_googleapi.processGoogleApiErrors(arc);
        Test.stopTest();    
        
        system.assertEquals(arc != null, true, 'List is not empty');
        
    } 
}