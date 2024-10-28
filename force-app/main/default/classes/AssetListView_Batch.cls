/*
This batch job will be used to create custom list view records for newly created stadard list view on asset object.

*/
global class AssetListView_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    
    Map<String, Asset_List__c> customListViewMap;
    Map<String, ListView> stdListViewMap;
    String sessionId = null;
    
    public AssetListView_Batch(){
        customListViewMap = new Map<String, Asset_List__c>();
        stdListViewMap    = new Map<String, ListView>();
        
        for(Asset_List__c lv : [select Id, List_View_Query__c, List_View_Developer_Name__c, List_view_Name__c from Asset_List__c]){
            customListViewMap.put(lv.List_View_Developer_Name__c, lv);//custom object 
        }        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType = \'Asset\' AND DeveloperName != \'All_Asset\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ListView> scope){
        
        if(!Test.isRunningTest() && sessionId == null){
            sessionId = UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionId);
        }
        
        List<Asset_List__c> assetlistViews = new List<Asset_List__c>();
        for(ListView lv : scope){
            stdListViewMap.put(lv.DeveloperName, lv);// standard object
            Asset_List__c obj = new Asset_List__c(List_view_Name__c=lv.Name, List_View_Developer_Name__c=lv.DeveloperName);
            obj.List_View_Query__c = fetchListViewSoql(lv.Id, sessionId);
            
            if(customListViewMap.containsKey(lv.DeveloperName) && customListViewMap.get(lv.DeveloperName).List_View_Query__c != obj.List_View_Query__c ){
                obj.Id = customListViewMap.get(lv.DeveloperName).Id;
                assetlistViews.add(obj);
            }else {
                assetlistViews.add(obj);
            }
        }
        
        if(!assetlistViews.isEmpty()){
            upsert assetlistViews;
        }
    }
    
    global void finish(Database.BatchableContext bC){
        List<Asset_List__c> delAssetListViews = new List<Asset_List__c>();
        for(Asset_List__c lv : customListViewMap.Values()){
            if(!stdListViewMap.containsKey(lv.List_View_Developer_Name__c)){
                delAssetListViews.add(lv);
            }
        }
        
        if(!delAssetListViews.isEmpty()){
            delete delAssetListViews;
        }
    }
    
    private String fetchListViewSoql(String lvId, String sessionId){
        String qry = null;
        
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v50.0/sobjects/asset/listviews/'+ lvId +'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res;
        String resBody;
        
        if(!Test.isRunningTest()){
            req.setHeader('Authorization', 'Bearer ' + sessionId);
            
            res = http.send(req);
            resBody = res.getBody();
        }else {
            resBody  = '{ "query": "SELECT Name,  AccountId FROM Asset WHERE Account_Unique_Id__c = A-000003", "relatedEntityId": null, "scope": "everything", "scopeEntityId": null, "sobjectType": "Asset" }';
        }
        
        if(Test.isRunningTest() || res.getStatusCode() == 200 ){            
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(resBody);     
            String query = (String) tokenResponse.get('query');
            qry = query.toLowerCase().substringAfter('where');
        }
        
        return qry;
    }
    
    // ------------------------------------- For Scheduler ----------------------------------------------
    global void execute(SchedulableContext sc){
        database.executebatch(new AssetListView_Batch(), 40);
    }
}