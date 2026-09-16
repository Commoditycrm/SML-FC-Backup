@RestResource(urlMapping='/locoawareapi/*')

 //global to public (check with class)
global class  LocoAwareTestControler {
    global static Asset ast= new Asset();
    global static String deviceId;
    global static string devTs;
    global static string model;
    global static Redesign_NL__mdt RedesignMetadata = RedesignNL_Helper.getRedesignMetadata('Default');
    global static Datetime currentDateTime; 
  //global to public

    @HttpPost
     global static string parseResponse() {
        String requestBody = RestContext.request.requestBody.toString();
        String authHeader = RestContext.request.headers.get('X-API-Key');

        if (validateHeader(authHeader)) {
            //return 'Response recived sucessfully';
            return parseRequestBody(requestBody); 
        }else
        {
            return 'Invalid Authorization Header :'+authHeader + RestContext.request.headers;
        } 

    }

    private static Boolean validateHeader(String headerValue) {
        // Expected header value
        String expectedHeaderValueNew = System.label.Loco_Ware_API_Key;// use label
        String expectedHeaderValueOld = System.label.Loco_Ware_API_Key_Old;// use label

        // Check if the header matches the expected value
        Boolean isValid = headerValue != null && (headerValue.equals(expectedHeaderValueNew) || headerValue.equals(expectedHeaderValueOld));
        return Test.isRunningTest() ? true : isValid;
    }

    public static String parseRequestBody(String requestBody) {          

        List<API_Response_Childs__c> locApiResp;
        List<API_Response_Childs__c> tempApiResp;
        currentDateTime = System.now().addDays(1);

        if(requestBody == null || requestBody == ''){
            return 'please Send a valid response';
            }
        try {       
            if(requestBody != null){
                Api_Response__c resp = new Api_Response__c();
                string locationTs;
                Map<String, Object> location = new Map<String, Object>();
                Map<String, Object> deviceData = new Map<String, Object>();
                string facilityLoc;
                decimal rssi;
                Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(requestBody);
                    if (lst_JsonParse.containsKey('rxTime')) {
                        model =  String.valueOf(lst_JsonParse.get('model'));
                        devTs = String.valueof(lst_JsonParse.get('rxTime'));
                        //TimestampConverter.convertUnixTimestampToGMT((Long)dvcMap.get('ts'));  
                    }
                    if (lst_JsonParse.containsKey('pos')) {
                         location = (Map<String, Object>)lst_JsonParse.get('pos');
                         locationTs = string.valueOf(location.get('time'));
                    }
                    if (lst_JsonParse.containskey('status')){
                        deviceData = (Map<String, Object>)lst_JsonParse.get('status');
                        deviceId = String.valueOf(lst_JsonParse.get('deviceId'));
                    }
                    if (lst_JsonParse.containskey('master')){
                        facilityLoc = String.valueOf(lst_JsonParse.get('master'));
                    }
                    if (lst_JsonParse.containskey('rssi')){
                        rssi = ((decimal)lst_JsonParse.get('rssi')*(-1));
                        if(rssi >=-2){
                            rssi = 0;
                        }
                    }
                	getAssetSummary(deviceId,model);
                locApiResp = CreateLocApi(deviceData, location,devTs);
                tempApiResp = createTempArc(deviceData,devTs);
                if (locApiResp.size() > 0){
                    if(!Test.isRunningTest())
                    	utilityClass_Controller.createGoogleAPIRecords(locApiResp, deviceId,ast);
                   
                   if (ast!= null){
                    resp.Asset__c = ast.id;
                    resp.Incoming_Messsage__c =requestBody; 
                    resp.ResEnteringDttime__c = system.now(); 
                    resp.ResEnteringTime__c = (system.now().getTime()/1000);
                    resp.Location_TimeStamp__c = locationTs !=null ? locationTs : null;
                    resp.ResEnteringDttime__c = system.now();
                    resp.Is_Nimbelink_Asset__c = true;
                    resp.Device_Id__c = deviceId;
                    resp.Device_Status__c = String.valueof(deviceData);
                    resp.loc__c = String.valueof(location);
                    resp.Redesigned_Processed__c = true;
                    resp.Asset__c = ast.Id;
                    resp.status__c= 'New';
                   }
                   try{ 
                    upsert resp;
                    Resp = [Select Id, Name, Status__c from API_Response__c where Id =: resp.Id];
                    List<Decimal> duplicateLocArc = new List<Decimal>();
                    for(API_Response_Childs__c arc : locApiResp){
                        arc.API_Response__c = resp.id;
                        arc.Asset__c = ast.id;
                        arc.Facility_Location__c = facilityLoc;
                        if(ast.Product_Name__c=='Tag-e4bl-1-0'){
                            arc.rssi__c = rssi;
                        }
                        arc.Name = resp.Name +'-'+ RedesignNL_Helper.ArcLocationRecordtype;
                        if(duplicateLocArc.contains(arc.Timestamp__c)){
                            arc.status__c = 'Duplicate';
                        }else{
                            arc.Status__c=setARCStatus(arc, resp);
                            duplicateLocArc.add(arc.Timestamp__c);
                        }
                    }
                    try{
                        insert locApiResp ;
                    }catch (DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
                                API_Response_Childs__c failedRecord = locApiResp[e.getDmlIndex(i)];
                                failedRecord.Status__c = 'Duplicate';
                                failedRecord.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                                try {
                                    insert failedRecord;
                                } catch (DmlException ex) {
                                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                                }
                            }
                        }
                    }
                   }
                   catch(DmlException er){
                    RedesignNL_CaptureErrors.createErrorLogs(er, 'LocoAwareController', 'parseRequestBody', 'API Error', deviceId, requestBody, false);
                   }
                
                }
                List<Decimal> duplicateTempArc = new List<Decimal>();
                if(tempApiResp.size() > 0 && resp.id!=null){
                    for(API_Response_Childs__c arc : tempApiResp){
                        arc.API_Response__c = resp.id;
                        arc.Asset__c = ast.id;
                        arc.Name = resp.Name +'-'+ RedesignNL_Helper.ArcTemperatureRecordtype;
                        //setARCStatus(arc, resp);
                        if(duplicateTempArc.contains(arc.Timestamp__c)){
                            arc.status__c = 'Duplicate';
                        }else{
                            arc.Status__c=setARCStatus(arc, resp);
                            duplicateTempArc.add(arc.Timestamp__c);
                        }

                    }
                    // try catch block
                    try {
                        insert tempApiResp;
                    } catch (DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            if (e.getDmlMessage(i).containsIgnoreCase('duplicate value found: ARC_External_Id__c duplicates value on record with id')) {
                                API_Response_Childs__c failedRecord = tempApiResp[e.getDmlIndex(i)];
                                failedRecord.Status__c = 'Duplicate';
                                failedRecord.ARC_External_Id__c += '~Duplicate'+System.now()+integer.valueof(Math.random() * 999);
                                try {
                                    insert failedRecord;
                                } catch (DmlException ex) {
                                    RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_Controller', 'Duplicate', 'Exception', deviceId, null, false);
                                }
                            }
                        }
                    }
                }
                
            }    
        	return 'Successfully Recieved response';

        //return devId != null ? devId : 'Name field is null in model';
    } catch (Exception e) {
        return 'Error parsing JSON: ' + e.getMessage()+ ' : '+ e.getCause()+' : '+ e.getStackTraceString()+' : '+ e.getLineNumber()+' : '+ e.getTypeName();
    }
    }
    
    public static void getAssetSummary(String devId,string model){
        List<Asset> assetLst = [Select Id, Name,AccountId,Capture_Movement_Event__c,Dormant_Days__c,Last_Connected__c,Last_connected2__c, device_id__c,isNew_Asset__c,Product_Name__c  from Asset where device_id__c =: deviceId];
        if(assetLst.size()>0) {
            ast = assetLst[0];  
        } 
        else {
            List<Account> accList = [Select Id, Name from Account where Name = 'Testing'];
            if(accList.size() > 0) {
                ast = new Asset(); 
                ast.AccountId = accList[0].Id;
                ast.Device_Id__c = devId;
                ast.Name = devId;
                ast.AssetProvidedById = accList[0].Id;
                ast.Product2Id  = getModel (model);
                ast.Is_Loco_Asset__c= true;
                insert ast;
            }
        }
    }
    public static string getModel(string model){
         List <Product2> modelID = [Select id,Name from Product2 where Name =: model];
         Product2 prod = new Product2();
        if (modelID.size()>0){
            return modelID[0].Id;
        }
        else {
            prod.Name = model;
            prod.IsActive = true;
            insert prod;
            return prod.Id;
        }
    }

    public static List<API_Response_Childs__c> createTempArc(Map<String, Object> devStatus,string devts) {
        List<API_Response_Childs__c> Temparc = new List<API_Response_Childs__c>();    
        API_Response_Childs__c arc = new API_Response_Childs__c();
        arc.asset__c =ast.id;
            arc.RecordTypeId =  RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcTemperatureRecordtype);
            arc.Temperature__c = devStatus.containskey('temperature') ? 1.8 * (decimal) devStatus.get('temperature') + 32 : null;
            arc.Timestamp__c = decimal.valueOf(devts);
            arc.Timestamp_DateTime__c = DateTime.newInstance(Long.valueOf(devts));
            arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + 'Temp';

            Temparc.add(arc);
        return Temparc; 
    }

    public static List<API_Response_Childs__c> CreateLocApi(Map<String, Object> devStatus, Map<String, Object> locData,string devts) {
        List<API_Response_Childs__c> locArc = new List<API_Response_Childs__c>();    
        API_Response_Childs__c arc = new API_Response_Childs__c();
        arc.asset__c =ast.id;
            arc.RecordTypeId =  Schema.SObjectType.API_Response_Childs__c.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    
            if (locData.containsKey('time') && locData.get('time') != null) {
                arc.Timestamp__c = (decimal) locData.get('time');
                arc.Timestamp_DateTime__c = DateTime.newInstance((Long)locData.get('time'));
            }
            if (locData.containsKey('lat') && locData.get('lat') != null) {
                arc.latitude__c = String.valueof(locData.get('lat'));
                arc.haccRank__c = 0;
            }
            if (locData.containsKey('lon') && locData.get('lon') != null) {
                arc.longitude__c =  String.valueof(locData.get('lon'));
            }
            if (locData.containsKey('cep') && locData.get('cep') != null) {
                arc.Accuracy_meters__c = (decimal) locData.get('cep');
                arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + '~Location';
            }
        	if (!locData.containsKey('time')) {
                arc.ARC_External_Id__c = arc.Asset__c + '~' + arc.Timestamp__c + '~dev';
                arc.Timestamp__c = decimal.valueOf(devts);
                arc.Timestamp_DateTime__c = DateTime.newInstance(Long.valueOf(devts));
            }
    
        // Process device status
        arc.PowerUptime__c = 0;
        if (devStatus.containsKey('batteryVoltage') && devStatus.get('batteryVoltage') != null) {
            arc.Battery__c = (decimal)devStatus.get('batteryVoltage');
            }
        if(devts!=null){
            arc.Timestamp_Device_Status__c = decimal.valueOf(devts);
            arc.Timestamp_Date_Time_Device_Status__c =  DateTime.newInstance(Long.valueOf(devts));
        }
        if (devStatus.containsKey('signal') && devStatus.get('signal') != null && ast.Product_Name__c =='LTP-HGC4-1-0') {
            arc.rssi__c = ((decimal)devStatus.get('signal')*(-1));
            if(arc.rssi__c>=-2){
                arc.rssi__c = 0;
            }
        }     
        if (devStatus.containsKey('batteryLevel') && devStatus.get('batteryLevel') != null) {
            arc.EstBattPct__c =(decimal) devStatus.get('batteryLevel');
            }
            locArc.add(arc);
        return locArc;
    }
    
    public static String setARCStatus(API_Response_Childs__c arc, API_Response__c resp) {   

        if(utilityTS.futueTs(arc.Timestamp_Datetime__c)) {
            return 'FutureTS';
        }
        else if(String.valueof(arc.Timestamp__c).startsWith('1104') && arc.PowerUptime__c != null && arc.Latitude__c == null ){
            return 'New';
        }
        else if(Ast.Dormant_Days__c == true & arc.Timestamp_Datetime__c < currentDateTime) {
            if(Ast.Last_Connected__c > arc.Timestamp_Datetime__c)
                return 'BackdatedTS';
            else {
                if(resp != null && resp.Status__c != null)
                    return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed': 'New' ;                
                return 'New';
            }
        }                  
        else if(Ast.Dormant_Days__c == false & arc.Timestamp_Datetime__c < currentDateTime) {
            Integer daysDifference = currentDateTime.date().daysBetween(arc.Timestamp_Datetime__c.date());
            daysDifference = Math.abs(daysDifference); // This will make daysDifference positive
            Redesign_NL__mdt Redesign=RedesignNL_Helper.getRedesignMetadata('Default');
            Integer dormantDays = Integer.valueOf(Redesign.Dormant_Days__c);
            if (daysDifference > dormantDays) {
                return 'BackdatedTS';
            }else{
                if(resp != null && resp.Status__c != null)
                    return resp.Status__c.equalsIgnoreCase('PROCESSED') ? 'Processed': 'New' ;                
                return 'New';
            }
        }
        else
            return 'Pending';
    }
}