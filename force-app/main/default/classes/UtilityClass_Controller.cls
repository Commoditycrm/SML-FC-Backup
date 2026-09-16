public class UtilityClass_Controller {
    public static List<Google_API_Data__c> GADlist =new  List<Google_API_Data__c>();
    public static Redesign_NL__mdt RedesignMetadata = RedesignNL_Helper.getRedesignMetadata('Default');
    public static string latfull;
    public static string lngfull;
    public static String lat;
    public static String lon;
    public static Asset ast;
    public static Datetime currentDateTime;
    public static List<String> includeList = RedesignNL_Helper.getincludeList();
    public static List<String> excludeList = RedesignNL_Helper.getexludeList(); 
    public static List<Google_API_Data__c> gadListToInsert = new List<Google_API_Data__c>();
    public static Map<id,Google_Api_Data__c> gadInsertMap = new Map<id,Google_Api_Data__c>();
    public static Map<String,List<String>> latLonMap = new Map<String,List<String>>();   

    public static void createGoogleAPIRecords(List<API_Response_Childs__c> locApiResp, String deviceId, Asset ast){      
        Boolean accUniqId= False;
        List<Asset> assetLst = [Select Id, Name,AccountId, device_id__c,Account_Unique_Id__c,Account.Capture_Business_Name__c from Asset where device_id__c =: deviceId];
        String accountId;
        if(assetLst.size() > 0) {
            accountId = assetLst[0].AccountId;
            accUniqId= assetLst[0].Account.Capture_Business_Name__c;
        }
        else {
            List<Account> accList = [Select Id, Name,Account_ID__c,Capture_Business_Name__c from Account where Name = 'Testing'];
            accountId = accList[0].Id;
            accUniqId= accList[0].Capture_Business_Name__c;
        }  
        for(API_Response_Childs__c loc : locApiResp) {
            if(loc.haccRank__c == 0 && loc.Latitude__c != null && loc.Longitude__c != null && loc.Latitude__c != '0' && loc.Longitude__c != '0') {
                Boolean isGeofenceFound = checkGeofence(accountId, loc);
                if(isGeofenceFound == false) { 
                    latfull = loc.Latitude__c;
                    lngfull = loc.Longitude__c;
                    lat = loc.Latitude__c.left(7);
                    lon = loc.Longitude__c.left(7);
                    if(latLonMap == null || !latLonMap.containsKey(lat) || (latLonMap != null & latLonMap.containsKey(lat) & !latLonMap.get(lat).contains(lon))) {
                         GADlist = [SELECT id,Current_City__c,Current_State__c,Current_Address__c,Current_country__c,Current_Street_Address__c,Business_Name__c,Business_Place_Id__c,Business_Location__Longitude__s,Business_Location__Latitude__s,Captured_Business_Name__c,Likely_Business_Name_Types__c,
                                                            Current_Zip_Code__c,Latitude__c,Longitude__c FROM Google_API_Data__c 
                                                            WHERE Latitude__c LIKE: '%'+lat+'%' AND Longitude__c LIKE: '%'+lon+'%' LIMIT 1];
                        system.debug('###--GADlist--'+ GADlist);
                        gadListToInsert = googleCallout (latfull, lngfull,loc,accUniqId, ast, deviceId); 
                    }
                    //Changes for 353 - Google API Error in ARC start
                    else if(latLonMap != null & latLonMap.containsKey(lat) & latLonMap.get(lat).contains(lon)) {
                        for(Google_API_Data__c gad : gadListToInsert) {
                            if(gad.Latitude__c.contains(lat) && gad.Longitude__c.contains(lon)) {
                                loc.Location__c = 'In Transit';
                                loc.Current_Location_Address__c = gad.Current_Address__c;
                                loc.Current_Street_Address__c  = gad.Current_Street_Address__c;
                                loc.Current_City__c  = gad.Current_City__c;
                                loc.Current_State__c  = gad.Current_State__c;
                                loc.Current_Zipcode__c   = gad.Current_Zip_Code__c;
                                loc.current_country__c = gad.current_country__c;
                                if(gad.Business_Name__c != null){
                                    loc.Business_Name__c = gad.Business_Name__c;
                                    loc.Business_Location__Latitude__s =  gad.Business_Location__Latitude__s;
                                    loc.Business_Location__Longitude__s = gad.Business_Location__Longitude__s;
                                    loc.Business_Place_Id__c = gad.Business_Place_Id__c;
                                }                                
                                break;
                            }
                        }
                    }
                    //Changes for 353 - Google API Error in ARC end
                    else {
                        loc.Location__c = 'In Transit';
                        loc.Current_Location_Address__c = 'Address not in Google API data';
                        loc.Status__c = 'Google Api Error';
                    }
                }   
            }
        }
        system.debug('###--gadListToInsert--'+ gadListToInsert);
        if(!gadListToInsert.isEmpty()){
            	upsert gadListToInsert;  
        }
    }

    Public static List<Google_API_Data__c> googleCallout( String latfull, String lngfull,API_Response_Childs__c loc,Boolean accUniqId,Asset ast,String deviceId ){
        if(GADlist== null || (GADlist!=null && GADlist.isEmpty())){
            
        currentDateTime = System.now().addDays(1);
                            Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=latfull, Longitude__c=lngfull);
                            if((RedesignMetadata.Capture_Business_Name__c == True && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True) || Test.isRunningTest() ){
                                getBusinessName(latfull, lngfull, gadRec, loc, includeList, excludeList);
                            }
                            if (RedesignMetadata.Redesign_Api_Response_Toggle__c == true) {
                                Http h = new Http();
                                HttpRequest req = new HttpRequest();
                                req.setTimeout(60000);
                                req.setMethod('GET');
                                req.setHeader('content-type','application/x-www-form-urlencoded');
                                req.setHeader('Accept', 'application/json'); 
                                string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+Decimal.valueOf(latfull)+'%20'+Decimal.valueOf(lngfull)+'&sensor=true';
                                system.debug(endpt);    
                                req.setEndpoint(endpt);
                                HttpResponse res = h.send(req);
                                system.debug('###--res--'+ res);
                                //    system.debug('###--res.getBody()--'+ res.getBody());
                                if(res.getStatusCode() == 200){    
                                    Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                    
                                    system.debug(results1); 
                                    List<Object> mapGADdetails = (List<Object>) results1.get('results');
                                    Integer i=0;
                                    Map<String,Object> addrvalMap = new map<String,Object>();
                                    Map<integer , Map<string,string>> addressMap = New Map<integer , Map<string,string>>(); //Integer,Actual Address  Map
                                    Map<integer , Map<string,string>> plusCodeAddressMap = New Map<integer , Map<string,string>>(); //Integer,PlusCode Address  Map
                                    for(object obj : mapGADdetails){
                                        Map<string,string> fullAdressMap = New Map<string,string>(); //Actual AddressMap
                                        Map<string,string> plusCodeFullAdressMap = New Map<string,string>(); //Pluscode AddressMap
                                        string streetAddress = '';
                                        addrvalMap = (Map<String,Object>)obj;
                                        List<Object> addressdetails = new List<Object>();
                                        if(addrvalMap.containskey('address_components')){
                                            addressdetails = (List<Object>) addrvalMap.get('address_components');    
                                        }  
                                        Map<String,Object> comGADmap = new map<String,Object>();
                                        //string types;
                                        //List<string> types = New List<String>();
                                        for(object obj1 : addressdetails){
                                            comGADmap = (Map<String,Object>)obj1;
                                            List<string> types = New List<String>();
                                            
                                        if(comGADmap.containskey('types')){
                                            // types = (List<string>) comGADmap.get('types');
                                            for(object obj2 : (List<Object>) comGADmap.get('types') ){
                                                if((string)obj2 != 'political'){
                                                    //types = (string)obj2;  
                                                    types.add((string)obj2);       
                                                }
                                            }    
                                            }
                                            system.debug('types for Address-'+types);
                                            if(comGADmap.containskey('short_name') || comGADmap.containskey('long_name')){
                                                string value = null;
                                                string shortName = (string)comGADmap.get('short_name'); 
                                                string longName = (string)comGADmap.get('long_name'); 
                                                if (shortName.length() > 0 && shortName != 'NULL' &&  shortName != 'null' && shortName != '' && shortName!=null) {
                                                    value = shortName;
                                                }else if (longName.length() > 0 && longName != 'NULL' &&  longName != 'null' && longName != ''  && longName!=null) {
                                                    value = longName;
                                                }
                                                if(types.contains('street_number')){       
                                                    if(value != null && !value.contains('+')){
                                                        fullAdressMap.put('streetNumber',value);
                                                    }else if(value != null){
                                                        plusCodeFullAdressMap.put('streetNumber',value);
                                                    }
                                                }
                                                if(types.contains('route') ){
                                                    if(value != null && !value.contains('+')){
                                                        fullAdressMap.put('streetName',value);
                                                    }else if(value != null){
                                                        plusCodeFullAdressMap.put('streetName',value);
                                                    }
                                                }
                                                if(types.contains('locality')){
                                                    if(value != null && !value.contains('+')){
                                                        fullAdressMap.put('city',value);
                                                    }
                                                }
                                                if(types.contains('administrative_area_level_1')){
                                                    if(value != null && !value.contains('+')){
                                                        if(value.length()>2){
                                                            string str = value.replace(' ', '_'); //replacing empty space with _ to get metadata
                                                            Us_States__mdt  uss = Us_States__mdt.getInstance(str); //getting short name for us states
                                                            if(uss!=null){
                                                                fullAdressMap.put('state',uss.Short_Name__c);
                                                            }else{
                                                                fullAdressMap.put('state',value);
                                                            }
                                                        }else{
                                                            fullAdressMap.put('state',value);
                                                        }
                                                    }
                                                }
                                                
                                                if(types.contains('postal_code')){
                                                    if(value != null && !value.contains('+')){
                                                        fullAdressMap.put('zipCode',value);
                                                    }
                                                }
                                                if(types.contains('country')){
                                                    if(value != null && !value.contains('+')){
                                                        if(value.length()>2){
                                                            string str = value.replace(' ', '_'); //replacing empty space with _ to get metadata
                                                            Us_States__mdt  uss = Us_States__mdt.getInstance(str); //getting short name for us states
                                                            if(uss!=null){
                                                                fullAdressMap.put('country',uss.Short_Name__c);
                                                            }else{
                                                                fullAdressMap.put('country',value);
                                                            }
                                                        }else{
                                                            fullAdressMap.put('country',value);
                                                        }
                                                    }
                                                }
                                            }//IF Contains Short Name
                                        } //For Address Details
                                        addressMap.put(i,fullAdressMap);
                                        plusCodeAddressMap.put(i,plusCodeFullAdressMap);
                                        i++;
                                    }
                                    Integer adDetailsMaxSize = 0;
                                    Map<String, String> mostDetailedAddress = null;
                                    
                                    // finding the most detailed address
                                    for (Integer key : addressMap.keySet()) {
                                        Map<String, String> adMap = addressMap.get(key);
                                        if (adMap.size() > adDetailsMaxSize) {
                                            adDetailsMaxSize = adMap.size();
                                            mostDetailedAddress = adMap;
                                        }
                                    }
                                    
                                    // Checking and updating the state if missing
                                    if (mostDetailedAddress != null) {
                                        List<String> addressFields = new List<String>{ 'streetNumber', 'streetName', 'city', 'state', 'zipCode', 'country' };
                                            // Iterate over the fields and fill missing values
                                            for (String field : addressFields) {
                                                if (!mostDetailedAddress.containsKey(field) || String.isEmpty(mostDetailedAddress.get(field))) {
                                                    // Searching for the field in other addresses
                                                    for (Integer key : addressMap.keySet()) {
                                                        Map<String, String> adMap = addressMap.get(key);
                                                        if (adMap.containsKey(field) && !String.isEmpty(adMap.get(field))) {
                                                            mostDetailedAddress.put(field, adMap.get(field));
                                                            break;
                                                        }
                                                    }
                                                    
                                                    // If still missing, fallback to a +code or default value for street Address
                                                    if(field == 'streetNumber' || field == 'streetName'){
                                                        if (!mostDetailedAddress.containsKey(field) || String.isEmpty(mostDetailedAddress.get(field))) {
                                                            for (Integer key : plusCodeAddressMap.keySet()) {
                                                                Map<String, String> adMap = plusCodeAddressMap.get(key);
                                                                if (adMap.containsKey(field) && !String.isEmpty(adMap.get(field))) {
                                                                    mostDetailedAddress.put(field, adMap.get(field));
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                    
                                    // Assigning values to fields
                                if (mostDetailedAddress != null) {
                                    String fullAddress = '';
                                    
                                    //  address components with safe fallbacks
                                    String streetNumber = mostDetailedAddress.containsKey('streetNumber') ? mostDetailedAddress.get('streetNumber') : '';
                                    String streetName = mostDetailedAddress.containsKey('streetName') ? mostDetailedAddress.get('streetName') : '';
                                    String city = mostDetailedAddress.containsKey('city') ? mostDetailedAddress.get('city') : '';
                                    String state = mostDetailedAddress.containsKey('state') ? mostDetailedAddress.get('state') : '';
                                    String zipCode = mostDetailedAddress.containsKey('zipCode') ? mostDetailedAddress.get('zipCode') : '';
                                    String country = mostDetailedAddress.containsKey('country') ? mostDetailedAddress.get('country') : '';
                                    string streetAddress ='';
                                    if(!String.isEmpty(streetNumber) && !String.isEmpty(streetName)) {
                                        streetAddress = streetNumber+' '+streetName;
                                    }else{
                                        streetAddress = streetNumber!='' ? streetNumber : streetName;
                                    }
                                    
                                    // Assign individual values to gadRec record
                                    gadRec.Current_Street_Address__c = streetAddress;
                                    gadRec.Current_City__c = city;
                                    gadRec.Current_State__c = state;
                                    gadRec.Current_Zip_Code__c = zipCode;
                                    gadRec.Current_Country__c = country;
                                    gadRec.Device_Id__c = deviceId;
                                    gadRec.Vendor__c = 'Loco';
                                    
                                    List<String> addressParts = new List<String>();
                                        if (!String.isEmpty(streetAddress) && streetAddress!='')
                                        addressParts.add(streetAddress);
                                    
                                    if (!String.isEmpty(city) && city!='') 
                                        addressParts.add(city);
                                    if (!String.isEmpty(state) && state!='') 
                                        addressParts.add(state);
                                    if (!String.isEmpty(zipCode) && zipCode!='') 
                                        addressParts.add(zipCode);
                                    if (!String.isEmpty(country) && country!='') 
                                        addressParts.add(country);
                                    
                                    fullAddress = String.join(addressParts, ', ');
                                    
                                    gadRec.Current_Address__c = fullAddress;
                                }
                                    if(!String.isBlank(gadRec.Current_Address__c)){
                                        if(!gadListToInsert.Contains(gadRec)){
                                            gadListToInsert.add(gadRec); 
                                        }
                                        if(latLonMap.containsKey(lat)){
                                            if(!latLonMap.get(lat).contains(lon)){
                                                latLonMap.get(lat).add(lon);
                                            } 
                                        }else{
                                            latLonMap.put(lat,new List<String> {lon});
                                        }  
                                        loc.Location__c = 'In Transit';
                                        loc.Current_Location_Address__c = gadRec.Current_Address__c;
                                        loc.Current_Street_Address__c  = gadRec.Current_Street_Address__c;
                                        loc.Current_City__c  = gadRec.Current_City__c;
                                        loc.Current_State__c  = gadRec.Current_State__c;
                                        loc.Current_Zipcode__c   = gadRec.Current_Zip_Code__c;
                                        loc.Current_Country__c =  gadRec.Current_Country__c ;
                                    }
                                    
                                    if(String.isBlank(gadRec.Current_Address__c)|| test.isRunningTest()){
                                        loc.Location__c = 'In Transit';
                                        loc.Current_Location_Address__c = 'Address not in Google API data';
                                        loc.Status__c = 'Google Api Error';
                                    }
                                    
                                }
                                else{
                                    try {
                                        RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', res.getBody(), String.valueOf(res.getStatusCode()), res.getStatus(), deviceId, lat, lon, 'Address Callout API Error log','Error');            
                                    }
                                    catch(Exception ex) {
                                        RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);
                                    }
                                    loc.Location__c = 'In Transit';
                                    loc.Current_Location_Address__c = 'Address not in Google API data';
                                    loc.Status__c = 'Google Api Error';
                                }
                            }
                            else{
                                try {
                                    RedesignNL_CaptureErrors.createGoogleErrorLogs('RedesignNL_Controller', 'createGoogleAPIRecords', 'Redesign 3.0 Toggle False - But Address not in Google API data', null, null, deviceId, lat, lon, 'No callout Error log', 'Error');
                                }
                                catch(Exception ex) {
                                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'createGoogleAPIRecords', 'Exception', deviceId, null, false);                                       
                                }
                                loc.Location__c = 'In Transit';
                                loc.Current_Location_Address__c = 'Address not in Google API data';
                                loc.Status__c = 'Google Api Error';
                            }
                            
                        }
                        else {
                            loc.Location__c = 'In Transit';
                            loc.Current_Location_Address__c = GADlist[0].Current_Address__c; 
                            loc.Current_Street_Address__c  = GADlist[0].Current_Street_Address__c;
                            loc.Current_City__c  = GADlist[0].Current_City__c;
                            loc.Current_State__c  = GADlist[0].Current_State__c;
                            loc.Current_Zipcode__c   = GADlist[0].Current_Zip_Code__c;
                            loc.Current_Country__c   = GADlist[0].current_country__c;
                            String BusinessName = null;
                            if(GADlist[0].Business_Name__c != null){
                                loc.Business_Name__c = GADlist[0].Business_Name__c;
                                loc.Business_Location__Latitude__s =  GADlist[0].Business_Location__Latitude__s;
                                loc.Business_Location__Longitude__s = GADlist[0].Business_Location__Longitude__s;
                                loc.Business_Place_Id__c = GADlist[0].Business_Place_Id__c;
                            }
                            else if(RedesignMetadata.Capture_Business_Name__c == True && RedesignMetadata.Capture_BuiName_for_OldRec__c == true && GADlist[0].Business_Name__c == null && GADlist[0].Captured_Business_Name__c == False && loc.Accuracy_meters__c != null && loc.Accuracy_meters__c <= 150 && (loc.Message_Type__c == 'gps' || loc.Message_Type__c == 'wifi') && accUniqId == True){
                                getBusinessName(latfull, lngfull, GADlist[0], loc, includeList, excludeList);
                                BusinessName = GADlist[0].Business_Name__c != null ? GADlist[0].Business_Name__c : null; 
                                if(BusinessName != null && !gadListToInsert.contains(GADlist[0]) && !gadInsertMap.containsKey(GADlist[0].Id)){
                                    gadListToInsert.add(GADlist[0]);
                                    gadInsertMap.put(GADlist[0].Id,GADlist[0]);
                                }
                            }
                           
                        }
        return gadListToInsert;
    }
    public static Boolean checkGeofence(String accId, API_Response_Childs__c loc) {
        boolean flag = false;
        map<id,account> accmap = new map<id,account>();
        Set<id> accids = new Set<id>();
        
        if(accId != null){
            accids.add(accId ); 
            
            
            for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: accId]){
                accids.add(rc.Related_To__c);
            }
            //ADO - 358 Sorting account by CreatedDate desc Adding (order by createddate asc limit 1) on next line
            
            accmap = new Map<ID, Account>([select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c FROM Account where id IN : accids order by createddate asc]);
            Decimal lat = Decimal.valueOf(loc.Latitude__c);
            Decimal lon = Decimal.valueOf(loc.Longitude__c);
            
            Location loc2 = Location.newInstance(lat, lon); //response
            Double shortestDistance = 999;
            Double NestedshortDistance = 999;
            String Name = null;
            for(id acc :accids ){
                if(accMap.containskey(acc)) {
                    Location loc1 = Location.newInstance(accmap.get(acc).shippinglatitude,accmap.get(acc).shippinglongitude); //
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    system.debug('accmap.get(acc).GeoFence_Radius_in_Miles__c---'+accmap.get(acc).GeoFence_Radius_in_Miles__c);
                    if(accmap.get(acc).GeoFence_Radius_in_Miles__c != null && result <= accmap.get(acc).GeoFence_Radius_in_Miles__c && shortestDistance > result && (Name == null || Name != accmap.get(acc).name)) {
                        shortestDistance = result;
                        loc.Location__c = accmap.get(acc).name;
                        loc.CurrentLocationId__c = acc;
                        Name = accmap.get(acc).name;
                        loc.Current_Location_Address__c = accmap.get(acc).Address__c;
                        flag = true;
                        system.debug('###--acc--'+ acc + ' = ' + accmap.containskey(acc));
                        //  break;
                    }
                }
            } 
            List<Nested_Geofence__mdt> mdtList = Nested_Geofence__mdt.getall().values();
            for(Nested_Geofence__mdt mdt:mdtList) {
                if(accmap.containskey(mdt.Current_Location_Id__c) || Test.isRunningTest()){
                    Location loc1 = Location.newInstance(mdt.Latitude__c,mdt.Longitude__c);
                    Double result = Location.getDistance(loc1, loc2, 'mi');
                    if(result < mdt.Diameter__c && NestedshortDistance > result){
                        NestedshortDistance = result;
                        loc.Location__c = accmap.get(mdt.Current_Location_Id__c).name;
                        loc.CurrentLocationId__c = mdt.Current_Location_Id__c;
                        loc.Current_Location_Address__c = accmap.get(mdt.Current_Location_Id__c).Address__c;
                        loc.Facility_Location__c = mdt.Facility_Location__c;
                        flag = true;
                    }  
                }
            }
        }
        return flag ;
    }
    
    public Static void getBusinessName(String latfull, String lngfull, Google_Api_Data__c GadRec, Api_Response_childs__c loc,List<String> includeList ,List<String> excludeList){
        if (RedesignMetadata.Capture_Business_Name__c || Test.isRunningTest()) {
            Set<String> excludeType = new Set<String>();
            
            if (System.Label.Exclude_Business_types != null) {
                excludeType.addAll(System.Label.Exclude_Business_types.split(', '));
                
            }
            Set<String> priorityType = new Set<String>();
            
            if (System.Label.Priority_Business_Types != null) {
                priorityType.addAll(System.Label.Priority_Business_Types.split(', '));
            }
            Http http1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setTimeout(60000);
            req1.setMethod('GET');
            req1.setHeader('content-type', 'application/x-www-form-urlencoded');
            req1.setHeader('Accept', 'application/json');
            
            String endpt = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' + Decimal.valueOf(latfull) + ',' + Decimal.valueOf(lngfull) + '&radius=100&key=' + system.label.googleAPIKey;
            req1.setEndpoint(endpt);
            
            HttpResponse res1 = http1.send(req1);
            
            // Filter by 'establishment' type and calculate distance
            if (res1.getStatusCode() == 200) {
                gadRec.Captured_Business_Name__c = True;
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
                List<Object> results = (List<Object>) jsonResponse.get('results');
                String nearestloc;
                Location assetLocation = Location.newInstance(Decimal.valueOf(latfull), Decimal.valueOf(lngfull));
                
                // This will store business names and their data
                Map<String, Map<String, Object>> businessData = new Map<String, Map<String, Object>>();
                
                // This will store the distances
                List<Decimal> distancesSet = new List<Decimal>();
                String selectedBusinessName = null;
                Decimal selectedBusinessDistance = null;
                String SelectedMapObj = null;
                // First, filter by 'establishment' type
                for (Object resultObj : results) {
                    Set<String> excludeTypeCPY = new Set<String>(excludeType);
                    Map<String, Object> result = (Map<String, Object>) resultObj;
                    
                    // Assuming result.get('types') is a List<Object>
                    List<Object> typesAsObjects = (List<Object>) result.get('types');
                    
                    // Convert List<Object> to List<String>
                    List<String> types = new List<String>();
                    for (Object obj : typesAsObjects) {
                        types.add(String.valueOf(obj)); // Convert each Object to String and add to the list
                    }
                    
                    // Now typesAsStrings is a List<String>
                    
                    String businessName = String.valueOf(result.get('name'));
                    String PlaceId = String.valueOf(result.get('place_id'));
                    excludeTypeCPY.removeAll(types);
                    boolean typecheck= excludeType.size() != excludeTypeCPY.size();
                    // Ensure the result has types and contains 'establishment'
                    if (types != null && types.contains('establishment') && typecheck == false) {
                        // Get location from geometry
                        Map<String, Object> geometry = (Map<String, Object>) result.get('geometry');
                        Map<String, Object> locationData = (Map<String, Object>) geometry.get('location');
                        Decimal geolat = (Decimal) locationData.get('lat');
                        Decimal lng = (Decimal) locationData.get('lng');
                        Set<String> priorityTypeCPY = new Set<String>(priorityType);
                        priorityTypeCPY.removeAll(types);
                        boolean priorTypecheck= priorityType.size() != priorityTypeCPY.size();
                        // Create Location instance for the result
                        Location businessLocation = Location.newInstance(geolat, lng);
                        
                        // Calculate the distance in miles between the two locations
                        Decimal distance = Location.getDistance(businessLocation, assetLocation, 'mi');
                        
                        System.debug('Distance to ' + businessName + ' is: ' + distance + ' miles');
                        // Add the distance to the set
                        distancesSet.add(distance);
                        // Store the business data with its distance and types
                        businessData.put(businessName, new Map<String, Object>{'distance' => distance, 'types' => types,'lat'=> geolat,'lng'=>lng,'PlaceId'=> PlaceId});
                        
                        //Newly added BusinessName for top Priority types
                        if(priorTypecheck || Test.isRunningTest()){
                            String smallbusinessName = businessName.toLowerCase();
                            boolean captureBusinessName = false;
                            boolean isexcludename = false;
                            String selectedBuiword = null;
                            for(String word : excludeList){
                                word = word.toLowerCase();
                                if(smallbusinessName.contains(word) || Test.isRunningTest()){
                                    if(SelectedMapObj == businessName || Test.isRunningTest()){
                                        selectedBusinessName = null;
                                        SelectedMapObj = null;
                                        selectedBusinessDistance = null;
                                        System.debug('eclude '+ businessName);
                                    }
                                    
                                    break;
                                }
                            }
                            if(isexcludename == false){
                                for(String word : includeList){
                                    String reword = word.toLowerCase();
                                    if(smallbusinessName.contains(reword) || Test.isRunningTest()){
                                        if(selectedBusinessDistance == null || selectedBusinessDistance > distance){
                                            selectedBuiword = word;
                                            System.debug('include'+ word+' ' + businessName);
                                            captureBusinessName = true;
                                        }
                                    }else {
                                        if(selectedBusinessDistance == null || selectedBusinessDistance > distance){
                                            captureBusinessName = true;
                                            System.debug('include' + businessName);
                                        }
                                    }
                                }
                            }
                            if(captureBusinessName){
                                system.debug('sekected  '+ businessName);
                                selectedBusinessName = selectedBuiword != null ? selectedBuiword : businessName;
                                selectedMapObj = businessName;
                                selectedBusinessDistance = distance;
                            }
                        }
                    }
                }
                // Sort the distances
                distancesSet.sort();
                System.debug('/n after sorted /n');
                // Create a new sorted map to store businesses by their distance
                Map<String, Map<String, Object>> sortedBusinessData = new Map<String, Map<String, Object>>();
                
                // Iterate over the sorted distances and map them to the business data
                for (Decimal distance : distancesSet) {
                    
                    for (String businessName : businessData.keySet()) {
                        // Check if the distance matches
                        if ((Decimal) businessData.get(businessName).get('distance') == distance) {
                            // Add to the sorted business data map
                            sortedBusinessData.put(businessName, businessData.get(businessName));
                            // Once we find a match, we break out of the inner loop
                        }
                    }
                }
                
                
                // Now check for common words in business names (sorted by distance)
                for (String businessName : sortedBusinessData.keySet()) {
                    boolean containsExclude = false;
                    System.debug(businessName);
                    String smallbusinessName = businessName.toLowerCase();
                    if(selectedBusinessName != null){
                        System.debug('exhgchclude' + businessName);
                        break;
                    }
                    for(String word : excludeList){
                        word = word.toLowerCase();
                        if(smallbusinessName.contains(word)){
                            selectedBusinessName = null;
                            SelectedMapObj = null;
                            containsExclude = true;
                            System.debug('exclude' + businessName);
                            break;
                        }
                    }
                    if(containsExclude == false){
                        system.debug('inside includeList');
                        system.debug(includeList.size());
                        for(String word: includeList){
                            String reword = word.toLowerCase();
                            if(smallbusinessName.contains(reword) ){
                                selectedBusinessName = word;
                                SelectedMapObj = businessName;
                                System.debug('include ' +word +' '+ businessName);
                                break;
                            }
                        }
                        if(selectedBusinessName == null) {
                            selectedBusinessName = businessName;
                            SelectedMapObj = businessName;
                            System.debug('include ' + businessName);
                            break;
                        }
                    }
                    
                }
                
                System.debug('Selected business: ' + selectedBusinessName);
                if(selectedBusinessName != null){
                    Map<String, Object> businessObj = businessData.get(SelectedMapObj);
                    List<String> typeslst =(List<String>) businessObj.get('types');
                    loc.Business_Name__c = selectedBusinessName;
                    gadRec.Business_Name__c = selectedBusinessName;
                    gadRec.Business_Location__Latitude__s = (Decimal) businessObj.get('lat');
                    gadRec.Business_Location__Longitude__s =(Decimal) businessObj.get('lng');
                    gadRec.Likely_Business_Name_Types__c =String.join(typeslst,' , ');
                    loc.Business_Location__Latitude__s = (Decimal) businessObj.get('lat');
                    loc.Business_Location__Longitude__s =(Decimal) businessObj.get('lng');
                    loc.Business_Place_Id__c = (String) businessObj.get('PlaceId');
                    gadRec.Business_Place_Id__c = (String) businessObj.get('PlaceId');
                }
            } else { 
                System.debug('Error: ' + res1.getStatusCode());
            }
            
        }
        
    }
}