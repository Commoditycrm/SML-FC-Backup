public class AssetListTriggerHelper{
    
    @future(callout=true)
    public static void getListViewQuery(string recId){
        
        List<Asset_List__c> assetlist = [select Id,List_view_Name__c,List_View_Query__c,List_View_Developer_Name__c from Asset_List__c Where Id =: recId AND List_view_Name__c != null];
        if(assetlist != null) {            
             
            List<ListView> lv = [select Id, Name, DeveloperName FROM ListView Where SobjectType = 'asset' 
                                      and name =: assetlist[0].List_view_Name__c order by createddate desc limit 1];     
            system.Debug('test'+lv);
            string selListViewId = lv[0].Id;
            
            string objectName = 'asset';
            HttpRequest req = new HttpRequest();
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String endPoinURL = baseUrl+'/services/data/v50.0/sobjects/'+ objectName +'/listviews/'+ selListViewId +'/describe';
            req.setEndpoint(endPoinURL);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res;
            String resBody;
            
            if(!Test.isRunningTest()){
                req.setHeader('Authorization', 'Bearer ' + UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionId));
            
                res = http.send(req);
                resBody = res.getBody();
            }else {
                resBody  = '{ "query": "SELECT Name,  AccountId FROM Asset WHERE Rack_Type__c != \'A-Frame Rack\' AND Account_Unique_Id__c = A-000003 ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST", "relatedEntityId": null, "scope": "everything", "scopeEntityId": null, "sobjectType": "Asset" }';
            }
            
            if(Test.isRunningTest() || res.getStatusCode() == 200 ){            
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(resBody);     
                String query = (String) tokenResponse.get('query');
                assetlist[0].List_View_Query__c = query.toLowerCase().substringAfter('where');
                assetlist[0].List_View_Developer_Name__c = lv[0].DeveloperName;
                update assetlist;
            }
        }
    }
}