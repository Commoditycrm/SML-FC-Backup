public class Chorus_googleapi {
 Public static Boolean checkarc=false;
    @InvocableMethod(label='Google API Errors Chorus')
    public static List<Api_response_childs__c> processGoogleApiErrors(List<Api_response_childs__c> arcGoogleErrorList) {
        try{
            if(arcGoogleErrorList.size()>0) {
                Map<String, Api_response__c> ApiResponseIdMap = new Map<String, Api_response__c>(); //added for 320
                for (Api_response_childs__c arc : arcGoogleErrorList) {
                    system.debug('entered value '+ arc);
                        Chorus_ArcBatch.createGoogleAPIRecords(new List<Api_response_childs__c>{arc}, arc.Asset__r.Name);
                        if(arc.Current_Location_Address__c !='Address Pending' && arc.Current_Location_Address__c != ''){
                            arc.Status__c='Chorus-New';
                            checkarc=true;
                    }
                }
             }
           } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Redesign_googleapi', 'processGoogleApiErrors', 'Exception', null, null, true);
        }     
        if(checkarc == true)
            return arcGoogleErrorList;
        else
            return null;
    }
}