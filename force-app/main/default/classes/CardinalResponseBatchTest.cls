@isTest
public class CardinalResponseBatchTest {
    static testmethod void ProcessData_Ctrl2(){
        account acc=new account();
        acc.name='tset';
        insert acc;
        Asset ast = new Asset();
        ast.Name='at-atp36f5c401201';
        ast.Device_Id__c='at-atp36f5c401201';
        ast.AccountId=acc.id;
        ast.Field2__c ='RA00115968';
        ast.Ship_To_Customer_ID__c =10103907;
        ast.Ship_To_Customer_Name__c ='Thermal Industries (ship to)'; 
        //ast.Date_Shipped__c = 2020-01-15T00:00:00 ;
        insert ast;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProcessData/*';
        req.httpMethod = 'POST';
        String postData = '[{"CustomerID": "RA00076287","DeviceID": "at-atp36f5c401201","ShipToCustomerID": 10447964.0,"ShipToCustomerName": "Piva Group North America - MO","ShipDate": "2019-10-03T00:00:00","LastScanDate": "2019-10-03T03:56:04","AssetType": "A84P","PlantName": "test","PlantID": "16","ActionNeeded": "qyqyqy"}]';
        req.requestBody = Blob.valueof(postData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ProcessData_Ctrl.parseresponse();
        database.executeBatch(New CardinalResponseBatch('SELECT Id,Name FROM API_Response__c where Status__c in (\'CardinalNew\',\'CardinalProcessed\')'),1);
        Test.stopTest();        
        
        
    }
}