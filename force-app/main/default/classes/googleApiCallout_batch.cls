public class googleApiCallout_batch implements Database.Batchable<sObject>, Database.stateFul, Database.AllowsCallouts{
    /* 
        createdate by : Govardhan
        created on: 25th nov 2024
        purpose : to update AHC's who current address is *googleApiCallout_batch*
	*/
     private String inputQuery = null; // Parameter to be passed

    public googleApiCallout_batch(String inputQuery) {
        this.inputQuery = inputQuery;
    }
    public DateTime batchStartTime;
    public List<string> failureMsgs = new List<string>();
    public static Integer totalFailureRecords = 0;
    public String batchStatus;
    public Integer totalRecords = 0;
    public List<Asset_History_custom__c> updateAHC = New List<Asset_History_custom__c>();
    public List<Google_API_Data__c> GADlistToInsert = New List<Google_API_Data__c>();
    public map<string , Google_API_Data__c> latlongGADmap = New  map<string , Google_API_Data__c>(); // storing here cause not to make callouts for same latlong
    
    public Database.QueryLocator start(Database.BatchableContext BC){
         this.batchStatus='Processing';
        this.batchStartTime = system.Now();
        String query = inputQuery != null ? inputQuery : 'Select id,name,Latitude__c,Longitude__c, Location__c,Current_Location_Address__c,Asset__r.Name,start_time__c from Asset_History_custom__c where Current_Location_Address__c = \'Address Pending\' order by start_time__c asc';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Asset_History_custom__c> scope){
         totalRecords += scope.size();
        for(Asset_History_custom__c ahc : scope){
            if(ahc.Latitude__c!=null && ahc.Longitude__c !=null){
                string lat = string.valueof(ahc.Latitude__c);
                string lon = string.valueof(ahc.Longitude__c);
                string latlong  = ahc.Latitude__c+'/'+ahc.Longitude__c;
                List<Google_API_Data__c> GADlist = [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,Business_Name__c,Business_Place_Id__c,Business_Location__Longitude__s,Business_Location__Latitude__s,Captured_Business_Name__c,Likely_Business_Name_Types__c,
                                                    Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c 
                                                    where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lon+'%' order by createddate DESC];
                if(GADlist.size()==0){
                    if(!latlongGADmap.keyset().contains(latlong)){
                        Http h = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setTimeout(60000);
                        req.setMethod('GET');
                        req.setHeader('content-type','application/x-www-form-urlencoded');
                        req.setHeader('Accept', 'application/json'); 
                        string endpt = 'https://maps.googleapis.com/maps/api/geocode/json?key='+system.label.googleAPIKey+'&latlng='+Decimal.valueOf(lat)+'%20'+Decimal.valueOf(lon)+'&sensor=true';
                        system.debug(endpt);    
                        req.setEndpoint(endpt);
                        HttpResponse res = h.send(req);
                        system.debug('###--res--'+ res);
                        if(res.getStatusCode() == 200){    
                            Google_API_Data__c gadRec = new Google_API_Data__c(Latitude__c=lat, Longitude__c=lon);
                            
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
                                ahc.Current_Location_Address__c = gadRec.Current_Address__c; //updating address in AHC
                                ahc.Current_Street_Address__c  = gadRec.Current_Street_Address__c;
                                ahc.Current_City__c  = gadRec.Current_City__c;
                                ahc.Current_State__c  = gadRec.Current_State__c;
                                ahc.Current_Zipcode__c   = gadRec.Current_Zip_Code__c;
                                ahc.Current_Country__c =  gadRec.Current_Country__c ;
                                updateAHC.add(ahc);
                                if(!latlongGADmap.keyset().contains(latlong))
                                    latlongGADmap.put(latlong , gadRec);
                                if(!GADlistToInsert.Contains(gadRec)){
                                    GADlistToInsert.add(gadRec);  //adding into list to insert
                                }
                            }
                        }
                    }else{
                        Google_API_Data__c gad1 = latlongGADmap.get(latlong);
                        ahc.Current_Location_Address__c = gad1.Current_Address__c; //updating address in AHC
                        ahc.Current_Street_Address__c  = gad1.Current_Street_Address__c;
                        ahc.Current_City__c  = gad1.Current_City__c;
                        ahc.Current_State__c  = gad1.Current_State__c;
                        ahc.Current_Zipcode__c   = gad1.Current_Zip_Code__c;
                        ahc.Current_Country__c =  gad1.Current_Country__c ;
                        updateAHC.add(ahc);
                    }
                }else{
                    ahc.Current_Location_Address__c = GADlist[0].Current_Address__c;
                        ahc.Current_Street_Address__c  = GADlist[0].Current_Street_Address__c;
                        ahc.Current_City__c  = GADlist[0].Current_City__c;
                        ahc.Current_State__c  = GADlist[0].Current_State__c;
                        ahc.Current_Zipcode__c   = GADlist[0].Current_Zip_Code__c;
                        ahc.Current_Country__c =  GADlist[0].Current_Country__c ;
                    updateAHC.add(ahc);
                }
                
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        try{
            if(GADlistToInsert.size()>0)
                insert GADlistToInsert;
            if(updateAHC.size()>0)
                update updateAHC;

        }catch(DMLException e){
             failureMsgs.add('googleApiCallout_batch - while updating AHC records. Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, 'googleApiCallout_batch', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
        
    }
}