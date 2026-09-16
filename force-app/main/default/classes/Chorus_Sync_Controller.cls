global with sharing class Chorus_Sync_Controller {

    /**
     * Sync-only ARC creation for Chorus.
     * Called from RedesignNL_CreateAPIRespChild_Batch.
     */
    public static void createARCFromSync(API_Response__c ar) {

        // Basic safety checks
        if (ar == null || ar.Asset__c == null || String.isBlank(ar.Incoming_Messsage__c)) {
            return;
        }

        try {
           
            List<Api_Response__c> scope = new List<Api_Response__c>{ ar };

            // Call execute() directly
            new Chorus_ArcBatch().execute(null, scope);
            // ADDED- Database.executeBatch(new Chorus_ArcBatch(), 1);

        } catch (Exception ex) {
            // Centralized error logging (same pattern as rest of project)
            RedesignNL_CaptureErrors.createErrorLogs(
                ex,
                'Chorus_Sync_Controller',
                'createARCFromSync',
                'SYNC Error',
                ar.Device_Id__c,
                ar.Incoming_Messsage__c,
                false
            );
        }
    }
}