@RestResource(urlMapping='/qrScanner/*')

global without sharing class QrScanner_Controller {
    
@HttpGet
     global static List<Asset> parseResponse() {
         String deviceId = RestContext.request.params.get('deviceId');
        
        // Check if deviceId is present and return it
        if (deviceId != null) {
            List<Asset> astList = [Select Name, Action_needed__c, Last_connected__c, battery_Voltage__c, est_Batterycalculate__c from Asset where device_id__c = :deviceId];
            return astList;
        } else {
            // Return a message if deviceId is not found
            return null;
        }
    }
}