@isTest
public class ProdToUATNimblelinkTest {
	
    @isTest
    public static void scheduleTest() {
		String cronExpr = '0 10 * * * ?';
        Test.startTest();
		ScheduleProdToUAT sched = new ScheduleProdToUAT();
		system.schedule('Test', cronExpr, sched);
        Test.Stoptest();
    }
    
    @isTest
    public static void ProdToUAT() {
        insert new Nimbelink_Sync_Prod_Full_Copy__c(Name='Test', Last_Timestamp__c=Datetime.now().addMinutes(-10));
        Api_Response__c apires=new Api_Response__c();
        apires.Loc__c='({alt=777.0, calc=true, hacc=120, haccRank=0, lat=44.46124304, lon=-92.15820692, pdop=99.0, requestTs=1635309269, src=w, ts=1104309271, ...}';
        apires.Device_Status__c='({battery=6.73, estBattPct=99.7, network=lte, powerUptime=51250, rsrp=-77, rsrq=-10, rssi=-52, signal=4, ts=1635309519})';
        apires.Incoming_Messsage__c='{"message": {"data": "eyJyZWNvcmRzIjogW3siYmFzZSI6IHsiZGl2aXNpb24iOiAiYXozZ3A3IiwgIm1zZ0lkIjogInNoYXJkSWQtMDAwMDAwMDAwMDAwOjQ5NjA0MjM4OTQ2NjkxNDQyNjAxOTE0MTk0NjcyMzc3NzY5OTQwNjczOTIyMTE1OTExNTQ4OTMwIiwgInNjaGVtYVZlciI6ICIwLjYiLCAidHNzIjogMTYzNTUxMzUzOTE1MywgImRldmljZVR5cGUiOiAiYXQiLCAib3JnIjogIng3NnFzMyIsICJpZCI6ICJhdC1hdHAyNDJlMzE1MDNkMCJ9LCAiZGF0YSI6IHsiaW5mbyI6IFtdLCAibG9jIjogW3sic3JjIjogInciLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMCwgImxvbiI6IC05Mi4xNTgyMDEsICJ0cyI6IDE2MzU1MTM1MjEsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQ2MTI4NSwgImFsdCI6IDc3Ny4wLCAiY2FsYyI6IHRydWUsICJ0dGYiOiAwLCAiaGFjYyI6IDEyMH0sIHsic3JjIjogImMiLCAicmVxdWVzdFRzIjogMTYzNTUxMzUxOCwgImhhY2NSYW5rIjogMSwgImxvbiI6IC05Mi4xMTkwODEsICJ0cyI6IDE2MzU1MTM1MjcsICJwZG9wIjogOTkuMCwgImxhdCI6IDQ0LjQwNjk0LCAiYWx0IjogNzc3LjAsICJjYWxjIjogdHJ1ZSwgInR0ZiI6IDAsICJoYWNjIjogMzE2NX1dLCAidGVtcCI6IFtdLCAiYWNjZWwiOiBbXSwgImRldmljZVN0YXR1cyI6IFt7InJzcnEiOiAtMTEuMCwgInJzcnAiOiAtNzQuMCwgInBvd2VyVXB0aW1lIjogNDkyNDAzMjUsICJuZXR3b3JrIjogImx0ZSIsICJiYXR0ZXJ5IjogNi4xMiwgInNpZ25hbCI6IDQsICJ0cyI6IDE2MzU1MTM1MjcsICJyc3NpIjogLTUwLjAsICJlc3RCYXR0UGN0IjogMTYuNX1dLCAiZXZlbnRzIjogW3siZXZlbnROYW1lIjogIm1vdmVtZW50IiwgInRzIjogMTYzNTUxMzUxOH1dfX1dfQ==", "messageId": "3302397642761908", "message_id": "3302397642761908", "publishTime": "2021-10-29T13:19:02.472Z", "publish_time": "2021-10-29T13:19:02.472Z"}, "subscription": "projects/nl-at-x76qs3-prod/topics/org-x76qs3-az3gp7"}';
        apires.Temp__c='({c=18.427, lvl=1, rh=57.172, tc=0, ts=1635314398})';
        apires.Last_Connected__c=system.now();
        apires.Base__c='{deviceType=at5, division=az3gp7, id=at5-t16ee4491f50, msgId=shardId-000000000000:49610839925880024577843927336020220851083428547486810114, org=x76qs3, schemaVer=0.6, tss=1635309528142}';
        apires.Last_Connected__c=system.now();
        insert apires;
        insert new Google_API_Data__c(Current_City__c='Test City',Current_State__c='Test State',Current_Address__c='Test ADDRESS',Current_Street_Address__c='Test City',Current_Zip_Code__c='1234',Latitude__c='36.8278575',Longitude__c='-94.62209');
        //SELECT Id, Name, Last_Timestamp__c FROM Nimbelink_Sync_Prod_Full_Copy__c
        Test.setMock(HttpCalloutMock.class, new NimbeliinkPRodToUATCallout.ApiMock());
        Test.startTest();
        System.enqueueJob(new ProdToUATNimblelink());
        Test.stopTest();
    }
}