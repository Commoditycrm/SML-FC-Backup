@isTest
public class testRedesignNl_errorMail_schedulerClass {
@testSetup static void testDataSetup(){
        Api_response__c ar = new Api_response__c();
       insert ar;
}
     @IsTest
    Static Void testAC_DC_to_NLUpdate_FailBatch(){
        Test.startTest();
        RedesignNlErrorMailSchedulerClass job = new RedesignNlErrorMailSchedulerClass();
        job.execute(null);
        RedesignNlErrorMailSchedulerClass.sendEmailToCCRM('dummy');
        Test.stopTest();
    }
}