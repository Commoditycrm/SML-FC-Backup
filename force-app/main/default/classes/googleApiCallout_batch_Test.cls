@isTest
public class googleApiCallout_batch_Test {

   @IsTest
    static void testGoogleApiCalloutBatch() {
         Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'test1';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;  
        insert ast;
        
        // Create mock data
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Latitude__c = 37.422476,
            Longitude__c = -122.084249,
            asset__c= ast.id,
            Current_Location_Address__c = 'Address Pending'
        );
        insert ahc;
		 
        API_Response_Childs__c apc = new API_Response_Childs__c();
        apc.Timestamp__c =5658878;
        apc.Timestamp_DateTime__c = System.today();
        apc.Location__c='In Transit';
        apc.Latitude__c='33.277843';
        apc.HaccRank__c=0;
        apc.Latitude__c='75.341243';
        apc.Current_Location_Address__c='Address Pending';
        apc.Status__c ='Google Api Error';
        apc.ARC_External_Id__c = 'Testgoogleapi';
        insert apc;
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Instantiate and execute the batch
        //string query1 = 'select Id, OwnerId,asset__r.name, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, API_Response_ID__c, Accuracy_meters__c, Alt__c, Api_Response__c, Asset_History__c, Asset__c, Battery__c, CurrentLocationId__c, Current_Location_Address__c, EstBattPct__c, Event_Name__c, Facility_Location__c, HaccRank__c, Latitude__c, Location__c, Longitude__c, Message_Type__c, Network__c, PowerUptime__c, Relative_Humidity__c, Signal__c, Status__c, Temperature__c, Timestamp_DateTime__c, Timestamp_Date_Time_Device_Status__c, Timestamp_Device_Status__c, Timestamp__c, rsrp__c, rsrq__c, rssi__c, ARC_External_Id__c, changedForGrouping__c, old_Account_id__c, Device_Ts__c, Business_Name__c, Business_Location__Latitude__s, Business_Location__Longitude__s, Business_Location__c, Business_Place_Id__c  from API_Response_Childs__c where Current_Location_Address__c =\'Address Not in Google API Data\'';

        String query = 'SELECT Id, Latitude__c, Longitude__c, Current_Location_Address__c FROM Asset_History_Custom__c WHERE Current_Location_Address__c = \'Address Pending\'';
        GoogleApiCallout_Batch batch = new GoogleApiCallout_Batch(query);
        Test.startTest();
        Database.executeBatch(batch, 1);
        
        Test.stopTest();
    }
      @IsTest
    static void testGoogleAPIcalloutForARCBatch() {
         Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'test1';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;  
        insert ast;
        
         List<API_Response_Childs__c> testRecords = new List<API_Response_Childs__c>();
        for (Integer i = 0; i < 5; i++) {
            testRecords.add(new API_Response_Childs__c(
                Latitude__c = '37.7749', // Add slight variation for testing
                Longitude__c = '-122.4194' ,
                HaccRank__c=0,
        		Current_Location_Address__c='Address Pending',
        	Status__c ='Google Api Error',
        	ARC_External_Id__c = 'Testgoogleapi'+i,
                asset__C = ast.id
            ));
        }
        insert testRecords;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		GoogleAPIcalloutForARC_Batch batch = new GoogleAPIcalloutForARC_Batch();
        Test.startTest();
        Database.executeBatch(batch, 5);
        Test.stopTest();

    }
}