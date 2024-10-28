global class CardinalResponseBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Static map to store device IDs and associated plant names across batches
    public Map<String, List<String>> achNamesByAsset = new Map<String, List<String>>();
     public set<String> assetIds = new Set<String>();
	String query;
    public CardinalResponseBatch(string qry){
        query= qry;
       }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Querying API_Response__c in the start method
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<API_Response__c> scope) {
        List<Object> lst_JsonParse = new List<Object>();
        List<Cardinal_Response__c> crdRespList = [SELECT Id, Cardinal_Response_1__c,status__c,Response_Info__c FROM Cardinal_Response__c where API_Response__c in:scope order by Response_Sequence__c asc];
            for (Cardinal_Response__c api :crdRespList) {
                String requestBody;
                if (api.Cardinal_Response_1__c != null) {
                    requestBody = api.Cardinal_Response_1__c;
                }
                
                List<Object> sublst_JsonParse = new List<Object>();
                if (requestBody != null) {
                    sublst_JsonParse = (List<Object>)Json.deserializeUntyped(requestBody);
                    lst_JsonParse.addAll(sublst_JsonParse);
                }
            }
        

        // Process each object and store results in the static map to track duplicates
        for (Object instance : lst_JsonParse) {
            Map<String, Object> customer = (Map<String, Object>)instance;
            String devID = String.valueOf(customer.get('DeviceID'));
            String plant = String.valueOf(customer.get('PlantName'));

            if (assetIds.contains(devID)) {
                List<String> res = achNamesByAsset.containskey(devID) ? achNamesByAsset.get(devID): new List<String>();
                res.add(plant+' '+scope[0].Name);
                achNamesByAsset.put(devID, res);  // Update the map with new plant info
            } else {
                assetIds.add(devId);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Composing the email body
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'murali@agilenautics.com', 'prithiviraj2348@gmail.com' };
        msg.setSubject('Cardinal Dupilcate Record');

        String body = 'Overall Duplicate: Asset records Count ' + achNamesByAsset.keySet().size() + '\n';
        for (String devID : achNamesByAsset.keySet()) {
            body += devID + ' : ' + String.join(achNamesByAsset.get(devID), ' , ') + '\n';
        }

        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
        System.debug('Email sent--');
    }
}