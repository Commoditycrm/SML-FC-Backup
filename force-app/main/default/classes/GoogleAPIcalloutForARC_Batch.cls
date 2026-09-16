public class GoogleAPIcalloutForARC_Batch implements Database.Batchable<sObject>,Database.stateFul, Database.AllowsCallouts{
    List<API_Response_Childs__c> arcList = New List<API_Response_Childs__c> (); //= [select Id, OwnerId,asset__r.name, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, API_Response_ID__c, Accuracy_meters__c, Alt__c, Api_Response__c, Asset_History__c, Asset__c, Battery__c, CurrentLocationId__c, Current_Location_Address__c, EstBattPct__c, Event_Name__c, Facility_Location__c, HaccRank__c, Latitude__c, Location__c, Longitude__c, Message_Type__c, Network__c, PowerUptime__c, Relative_Humidity__c, Signal__c, Status__c, Temperature__c, Timestamp_DateTime__c, Timestamp_Date_Time_Device_Status__c, Timestamp_Device_Status__c, Timestamp__c, rsrp__c, rsrq__c, rssi__c, ARC_External_Id__c, changedForGrouping__c, old_Account_id__c, Device_Ts__c, Business_Name__c, Business_Location__Latitude__s, Business_Location__Longitude__s, Business_Location__c, Business_Place_Id__c  from API_Response_Childs__c where Current_Location_Address__c ='Address Not in Google API Data' ];
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select Id, OwnerId,asset__r.name, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, API_Response_ID__c, Accuracy_meters__c, Alt__c, Api_Response__c, Asset_History__c, Asset__c, Battery__c, CurrentLocationId__c, Current_Location_Address__c, EstBattPct__c, Event_Name__c, Facility_Location__c, HaccRank__c, Latitude__c, Location__c, Longitude__c, Message_Type__c, Network__c, PowerUptime__c, Relative_Humidity__c, Signal__c, Status__c, Temperature__c, Timestamp_DateTime__c, Timestamp_Date_Time_Device_Status__c, Timestamp_Device_Status__c, Timestamp__c, rsrp__c, rsrq__c, rssi__c, ARC_External_Id__c, changedForGrouping__c, old_Account_id__c, Device_Ts__c, Business_Name__c, Business_Location__Latitude__s, Business_Location__Longitude__s, Business_Location__c, Business_Place_Id__c  from API_Response_Childs__c where Current_Location_Address__c =\'Address Pending\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<API_Response_Childs__c> scope){
        for(API_Response_Childs__c arc : scope){
            List<API_Response_Childs__c> arc1 = New List<API_Response_Childs__c>();
            arc1.add(arc);
            if(arc1.size()>0){
                
            
            List<API_Response_Childs__c> updatelist = Redesign_googleapi.processGoogleApiErrors(arc1);
            //Update updatelist;
            if(updatelist.size()>0){
                
            
            for(API_Response_Childs__c ar2 : updatelist){
                arcList.add(ar2);
            }
            }
            }
            
        }
    }
    public void finish(Database.BatchableContext bc){
        update arcList;
    }
}