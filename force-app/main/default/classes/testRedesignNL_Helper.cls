@isTest
public class testRedesignNL_Helper {
    @isTest
    public static void testRestMethods() {
          RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Location' LIMIT 1];
      Test.startTest();
       Id arcLoc = RedesignNl_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
       Id arcTemp = RedesignNl_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcTemperatureRecordtype);
       Id arcEvent = RedesignNl_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcEventsRecordtype);
       Id ahcLoc = RedesignNl_Helper.getAHCRecTypes(RedesignNL_Helper.AHCLocationRecordtype);
       Id ahcEvent = RedesignNl_Helper.getAHCRecTypes(RedesignNL_Helper.AHCEventsRecordtype);
       Id ahcTemp = RedesignNl_Helper.getAHCRecTypes(RedesignNL_Helper.AHCTemperatureRecordtype);
       Id ahcDwell = RedesignNl_Helper.getAHCRecTypes(RedesignNL_Helper.AHCDwellRecordtype); 
       Redesign_NL__mdt rdc = RedesignNl_Helper.getRedesignMetadata('Default');
        RedesignNl_Helper.sendemail('Testclass');
        List<String> failureMsgs= new List<String>();
        failureMsgs.add('error');
        Batch_Data_Custom__c bdc = RedesignNl_Helper.createBatchDataCustom(null, null, 'batchName', System.now(), failureMsgs, 1, 'Completed', 1);
        Test.stopTest();
    }
     @isTest
    static void CaptureError(){
        Exception ex = new System.MathException();
        ex.setMessage('my message');
        Debug_Logs__c deb = RedesignNL_CaptureErrors.createErrorLogs(ex, 'className', 'methodName', 'API Error', 'deviceId', 'requestBody', true);
        RedesignNL_CaptureErrors.createGoogleErrorLogs('className', 'methodName', 'body', 200, 'ok', 'deviceId', 'latitude', 'longitude');
        RedesignNL_CaptureErrors.createDMLErrorLogs(null, deb, 'deviceId');
    }
}