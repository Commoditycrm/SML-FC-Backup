global class RedesignNL_LocationMismatch implements Database.Batchable<sObject>, Database.stateful {
    public Map<String, List<String>> achNamesByAsset;
    List<Asset_History_Custom__c> mismatchAHCList;
    Set<String> AccountList;
    Map<Id,Asset_History_Custom__c> ahcReportMap= new Map<Id,Asset_History_Custom__c>();
    public RedesignNL_LocationMismatch(){
        this.achNamesByAsset = new Map<String, List<String>>();
        this.mismatchAHCList = new List<Asset_History_Custom__c>();
        this.AccountList = new Set<String>();
        this.ahcReportMap = new Map<Id,Asset_History_Custom__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id ,Name From Asset]);
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        List<Asset_History_Custom__c> ahcList= [SELECT Id, Name, Start_Time__c,Still_in_this_Location__c, End_Time__c,Asset__c,Current_Location_Address__c,Location__c,Delete_check__c,createdDate,RecordTypeId FROM Asset_History_custom__c WHERE Asset__c in :Scope AND Recordtype.developerName = 'Location' AND isDeleted = false AND CreatedDate = Last_N_Days:95 ORDER BY Asset__c asc,End_time__c desc];
        Map<id,List<Asset_History_Custom__c>> ahcMap = new Map<id,List<Asset_History_Custom__c>>();
        for(Asset_History_Custom__c ahc:ahclist){
            List<Asset_History_Custom__c> ahMapAdd =new List<Asset_History_Custom__c>();
            if(ahcMap.containsKey(ahc.Asset__c)){
                ahMapAdd = ahcMap.get(ahc.Asset__c);
            }
            ahMapAdd.add(ahc);
            ahcMap.put(ahc.Asset__c,ahMapAdd);
        }
        
        for(Asset  ast:scope){
            if(ahcMap.containskey(ast.id)){
                List<String> temp = new List<String>();
                List<Asset_History_Custom__c> achList = new List<Asset_History_Custom__c>();
                achList = ahcMap.get(ast.id);
                
                
                for(Integer i=1; i<achList.size(); i++){
                    if((achList[i-1].Location__c != 'In Transit' && achList[i-1].Current_Location_Address__c == achList[i].Current_Location_Address__c )&& ((achList[i-1].Start_time__c == achList[i].End_Time__c )||(achList[i-1].End_Time__c == achList[i].Start_Time__c ))&& (achList[i-1].Still_in_this_Location__c == true || achList[i].Still_in_this_Location__c == true)){
                        mismatchAHCList.add(achList[i]);
                        ahcReportMap.put(achList[i-1].Id,achList[i-1]);
                        ahcReportMap.put(achList[i].Id,achList[i]);
                        temp.add('In Transit' + achList[i].Name + '---' + achList[i].Start_Time__c + ' || ' + achList[i-1].Name + '--'+ achList[i-1].End_Time__c);
                    }
                    if((achList[i-1].Location__c != 'In Transit' && achList[i-1].Location__c == achList[i].Location__c ) && ((achList[i-1].Start_time__c == achList[i].End_Time__c )||(achList[i-1].End_Time__c == achList[i].Start_Time__c )) &&  (achList[i-1].Still_in_this_Location__c == true || achList[i].Still_in_this_Location__c == true)){
                        mismatchAHCList.add(achList[i]);
                        ahcReportMap.put(achList[i].Id,achList[i]);
                        ahcReportMap.put(achList[i-1].Id,achList[i-1]);
                        temp.add('\n' + achList[i].Location__c + achList[i].Name + '---' + achList[i].Start_Time__c + ' || ' + achList[i-1].Name + '--'+ achList[i-1].End_Time__c);
                        AccountList.add(achList[i].Location__c);                    
                    }
                }
                if(temp.size()>0)
                    achNamesByAsset.put(ast.Name, temp);
            }
        }       
    }
    global void finish(Database.BatchableContext BC) {
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { System.Label.Email_Address };
            msg.setSubject('Un Grouped AHC Records');
        string body = 'Overall Mismatched : '+ 'Asset records Count '+achNamesByAsset.keySet().size() +   ' AHC records Count: '+ mismatchAHCList.size() + '\n';
        for(String astName : achNamesByAsset.keySet()){
            body += astName + '\n' + '\n';
        }
        for(String astName : achNamesByAsset.keySet()){
            body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ' , ') + '\n';
        }
        body+= 'Duplicates Account Count' + AccountList.size() + '\n';
        for( String ats : AccountList){
            body+= ats + '\n';
        }
        List<Asset_History_Custom__c> acc= New List<Asset_History_Custom__c>(ahcReportMap.values());
        RedesignNL_CSVEmailSender.sendCSVAsEmail(acc);
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
    }
    
}