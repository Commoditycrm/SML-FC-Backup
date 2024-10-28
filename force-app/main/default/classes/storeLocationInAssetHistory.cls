public class storeLocationInAssetHistory {
    public static void updateAddress(list<asset_history_custom__c> ahlist){
        try{
            string currentLocName;
            //string currentLocId;
            set<string> setid=new set<string>();
            map<string,string> locmap=new map<string,string>();
            system.debug('###--ahlist--'+ahlist);
            for(asset_history_custom__c ahhis:ahlist){
                if(ahhis.Inserted_From__c == 'Location Record' && ahhis.Location__c==null){
                    currentLocName = Utilityclass.currentLocName(ahhis.Account_ID__c,ahhis.Latitude__c,ahhis.Longitude__c);
                    if(currentLocName!=null){
                        ahhis.Location__c = currentLocName;
                        setid.add(currentLocName);
                    }
                    else{
                        ahhis.Location__c='In Transit';
                    }
                }
            }
           /* if(currentLocName!=null){
            for(asset_history_custom__c aaa:[select id,Account_ID__c,Latitude__c,Longitude__c,location__c,asset__r.current_location__c from asset_history_custom__c where id=:ahlist[0].id]) {
               currentLocId = Utilityclass.currentLocId(aaa.Account_ID__c,aaa.Latitude__c,aaa.Longitude__c);

                aaa.Asset__r.current_location__c=currentLocId;
            }
            }*/
           for(account acc:[SELECT Id,name,ShippingStreet,ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy,ShippingAddress,shipaddformula__c FROM Account where name=:setid]){
                locmap.put(acc.Name,acc.shipaddformula__c);
            }
            
            for(asset_history_custom__c ahhis2:ahlist){
                system.debug('###--ahhis2 record--'+ahhis2);
                if(ahhis2.Inserted_From__c == 'Location Record'){
                    ahhis2.Current_Location_Address__c=locmap.get(ahhis2.Location__c);
                }
            }
            
            system.debug('###--ahlist 2--'+ahlist);
        }catch(exception ex){
            Utilityclass.sendemailtoadmin(ex);      
            
        }
    }
}