@isTest
public class InventoryBatch_Scheduler_test {

     static testmethod void schedulerTestMethod() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();

            String jobId1 = System.schedule('ScheduleApexClassTest1',  CRON_EXP, new InventoryBatch_Scheduler());
            //String jobId2 = System.schedule('ScheduleApexClassTest2',  CRON_EXP, new UpsertAssetfromApi_Scheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId1];
            System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        // Add assert here to validate result
    }
}