/**
 * @author -- Gokulprasath
 * @date -- 02/20/2019
 * @description -- This Class will test class coverage for googleApicallout class.
 **/

@isTest
public class googleApiCallout_Test{
    public class ApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse hr = new HttpResponse();
            hr.setBody('{"results": [        {             "address_components": [                 {                     "long_name": "5-B2",                     "short_name": "5-B2",                     "types": [                         "premise"                     ]                 },                 {                     "long_name": "Padi Pudur Nagar",                     "short_name": "Padi Pudur Nagar",                     "types": [                         "political",                         "sublocality",                         "sublocality_level_3"                     ]                 },                 {                     "long_name": "Anna Nagar West",                     "short_name": "Anna Nagar West",                     "types": [                         "political",                         "sublocality",                         "sublocality_level_2"                     ]                 },                 {                     "long_name": "Koyambedu",                     "short_name": "Koyambedu",                     "types": [                         "political",                         "sublocality",                         "sublocality_level_1"                     ]                 },                 {                     "long_name": "Chennai",                     "short_name": "Chennai",                     "types": [                         "locality",                         "political"                     ]                 },                 {                     "long_name": "Chennai",                     "short_name": "Chennai",                     "types": [                         "administrative_area_level_3",                         "political"                     ]                 },                 {                     "long_name": "Tamil Nadu",                     "short_name": "TN",                     "types": [                         "administrative_area_level_1",                         "political"                     ]                 },                 {                     "long_name": "India",                     "short_name": "IN",                     "types": [                         "country",                         "political"                     ]                 },                 {                     "long_name": "600050",                     "short_name": "600050",                     "types": [                         "postal_code"                     ]                 }             ],             "formatted_address": "5-B2, Padi Pudur Nagar, Anna Nagar West, Koyambedu, Chennai, Tamil Nadu 600050, India",             "geometry": {                 "location": {                     "lat": 13.0800808,                     "lng": 80.1882813                 },                 "location_type": "ROOFTOP",                 "viewport": {                     "northeast": {                         "lat": 13.0814297802915,                         "lng": 80.18963028029151                     },                     "southwest": {                         "lat": 13.0787318197085,                         "lng": 80.1869323197085                     }                 }             },             "place_id": "ChIJ4YuJEQBkUjoR0pFj_jwLdYU",             "plus_code": {                 "compound_code": "35JQ+28 Chennai, Tamil Nadu, India",                 "global_code": "7M5235JQ+28"             },             "types": [                 "street_address"             ]         }]}');
            return hr ;
        }
    }
	Public static testmethod void testgoogleApiCallout() {
    	//As a part of account restructuring requirement
        //Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
         Account Acc1 = new Account();
         Acc1.Name ='Cardinal Glass Spring Green';
         Acc1.phone='9600205548';
        Acc1.BillingCity='Spring Green';
        Acc1.BillingCountry='United States';
        Acc1.BillingPostalCode='53588';
        Acc1.BillingState='WI';
        Acc1.BillingStreet='1011 East Madison Street';
        Acc1.shippinglatitude=40.12568900;
        Acc1.shippinglongitude =-90.15486000;
        //ACC1.RecordTypeId=accRecordTypeId;
        ACC1.External_Location_Id__c='1';
        insert Acc1;
        
        Asset asst=new Asset(Name='Test');
        asst.AccountId=Acc1.id;
     	asst.Temporary_Latitude__c=40.12568900;
        asst.Temporary_Longitude__c=-90.15486000;
        asst.Current_Street_Address__c='1011 East Madison Street';
        insert asst; 
        
       //To Test HTTPreq1
        Asset_History_custom__c assthis =new Asset_History_custom__c();
        assthis.Latitude__c=40.12568900;
        assthis.Longitude__c=-90.15486000;
        assthis.Asset__c = asst.id;
        assthis.Current_Location_Address__c='1011 East Madison Street';
        insert assthis; 
       
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        googleApiCallout.httpreq1(40.12568900,-90.15486000,assthis.id);
        googleApiCallout.httpreq(40.12568900,-90.15486000,asst.id);
        googleApiCallout.httpreq(40.12568900,-90.15486000,Acc1.id);
        Test.setMock(HttpCalloutMock.class, new googleApiCallout_Test.ApiMock());
        googleApiCallout.httpreq(13.080146,80.188226,asst.id);
        Test.stopTest();      
    }
}