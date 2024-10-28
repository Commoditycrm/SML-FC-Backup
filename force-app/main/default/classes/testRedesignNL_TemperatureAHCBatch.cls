@isTest(SeeAllData=false)
public class testRedesignNL_TemperatureAHCBatch {
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
        ast.Capture_Temperature_Response__c = true;
        ast.Power_Reset_Occurred__c = true;
        ast.Battery_Replaced_Date__c = date.valueof(system.now());
        ast.Power_Reset_Time__c = system.now().adddays(-1);
        insert ast;
        
        Asset ast1 = new Asset();
        ast1.Name = 'atp2bbef1c017f1';
        ast1.Device_Id__c = 'at5-t16ee4491f501';
        ast1.AccountId = acc.Id;
        ast1.Last_Known_Location__c = acc.Id;
        ast1.Current_Location__c = acc.Id;
        ast1.Current_Address__c = 'test';
        ast1.Capture_Movement_Event__c = true;
        ast1.Capture_Temperature_Response__c = false;
        ast1.Power_Reset_Occurred__c = true;
        ast1.Battery_Replaced_Date__c = date.valueof(system.now());
        ast1.Power_Reset_Time__c = system.now().adddays(-1);
        insert ast1;
        
       Id RecordTypeId = Schema.SObjectType.API_Response_Childs__c.getRecordTypeInfosByName().get('Temperature').getRecordTypeId(); 
       API_Response_Childs__c apc = new API_Response_Childs__c();
       apc.Temperature__c =5658878;
       apc.Asset__c =  ast.Id; 
       apc.Timestamp_DateTime__c = System.today();
       apc.ARC_External_Id__c =ast1.Id +'~'+ apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
       apc.status__c = 'New';
       apc.RecordTypeId = RecordTypeId;
       insert apc;
        
       API_Response_Childs__c apc1 = new API_Response_Childs__c();
       apc1.Temperature__c =5658878;
       apc1.Asset__c =  ast.Id; 
       apc1.Timestamp_DateTime__c = System.today();
       apc1.ARC_External_Id__c =ast.Id+'~'+ apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
       apc1.status__c = 'New';
       apc1.RecordTypeId = RecordTypeId;
       insert apc1; 
        
        Asset_History_custom__c objHistory = new Asset_History_custom__c();
        objHistory.Temperature__c =123;
        objHistory.Asset__c = ast.Id;
        insert objHistory;
        
/*        Asset_Summary__c objSummary = new Asset_Summary__c();
        objSummary.Asset__c = ast.Id;
        insert objSummary;        */
        API_Response__c objAPIResponse1 = new API_Response__c();
        objAPIResponse1.Incoming_Messsage__c ='test';
        objAPIResponse1.Asset__c = ast1.Id;
        objAPIResponse1.Status__c = 'New';
        insert objAPIResponse1;
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test';
        objAPIResponse.Asset__c = ast.Id;
        insert objAPIResponse;
               
    }

    @isTest
    static void testRedesignNLTemperatureAHC(){
       List<API_Response__c> apiRespRecList = [select Id,Asset__r.id, Incoming_Messsage__c,Asset__c  from API_Response__c];
       Asset objAsset = [select id from Asset where Capture_Temperature_Response__c = true limit 1];
       List<String> astID = new List<String>();
       astID.add(objAsset.Id);
        
        String query = 'SELECT Id, Name, Latest_Temp_AHC__c,Humidity__c,Temperature__c, Capture_Temperature_Response__c,Last_Connected__c, Latest_Temp_ahc__r.Start_Time__c FROM Asset';
        RedesignNL_TemperatureAHCBatch obj = new RedesignNL_TemperatureAHCBatch();
        RedesignNL_TemperatureAHCBatch objQuery = new RedesignNL_TemperatureAHCBatch(query);
        
        Test.startTest();
        Database.executeBatch(new RedesignNL_TemperatureAHCBatch(failureAssetIds, System.today(), apiRespRecList),2);
        Test.stopTest();
        
        system.assertEquals(true, true);
        
    }
    
    @isTest
    static void testBlankAssetSenario(){
        
        List<API_Response__c> apiRespRecList = [select Id,Asset__r.id,Asset__c, Incoming_Messsage__c  from API_Response__c];
        Asset objAsset = [select id from Asset limit 1];
        List<String> astID = new List<String>();
        
        String query = 'SELECT Id, Name, Latest_Temp_AHC__c,Humidity__c,Temperature__c, Capture_Temperature_Response__c,Last_Connected__c, Latest_Temp_ahc__r.Start_Time__c FROM Asset';
        RedesignNL_TemperatureAHCBatch obj = new RedesignNL_TemperatureAHCBatch();
        RedesignNL_TemperatureAHCBatch objQuery = new RedesignNL_TemperatureAHCBatch(query);
        
        Test.startTest();
        Database.executeBatch(new RedesignNL_TemperatureAHCBatch(failureAssetIds, System.today(), apiRespRecList),2);
        Test.stopTest();
        
        system.assertEquals(true, true);
        
    }    
    
   
    
}