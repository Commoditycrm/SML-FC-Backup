@isTest(SeeAllData=false)
public class TestNimbelink_Helper {
    
    static testmethod void nimbeLink_CTRL1(){
        nimbeLink_CTRL_Helper.NimblinkResponse testResponseWrapper = new nimbeLink_CTRL_Helper.NimblinkResponse();
	        
        nimbeLink_CTRL_Helper.records testRecords = new nimbeLink_CTRL_Helper.records();
        nimbeLink_CTRL_Helper.data testData = new nimbeLink_CTRL_Helper.data();
        nimbeLink_CTRL_Helper.base testbase = new nimbeLink_CTRL_Helper.base();    
        List<nimbeLink_CTRL_Helper.loc> testLocList = new List<nimbeLink_CTRL_Helper.loc>();
        nimbeLink_CTRL_Helper.accmap = new Map<Id,Account>();
        nimbeLink_CTRL_Helper.loc testLoc = new nimbeLink_CTRL_Helper.loc();
        List<nimbeLink_CTRL_Helper.deviceStatus> testdvslist = new List<nimbeLink_CTRL_Helper.deviceStatus>();
        nimbeLink_CTRL_Helper.deviceStatus testdvs = new nimbeLink_CTRL_Helper.deviceStatus();
        List<nimbeLink_CTRL_Helper.temp> testtempList = new List<nimbeLink_CTRL_Helper.temp>();
        nimbeLink_CTRL_Helper.temp testtemp = new nimbeLink_CTRL_Helper.temp();
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<sobject> objs3=new list<sobject>();
        List<Nested_Geofence__mdt> nestedGeofences=new List<Nested_Geofence__mdt>();
            
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            list<Asset_History_custom__c> tempHistoryList = new list<Asset_History_custom__c>();
            account acc=new account();
            acc.name='Testing';
            insert acc;
             nimbeLink_CTRL_Helper.accmap.put(acc.id,acc);
            Asset ast = new Asset();
            ast.Name='at-att18790011bc0';
            ast.Device_Id__c='at-att18790011bc0';
            ast.AccountId=acc.Id;
            ast.Last_Known_Location__c=acc.Id;
            ast.Current_Location__c=acc.Id;
            ast.Current_Address__c='test';
            ast.Capture_Movement_Event__c=false;
            ast.Capture_Temperature_Response__c=true;
            ast.powerup_time__c=41204350;
            ast.Battery_Voltage__c = 6.42;
            ast.rsrp__c =-107;
            ast.rsrq__c = -14;
            ast.rssi__c = -62;
            ast.src__c = 'wifi';
            ast.signal__c = 4;
            ast.Power_reset_occurred__c = true;
            ast.Is_NimbeLink_Asset__c=false;
            ast.estbattpct__c =47.5;
            insert ast;
            
            Asset_History_custom__c ah=new Asset_History_custom__c();
            ah.Asset__c=ast.Id; 
            ah.Timestamp__c= 1687226699;
            ahlist.add(ah);
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=40, haccRank=0, lat=26.252877, lon=49.98464, pdop=99.0, requestTs=1687226699, src=w, ts=1687226701, ...})';
            apires.Device_Status__c='({battery=6.42, estBattPct=50.0, network=2g, powerUptime=41204350, rssi=-60.0, signal=4, ts=1687227010})';
            apires.Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM4MTQ1OTc1MjM3Mzg3MjcxMDE2MjIzNzg3NzkyNTM1NzcxODY1Njg4MzQwNjMwMDc3NDU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4NzIyNzIzNDA2NSwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHQxODc5MDAxMWJjMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4NzIyNjY5OSwgImhhY2NSYW5rIjogMCwgImxvbiI6IDQ5Ljk4NDY0LCAidHMiOiAxNjg3MjI2NzAxLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNi4yNTI4NzcsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH1dLCAidGVtcCI6IFt7Imx2bCI6IDQsICJjIjogMzQuOTc4LCAicmgiOiAyMi4yMTEsICJ0cyI6IDE2ODcyMjY2OTksICJ0YyI6IDB9XSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDQxMjA0MzUwLCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi40MiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2ODcyMjcwMTAsICJyc3NpIjogLTYwLjAsICJlc3RCYXR0UGN0IjogNTAuMH1dLCAiZXZlbnRzIjogW119fV19", "messageId": "8432981444606205", "message_id": "8432981444606205", "publishTime": "2023-06-20T02:13:55.462Z", "publish_time": "2023-06-20T02:13:55.462Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            apires.Temp__c='({c=34.978, lvl=4, rh=22.211, tc=0, ts=1687226699})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at, division=qw3mj8, id=at-att18790011bc0, msgId=shardId-000000000001:49638145975237387271016223787792535771865688340630077458, org=x76qs3, schemaVer=0.6, tss=1687227234065}';
            apires.data__c ='{loc=apires.Loc__c,temp=apires.Temp__c,deviceStatus = apires.Device_Status__c}';
            apires.Asset__c=ast.id;
            apires.Last_Connected__c=system.now();
            objs.add(apires);
            insert objs;
             
        
        // Set values for the temp
        testtemp.rh = 22.211;
        testtemp.lvl = 4;
        testtemp.c = 34.978;
        testtemp.tc = 0;
        testtemp.ts = 1687226699;
        testtempList.add(testtemp);
        testData.temp = testtempList;
                                              
        // Step 2: Assign values to the Loc
        
        testLoc.ttf = 0;
        testLoc.lon = 49.98464;
        testLoc.pdop = 99.0;
        testLoc.lat = 26.252877;
        testLoc.alt = 777.0;
        testLoc.haccRank = 0;
        testLoc.hacc = 40;
        testLoc.requestTs = 1687226699;
        testLoc.src = 'w';
        testLoc.ts = 1687226701L;
        testLoc.calc = true;
        testLoc.rssi = -60.0;
        testLoc.rsrp = -80.0;
        testLoc.rsrq = -10.0;
        testLoc.battery = 3.5;
        testLoc.signal = 4;
        testLocList.add(testLoc);
        testData.loc = testLocList;
        //device status values
        testdvs.estBattPct=47.5;
        testdvs.battery = 6.42;
        testdvs.rsrp=-107;
        testdvs.rsrq=-14;
        testdvs.rssi=-62;
        testdvs.powerUptime = 41204350;
        testdvs.signal=4;
        testdvs.ts= 1687227010L;
        testdvslist.add(testdvs);
        testData.deviceStatus = testdvslist;
        list<long> locid = new list<long>();
        locid.add(testLoc.ts);
      
        //assign values to base
        testbase.msgId= 'shardId-000000000001:49638145975237387271016223787792535771865688340630077458';
        testbase.deviceType = 'at';
        testbase.division ='qw3mj8';
        testbase.tss=1687227234065L;
        testbase.id='at-att18790011bc0';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Apiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDA5ODcyMTcxMjQ4NjYzNzkwODMwNzkzOTM2MzM4OTYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2NzQ2OTkwMjk0MCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxOTcwMTBjMmZjYyJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Ny40MjY0MjYsICJ0cyI6IDE2Njc0Njk4MjIsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg1NTY1MywgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDcwMDd9LCB7InNyYyI6ICJ3IiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDAsICJsb24iOiAtOTcuNDM5NjAxNDUsICJ0cyI6IDE2Njc0Njk4MTcsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg0MjUyNDk2LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogNDB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDEsICJsb24iOiAtOTcuNDQ4MjEyLCAidHMiOiAxNjY3NDY5ODIyLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNS44NDY5MiwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDM0MzV9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDY1Mjk4OTI1LCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi44MiwgInNpZ25hbCI6IDMsICJ0cyI6IDE2Njc0Njk4MjIsICJyc3NpIjogLTg5LCAiZXN0QmF0dFBjdCI6IDYxLjR9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE2Njc0Njk4MTV9XX19XX0=", "messageId": "6151726618581024", "message_id": "6151726618581024", "publishTime": "2022-11-03T10:05:08.892Z", "publish_time": "2022-11-03T10:05:08.892Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
          
            Test.startTest();
            //nimbeLink_CTRL_Helper.parseresponse(apires);
            nimbeLink_CTRL_Helper.caldistance(nimbeLink_CTRL_Helper.accmap,26.252877,49.98464);
            nimbeLink_CTRL_Helper.captureTempResponses(apires,testtempList,ast);
            nimbeLink_CTRL_Helper.updateTempValues(testtempList,ahlist,ast);
            nimbeLink_CTRL_Helper.fetchDownstreamCustomer(ast,ah);
            nimbeLink_CTRL_Helper.checkForDwelDays(ast);
            nimbeLink_CTRL_Helper.fillAssetDetails(ast, testdvs, apires);
           
            Test.stopTest();   
        }
     static testmethod void nimbeLink_CTRL_Helper2(){
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        Map<String, Object> dvcmap=new Map<String, Object>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
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
        ah.Asset__c=ast.Id; 
        ahlist.add(ah);
        Api_Response__c apires=new Api_Response__c();
        apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
        apires.Device_Status__c='({battery=6.73, estBattPct=99.7, network=lte, powerUptime=51250, rsrp=-77, rsrq=-10, rssi=-52, signal=4, ts=1635309519})';
        apires.Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjA0MjM4OTQ2NjkxNDQyNjAxOTE0MTk0NjcyMzc3NzY5OTQwNjczOTIyMTE1OTExNTQ4OTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTUxMzUzOTE1MywgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Mi4xNTgyMDEsICJ0cyI6IDE2MzU1MTM1MjEsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQ2MTI4NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05Mi4xMTkwODEsICJ0cyI6IDE2MzU1MTM1MjcsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQwNjk0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzE2NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEuMCwgInJzcnAiOiAtNzQuMCwgInBvd2VyVXB0aW1lIjogNDkyNDAzMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4xMiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2MzU1MTM1MjcsICJyc3NpIjogLTUwLjAsICJlc3RCYXR0UGN0IjogMTYuNX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTYzNTUxMzUxOH1dfX1dfQ==", "messageId": "3302397642761908", "message_id": "3302397642761908", "publishTime": "2021-10-29T13:19:02.472Z", "publish_time": "2021-10-29T13:19:02.472Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
        apires.Last_Connected__c=system.now();
        apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
        apires.Asset__c=ast.id;
        apires.Last_Connected__c=system.now();
        insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Apiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        //nimbeLink_CTRL.parseresponse();
        nimbeLink_CTRL_Helper.parseresponse(apires);
        
       
        Test.stopTest();
        
    }
    //captureTempTruecheck
     static testmethod void captureTempTruecheck(){
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        Map<String, Object> dvcmap=new Map<String, Object>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
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
        ast.Capture_Temperature_Response__c = false;
        insert ast;
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c=ast.Id; 
        ahlist.add(ah);
        Api_Response__c apires=new Api_Response__c();
        apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
        apires.Device_Status__c='({battery=6.73, estBattPct=99.7, network=lte, powerUptime=51250, rsrp=-77, rsrq=-10, rssi=-52, signal=4, ts=1635309519})';
        apires.Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjA0MjM4OTQ2NjkxNDQyNjAxOTE0MTk0NjcyMzc3NzY5OTQwNjczOTIyMTE1OTExNTQ4OTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTUxMzUzOTE1MywgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Mi4xNTgyMDEsICJ0cyI6IDE2MzU1MTM1MjEsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQ2MTI4NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05Mi4xMTkwODEsICJ0cyI6IDE2MzU1MTM1MjcsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQwNjk0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzE2NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEuMCwgInJzcnAiOiAtNzQuMCwgInBvd2VyVXB0aW1lIjogNDkyNDAzMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4xMiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2MzU1MTM1MjcsICJyc3NpIjogLTUwLjAsICJlc3RCYXR0UGN0IjogMTYuNX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTYzNTUxMzUxOH1dfX1dfQ==", "messageId": "3302397642761908", "message_id": "3302397642761908", "publishTime": "2021-10-29T13:19:02.472Z", "publish_time": "2021-10-29T13:19:02.472Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
        apires.Last_Connected__c=system.now();
        apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
        apires.Asset__c=ast.id;
        apires.Last_Connected__c=system.now();
        insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Apiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        //nimbeLink_CTRL.parseresponse();
        nimbeLink_CTRL_Helper.parseresponse(apires);
        
       
        Test.stopTest();
        
    }
    // send email method
    static testmethod void nimbeLink_CTRL3(){
       
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 28.66903;
            acc.shippinglongitude = -82.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM3NDc3MjgyMjE4ODM2NDQ0MjE1ODA2OTg3MDUyNjU0NjIwODQwOTA2ODU4ODE4NDM3MTM4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4MjkxNjI5ODg5MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0OGJkNjBhYjIwZCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4MjkxNjAyMywgImhhY2NSYW5rIjogMCwgImxvbiI6IC04Mi4xMjk4NTE0NiwgInRzIjogMTY4MjkxNjAyNSwgInBkb3AiOiA5OS4wLCAibGF0IjogMjguNjY5MDMyNDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2ODI5MTYwMjMsICJoYWNjUmFuayI6IDEsICJsb24iOiAtODIuMTE4MDI3LCAidHMiOiAxNjgyOTE2MDMwLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyOC42NjM0NDMsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAzNjkzNX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTMsICJyc3JwIjogLTkwLCAicG93ZXJVcHRpbWUiOiA0OTE2OTIyNSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjkxLCAic2lnbmFsIjogMywgInRzIjogMTY4MjkxNjI5MCwgInJzc2kiOiAtNjMsICJlc3RCYXR0UGN0IjogNzIuOX1dLCAiZXZlbnRzIjogW119fV19", "messageId": "7570151436437605", "message_id": "7570151436437605", "publishTime": "2023-05-01T04:45:02.318Z", "publish_time": "2023-05-01T04:45:02.318Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
            apires.Device_Status__c='({battery=6.91, estBattPct=72.9, network=lte, powerUptime=49169225, rsrp=-90, rsrq=-13, rssi=-63, signal=3, ts=1682916290})';
            apires.Incoming_Messsage__c=apiRequest;
            apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
        
    }
 static testmethod void nimbeLink_CTRL4(){
       
            
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 22.66903;
            acc.shippinglongitude = -80.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM3NDc3MjgyMjE4ODM2NDQ0MjE1ODA2OTg3MDUyNjU0NjIwODQwOTA2ODU4ODE4NDM3MTM4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4MjkxNjI5ODg5MSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0OGJkNjBhYjIwZCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4MjkxNjAyMywgImhhY2NSYW5rIjogMCwgImxvbiI6IC04Mi4xMjk4NTE0NiwgInRzIjogMTY4MjkxNjAyNSwgInBkb3AiOiA5OS4wLCAibGF0IjogMjguNjY5MDMyNDQsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2ODI5MTYwMjMsICJoYWNjUmFuayI6IDEsICJsb24iOiAtODIuMTE4MDI3LCAidHMiOiAxNjgyOTE2MDMwLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyOC42NjM0NDMsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAzNjkzNX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTMsICJyc3JwIjogLTkwLCAicG93ZXJVcHRpbWUiOiA0OTE2OTIyNSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjkxLCAic2lnbmFsIjogMywgInRzIjogMTY4MjkxNjI5MCwgInJzc2kiOiAtNjMsICJlc3RCYXR0UGN0IjogNzIuOX1dLCAiZXZlbnRzIjogW119fV19", "messageId": "7570151436437605", "message_id": "7570151436437605", "publishTime": "2023-05-01T04:45:02.318Z", "publish_time": "2023-05-01T04:45:02.318Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
            apires.Device_Status__c='({battery=6.91, estBattPct=72.9, network=lte, powerUptime=49169225, rsrp=-90, rsrq=-13, rssi=-63, signal=3, ts=1682916290})';
            apires.Incoming_Messsage__c=apiRequest;
            apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
        
    }   
    static testmethod void catchCoverCode(){
       
            
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 22.66903;
            acc.shippinglongitude = -80.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM3NDc3MjgyMjE4ODM2NDQ0MjE1OTQxMDgwNjc2NjA2NTM1NzU3MzE1NDMxMTk0NDI3NDEwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4ODYxOTYxNDU3NiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXM0ZGNmZjRmMTM5ZSJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY4ODYxOTU4NywgImhhY2NSYW5rIjogMCwgImxvbmciOiIiLCAidHMiOiAxNjg4NjE5NTk1LCAicGRvcCI6IDk5LjAsICJsYXQiOiAiIiwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDM5Nzl9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE3LCAicnNycCI6IC0xMjgsICJwb3dlclVwdGltZSI6IDU0ODczNzAwLCAibmV0d29yayI6ICJsdGUiLCAiYmF0dGVyeSI6IDYuNzMsICJzaWduYWwiOiAwLCAidHMiOiAxNjg4NjE5NTk2LCAicnNzaSI6IC0xMDAsICJlc3RCYXR0UGN0IjogNzEuNH1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY4ODYxOTU4N31dfX1dfQ==", "message_id": "8651030989838832", "publishTime": "2023-07-06T05:00:17.887Z", "publish_time": "2023-07-06T05:00:17.887Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=3979, haccRank=0, lat=, long=, pdop=99.0, requestTs=1688619587, src=c, ts=1688619595, ...})';
            apires.Device_Status__c='[{"estBattPct":71.4,"rssi":-100,"ts":1688619596,"signal":0,"battery":6.73,"network":"lte","powerUptime":54873700,"rsrp":-128,"rsrq":-17}]';
            apires.Incoming_Messsage__c=apiRequest;
            //apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
           // apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
        }
       
    
    
    static testmethod void LrimethodCoverCode(){
      
            
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 22.66903;
            acc.shippinglongitude = -80.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM4MTQ1OTc1MjM3Mzg3MjcxMDE2MjIzNzg3NzkyNTM1NzcxODY1Njg4MzQwNjMwMDc3NDU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4NzIyNzIzNDA2NSwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHQxODc5MDAxMWJjMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4NzIyNjY5OSwgImhhY2NSYW5rIjogMCwgImxvbiI6IDQ5Ljk4NDY0LCAidHMiOiAxNjk3OTAzNjYzLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNi4yNTI4NzcsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH1dLCAidGVtcCI6IFt7Imx2bCI6IDQsICJjIjogMzQuOTc4LCAicmgiOiAyMi4yMTEsICJ0cyI6IDE2ODcyMjY2OTksICJ0YyI6IDB9XSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDQxMjA0MzUwLCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi40MiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2ODcyMjcwMTAsICJyc3NpIjogLTYwLjAsICJlc3RCYXR0UGN0IjogNTAuMH1dLCAiZXZlbnRzIjogW119fV19", "message_id": "8432981444606205", "publishTime": "2023-06-20T02:13:55.462Z", "publish_time": "2023-06-20T02:13:55.462Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1697903663, ...}';
            //apires.Device_Status__c='({battery=6.91, estBattPct=72.9, network=lte, powerUptime=49169225, rsrp=-90, rsrq=-13, rssi=-63, signal=3, ts=1697903663})';
            apires.Incoming_Messsage__c=apiRequest;
            apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
        
    } 
    
    static testmethod void powerResetoccureCovercode(){
     
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 22.66903;
            acc.shippinglongitude = -80.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Power_Reset_Occurred__c = false;
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM4MTQ1OTc1MjM3Mzg3MjcxMDE2MjIzNzg3NzkyNTM1NzcxODY1Njg4MzQwNjMwMDc3NDU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4NzIyNzIzNDA2NSwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHQxODc5MDAxMWJjMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4NzIyNjY5OSwgImhhY2NSYW5rIjogMCwgImxvbiI6IDQ5Ljk4NDY0LCAidHMiOiAxNjg3MjI2NzAxLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNi4yNTI4NzcsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH1dLCAidGVtcCI6IFt7Imx2bCI6IDQsICJjIjogMzQuOTc4LCAicmgiOiAyMi4yMTEsICJ0cyI6IDE2ODcyMjY2OTksICJ0YyI6IDB9XSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDQxMjA0MzUwLCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi40MiwgInNpZ25hbCI6IDQsICJ0cyI6IDExMDQ5NTQ4NjMsICJyc3NpIjogLTYwLjAsICJlc3RCYXR0UGN0IjogNTAuMH1dLCAiZXZlbnRzIjogW119fV19", "message_id": "8432981444606205", "publishTime": "2023-06-20T02:13:55.462Z", "publish_time": "2023-06-20T02:13:55.462Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
            apires.Device_Status__c='({battery=6.91, estBattPct=72.9, network=lte, powerUptime=49169225, rsrp=-90, rsrq=-13, rssi=-63, signal=3, ts=1104954863})';
            apires.Incoming_Messsage__c=apiRequest;
            apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
        }

    
    static testmethod void poweruptimeElseCovercode(){
       
            
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            acc.GeoFence_Radius_in_Miles__c = 1;
            acc.shippinglatitude = 22.66903;
            acc.shippinglongitude = -80.12985146;
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='at5-s48bd60ab20d';
            ast.Device_Id__c='at5-s48bd60ab20d';
            ast.Current_Location__c=acc.Id;
            ast.PowerUp_Time__c =49169225;
            ast.AccountId=acc.Id;
            insert ast;
            String apiRequest = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjM4MTQ1OTc1MjM3Mzg3MjcxMDE2MjIzNzg3NzkyNTM1NzcxODY1Njg4MzQwNjMwMDc3NDU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY4NzIyNzIzNDA2NSwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHQxODc5MDAxMWJjMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY4NzIyNjY5OSwgImhhY2NSYW5rIjogMCwgImxvbiI6IDQ5Ljk4NDY0LCAidHMiOiAxNjg3MjI2NzAxLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNi4yNTI4NzcsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH1dLCAidGVtcCI6IFt7Imx2bCI6IDQsICJjIjogMzQuOTc4LCAicmgiOiAyMi4yMTEsICJ0cyI6IDE2ODcyMjY2OTksICJ0YyI6IDB9XSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDAsICJuZXR3b3JrIjogIjJnIiwgImJhdHRlcnkiOiA2LjQyLCAic2lnbmFsIjogNCwgInRzIjoxNjg3MjI2Njk5ICwgInJzc2kiOiAtNjAuMCwgImVzdEJhdHRQY3QiOiA1MC4wfV0sICJldmVudHMiOiBbXX19XX0=", "message_id": "8432981444606205", "publishTime": "2023-06-20T02:13:55.462Z", "publish_time": "2023-06-20T02:13:55.462Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            Api_Response__c apires=new Api_Response__c();
            apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
            apires.Device_Status__c='({battery=6.91, estBattPct=72.9, network=lte, powerUptime=0, rsrp=-90, rsrq=-13, rssi=-63, signal=3, ts=1682916290})';
            apires.Incoming_Messsage__c=apiRequest;
            apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
            apires.Last_Connected__c=system.now();
            apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
            apires.Asset__c=ast.id;
            insert apires;
            apires = [Select id, name, Asset__r.AccountId, Loc__c, Device_Id__c, Device_Status__c, Incoming_Messsage__c, Temp__c, Last_Connected__c, Base__c, Asset__c, CreatedDate from Api_Response__c where Id =: apires.Id];
            objs.add(apires);
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Apiresponse1/*';
            req.httpMethod = 'POST';
            string postdata = apiRequest;
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            //nimbeLink_CTRL_Helper.parseresponse(apires, apires.CreatedDate);
            nimbeLink_CTRL_Helper.parseresponse(apires);    
     
    } 
}