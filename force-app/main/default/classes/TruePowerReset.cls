public class TruePowerReset implements Database.Batchable<sobject>,Database.Stateful {
    
    public Map<String, List<String>> apiRespByAsset;
    public String astQuery;
    public String apiQueryFilter;
    public Set<String> assetIds = new Set<String>();
    public String Email_address = System.Label.Email_address;
         
    public TruePowerReset(String apiQueryFilter){
        this.apiQueryFilter = apiQueryFilter;
        //select Id,asset__c from Api_Response__c  where createddate >= 2023-05-26T00:00:00.000Z and createddate < 2023-06-10T00:00:00.000Z order by createddate asc
        //select Id,asset__c from Api_Response__c where createddate = 2023-05-26T00:00:00.000Z 
            this.apiRespByAsset = new Map<String, List<String>>();        
        for(Api_Response__c obj : DataBase.Query(apiQueryFilter)){
            assetIds.add(obj.Asset__c);
        }       
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        astQuery = 'Select Id, Name from Asset Where Id IN:assetIds';
        //System.debug('Asset Size'+assetIds.size());
        return database.getQueryLocator(astQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){
        String qry = apiQueryFilter + ' AND Asset__c IN: assets' + ' ORDER BY createddate asc';
      //  System.debug('qry='+ qry);           
        List<Api_Response__c> apirespList = DataBase.Query(qry);
      //   System.debug('list size='+ apirespList.size());
   
         for(Integer i=0; i<apirespList.size()-1; i++){         
          Integer Power1 = extractPowerUptime(String.valueOf(apirespList[i].device_status__c));
            Integer Power2 = extractPowerUptime(String.valueOf(apirespList[i+1].device_status__c)); 
             if(Power1 >Power2 && string.valueOf(Power1).length() > string.valueOf(Power2).length() ){ // condition satisfied - power reset occurred
              //  System.debug('API Response '+ apirespList[i+1].Name + ' had power reset');
                List<String> temp = apiRespByAsset.containsKey(assets[0].Name) ? apiRespByAsset.get(assets[0].Name) : new List<String>();
                temp.add(apirespList[i+1].Name);
                apiRespByAsset.put(assets[0].Name, temp);
                //  System.debug('Assets are :' + assets[0].Name);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] {'commodityccrm@gmail.com'};
        msg.setSubject('Assets with true power reset');
        string body = 'Assets with true power reset : '+ '\n';       
        for(String astName : apiRespByAsset.keySet()){
            body += astName + ' : ' + String.join(apiRespByAsset.get(astName), ',') + '\n';
        }
       msg.setPlainTextBody(body);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
       //system.debug('Email sent--');
    }
    
     public static Integer extractPowerUptime(String deviceStatus) {
         try {
        String deviceStatusString = deviceStatus.substring(1, deviceStatus.length() - 1);

        List<String> keyValuePairs = deviceStatusString.split(', ');

        //Map<String, String> deviceStatusMap = new Map<String, String>();
        for (String pair : keyValuePairs) {
            List<String> parts = pair.split('=');
            if(parts[0] == 'powerUptime'){
                Integer result = Integer.valueOf(parts[1]);
                return result;
              /* String key = parts[0];
            String value = parts[1];
            deviceStatusMap.put(key, value); */
            }
        }

        /*if (deviceStatusMap.containsKey('powerUptime')) {
            Integer powerUptimeValue = Integer.valueOf(deviceStatusMap.get('powerUptime'));
            return powerUptimeValue;
        }*/
    } catch (Exception e) {
             RedesignNL_CaptureErrors.createErrorLogs(e, 'TruePowerReset', 'extractPowerUptime', 'Exception', null, null, true);
             //System.debug('Error parsing JSON: ' + e.getMessage());
         }
         return null;
     }
}