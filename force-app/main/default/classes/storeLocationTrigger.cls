public class storeLocationTrigger {
  public static void updateAddress(list<Location_Record_Ignored__c> lrList){
        
        map<id,account> accmap = new map<id,account>();
        map<string,id> assetAccIdsmap = new map<string,id>();
        map<id,set<id>> parentchilaccids = new map<id,set<id>>();
        string accname;
        set<id> accids = new set<id>();
        try{
            
            
            for(Location_Record_Ignored__c lr1 : lrList){
                               // accname=lr1.Account_Name__c;

                assetAccIdsmap.put(lr1.Device_Id__c,lr1.Account__c);
                if(lr1.Account__c != null)
                    parentchilaccids.put(lr1.Account__c,new set<id>{lr1.Account__c});
            }
            for(account acc : [select id,name,GeoFence_Radius_in_Miles__c,shippinglatitude,parentid, shippinglongitude  FROM Account where Id IN: assetAccIdsmap.values()]){
                accmap.put(acc.id,acc);    
            } 
            system.debug(assetAccIdsmap);
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c IN: assetAccIdsmap.values()]){
                
                if(parentchilaccids.containskey(rc.Source_Account__c)){
                    accids = parentchilaccids.get(rc.Source_Account__c); 
                    accids.add(rc.Related_To__c);
                    accids.add(rc.Source_Account__c);
                    parentchilaccids.put(rc.Source_Account__c,accids); 
                }else{
                    parentchilaccids.put(rc.Source_Account__c,new set<id>{rc.Related_To__c});    
                }
            }
            
            for(Location_Record_Ignored__c lr2 : lrList ){
                double result;
                decimal result1;
                //boolean isInnetwork = false;
                string state;
                id locId;
                boolean executeaction;
                executeaction = false;
          
                    if(lr2.Latitude__c != null || lr2.Longitude__c != null){
                        
                        executeaction = true;   
                    }    
                
                system.debug('execution--'+executeaction);
                if(executeaction){
                    
                    decimal cirlat = lr2.Latitude__c;
                    decimal cirlong = lr2.Longitude__c;
                    system.debug(parentchilaccids);
                    system.debug(result);
                    system.debug(state);
                    system.debug(locid);
                    if(parentchilaccids.containskey(assetAccIdsmap.get(lr2.Device_Id__c))){
                        for(id accid : parentchilaccids.get(assetAccIdsmap.get(lr2.Device_Id__c))){
                            system.debug(accid);
                            //system.debug(accmap.get(accid).shippinglatitude +'-'+ accmap.get(accid).shippinglongitude);
                            if(accmap.containskey(lr2.account__c)){
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
                                        locId = accid;
                                        break;
                                    }  
                                }
                            }
                        }    
                    }//If ParentChild
                    if(locId != null && result1 < accmap.get(locId).GeoFence_Radius_in_Miles__c ){
                        lr2.Location_Account__c = locId;
                    }
                        
                }
            }
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex); 	    
        }
    }
}