@isTest
public class testRedesignNL_CTRL {
    @testSetup
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.GeoFence_Radius_in_Miles__c = 20;
        acc.shippinglatitude = 42.59104532;
        acc.shippinglongitude = -83.55054479;
        acc.Capture_Business_Name__c = true;
        acc.ShippingPostalCode= '58102';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Testing';
        acc2.GeoFence_Radius_in_Miles__c = 20;
        acc2.shippinglatitude = 42.59104532;
        acc2.shippinglongitude = -83.55054479;
        acc2.Capture_Business_Name__c = true;
        acc2.ShippingPostalCode= '58102';
        acc2.Geofence_Type__c = 'Custom_Geofence';
        acc2.Geofence_data__c ='[{"id":1,"lat":40.12935403670003,"lng":-77.17211434210286},{"id":2,"lat":40.12531795516454,"lng":-77.17374491506425},{"id":3,"lat":40.12377564934552,"lng":-77.16344655951869},{"id":4,"lat":40.12817276934908,"lng":-77.1627600024823}]';
        insert acc2;
        
        

//        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Account__c = acc.Id;
        astCon.RecordTypeId = AccountRecType.Id;
        astCon.Accelerometer_Status_Desired__c = 'true';
        astCon.Connect_On_Tilt_Desired__c      = 'true';
        astCon.ConnectMovementEnd_Desired__c = 'true';
        astCon.ConnectMovementStart_Desired__c = 'false';
        astCon.Location_Sampling_Period_Desired__c = '86400';
        astCon.Location_Status_Desired__c = 'true';
        astCon.Log_Every_n_Desired__c = 0;
        astCon.Measurement_Period_desired__c = '900';
        astCon.Network_Check_in_period_Desired__c = '86400';
        astCon.Reference_X_Desired__c = 0;
        astCon.Reference_Y_Desired__c = 0;
        astCon.Reference_Z_Desired__c = 0;
        astCon.Temperature_Check_in_Period_Desired__c = '86400';
        astCon.Temperature_Status_Desired__c = 'true';
        astCon.Tilt_Degrees_Desired__c = 15;
        astCon.Tracking_Location_Period_desired__c = '7200';
        astCon.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        astCon.Trackmode_Desired__c = '3';
        astCon.Use_Cell_Desired__c = 'true';
        astCon.Use_GPS_Desired__c = 'false';
        astCon.Use_WiFi_Desired__c = 'true';
        insert astCon;

        Asset ast = new Asset();
        ast.Name = 'at5-s4-testing'; 
        ast.Device_Id__c = 'at5-s4-testing';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        insert ast;
        
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc.Id;
        rc.Related_To__c = acc2.Id;
        insert rc;
          Api_Response__c  resp = new Api_Response__c(Incoming_Messsage__c = 'eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjMzNjU5NTAwMTA3MTY4NzY3MjI5Mjg0NjYxMDY3Nzk0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNzEyNDUwNjkyOCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAgImV2ZW50cyI6IFsgeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNzA4MTQ4MDk5fSx7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE3MDgxNDgwOTl9LHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTcwODE0ODA5OX1dfX1dfQ==', 
                                       ResEnteringDttime__c = system.now(), 
                                       ResEnteringTime__c = (system.now().getTime()/1000),
                                       Is_Nimbelink_Asset__c = true,
                                       Status__c = 'NEW');
                  insert resp;
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Api_Response__c = resp.id;
        apc.Location__c = 'testingAccoubt';
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = 'test';
        apc.PowerUptime__c = 12345;
        apc.RecordTypeId = locationRecordType.Id;
        apc.HaccRank__c = 0;
        apc.ARC_External_Id__c = 'dummy1';
        apc.Accuracy_meters__c = 15;
        apc.Message_Type__c = 'wifi';
        insert apc;
        API_Response_Childs__c apc1 = new API_Response_Childs__c();
        apc1.Timestamp__c =5658878;
        apc1.Timestamp_DateTime__c = System.now().addhours(4);
        apc1.Latitude__c = '42.59104532';
         apc1.Longitude__c = '-83.55054479';
        apc1.RecordTypeId = locationRecordType.Id;
        apc1.Longitude__c = '-83.55054479';
        apc1.Asset__c = ast.Id;
        apc1.ARC_External_Id__c = 'dummy2';
        apc1.HaccRank__c = 0;
	insert apc1;

