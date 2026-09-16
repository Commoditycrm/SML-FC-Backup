@RestResource(urlMapping='/nimbeLinkProdToUAT/*')
global class nimbelinkProdToBatchAPI {

    @HttpPost global static void doPost() {
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            when 'apiresponse' { doApiResponse(); }
            when 'googleapi' { doGoogleData(); }
        }
    }
    
    public static void doApiResponse() {
        try{
        String requestBody = RestContext.request.requestBody.toString();
        List<Api_Response__c> apiList = (List<Api_Response__c>)JSON.deserialize(requestBody, List<Api_Response__c>.class);
        Map<String, String> deviceIdList = new Map<String, String>();
        for(Api_Response__c api : apiList) {
            deviceIdList.put(api.Device_Id__c, api.Api_Callouts__c);
            system.debug(api);
            api.Production_Created_Date__c = api.CreatedDate;
            api.Production_Name__c = api.Name; 
            api.id = null;
        }
        
        Map<String, Asset> assMap = getasset(deviceIdList); 
        for (Integer i = apiList.size() - 1; i >= 0; i--) {

            Api_Response__c api = apiList[i];
            Asset ast = assMap.get(api.Device_Id__c);

            if (ast == null /*|| ast.Is_Chorus_Asset__c || ast.Is_M2MD__c*/) {
                apiList.remove(i);
                continue;
            }

            api.Asset__c = ast.Id;
            api.Status__c = ast.Is_M2MD__c ? 'Chorus-New' : ast.Is_Chorus_Asset__c ? 'Chorus-New' : ast.Is_Loco_Asset__c ? 'New' : 'New-Pending';
        }
        insert apiList;
            List<Redesign_NL__mdt> redesignNLMdtList = [Select Id, DeveloperName, Capture_Child_Response__c from Redesign_NL__mdt Limit 1];
            if(redesignNLMdtList.size() > 0 && redesignNLMdtList[0].Capture_Child_Response__c == true) {
                List<String> apirRespIdList = new List<String>();
                for(Api_Response__c api : apiList) {
                    apirRespIdList.add(api.Id);
                }
                String query = 'Select Id, Incoming_Messsage__c,Asset_Summary__c from API_Response__c where Id in: apirRespIdList';
                RedesignNL_CreateAPIRespChild_Batch respbatch = new RedesignNL_CreateAPIRespChild_Batch(apirRespIdList);
                Id jobId = Database.executeBatch(respbatch, 1);
            }
        }
        catch(Exception ex) {
            System.debug('Exception in code - '+ex.getMessage());
                        RedesignNL_CaptureErrors.createErrorLogs(ex, 'nimbelinkProdToBatchAPI', 'Api sync', 'Exception', null, null, false);
        }

    }
    
    public static Map<String, Asset> getasset(Map<String, String> deviceIdListInput) {
        Map<String, Asset> assetMap = new Map<String, Asset>();
        account acc = [select Id,name from account where name = 'Testing'];
        List<String> deviceCapIdList = new List<String>();
        List<Asset> asstlst = new List<Asset>();
        for(String st : deviceIdListInput.keySet()) {
            String devid = st.substring(0,1).isAllUpperCase() ? (st.substring(0,1).toLowerCase()+st.substring(1)) : (st.substring(0,1).toUpperCase()+st.substring(1));
            system.debug('devid---'+devid);
            deviceCapIdList.add(devid);
        }
        List<Asset> astList = [SELECT id, Device_Id__c, Is_Chorus_Asset__c, Is_M2MD__c, Is_Nimbelink_Asset__c, Is_Loco_Asset__c FROM Asset WHERE Device_Id__c in: deviceIdListInput.keySet() or Device_Id__c in: deviceCapIdList];
        for(Asset ast : astList) {
            String t = ast.Device_Id__c.toLowerCase();
            assetMap.put(t, ast);
        }
        List<String> assetLstCreated = new List<String>();
        for(String deviceId : deviceIdListInput.keySet()) {
            String t = deviceId.toLowerCase();
            if(!assetMap.containsKey(t) && !assetLstCreated.contains(t)) {
                system.debug('deviceId--'+deviceId);
                Asset asst = new Asset();
                asst.name = deviceId;
                asst.Device_Id__c = deviceId;
                asst.Capturing_Response__c= true;
                asst.Is_M2MD__c = deviceIdListInput.get(deviceId) == 'M2MD' ? true : false;
                asst.Is_Chorus_Asset__c = deviceIdListInput.get(deviceId) == 'Chorus' ? true : false;
                asst.Is_Nimbelink_Asset__c = deviceIdListInput.get(deviceId) == 'Nimbelink' ? true : false;
                asst.Is_Loco_Asset__c = deviceIdListInput.get(deviceId) == 'System Loco' ? true : false;
                asst.accountid = acc.id;
                assetLstCreated.add(deviceId);
                asstlst.add(asst);                
            }
        }
        insert asstlst;
        for(Asset ast : asstLst) {
            assetMap.put(ast.Device_Id__c, ast);
        }
        return assetMap;
    }
    
    public static void doGoogleData() {
        String  requestBody = RestContext.request.requestBody.toString();
        List<Google_API_Data__c> apiList = (List<Google_API_Data__c>)JSON.deserialize(requestBody, List<Google_API_Data__c>.class);
        for(Google_API_Data__c api : apiList) {
            system.debug(api);
            api.Id = null;
        }
        insert apiList;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('SUCCESS');
    }
}