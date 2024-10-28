@isTest
public class NimbeLink_CTRL_Batch_Test {
    @testSetup
    public static void prepareData(){
        List<Account> accts = new List<Account>(); 
        account acc=new account();
        acc.name='test2';
        acc.Batch_Name__c='Other';
        accts.add(acc);
        accts.add(new Account(name='Testing'));
        insert accts;
        Asset ast = new Asset();
        ast.Name='at5-t16ee4491f50';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Capturing_Response__c = true;
        insert ast;
        insert new Related_Customer__c(Source_Account__c=acc.Id, Related_To__c=acc.Id);
    }
    @isTest
    public static void testBatch(){
        if(Label.Execute_Nimblink_Batch_Process == 'YES'){
            Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
            Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
            //List<>
            //Calling nimbelink ctrl to create API Response
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
            
            req.httpMethod = 'POST';
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
            RestContext.request = req;
            //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
            List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
            gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.8278575',Longitude__c='-94.62209'));
            gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
            insert gads;
            
            //Scenario 1 : no Loc present
            nimbeLink_CTRL.parseresponse();
            
            //Scenario 2: Loc Present
            req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAyMTc4MDMwMjI5MjcyODcwNjExODc1NDAyODc0OTE0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI5ODE4MTQ3MywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTI5ODE2MiwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42MjIwOSwgInRzIjogMTY2OTI5ODE2NCwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuODI3ODU3NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEsICJyc3JwIjogLTgzLCAicG93ZXJVcHRpbWUiOiAxNjQwNTcwMCwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjgyLCAic2lnbmFsIjogMywgInRzIjogMTY2OTI5ODE3MCwgInJzc2kiOiAtNTcsICJlc3RCYXR0UGN0IjogODIuMX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTI5ODE2Mn1dfX1dfQ==", "messageId": "6314496023349537", "message_id": "6314496023349537", "publishTime": "2022-11-24T13:56:25.814Z", "publish_time": "2022-11-24T13:56:25.814Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
            nimbeLink_CTRL.parseresponse();
            //Scenario 3: Capture_Temperature_Response__c = true
            req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5NDUxNDYyOTQzOTcxNDQ0NDczMDE2NDU5NzIyNzcwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIyMjUyMjE2NiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMywgInJzcnAiOiAtMTI2LCAicG93ZXJVcHRpbWUiOiAxNjMzMDAyNSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjQyLCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIyMjQ5NywgInJzc2kiOiAtOTYsICJlc3RCYXR0UGN0IjogODIuMn1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY2OTIxNDk2Nn1dfX1dfQ==", "messageId": "6308796233351266", "message_id": "6308796233351266", "publishTime": "2022-11-23T16:55:26.341Z", "publish_time": "2022-11-23T16:55:26.341Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
            ast.Capture_Temperature_Response__c=true;
            update ast;
            nimbeLink_CTRL.parseresponse();
            //Scenario 4: Power Reset 
            req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
            ast.Capture_Temperature_Response__c=false;
            update ast;
            nimbeLink_CTRL.parseresponse();
            //Scenario 4: backIntime LRI
            req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
            nimbeLink_CTRL.parseresponse();
            Test.startTest();
            //cover NimbeLink_CTRL_Batch Class--
            Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 7);
            system.schedule('nimbelinkBatch','0 0 12 1/1 * ? *',new NimbeLink_CTRL_Batch('Other'));
            /*List<location_record_ignored__c> location_record_ignoreds = [SELECT ID FROM location_record_ignored__c];
system.debug('location_record_ignoreds siz3--'+location_record_ignoreds.size());
Database.executeBatch(new storeLocationRecord(),1);
Database.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'),1);*/
            //cover NimbeLink_CTRL_Batch Class--
            Test.stopTest();
        }
    }
    @isTest
    public static void testBatch2(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        //List<>
        //Calling nimbelink ctrl to create API Response
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
        List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.8278575',Longitude__c='-94.62209'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
        insert gads;
        
        //Scenario 1 : no Loc present
        Api_Response__c api1 = new Api_Response__c(Asset__c=ast.Id,Status__c = 'NEW',Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        insert api1; 
        //nimbeLink_CTRL.parseresponse();
        
        //Scenario 2: Loc Present
        Api_Response__c api2 = new Api_Response__c(Asset__c=ast.Id,Status__c = 'NEW',Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAyMTc4MDMwMjI5MjcyODcwNjExODc1NDAyODc0OTE0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI5ODE4MTQ3MywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTI5ODE2MiwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42MjIwOSwgInRzIjogMTY2OTI5ODE2NCwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuODI3ODU3NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEsICJyc3JwIjogLTgzLCAicG93ZXJVcHRpbWUiOiAxNjQwNTcwMCwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjgyLCAic2lnbmFsIjogMywgInRzIjogMTY2OTI5ODE3MCwgInJzc2kiOiAtNTcsICJlc3RCYXR0UGN0IjogODIuMX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTI5ODE2Mn1dfX1dfQ==", "messageId": "6314496023349537", "message_id": "6314496023349537", "publishTime": "2022-11-24T13:56:25.814Z", "publish_time": "2022-11-24T13:56:25.814Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        insert api2;
        //Scenario 3: Capture_Temperature_Response__c = true
        Api_Response__c api3 = new Api_Response__c(Asset__c=ast.Id,Status__c = 'NEW', Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5NDUxNDYyOTQzOTcxNDQ0NDczMDE2NDU5NzIyNzcwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIyMjUyMjE2NiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMywgInJzcnAiOiAtMTI2LCAicG93ZXJVcHRpbWUiOiAxNjMzMDAyNSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjQyLCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIyMjQ5NywgInJzc2kiOiAtOTYsICJlc3RCYXR0UGN0IjogODIuMn1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50RW5kIiwgInRzIjogMTY2OTIxNDk2Nn1dfX1dfQ==", "messageId": "6308796233351266", "message_id": "6308796233351266", "publishTime": "2022-11-23T16:55:26.341Z", "publish_time": "2022-11-23T16:55:26.341Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        ast.Capture_Temperature_Response__c=true;
        update ast;
        insert api3;
        //Scenario 4: Power Reset 
        Api_Response__c api4 = new Api_Response__c(Asset__c=ast.Id,Status__c = 'NEW', Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        insert api4;
        //Scenario 4: backIntime LRI
        Api_Response__c api5 = new Api_Response__c(Asset__c=ast.Id,Status__c = 'NEW', Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        insert api5;
        Test.startTest();
        //cover NimbeLink_CTRL_Batch Class--
        Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 7);
        system.schedule('nimbelinkBatch','0 0 12 1/1 * ? *',new NimbeLink_CTRL_Batch('Other'));
        Test.stopTest();
    }
    @isTest
    public static void testLocLRI(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        ast.Capture_Temperature_Response__c = true;
        update ast;
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        //List<>
        //Calling nimbelink ctrl to create API Response
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
        List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55442404',Longitude__c='-94.80839065'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55574295',Longitude__c='-94.81133772'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55780642',Longitude__c='-94.80087798'));
        insert gads;
        nimbeLink_CTRL.parseresponse();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDc5MTM5OTU4ODc2Mjc0NTczMTkyNzQxMDM5MTEyMjEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTU1NjExMTI4NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTU1NjA5NCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDgzOTA2NSwgInRzIjogMTY2OTU1NjA5NiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU0NDI0MDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTEwLCAicnNycCI6IC0xMDQsICJwb3dlclVwdGltZSI6IDE2NjYzNjI1LCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzQsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5NTU2MTAyLCAicnNzaSI6IC03NSwgImVzdEJhdHRQY3QiOiA4Mi4wfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5NTU2MDk0fV19fV19", "messageId": "6333976386257454", "message_id": "6333976386257454", "publishTime": "2022-11-27T13:35:16.682Z", "publish_time": "2022-11-27T13:35:16.682Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL.parseresponse();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjA0MjU0MjM1ODA1MTAxNTgwMjk3MjA1NzU5MDgyNTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTM2MTk4NTA0MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTM2MTY2NSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MTEzMzc3MiwgInRzIjogMTY2OTM2MTY2NywgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU1NzQyOTUsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2NjkzNjE2NjUsICJoYWNjUmFuayI6IDEsICJsb24iOiAtOTQuODEwMjI1LCAidHMiOiAxNjY5MzYxNjc0LCAicGRvcCI6IDk5LjAsICJsYXQiOiAzNi41ODc4NTEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMDQ0NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTcsICJyc3JwIjogLTExMCwgInBvd2VyVXB0aW1lIjogMTY0Njk1MDAsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi43OSwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NjkzNjE5NzYsICJyc3NpIjogLTc2LCAiZXN0QmF0dFBjdCI6IDgyLjF9XSwgImV2ZW50cyI6IFtdfX1dfQ==", "messageId": "6319315920108107", "message_id": "6319315920108107", "publishTime": "2022-11-25T07:39:48.987Z", "publish_time": "2022-11-25T07:39:48.987Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL.parseresponse();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAyNTg0ODk2NjMxNzE1ODE0MzI3ODg4ODExOTE3MzQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTMxMzI4NTQ2MCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTMxMzI2NiwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDA4Nzc5OCwgInRzIjogMTY2OTMxMzI2OCwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU3ODA2NDIsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE2LCAicnNycCI6IC0xMTAsICJwb3dlclVwdGltZSI6IDE2NDIwODAwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5MzEzMjc2LCAicnNzaSI6IC03OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5MzEzMjY2fV19fV19", "messageId": "6315767092439024", "message_id": "6315767092439024", "publishTime": "2022-11-24T18:08:10.126Z", "publish_time": "2022-11-24T18:08:10.126Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        Test.startTest();
        //cover NimbeLink_CTRL_Batch Class--
        Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 7);
       // nimbeLink_CTRL.parseresponse();
        List<API_Response__c> apires = [SELECT ID,Asset__c,Incoming_Messsage__c,Loc__c,Temp__c,Device_status__c,Device_Id__c  fROM API_Response__c Order by Createddate desc limit 1];
        system.debug('apires--'+apires.size());
        //nimbeLink_CTRL_Helper.parseresponse(apires[0], system.now());
        nimbeLink_CTRL_Helper.parseresponse(apires[0]);
        Test.stopTest();    
    }
    @isTest
    public static void testLocLRI2(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        ast.Capture_Temperature_Response__c = true;
        update ast;
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        //List<>
        //Calling nimbelink ctrl to create API Response
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDc5MTM5OTU4ODc2Mjc0NTczMTkyNzQxMDM5MTEyMjEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTU1NjExMTI4NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTU1NjA5NCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDgzOTA2NSwgInRzIjogMTY2OTU1NjA5NiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU0NDI0MDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTEwLCAicnNycCI6IC0xMDQsICJwb3dlclVwdGltZSI6IDE2NjYzNjI1LCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzQsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5NTU2MTAyLCAicnNzaSI6IC03NSwgImVzdEJhdHRQY3QiOiA4Mi4wfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5NTU2MDk0fV19fV19", "messageId": "6333976386257454", "message_id": "6333976386257454", "publishTime": "2022-11-27T13:35:16.682Z", "publish_time": "2022-11-27T13:35:16.682Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
        List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55442404',Longitude__c='-94.80839065'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55574295',Longitude__c='-94.81133772'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55780642',Longitude__c='-94.80087798'));
        insert gads;
        nimbeLink_CTRL.parseresponse();
        List<Asset_History_custom__c> ahcs = [SELECT Id FROM Asset_History_custom__c];
        system.debug('ahcs--'+ahcs.size());
        //Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 1);
        //List<Asset_History_custom__c> ahcs = [SELECT Id FROM Asset_History_custom__c];
        //system.debug('ahcs--'+ahcs.size());
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL.parseresponse();
        ast.Capturing_Response__c = false;
        update ast;
        Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 3);
    }
    @isTest
    public static void testupdateNimbelinkconfiguration_batch(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        Test.setMock(HttpCalloutMock.class, new MockGetConfigClass());
        Test.startTest();
        Database.executeBatch(new updateNimbelinkconfiguration_batch(new List<Id>{ast.Id},'Other'), 3);
        Test.stopTest();
    }
    @isTest
    public static void teststoreLocationRecord(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        Test.startTest();
        Database.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'), 3);
        Test.stopTest();
        //Database.executeBatch(new storeLocationRecord(),3);
        
    }
    @isTest static void testnimbeLink_CTRL(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        Test.setMock(HttpCalloutMock.class, new googleApiCallout_Test.ApiMock());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        Test.stopTest();
    }
    @isTest static void testnimbeLink_CTRL_Prod(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        Test.setMock(HttpCalloutMock.class, new googleApiCallout_Test.ApiMock());
        Test.startTest();
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        Test.stopTest();
    }
    @isTest
    public static void testnimbeLink_CTRL_Prod2(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        ast.Capture_Temperature_Response__c = true;
        update ast;
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        //List<>
        //Calling nimbelink ctrl to create API Response
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDc5MTM5OTU4ODc2Mjc0NTczMTkyNzQxMDM5MTEyMjEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTU1NjExMTI4NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTU1NjA5NCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDgzOTA2NSwgInRzIjogMTY2OTU1NjA5NiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU0NDI0MDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTEwLCAicnNycCI6IC0xMDQsICJwb3dlclVwdGltZSI6IDE2NjYzNjI1LCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzQsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5NTU2MTAyLCAicnNzaSI6IC03NSwgImVzdEJhdHRQY3QiOiA4Mi4wfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5NTU2MDk0fV19fV19", "messageId": "6333976386257454", "message_id": "6333976386257454", "publishTime": "2022-11-27T13:35:16.682Z", "publish_time": "2022-11-27T13:35:16.682Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
        List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55442404',Longitude__c='-94.80839065'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55574295',Longitude__c='-94.81133772'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55780642',Longitude__c='-94.80087798'));
        insert gads;
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDc5MTM5OTU4ODc2Mjc0NTczMTkyNzQxMDM5MTEyMjEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTU1NjExMTI4NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTU1NjA5NCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDgzOTA2NSwgInRzIjogMTY2OTU1NjA5NiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU0NDI0MDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTEwLCAicnNycCI6IC0xMDQsICJwb3dlclVwdGltZSI6IDE2NjYzNjI1LCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzQsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5NTU2MTAyLCAicnNzaSI6IC03NSwgImVzdEJhdHRQY3QiOiA4Mi4wfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5NTU2MDk0fV19fV19", "messageId": "6333976386257454", "message_id": "6333976386257454", "publishTime": "2022-11-27T13:35:16.682Z", "publish_time": "2022-11-27T13:35:16.682Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        List<Asset_History_custom__c> ahcs = [SELECT Id FROM Asset_History_custom__c];
        system.debug('ahcs--'+ahcs.size());
        //Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 1);
        //List<Asset_History_custom__c> ahcs = [SELECT Id FROM Asset_History_custom__c];
        //system.debug('ahcs--'+ahcs.size());
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        ast.Capturing_Response__c = false;
        update ast;
        Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 3);
        nimbeLink_CTRL_Prod.sendemail('TestEmail');
        nimbeLink_CTRL_Prod.toaddress();
        //cover test account part in getasset
        Asset ast1 = new Asset();
        ast1.Name='at5-t16ee4491f50';
        ast1.Device_Id__c='at5-t16ee4491f50-test';
        nimbeLink_CTRL_Prod.getasset(ast1.Device_Id__c);
        Test.startTest();
        //No Loc Present
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');      
        Test.stopTest();
        //cover updateTSFromDeviceStatus
        //nimbeLink_CTRL_Prod.updateTSFromDeviceStatus()
    }
    @isTest
    public static void testnimbeLink_CTRL_Prod3(){
        Asset ast = [SELECT Id,Name,Device_Id__c,AccountId,Last_Known_Location__c,Current_Location__c,Current_Address__c,Capture_Movement_Event__c,Capturing_Response__c FROM Asset LIMIT 1];      
        ast.Capture_Temperature_Response__c = true;
        update ast;
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        //List<>
        //Calling nimbelink ctrl to create API Response
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        req.httpMethod = 'POST';
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Apiresponse/*';
        RestContext.request = req;
        //insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='32.34',Longitude__c='32.56');
        List<Google_API_Data__c> gads = new List<Google_API_Data__c>();
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55442404',Longitude__c='-94.80839065'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.763679',Longitude__c='-94.65231'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55574295',Longitude__c='-94.81133772'));
        gads.add(new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.55780642',Longitude__c='-94.80087798'));
        insert gads;
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAxNjk2NzQyMzUzMzc0NDQ5ODEyOTM3NzcyMTA1NzYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTI3NTY0MjM0NywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTI3NTI2MywgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC42NTIzMSwgInRzIjogMTY2OTI3NTI3MiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNzYzNjc5LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzA3NH1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOSwgInJzcnAiOiAtNzQsICJwb3dlclVwdGltZSI6IDE2MzgzMTUwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiA0LCAidHMiOiAxNjY5Mjc1NjMzLCAicnNzaSI6IC00OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbXX19XX0=", "messageId": "6312842575676374", "message_id": "6312842575676374", "publishTime": "2022-11-24T07:40:48.067Z", "publish_time": "2022-11-24T07:40:48.067Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDc5MTM5OTU4ODc2Mjc0NTczMTkyNzQxMDM5MTEyMjEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTU1NjExMTI4NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTU1NjA5NCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDgzOTA2NSwgInRzIjogMTY2OTU1NjA5NiwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU0NDI0MDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTEwLCAicnNycCI6IC0xMDQsICJwb3dlclVwdGltZSI6IDE2NjYzNjI1LCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzQsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5NTU2MTAyLCAicnNzaSI6IC03NSwgImVzdEJhdHRQY3QiOiA4Mi4wfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5NTU2MDk0fV19fV19", "messageId": "6333976386257454", "message_id": "6333976386257454", "publishTime": "2022-11-27T13:35:16.682Z", "publish_time": "2022-11-27T13:35:16.682Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjA0MjU0MjM1ODA1MTAxNTgwMjk3MjA1NzU5MDgyNTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTM2MTk4NTA0MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTM2MTY2NSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MTEzMzc3MiwgInRzIjogMTY2OTM2MTY2NywgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU1NzQyOTUsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2NjkzNjE2NjUsICJoYWNjUmFuayI6IDEsICJsb24iOiAtOTQuODEwMjI1LCAidHMiOiAxNjY5MzYxNjc0LCAicGRvcCI6IDk5LjAsICJsYXQiOiAzNi41ODc4NTEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMDQ0NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTcsICJyc3JwIjogLTExMCwgInBvd2VyVXB0aW1lIjogMTY0Njk1MDAsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi43OSwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NjkzNjE5NzYsICJyc3NpIjogLTc2LCAiZXN0QmF0dFBjdCI6IDgyLjF9XSwgImV2ZW50cyI6IFtdfX1dfQ==", "messageId": "6319315920108107", "message_id": "6319315920108107", "publishTime": "2022-11-25T07:39:48.987Z", "publish_time": "2022-11-25T07:39:48.987Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
       
        Test.startTest();
        //cover NimbeLink_CTRL_Batch Class--
        Database.executeBatch(new NimbeLink_CTRL_Batch('Other'), 7);
        nimbeLink_CTRL_Prod.parseresponse('{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTE1NjAyNTg0ODk2NjMxNzE1ODE0MzI3ODg4ODExOTE3MzQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTMxMzI4NTQ2MCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTMxMzI2NiwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05NC44MDA4Nzc5OCwgInRzIjogMTY2OTMxMzI2OCwgInBkb3AiOiA5OS4wLCAibGF0IjogMzYuNTU3ODA2NDIsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE2LCAicnNycCI6IC0xMTAsICJwb3dlclVwdGltZSI6IDE2NDIwODAwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzgsICJzaWduYWwiOiAxLCAidHMiOiAxNjY5MzEzMjc2LCAicnNzaSI6IC03OCwgImVzdEJhdHRQY3QiOiA4Mi4xfV0sICJldmVudHMiOiBbeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNjY5MzEzMjY2fV19fV19", "messageId": "6315767092439024", "message_id": "6315767092439024", "publishTime": "2022-11-24T18:08:10.126Z", "publish_time": "2022-11-24T18:08:10.126Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}');
        List<API_Response__c> apires = [SELECT ID,Asset__c,Incoming_Messsage__c,Loc__c,Temp__c,Device_status__c,Device_Id__c fROM API_Response__c Order by Createddate desc limit 1];
        system.debug('apires--'+apires.size());
       // nimbeLink_CTRL_Helper.parseresponse(apires[0], system.now());
        nimbeLink_CTRL_Helper.parseresponse(apires[0]);
        Test.stopTest();    
    }
}