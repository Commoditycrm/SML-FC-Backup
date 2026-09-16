global class Chorus_TemperatureAhcBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Set<ID> AssetIDSet;
    public Chorus_TemperatureAhcBatch(Set<ID> AssetIDSet) {
        this.AssetIDSet = AssetIDSet;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id ' +
                       'FROM Asset ' +
                       'WHERE Id IN :AssetIDSet ';// +
                       //'AND Capture_Temperature_Response__c = True';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Asset> scope) {
        String tempRecTypeId;
        try {
            tempRecTypeId = RedesignNL_Helper.getAHCRecTypes(RedesignNL_Helper.AHCTemperatureRecordtype);
        } catch (Exception e) {
            tempRecTypeId = null;
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'execute', 'Temp RecType Exception', null, null, true);
        }
        List<Asset_History_Custom__c> tempAhcToInsert = new List<Asset_History_Custom__c>();
        List<API_Response_Childs__c> ARCList = [SELECT Id, Asset__c, Temperature__c, Relative_Humidity__c, Timestamp_DateTime__c, 
                                                Status__c,Asset__r.Capture_Temperature_Response__c 
                                                FROM API_Response_Childs__c 
                                                WHERE Asset__c IN :scope 
                                                AND RecordType.DeveloperName = 'Temperature' 
                                                AND Status__c = 'Chorus-New' ORDER BY Asset__c, createddate asc];
        
        Map<Id, Asset> assetsToUpdate = new Map<Id, Asset>();

        for (API_Response_Childs__c arcDev : ARCList) {
            if (arcDev.Asset__r.Capture_Temperature_Response__c == true) {
                createTemperatureAHC_NoDml(arcDev, tempRecTypeId, tempAhcToInsert);
            }

            assetsToUpdate.put(
                arcDev.Asset__c,
                new Asset(
                    Id = arcDev.Asset__c,
                    Temperature__c = arcDev.Temperature__c,
                    Humidity__c = arcDev.Relative_Humidity__c
                )
            );

            arcDev.Status__c = 'Processed';
        }

        if (!tempAhcToInsert.isEmpty()) {
            insert tempAhcToInsert;
        }

        if (!ARCList.isEmpty()) {
            update ARCList;
        }

        if (!assetsToUpdate.isEmpty()) {
            update assetsToUpdate.values();
        }
    }

    global void finish(Database.BatchableContext bc) {
        try {
            Chorus_Controller.scheduleJob();
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Chorus_AhcBatch', 'finish', 'Exception', null, null, true);
        }
    }

    public static void createTemperatureAHC_NoDml(Api_Response_Childs__c arcDev, String tempRecTypeId, List<Asset_History_Custom__c> tempAhcToInsert) {
        if (arcDev == null) return;
        if (arcDev.Temperature__c == null && arcDev.Relative_Humidity__c == null) return;

        Asset_History_Custom__c tempAhc = new Asset_History_Custom__c();
        tempAhc.Asset__c = arcDev.Asset__c;
        if (!String.isBlank(tempRecTypeId)) tempAhc.RecordTypeId = tempRecTypeId;

        tempAhc.Start_Time__c = arcDev.Timestamp_DateTime__c;
        tempAhc.End_Time__c   = arcDev.Timestamp_DateTime__c;
        tempAhc.Temperature__c = arcDev.Temperature__c;
        tempAhc.Relative_Humidity__c = arcDev.Relative_Humidity__c;
        tempAhc.Still_in_this_Location__c = false;

        tempAhcToInsert.add(tempAhc);
    }
}