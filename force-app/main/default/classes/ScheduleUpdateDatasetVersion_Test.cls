@IsTest
public class ScheduleUpdateDatasetVersion_Test {
     static testmethod void schedulerTestMethod1() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
       
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ScheduleUpdateDatasetVersion());
            

        Test.stopTest();
    }

}