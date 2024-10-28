global class RedesignAC_NL_to_SF_MonthlyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        RedesignAC_NL_to_SF_CalloutBatch AstconUpdate = new RedesignAC_NL_to_SF_CalloutBatch('MonthQuery');
        Database.executeBatch(AstconUpdate,50);
    }
}