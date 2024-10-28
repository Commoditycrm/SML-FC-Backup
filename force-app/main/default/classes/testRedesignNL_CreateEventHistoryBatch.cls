@isTest
public class testRedesignNL_CreateEventHistoryBatch {
    
    static Asset ast;
    static Asset ast1;
    static Asset ast2;
    static Asset_History_custom__c ahc;
    static Asset_History_custom__c ahc1;
    static Asset_History_custom__c ahc2;
     public static List<Id> failureAssetIds = new List<Id>();
    @testSetup 
    static void testDataSetup(){
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
        
        ast1 = new Asset();
        ast1.Name = 'atp2bbef1c017g';
        ast1.Device_Id__c = 'at5-t16ee4491f51';
        ast1.AccountId = acc.Id;
        ast1.Last_Known_Location__c = acc.Id;
        ast1.Current_Location__c = acc.Id;
        ast1.Current_Address__c = 'test';
        ast1.Capture_Movement_Event__c = true;
        ast1.Movement__c=  Datetime.now().addDays(-16);
        insert ast1;
        
        ast2 = new Asset();
        ast2.Name = 'atp2bbef2c017g';
        ast2.Device_Id__c = 'at5-t162e4491f51';
        ast2.AccountId = acc.Id;
        ast2.Last_Known_Location__c = acc.Id;
        ast2.Current_Location__c = acc.Id;
        ast2.Current_Address__c = 'test';
        ast2.Movement__c=Datetime.now().addDays(-16);
        ast2.Capture_Movement_Event__c = true;
        insert ast2;
        
        
        
        Id RecordTypeId = Schema.SObjectType.API_Response_Childs__c.getRecordTypeInfosByName().get('Events').getRecordTypeId(); 
        API_Response_Childs__c arc = new API_Response_Childs__c();
        arc.Timestamp__c = 5658878;
        arc.RecordTypeId = RecordTypeId;
        arc.Timestamp_DateTime__c =  Datetime.now();
        arc.Asset__c  = ast.Id;
        arc.Status__c = 'New';
        arc.Event_Name__c = 'movement';
        arc.ARC_External_Id__c='123';
        insert arc;
         API_Response_Childs__c arc3 = new API_Response_Childs__c();
        arc3.Timestamp__c = 5658878;
        arc3.RecordTypeId = RecordTypeId;
        arc3.Timestamp_DateTime__c =  Datetime.now();
        arc3.Asset__c  = ast.Id;
        arc3.Event_Name__c = 'movementEND';
        arc3.Status__c = 'New';
        arc3.ARC_External_Id__c='1235';
        insert arc3;
        
        API_Response_Childs__c ard = new API_Response_Childs__c();
        ard.Timestamp__c = 5658878;
        ard.RecordTypeId = RecordTypeId;
        ard.Timestamp_DateTime__c =  Datetime.now();
        ard.Asset__c  = ast2.Id;
        ard.Status__c = 'New';
        ard.Event_Name__c = 'movementEnd';
        ard.ARC_External_Id__c='12333';
        insert ard;
        
        Id assetHistroyRecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByName().get('Events').getRecordTypeId(); 
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-16),
            RecordTypeId = assetHistroyRecordTypeId
        );
        insert ahc;
        
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Location__c = 'In range',
            Start_Time__c = Datetime.now().addDays(-17),
            End_Time__c = Datetime.now().addHours(-1),
            RecordTypeId = assetHistroyRecordTypeId,
            In_Transit_Ever_Check__c = true
        );
        insert ahc1;
         Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-16),
            RecordTypeId = assetHistroyRecordTypeId
        );
        Asset_History_Custom__c ahc5 = new Asset_History_Custom__c(
            Asset__c = ast2.Id,
            Start_Time__c = Datetime.now().addDays(-16),
            RecordTypeId = assetHistroyRecordTypeId
        );
        Asset_History_Custom__c ahc3 = new Asset_History_Custom__c(
            Asset__c = ast1.Id,
            Location__c = 'In range',
            Start_Time__c = Datetime.now().addDays(-22),
            End_Time__c = Datetime.now().addDays(-1),
            RecordTypeId = assetHistroyRecordTypeId,
            In_Transit_Ever_Check__c = true
        );
        insert ahc3;
        API_Response_Childs__c arc1 = new API_Response_Childs__c();
        arc1.Timestamp__c = 5658878;
        arc1.RecordTypeId = RecordTypeId;
        arc1.Timestamp_DateTime__c =  Datetime.now();
        arc1.Asset__c  = ast1.Id;
        arc1.Event_Name__c = 'movement';
        arc1.Status__c = 'New';
        arc1.ARC_External_Id__c='1234';
        insert arc1;
         API_Response_Childs__c arc4 = new API_Response_Childs__c();
        arc4.Timestamp__c = 5658878;
        arc4.RecordTypeId = RecordTypeId;
        arc4.Timestamp_DateTime__c =  Datetime.now()+ 2;
        arc4.Asset__c  = ast1.Id;
        arc4.Event_Name__c = 'movementEND';
        arc4.ARC_External_Id__c='123675';
        arc4.Status__c = 'New';
        insert arc4;
        
        API_Response_Childs__c arc7 = new API_Response_Childs__c();
        arc7.Timestamp__c = 5658878;
        arc7.RecordTypeId = RecordTypeId;
        arc7.Timestamp_DateTime__c =  Datetime.now()+1;
        arc7.Asset__c  = ast1.Id;
        arc7.Event_Name__c = 'movement';
        arc7.ARC_External_Id__c='123674';
        arc7.Status__c = 'New';
        insert arc7;
         API_Response_Childs__c arc8 = new API_Response_Childs__c();
        arc8.Timestamp__c = 5658878;
        arc8.RecordTypeId = RecordTypeId;
        arc8.Timestamp_DateTime__c =  Datetime.now();
        arc8.Asset__c  = ast1.Id;
        arc8.Event_Name__c = 'movementEND';
        arc8.Status__c = 'New';
        arc8.ARC_External_Id__c='123567';
        insert arc8;
        
        
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test';
        objAPIResponse.Asset__c = ast.Id;
        insert objAPIResponse;
        
        API_Response__c objAPIResponse1 = new API_Response__c();
        objAPIResponse1.Incoming_Messsage__c ='test';
        objAPIResponse1.Asset__c = ast1.id;
        insert objAPIResponse1;
        API_Response__c objAPIResponse2 = new API_Response__c();
        objAPIResponse2.Incoming_Messsage__c ='test';
        objAPIResponse2.Asset__c = ast2.id;
        insert objAPIResponse2;
        
        
    }
    
    @isTest
    static void testBatchWithCorrectQuery() {
        List<API_Response__c> objResponse = [Select Asset__r.Id,status__c, Incoming_Messsage__c, Asset__c  From API_Response__c];
           Test.startTest();
        RedesignNL_CreateEventHistoryBatch batch = new RedesignNL_CreateEventHistoryBatch(failureAssetIds, System.now(), objResponse);
        Database.executeBatch(batch);
       Test.stopTest();
    }
    
        
}