global class RedesignCardinalUpdateAsset implements Database.Batchable<sObject>, Database.Stateful, schedulable{
    public Datetime BefAssetProcDttime;
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    Map<Id,Asset> astMap = new Map<Id,Asset>();
    public Map<string,Map<String,Object>> results = new map<string,Map<String,Object>>();
    Public Api_Response__c resp = new Api_Response__c();
    List<Cardinal_Response__c> crdRespList = new List<Cardinal_Response__c>();
    public Map<string,Object> cardinalMap = new map<string,Object>();
    
    global RedesignCardinalUpdateAsset(){
        //Initializing for BatchLogs
        this.batchName='RedesignCardinalUpdateAsset';
        this.batchStartTime = system.Now();
        this.BefAssetProcDttime = system.Now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        resp= [Select Id, Name, Check_Class__c,Status__c from API_Response__c where Status__c = 'CardinalNew' order by createdDate asc Limit 1];
        crdRespList = [SELECT Id, Cardinal_Response_1__c,status__c,Response_Info__c FROM Cardinal_Response__c where status__c='New' and API_Response__c = :resp.ID order by Response_Sequence__c asc];
        List<Object> lst_JsonParse = new List<Object>();
        for(Cardinal_Response__c api : crdRespList) {
            api.Status__c = 'Processed';
            String requestBody;
            if (api.Cardinal_Response_1__c != null) { 
                requestBody =api.Cardinal_Response_1__c;
                
            }
            List<Object> sublst_JsonParse = new List<Object>();
            if(requestBody != null){
                sublst_JsonParse = (List<object>)Json.deserializeUntyped(requestBody); 
                lst_JsonParse.addALL(sublst_JsonParse);
            }
        }
        
        for (Object instance :lst_JsonParse){
            Map<String, Object> customer = new Map<String, Object>();
            customer = (Map<String,Object>)instance;
            string devID;
            if(Customer.containskey('DeviceID')){
                string cusDevID = string.valueof(Customer.get('DeviceID'));
                devID = cusDevID.toLowerCase();
            }
            if(devID != null){
                results.put(devID,customer);
                cardinalMap.put(devID,instance);
            }
        }
        Set<String> astSet = results.keySet();
        String query = 'SELECT Id, Name, Device_Id__c,RMA_Date_by_Cardinal__c,Tag_Destroyed_Date__c,Action_Needed__c,Battery_Replaced_Date__c, Field2__c,PlantID__c,PlantName__c,Rack_Type__c, Ship_To_Customer_ID__c, Ship_To_Customer_Name__c, Date_Shipped__c, Action_Needed_From_E1__c FROM Asset WHERE Device_Id__c IN :astSet';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Asset> scope){
        system.debug(scope.size());
        try{
            if(scope.size()>0){
                string anfe1res,anfe1ast;
                // Map<String, Object> Customermap = new Map<String, Object>();   Removed this line 
                for(asset ast:scope){
                    String astDevID = ast.Device_Id__c.toLowerCase();
                    Map<String, Object> Customermap = new Map<String, Object>(); //Added this line to ensure the result map assigning the right values
                    if(results.containskey(astDevID)){
                        Customermap = results.get(astDevID);
                    }
                    string devId = string.valueof(Customermap.get('DeviceID'));
                    if(devId == astDevID){
                        astMap.put(ast.Id,ast);
                        anfe1ast=ast.Action_Needed_From_E1__c;
                        
                        if(Customermap.containskey('CustomerID')){
                            ast.Field2__c = string.valueof(Customermap.get('CustomerID'));
                        }
                        if(Customermap.containskey('AssetType')){
                            ast.Rack_Type__c = string.valueof(Customermap.get('AssetType'));
                        }
                        if(Customermap.containskey('ShipToCustomerID')){
                            ast.Ship_To_Customer_ID__c = (decimal)Customermap.get('ShipToCustomerID');
                        }
                        if(Customermap.containskey('ShipToCustomerName')){
                            ast.Ship_To_Customer_Name__c =string.valueof(Customermap.get('ShipToCustomerName'));
                        }
                        if(Customermap.containskey('PlantName')){
                            ast.PlantName__c =string.valueof(Customermap.get('PlantName'));
                        }
                        if(Customermap.containskey('PlantID')){
                            ast.PlantID__c =integer.valueof(Customermap.get('PlantID'));
                        }
                        
                        if(Customermap.containskey('ActionNeededFromE1')) {
                            anfe1res= string.valueof(Customermap.get('ActionNeededFromE1'));
                            ast.Action_Needed_From_E1__c = string.valueof(Customermap.get('ActionNeededFromE1'));
                            
                            switch on anfe1res
                            {
                                when 'A' {ast.Action_Needed__c= 'Confirm RA#';}
                                when 'R' {ast.Action_Needed__c='RMA To SMART';}
                                when 'Y' {ast.Action_Needed__c='Cardinal Generic';}
                                When 'D' {ast.Action_Needed__c='Tag Destroyed';}
                                when 'B' {ast.Action_Needed__c='Replace Batteries';}
                            } 
                            if (string.isBlank(anfe1res)) {
                                if ((anfe1ast == 'A')||(anfe1ast == 'Y')) {ast.Action_Needed__c='None';}
                            }
                        }
                        string st;
                        if(Customermap.containskey('LastScanDate')){                
                            st = (string)Customermap.get('LastScanDate');
                        }
                        
                        datetime ut;
                        if(st != null){
                            ut = (DateTime)JSON.deserialize('"' + st + '"', DateTime.class);
                        }
                        if(ut!=null){
                            string ny = ut.format('yyyy-MM-dd HH:mm:ss','GMT');
                            
                            ast.Date_Shipped__c= datetime.valueOf(ny);
                        }
                        
                        string rmadate,tagdestroydate,btryreplacedate;
                        if(Customermap.containskey('RMADatebyCardinal')){                
                            rmadate = (string)Customermap.get('RMADatebyCardinal');
                        }
                        if ((rmadate != null)&&(!string.isBlank(rmadate)))
                        {
                            if (Date.valueOf(rmadate) != Date.newInstance(1900,1,1))
                                ast.RMA_Date_by_Cardinal__c= Date.valueOf(rmadate); 
                        }
                        
                        if(Customermap.containskey('TagDestroyedDate')){                
                            tagdestroydate = (string)Customermap.get('TagDestroyedDate');
                        }
                        if ((tagdestroydate != null)&& (!string.isBlank(tagdestroydate)))
                        {
                            if (Date.valueof(tagdestroydate)!=Date.newInstance(1900,1,1)) {
                                ast.Tag_Destroyed_Date__c= Date.valueOf(tagdestroydate);
                                ast.Action_Needed__c = 'Tag Destroyed';
                            }
                        }
                        
                        if(Customermap.containskey('BatteryReplacedDate')){                
                            btryreplacedate = (string)Customermap.get('BatteryReplacedDate');
                        }
                        
                        if ((btryreplacedate != null)&& (!string.isBlank(btryreplaceDate)))
                        {
                            if (Date.valueof(btryreplacedate)!= Date.newInstance(1900, 1, 1)) {
                                ast.Battery_Replaced_Date__c= Date.valueOf(btryreplacedate);
                            }                 
                        }
                    }
                }
                Utilityclass.stopTrigger1();
                List<Database.SaveResult> updateResultList = Database.update(scope, false);
                if(updateResultList.size()>0){
                    List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
                    for(Database.SaveResult ds : updateResultList){
                        if(!ds.isSuccess()){
                            Asset ast = astMap.get(ds.getId());
                            Debug_Logs__c dl = new Debug_Logs__c();
                            dl.Asset_Device_ID__c = ast.Name;
                            dl.Class_Name__c ='RedesignCardinalBatch';
                            dl.Asset__c = ast.ID;
                            dl.Incoming_Message__c = JSON.serialize(cardinalMap.get(ast.Device_Id__c));
                            for(Database.Error err : ds.getErrors()) {
                                dl.Error_Message__c = dl.Error_Message__c == null ? err.getMessage() : dl.Error_Message__c+', '+err.getMessage();
                            }
                            debugLogsToInset.add(dl);
                        }
                    }
                    if(debugLogsToInset.size()>0) {
                        insert debugLogsToInset;            
                    }
                }
            }
            
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignCardinalUpdateAsset', 'UpdateAsset', 'Exception', null, null, true); 
            resp.Status__c = 'Pending';
            for(Cardinal_Response__c ar : crdRespList) {
                ar.Status__c = 'Pending';
            }
            update resp;
            update crdRespList;
            failureMsgs.add('RedesignCardinalBatch - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    global void finish(Database.BatchableContext bc){
        try{
            if( resp.Status__c =='CardinalNew'){ 
                resp.Status__c = 'CardinalProcessed';
                for(Cardinal_Response__c ar : crdRespList) {
                    ar.Status__c = 'Processed';
                }
                update resp;
                update crdRespList;
            }
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignCardinalUpdateAsset', 'UpdateAsset', 'Exception', null, null, true); 
            resp.Status__c = 'Pending';
            for(Cardinal_Response__c ar : crdRespList) {
                ar.Status__c = 'Pending';
            }
            update resp;
            update crdRespList;
            failureMsgs.add('RedesignCardinalBatch - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
        RedesignNL_Helper.createBatchDataCustom(bc,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, null, totalRecords);
        database.executeBatch(New RedesignNL_CreateAssetHistoryBatch(),15);
    }
    global void execute(SchedulableContext sc){
        database.executebatch(new RedesignCardinalUpdateAsset(),100);
    }
}