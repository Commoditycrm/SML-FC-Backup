@istest
public class testRedesignNL_Patchclass {
  @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Testing1';
        insert acc1;
        
        Asset ast1 = new Asset();
        ast1.Name = 'atp2bbef1c018f'; 
        ast1.Device_Id__c = 'at5-t16ee4491f60';
        ast1.AccountId = acc.Id;
        ast1.Account_to_Update__c = acc1.Id;
        ast1.Last_Known_Location__c = acc.Id;
        ast1.Date_Shipped__c = system.now();
        ast1.Current_Location__c = acc.Id;
        ast1.Current_Address__c = 'test';
        ast1.Capture_Movement_Event__c = true;
        ast1.Accuracy_meters__c =null ;
        ast1.Temporary_Longitude__c= null;
        ast1.Power_Reset_Time__c = system.now();
        //   ast.tot = System.now().addhours(-1);
        ast1.Temporary_Latitude__c= null;
        ast1.State_of_Pallet__c = 'In Transit';
        ast1.PowerUp_Time__c = 12345;
        insert ast1;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Account_to_Update__c = acc1.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Date_Shipped__c = system.now();
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Accuracy_meters__c =null ;
        ast.Temporary_Longitude__c= null;
        ast.PowerUp_Time__c = 12345;
        //   ast.tot = System.now().addhours(-1);
        ast.Temporary_Latitude__c= null;
        ast.State_of_Pallet__c = 'In Transit';
        insert ast;
        
        Asset ast9 = new Asset();
        ast9.Name = 'atp2bb7f'; 
        ast9.Device_Id__c = 'at5-91f50';
        ast9.AccountId = acc.Id;
        ast9.Account_to_Update__c = acc1.Id;
        ast9.Last_Known_Location__c = acc.Id;
        ast9.Date_Shipped__c = system.now();
        ast9.Current_Location__c = acc.Id;
        ast9.Current_Address__c = 'test';
        ast9.Capture_Movement_Event__c = true;
        ast9.Accuracy_meters__c =null ;
      	ast9.Battery_Replaced_Date__c = date.today();
        ast9.Temporary_Longitude__c= null;
        //   ast.tot = System.now().addhours(-1);
        ast9.Temporary_Latitude__c= null;
        ast9.State_of_Pallet__c = 'In Transit';
        ast9.PowerUp_Time__c = 12345;
        insert ast9;
        
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
      
      API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = 'test';
        apc.CurrentLocationId__c = acc.Id;
        apc.Location__c = acc.Name;
        //apc.PowerUptime__c = 12345;
        apc.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc.RecordTypeId = locationRecordType.Id;
        insert apc;
        
        API_Response_Childs__c apc2 = new API_Response_Childs__c();
        apc2.Timestamp__c =5658878;
        apc2.Timestamp_DateTime__c = System.now().addhours(-3);
        apc2.Timestamp_Device_Status__c =5658878;
        apc2.Timestamp_Date_Time_Device_Status__c = System.now().addhours(-3);
        apc2.Asset__c = ast.Id;
        apc2.Status__c = 'New';
        apc2.Latitude__c = '42.59104532';
        apc2.Longitude__c = '-83.55054479';
        apc2.Current_Location_Address__c = 'test2';
        apc2.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        //apc2.PowerUptime__c = 12345;
        apc2.RecordTypeId = locationRecordType.Id;
        insert apc2;
        API_Response_Childs__c apc3 = new API_Response_Childs__c();
        apc3.Timestamp__c =5658878;
        apc3.Timestamp_DateTime__c = System.now().addhours(+2);
        apc3.Timestamp_Device_Status__c =11042344;
        apc3.Timestamp_Date_Time_Device_Status__c = System.now().addhours(+2);
        apc3.Asset__c = ast.Id;
        apc3.Status__c = 'New';
        apc3.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        //apc3.PowerUptime__c = 12345;
        apc3.rsrp__c=123;
        apc3.rsrq__c=123;
        apc3.rssi__c=123;
        apc3.EstBattPct__c= 0;
        apc3.RecordTypeId = locationRecordType.Id;
        insert apc3;
        
        API_Response__c objAPIResponse = new API_Response__c();
        objAPIResponse.Incoming_Messsage__c ='test';
        objAPIResponse.Asset__c = ast.Id;
        objAPIResponse.Status__c='NEW';
        insert objAPIResponse;
        
        API_Response__c objAPIResponse9 = new API_Response__c();
        objAPIResponse9.Incoming_Messsage__c ='test';
        objAPIResponse9.Asset__c = ast9.Id;
        objAPIResponse9.Status__c='NEW';
        insert objAPIResponse9;
        
