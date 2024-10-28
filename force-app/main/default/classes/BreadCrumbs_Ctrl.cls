public with sharing class BreadCrumbs_Ctrl {
     @Auraenabled
    public static user getLanguage(){
        return [SELECT Id, Name, Latitude, Longitude,Profile.Name, LanguageLocaleKey  FROM User where id = : UserInfo.getUserId() limit 1];
    }
    @auraenabled
    public static list<Asset_history_custom__c> asthis(Date startdate,Date enddate,id recordid){
        DateTime StartDate1 = datetime.newInstance(startdate, Time.newInstance(0,0,0,0));
        
        DateTime EndDate1 = datetime.newInstance(enddate, Time.newInstance(23,59,59,59));
        //  system.debug('sttime--'+StartDate1);
        // system.debug('EndDate1--'+EndDate1);
        //       system.debug('EndDate1--'+recordid);
        
        list<Asset_history_custom__c>asthistory =[select id,name,RecordTypeId,Latitude__c,Asset_Type__c,Current_Location_Address__c,Longitude__c,Asset__c,Asset_Account__c,Asset_Name__c,Start_Time__c,End_Time__c,Location__c,Asset_Customer_ID__c,Start_Time_TZ__c,End_Time_TZ__c,End_Time_12_Hours__c,Start_Time_12_Hours__c,Current_Location__r.ShippingLatitude, Current_Location__r.ShippingLongitude from Asset_History_custom__c where RecordTypeId=:Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Location').getRecordTypeId() and Asset__c=:recordid AND (
            (Start_Time__c >:StartDate1 AND End_Time__c <:EndDate1 AND End_Time__c >:StartDate1 AND Start_Time__c <:EndDate1 ) OR 
            (Start_Time__c >:StartDate1 AND End_Time__c >:EndDate1 AND End_Time__c >:StartDate1 AND Start_Time__c <:EndDate1 ) OR
            (Start_Time__c <:StartDate1 AND End_Time__c <:EndDate1 AND End_Time__c >:StartDate1 AND Start_Time__c <:EndDate1) OR
            (Start_Time__c <:StartDate1 AND End_Time__c >:EndDate1 AND End_Time__c >:StartDate1 AND Start_Time__c <:EndDate1)) order by Start_Time__c asc ];
        // System.debug('Assethistory--'+asthistory[0].Asset_Type__c);
        for(Asset_history_custom__c asthis:asthistory){
            string name2=asthis.Name;
            string idd=asthis.Id;
            decimal iiiii=asthis.Latitude__c;
            // system.debug('name'+name2+'  '+idd+'  '+iiiii);
        }
        return asthistory;
    }
    
    
}