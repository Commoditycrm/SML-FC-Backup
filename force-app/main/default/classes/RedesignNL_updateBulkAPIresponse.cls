public class RedesignNL_updateBulkAPIresponse implements Database.Batchable<sObject>, Database.Stateful{
    public List<Api_response__c> apiList = new List<Api_response__c>();
    public List<API_Response__c> apiResponses ;
    public Set<Id> apiResponseIds = new Set<Id>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'select id,status__c,Asset__c from APi_response_childs__c '+
            +' where Asset__r.isNew_Asset__C = true and Asset__r.pause_job__c = false and '+
            +' status__c = \'Pending\' Order by createddate asc limit 100';
        
        /*List<asset> assetlist = [select id ,name,(select id,asset__c,Timestamp_DateTime__c,api_response__c  from API_Response_Childs__r Order by Timestamp_DateTime__c ASC limit 1000 ) limit 93]*/
        
            /* apiList = [select id,status__c,Asset__c from Api_response__c where Asset__r.isnew_Asset__C = true and Asset__r.pause_job__c = false 
                   and status__c='Pending' order by Asset__c,createddate ASC limit 100];
        if(apiList.size()>0){
            for(Api_response__c api :apiList ){
                apiResponseIds.add(api.id);
            }
        }
        */
        //query = 'select id,status__c from APi_response_childs__c where API_response__c IN : apiResponseIds and status__c = \'Pending\'';
        query = 'select id,Name from Asset where isNew_Asset__c=true and pause_job__c = false';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope) {
        set<id> assetids = New set<id>();
        for(Asset ast : scope){
			assetids.add(ast.id) ;      
        }
        set<id> allAPiIds = New set<id>();
        Map<id,set<id>> APiIdmap = New Map<id,set<id>>();
        list<asset> assetlist = [select id,name,(select id,asset__c,Timestamp_DateTime__c,api_response__c  from API_Response_Childs__r where   status__c='Pending' and Timestamp_DateTime__c < 2025-01-15T00:00:00.000+0000 Order by Timestamp_DateTime__c ASC limit 1000) from Asset where id in : assetids];
            //List<Api_Response_childs__c> arclist = [select id,asset__c,Timestamp_DateTime__c,api_response__c  from API_Response_Childs__c where  asset__c= :ast.id and status__c='Pending' Order by Timestamp_DateTime__c ASC limit 1000];        
        for(asset astl : assetlist){
            if (astl.API_Response_Childs__r != null && !astl.API_Response_Childs__r.isEmpty()) {
                for(API_Response_Childs__c arc : astl.API_Response_Childs__r){
                    if(APiIdmap.containsKey(arc.asset__c)){
                        set<id> apiset = APiIdmap.get(arc.asset__c);
                        if(apiset.size()==100){
                            break;
                        }else{
                            apiset.add(arc.api_response__c);
                            APiIdmap.put(arc.asset__c,apiset);
                       	}
                    }else{
                        set<id> apisetids = new set<id>();
                        apisetids.add(arc.api_response__c);
                         APiIdmap.put(arc.asset__c,apisetids);
                    }
                    
                }
            }
        }
        for(id assetid : APiIdmap.keyset()){
            allAPiIds.addAll(APiIdmap.get(assetid));
        }
        
        if(allAPiIds.size()>0){
            List<api_response__c> apiList = [select id,status__c from APi_response__c where id IN : allAPiIds and status__c = 'Pending'];
            for(api_response__c api : apiList){
                api.status__c = 'NEW';
            }
            List<api_response_childs__c> arclst = [select id,status__c from API_response_childs__c where api_response__c IN :allAPiIds and status__c = 'Pending'];
            for(api_response_childs__c arcs : arclst){
                arcs.status__c = 'New';
            }
            update apiList;
            update arclst;
            
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
   
}