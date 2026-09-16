global class ScheduleProdToUAT implements Schedulable {

    global void execute(SchedulableContext sc) {
        if(!Test.isRunningTest())
	        ID jobID = System.enqueueJob(new ProdToUATNimblelink());
        else {
            integer i = 0;
        }
    }
}
/*
//String cronExpr = '0 0/10 * * * ?';
ScheduleProdToUAT sched = new ScheduleProdToUAT();
system.schedule('Every Hour plus 10 min', cronExpr, sched);
 */