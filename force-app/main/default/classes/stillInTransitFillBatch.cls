global class stillInTransitFillBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Total_Dwell_Days__c, Max_LKL_End_time__c FROM Asset WHERE State_of_Pallet__c =\'In Transit\' AND Total_Dwell_Days__c > 13';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        List<Asset_History_Custom__c> ahcToUpdate = new List<Asset_History_Custom__c>();
        
        for (Asset ast : scope) {
            Asset_History_Custom__c InTransitEverRec;
            try {
                InTransitEverRec = [
                    SELECT Id, Asset__c, Location__c, Name, In_Transit_Ever_Check__c, Still_in_transit__c, Consider_for_Dwell__c, Start_Time__c, End_Time__c
                    FROM Asset_History_Custom__c
                    WHERE Asset__c = :ast.Id AND Location__c = 'In Transit - Ever' 
                    ORDER BY Start_Time__c DESC LIMIT 1
                ];
            } catch (Exception e) {
                InTransitEverRec = null;
            }

           /* Asset_History_Custom__c KnownLocRec;
            try {
                KnownLocRec = [
                    SELECT Id, Asset__c, Location__c, Name, In_Transit_Ever_Check__c, Still_in_transit__c, Consider_for_Dwell__c, Start_Time__c, End_Time__c
                    FROM Asset_History_Custom__c
                    WHERE Asset__c = :ast.Id AND Location__c != 'In Transit - Ever' AND Location__c != 'In Transit'
                    ORDER BY Start_Time__c DESC LIMIT 1
                ];
            } catch (Exception e) {
                KnownLocRec = null;
            }*/
            
            Long InTransitEverRecStartTime = InTransitEverRec != null ? InTransitEverRec.Start_Time__c.getTime() / 1000 : null;
            Long KnownLocRecEndTime = ast.Max_LKL_End_time__c != null ? ast.Max_LKL_End_time__c.getTime() / 1000 : null;

            if (InTransitEverRec != null && KnownLocRecEndTime != null) {
                if (InTransitEverRecStartTime >= KnownLocRecEndTime) {
                    InTransitEverRec.Still_in_transit__c = true;
                    ahcToUpdate.add(InTransitEverRec);
                }
            } else if (InTransitEverRec != null && KnownLocRecEndTime == null) {
                InTransitEverRec.Still_in_transit__c = true;
                ahcToUpdate.add(InTransitEverRec);
            }
        }

        if (!ahcToUpdate.isEmpty()) {
            update ahcToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing completed successfully.');
    }
}