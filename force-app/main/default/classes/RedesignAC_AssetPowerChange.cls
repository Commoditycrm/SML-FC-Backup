public class RedesignAC_AssetPowerChange {
	 @auraenabled
    public static String ForActivation(list<string> deviceIDs,string status,Id AccountID){
        String response = '';
        Account acc = [Select Id,Device_Ownership__c,Account_ID__c from Account where Id =:AccountID];
        string token = generatetoken(acc);
        list<string> deviceIdslist = new list<string>();
        for(string st : deviceIDs){
            st = st.remove(' ');
         	deviceIdslist = st.split(';');
            system.debug('called : '+ st);
        }
        system.debug('called'+ deviceIdslist);    
      // HttpResponse resp =calloutActivateDeactivate(deviceIdslist,'activate',token);
      // response = resp.getStatusCode() +' '+ resp.getStatus()+' '+ resp.getBody();
       return token +' '+ deviceIdslist;
        
    }
    
    //Generate Token
    public static string generatetoken(Account acc){
        string username1;
        string Password1;
        assetConfigUsername__mdt OwnedDeviceMdt = new assetConfigUsername__mdt();
        if(acc.Device_Ownership__c == 'Owned'){
        OwnedDeviceMdt = [SELECT Password__c, UserName__c, Id FROM assetConfigUsername__mdt Where Unique_Id__c = :acc.Account_ID__c];
        }
        else{
            OwnedDeviceMdt = [SELECT Password__c, UserName__c, Id FROM assetConfigUsername__mdt Where Unique_Id__c = 'Leased'];
        }
            username1 = OwnedDeviceMdt.UserName__c;
            Password1 = OwnedDeviceMdt.Password__c;
        
        system.debug('entering token');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('content-type','application/json');
        req.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34'); 
        string obj = '{"username": "' + username1 + '","password": "' + Password1 + '"}';
        req.setBody(obj);
        string endpt = 'https://api.iot.nimbelink.net/v1/auth';
        system.debug(endpt);    
        req.setEndpoint(endpt);
        HttpResponse res;
        system.debug('httpres'+res);
        if(!test.isRunningTest())
          res = h.send(req);
        string token;
        if(res != null){
            map<string,object> tokenobj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            token = (string)tokenobj.get('token');
        }
        
        return token;
    }
    
    //Making the Action
    public static HttpResponse calloutActivateDeactivate(list<string>deviceIDs, string status,String Token){
        system.debug('str--'+deviceIDs);
        HttpResponse resp = new HttpResponse();
        list<string> strlist = new list<string>();
        for(Asset Ast : [select id,Name,Device_Id__c from Asset where Name IN : deviceIDs]){
            strlist.add(Ast.Device_Id__c);
            system.debug('deviceids'+strlist);
        }
        string loopval = '';
        if(strlist.size()>1){
            for(string str : strlist){
                
                if(loopval == ''){
                    loopval = '"'+str+'",';    
                }else{
                    loopval += '"'+str+'"'; 
                }
            }     
        }else if (strlist.size() == 1){
            loopval = strlist[0];    
        }
        
        
        try{
            system.debug(token);
			string authorize = 'Bearer'+' '+ token;
            system.debug(authorize);
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setTimeout(60000);
            req1.setMethod('POST');
            req1.setHeader('content-type','application/json');
            req1.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34'); 
            req1.setHeader('Authorization', authorize); 
            string endpt1;
            if(status == 'Activate'){
                endpt1 = 'https://api.iot.nimbelink.net/v1/devices/activate';    
            }
            if(status == 'deactivate'){
                endpt1 = 'https://api.iot.nimbelink.net/v1/devices/deactivate';
            }
            
            system.debug(endpt1);    
            req1.setEndpoint(endpt1);
            
            //string loopval; 
            
            string resbody = '{"devices": ['+loopval+ ']}';
            system.debug(resbody);
            req1.setBody(resbody);
            system.debug(req1);
            HttpResponse res1;
            res1= h1.send(req1);
            system.debug('res--'+res1.getBody());
            resp = res1;
        }
        catch(exception ex){
           RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignAC_AssetPowerChange', 'calloutActivateDeactivate', 'Exception', null, null, false);
        }
        return resp;
    }
}