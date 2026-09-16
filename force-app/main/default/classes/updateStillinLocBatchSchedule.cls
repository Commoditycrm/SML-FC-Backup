global with sharing  class updateStillinLocBatchSchedule implements schedulable{
		global void execute(SchedulableContext sc) {
        UpdateStillInLoc_batch updatestillinloc = new UpdateStillInLoc_batch();
        database.executebatch(updatestillinloc);

        }
}