@istest
public class testRedesignNL_BusinessName {
	 @testSetup
    static void testDataSetup(){
        Google_Api_Data__c acc = new Google_Api_Data__c();
        acc.Business_Name__c = '123';
        insert acc;
    }
     @isTest
    public static void testParseBidNimbeLinkResponse(){
        Test.startTest();
        database.executeBatch(New RedesignNL_BusinessName(),15);
        Test.stopTest();
    }
    
}