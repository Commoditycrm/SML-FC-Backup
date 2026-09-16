@isTest
public class AHCAddressCleanerBatch_Test {
@isTest
    public static void testAHCAddressCleanerBatch() {
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
     //   ast.tot = System.now().addhours(-1);
        ast1.Temporary_Latitude__c= null;
        ast1.State_of_Pallet__c = 'In Transit';
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
     //   ast.tot = System.now().addhours(-1);
        ast.Temporary_Latitude__c= null;
        ast.State_of_Pallet__c = 'In Transit';
        insert ast;
        
        RecordType locationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.now().addhours(-1);
        apc.Asset__c = ast.Id;
        apc.Status__c = 'New';
        apc.Latitude__c = '41.59104532';
        apc.Longitude__c = '-83.55054479';
        apc.Current_Location_Address__c = '401 John Quincy Adams St, Sauk City, WI, 53583, USA';
        apc.CurrentLocationId__c = acc.Id;
        apc.Location__c = acc.Name;
        apc.PowerUptime__c = 12345;
        apc.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc.RecordTypeId = locationRecordType.Id;
        insert apc;
        API_Response_Childs__c apc5 = new API_Response_Childs__c();
        apc5.Timestamp__c =5658878;
        apc5.Timestamp_DateTime__c = System.now();
        apc5.Asset__c = ast.Id;
        apc5.Status__c = 'New';
        apc5.Latitude__c = '41.59104532';
        apc5.Longitude__c = '-83.55054479';
        apc5.Current_Location_Address__c = '3770 Nashua Dr, Mississauga, ON, L4V 1M5, Canada';
        apc5.PowerUptime__c = 12345;
        apc5.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc5.RecordTypeId = locationRecordType.Id;
        insert apc5;
        
        API_Response_Childs__c apc1 = new API_Response_Childs__c();
        apc1.Timestamp__c =5658878;
        apc1.Timestamp_DateTime__c = System.now().addhours(-2);
        apc1.Asset__c = ast.Id;
        apc1.Status__c = 'New';
        apc1.Latitude__c = '41.59104532';
        apc1.Longitude__c = '-83.55054479';
        apc1.Current_Location_Address__c = 'Nuevo Progreso, Tamps., 88123, MX';
        apc1.ARC_External_Id__c = apc.Timestamp_Datetime__c + integer.valueof(Math.random() * 999)+'~Loc';
        apc1.PowerUptime__c = 12345;
        apc1.RecordTypeId = locationRecordType.Id;
        insert apc1;
        
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
        apc2.PowerUptime__c = 12345;
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
        apc3.PowerUptime__c = 12345;
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
        
        RecordType ahcLocationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];  
        Asset_History_custom__c ahc = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-1),
            End_Time__C = Datetime.now().addHours(1),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = 'test,',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -83.55054479 ,
            Latitude__c= 41.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc;
        
        Asset_History_custom__c ahc1 = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-4),
            End_Time__C = Datetime.now().addHours(-1),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = false,
            Current_Location_Address__c = ',,test',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -83.55054479 ,
            Latitude__c= 41.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc1;
        
        Asset_History_custom__c ahc2 = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-5),
            End_Time__C = Datetime.now().addHours(-4),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = ',',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -84.55054479 ,
            Latitude__c= 42.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc2;
        Test.startTest();
        	string objname = 'API_Response_Childs__c';
        	string query = 'select id,current_location_address__c from API_Response_Childs__c limit 100';
            AHCAddressCleanerBatch obj = new AHCAddressCleanerBatch(query,objname);
            Database.executeBatch(obj);
        UpdateGoogleAPIData batch = New UpdateGoogleAPIData(query);
         Database.executeBatch(batch);
        Test.stopTest();
    }
}