global with sharing class UpdateNullCurrentAddress implements schedulable
{
      global void execute(SchedulableContext sc) {
        updateCurrentAddress updateAssethis = new updateCurrentAddress();
        database.executebatch(updateAssethis);
    }
}