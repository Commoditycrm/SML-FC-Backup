@RestResource(urlMapping='/ProcessData/*')
global with sharing class ProcessData_Ctrl {
    
    global Integer listSize = 100;
    
    @HttpPost
    global static string parseresponse() {
        Map<string,Map<String,Object>> results = new map<string,Map<String,Object>>();
        Api_Response__c ar = new Api_Response__c();
        Set<string> astlist = new Set<string>();
        try{
            String requestBody = RestContext.request.requestBody.toString();
            
            ar.check_class__c = 'Process Data';
            ar.Status__c = 'CardinalNew';
            insert ar;
            
            List<Object> lst_JsonParse = new List<Object>();
            
            if(requestBody != null) {
                lst_JsonParse = (List<object>)Json.deserializeUntyped(requestBody);    
            }
            Map<Integer, List<Object>> jsonParseLstMap = new Map<Integer, List<Object>>();
            Map<String, Object> customer = new Map<String, Object>();
                for (Object instance :lst_JsonParse){
                    customer = (Map<String,Object>)instance;
                    string devID;
                    
                    if(Customer.containskey('DeviceID'))
                    {
                        devID = string.valueof(Customer.get('DeviceID'));
                        astlist.add(devID);
                    }
                    if(devID != null){
                        results.put(devID,customer);
                    }
                }
            List<Cardinal_Response__c> crdList = new List<Cardinal_Response__c>();
            
            Integer mapKey = 0;
            
            for (Object instance : lst_JsonParse) {
                List<Object> objList;
                if(jsonParseLstMap.containsKey(mapKey))
                    objList = jsonParseLstMap.get(mapKey);
                else
                    objList = new List<Object>();
                objList.add(instance);
                jsonParseLstMap.put(mapKey, objList);
                if(objList.size() >= 100)
                    mapKey++;
            }
            for (Integer key :jsonParseLstMap.keySet()) {
                List<Object> instanceLst =  jsonParseLstMap.get(key);
                Cardinal_Response__c crd = new Cardinal_Response__c();
                crd.Status__c = 'New';
                crd.Cardinal_Response_1__c = JSON.serialize(instanceLst);
                crd.Response_Info__c = 'Device Count - '+instanceLst.size();
                crd.Response_Sequence__c = key;
                crd.Api_Response__c = ar.Id;
                crdList.add(crd);
            }
            if(crdList.size() > 0){
	            insert crdList;
            }
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'ProcessData_Ctrl', 'parseRequestBody', 'Exception', null, null, true);            
            if(ar.Id != null) {
                ar.Status__c = 'Error';
                update ar;
            }
        }
        string message = astlist.size()+ ' tags processed successfully';   
        return message;
    }
}