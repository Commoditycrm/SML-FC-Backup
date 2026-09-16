global class ProcessOLESmartPalletsData_Batch implements Database.Batchable<sObject>,Database.Stateful {
    
    public  List<account> accList = New List<Account>();
    public String batchName;
    public String batchStatus;
    public DateTime batchStartTime;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext context){
        this.batchName='ProcessOLESmartPalletsData_Batch';
        this.batchStartTime = system.Now();
        accList = [Select Id, Name from Account where Name = 'Testing'];
        return Database.getQueryLocator('Select id,name,Incoming_Messsage__c,Status__c,CreatedDate,LastModifiedDate, Shipment_BOL_Number__c,Order_Type__c,Shipped_From_Zip_code__c,Shipped_To_Zip_code__c,Shipped_Date__c,Shipped_method__c,'+
                                        'Ship_To_Customer_Name__c,Refrig_Flag__c,Smart_Pallets__c,PlantId__c, Ship_To_Customer_ID__c from APi_response__c where check_class__c = \'SmartPallet Data\' and Status__c = \'NEW\' order by createddate Asc ');
    }
    
    global void Execute(Database.BatchableContext context, List<API_Response__c> scope){
        this.batchStatus = 'Processing';
        totalRecords += scope.size();
        try{
            Set<String> allAssetNames = new Set<String>();
            Map<String, API_Response__c> assetNameToResponseMap = new Map<String, API_Response__c>();
            
            for (API_Response__c response : scope) {
                if (String.isNotBlank(response.Smart_Pallets__c)) {
                    List<String> assetNames = response.Smart_Pallets__c.split(', ');
                    
                    for (String assetName : assetNames) {
                        String ast = assetName.trim().toLowerCase();
                        if (!String.isBlank(ast)) {
                            allAssetNames.add(ast);
                            assetNameToResponseMap.put(ast, response);
                        }
                    }
                }
            }
            
            
            Map<string, Asset> assetsToUpdateMap = new Map<String, Asset>();
            List<Asset> astList = [select id, name,Ship_To_Customer_ID_SmartPallet__c, Field2__c, Refrig_Flag__c, Shipment_BOL_Number__c,PlantID_SmartPallet__c,Order_Type__c,Shipped_From_Zip_code__c,Shipped_To_Zip_code__c,Shipped_Date__c,Shipped_method__c,
                                   Ship_To_Customer_Name__c, PlantID__c, Ship_To_Customer_ID__c from Asset where Field2__c IN : allAssetNames];
            If(astList.size()>0){
                for(Asset ast : astList){
                    assetsToUpdateMap.put(ast.Field2__c.toLowerCase(),ast);
                }
            }
            //for update and creating new asset
            /*for(string ast : assetNameToResponseMap.keySet()){
                if(assetsToUpdateMap.containsKey(ast)){
                    assetsToUpdateMap.get(ast).Shipment_BOL_Number__c = assetNameToResponseMap.get(ast).Shipment_BOL_Number__c;
                    assetsToUpdateMap.get(ast).Order_Type__c = assetNameToResponseMap.get(ast).Order_Type__c;
                    assetsToUpdateMap.get(ast).Shipped_From_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_From_Zip_code__c;
                    assetsToUpdateMap.get(ast).Shipped_To_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_To_Zip_code__c;
                    assetsToUpdateMap.get(ast).Shipped_Date__c = assetNameToResponseMap.get(ast).Shipped_Date__c;
                    assetsToUpdateMap.get(ast).Shipped_method__c = assetNameToResponseMap.get(ast).Shipped_method__c;
                    assetsToUpdateMap.get(ast).Ship_To_Customer_Name__c = assetNameToResponseMap.get(ast).Ship_To_Customer_Name__c;
                } else{
                    Asset Newast = new Asset(); 
                    Newast.AccountId = accList[0].Id;
                    Newast.Device_Id__c = ast;
                    Newast.Name = ast;
                    Newast.AssetProvidedById = accList[0].Id;
                    Newast.Shipment_BOL_Number__c = assetNameToResponseMap.get(ast).Shipment_BOL_Number__c;
                    Newast.Order_Type__c = assetNameToResponseMap.get(ast).Order_Type__c;
                    Newast.Shipped_From_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_From_Zip_code__c;
                    Newast.Shipped_To_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_To_Zip_code__c;
                    Newast.Shipped_Date__c = assetNameToResponseMap.get(ast).Shipped_Date__c;
                    Newast.Shipped_method__c = assetNameToResponseMap.get(ast).Shipped_method__c;
                    Newast.Ship_To_Customer_Name__c = assetNameToResponseMap.get(ast).Ship_To_Customer_Name__c;
                    assetsToUpdateMap.put(ast,Newast);               
                }
                
            }*/
            //for updating existing assets
            for(String ast : assetsToUpdateMap.keySet()){
                if(assetNameToResponseMap.containsKey(ast)){
                    assetsToUpdateMap.get(ast).Shipment_BOL_Number__c = assetNameToResponseMap.get(ast).Shipment_BOL_Number__c;
                    assetsToUpdateMap.get(ast).Order_Type__c = assetNameToResponseMap.get(ast).Order_Type__c;
                    assetsToUpdateMap.get(ast).Shipped_From_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_From_Zip_code__c;
                    assetsToUpdateMap.get(ast).Shipped_To_Zip_code__c = assetNameToResponseMap.get(ast).Shipped_To_Zip_code__c;
                    assetsToUpdateMap.get(ast).Shipped_Date__c = assetNameToResponseMap.get(ast).Shipped_Date__c;
                    assetsToUpdateMap.get(ast).Shipped_method__c = assetNameToResponseMap.get(ast).Shipped_method__c;
                    assetsToUpdateMap.get(ast).Ship_To_Customer_Name__c = assetNameToResponseMap.get(ast).Ship_To_Customer_Name__c;
                    assetsToUpdateMap.get(ast).PlantID_SmartPallet__c = assetNameToResponseMap.get(ast).PlantId__c;
                    assetsToUpdateMap.get(ast).Ship_To_Customer_ID_SmartPallet__c = assetNameToResponseMap.get(ast).Ship_To_Customer_ID__c;
                    assetsToUpdateMap.get(ast).Refrig_Flag__c = assetNameToResponseMap.get(ast).Refrig_Flag__c;
                }
            }
            
            if (!assetsToUpdateMap.isEmpty()) {
                Update assetsToUpdateMap.values(); 
            }
            
            for (API_Response__c response : scope) {
                response.Status__c = 'PROCESSED';
            }
            update scope; 
        }catch(Exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'ProcessOLESmartPalletsData_Batch', 'ExecuteMethod', 'Exception', null, null, true);
            failureMsgs.add('ProcessOLESmartPalletsData_Batch - ExecuteMethod. Error msg: '+ex.getMessage());
            totalFailureRecords = totalFailureRecords + 1;
        }
    }
    global void finish(Database.BatchableContext BC){
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        } 
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
    }
}