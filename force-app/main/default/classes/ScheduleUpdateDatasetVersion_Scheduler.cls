global class ScheduleUpdateDatasetVersion_Scheduler implements Queueable, Database.AllowsCallouts  {
    
    global void execute(QueueableContext context) {
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
    		EinsteinCallOut.makeWebserviceCallout();
        }
        else{
    		EinsteinCallOut.makeWebserviceCallout();
        }
    }
}