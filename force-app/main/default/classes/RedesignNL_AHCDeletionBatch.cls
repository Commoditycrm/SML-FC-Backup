public class RedesignNL_AHCDeletionBatch implements Database.Batchable<sObject>{
    
    public String query;
    public boolean isdelete;
    
    public RedesignNL_AHCDeletionBatch(String query, boolean isdelete) {
        this.isdelete = isdelete;
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Asset_History_custom__c> scope) {
        if(isdelete){
            Database.DeleteResult[] deleteResults = Database.delete(scope, false);
        }else{
            for(Asset_History_custom__c ahc : scope){
                ahc.Preserve_for_EA__c =true;
            }
            Database.SaveResult[] updateResults = Database.update(scope, false);
        }
    }
    // Finish method after all batches are processed
    public void finish(Database.BatchableContext bc) {
    }
}