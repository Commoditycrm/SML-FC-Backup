@istest
public class currentaddressasthis_batch_Test {
   public static String Location='Location';
    public static string hisid = 'hisid';
    @testSetup
    static void setup1() {
        
        
        Account Acc = new Account();
        Acc.Name ='Cardinal Glass';
        Acc.phone='9600205548';
        insert Acc;
        
        Asset asst=new Asset(Name='Test');
        asst.AccountId=Acc.Id;
        asst.Last_Connected__c=system.now();
        asst.State_of_Pallet__c='In transit';
        asst.Device_Id__c='1234567';
        asst.Field2__c='123465';
        insert asst; 
        
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c=asst.id;
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In transit';
        assetHsitory.Latitude__c=44.39546900;
        assetHsitory.Longitude__c=44.39546900;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Battery_Current__c=0.2165489653;
        assetHsitory.Current_Location_Address__c =null;
        assetHsitory.Still_in_this_Location__c=true;
        assetHsitory.Last_Connected_Time__c =system.now();
        insert assetHsitory;
        
    }
    
        static testmethod void Contractsashis_BatchTest(){
        DateTime lastfiveminutes=Datetime.now().addMinutes(-5);
        String Query = 'select Asset__c,Asset__r.Device_Id__c,Start_Time__c,LastModifiedDate,End_Time__c,Location__c,Latitude__c,Longitude__c,Last_Connected_Time__c,Current_Location_Address__c from Asset_History_custom__c where Latitude__c != null AND Longitude__c != null ';
        Query += 'AND LastModifiedDate >=: lastfiveminutes limit 200';
        List<Asset_History_custom__c> assethisrecords=Database.Query(Query);    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        currentaddressasthis_Batch  updatebatches = new currentaddressasthis_Batch();
        DataBase.executeBatch(updatebatches);
        //system.assertEquals(0, historyRecords.size());
        test.stopTest();
    }
}