global class ScheduleUpdateDatasetVersion implements schedulable{
	
    global void execute (SchedulableContext ctx) {
		
        /** Get Recent Dataset Version Id**/
      System.enqueueJob(new ScheduleUpdateDatasetVersion_Scheduler());

    }
}