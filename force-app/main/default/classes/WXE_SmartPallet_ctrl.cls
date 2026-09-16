@RestResource(urlMapping='/ProcessSmartPalletData/*')
global class WXE_SmartPallet_ctrl {
    
    @HttpPost
    global static String parseSmartPalletResponse() {
        String requestBody = RestContext.request.requestBody.toString();
        try{
            Set<string> lpnList = New Set<string>();
            // below code find lPN's before deserialize 
            Pattern p = Pattern.compile('"lpn"\\s*:\\s*"([^"]+)"');
            Matcher m = p.matcher(requestBody);
            while (m.find()) {
                lpnList.add(m.group(1));
            }
            
            Map<string, Asset> assetsToUpdateMap = new Map<String, Asset>();
			List<Asset> astList = [select id,name, Field2__c, Shipment_BOL_Number__c,Order_Type__c,Shipped_From_Zip_code__c,Shipped_To_Zip_code__c,Shipped_Date__c,Shipped_method__c,
                                   Ship_To_Customer_Name__c from Asset where Field2__c IN : lpnList];
            If(astList.size()>0){
                for(Asset ast : astList){
                    assetsToUpdateMap.put(ast.Field2__c.toLowerCase(),ast);
                }
            }  
            string unavailablelpns = null ;
            string availablelpns =null;
            if(lpnList.size()>0){
                for(string Lpn : lpnList){
                    if(assetsToUpdateMap.containsKey(lpn.toLowerCase())){
                        availablelpns = availablelpns == null ? availablelpns = lpn : +availablelpns +', '+ lpn;
                    }else{
                        unavailablelpns = unavailablelpns == null ? unavailablelpns = lpn : +unavailablelpns +', '+ lpn;

                    }
                }
            }
            
            Map<String, Object> responseMap = (Map<String, Object>)Json.deserializeUntyped(requestBody);
            Api_Response__c apires = new Api_Response__c();
            apires.check_class__c = 'SmartPallet Data';
            apires.Status__c = 'NEW';
            apires.Incoming_Messsage__c =requestBody; 
            apires.ResEnteringDttime__c = system.now(); 
            apires.ResEnteringTime__c = (system.now().getTime()/1000);
            if(responseMap.containsKey('bolnumber')){
                apires.Shipment_BOL_Number__c = Decimal.valueof(string.valueof(responseMap.get('bolnumber')));
            }
            if(responseMap.containsKey('ordertype')){
                apires.order_type__c =string.valueof(responseMap.get('ordertype'));
            }
            if(responseMap.containsKey('zipcodefrom')){
                apires.shipped_from_zip_code__c = Decimal.valueof(string.valueof(responseMap.get('zipcodefrom')));
            }
            if(responseMap.containsKey('zipcodeto')){
                apires.shipped_to_zip_code__c = Decimal.valueof(string.valueof(responseMap.get('zipcodeto')));
            }
            if(responseMap.containsKey('shipclosedate')){
                apires.shipped_date__c = date.valueof(string.valueof(responseMap.get('shipclosedate')));
            }
            if(responseMap.containsKey('shipmethod')){
                apires.shipped_method__c =string.valueof(responseMap.get('shipmethod'));
            }
            if(responseMap.containsKey('customername')){
                apires.ship_to_customer_name__c = string.valueof(responseMap.get('customername'));
            }
            if(responseMap.containsKey('whsitenumber')){
                apires.PlantId__c = string.valueof(string.valueof(responseMap.get('whsitenumber')));
            }
            if(responseMap.containsKey('custnumber')){
                apires.Ship_To_Customer_ID__c = string.valueof(responseMap.get('custnumber'));
            }
            if(responseMap.containsKey('refrigflag')){
                apires.Refrig_Flag__c = string.valueof(responseMap.get('refrigflag'));
            }
            /*if(responseMap.containsKey('smartpallets')){
                List<object> lpnObj = (List<Object>) responseMap.get('smartpallets');
                if(lpnObj.size()>0){
                    for(object obj : lpnObj){
                        Map<string,object> lnpMap = (Map<String, Object>)obj;
                        if(lnpMap.containsKey('lpn')){
                            lpnList.add(string.valueof(lnpMap.get('lpn')));
                        }
                        
                    }
                }
            }
            if(lpnList.size()>0){
                apires.smart_pallets__c =  String.join(lpnList, ', ');
            }*/
            apires.smart_pallets__c =  availablelpns;
            apires.Unavailable_SmartPallets__c  =  unavailablelpns;
            try{
                insert apires;
            }catch (Exception ex) {
                RedesignNL_CaptureErrors.createErrorLogs(ex, 'WXE_SmartPallet_ctrl', 'parseSmartPalletResponse', 'API Error', null, requestBody, false);
                return 'Error: ' + ex.getMessage();
        	}
            if(unavailablelpns==null && unavailablelpns!=''){
                return 'Successful!';
            }else{
                return 'Successfully received, but did not recognize the following LPNs: '+unavailablelpns;
            }
            
        }catch (Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'WXE_SmartPallet_ctrl', 'parseSmartPalletResponse','Exception', null, requestBody, false);
			return 'Error: ' + ex.getMessage();
        }
        
        
    }
    
    
}