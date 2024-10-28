/*
* Class Name: Redesign_googleapi
* Created By: Sandeep Tripati
* Description: This class is make Google API callout for ARC records again when the status is google API error
* Modified Date  Modified By  		Last Change
*/
public class Redesign_googleapi {
    Public static Boolean checkarc=false;
    @InvocableMethod(label='Google API Errors')
    public static List<Api_response_childs__c> processGoogleApiErrors(List<Api_response_childs__c> arcGoogleErrorList) {
        try{
            if(arcGoogleErrorList.size()>0) {
                Map<String, Api_response__c> ApiResponseIdMap = new Map<String, Api_response__c>(); //added for 320
                for (Api_response_childs__c arc : arcGoogleErrorList) {
                    system.debug('entered value '+ arc);
                    RedesignNL_Controller.createGoogleAPIRecords(new List<Api_response_childs__c>{arc}, arc.Asset__r.Name);
                    if(arc.Current_Location_Address__c !='Address not in Google API data' || arc.Current_Location_Address__c != ''){
                        arc.Status__c='New';
                        checkarc=true;
                        //Changes for 320 - API Response Status update from pending to new when google api response processes start
                       
                    }
                }
             }
            
            //Murali:We have to Query the API response for arc and update the Status as New
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'Redesign_googleapi', 'processGoogleApiErrors', 'Exception', null, null, true);
        }     
        if(checkarc == true)
            return arcGoogleErrorList;
        else
            return null;
    }
}