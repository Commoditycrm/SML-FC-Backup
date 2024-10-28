public class ProcessAPIResponse {
	
    public static void process(list<Pallet_Location_Event__e> eventlist){
    	
        list<Api_Response__c> apiList = new list<Api_Response__c>();
        for(Pallet_Location_Event__e ev : eventlist){
        	Api_Response__c  ap = new  Api_Response__c();
         	ap.Access_Point_Id__c = ev.Access_Point_Id__c;
            ap.Access_Point_Type__c = ev.Access_Point_Id__c;
            ap.Area_Id__c = ev.Area_Id__c;
           	ap.Area_Name__c = ev.Area_Name__c;
            ap.Asset_Group_Id__c = ev.Asset_Group_Id__c;
            ap.Asset_Product__c = ev.Asset_Product__c;
            ap.Battery_Level__c = ev.Battery_Level__c;
            ap.Device_Id__c = ev.Device_Id__c.toLowerCase();
            ap.Field1__c =ev.Field1__c;
            ap.Field2__c = ev.Field2__c;
            ap.Humidity__c = ev.Humidity__c;
            ap.Latitude__c = ev.Latitude__c;
            ap.Longitude__c = ev.Longitude__c;
            ap.Msg_Type__c = ev.Msg_Type__c;
            ap.Needs_Repair__c = ev.Needs_Repair__c;
            ap.Position_Source__c = ev.Position_Source__c;
            ap.Ready_for_Pickup__c = ev.Ready_for_Pickup__c;
            ap.Shock_Count__c = ev.Shock_Count__c;
            ap.Shock_Max__c = ev.Shock_Max__c;
            ap.Shock_Max_Time__c = ev.Shock_Max_Time__c;
            ap.Shock_Threshold__c = ev.Shock_Threshold__c;
            ap.Temperature__c = ev.Temperature__c;
            ap.Zone_Id__c =  ev.Zone_Id__c;
            ap.Zone_Name__c  = ev.Zone_Name__c;
            ap.Last_Connected__c = ev.Last_Connected__c;
            apiList.add(ap);
        }
        if(apiList.size()>0){
        	insert apiList;  
        }
    }
}