global with sharing class UpsertAssetfromApi_Batch implements Database.Batchable<sObject> {
    
    global  List<Api_Response__c> start(Database.BatchableContext bc) {
        List<Api_Response__c> apiList = new List<Api_Response__c>();
        List<Api_Response__c> updateapiList = new List<Api_Response__c>();
        List<Api_Response__c> notupdatedapiList = new List<Api_Response__c>();
        List<Api_Response__c> apiListforMap = new List<Api_Response__c>();
        set<string> assetdeviceIds = new set<string>();
        map<string,List<Api_Response__c>> deviceIdApiresMap = new map<string,List<Api_Response__c>>();
        list<string> DeviceIds = new list<string>();
        
        
        for(Api_Response__c api : [select id,name,Access_Point_Id__c,Message_Count__c,Access_Point_Type__c,Area_Name__c,Area_Id__c,Device_Id__c,Asset_Group_Id__c,Zone_Id__c,Asset_Product__c,Zone_Name__c,Position_Source__c,Shock_Threshold__c,Field1__c,
                                   Field2__c,Shock_Max__c,Latitude__c,Longitude__c,Shock_Count__c,Temperature__c,Humidity__c,Last_Connected__c,Needs_Repair__c,
                                   Msg_Type__c,Start_Time__c,Battery_Level__c,Shock_Max_Time__c,Ready_for_Pickup__c,UpdateResponseToAsset__c
                                   from Api_Response__c where UpdateResponseToAsset__c=false and Unprocessed_Response__c = false
                                   and Last_Connected__c != null order by Last_Connected__c asc limit 50000]){
                                       
                                       if(deviceIdApiresMap.containskey(api.Device_Id__c)){
                                           apiListforMap =  deviceIdApiresMap.get(api.Device_Id__c);
                                           apiListforMap.add(api); 
                                           deviceIdApiresMap.put(api.Device_Id__c,apiListforMap);
                                       }else{
                                           deviceIdApiresMap.put(api.Device_Id__c, new list<Api_Response__c>{api});    
                                       }        
                                       
                                   }
        
        system.debug(deviceIdApiresMap);
        system.debug(deviceIdApiresMap.keyset().size());
        for(asset ast : [select id,name,Device_Id__c,Access_Point_Device_Id__c,Temporary_Latitude__c,
                         Temporary_Longitude__c,Last_Connected__c,Message_Type_Formula__c  from asset
                         where Is_Access_Point__c = false and Device_Id__c IN : deviceIdApiresMap.keyset() limit 50000]){
                             assetdeviceIds.add(ast.Device_Id__c);
                             datetime starttime;
                             system.debug(ast);
                             system.debug(deviceIdApiresMap.containskey(ast.Device_Id__c));
                             if(deviceIdApiresMap.containskey(ast.Device_Id__c)){
                                 integer msgcount = 0;
                                 Api_Response__c apres = new Api_Response__c();	
                                 Api_Response__c  nullapres = new Api_Response__c();
                                 if(deviceIdApiresMap.get(ast.Device_Id__c).size()!=1){
                                     for(Api_Response__c ap : deviceIdApiresMap.get(ast.Device_Id__c) ){
                                         
                                         if(ast.Last_Connected__c > ap.Last_Connected__c){
                                             apres = ap;
                                             break;
                                         }
                                         else if(apres == nullapres && ast.get('Access_Point_Device_Id__c') == ap.get('Access_Point_Id__c') && 
                                                 ast.get('Temporary_Latitude__c') == ap.get('Latitude__c') && 
                                                 ast.get('Temporary_Longitude__c') == ap.get('Longitude__c') &&
                                                 ast.get('Message_Type_Formula__c') == string.valueof(ap.get('Msg_Type__c'))){
                                                     
                                                     system.debug('1');
                                                     apres = ap;
                                                     msgcount = msgcount + 1;
                                                     apres.Message_Count__c = msgcount;
                                                     starttime = apres.Last_Connected__c;
                                                     system.debug('@@'+apres.get('Latitude__c') != ap.get('Latitude__c'));
                                                     system.debug('@@'+apres.get('Longitude__c') != ap.get('Longitude__c'));
                                                 }else if(apres != nullapres &&(apres.get('Access_Point_Id__c') != ap.get('Access_Point_Id__c') 
                                                                                || apres.get('Latitude__c') != ap.get('Latitude__c') 
                                                                                || apres.get('Longitude__c') != ap.get('Longitude__c')
                                                                                || apres.get('Msg_Type__c') != ap.get('Msg_Type__c'))){
                                                                                    system.debug('2');    
                                                                                    //msgcount = msgcount + 1;
                                                                                    //apres.Message_Count__c = msgcount;
                                                                                    break;
                                                                                    
                                                                                }else{
                                                                                    system.debug('3');
                                                                                    
                                                                                    apres = ap;
                                                                                    msgcount = msgcount + 1; 
                                                                                    if(msgcount == 1){
                                                                                        starttime = apres.Last_Connected__c;    
                                                                                    }
                                                                                    apres.Message_Count__c = msgcount;
                                                                                }
                                         system.debug(msgcount);
                                         notupdatedapiList.add(ap);
                                     }
                                     
                                     if(starttime != null){
                                         apres.Start_Time__c = starttime;  
                                     }
                                 }else{
                                     system.debug('only one');
                                     apres =  deviceIdApiresMap.get(ast.Device_Id__c)[0];
                                     apres.Message_Count__c = 1;
                                     apres.Start_Time__c = apres.Last_Connected__c;
                                     
                                 }
                                 
                                 apiList.add(apres);
                             }
                             
                         }
        system.debug(apiList);
        for(string astid : deviceIdApiresMap.keyset()){
            system.debug('enters new asset--->');
            if(!assetdeviceIds.contains(astid)){
                system.debug('enters new asset1--->');
                for(Api_Response__c ap : deviceIdApiresMap.get(astid) ){
                    system.debug('for new asset');
                    ap.Message_Count__c = 1;
                    ap.Start_Time__c = ap.Last_Connected__c;
                    apiList.add(ap);
                    break;
                }	    
            }    
        }
        system.debug(notupdatedapiList);
        for(Api_Response__c apires : notupdatedapiList){
            
            apires.UpdateResponseToAsset__c=true;
            updateapiList.add(apires);
            
        }
        if(updateapiList.size()>0){
            update updateapiList;    
        }   
        system.debug(apilist.size() +'-'+ apilist );
        return apiList;    
        
    }
    
    global void execute(Database.BatchableContext bc, List<Api_Response__c> getApiRecords){
        system.debug('getApiRecords--->'+getApiRecords.size()); 
        UpsertAssetfromApi upsertAsset= new UpsertAssetfromApi();
        upsertAsset.AssetEventProcessor(getApiRecords);
    }    
    
    global void finish(Database.BatchableContext bc){
    }    
    
}