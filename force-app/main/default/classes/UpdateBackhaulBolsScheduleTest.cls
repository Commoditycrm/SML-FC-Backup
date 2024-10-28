@isTest
private class UpdateBackhaulBolsScheduleTest {
    private static void init() {
        //insert test TMS_Credentials Custom Setting
		insert new TMS_Credentials__c(
			Username__c = 'tmsUsername',
			Password__c = 'tmsPassword',
			Is_Production__c = false,
			Endpoint__c = 'https://www.testTmsEndpoint.com'
		);

        BolTriggerHandler.bypassAfterInsertTrigger = true;
    }
	
	@isTest static void BackhaulBatchSchedulerTest() {
        init();

		String CRON_EXP = '0 0 1 * * ?';
        
        Test.startTest();

        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new UpdateBackhaulBolsSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
	}
}