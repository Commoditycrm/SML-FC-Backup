global with sharing class updateCurrentAddress implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string Location='In Transit';
        Integer num=Integer.valueof(system.label.HistoryLimits);
        
        string query='SELECT Id,Latitude__c,Device_Id__c,Longitude__c,Account_ID__c,Current_Location_Address__c,createddate,location__c FROM asset_history_custom__c where location__c!=\'' + String.escapeSingleQuotes(Location)+'\'and Current_Location_Address__c = null and latitude__c!=null and longitude__c!=null order by createddate asc limit '+num+'';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<asset_history_custom__c> astHisList)
    {
        MAP<Id,asset_history_custom__c> ahMap = new MAP<Id,asset_history_custom__c>();
        list<asset_history_custom__c> ahlist=new list<asset_history_custom__c>();
        map<id,account> accmap = new map<id,account>();
        map<string,id> assetAccIdsmap = new map<string,id>();
        map<id,set<id>> parentchilaccids = new map<id,set<id>>();
        set<id> accids = new set<id>();
        double result;
        decimal result1;        
        
        for(asset_history_custom__c asstHis : astHisList){
            system.debug('newlist'+astHisList);
            assetAccIdsmap.put(asstHis.Device_Id__c,asstHis.Account_ID__c);
            if(asstHis.Account_ID__c != null)
                parentchilaccids.put(asstHis.Account_ID__c,new set<id>{asstHis.Account_ID__c});
        }
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c IN: assetAccIdsmap.values()]){
            
            if(parentchilaccids.containskey(rc.Source_Account__c)){
                accids = parentchilaccids.get(rc.Source_Account__c); 
                accids.add(rc.Related_To__c);
                accids.add(rc.Source_Account__c);
                parentchilaccids.put(rc.Source_Account__c,accids); 
                system.debug('accidsnew'+accids);
            }else{
                parentchilaccids.put(rc.Source_Account__c,new set<id>{rc.Related_To__c});    
            }
        }
        for(account acc : [select id,address__c,GeoFence_Radius_in_Miles__c,shippinglatitude,parentid, shippinglongitude FROM Account]){
            accmap.put(acc.id,acc);    
        }
        for(asset_history_custom__c asst : astHisList){
            if(asst.Latitude__c != null && asst.Longitude__c != null){
                decimal cirlat = asst.Latitude__c;
                decimal cirlong = asst.Longitude__c;
                system.debug(parentchilaccids);
                if(parentchilaccids.containskey(assetAccIdsmap.get(asst.Device_Id__c))){
                    for(id accid : parentchilaccids.get(assetAccIdsmap.get(asst.Device_Id__c))){
                        system.debug(accid);
                        if(accmap.containskey(asst.Account_ID__c)){
                            if(accmap.containskey(accid)){
                                Location loc1 = Location.newInstance(accmap.get(accid).shippinglatitude,accmap.get(accid).shippinglongitude);
                                Location loc2 = Location.newInstance(cirlat,cirlong);
                                result = Location.getDistance(loc1, loc2, 'mi');    
                                
                                system.debug('result--'+result);
                                system.debug('Distance result--'+result);
                                system.debug('Distance in mile result--'+loc1.getDistance(loc2, 'mi'));
                                system.debug('Distance in km result--'+loc1.getDistance(loc2, 'km'));
                                system.debug('Account Geofence Radius--'+accmap.get(accid).GeoFence_Radius_in_Miles__c);
                                result1 = result;
                                if(accmap.get(accid).GeoFence_Radius_in_Miles__c != null && result < accmap.get(accid).GeoFence_Radius_in_Miles__c){
                                    asst.Current_Location_Address__c=accmap.get(accid).Address__c;
                                    ahlist.add(asst);
                                    system.debug('allvalues'+ahlist);
                                }  
                            }
                        }
                    }    
                }       
                
            }       
            
        }
        if(ahlist.size()>0){
            ahMap.putAll(ahlist);
        }
        if(ahMap.size()>0){
        update ahMap.values();
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }   

    
}