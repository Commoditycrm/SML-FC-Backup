@isTest
public class capturingEvents_Test{

    static testMethod void capturingEvents_UnitTest(){
        Account acc = new Account();
        acc.name='Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        insert ast;
        
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c = ast.Id; 
        ah.RecentHistory__c = true;
        ah.Start_Time__c = system.now().addDays(-100);
        ah.End_Time__c = system.now().addDays(-100).addMinutes(1);
        insert ah;        
        
        String requestBody = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTIzNzkxOTg3NTQ4NzI1NDEyNjEzMjMyMjg5Nzk5NzMwODUzNjQ4Mjk3NjE1MTYzNDI2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY3NjAwNTEzODQwMiwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY3NjAwNTExOSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC0xMTQuMTMyMzg3LCAidHMiOiAxNjc2MDA1MTI3LCAicGRvcCI6IDk5LjAsICJsYXQiOiAzNC4zMjY5NTEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAzMDU4fV0sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMC4wLCAicnNycCI6IC05Ni4wLCAicG93ZXJVcHRpbWUiOiAyNzg3MDAsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi45MywgInNpZ25hbCI6IDIsICJ0cyI6IDE2NzYwMDUxMjcsICJyc3NpIjogLTY2LjAsICJlc3RCYXR0UGN0IjogOTkuNH1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NTk5ODgxOX0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NTk5OTAzOH0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NTk5OTkzOH0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NjAwMTk4Nn0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NjAwMzQzOX0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NjAwNDI2NX1dfX1dfQ==", "messageId": "6849164369034169", "message_id": "6849164369034169", "publishTime": "2023-02-10T04:59:01.237Z", "publish_time": "2023-02-10T04:59:01.237Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
    
        Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
        Map<String, Object> mapdetails = (Map<String, Object>) lst_JsonParse.get('message');
        
        String data = (String) mapdetails.get('data');       
        String response = EncodingUtil.base64Decode(data).toString();
        Map<String, Object> lst_JsonParse1 = (Map<String, Object>)Json.deserializeUntyped(response);    
                                
        Map<String,Object> commap = new Map<String, Object>();
        for(object obj : (list<Object>) lst_JsonParse1.get('records')){
            commap.putAll((Map<String, Object>)obj);   
        }    
                                    
        Map<String, Object> datamap = new  Map<String, Object>();
        if(commap.containskey('data')){
            datamap = (Map<String, Object>)commap.get('data');    
        }  
        
        // creating event list
        if(datamap.containskey('events')){
            List<Object> eventlist = (list<Object>)datamap.get('events');
            capturingEvents.parseEventDataMethod(eventlist, ast);
        }                        
    }
    
    static testMethod void capturingEvents_UnitTest2(){
        Account acc = new Account();
        acc.name='Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        insert ast;
        
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c = ast.Id; 
        ah.RecentHistory__c = true;
        ah.Start_Time__c = system.now().addDays(-100);
        ah.End_Time__c = system.now().addDays(-100).addMinutes(1);
        insert ah;
        
        String requestBody = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTIzNzkxOTg3NTQ4NzI1NDEyNjEzMjMyMjg5Nzk5NzMwODUzNjQ4Mjk3NjE1MTYzNDI2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY3NjAwNTEzODQwMiwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY3NjAwNTExOSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC0xMTQuMTMyMzg3LCAidHMiOiAxNjc2MDA1MTI3LCAicGRvcCI6IDk5LjAsICJsYXQiOiAzNC4zMjY5NTEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAzMDU4fV0sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMC4wLCAicnNycCI6IC05Ni4wLCAicG93ZXJVcHRpbWUiOiAyNzg3MDAsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi45MywgInNpZ25hbCI6IDIsICJ0cyI6IDE2NzYwMDUxMjcsICJyc3NpIjogLTY2LjAsICJlc3RCYXR0UGN0IjogOTkuNH1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NTk5ODgxOX0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NTk5OTAzOH0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NTk5OTkzOH0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NjAwMTk4Nn0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY3NjAwMzQzOX0sIHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY3NjAwNDI2NX1dfX1dfQ==", "messageId": "6849164369034169", "message_id": "6849164369034169", "publishTime": "2023-02-10T04:59:01.237Z", "publish_time": "2023-02-10T04:59:01.237Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
    
        Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
        Map<String, Object> mapdetails = (Map<String, Object>) lst_JsonParse.get('message');
        
        String data = (String) mapdetails.get('data');       
        String response = EncodingUtil.base64Decode(data).toString();
        Map<String, Object> lst_JsonParse1 = (Map<String, Object>)Json.deserializeUntyped(response);    
                                
        Map<String,Object> commap = new Map<String, Object>();
        for(object obj : (list<Object>) lst_JsonParse1.get('records')){
            commap.putAll((Map<String, Object>)obj);   
        }    
                                    
        Map<String, Object> datamap = new  Map<String, Object>();
        if(commap.containskey('data')){
            datamap = (Map<String, Object>)commap.get('data');    
        }  
        
        Map<String, Object> datamap1 = new Map<String, Object>();
        if(commap.containskey('base')){
            datamap1 = (Map<String, Object>)commap.get('base');    
            if(datamap1.containskey('id')){
                //ast      = getasset(deviceId);
            }
        }
        
        // creating event list
        if(datamap.containskey('events')){
            List<Object> eventlist = (list<Object>)datamap.get('events');
            capturingEvents.parseEventDataMethodNimblink(eventlist, ast, system.now());
        }                        
    }
}