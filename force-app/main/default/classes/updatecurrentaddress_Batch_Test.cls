@IsTest
public class updatecurrentaddress_Batch_Test {
    public static String Location='Location';
    public static String Message='Message_Type';
    @testSetup
    static void setup() {
        Message_Type__c msgtype=new Message_Type__c();
        msgtype.Battery_Current_Use__c=0.5369;
        msgtype.Description__c='HeartBeat';
        msgtype.Name='2';
        insert msgtype;
        
        Account Acc = new Account();
        Acc.Name ='Cardinal Glass';
        Acc.phone='9600205548';
        insert Acc;
        
        Asset asst=new Asset(Name='Test');
        asst.AccountId=Acc.Id;
        asst.Current_Location__c=Acc.Id;
        asst.Message_Types__c=msgtype.Id;
        asst.Last_Connected__c=system.now();
        asst.State_of_Pallet__c='In Network';
        asst.Temporary_Latitude__c=40.1823;
        asst.Temporary_Longitude__c=-90.058477;
        asst.Device_Id__c='1234567';
        //asst1.Current_Location__c=Acc1.id;
        asst.Field2__c='123465';
        insert asst; 
        
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c=asst.id;
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asst.Temporary_Latitude__c;
        assetHsitory.Longitude__c=asst.Temporary_Longitude__c;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Battery_Current__c=0.2165489653;
        assetHsitory.Location__c='In Transit';
        assetHsitory.Still_in_this_Location__c=true;
        insert assetHsitory;
    }
    static testmethod void Contract_BatchTest(){
        DateTime lastfiveminutes=Datetime.now().addMinutes(-5);
        String Query = 'select id,name,Temporary_Latitude__c,Current_Zip_Code__c,Current_City__c,Current_State__c,Current_Street_Address__c,Current_Address__c,Temporary_Longitude__c,LastModifiedDate from Asset where Temporary_Latitude__c!=null AND';
        Query += ' Temporary_Longitude__c !=null AND LastModifiedDate >=: lastfiveminutes limit 200';
        List<Asset> assetrecords=Database.Query(Query);    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpforUpdateCurrentAddress());
        updatecurrentaddress_Batch  updatebatch = new updatecurrentaddress_Batch();
        DataBase.executeBatch(updatebatch);
        //system.assertEquals(0, historyRecords.size());
        test.stopTest();
    }
    static void setup2() {
        Message_Type__c msgtype=new Message_Type__c();
        msgtype.Battery_Current_Use__c=0.5369;
        msgtype.Description__c='HeartBeat';
        msgtype.Name='2';
        insert msgtype;
        
        Account Acc = new Account();
        Acc.Name ='Cardinal Glass';
        Acc.phone='9600205548';
        insert Acc;
        
        Asset asst=new Asset(Name='Test');
        asst.AccountId=Acc.Id;
        asst.Current_Location__c=Acc.Id;
        asst.Message_Types__c=msgtype.Id;
        asst.Last_Connected__c=system.now();
        asst.State_of_Pallet__c='In Network';
        asst.Temporary_Latitude__c=40.1823;
        asst.Temporary_Longitude__c=-90.058477;
        asst.Device_Id__c='1234567';
                                        asst.Current_Street_Address__c = 'test';    

        //asst1.Current_Location__c=Acc1.id;
        asst.Field2__c='123465';
        insert asst; 
        
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c=asst.id;
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asst.Temporary_Latitude__c;
        assetHsitory.Longitude__c=asst.Temporary_Longitude__c;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Battery_Current__c=0.2165489653;
        assetHsitory.Still_in_this_Location__c=true;
        insert assetHsitory;
    }
    
    
}