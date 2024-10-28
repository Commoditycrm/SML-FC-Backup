global without sharing class updateCurrentLocationAddress{
    
    public static void  updateAssetddress(List<Asset> getAssetRecords){
        List<Asset_History_custom__c> asstHisList= new List<Asset_History_custom__c>();
        list<asset> updateassetlist = new list<asset>();
        
        for(Asset asstRec : getAssetRecords){
            asstRec.Current_City__c = '';
            asstRec.Current_Address__c = '';
            asstRec.Current_State__c = '';
            asstRec.Current_Street_Address__c = '';
            asstRec.Current_Zip_Code__c = '';
            
            compareGoogleAPIData.performAction(asstRec.Temporary_Latitude__c,asstRec.Temporary_Longitude__c,asstRec);
            
            if(!String.isBlank(asstRec.Current_Address__c)){
                asstRec.Current_Location__c = null;
                for(Asset_History_custom__c asstHis : [Select id,name,Asset__c,Current_Location_Address__c from Asset_History_custom__c where Location__c='In Transit' AND (Still_in_this_Location__c=true OR Current_Message_Type__c=true) AND Asset__c=:asstRec.Id])
                {
                    asstHis.Current_Location_Address__c=asstRec.Current_Address__c;
                    asstHisList.add(asstHis);
                }
                asstRec.Batch_Update__c = false;
                updateassetlist.add(asstRec);    
            }
            
            //if
        }//for
        
        if(updateassetlist.size()>0){
            Utilityclass.stopTrigger();
            update updateassetlist;    
        }
        
        //system.debug('asstHisList'+asstHisList.size());
        if(asstHisList.size()>0){
            update asstHisList;
        }
    }
    
    public static void updateACHAddress(List<Asset_History_custom__c> getAssetRecords){
        /*List<Asset_History_custom__c> asstHisList= new List<Asset_History_custom__c>();
        
        Map<String,List<sObject>> AsstHist_GoogleDataMap =  new Map<String,List<sObject>> ();
        boolean callout = false;
        for(Asset_History_custom__c asstRec : getAssetRecords){
        
           compareGoogleAPIData.performAction(asstRec.Latitude__c,asstRec.Longitude__c,asstRec);
           asstHisList.add(asstRec);
        }//For             
        
        if(asstHisList.size()>0){
            update asstHisList;   
        }*/
        
        set<id> accids = new set<id>();
        for(Asset_History_custom__c ast : getAssetRecords){
           if(ast != null && ast.Asset__r.AccountId != null){
               accids.add(ast.Asset__r.AccountId);
           }
        }
        
        if(!accids.isEmpty()){
            map<id,account> accmap = new map<id,account>();
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c IN: accids]){
                accids.add(rc.Source_Account__c);
                accids.add(rc.Related_To__c);
            }
            
            for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
                accmap.put(acc.id,acc);    
            }
            
            List<Asset_History_custom__c> asstHisList = new List<Asset_History_custom__c>();
            
            List<Nested_Geofence__mdt> nestedGeofence = [select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,
                                                         Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids];
                
            for(Asset_History_custom__c ast : getAssetRecords){
               double result;
               if(ast != null && ast.Asset__r.AccountId != null && accmap.containskey(ast.Asset__r.AccountId)){
                   Location loc1 = Location.newInstance(accmap.get(ast.Asset__r.AccountId).shippinglatitude,accmap.get(ast.Asset__r.AccountId).shippinglongitude);
                   Location loc2 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
                   result = Location.getDistance(loc1, loc2, 'mi');    
                   if(accmap.get(ast.Asset__r.AccountId).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(ast.Asset__r.AccountId).GeoFence_Radius_in_Miles__c){
                       //ast.Current_Location_Address__c = accmap.get(ast.Asset__r.AccountId).name;
                       ast.location__c =  accmap.get(ast.Asset__r.AccountId).name;
                       ast.currentLocationId__c = ast.Asset__r.AccountId;
                       ast.Current_Location_Address__c = ast.Current_Location_Address__c;
                   }
               }
               
               if(ast.Current_Location_Address__c == null){
                    for (Nested_Geofence__mdt mdt : nestedGeofence ){
                        if(ast.Asset__r.AccountId == mdt.Current_Location_Id__c){
                            Location loc1 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
                            Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                            result = Location.getDistance(loc1, loc2, 'mi');
                            if(result <= mdt.Diameter__c){
                                ast.location__c =  accmap.get(ast.Asset__r.AccountId).name;
                                ast.currentLocationId__c = ast.Asset__r.AccountId;  
                                ast.Current_Location_Address__c = mdt.Current_Location__c; 
                            } 
                        } 
                    }
                }
                
                if(ast.Current_Location_Address__c == null){
                    compareGoogleAPIData.performAction(ast.Latitude__c, ast.Longitude__c,ast);
                }
            }
            
            if(getAssetRecords.size() > 0){
                update getAssetRecords;   
            }
        }
    }
    /*
    public static Asset checkGeofenceForAsset(Asset ast){
        double result;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        
        if(ast != null && ast.AccountId != null && ast.Temporary_Latitude__c != null && ast.Temporary_Longitude__c != null){
            accids.add(ast.AccountId);
        
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: ast.AccountId]){
                
                accids.add(rc.Source_Account__c);
                accids.add(rc.Related_To__c);
            }
            for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
                accmap.put(acc.id,acc);    
            }
            
            for(id acc :accids ){
                if(accmap.containskey(acc)){
                    Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                    Location loc2 = Location.newInstance(ast.Temporary_Latitude__c, ast.Temporary_Longitude__c);
                    result = Location.getDistance(loc1, loc2, 'mi');      
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                        ast.Current_Address__c = accmap.get(acc).name;
                        break;  
                    }
                }
            } 
            
            if(ast.Current_Address__c == null){
                for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){
                
                    Location loc1 = Location.newInstance(ast.Temporary_Latitude__c, ast.Temporary_Longitude__c);
                    Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    result = Location.getDistance(loc1, loc2, 'mi');
                    //system.debug('result--'+ result);
                    if(result < mdt.Diameter__c){
                        ast.Current_Address__c  = mdt.Current_Location__c;  
                        break;  
                    }  
                }
            }
        }
        return ast;
    }
    
    public static Asset_History_custom__c checkGeofenceForACH(Asset_History_custom__c ast){
        double result;
        map<id,account> accmap = new map<id,account>();
        set<id> accids = new set<id>();
        
        if(ast != null && ast.Asset__r.AccountId != null){
            accids.add(ast.Asset__r.AccountId);
        
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: ast.Asset__r.AccountId]){
                
                accids.add(rc.Source_Account__c);
                accids.add(rc.Related_To__c);
            }
            for(account acc : [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude FROM Account where id IN : accids]){
                accmap.put(acc.id,acc);    
            }
            
            for(id acc :accids ){
                if(accmap.containskey(acc)){
                    Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude);
                    Location loc2 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
                    result = Location.getDistance(loc1, loc2, 'mi');      
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c){
                        ast.Current_Location_Address__c = accmap.get(acc).name;
                        break;  
                    }
                }
            } 
            
            if(ast.Current_Location_Address__c == null){
                for (Nested_Geofence__mdt mdt:[select MasterLabel,Latitude__c,Longitude__c,Facility_Location__c,Diameter__c,Current_Location__c,Current_Location_Id__c from Nested_Geofence__mdt where Current_Location_Id__c in :accids]){
                
                    Location loc1 = Location.newInstance(ast.Latitude__c, ast.Longitude__c);
                    Location loc2 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    result = Location.getDistance(loc1, loc2, 'mi');
                    //system.debug('result--'+ result);
                    if(result < mdt.Diameter__c){
                        ast.Current_Location_Address__c = mdt.Current_Location__c;  
                        break;  
                    }  
                }
            }
        }
        
        return ast;
    }*/
}