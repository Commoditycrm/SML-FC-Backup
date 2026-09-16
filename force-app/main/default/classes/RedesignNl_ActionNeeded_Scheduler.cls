public class RedesignNl_ActionNeeded_Scheduler implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc){
         String query = 'SELECT Id, Action_Needed__c FROM Asset WHERE Last_connected__c < LAST_N_DAYS:365 AND Action_Needed__c Not In (\'Replace Batteries\', \'RMA To SMART\', \'Tag Destroyed\', \'Confirm RA#\') And (Product_Name__c LIKE \'AT2%\' OR Product_Name__c LIKE \'AT5%\')';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){
        try {
            for(Asset ast : assets) {
            ast.Action_Needed__c = 'Replace Batteries';
        }
        update assets; 
        } catch (Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNl_ActionNeeded_Scheduler', 'RedesignNl_ActionNeeded_Scheduler', 'Exception', null, null, true);
        }
    }
    
    public void finish(Database.BatchableContext bc){

    }
    
}