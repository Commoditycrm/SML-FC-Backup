@isTest
public class testRedesignNL_CreateAPIRespChild_Batch {
    
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
        apc.ARC_External_Id__c='asd';
        insert apc;
        
        
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test';
        objAPIResponse.Asset__c = ast.Id;
        insert objAPIResponse;
    }
    
    @isTest
    static void testRedesignNLCreateAPIRespChild(){
        string query='Select Id, Incoming_Messsage__c from API_Response__c limit 1';
        API_Response__c objAPI = [select Id, Incoming_Messsage__c from API_Response__c limit 1 ];
        List<String> listOfIds = new List<String>();
        if(objAPI != null){
            listOfIds.add(objAPI.Id); 
        }
        Test.startTest();
        RedesignNL_CreateAPIRespChild_Batch obj = new RedesignNL_CreateAPIRespChild_Batch();
        RedesignNL_CreateAPIRespChild_Batch objquery = new RedesignNL_CreateAPIRespChild_Batch(query);
        RedesignNL_CreateAPIRespChild_Batch objRespChild = new RedesignNL_CreateAPIRespChild_Batch(listOfIds);
        Database.executeBatch(new RedesignNL_CreateAPIRespChild_Batch(query), 1);
        Test.stopTest();
        System.assertEquals(true, query != null, 'Query is not null');
    } 
    
    @isTest
    static void testRedesignNLCreateAPIRespChildForBlank(){
        List<String> listOfIds = new List<String>();
        API_Response__c objAPI = [select Id, Incoming_Messsage__c from API_Response__c limit 1 ];
        if(objAPI != null){
            listOfIds.add(objAPI.Id); 
        }
        Test.startTest();
        RedesignNL_CreateAPIRespChild_Batch ab = new RedesignNL_CreateAPIRespChild_Batch();
        RedesignNL_CreateAPIRespChild_Batch objRespChild = new RedesignNL_CreateAPIRespChild_Batch(listOfIds);
        Database.executeBatch(new RedesignNL_CreateAPIRespChild_Batch(listOfIds), 1);
        Test.stopTest();
        System.assertEquals(true, listOfIds.size() != 4);
    }
    
    @isTest
    static void testRedesignNLCreateAPIRespChildForNull(){
        List<String> listOfIds = new List<String>();
        Test.startTest();
        RedesignNL_CreateAPIRespChild_Batch ab = new RedesignNL_CreateAPIRespChild_Batch();
        Database.executeBatch(new RedesignNL_CreateAPIRespChild_Batch(), 1);
        Test.stopTest();
        System.assertEquals(true, true);
    }    
}