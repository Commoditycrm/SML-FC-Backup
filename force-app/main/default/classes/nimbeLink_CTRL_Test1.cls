@isTest(SeeAllData=false)
public class nimbeLink_CTRL_Test1 {
    /* public class ApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse hr = new HttpResponse();
             RestRequest reqs = new RestRequest();
            RestResponse res = new RestResponse();
            reqs.requestURI = '/services/apexrest/Apiresponse/*';
            reqs.httpMethod = 'POST';
            string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDA5ODcyMTcxMjQ4NjYzNzkwODMwNzkzOTM2MzM4OTYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2NzQ2OTkwMjk0MCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxOTcwMTBjMmZjYyJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Ny40MjY0MjYsICJ0cyI6IDE2Njc0Njk4MjIsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg1NTY1MywgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDcwMDd9LCB7InNyYyI6ICJ3IiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDAsICJsb24iOiAtOTcuNDM5NjAxNDUsICJ0cyI6IDE2Njc0Njk4MTcsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg0MjUyNDk2LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogNDB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDEsICJsb24iOiAtOTcuNDQ4MjEyLCAidHMiOiAxNjY3NDY5ODIyLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNS44NDY5MiwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDM0MzV9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDY1Mjk4OTI1LCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi44MiwgInNpZ25hbCI6IDMsICJ0cyI6IDE2Njc0Njk4MjIsICJyc3NpIjogLTg5LCAiZXN0QmF0dFBjdCI6IDYxLjR9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE2Njc0Njk4MTV9XX19XX0=", "messageId": "6151726618581024", "message_id": "6151726618581024", "publishTime": "2022-11-03T10:05:08.892Z", "publish_time": "2022-11-03T10:05:08.892Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
            reqs.requestBody = Blob.valueof(postData);
            RestContext.request = reqs;
            RestContext.response= res;
            return hr;
        }
    }
    static testmethod void nimbeLink_CTRL1(){
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
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
//        objs.add(apires);
        insert apires;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Apiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
//        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDA5ODcyMTcxMjQ4NjYzNzkwODMwNzkzOTM2MzM4OTYyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2NzQ2OTkwMjk0MCwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxOTcwMTBjMmZjYyJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogImMiLCAicmVxdWVzdFRzIjogMCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Ny40MjY0MjYsICJ0cyI6IDE2Njc0Njk4MjIsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg1NTY1MywgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDcwMDd9LCB7InNyYyI6ICJ3IiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDAsICJsb24iOiAtOTcuNDM5NjAxNDUsICJ0cyI6IDE2Njc0Njk4MTcsICJwZG9wIjogOTkuMCwgImxhdCI6IDI1Ljg0MjUyNDk2LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogNDB9LCB7InNyYyI6ICJjIiwgInJlcXVlc3RUcyI6IDE2Njc0Njk4MTUsICJoYWNjUmFuayI6IDEsICJsb24iOiAtOTcuNDQ4MjEyLCAidHMiOiAxNjY3NDY5ODIyLCAicGRvcCI6IDk5LjAsICJsYXQiOiAyNS44NDY5MiwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDM0MzV9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDY1Mjk4OTI1LCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi44MiwgInNpZ25hbCI6IDMsICJ0cyI6IDE2Njc0Njk4MjIsICJyc3NpIjogLTg5LCAiZXN0QmF0dFBjdCI6IDYxLjR9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE2Njc0Njk4MTV9XX19XX0=", "messageId": "6151726618581024", "message_id": "6151726618581024", "publishTime": "2022-11-03T10:05:08.892Z", "publish_time": "2022-11-03T10:05:08.892Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res; 
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutTest());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        // nimbeLink_CTRL.unableToLockRow(ast,null,null);
        
        Test.stopTest();   
    }*/
    static testmethod void nimbeLink_CTRL2(){
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        Map<String, Object> dvcmap=new Map<String, Object>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='test2';
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
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new googleApiCallout_Test.ApiMock());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        //nimbeLink_CTRL.checkDeviceStatus(dvcmap,ast);
        Test.stopTest();        
    }
    static testmethod void nimbeLink_CTRL3(){
        user usr=new user();
        usr.FirstName='sw test';
        usr.LastName='test';
        usr.Username='test@usr.com'+'.TestClass';
        usr.Email='abc@gmail.com';
        usr.Alias='abc';
        usr.TimeZoneSidKey='America/Lima';
        usr.LocaleSidKey='en_US';
        usr.EmailEncodingKey='ISO-8859-1';
        usr.ProfileId='00e0h0000012KLkAAM';
        usr.LanguageLocaleKey='en_US';
        insert usr;
        
        system.RunAs(usr)
        {
            
            map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
            list<sobject> objs=new list<sobject>();
            list<sobject> objs2=new list<sobject>();
            list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
            
            account acc=new account();
            acc.name='Testing';
            insert acc;
            
            
            // list<Asset_History_custom__c> ah=new list<Asset_History_custom__c>();
            Asset ast = new Asset();
            ast.Name='atp2bbef1c017f';
            ast.Device_Id__c='at-atp2bbef1c017f';
            ast.Current_Location__c=acc.Id;
            ast.AccountId=acc.Id;
            insert ast;
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/oldApiresponse/*';
            req.httpMethod = 'POST';
            string postdata = '{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjEwODM5OTI1ODgwMDI0NTc3ODQzOTMyNTI3NjA3MDgyMDg3NzU3MDk3NzI4NjIxOTM2NjQyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTM0NzgyNDIwMywgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0zLCAicnNycCI6IC04MSwgInBvd2VyVXB0aW1lIjogODk1MjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi42OCwgInNpZ25hbCI6IDMsICJ0cyI6IDE2MzUzNDc4MTQsICJyc3NpIjogLTU2LCAiZXN0QmF0dFBjdCI6IDk5LjV9XSwgImV2ZW50cyI6IFtdfX1dfQ==", "messageId": "3290653223767221", "message_id": "3290653223767221", "publishTime": "2021-10-27T15:17:12.476Z", "publish_time": "2021-10-27T15:17:12.476Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
            req.requestBody = Blob.valueof(postData);
            RestContext.request = req;
            RestContext.response= res;
            nimbeLink_CTRL.parseresponse();
            // nimbeLink_CTRL.captureTempResponses(objs,ast);
            //   nimbeLink_CTRL.updateTSFromDeviceStatus(objs2,ast);
            //    nimbeLink_CTRL.checkDeviceStatus(objs,ast);
            //  nimbeLink_CTRL.devicestatus(ast,objs);
            //nimbeLink_CTRL.updateTempValues(objs,ahmap,ast);
            //nimbeLink_CTRL.updatLocevalues(objs, ast,objs);
            // nimbeLink_CTRL_Mock.getasset(null);
            //nimbeLink_CTRL.upsertAsset(ast,ahlist);
            
        } 
        
    }
    static testmethod void nimbeLink_CTRL4(){
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='testing';
        insert acc;
        list<asset> ast=[SELECT Id, Name FROM Asset where name='at5-s41c39617092'];
        Api_Response__c apires=new Api_Response__c();
        
        apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
        apires.Device_Status__c='({battery=6.73, estBattPct=99.7, network=lte, powerUptime=51250, rsrp=-77, rsrq=-10, rssi=-52, signal=4, ts=1635309519})';
        apires.Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjA0MjM4OTQ2NjkxNDQyNjAxOTE0MTk0NjcyMzc3NzY5OTQwNjczOTIyMTE1OTExNTQ4OTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTUxMzUzOTE1MywgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Mi4xNTgyMDEsICJ0cyI6IDE2MzU1MTM1MjEsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQ2MTI4NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05Mi4xMTkwODEsICJ0cyI6IDE2MzU1MTM1MjcsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQwNjk0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzE2NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEuMCwgInJzcnAiOiAtNzQuMCwgInBvd2VyVXB0aW1lIjogNDkyNDAzMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4xMiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2MzU1MTM1MjcsICJyc3NpIjogLTUwLjAsICJlc3RCYXR0UGN0IjogMTYuNX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTYzNTUxMzUxOH1dfX1dfQ==", "messageId": "3302397642761908", "message_id": "3302397642761908", "publishTime": "2021-10-29T13:19:02.472Z", "publish_time": "2021-10-29T13:19:02.472Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
        apires.Last_Connected__c=system.now();
        apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
        //apires.Asset__c=ast[0].id;
        apires.Last_Connected__c=system.now();
        insert apires;
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDY5MjAxODU0ODIxMDY5NzkxNzkxNTkzODA1NTc4MjU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTIxNDA2NjU3NSwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW10sICJ0ZW1wIjogW10sICJhY2NlbCI6IFtdLCAiZGV2aWNlU3RhdHVzIjogW3sicnNycSI6IC0xMiwgInJzcnAiOiAtMTIxLCAicG93ZXJVcHRpbWUiOiAxNjMyMTU3NSwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjU4LCAic2lnbmFsIjogMCwgInRzIjogMTY2OTIxNDA0NywgInJzc2kiOiAtOTMsICJlc3RCYXR0UGN0IjogODIuM31dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTY2OTIxNDAzOH1dfX1dfQ==", "messageId": "6307974246040331", "message_id": "6307974246040331", "publishTime": "2022-11-23T14:34:31.93Z", "publish_time": "2022-11-23T14:34:31.93Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        Test.stopTest();
        
    }
    static testmethod void nimbeLink_CTRL7(){
        Map<String, Object> dvcmap=new Map<String, Object>();
        
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='test2';
        insert acc;
        Asset ast = new Asset();
        ast.Name='at-atp242e31503d0';
        ast.Device_Id__c='at-atp242e31503d0';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        insert ast;
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c=ast.Id; 
        ah.Still_in_this_Location__c=true;
        
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
        dvcmap.put(apires.Loc__c,apires);
        
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjA0MjM4OTQ2NjkxNDQyNjAxOTE0MDEwMTg4MTk2NTgzNjczNzYxNzY3MDI1Mjg1MjY3NDU4IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTM2OTkyMDEzMCwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTYzNTM2OTkwMCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Mi4xNTgyMDgsICJ0cyI6IDE2MzUzNjk5MDIsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQ2MTI0NCwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTYzNTM2OTkwMCwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05Mi4xMTkwODEsICJ0cyI6IDE2MzUzNjk5MDgsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQwNjk0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzE2NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtOS4wLCAicnNycCI6IC03NS4wLCAicG93ZXJVcHRpbWUiOiA0OTA5NjcwMCwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2LjEsICJzaWduYWwiOiA0LCAidHMiOiAxNjM1MzY5OTA4LCAicnNzaSI6IC00OS4wLCAiZXN0QmF0dFBjdCI6IDE2LjZ9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2MzUzNjUxMTd9LCB7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE2MzUzNjU3Mzd9LCB7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2MzUzNjg4MjV9LCB7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudCIsICJ0cyI6IDE2MzUzNjkwODR9XX19XX0=", "messageId": "3292586801325216", "message_id": "3292586801325216", "publishTime": "2021-10-27T21:25:24.075Z", "publish_time": "2021-10-27T21:25:24.075Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutTest());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        nimbeLink_CTRL.getasset('at-atp242e31503d0');
        //nimbeLink_CTRL.upsertAsset(ast, ahlist);
        //nimbeLink_CTRL.updateTSFromDeviceStatus(dvcmap,ast);
        
        Test.stopTest();
        
    }
    static testmethod void nimbeLink_CTRL5(){
        Map<String, Object> dvcmap=new Map<String, Object>();
        Map<id,account> accMap=new Map<id,account>();
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='test2';
        insert acc;
        accMap.put(acc.Id,acc);
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
        insert ast;
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Still_in_this_Location__c=true;
        // ah.Asset__c=ast.Id; 
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
        // ahlist.add(apires);
        insert apires;
        dvcmap.put(apires.Loc__c,apires);
        
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutTest());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        //nimbeLink_CTRL.checkDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.unableToLockRow(ast, objs2, dvcmap);
        //nimbeLink_CTRL.upsertAsset(ast,ahlist);
        //nimbeLink_CTRL.captureTempResponses(null,ast);
        //nimbeLink_CTRL.updateTSFromDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.caldistance(accMap, 45.02241276, -93.45614612);
        Test.stopTest();
        
    }
    
    static testmethod void nimbeLink_CTRL8(){
        Map<String, Object> dvcmap=new Map<String, Object>();
        Map<id,account> accMap=new Map<id,account>();
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='test2';
        insert acc;
        accMap.put(acc.Id,acc);
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
            ast.Power_Reset_Occurred__c=true;
        insert ast;
        Asset_History_custom__c ah=new Asset_History_custom__c();
       // ah.Still_in_this_Location__c=true;
        // ah.Asset__c=ast.Id; 
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
        // ahlist.add(apires);
    //            Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(apires.Loc__c);
       //     objs2.add(lst_JsonParse.values());
        insert apires;
        dvcmap.put(apires.Loc__c,apires);
        
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutTest());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        //nimbeLink_CTRL.checkDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.unableToLockRow(ast, lst_JsonParse.values(), dvcmap);
        //nimbeLink_CTRL.upsertAsset(ast,ahlist);
        //nimbeLink_CTRL.captureTempResponses(null,ast);
        //nimbeLink_CTRL.updateTSFromDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.caldistance(accMap, 45.02241276, -93.45614612);
        Test.stopTest();
        
    }
    
    static testmethod void nimbeLink_CTRL9(){
        Map<String, Object> dvcmap=new Map<String, Object>();
        Map<id,account> accMap=new Map<id,account>();
        map<decimal,Asset_History_custom__c> ahmap=new map<decimal,Asset_History_custom__c>();
        list<sobject> objs=new list<sobject>();
        list<sobject> objs2=new list<sobject>();
        list<sobject> objs3=new list<sobject>();
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        account acc=new account();
        acc.name='test2';
        acc.GeoFence_Radius_in_Miles__c=1;
        insert acc;
        
        accMap.put(acc.Id,acc);
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
            ast.Power_Reset_Occurred__c=true;
        ast.Battery_Replaced_Date__c=Date.newInstance(2022, 06, 09);
        insert ast;
        Asset_History_custom__c ah=new Asset_History_custom__c();
        // ah.Still_in_this_Location__c=true;
        // ah.Asset__c=ast.Id; 
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
        // ahlist.add(apires);
        // Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(apires.Loc__c);
        // objs2.add(lst_JsonParse.values());
        insert apires;
        dvcmap.put(apires.Loc__c,apires);
        
        objs.add(apires);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/oldApiresponse/*';
        req.httpMethod = 'POST';
        string postdata='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTg2MTUxMjkzNzM4NDM0MTEzMzkyMzk1NDkxNDk0MDMxNTIwMTg0MTEwOTUyNzQyOTQ2IiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY0MjEwODAwMjEyNiwgImRldmljZVR5cGUiOiAiYXQ1IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ1LXQxNmVlNDQ5MWY1MCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY0MjEwNzk2MCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC04OC42NDA5NzczOSwgInRzIjogMTY0MjEwNzk2MiwgInBkb3AiOiA5OS4wLCAibGF0IjogNDIuNjI3ODQyNDEsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiAxMjB9XSwgInRlbXAiOiBbXSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJyc3JxIjogLTE0LCAicnNycCI6IC0xMTMsICJwb3dlclVwdGltZSI6IDI0MzMxMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDEsICJ0cyI6IDE2NDIxMDc5NzIsICJyc3NpIjogLTgyLCAiZXN0QmF0dFBjdCI6IDg3Ljl9XSwgImJsZSI6IFt7Imxhc3RTZWVuVHMiOiAxNjQwMTI0MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhOREUyNlFPSUJRc0N6UWZ6RE13RDdnblgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTQyfSwgeyJsYXN0U2VlblRzIjogMTY0MTk0NTYwNCwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDZ1FaZkRPVUQ5QW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC01Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk2ODQ4MDQsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ3ZnZVNEYzBEOXduWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDB9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NjkyMDA1LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0M0Z2NQRGM4RGNRclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTY0fSwgeyJsYXN0U2VlblRzIjogMTYzOTY5OTIwMiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TWpFeDZRTzdCQXNDeHdmbkRORURod3JYIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC02Mn0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MDY0MDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQzNRZlZETk1ENUFuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDN9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzA2NDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NBZ2llRE5NRGZnclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU4fSwgeyJsYXN0U2VlblRzIjogMTYzOTcxMzYwNSwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDNmdlREROVUQrUW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MH0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MTM2MDYsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQ0JnaGRETlFEZlFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzIwODAwLCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0N5Z2RCRE5VRGpBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTYyfSwgeyJsYXN0U2VlblRzIjogMTYzOTcyMDgwNiwgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDdVFkVUROWUQ5d25YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC0zOX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MjgwMDUsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE5ERTI2UU9JQlFzQ1VRYzFETmNEN0FuWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNDJ9LCB7Imxhc3RTZWVuVHMiOiAxNjM5NzI4MDA2LCAiYWR2IjogIkFnRUdHdjhDQVFFQU1EQXhNakV4NlFPN0JBc0NXQWNsRE5jRGVBclgiLCAiZ2F0ZXdheUxvY2F0aW9uIjogeyJzcmMiOiAidyIsICJjYWxjIjogdHJ1ZSwgImhhY2NSYW5rIjogMCwgImxhdCI6IDQ0LjQ2MTI4ODc3LCAidHRmIjogMCwgImFsdCI6IDc3Ny4wLCAicGRvcCI6IDk5LjAsICJsb24iOiAtOTIuMTU4MjY5NDYsICJ0cyI6IDI5MTA5NzYwODUsICJoYWNjIjogMTIwfSwgImxhc3RSc3NpIjogLTU5fSwgeyJsYXN0U2VlblRzIjogMTYzOTczNTIwMywgImFkdiI6ICJBZ0VHR3Y4Q0FRRUFNREF4TkRFMjZRT0lCUXNDMGdaT0ROa0QyQW5YIiwgImdhdGV3YXlMb2NhdGlvbiI6IHsic3JjIjogInciLCAiY2FsYyI6IHRydWUsICJoYWNjUmFuayI6IDAsICJsYXQiOiA0NC40NjEyODg3NywgInR0ZiI6IDAsICJhbHQiOiA3NzcuMCwgInBkb3AiOiA5OS4wLCAibG9uIjogLTkyLjE1ODI2OTQ2LCAidHMiOiAyOTEwOTc2MDg1LCAiaGFjYyI6IDEyMH0sICJsYXN0UnNzaSI6IC00MX0sIHsibGFzdFNlZW5UcyI6IDE2Mzk3MzUyMDMsICJhZHYiOiAiQWdFR0d2OENBUUVBTURBeE1qRXg2UU83QkFzQzFRWkVETmdEYkFyWCIsICJnYXRld2F5TG9jYXRpb24iOiB7InNyYyI6ICJ3IiwgImNhbGMiOiB0cnVlLCAiaGFjY1JhbmsiOiAwLCAibGF0IjogNDQuNDYxMjg4NzcsICJ0dGYiOiAwLCAiYWx0IjogNzc3LjAsICJwZG9wIjogOTkuMCwgImxvbiI6IC05Mi4xNTgyNjk0NiwgInRzIjogMjkxMDk3NjA4NSwgImhhY2MiOiAxMjB9LCAibGFzdFJzc2kiOiAtNjV9XSwgImV2ZW50cyI6IFt7ImV2ZW50TmFtZSI6ICJtb3ZlbWVudEVuZCIsICJ0cyI6IDE2NDIxMDc5NjB9XX19XX0=", "messageId": "3650492742462412", "message_id": "3650492742462412", "publishTime": "2022-01-13T21:06:47.755Z", "publish_time": "2022-01-13T21:06:47.755Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response= res;
        List<Nested_Geofence__mdt> nestedGeofences=new List<Nested_Geofence__mdt>();
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutTest());
        Test.startTest();
        nimbeLink_CTRL.parseresponse();
        //nimbeLink_CTRL.checkDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.unableToLockRow(ast, lst_JsonParse.values(), dvcmap);
        //nimbeLink_CTRL.upsertAsset(ast,ahlist);
        //nimbeLink_CTRL.captureTempResponses(null,ast);
        //nimbeLink_CTRL.updateTSFromDeviceStatus(dvcmap,ast);
        //nimbeLink_CTRL.caldistance(accMap, 45.02241276, -93.45614612);
        //nimbeLink_CTRL.currentLocName(accMap, 45.02241276, -93.45614612,nestedGeofences);
        Test.stopTest();
    }
    
    static testmethod void unableToLockRow_Test(){
        account acc=new account();
        acc.name='test2';
        insert acc;
      
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
        ast.Power_Reset_Occurred__c=true;
        insert ast;
          list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();        

         Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=date.parse('01/11/2022');
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lrlist.add(lr);
        insert lrlist;
        
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c=ast.Id; 
        insert ah;
        
        string data='eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDgxMjQ5NjkxNTkxODU4NjU1NDc2NjU5NTc0MDEzOTcwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTYyMTE5MTIyMSwgImRldmljZVR5cGUiOiAiYXQ2IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ2LXMyMDM1ODhmNDVkYyJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTYyMDkwOSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05My40NTU1MDEyMywgInRzIjogMTY2OTYyMDkxMSwgInBkb3AiOiA5OS4wLCAibGF0IjogNDUuMDIyMjQwNTYsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTYyMDkwOSwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05My40NTk3NSwgInRzIjogMTY2OTYyMDkxNSwgInBkb3AiOiA5OS4wLCAibGF0IjogNDUuMDI0MDI3LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMTYxMn1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTIsICJyc3JwIjogLTk2LCAicG93ZXJVcHRpbWUiOiAxMTM2OTE1MCwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2Ljc1LCAic2lnbmFsIjogMiwgInRzIjogMTY2OTYyMTE4NiwgInJzc2kiOiAtNjgsICJlc3RCYXR0UGN0IjogODguNn1dLCAiZXZlbnRzIjogW119fV19';
        Map<String, Object> lst_JsonParse1 = (Map<String, Object>)Json.deserializeUntyped(EncodingUtil.base64Decode(data).toString());    
        Map<String,Object> commap = new Map<String, Object>();
        for(object obj : (list<Object>) lst_JsonParse1.get('records')){
            commap.putAll((Map<String, Object>)obj);   
        }    
        
        Map<String, Object> datamap = new  Map<String, Object>();
        if(commap.containskey('data')){
            datamap = (Map<String, Object>)commap.get('data');    
        }  
        
        list<Object> loclist = new list<Object>();
        if(datamap.containskey('loc')){
            loclist = (list<Object>)datamap.get('loc');
        }
        
        list<Object> dvcstatus = new list<Object>();
        if(datamap.containskey('deviceStatus')){
            dvcstatus = (list<Object>)datamap.get('deviceStatus');
        }
                list<asset> assetlist = [select Id from asset limit 1];
        string assetlist2;
        for(asset ast1:assetlist){
            assetlist2 = ast1.id;
        }

        //Map<String, Object> dvcmap = nimbeLink_CTRL.convertListOfObjectToMap(dvcStatus);
        //nimbeLink_CTRL.unableToLockRow(assetlist2, loclist, dvcmap);
        
      //  list<location_record_ignored__c> lriList = [select Id from location_record_ignored__c];
        system.assertEquals(1, lrlist.size());
        
        list<Object> templist = new list<Object>();
        if(datamap.containskey('temp')){
            templist = (list<Object>)datamap.get('temp');
        }
        //nimbeLink_CTRL.captureTempResponses(templist,ast);
    }
    
    /*static testmethod void devicestatus(){
        account acc=new account();
        acc.name='test2';
        insert acc;
      
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
        ast.Power_Reset_Occurred__c=true;
        insert ast;
                list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();        

         Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=date.parse('01/11/2022');
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lrlist.add(lr);
        insert lrlist;
       
        Asset_History_custom__c ah=new Asset_History_custom__c();
        ah.Asset__c=ast.Id; 
        insert ah;
        
        //string data='eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAxOjQ5NjI0NTg2MTUxMjcxNDM3Njg4OTE3MDgxMjQ5NjkxNTkxODU4NjU1NDc2NjU5NTc0MDEzOTcwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY2OTYyMTE5MTIyMSwgImRldmljZVR5cGUiOiAiYXQ2IiwgIm9yZyI6ICJ4NzZxczMiLCAiaWQiOiAiYXQ2LXMyMDM1ODhmNDVkYyJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY2OTYyMDkwOSwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05My40NTU1MDEyMywgInRzIjogMTY2OTYyMDkxMSwgInBkb3AiOiA5OS4wLCAibGF0IjogNDUuMDIyMjQwNTYsICJhbHQiOiA3NzcuMCwgImNhbGMiOiB0cnVlLCAidHRmIjogMCwgImhhY2MiOiA0MH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTY2OTYyMDkwOSwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05My40NTk3NSwgInRzIjogMTY2OTYyMDkxNSwgInBkb3AiOiA5OS4wLCAibGF0IjogNDUuMDI0MDI3LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMTYxMn1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTIsICJyc3JwIjogLTk2LCAicG93ZXJVcHRpbWUiOiAxMTM2OTE1MCwgIm5ldHdvcmsiOiAibHRlIiwgImJhdHRlcnkiOiA2Ljc1LCAic2lnbmFsIjogMiwgInRzIjogMTY2OTYyMTE4NiwgInJzc2kiOiAtNjgsICJlc3RCYXR0UGN0IjogODguNn1dLCAiZXZlbnRzIjogW119fV19';
        string data='eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAicXczbWo4IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAyOjQ5NjI0NTIzNzkxOTg3NTQ4NzI1NDA0MTY2MDg2NDQ3NjkxMzE0OTA5Njg3NTk5MDU4NjQ5MTIyIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTY3MDgxMTI3ODExNSwgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHQxODc5MDAxMWJjMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTY3MDgxMDcwMCwgImhhY2NSYW5rIjogMCwgImxvbiI6IDQ5Ljk4NDc5NCwgInRzIjogMTY3MDgxMDcwMiwgInBkb3AiOiA5OS4wLCAibGF0IjogMjYuMjUyOTE0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogNDB9XSwgInRlbXAiOiBbeyJsdmwiOiAzLCAiYyI6IDIwLjE3OSwgInJoIjogNDYuMDYsICJ0cyI6IDE2NzA4MTA3MDAsICJ0YyI6IDB9XSwgImFjY2VsIjogW10sICJkZXZpY2VTdGF0dXMiOiBbeyJwb3dlclVwdGltZSI6IDI0Nzg3MjUwLCAibmV0d29yayI6ICIyZyIsICJiYXR0ZXJ5IjogNi4yNiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2NzA4MTEwNTgsICJyc3NpIjogLTU5LjAsICJlc3RCYXR0UGN0IjogNjYuNX1dLCAiZXZlbnRzIjogW119fV19';
        Map<String, Object> lst_JsonParse1 = (Map<String, Object>)Json.deserializeUntyped(EncodingUtil.base64Decode(data).toString());    
        Map<String,Object> commap = new Map<String, Object>();
        for(object obj : (list<Object>) lst_JsonParse1.get('records')){
            commap.putAll((Map<String, Object>)obj);   
        }    
        
        Map<String, Object> datamap = new  Map<String, Object>();
        if(commap.containskey('data')){
            datamap = (Map<String, Object>)commap.get('data');    
        }  
        
        list<Object> loclist = new list<Object>();
        if(datamap.containskey('loc')){
            loclist = (list<Object>)datamap.get('loc');
        }
        
        list<Object> dvcstatus = new list<Object>();
        if(datamap.containskey('deviceStatus')){
            dvcstatus = (list<Object>)datamap.get('deviceStatus');
        }
        
        //Map<String, Object> dvcmap = nimbeLink_CTRL.convertListOfObjectToMap(dvcStatus);
       // nimbeLink_CTRL.unableToLockRow(ast, loclist, dvcmap);
        
        //list<location_record_ignored__c> lriList = [select Id from location_record_ignored__c];
        
        system.assertEquals(1, lrlist.size());
        
        list<Object> templist = new list<Object>();
        if(datamap.containskey('temp')){
            templist = (list<Object>)datamap.get('temp');
        }
        //nimbeLink_CTRL.captureTempResponses(templist,ast);
                list<Object> dvclist = new list<Object>();
        if(datamap.containskey('temp')){
            dvclist = (list<Object>)datamap.get('deviceStatus');
        }
        //nimbeLink_CTRL.checkDeviceStatus(dvcstatus,ast);
    }*/
}