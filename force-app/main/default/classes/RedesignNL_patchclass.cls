global class RedesignNL_patchclass implements Database.Batchable<sObject> {
    Public String query ;
    public Integer totalMisMatchCount;

    
     public RedesignNL_patchclass(String query) {
        this.query = query;  
         this.totalMisMatchCount = 0;
    }
    
    public RedesignNL_patchclass() {   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(query)){
           //this.query = 'select Id,End_Time__c, Power_Reset_Time__c,Asset__r.CreatedDate,Asset__r.Battery_Replaced_Date__c, CreatedDate,  Power_Reset_Occurred__c, rsrp__c, rsrq__c, rssi__c, estBattPct__c, Est_Remaining_Battery__c from Asset_History_custom__c where Est_Remaining_Battery__c =null AND  estBattPct__c != null';
           //this.query = 'SELECT Id, Asset__c FROM Asset_History_custom__c WHERE Location__c = \'Kacey Weaver\'';
           //this.query = 'Select Id, Name, Max_LKL_End_time__c from Asset where Deleted_AHC__c = true';
           //this.query = 'select id from Asset_History_custom__c where CreatedDate > 2023-07-01T00:00:00.000+0000 and End_Time__c <2024-01-01T00:00:00.000+0000 and Still_in_this_Location__c != true and Preserve_for_EA__c = true';
           this.query =  'SELECT Id, Source_Account__c From Account WHERE Source_Account__c != null';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> Scope) {
        Asset ast = Scope[0];
        List<Asset_History_Custom__c> ahcToUpdate = new List<Asset_History_Custom__c>();
        List<Asset_History_Custom__c> ahcList = [SELECT Id, Asset__c, Start_Time__c, End_Time__c, Still_in_this_Location__c
                                    FROM Asset_History_Custom__c
                                    WHERE Asset__c = :ast.Id AND RecordType.DeveloperName = 'Location' AND Location__c != 'In Transit - Ever' 
                                    ORDER BY End_Time__c DESC Limit 50000];
        Asset_History_Custom__c prevAhc = null;
        
        for(Asset_History_Custom__c ahc : ahcList){
            if(ahc.Id == ahcList[0].Id){
                prevAhc = ahc;
                continue;
            }
            if(prevAhc != null && prevAhc.Start_Time__c != ahc.End_Time__c){
                    prevAhc.Start_Time__c = ahc.End_Time__c;
                    ahcToUpdate.add(prevAhc);
            }
            prevAhc = ahc;
        }
        
        if(ahcToUpdate.size() > 0){
            totalMisMatchCount = totalMisMatchCount + ahcToUpdate.size();
            update ahcToUpdate;
        }
        
        
        /*
          NEW FIXLOCATIONLOOKUP LOGIC


        List<Asset_History_Custom__c> ahcList = [
            SELECT Id, Last_Known_Location__c
            FROM Asset_History_Custom__c
            WHERE Last_Known_Location_Lookup__c = null
            AND Last_Known_Location__c != null
        ];

        Map<String, Account> accMap = new Map<String, Account>();
        
        for(Account a : [SELECT Id, Name FROM Account]){
            accMap.put(a.Name, a);
        }
        
        for(Asset_History_Custom__c ahc : ahcList){
            if(accMap.containsKey(ahc.Last_Known_Location__c)){
                ahc.Last_Known_Location_Lookup__c =
                    accMap.get(ahc.Last_Known_Location__c).Id;
            }
        }
        
        update ahcList;
        
        
        /*for(Asset ast : Scope){
                Boolean lowEstPct      = (ast.est_Batterycalculate__c != null  && ast.est_Batterycalculate__c < 15);
                Boolean lowVoltage     = (ast.Battery_Voltage__c  != null && ast.Battery_Voltage__c  < 5.9);
                Boolean scanMinusConn  = false;
                Boolean todayMinusConn = false;

                if (ast.Date_Shipped__c != null && ast.Last_connected__c != null) {
                    Integer diff1 = Math.abs(ast.Date_Shipped__c.date().daysBetween(ast.Last_connected__c.date()));
                    scanMinusConn = diff1 > 30;
                }

                if (ast.Last_connected__c != null) {
                    Integer diff2 = Math.abs(Date.today().daysBetween(ast.Last_connected__c.date()));
                    todayMinusConn = diff2 > 365;
                }

                if((lowEstPct || lowVoltage || scanMinusConn || todayMinusConn)&& ast.Action_Needed__c != 'Replace Batteries'){
                    ast.Action_Needed__c = 'Replace Batteries';
                    astToUpdate.add(ast);
                }else {
                    if (ast.Action_Needed__c == 'Replace Batteries') {
                        ast.Action_Needed__c = null;
                        astToUpdate.add(ast);
                    }
                }
        }

        if(astToUpdate.size() > 0){
            List<Database.SaveResult> UpdateAst = Database.update(astToUpdate, false);
        }*/

       /*Set<Id> astIdSet = new Set<Id>();
        for(Asset_History_custom__c ahc : astHistoryList){
            astIdSet.add(ahc.Asset__c);
    }
        List<Asset> astList = [SELECT Id, Deleted_AHC__C from Asset WHERE Id in :astIdSet];
        for(Asset ast : astList){
            ast.Deleted_AHC__c = true;
        }
         List<Database.SaveResult> UpdateResult = Database.update(astList, false);
         List<Database.DeleteResult> DeleteResult = Database.Delete(astHistoryList, false);
        String astId = Scope[0].Id;
        Asset_History_custom__c ahc = [Select Id, Still_in_this_Location__c, End_Time__c from Asset_History_custom__c WHERE Asset__c = :astId order by Start_Time__c desc LIMIT 1];
        API_Response_Childs__c apc = [Select Id, Name, status__c from API_Response_Childs__c WHERE Asset__c = :astId and Recordtype.DeveloperName = 'Location' order by CreatedDate desc LIMIT 1];
        ahc.Still_in_this_Location__c = true;
        ahc.End_Time__c = ahc.End_Time__c < Scope[0].Max_LKL_End_time__c ? Scope[0].Max_LKL_End_time__c : ahc.End_Time__c;
        Database.SaveResult UpdateAhcResult = Database.update(ahc, false);
        
        apc.Status__c = 'New';
        ListDatabase.SaveResult UpdateApcResult = Database.update(apc, false);*/
        //List<Database.DeleteResult> DeleteAhcResult = Database.delete(Scope, false);
        
    }
    
    global void finish(Database.BatchableContext BC) {
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { System.label.Email_Address };
        msg.setSubject('ACH MisMatch Start/End Time Fix');
        string body = 'Overall Mismatched : '+totalMisMatchCount + '\n';
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
    }
    /*
     * RedesignNL_patchclass batch = new RedesignNL_patchclass();
Database.executeBatch(batch, 1); // Set batch size to 1
     * */
}