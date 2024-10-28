@isTest
public class EinsteinCallout_Test {
    private static testmethod void EinsteinCallOut(){
        
        Data_Configuration__c d = new Data_Configuration__c();
        d.Name = 'DatasetVersionId';
        insert d;
            
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        EinsteinCallOut.makeWebserviceCallout();
        test.stopTest();
    }
}