@RestResource(urlMapping='/nimbeLinkProdToUAT/*')
global class nimbelinkProdToBatchAPI {

    @HttpPost global static void doPost() {
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            when 'apiresponse' { doApiResponse(); }
            when 'googleapi' { doGoogleData(); }
        }
    }
    
    public static void doApiResponse() {
        String requestBody = RestContext.request.requestBody.toString();
        List<Api_Response__c> apiList = (List<Api_Response__c>)JSON.deserialize(requestBody, List<Api_Response__c>.class);
        List<String> deviceIdList = new List<String>();
        for(Api_Response__c api : apiList) {
            deviceIdList.add(api.Device_Id__c);
            system.debug(api);
            api.Production_Created_Date__c = api.CreatedDate;
            api.Production_Name__c = api.Name;
            api.id = null;
        }
        
        Map<String, String> assMap = getasset(deviceIdList);
        for(Api_Response__c api : apiList) {
            api.asset__c = assMap.get(api.Device_Id__c);
            api.Status__c = 'New-Pending';
        }
        insert apiList;
        try {
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
        }

    }
    
    public static Map<String, String> getasset(List<String> deviceIdList) {
        Map<String, String> assetMap = new Map<String, String>();
        account acc = [select Id,name from account where name = 'Testing'];
        List<String> deviceCapIdList = new List<String>();
        List<Asset> asstlst = new List<Asset>();
        for(String st : deviceIdList) {
            String devid = st.substring(0,1).isAllUpperCase() ? (st.substring(0,1).toLowerCase()+st.substring(1)) : (st.substring(0,1).toUpperCase()+st.substring(1));
            system.debug('devid---'+devid);
            deviceCapIdList.add(devid);
        }
        List<Asset> astList = [SELECT id, Device_Id__c FROM Asset WHERE Device_Id__c in: deviceIdList or Device_Id__c in: deviceCapIdList];
        for(Asset ast : astList) {
            String t = ast.Device_Id__c.toLowerCase();
            assetMap.put(t, ast.Id);
        }
        List<String> assetLstCreated = new List<String>();
        for(String deviceId : deviceIdList) {
            String t = deviceId.toLowerCase();
            if(!assetMap.containsKey(t) && !assetLstCreated.contains(t)) {
                system.debug('deviceId--'+deviceId);
                Asset asst = new Asset();
                asst.name = deviceId;
                asst.Device_Id__c = deviceId;
                asst.Capturing_Response__c= true;
                asst.accountid = acc.id;
                assetLstCreated.add(deviceId);
                asstlst.add(asst);                
            }
        }
        insert asstlst;
        for(Asset ast : asstLst) {
            assetMap.put(ast.Device_Id__c, ast.Id);
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