         API_Response_Childs__c apc2 = new API_Response_Childs__c();
        apc2.Timestamp__c =5658878;
        apc2.Timestamp_DateTime__c = System.now().addhours(4);
        apc2.Latitude__c = '42.59104532';
         apc2.Longitude__c = '-83.55054479';
        apc2.RecordTypeId = locationRecordType.Id;
        apc2.Longitude__c = '-83.55054479';
        apc2.Asset__c = ast.Id;
        apc2.ARC_External_Id__c = 'dummy21';
        apc2.HaccRank__c = 0;
        insert apc2;
         API_Response_Childs__c apc3 = new API_Response_Childs__c();
        apc3.Timestamp_Device_Status__c = 5658878;
        apc3.Latitude__c = '42.59104532';
         apc3.Longitude__c = '-83.55054479';
        apc3.RecordTypeId = locationRecordType.Id;
        apc3.Longitude__c = '-83.55054479';
        apc3.Asset__c = ast.Id;
        apc3.ARC_External_Id__c = 'dummy3';
        apc3.HaccRank__c = 0;
        insert apc3;
          API_Response_Childs__c apc4 = new API_Response_Childs__c();
        apc4.Timestamp_Device_Status__c = 5658878;
        apc4.Latitude__c = '42.59104532';
         apc4.Longitude__c = '-83.55054479';
        apc4.RecordTypeId = locationRecordType.Id;
        apc4.Longitude__c = '-83.55054479';
        apc4.Asset__c = ast.Id;
        apc4.ARC_External_Id__c = 'dummy4';
        apc4.HaccRank__c = 0;
        insert apc4;
        
    }
    @isTest
    public static void testRestMethods() {
        string event = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjMzNjU5NTAwMTA3MTY4NzY3MjI5Mjg0NjYxMDY3Nzk0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNzEyNDUwNjkyOCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAgImV2ZW50cyI6IFsgeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNzA4MTQ4MDk5fSx7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE3MDgxNDgwOTl9LHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTcwODE0ODA5OX1dfX1dfQ==", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string temp = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjI5Mzc5NjMwNjk3NDIzNTUyMDU3MTI3NTk2OTgyMjkwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNjkxMjAxOTY1MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgImxvYyI6IFtdLCAidGVtcCI6IFsgeyJsdmwiOiA0LCAiYyI6IDkwLjE2LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg1MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMjQsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODYxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC4zMiwgInJoIjogMC4wLCAidHMiOiAxNzA4MTQ4NzE1LCAidGMiOiAwfSwgeyJsdmwiOiA0LCAiYyI6IDkwLjI3LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg4MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMzgsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODkxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC41LCAicmgiOiAwLjAsICJ0cyI6MTcwODE0ODQxNSwgInRjIjogMH0gXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTExLCAicnNycCI6IC0xMTAsICJwb3dlclVwdGltZSI6IDUxOTI3MjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNS44NSwgInNpZ25hbCI6IDEsICJ0cyI6MTcwODE0ODExNSwgInJzc2kiOiAtODEsICJlc3RCYXR0UGN0IjogOTcuNX1dLCAiZXZlbnRzIjogW119fV19", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string temp2 = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjI5Mzc5NjMwNjk3NDIzNTUyMDU3MTI3NTk2OTgyMjkwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNjkxMjAxOTY1MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgImxvYyI6IFtdLCAidGVtcCI6IFsgeyJsdmwiOiA0LCAiYyI6IDkwLjE2LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg1MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMjQsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODYxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC4zMiwgInJoIjogMC4wLCAidHMiOiAxNzA4MTQ4NzE1LCAidGMiOiAwfSwgeyJsdmwiOiA0LCAiYyI6IDkwLjI3LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg4MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMzgsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODkxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC41LCAicmgiOiAwLjAsICJ0cyI6MTcwODE0ODQxNSwgInRjIjogMH0gXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTExLCAicnNycCI6IC0xMTAsICJwb3dlclVwdGltZSI6IDUxOTI3MjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNS44NSwgInNpZ25hbCI6IDEsICJ0cyI6MTcwODE0ODExNSwgInJzc2kiOiAtODEsICJlc3RCYXR0UGN0IjogOTcuNX1dLCAiZXZlbnRzIjogW119fV19", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string loc = '{"message": {"data": "eyJyZWNvcmRzIjpbeyJiYXNlIjp7ImRpdmlzaW9uIjoicXczbWo4IiwibXNnSWQiOiJzaGFyZElkLTAwMDAwMDAwMDAwMjo0OTYzNzQ3NzI4MjI0MTEzNzE4OTQxNDc5MDEzODMzNDEzODc0MDc5NTI5Mjc1MjcyNjE5NjI1OCIsInNjaGVtYVZlciI6IjAuNiIsInRzcyI6MTcwMjkxMTE5MTAwMCwiZGV2aWNlVHlwZSI6ImF0NiIsIm9yZyI6Ing3NnFzMyIsImlkIjoiYXQ1LXM0LXRlc3RpbmcifSwiZGF0YSI6eyJpbmZvIjpbXSwibG9jIjpbeyJzcmMiOiJ3IiwicmVxdWVzdFRzIjoxNzA0NDYzMjAwLCJoYWNjUmFuayI6MCwibG9uIjotOTMuMDU4NTcyLCJ0cyI6MTcwODIzNTgwNiwicGRvcCI6OTksImxhdCI6MzkuMTY5ODQ5LCJhbHQiOjc3NywiY2FsYyI6dHJ1ZSwidHRmIjowLCJoYWNjIjoxMjB9LHsic3JjIjoiYyIsInJlcXVlc3RUcyI6MTcwNDQ2MzIwMCwiaGFjY1JhbmsiOjAsImxvbiI6LTk2LjA1ODU3MiwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjQ3LjE2OTg0OSwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6OTQ3M30seyJzcmMiOiJ3IiwicmVxdWVzdFRzIjoxNzA0NDc1MDAwLCJoYWNjUmFuayI6MCwibG9uIjotOTIuMDU4NTcyLCJ0cyI6MTcwODIzNTgwNiwicGRvcCI6OTksImxhdCI6NDIuMTY5ODQ5LCJhbHQiOjc3NywiY2FsYyI6dHJ1ZSwidHRmIjowLCJoYWNjIjoxMjB9LHsic3JjIjoidyIsInJlcXVlc3RUcyI6MTcwNDQ3NTAwMCwiaGFjY1JhbmsiOjAsImxvbiI6LTkyLjA1ODU3MiwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjQyLjE2OTg0OSwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6MTIwfSx7InNyYyI6InciLCJyZXF1ZXN0VHMiOjE3MDQ0NzUwMDAsImhhY2NSYW5rIjowLCJsb24iOi05Mi4wNTg1NzIsInRzIjoxNzA4MjM1ODA2LCJwZG9wIjo5OSwibGF0Ijo0Mi4xNjk4NDksImFsdCI6Nzc3LCJjYWxjIjp0cnVlLCJ0dGYiOjAsImhhY2MiOjEyMH1dLCJ0ZW1wIjpbXSwiYWNjZWwiOltdLCJkZXZpY2VTdGF0dXMiOlt7InJzcnEiOi0xMiwicnNycCI6LTk0LCJwb3dlclVwdGltZSI6MjIwMzk4MDAsIm5ldHdvcmsiOiJsdGUiLCJiYXR0ZXJ5Ijo2LjUzLCJzaWduYWwiOjMsInRzIjogMTcwODI3NDM5MywicnNzaSI6LTY3LCJlc3RCYXR0UGN0Ijo4NC4xfV0sImV2ZW50cyI6W119fV19", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string event1 = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjMzNjU5NTAwMTA3MTY4NzY3MjI5Mjg0NjYxMDY3Nzk0IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNzEyNDUwNjkyOCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAgImV2ZW50cyI6IFsgeyJldmVudE5hbWUiOiAibW92ZW1lbnQiLCAidHMiOiAxNzA4MTQ4MDk5fSx7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE3MDgxNDgwOTl9LHsiZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTcwODE0ODA5OX1dfX1dfQ==", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string temp1 = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjQ3NjMwMDAyNjE1MDk3NTk1ODI5MjI5Mzc5NjMwNjk3NDIzNTUyMDU3MTI3NTk2OTgyMjkwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTcwNjkxMjAxOTY1MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0LXRlc3RpbmcifSwgImRhdGEiOiB7ImluZm8iOiBbXSwgImxvYyI6IFtdLCAidGVtcCI6IFsgeyJsdmwiOiA0LCAiYyI6IDkwLjE2LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg2MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMjQsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODYxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC4zMiwgInJoIjogMC4wLCAidHMiOiAxNzA4MTQ4NzE1LCAidGMiOiAwfSwgeyJsdmwiOiA0LCAiYyI6IDkwLjI3LCAicmgiOiAwLjAsICJ0cyI6IDE3MDgxNDg4MTUsICJ0YyI6IDB9LCB7Imx2bCI6IDQsICJjIjogOTAuMzgsICJyaCI6IDAuMCwgInRzIjogMTcwODE0ODYxNSwgInRjIjogMH0sIHsibHZsIjogNCwgImMiOiA5MC41LCAicmgiOiAwLjAsICJ0cyI6MTcwODE0ODQxNSwgInRjIjogMH0gXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTExLCAicnNycCI6IC0xMTAsICJwb3dlclVwdGltZSI6IDUxOTI3MjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNS44NSwgInNpZ25hbCI6IDEsICJ0cyI6MTcwODE0ODExNSwgInJzc2kiOiAtODEsICJlc3RCYXR0UGN0IjogOTcuNX1dLCAiZXZlbnRzIjogW119fV19", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string loc1 = '{"message": {"data": "eyJyZWNvcmRzIjpbeyJiYXNlIjp7ImRpdmlzaW9uIjoicXczbWo4IiwibXNnSWQiOiJzaGFyZElkLTAwMDAwMDAwMDAwMjo0OTYzNzQ3NzI4MjI0MTEzNzE4OTQxNDc5MDEzODMzNDEzODc0MDc5NTI5Mjc1MjcyNjE5NjI1OCIsInNjaGVtYVZlciI6IjAuNiIsInRzcyI6MTcwMjkxMTE5MTAwMCwiZGV2aWNlVHlwZSI6ImF0NiIsIm9yZyI6Ing3NnFzMyIsImlkIjoiYXQ1LXM0LXRlc3RpbmcifSwiZGF0YSI6eyJpbmZvIjpbXSwibG9jIjpbeyJzcmMiOiJ3IiwicmVxdWVzdFRzIjoxNzA0NDYzMjAwLCJoYWNjUmFuayI6MCwibG9uIjotOTMuMDU4NTcyLCJ0cyI6MTcwODIzNTgwNiwicGRvcCI6OTksImxhdCI6MzkuMTY5ODQ5LCJhbHQiOjc3NywiY2FsYyI6dHJ1ZSwidHRmIjowLCJoYWNjIjoxMjB9LHsic3JjIjoiYyIsInJlcXVlc3RUcyI6MTcwNDQ2MzIwMCwiaGFjY1JhbmsiOjAsImxvbiI6LTk2LjA1ODU3MiwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjQ3LjE2OTg0OSwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6OTQ3M30seyJzcmMiOiJ3IiwicmVxdWVzdFRzIjoxNzA0NDc1MDAwLCJoYWNjUmFuayI6MCwibG9uIjotOTIuMDU4NTcyLCJ0cyI6MTcwODIzNTgwNiwicGRvcCI6OTksImxhdCI6NDIuMTY5ODQ5LCJhbHQiOjc3NywiY2FsYyI6dHJ1ZSwidHRmIjowLCJoYWNjIjoxMjB9LHsic3JjIjoidyIsInJlcXVlc3RUcyI6MTcwNDQ3NTAwMCwiaGFjY1JhbmsiOjAsImxvbiI6LTkyLjA1ODU3MiwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjQyLjE2OTg0OSwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6MTIwfSx7InNyYyI6InciLCJyZXF1ZXN0VHMiOjE3MDQ0NzUwMDAsImhhY2NSYW5rIjowLCJsb24iOi05Mi4wNTg1NzIsInRzIjoxNzA4MjM1ODA2LCJwZG9wIjo5OSwibGF0Ijo0Mi4xNjk4NDksImFsdCI6Nzc3LCJjYWxjIjp0cnVlLCJ0dGYiOjAsImhhY2MiOjEyMH1dLCJ0ZW1wIjpbXSwiYWNjZWwiOltdLCJkZXZpY2VTdGF0dXMiOlt7InJzcnEiOi0xMiwicnNycCI6LTk0LCJwb3dlclVwdGltZSI6MjIwMzk4MDAsIm5ldHdvcmsiOiJsdGUiLCJiYXR0ZXJ5Ijo2LjUzLCJzaWduYWwiOjMsInRzIjogMTcwODI3NDM5MywicnNzaSI6LTY3LCJlc3RCYXR0UGN0Ijo4NC4xfV0sImV2ZW50cyI6W119fV19", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string loc2 = '{"message": {"data": "eyJyZWNvcmRzIjpbeyJiYXNlIjp7ImRpdmlzaW9uIjoicXczbWo4IiwibXNnSWQiOiJzaGFyZElkLTAwMDAwMDAwMDAwMjo0OTYzNzQ3NzI4MjI0MTEzNzE4OTQxNDc5MDEzODMzNDEzODc0MDc5NTI5Mjc1MjcyNjE5NjI1OCIsInNjaGVtYVZlciI6IjAuNiIsInRzcyI6MTcwMjkxMTE5MTAwMCwiZGV2aWNlVHlwZSI6ImF0NiIsIm9yZyI6Ing3NnFzMyIsImlkIjoiYXQ1dGluZyJ9LCJkYXRhIjp7ImluZm8iOltdLCJsb2MiOlt7InNyYyI6InciLCJyZXF1ZXN0VHMiOjE3MDQ0NzUwMDAsImhhY2NSYW5rIjowLCJsb24iOjg4LjMxNTA3NSwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjIyLjU4ODYyMCwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6MTIwfV0sInRlbXAiOltdLCJhY2NlbCI6W10sImRldmljZVN0YXR1cyI6W3sicnNycSI6LTEyLCJyc3JwIjotOTQsInBvd2VyVXB0aW1lIjoyMjAzOTgwMCwibmV0d29yayI6Imx0ZSIsImJhdHRlcnkiOjYuNTMsInNpZ25hbCI6MywidHMiOiAxNzA4Mjc0MzkzLCJyc3NpIjotNjcsImVzdEJhdHRQY3QiOjg0LjF9XSwiZXZlbnRzIjpbXX19XX0=", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string loc3 = '{"message": {"data": "eyJyZWNvcmRzIjpbeyJiYXNlIjp7ImRpdmlzaW9uIjoicXczbWo4IiwibXNnSWQiOiJzaGFyZElkLTAwMDAwMDAwMDAwMjo0OTYzNzQ3NzI4MjI0MTEzNzE4OTQxNDc5MDEzODMzNDEzODc0MDc5NTI5Mjc1MjcyNjE5NjI1OCIsInNjaGVtYVZlciI6IjAuNiIsInRzcyI6MTcwMjkxMTE5MTAwMCwiZGV2aWNlVHlwZSI6ImF0NiIsIm9yZyI6Ing3NnFzMyIsImlkIjoiYXQ1dGluZyJ9LCJkYXRhIjp7ImluZm8iOltdLCJsb2MiOlt7InNyYyI6InciLCJyZXF1ZXN0VHMiOjE3MDQ0NzUwMDAsImhhY2NSYW5rIjowLCJsb24iOjg4LjMxNTA3NSwidHMiOjE3MDgyMzU4MDYsInBkb3AiOjk5LCJsYXQiOjIyLjU4ODYyMCwiYWx0Ijo3NzcsImNhbGMiOnRydWUsInR0ZiI6MCwiaGFjYyI6MTIwfV0sInRlbXAiOltdLCJhY2NlbCI6W10sImRldmljZVN0YXR1cyI6W3sicnNycSI6LTEyLCJyc3JwIjotOTQsInBvd2VyVXB0aW1lIjoyMjAzOTgwMCwibmV0d29yayI6Imx0ZSIsImJhdHRlcnkiOjYuNTMsInNpZ25hbCI6MywidHMiOiAxNzA4Mjc0MzkzLCJyc3NpIjotNjcsImVzdEJhdHRQY3QiOjg0LjF9XSwiZXZlbnRzIjpbXX19XX0=", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        string devst = '{"message": {"data": "ewogICJyZWNvcmRzIjogWwogICAgewogICAgICAiYmFzZSI6IHsKICAgICAgICAiZGl2aXNpb24iOiAicXczbWo4IiwKICAgICAgICAibXNnSWQiOiAic2hhcmRJZC0wMDAwMDAwMDAwMDI6NDk2Mzc0NzcyODIyNDExMzcxODk0MTQ3OTAxMzgzMzQxMzg3NDA3OTUyOTI3NTI3MjYxOTYyNTgiLAogICAgICAgICJzY2hlbWFWZXIiOiAiMC42IiwKICAgICAgICAidHNzIjogMTcwMjkxMTE5MTAwMCwKICAgICAgICAiZGV2aWNlVHlwZSI6ICJhdDYiLAogICAgICAgICJvcmciOiAieDc2cXMzIiwKICAgICAgICAiaWQiOiAiYXQ1LXM0LXRlc3RpbjEyZyIKICAgICAgfSwKICAgICAgImRhdGEiOiB7CiAgICAgICAgImluZm8iOiBbXSwKICAgICAgICAidGVtcCI6IFtdLAogICAgICAgICJhY2NlbCI6IFtdLAogICAgICAgICJkZXZpY2VTdGF0dXMiOiBbCiAgICAgICAgICB7CiAgICAgICAgICAgICJyc3JxIjogLTEyLAogICAgICAgICAgICAicnNycCI6IC05NCwKICAgICAgICAgICAgInBvd2VyVXB0aW1lIjogMjIwMzk4MDAsCiAgICAgICAgICAgICJuZXR3b3JrIjogImx0ZSIsCiAgICAgICAgICAgICJiYXR0ZXJ5IjogNi41MywKICAgICAgICAgICAgInNpZ25hbCI6IDMsCiAgICAgICAgICAgICJ0cyI6IDE3MDgyNzQzOTMsCiAgICAgICAgICAgICJyc3NpIjogLTY3LAogICAgICAgICAgICAiZXN0QmF0dFBjdCI6IDg0LjEKICAgICAgICAgIH0KICAgICAgICBdLAogICAgICAgICJldmVudHMiOiBbXQogICAgICB9CiAgICB9CiAgXQp9===", "messageId": "7464788108267185", "message_id": "7464788108267185", "publishTime": "2023-04-19T05:38:49.475Z", "publish_time": "2023-04-19T05:38:49.475Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
		string dist = '{"message": {"data": "ewogICJyZWNvcmRzIjogWwogICAgewogICAgICAiYmFzZSI6IHsKICAgICAgICAic2NoZW1hVmVyIjogIjAuNiIsCiAgICAgICAgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjQ2OTA1MzQ2NTIzMTkyNjY3MjAzMzU2NjM4NzE4NzY0NDIzNzMxMTUzMzc2NTYxMzMyMjU4IiwKICAgICAgICAidHNzIjogMTc1MTk4OTE1OCwKICAgICAgICAiZGV2aWNlVHlwZSI6ICJhdCIsCiAgICAgICAgImlkIjogIlRlc3RBc3NldGZvclJhaWx3YXkiLAogICAgICAgICJvcmciOiAieDc2cXMzIiwKICAgICAgICAiZGl2aXNpb24iOiAiYXozZ3A3IgogICAgICB9LAogICAgICAiZGF0YSI6IHsKICAgICAgICAiZGV2aWNlU3RhdHVzIjogWwogICAgICAgICAgewogICAgICAgICAgICAidHMiOiAxNzUyMTMzMzk1LAogICAgICAgICAgICAiYmF0dGVyeSI6IDYuNzEsCiAgICAgICAgICAgICJzaWduYWwiOiAzLAogICAgICAgICAgICAiZXN0QmF0dFBjdCI6IDkzLjMsCiAgICAgICAgICAgICJwb3dlclVwdGltZSI6IDcyNTgwMDAsCiAgICAgICAgICAgICJyc3JwIjogLTgyLAogICAgICAgICAgICAicnNycSI6IC0xMi41LAogICAgICAgICAgICAicnNzaSI6IC02MywKICAgICAgICAgICAgIm5ldHdvcmsiOiAibHRlIgogICAgICAgICAgfQogICAgICAgIF0sCiAgICAgICAgImxvYyI6IFsgICAgIAogICAgICAgIF0sCiAgICAgICAgInRlbXAiOiBbXSwKICAgICAgICAiYWNjZWwiOiBbXSwKICAgICAgICAiZGlzdCI6WwogICAgICAgICAgewogICAgICAgICAgICAiYXN5bmMiOnRydWUsCiAgICAgICAgICAgICJtIjogMC4wNTUsCiAgICAgICAgICAgICJ0cyI6IDE3NTIxMzM1MjcsCiAgICAgICAgICAgICJsdmwiOiAyCiAgICAgICAgICB9CiAgICAgICAgICBdLAogICAgICAgICJldmVudHMiOiBbCiAgICAgICAgICAKICAgICAgICBdLAogICAgICAgICJpbmZvIjogW10KICAgICAgfQogICAgfQogIF0KfQ==", "messageId": "10886952787788867", "message_id": "10886952787788867", "publishTime": "2024-04-09T18:46:44.655Z", "publish_time": "2024-04-09T18:46:44.655Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator());
        Test.startTest();
        
        RedesignNL_Controller.parseRequestBody(event, null, false);
        RedesignNL_Controller.parseRequestBody(temp, null, false);
        RedesignNL_Controller.parseRequestBody(loc, null, false);
        RedesignNL_Controller.parseRequestBody(event1, null, false);
        RedesignNL_Controller.parseRequestBody(temp1, null, false);
        RedesignNL_Controller.parseRequestBody(loc1, null, false);
        RedesignNL_Controller.parseRequestBody(loc2, null, false);
        RedesignNL_Controller.parseRequestBody(loc3, null, false);
        RedesignNL_Controller.parseRequestBody(temp2, null, false);
        RedesignNL_Controller.parseRequestBody(devst, null, false);
        RedesignNL_Controller.parseRequestBody(dist, null, false);
        

        Test.stopTest();
    }
    @isTest
     public static void testGADCallout() {
               
          //.List<Api_Response_Childs__c> arcLst1 = New  List<Api_Response_Childs__c>();
         //arcLst1.add(apc);
         List<Api_Response_Childs__c> arcLst = [Select Id, Name, HaccRank__c, Asset__c, Latitude__c, Message_Type__c, Longitude__c, Timestamp__c, Timestamp_DateTime__c,Accuracy_meters__c, Asset__r.Is_Loco_Asset__c, Asset__r.Is_Nimbelink_Asset__c,
                                                Battery__c,API_Response__c, EstBattPct__c, Network__c, PowerUptime__c, rsrp__c,rsrq__c,rssi__c,Signal__c,Timestamp_Device_Status__c,Timestamp_Date_Time_Device_Status__c
                                                FROM Api_Response_Childs__c ];
          List<Api_Response_Childs__c> arcLst1 = [Select Id, Name, HaccRank__c, Asset__c, Latitude__c, Message_Type__c, Longitude__c, Timestamp__c, Timestamp_DateTime__c,Accuracy_meters__c, Asset__r.Is_Loco_Asset__c, Asset__r.Is_Nimbelink_Asset__c,
                                                Battery__c,API_Response__c, EstBattPct__c, Network__c, PowerUptime__c, rsrp__c,rsrq__c,rssi__c,Signal__c,Timestamp_Device_Status__c,Timestamp_Date_Time_Device_Status__c
                                                FROM Api_Response_Childs__c where  location__c!=null];
         Api_Response_Childs__c res = arcLst[0];
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator());
         Test.startTest();
        RedesignNL_Controller.createGoogleAPIRecords(arcLst, arcLst[0].Asset__c);
         RedesignNL_Controller.createGoogleAPIRecords(arcLst1, arcLst1[0].Asset__c);
         //RedesignNL_Controller.createDevStsRecords(res);

         //RedesignNL_Controller.createDevStsRecords(apc);
        Test.stopTest();
          
    }
    private class MockSuccessHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if(endpoint.contains('nearbysearch')){
                res.setBody('{"results": [{"name": "Starbucks", "geometry": {"location": {"lat": 37.7749, "lng": -122.4194}}, "types": ["restaurant", "establishment"]}]}');
            }
            else{
				res.setBody('{"results":[{"address_components":[{"long_name":"123","short_name":"123","types":["street_number"]},{"long_name":"Test Street","short_name":"TS","types":["route"]},{"long_name":"Test City","short_name":"TC","types":["locality","political"]},{"long_name":"California","short_name":"CAS","types":["administrative_area_level_1","political"]},{"long_name":"12345","short_name":"12345","types":["postal_code"]},{"long_name":"United States","short_name":"USA","types":["country","political"]}],"formatted_address":"123 Test Street, Test City, CA, 12345, USA","geometry":{"location":{"lat":37.7749,"lng":-122.4194}},"name":"Test Business","place_id":"ChIJ123456789","types":["establishment","restaurant"]}]}');

            }
            return res;
        }
    }
    
    
    @isTest
    public static void testParseNimbeLinkResponse(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/WorkdayIntegration/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        String str = '{\"StartDate\": \"2019-08-01\",\"EndDate\": \"2019-12-03\"}';
        req.requestBody= Blob.valueOf(str);
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponseGenerator());
        Test.startTest();
        RedesignNL_Controller.parseNimbeLinkResponse();
        Test.stopTest();
    }
}