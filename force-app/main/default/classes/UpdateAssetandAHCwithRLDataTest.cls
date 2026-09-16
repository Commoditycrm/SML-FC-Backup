@isTest
public class UpdateAssetandAHCwithRLDataTest {
    
     @isTest
    public static void testUpdateAssetandAHCwithRLData() {
          Account acc = new Account();
        acc.Name = 'Testing';
        acc.Check_Railway_Geofence__c = true ;
        acc.ShippingCity = 'testCity';
        acc.ShippingCountry='testCountry';
        acc.ShippingPostalCode='12345';
        insert acc;
        Asset ast1 = new Asset();
        ast1.Name = 'atp2bbef1c018f'; 
        ast1.Device_Id__c = 'atp2bbef1c018f';
        ast1.AccountId = acc.Id;
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
        
         Asset_History_custom__c ahc = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-1),
            End_Time__C = Datetime.now().addHours(1),
            Asset__c = ast1.Id,
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
            Altitude__c=null ,
            PowerUptime__c=null ,
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc;
          Test.setMock(HttpCalloutMock.class, new EAcalloutMockClass());

        Test.startTest();
        UpdateAssetandAHCwithRLData obj = new UpdateAssetandAHCwithRLData();
        Database.executeBatch(obj);
        Test.stopTest();
    }

}