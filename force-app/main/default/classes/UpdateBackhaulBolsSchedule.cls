global class UpdateBackhaulBolsSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		UpdateBackhaulBolsBatch batch = new UpdateBackhaulBolsBatch();
		Database.executebatch(batch);
	}
}