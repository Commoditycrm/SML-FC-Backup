/*
* Class Name: RedesignNL_CaptureErrors
* Created By: Jayesh Khatter
* Description: This class is used to store records in Debug Log Regarding Error's in 3.0 Classes
* Modified Date  Modified By  		Last Change
* Jan 16, 2024   Murali Krishna    uncommented the mail method
* Jan 17, 2024   Prithivi          Removed the line no 17 because it has been duplicated 2 Error_type__c
*/
public class RedesignNL_CaptureErrors {
    
    public static Debug_Logs__c createErrorLogs(Exception ex, String className, String methodName, String errorType, String deviceId, String requestBody, Boolean sendEmail) {
        Debug_Logs__c debugLog = new Debug_Logs__c();
        if(errorType == null)
            debugLog.Error_Type__c = 'Exception';	
        else
            debugLog.Error_Type__c = errorType;	
        debugLog.Line_Number__c = ex.getLineNumber();
        debugLog.Error_Message__c = ex.getMessage();
        debugLog.Error_Type_Name__c = ex.getTypeName();
        debugLog.Method_Name__c = methodName;
        debugLog.Class_Name__c = className;
        debugLog.Error_Cause__c = String.valueof(ex.getCause());
        debugLog.Stack_Trace__c = ex.getStackTraceString();
        debugLog.Asset__c = getAssetId(deviceId);
        debugLog.Asset_Device_ID__c = deviceId;
        if(debugLog.Error_Type__c == 'DML Error') {
        }
        else if(debugLog.Error_Type__c == 'API Error') {
            debugLog.Incoming_Message__c = requestBody;
        }
        System.debug('Exception Debug=\n ErrorType:'+errorType+'\nClassName:'+ className+'\nMethod:'+methodName+'\nLine Number:'+
                     debugLog.Line_Number__c+'\nError Message:'+debugLog.Error_Message__c+'\nDevice Id:'+deviceId);
        insert debugLog;
        if(sendEmail == true) {
            String emailString = 'Error Occurred - \n'+
                'Error Type    : '+debugLog.Error_Type__c + '\n'+
                'Error Name    : '+debugLog.Error_Type_Name__c + '\n'+
                'Class Name    : '+debugLog.Class_Name__c + '\n'+
                'Method Name   : '+debugLog.Method_Name__c + '\n'+
                'Line Number   : '+debugLog.Line_Number__c + '\n'+
                'Error Message : '+debugLog.Error_Message__c + '\n'+
                'Stack Trace   : '+debugLog.Stack_Trace__c + '\n'+
                'Asset         : '+debugLog.Asset__c + '\n'+
                'Device Id     : '+debugLog.Asset_Device_ID__c;
            //RedesignNL_Helper.sendEmail(emailString);           
            //Write send email code
        }
        return debugLog;
    }
    public static void createDMLErrorLogs(List<Database.Error> errLst, Debug_Logs__c debugLogParent, String deviceId) {
        Debug_Logs__c debugLog = new Debug_Logs__c();
        debugLog.Error_Type__c = 'DML Error';
        debugLog.Parent_Debug_Log__c = debugLogParent.Id;
        String errorMessage = '';
        if(errLst != null) {
            for(Database.Error dbe : errLst) {
                errorMessage += dbe.getMessage() + '/n';
            }
        }
        debugLog.Error_Message__c = errorMessage;
        debugLog.Method_Name__c = debugLogParent.Method_Name__c;
        debugLog.Class_Name__c = debugLogParent.Class_Name__c;
        debugLog.Stack_Trace__c = debugLogParent.Stack_Trace__c;
        debugLog.Asset__c = getAssetId(deviceId);
        debugLog.Asset_Device_ID__c = deviceId;
        
        insert debugLog;
    }
    
    public static void createGoogleErrorLogs(String className, String methodName, String body, Decimal statusCode, String status, String deviceId, String latitude, String longitude) {
        Debug_Logs__c debugLog = new Debug_Logs__c();
        debugLog.Error_Type__c = 'Google API Error';
        debugLog.Method_Name__c = methodName;
        debugLog.Class_Name__c = className;
        debugLog.Google_Response_Body__c = body;
        debugLog.Google_Response_Code__c = statusCode;
        debugLog.Google_Response_Status__c = status;
        debugLog.Latitude__c = latitude;
        debugLog.Longitude__c = longitude;
        debugLog.Asset_Device_ID__c = deviceId;
        debugLog.Asset__c = getAssetId(deviceId);
        
        insert debugLog;
    }
    
    public static String getAssetId(String deviceId) {
        if(String.isNotBlank(deviceId)) {
            List<Asset> assetList = [Select Id, Name from Asset where Device_ID__c = :deviceId LIMIT 1];
            if(assetList.size() > 0)
                return assetList[0].Id;            
        }
        return null;
    }
}