        RecordType ahcLocationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];  
        Asset_History_custom__c ahc = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-1),
            End_Time__C = Datetime.now().addHours(1),
            Asset__c = ast9.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = 'test',
            currentLocationId__c =acc1.id,
            location__c = acc1.Name,
            Accuracy_meters__c =12345 ,
            Longitude__c = -83.55054479 ,
            Latitude__c= 41.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            estBattPct__c = 34.5,
            Cellular_Signal__c= null,
            Battery_Current__c=null ,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=99,
            Power_Reset_Occurred__c = true
        );
        insert ahc;
        
        Asset_History_custom__c ahc1 = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-4),
            End_Time__C = Datetime.now().addHours(-1),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = false,
            Current_Location_Address__c = 'test',
            currentLocationId__c =acc.id,
            location__c = acc.Name,
            Accuracy_meters__c =12345 ,
            Longitude__c = -83.55054479 ,
            Latitude__c= 41.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Battery_Current__c=null ,
            Altitude__c=null ,
            PowerUptime__c=null ,
            estBattPct__c = 343.5,
            Est_Remaining_Battery__c=72,
            Power_Reset_Occurred__c = false
        );
        insert ahc1;
        
        Asset_History_custom__c ahc2 = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-5),
            End_Time__C = Datetime.now().addHours(-4),
            Asset__c = ast1.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = 'test2',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -84.55054479 ,
            Latitude__c= 42.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            estBattPct__c= 23,
            Cellular_Signal__c= null,
            Battery_Current__c=null ,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=58,
            Power_Reset_Occurred__c = true
        );
        insert ahc2;
      
       API_Response_Childs__c apc1 = new API_Response_Childs__c();
        apc1.Timestamp__c =5658878;
        apc1.Timestamp_DateTime__c = System.now().addhours(-2);
        apc1.Asset__c = ast.Id;
        apc1.Status__c = 'New';
        apc1.Latitude__c = '41.59104532';
        apc1.Longitude__c = '-83.55054479';
        apc1.Current_Location_Address__c = 'test1';
        apc1.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        //apc1.PowerUptime__c = 12345;
        apc1.Asset_History__c = ahc.Id;
        apc1.RecordTypeId = locationRecordType.Id;
        insert apc1;
      
        API_Response_Childs__c apc9 = new API_Response_Childs__c();
        apc9.Timestamp__c =5658878;
        apc9.Timestamp_DateTime__c = System.now().addhours(-1);
        apc9.Timestamp_Device_Status__c =5658878;
        apc9.Timestamp_Date_Time_Device_Status__c = System.now().addhours(-1);
        apc9.Asset__c = ast9.Id;
        apc9.Status__c = 'New';
        //apc9.PowerUptime__c = 12345;
        apc9.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc9.RecordTypeId = locationRecordType.Id;
        apc9.Asset_History__c = ahc1.Id;
        insert apc9;
        
        API_Response_Childs__c apc5 = new API_Response_Childs__c();
        apc5.Timestamp__c =5658878;
        apc5.Timestamp_DateTime__c = System.now();
        apc5.Asset__c = ast.Id;
        apc5.Status__c = 'New';
        apc5.Latitude__c = '41.59104532';
        apc5.Longitude__c = '-83.55054479';
        apc5.Current_Location_Address__c = 'test';
        //apc5.PowerUptime__c = 12345;
        apc5.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc5.RecordTypeId = locationRecordType.Id;
        apc5.Asset_History__c = ahc2.Id;
        insert apc5;
        
        AssetHistory  objHistory = new AssetHistory();
        objHistory.AssetId =ast.Id;
        objHistory.Field = 'Last_Connected__c'; 
        insert objHistory;     
    } 

    @isTest
    public static void testRedesignNL_CreateAssetHistoryBatch() {
        
        /*String query1 = 'select id, PowerUpTime__c, asset__r.PowerUp_Time__c from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and asset__r.PowerUp_Time__c != null';
        //For ARC   
        String query2 = 'select PowerUptime__c, Timestamp_Date_Time_Device_Status__c, CreatedDate, Asset__r.name, Asset__r.PowerUp_Time__c, Timestamp_DateTime__c, Location__c, EstBattPct__c from API_Response_Childs__c where Asset_History__c in (select id from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and Est_Remaining_Battery__c != null) and asset__r.PowerUp_Time__c != null';
        */
        Test.startTest();
        Database.ExecuteBatch(new RedesignNL_patchclass(false),1000);
        Database.ExecuteBatch(new RedesignNL_patchclass(true),1000);
        Test.stopTest();
        
    }    
}