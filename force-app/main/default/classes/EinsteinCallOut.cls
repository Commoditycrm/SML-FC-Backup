public class EinsteinCallOut {
public static void makeWebserviceCallout(){
    String sessionId = BreadCrumbs_Controller.fetchUserSessionId();
        Id versionId;
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'text/xml');
    string endpt = '/services/data/v45.0/wave/datasets/'+system.label.DatasetId+'/versions';
    system.debug('endpoint---'+endpt);
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + endpt);            
        HTTPResponse resp=h.send(req);
        System.debug('response'+resp.getBody());
        Map<String,Object> res = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
        System.debug('res'+res);
        List<Object> records = (List<Object>)res.get('versions');
        Map<String,Id> dateVersionIdMap = new Map<String,Id>();
        for(Object o : records){
            Map<String,Object> obj = (Map<String, Object>)o;
            dateVersionIdMap.put((String)obj.get('createdDate'),(Id)obj.get('id'));
            list<String> datelst = new list<String>();
        	datelst.addAll(dateVersionIdMap.keySet());
            datelst.sort();
            System.debug('datelst - '+datelst);
            if(dateVersionIdMap.containsKey(datelst[datelst.size() - 1])){
            	versionId = dateVersionIdMap.get(datelst[datelst.size() - 1]);    
            }
    	}
		System.debug('versionID'+versionId);
      
    integer cnt = [select count() from Data_Configuration__c where Name = 'DatasetVersionId' limit 1];
    if(cnt > 0){
        
       Data_Configuration__c dc =[select id,Name,value__C from Data_Configuration__c where Name = 'DatasetVersionId' limit 1];
       if(dc != null){
           dc.value__C = versionId;
           update dc;
       }
        
    }
}
}