public class TruePowerResetRevisedBatch implements Database.Batchable<sobject>,Database.Stateful{
    public Set<String> assetIds = new Set<String>();
    public Map<String, List<String>> apiRespByAsset = new Map<String, List<String>>();
    public boolean check;
    public TruePowerResetRevisedBatch(boolean check){
        this.check = check;
    }    
    public Database.QueryLocator start(Database.BatchableContext bc){
        string astQuery;
        if(this.check == false){
           astQuery = 'Select Id,Name from Asset where Power_Reset_Occurred__c = false';
        }
        else{
        astQuery = 'Select Id, Name from Asset';
        }
        return database.getQueryLocator(astQuery);
    }
    public void execute(Database.BatchableContext bc, List<Asset> assets){
        try{
            list<API_Response_childs__c> apirespChildList = [select Id, asset__c, PowerUptime__c, name, CreatedDate from API_Response_childs__c where asset__c IN: assets AND Timestamp_Device_Status__c != null order by Timestamp_Device_Status__c asc];        
            //Boolean breakIndicator = false;
            for(Integer i=0; i<apirespChildList.size()-1; i++){         
                Integer Power1 = Integer.valueOf(apirespChildList[i].PowerUptime__c);
                Integer Power2 = Integer.valueOf(apirespChildList[i+1].PowerUptime__c);
                /*while(Power2 == 0){
                    i++;
                    if(i+1 == apirespChildList.size()-1)
                        breakIndicator = true;
                    else
                        Power2 = Integer.valueOf(apirespChildList[i+1].PowerUptime__c);
                }
                if(breakIndicator)
                    Break;*/
                if(Power1 >Power2 && string.valueOf(Power1).length() > string.valueOf(Power2).length() ){ // condition satisfied - power reset occurred
                    //  System.debug('API Response '+ apirespChildList[i+1].Name + ' had power reset');
                    List<String> temp = apiRespByAsset.containsKey(assets[0].Name) ? apiRespByAsset.get(assets[0].Name) : new List<String>();
                    temp.add(apirespChildList[i+1].Name + ' - ' + apirespChildList[i+1].CreatedDate);
                    apiRespByAsset.put(assets[0].Name, temp);
                    Break;
                    //  System.debug('Assets are :' + assets[0].Name);
                }
            }
        }catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'TruePowerReset', 'extractPowerUptime', 'Exception', null, null, true);
        }
        
    }
    public void finish(Database.BatchableContext bc){
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'commodityccrm@gmail.com'};
            msg.setSubject('Assets with true power reset');
        string body = 'No Assets with true power reset';
        if(apiRespByAsset.size()>0){
            body = 'Assets with true power reset on: ' + DateTime.Now() + ' are '+ apiRespByAsset.size() + '\n';        
            for(String astName : apiRespByAsset.keySet()){
                body += astName + ' : ' + String.join(apiRespByAsset.get(astName), ',') + '\n';
            }   
        }                
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
    }
    
    /* public static Integer extractPowerUptime(String deviceStatus) {
try {
String deviceStatusString = deviceStatus.substring(1, deviceStatus.length() - 1);

List<String> keyValuePairs = deviceStatusString.split(', ');
for (String pair : keyValuePairs) {
List<String> parts = pair.split('=');
if(parts[0] == 'powerUptime'){
Integer result = Integer.valueOf(parts[1]);
return result;
}
}
} catch (Exception e) {
RedesignNL_CaptureErrors.createErrorLogs(e, 'TruePowerReset', 'extractPowerUptime', 'Exception', null, null, true);
}
return null;
}*/
    
}