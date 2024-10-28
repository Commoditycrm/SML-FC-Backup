global class RedesignNL_patchclass implements Database.Batchable<sObject>,Database.Stateful {
    //String query ;
    Boolean runARC;
    Integer recCount = 0;
    string body;
    
    global RedesignNL_patchclass(boolean runArc){
        this.runArc= runArc;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*if(String.isBlank(query)){
this.query = 'select Id,End_Time__c, Power_Reset_Time__c,Asset__r.CreatedDate,Asset__r.Battery_Replaced_Date__c, CreatedDate,  Power_Reset_Occurred__c, rsrp__c, rsrq__c, rssi__c, estBattPct__c, Est_Remaining_Battery__c from Asset_History_custom__c where Est_Remaining_Battery__c =null AND  estBattPct__c != null';
}*/
        String query;
        if(runArc == true){
            //query = 'select PowerUptime__c, Timestamp_Date_Time_Device_Status__c, CreatedDate, Asset__r.name, Asset__r.PowerUp_Time__c, Timestamp_DateTime__c, Location__c, EstBattPct__c from API_Response_Childs__c where Asset_History__c in (select id from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and Est_Remaining_Battery__c != null) and asset__r.PowerUp_Time__c != null and Asset__r.name in (\'at5-t16ee4491f7c\',\'at5-t19d779e3a5f\')';
            query = 'select PowerUptime__c, Timestamp_Date_Time_Device_Status__c, CreatedDate, Asset__r.name, Asset__r.PowerUp_Time__c, Timestamp_DateTime__c, Location__c, EstBattPct__c from API_Response_Childs__c where Asset_History__c in (select id from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and Est_Remaining_Battery__c != null) and asset__r.PowerUp_Time__c != null';
        }else
            //query = 'select id, PowerUpTime__c, asset__r.PowerUp_Time__c from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and asset__r.PowerUp_Time__c != null and Asset__r.name in (\'at5-t16ee4491f7c\',\'at5-t19d779e3a5f\')';
            query = 'select id, PowerUpTime__c, asset__r.PowerUp_Time__c from Asset_History_custom__c where Still_in_this_Location__c = true and PowerUpTime__c = null and asset__r.PowerUp_Time__c != null';
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> Scope) {
        
       List<Cardinal_Response__c> crdRespList = [SELECT Id, Cardinal_Response_1__c,status__c,Response_Info__c FROM Cardinal_Response__c where API_Response__r.Name = 'API-45342416' order by Response_Sequence__c asc];
        List<Object> lst_JsonParse = new List<Object>();
        for(Cardinal_Response__c api : crdRespList) {
            String requestBody;
            if (api.Cardinal_Response_1__c != null) { 
                requestBody =api.Cardinal_Response_1__c;
                
            }
            List<Object> sublst_JsonParse = new List<Object>();
            if(requestBody != null){
                sublst_JsonParse = (List<object>)Json.deserializeUntyped(requestBody); 
                lst_JsonParse.addALL(sublst_JsonParse);
            }
        }
       Map<String, List<String>> achNamesByAsset= new Map<String, List<String>>();
Map<String, List<String>> result = new Map<String, List<String>>();
for (Object instance :lst_JsonParse){
    Map<String, Object> customer = (Map<String,Object>)instance;
    string devID = string.valueof(Customer.get('DeviceID'));
    
    if(result.containskey(devID))
    {
        List<string> res =result.get(devID);
        string plant = string.valueof(Customer.get('PlantName'));
        res.add(plant);
        result.put(devID,res);
        achNamesByAsset.put(devID,res);
    }
    else{ 
         List<string> res = new List<string>();
        string plant = string.valueof(Customer.get('PlantName'));
        res.add(plant);
        result.put(devID,res);
    }
}
  messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'murali@agilenautics.com','prithiviraj2348@gmail.com' };
        msg.setSubject('Un Grouped AHC Records');
        body = 'Overall Mismatched : '+ 'Asset records Count '+achNamesByAsset.keySet().size() + '\n';
        for(String astName : achNamesByAsset.keySet()){
            body += astName + '\n' + '\n';
        }
        for(String astName : achNamesByAsset.keySet()){
            body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ' , ') + '\n';
        }
       
        
        system.debug('Email sent--');
   
    }
    
    global void finish(Database.BatchableContext BC) {
         messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
    }
}