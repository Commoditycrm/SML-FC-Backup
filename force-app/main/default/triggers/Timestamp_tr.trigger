trigger Timestamp_tr on Asset_History_custom__c (before insert,before update) {
    
    for(Asset_History_custom__c asth:trigger.new){
        
        TimeZone tz = UserInfo.getTimeZone();
        system.debug(tz.getDisplayName());  
        if(tz.getDisplayName().contains('(GMT-05:00)')){
            if(asth.Start_Time__c != null)
                asth.Start_Time_TZ__c =string.valueof((asth.Start_Time__c - (5/24)));
            if(asth.End_Time__c != null)
                asth.End_Time_TZ__c =string.valueof((asth.End_Time__c - (5/24)));
            
        } else if(tz.getDisplayName().contains('(GMT-06:00)')){
            if(asth.Start_Time__c != null)
                asth.Start_Time_TZ__c =string.valueof((asth.Start_Time__c - (6/24)));
            if(asth.End_Time__c != null)
                asth.End_Time_TZ__c =string.valueof((asth.End_Time__c - (6/24)));
        }
        system.debug('ast--'+asth);
    }
}