public class FixInTransitAHC_Batch implements Database.Batchable<sobject>,Database.Stateful {
    Integer toBeUpdatedCount;
    String query;
    Integer totalCount;
    Boolean updateAHC = false;
    String ahcIdsForEmail='';
    public FixInTransitAHC_Batch (String query,Boolean updateAHC){
        this.toBeUpdatedCount = 0;
        this.query = query;
        this.totalCount = 0;
        this.updateAHC = updateAHC;    
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(this.query);
    }
    public void execute(Database.BatchableContext bc,List<Asset_History_custom__c> ahcs){   
        List<Asset_History_custom__c> ahcsTobeUpdated = new List<Asset_History_custom__c>();
        for(Asset_History_custom__c ahc : ahcs){
            this.totalCount += 1;
            Map<String,String> locationAndAddressMap = currentLocName(ahc.Account_ID__c,ahc.latitude__c,ahc.longitude__c);
            if(locationAndAddressMap.containsKey('location') && !String.isBlank(locationAndAddressMap.get('location')) && ahc.Location__c != locationAndAddressMap.get('location')){
                this.toBeUpdatedCount += 1;
                ahcIdsForEmail += ahc.Name+',';
                ahc.Location__c = locationAndAddressMap.get('location');
                ahc.InTransit_Updated__c = true;
                if(locationAndAddressMap.containsKey('address')){
                   ahc.current_location_address__c = locationAndAddressMap.get('address');
                }
                ahcsTobeUpdated.add(ahc);
            }
        }
        if(!ahcsTobeUpdated.isEmpty() && updateAHC){
            update ahcsTobeUpdated;
        }
    }
    public void finish(Database.BatchableContext bc){
       	messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
        msg.toAddresses = new String[] { 'commodityccrm@gmail.com' };
        msg.setSubject('FixInTransitAHC_Batch Output');
        string body = 'No of AHC Record to update: ' +this.toBeUpdatedCount +' out of '+this.totalCount+' ';
        body += 'Asset History Numbers: '+this.ahcIdsForEmail;
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        system.debug('No of AHC Record to update: ' +this.toBeUpdatedCount +' out of '+this.totalCount);
        system.debug('Email sent--');
    }
    public static Map<String,String> currentLocName(id accid, decimal lat1,decimal lng1){
        double result;
        decimal lat;
        decimal lng;
        Map<Id,String> acctIdToAddressMap = new Map<Id,String>();
        Map<String,String> locationAndAddressMap = new Map<String,String>();
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        if(accid != null)
            accids.add(accid);        
        for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accid]){      
            accids.add(rc.Source_Account__c);
            accids.add(rc.Related_To__c);
        }
        for(account acc : [select id,name,shippinglatitude,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,ShippingAddress,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
            accmap.put(acc.id,acc);    
            String shippingAddress = acc.ShippingStreet+', '+acc.ShippingCity+', '+acc.ShippingState+', '+acc.ShippingPostalCode+', '+acc.ShippingCountry;
            acctIdToAddressMap.put(acc.Id,shippingAddress);
        }       
        for(id acc :accids ){
            if(accmap.containskey(acc)){
                Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                Location loc2 = Location.newInstance(lat1,lng1);
                result = Location.getDistance(loc1, loc2, 'mi');      
                if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){                   
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){      
                        locationAndAddressMap.put('location', accmap.get(acc).name);
                        locationAndAddressMap.put('address', acctIdToAddressMap.get(acc));
                        break;  
                    }
                }
            }   
        }   
        for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){  
            Location loc1 = Location.newInstance(lat1,lng1);
            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
            result = Location.getDistance(loc1, loc2, 'mi');
            system.debug('result--'+ result);
            if(result < mdt.Diameter__c){
                locationAndAddressMap.put('location', mdt.Current_Location__c);
                if(acctIdToAddressMap.containsKey(mdt.Current_Location_Id__c)){
                    locationAndAddressMap.put('address', acctIdToAddressMap.get(mdt.Current_Location_Id__c)); 
                }
                else{
                    Account acct = [Select Id,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,ShippingAddress FROM Account WHERE Id=:mdt.Current_Location_Id__c];
                    String shippingAddressGF = acct.ShippingStreet+', '+acct.ShippingCity+', '+acct.ShippingState+', '+acct.ShippingPostalCode+', '+acct.ShippingCountry;
                    locationAndAddressMap.put('address', shippingAddressGF);                         
                }
                break;  
            }  
        }
        system.debug('locationAndAddressMap--'+locationAndAddressMap);        
        return locationAndAddressMap;
    }
}