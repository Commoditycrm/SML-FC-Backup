global class RedesignAC_NL_to_SF_DailyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        RedesignAC_NL_to_SF_CalloutBatch AstconUpdate = new RedesignAC_NL_to_SF_CalloutBatch('DayQuery'); 
        Database.executeBatch(AstconUpdate,50);
    }
}