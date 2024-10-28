@isTest
public class FixInTransitAHC_Batch_Test {
    @isTest
    public static void testFixInTransitAHC_Batch(){

        Account acct = new Account(Name='test',GeoFence_Radius_in_Miles__c=1,shippinglatitude=43.174942,shippinglongitude=-90.056981);
        insert acct;
        insert new Related_Customer__c (Source_Account__c=acct.Id);
        Asset ast = new Asset(Name='Test1234',AccountId=acct.Id);
        insert ast;
        insert new Asset_History_custom__c(asset__c=ast.Id,latitude__c=43.174942,longitude__c=-90.056981,recordTypeID='0120h00000085zbAAA',Location__c='In Transit');
        Test.startTest();
        Database.executeBatch(new FixInTransitAHC_Batch('SELECT Id, Name, Asset__c, Account_ID__c, Asset_Name__c, Device_Id__c , location__c,latitude__c,'+
                                        'longitude__c,createddate,current_location_address__c, Api_Response__c,'+
                                        'record_type_developer_name__c, inserted_from__c, last_known_location__c '+
                                        'FROM Asset_History_custom__c WHERE record_type_developer_name__c = \'location\''+
                                        ' AND location__c = \'In Transit\' AND CreatedDate > 2023-04-21T00:00:00Z order by createddate desc',true), 1);
        Test.stopTest();
    }
}