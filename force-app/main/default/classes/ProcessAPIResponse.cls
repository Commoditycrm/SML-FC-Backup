public class ProcessAPIResponse {
    
    public static void process(list<Pallet_Location_Event__e> eventlist){
        
        list<Api_Response__c> apiList = new list<Api_Response__c>();
        for(Pallet_Location_Event__e ev : eventlist){
            Api_Response__c  ap = new  Api_Response__c();
            ap.Device_Id__c = ev.Device_Id__c.toLowerCase();
          
          
          
         
            
            apiList.add(ap);
        }
        if(apiList.size()>0){
            insert apiList;  
        }
    }
}