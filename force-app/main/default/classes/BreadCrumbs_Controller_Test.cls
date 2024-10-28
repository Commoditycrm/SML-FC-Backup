@isTest(SeeAllData=True)
public class BreadCrumbs_Controller_Test 
{
    /*    public static Data_Configuration__c d = new Data_Configuration__c();
    static testmethod void EinsteinCallOut(){
    
    d.Name = 'DatasetVersionId';
    insert d;
    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
    EinsteinCallOut.makeWebserviceCallout();
    test.stopTest();
    }*/
        
    private static testmethod void BreadCrumbs_Controller(){
        
        //As a part of account restructuring requirement
        //Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        //Id accRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        
        Date startdate= date.today();
        Date enddate=date.today();
        
        //Data_Configuration__c d = new Data_Configuration__c();
        //d.Name = 'DatasetVersionId';
        //insert d;
        
        Account Acc = new Account();
        Acc.Name ='Cardinal Glass';
        Acc.phone='9600205548';
        /*Acc.BillingCity='Chennai';
        Acc.BillingCountry='India';
        Acc.BillingPostalCode='123456';
        Acc.BillingState='Tamil Nadu';
        Acc.BillingStreet='1st Street';*/
        Acc.shippinglatitude=40.1823;
        Acc.shippinglongitude=80.1562;
        /*ACC.Type='Location';*/
        //Acc.RecordTypeId=accRecordTypeId;
        insert Acc;
        
        /* Account Acc1 = new Account();
        Acc1.Name ='Cardinal Glass Green';
        Acc1.ParentId=Acc.Id;
        Acc1.phone='9600205548';
        Acc1.BillingCity='Spring Green';
        Acc1.BillingCountry='United States';
        Acc1.BillingPostalCode='53588';
        Acc1.BillingState='WI';
        Acc1.BillingStreet='1011 East Madison Street';
        Acc1.shippinglatitude=43.174395;
        Acc1.shippinglongitude=-90.058477;
        Acc1.RecordTypeId=accRecordTypeId1;
        Acc1.External_Location_Id__c='1';
        insert Acc1;*/
        
        Asset asst1=new Asset();
        asst1.Name='Test Asset';
        asst1.AccountId=Acc.Id;
        asst1.Temporary_Latitude__c=42.175895;
        asst1.Temporary_Longitude__c=-89.058697;
        asst1.Device_Id__c='123456';
        //asst1.Current_Location__c=Acc1.id;
        asst1.Last_Connected__c=date.today()+2;
        asst1.State_of_Pallet__c='In Transit';
        asst1.Field2__c='123465';
        insert asst1;
        
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c=asst1.id;
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In Transit';
        assetHsitory.Latitude__c=asst1.Temporary_Latitude__c;
        assetHsitory.Longitude__c=asst1.Temporary_Longitude__c;
        assetHsitory.Start_Time__c=startdate;
        assetHsitory.End_Time__c=enddate;
        assetHsitory.Battery_Current__c=0.2165489653;
        insert assetHsitory;
        
        Data_Configuration__c dConfig= new Data_Configuration__c();
        dConfig.name='DatasetVersionId';
        dConfig.value__C= [select id,Name,value__C from Data_Configuration__c where Name = 'DatasetVersionId' limit 1].value__c;
        
        test.startTest();
        BreadCrumbs_Controller Bcrumbs= new BreadCrumbs_Controller();
        BreadCrumbs_Controller.fetchUserSessionId();
       // BreadCrumbs_Controller.getdatefromjs(startdate, enddate, asst1.id);
        test.stopTest();
        
    }
    
}