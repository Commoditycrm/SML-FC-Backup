@isTest
public class testRedesignNL_ARCCreation {

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
        
        Asset ast1 = new Asset();
        ast1.Name = 'test2';
        //ast1.Device_Id__c = 'at5-t16ee4491f50';
        ast1.AccountId = acc.Id;
        ast1.Last_Connected__c = system.now()-45;
        insert ast1;

        Id RecordTypeId = Schema.SObjectType.Asset_history_custom__c.getRecordTypeInfosByName().get('Location').getRecordTypeId(); 
        Asset_history_custom__c objHistory = new Asset_history_custom__c();
        objHistory.Asset__c =   ast1.id;
        objHistory.RecordTypeId = RecordTypeId;
        objHistory.Still_in_this_Location__c = true;
        objHistory.Start_Time__c = system.now()-30;
        objHistory.End_Time__c=system.now()-20;
        objHistory.Still_in_this_Location__c = true;
        insert objHistory;
        
/*        Asset_Summary__c objSummary = new Asset_Summary__c();
        objSummary.Asset__c = ast.Id;
        insert objSummary;*/
        
       API_Response_Childs__c apc = new API_Response_Childs__c();
       apc.Timestamp__c =5658878;
       apc.Timestamp_DateTime__c = System.today();
       apc.Status__c ='Pending';
       apc.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        
       insert apc;
        
       API_Response_Childs__c apc1 = new API_Response_Childs__c();
       apc1.Timestamp__c =5658878;
       apc1.Timestamp_DateTime__c = System.today();
       apc1.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
       apc1.Status__c ='Google Api Error';
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
    static void testAddAssetHistoryCustomRecords(){
        Test.startTest();
			database.executeBatch(New RedesignNL_ARCCreation(),15);
        Test.stopTest();
    }
    
   	@isTest
    static void testAddAssetHistoryCustomRecord(){
        List<Asset_history_custom__c> obj = [select id, Still_in_this_Location__c from Asset_history_custom__c where Still_in_this_Location__c = true];
        for(Asset_history_custom__c objData : obj){
            objData.Still_in_this_Location__c = false;
        }
        update obj;
        Test.startTest();
			database.executeBatch(New RedesignNL_ARCCreation(),15);
        Test.stopTest();
    }
    
    @isTest
    static void testAhclist(){
        List<Asset_history_custom__c> objAssethistory = [select id, Current_Location_Address__c, Start_Time__c, Still_in_this_Location__c from Asset_history_custom__c];
        Asset objAsset = [select id from Asset limit 1];
        
        Test.startTest();
			database.executeBatch(New RedesignNL_ARCCreationNew(),15);
        Test.stopTest();
    }
    
    
}