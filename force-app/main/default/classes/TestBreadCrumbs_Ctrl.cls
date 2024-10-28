@istest
public class TestBreadCrumbs_Ctrl {
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
        RecordType ahcLocationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];  
        Asset_History_custom__c ahc = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-1),
            End_Time__C = Datetime.now().addHours(1),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = 'test',
            location__c = 'In Transit',
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
            Current_Location_Address__c = 'test',
            location__c = 'In Transit',
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
            Current_Location_Address__c = 'test2',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -84.55054479 ,
            Latitude__c= 42.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Battery_Current__c=null ,
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc2;
        
    }
    @isTest
    public static void testBreadCrumbs() {
        Id recordid;
        Asset ast = [SELECT Id, Name FROM Asset LIMIT 1];
        recordid = ast.Id;
        
        Test.startTest();
        
        Date startDateTime = Date.valueof(DateTime.now().addMonths(-1));
        Date endDateTime = Date.valueof(DateTime.now());
        
        List<Asset_History_custom__c> ahcList = BreadCrumbs_Ctrl.asthis(startDateTime, endDateTime, recordid);
        Test.stopTest();
       // System.assertNotEquals(null, ahcList, 'List should not be null');
       // System.assertEquals(ahcList.size(), ahcList.size(), 'List should contain one record');            
    }    
}