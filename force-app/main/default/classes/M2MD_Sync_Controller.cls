global with sharing class M2MD_Sync_Controller {

    public static void createARCFromSync(API_Response__c ar) {

        // 
        if (ar == null || String.isBlank(ar.Incoming_Messsage__c)) {
            return;
        }

        try {
            String requestBody = ar.Incoming_Messsage__c;
            String deviceId    = ar.Device_Id__c;

            if (String.isBlank(deviceId)) {
                return;
            }

            // Get or create Asset (reuse existing M2MD logic)
            Asset ast = M2MD_Event_Ctrl.createAsset(deviceId);

            if (ast == null) {
                return;
            }
            //️⃣ Create ARC using existing M2MD parsing logic
            API_Response_Childs__c arc =
                M2MD_Event_Ctrl.createLocAndDevStsRecordFromM2MD(
                    requestBody,
                    ar.Asset__c
                );

            if (arc == null) {
                return;
            }

            // Record Type (MANDATORY to avoid "field not covered")
            arc.RecordTypeId =
                RedesignNL_Helper.getAPIChildRecordTypeID(
                    RedesignNL_Helper.ArcLocationRecordtype
                );

            //️⃣ Set mandatory ARC fields (SYNC context)
            arc.Asset__c        = ast.Id;
            arc.API_Response__c = ar.Id;
            arc.Name            = (ar.Name != null ? ar.Name : ar.Id) + '-Location';

            // External ID (SYNC-safe & idempotent)
            arc.ARC_External_Id__c =
                ast.Id + '~' + ar.Id + '~M2MD';

            // Timestamps (prefer device timestamp)
            if (ar.Location_TimeStamp__c != null) {
                Long ts = Long.valueOf(ar.Location_TimeStamp__c);
                arc.Timestamp__c = ts;
                arc.Timestamp_Device_Status__c = ts;
                arc.Timestamp_DateTime__c =
                    Datetime.newInstance(ts);
                arc.Timestamp_Date_Time_Device_Status__c =
                    Datetime.newInstance(ts);
            } else {
                arc.Timestamp__c = ar.ResEnteringTime__c;
                arc.Timestamp_Device_Status__c = ar.ResEnteringTime__c;
                arc.Timestamp_DateTime__c = ar.ResEnteringDttime__c;
                arc.Timestamp_Date_Time_Device_Status__c = ar.ResEnteringDttime__c;
            }

            // Status for M2MD sync
            arc.Status__c = 'Chorus-New';

            // Insert ARC (duplicate-safe via External ID)
            insert arc;

        } catch (Exception ex) {
            // Centralized error logging (same pattern as project)
            RedesignNL_CaptureErrors.createErrorLogs(
                ex,
                'M2MD_Sync_Controller',
                'createARCFromSync',
                'API Error',
                ar != null ? ar.Device_Id__c : null,
                ar != null ? ar.Incoming_Messsage__c : null,
                false
            );
        }
    }
}