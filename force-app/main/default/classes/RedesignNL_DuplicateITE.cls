global class RedesignNL_DuplicateITE implements Database.Batchable<sObject>, Database.stateful {
    public Map<String, List<String>> achNamesByAsset;
    Public Set<Asset_History_Custom__c> wrongAHCList; 
    public RedesignNL_DuplicateITE(){
        this.achNamesByAsset = new Map<String, List<String>>();
        this.wrongAHCList = new Set<Asset_History_Custom__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id ,Name From Asset]);
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        List<Asset_History_Custom__c> ahcList= [Select Id,Name,Asset__r.Name,Start_time__c,End_time__c,Location__c,CreatedDate,Asset__c,Asset__r.Account_Name__c from Asset_History_Custom__c 
                                                where Asset__c in:Scope and Recordtype.developerName = 'Dwell_Time' 
                                                Order by Start_time__c asc , Asset__c asc ];
        Map<id,Map<id,List<Datetime>>> ahcMap = new Map<id,Map<id,List<Datetime>>>();
        for(Asset_History_Custom__c ahc:ahclist){
            Map<id,List<Datetime>> ahMapAdd = new Map<id,List<Datetime>>();
            if(ahcMap.containsKey(ahc.Asset__c)){
                ahMapAdd = ahcMap.get(ahc.Asset__c);
            }
            List<DateTime> ahTime = new List<DateTime>();
            ahTime.add(ahc.Start_Time__c);
            ahTime.add(ahc.End_Time__c);
            ahMapAdd.put(ahc.id,ahTime);
            ahcMap.put(ahc.Asset__c,ahMapAdd);
        }
        
        for(Asset_History_Custom__c ah:ahcList){
            Map<id,List<Datetime>> ahMapAdd = ahcMap.get(ah.Asset__c);
            for(id ahID: ahMapAdd.KeySet()){
                if(ah.id != ahID){
                    List<DateTime> ahTime = ahMapAdd.get(ahID);
                    DateTime st = ahTime[0];
                    DateTime et = ahTime[1];
                    if(ah.Start_Time__c == st || ah.End_Time__c == et){
                        List<String> temp = achNamesByAsset.containsKey(ah.Asset__r.Name) ? achNamesByAsset.get(ah.Asset__r.Name) : new List<String>();
                        temp.add('Same Time');
                        temp.add(ah.Name);
                        temp.add('CreatedDate '+' : ' + string.valueof(ah.CreatedDate) + ' Account Name' + ah.Asset__r.Account_Name__c);
                        achNamesByAsset.put(ah.Asset__r.Name, temp);
                            wrongAHCList.add(ah);
                        
                        
                    }
                    else if((ah.Start_Time__c >= st && ah.Start_Time__c <= et) || (ah.End_Time__c >= st && ah.End_Time__c <= et)){
                        List<String> temp = achNamesByAsset.containsKey(ah.Asset__r.Name) ? achNamesByAsset.get(ah.Asset__r.Name) : new List<String>();
                        temp.add('in between');
                        temp.add(ah.Name);
                        temp.add('CreatedDate '+' : ' + string.valueof(ah.CreatedDate) + ' Account Name' + ah.Asset__r.Account_Name__c);
                        achNamesByAsset.put(ah.Asset__r.Name, temp);
                            wrongAHCList.add(ah);
                    }
                    else if(ah.Start_Time__c >= st && ah.End_Time__c <= et){
                        List<String> temp = achNamesByAsset.containsKey(ah.Asset__r.Name) ? achNamesByAsset.get(ah.Asset__r.Name) : new List<String>();
                        temp.add('in between');
                        temp.add(ah.Name);
                        temp.add('CreatedDate '+' : ' + string.valueof(ah.CreatedDate) + ' Account Name' + ah.Asset__r.Account_Name__c);
                        achNamesByAsset.put(ah.Asset__r.Name, temp);
                            wrongAHCList.add(ah);
                    }
                    
                }
            }
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { System.Label.Email_Address };
            msg.setSubject('ITE Duplicate Reports');
        string body = 'Overall Mismatched : '+achNamesByAsset.keySet().size() + '\n';
        
        for(String astName : achNamesByAsset.keySet()){
            body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ' , ') + '\n';
        }
        body += ' Total no of wrong records: '+ wrongAHCList.size();
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('Email sent--');
        list<Asset_History_Custom__c> updateAHCList = new List<Asset_History_Custom__c>();
        for(Asset_History_Custom__c ahc : wrongAHCList){
            ahc.Delete_mark__c = true;
            updateAHCList.add(ahc);
        }
        if(updateAHCList.size()>0){
        update updateAHCList;
        }
    }

}