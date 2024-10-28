global class RedesignCardinalBatch implements Database.Batchable<sObject>, Database.Stateful{
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus = 'Processing';
        this.batchStartTime = System.Now(); 
return Database.getQueryLocator([Select Id, Name, Check_Class__c,Status__c from API_Response__c where Status__c = 'CardinalNew']);
    }
    global void execute(Database.BatchableContext BC, List<API_Response__c> scope) {
        Id apiRespId = scope[0].Id;
        List<Cardinal_Response__c> crdRespList = [SELECT Id, Cardinal_Response_1__c,status__c,Response_Info__c FROM Cardinal_Response__c where status__c='New' and API_Response__c = :apiRespId order by Response_Sequence__c asc];
        boolean checkDebug = False;
        List<Asset> astlist = new list<Asset>();
        Map<Id,Asset> astMap = new Map<Id,Asset>();
        Map<string,Map<String,Object>> results = new map<string,Map<String,Object>>();
        try{
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
                Map<String, Object> customer = new Map<String, Object>();
                for (Object instance :lst_JsonParse){
                    customer = (Map<String,Object>)instance;
                    string devID;
                    if(Customer.containskey('DeviceID'))
                        devID = string.valueof(Customer.get('DeviceID'));
                    if(devID != null)
                        results.put(devID,customer);
                    
                }
                List<Asset> assetList =[select id,Name,Device_Id__c,Field2__c,Rack_Type__c,Ship_To_Customer_ID__c,Ship_To_Customer_Name__c,Date_Shipped__c,Action_Needed_From_E1__c from Asset where Device_Id__c IN:results.keyset()];
                for(Asset ast: assetList){
                    astMap.put(ast.Id,ast);
                }
                
                string anfe1res,anfe1ast;
                Map<String, Object> Customermap = new Map<String, Object>();
                for(asset ast:assetList){
                    
                    anfe1ast=ast.Action_Needed_From_E1__c;
                    if(results.containskey(ast.Device_ID__c))
                        Customermap = results.get(ast.Device_ID__c);
                    if(Customermap.containskey('CustomerID'))
                        ast.Field2__c = string.valueof(Customermap.get('CustomerID'));
                    if(Customermap.containskey('AssetType'))
                        ast.Rack_Type__c = string.valueof(Customermap.get('AssetType'));
                    if(Customermap.containskey('ShipToCustomerID'))
                        ast.Ship_To_Customer_ID__c = (decimal)Customermap.get('ShipToCustomerID');
                    if(Customermap.containskey('ShipToCustomerName'))
                        ast.Ship_To_Customer_Name__c =string.valueof(Customermap.get('ShipToCustomerName'));
                    if(Customermap.containskey('PlantName'))
                        ast.PlantName__c =string.valueof(Customermap.get('PlantName'));
                    if(Customermap.containskey('PlantID'))
                        ast.PlantID__c =integer.valueof(Customermap.get('PlantID'));
                    
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
                    if(Customermap.containskey('LastScanDate'))                
                        st = (string)Customermap.get('LastScanDate');
                    
                    datetime ut;
                    if(st != null){
                        ut = (DateTime)JSON.deserialize('"' + st + '"', DateTime.class);
                    }
                    if(ut!=null){
                        string ny = ut.format('yyyy-MM-dd HH:mm:ss','GMT');
                        
                        ast.Date_Shipped__c= datetime.valueOf(ny);
                    }
                    
                    string rmadate,tagdestroydate,btryreplacedate;
                    if(Customermap.containskey('RMADatebyCardinal'))                
                        rmadate = (string)Customermap.get('RMADatebyCardinal');
                    if ((rmadate != null)&&(!string.isBlank(rmadate)))
                    {
                        if (Date.valueOf(rmadate) != Date.newInstance(1900,1,1))
                            ast.RMA_Date_by_Cardinal__c= Date.valueOf(rmadate); 
                    }
                    
                    if(Customermap.containskey('TagDestroyedDate'))                
                        tagdestroydate = (string)Customermap.get('TagDestroyedDate');
                    if ((tagdestroydate != null)&& (!string.isBlank(tagdestroydate)))
                    {
                        if (Date.valueof(tagdestroydate)!=Date.newInstance(1900,1,1)) {
                            ast.Tag_Destroyed_Date__c= Date.valueOf(tagdestroydate);
                            ast.Action_Needed__c = 'Tag Destroyed';
                        }
                    }
                    
                    if(Customermap.containskey('BatteryReplacedDate'))                
                        btryreplacedate = (string)Customermap.get('BatteryReplacedDate');
                    
                    if ((btryreplacedate != null)&& (!string.isBlank(btryreplaceDate)))
                    {
                        if (Date.valueof(btryreplacedate)!= Date.newInstance(1900, 1, 1)) {
                            ast.Battery_Replaced_Date__c= Date.valueOf(btryreplacedate);
                        }                 
                    }
                    if(!astlist.contains(ast)){
                    astlist.add(ast);
                    }
                }
                Utilityclass.stopTrigger1();
             
            if(astlist.size()>0){
                List<Database.SaveResult> updateResultList = Database.update(astlist, false);
                if(updateResultList.size()>0){
                    List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
                    for(Database.SaveResult ds : updateResultList){
                        if(!ds.isSuccess()){
                            checkDebug = true;
                            Asset ast = astMap.get(ds.getId());
                            Debug_Logs__c dl = new Debug_Logs__c();
                            dl.Asset_Device_ID__c = ast.Name;
                            dl.Class_Name__c ='RedesignCardinalBatch';
                            dl.Asset__c = ast.ID;
                            dl.Incoming_Message__c = string.valueof(results.get(ast.Device_Id__c));
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
            if(checkDebug == false) {
                for(API_Response__c ar : scope) {
                    ar.Status__c = 'CardinalProcessed';
                }
                update scope;
                update crdRespList;
            }
        }
        catch(DMLException e) {
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignCardinalBatch', 'UpdateAsset', 'Exception', null, null, true); 
            if(scope.size()>0){
                scope[0].Status__c= 'Pending';
                update scope[0];
            }
            failureMsgs.add('RedesignCardinalBatch - Error msg: '+e.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
            this.batchStatus = 'Failed';
        }
    }
    global void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks here
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed'; 
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC, null, 'RedesignCardinalBatch', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
       
        RedesignNL_CreateEventHistoryBatch.scheduleBatch();
    }    
}