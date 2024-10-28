global class deleteApi_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        DeleteApiResponseBatch api_del = new DeleteApiResponseBatch(); 
        // To execute batch in 9,00,000 lakhs record will be processing
        Database.executeBatch(api_del,900000);
    }
}