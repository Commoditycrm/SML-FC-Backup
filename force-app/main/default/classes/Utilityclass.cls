/**
* @author -- Gokulprasath
* @date -- 02/20/2019
* @description -- This Class will provide support to all apex classes for utility purpose.
**/

public class Utilityclass {
    
    Public Static boolean allow = true;
    public static boolean enter = true;
    public static boolean dwelldays = true;
    Public Static boolean allowInventory = false;
    
    //This method help us to stop recursive trigger in asset object
    
    public static void stopTrigger(){
        allow = false;
    }
    public static void stoptrigger1(){
        enter = false;
    }
    
    // This method help us to stop recursive trigger in asset object 
    
    public static boolean canIRun(){
        return allow;
    }
    public static boolean canIEnter(){
        return enter;
    }
    
    public static void inventorycheck(){
        allowInventory = true;
    }
    
    public static boolean executeInventory(){
        return allowInventory;
    }
    //This method will send the email notification along with error details when there is an error in apex execution by any user.
    public static void sendemailtoccrm(exception ex,string assetid,string response){
        
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'commodityccrm@gmail.com' };
            msg.setSubject('Error Occured while performing Operation');
        string body = 'User/Org details:'+ userinfo.getUserId()+'/'+userinfo.getOrganizationId()+ '\n \n';
        body += 'Exception Type :'+ ex.getTypeName()+ '\n \n';
        body +='Error message :'+ex.getMessage()+ '\n \n';
        body +='stack Trace :'+ex.getStackTraceString()+ '\n \n';
        body +='Error is on :'+ex.getLineNumber()+ '\n \n';
        body +='assetid is :'+assetid+ '\n \n';
        body +='response is :'+response;
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        
        
    }
    
    
    public static void sendemailtoadmin(exception ex){
        
        messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.setToAddresses(toaddress());
        msg.setSubject('Error Occured while performing Operation');
        string body = 'User/Org details:'+ userinfo.getUserId()+'/'+userinfo.getOrganizationId()+ '\n \n';
        body += 'Exception Type :'+ ex.getTypeName()+ '\n \n';
        body +='Error message :'+ex.getMessage()+ '\n \n';
        body +='stack Trace :'+ex.getStackTraceString()+ '\n \n';
        body +='Error is on :'+ex.getLineNumber();
        msg.setPlainTextBody(body);
       // Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        
        
    }
    
    // This method will fetch the develpers email id from public group
    
    public static list<string> toaddress(){
        id grpid;
        set<id> usrids = new set<id>();
        list<string> emaillist = new list<string>();
        /*for(group gr : [SELECT id, Name FROM Group where developername = 'developers']){
            grpid = gr.id;    
        }
        for(groupmember gm : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember where GroupId =: grpid ]){
            usrids.add(gm.UserOrGroupId);    
        }
        for(user usr : [select id,email from user where id IN : usrids]){
            emaillist.add(usr.email);
        }*/
        return emaillist;
    }
    
    // Method overloading for 2.0 classes
    public static string generatetoken(){
        string username1;
        string Password1;
        assetConfigUsername__mdt OwnedDeviceMdt = [SELECT Password__c, UserName__c, Id FROM assetConfigUsername__mdt Where Unique_Id__c = 'Leased'];
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
    
    public static string generatetoken(String DeviceOwnership){
        string username1;
        string Password1;
        List<assetConfigUsername__mdt> OwnedDeviceMdt = [SELECT Password__c, UserName__c, Id FROM assetConfigUsername__mdt Where Unique_Id__c = :DeviceOwnership];
        if(OwnedDeviceMdt.isEmpty()){
            return '';
        }
        username1 = OwnedDeviceMdt[0].UserName__c;
        Password1 = OwnedDeviceMdt[0].Password__c;
        
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
    public static string calloutActivateDeactivate(list<string>deviceIDs, string status){
        system.debug('str--'+deviceIDs);
        String msg;
        list<string> strlist = new list<string>();
        for(Asset Ast : [select id,Name,Device_Id__c from Asset where Name IN : deviceIDs]){
            strlist.add(Ast.Device_Id__c);
            system.debug('deviceids'+strlist);
        }
        string loopval = '';
        if(strlist.size()>1){
            Integer i = 0;
            for(String str : strlist) {
                if(i == 0) {
                    loopval = '"' + str + '"';
                } else {
                    loopval += ',"' + str + '"';
                }
                i++;
            }     
        } else if(strlist.size() == 1) {
            loopval = '"' + strlist[0] + '"';     
        }
        
        
        try{
            
            string token = generatetoken('deactivation');
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
            if(res1.getStatusCode() == 200){
                msg = 'Your Request has been Processed Successfully !';
            }else{
                msg = 'Statuscode: '+ res1.getStatusCode() +'\n\n Status: '+ res1.getStatus()+'\n\n Status Body: \n' +res1.getBody(); 
            }
        }
        catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);
        }
        return msg;
    }
    
    
    public static boolean caldistance(id accid, decimal lat1,decimal lng1){
        boolean res = false;
        double result;
        decimal result1;
        decimal lat;
        decimal lng;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        if(accid != null)
            accids.add(accid);
        for(account acc : [select id,shippinglatitude,parentid,GeoFence_Radius_in_Miles__c,shippinglongitude  FROM Account]){
            accmap.put(acc.id,acc);    
        }
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accid]){ 
            if(!String.isBlank(rc.Source_Account__c)){
                accids.add(rc.Source_Account__c);
            }
            if(!String.isBlank(rc.Related_To__c)){
                accids.add(rc.Related_To__c);
            } 
        }
        
        for(id acc :accids ){
            system.debug('acc--'+acc);
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
            }
            if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result < accmap.get(acc).GeoFence_Radius_in_Miles__c){
                res = true;
                break;  
            }
            
        }    
        
        system.debug('result--'+result);
        return res;
    }
    
    public static string currentLocName(id accid, decimal lat1,decimal lng1){
        string res;
        double result;
        decimal lat;
        decimal lng;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        if(accid != null)
            accids.add(accid);
        
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accid]){
            
            accids.add(rc.Source_Account__c);
            accids.add(rc.Related_To__c);
        }
        for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
            accmap.put(acc.id,acc);
        }
        
        for(id acc :accids ){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
                if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                    
                    res = accmap.get(acc).name;
                    break; 
                }
            }
            
        }    
        //  for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c != null]){
        for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){
            
            Location loc1 = Location.newInstance(lat1,lng1);
            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
            result = Location.getDistance(loc1, loc2, 'mi');
            system.debug('result--'+ result);
            if(result < mdt.Diameter__c){
                res = mdt.Current_Location__c;  
                break;  
            }  
        }
        system.debug('result--'+res);
        
        return res;
    }
    public static Map<String,String> currentLocDetail(id accid, decimal lat1,decimal lng1){
        Map<String,String> res = new Map<String,String>();
        double result;
        decimal lat;
        decimal lng;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        if(accid != null)
            accids.add(accid);
        
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accid]){
            
            accids.add(rc.Source_Account__c);
            accids.add(rc.Related_To__c);
        }
        for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
            accmap.put(acc.id,acc);    
        }
        
        for(id acc :accids ){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
                if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                    
                    res.put('locName', accmap.get(acc).name);
                    res.put('locId', accmap.get(acc).Id);
                    break;  
                }
            }
            
        }    
        //  for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c != null]){
        for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){
            
            Location loc1 = Location.newInstance(lat1,lng1);
            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
            result = Location.getDistance(loc1, loc2, 'mi');
            system.debug('result--'+ result);
            if(result < mdt.Diameter__c){
                res.put('locName', mdt.Current_Location__c);
                res.put('locId', mdt.Current_Location_Id__c );
                break;  
            }  
        }
        system.debug('result--'+res);
        
        return res;
    }
    public static Map<String,String> currentLocDetail(set<id> accids, decimal lat1,decimal lng1, List<account> accList, List<Nested_Geofence__mdt> geoFenceList) {
        Map<String,String> res = new Map<String,String>();
        double result;
        decimal lat;
        decimal lng;
        map<id,account> accmap = new map<id,account>();
        
        for(account acc : accList){
            accmap.put(acc.id,acc);    
        }
        
        for(id acc :accids ){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
                if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                    
                    res.put('locName', accmap.get(acc).name);
                    res.put('locId', accmap.get(acc).Id);
                    break;  
                }
            }
            
        }    
        //  for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c != null]){
        for (Nested_Geofence__mdt mdt: geoFenceList) {
            
            Location loc1 = Location.newInstance(lat1,lng1);
            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
            result = Location.getDistance(loc1, loc2, 'mi');
            system.debug('result--'+ result);
            if(result < mdt.Diameter__c){
                res.put('locName', mdt.Current_Location__c);
                res.put('locId', mdt.Current_Location_Id__c );
                break;  
            }  
        }
        system.debug('result--'+res);
        
        return res;
    }
    public static string currentLocId(id accid, decimal lat1,decimal lng1){
        string res;
        double result;
        decimal lat;
        decimal lng;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        if(accid != null)
            accids.add(accid);
        
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accid]){
            
            accids.add(rc.Source_Account__c);
            accids.add(rc.Related_To__c);
        }
        for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
            accmap.put(acc.id,acc);    
        }
        
        for(id acc :accids ){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
                if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                    
                    res = accmap.get(acc).id;
                    break;  
                }
            }
            
        }
        return res;
    }      
    
    
}