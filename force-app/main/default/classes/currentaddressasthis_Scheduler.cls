global with sharing class currentaddressasthis_Scheduler implements schedulable{
   global void execute(SchedulableContext sc) {
        currentaddressasthis_Batch updateAssethis = new currentaddressasthis_Batch();
        database.executebatch(updateAssethis);
    }
}