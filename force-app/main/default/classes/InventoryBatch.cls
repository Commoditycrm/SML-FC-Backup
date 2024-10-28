global class InventoryBatch implements Database.Batchable<sObject>,schedulable,Database.Stateful {
    public DateTime batchStartTime;
    public map<string,integer> invcomboMap;
    global InventoryBatch(){
        this.invcomboMap = new map<string,integer>();
        this.batchStartTime = system.Now(); 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query ='select id,name,Current_Location__c,State_of_Pallet__c,Rack_Type__c,AccountId, Last_Known_Location__c from asset where Is_Access_Point__c = false and AccountId!=null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<asset> scope ){
        try{
            list<Inventory__c> updatelist = new list<Inventory__c>();  
            
            list<id> accLst = new list<id>();
            list<id> currentlocationLst = new list<id>();
            map<string,integer> inventorycombocount = new map<string,integer>();      
            integer count;
            for(asset ast :scope){
                //  system.debug(ast);
                acclst.add(ast.accountid);
                if(ast.Current_Location__c != null){
                    currentlocationLst.add(ast.Current_Location__c);
                    string key = ast.AccountId+'*'+ast.Current_Location__c+'*'+ast.Rack_Type__c;
                    if(invcomboMap.containskey(key)){
                        
                        count = invcomboMap.get(key);
                        count = count + 1;
                        invcomboMap.put(key, count); 
                        inventorycombocount.put(key, count); 
                    }else{
                        invcomboMap.put(key, 1);
                        inventorycombocount.put(key, 1);    
                    }
                }else if(ast.State_of_Pallet__c == 'In transit'){    
                    string key = ast.AccountId+'*'+'In transit'+'*'+ast.Rack_Type__c;
                    if(invcomboMap.containskey(key)){
                        
                        count = invcomboMap.get(key);
                        count = count + 1;
                        invcomboMap.put(key, count); 
                        inventorycombocount.put(key, count); 
                    }else{
                        invcomboMap.put(key, 1);
                        inventorycombocount.put(key, 1);    
                    }    
                }
                
                if(ast.Last_Known_Location__c != null){
                    currentlocationLst.add(ast.Last_Known_Location__c);
                    string key = ast.AccountId+'*'+ast.Last_Known_Location__c+'*'+ast.Rack_Type__c;
                    if(!invcomboMap.containskey(key)){
                        invcomboMap.put(key, 0);
                        inventorycombocount.put(key, 0);    
                    }
                }
            }
            system.debug('inventorycombocount size-> '+inventorycombocount.size());
            map<string,Inventory__c> inventoryComboMap = new map<string,Inventory__c>();
            list<Inventory__c> upsertlist = new list<Inventory__c>();
            for(Inventory__c inv : [select id,Location_Account__c,Is_In_Transit__c,Iserror__c,Parent_Account__c,Rack_Type__c,Asset_Count__c from Inventory__c 
                                    where Parent_Account__c IN: acclst AND (Location_Account__c IN:currentlocationLst OR Is_In_Transit__c = true)]){
                                        if(inv.Is_In_Transit__c){
                                            string key = inv.Parent_Account__c+'*'+'In transit'+'*'+inv.Rack_Type__c;
                                            if(!invcomboMap.containskey(key)){
                                                invcomboMap.put(key, 0);
                                                inventorycombocount.put(key, 0);    
                                            }
                                            inventoryComboMap.put(key,inv); 	    
                                        }else if(inv.Location_Account__c != null){
                                            inventoryComboMap.put(inv.Parent_Account__c+'*'+inv.Location_Account__c+'*'+inv.Rack_Type__c,inv);     
                                        }
                                    }
            system.debug('inventoryComboMap size-> '+inventoryComboMap.size());
            
            for(string st : inventorycombocount.keyset()){
                // system.debug(st);
                if(inventoryComboMap.containskey(st)){
                    Inventory__c inv = new Inventory__c();
                    inv = inventoryComboMap.get(st);
                    inv.Asset_Count__c = inventorycombocount.get(st);
                    upsertlist.add(inv);	
                }else{
                    Inventory__c inv = new Inventory__c();
                    list<string> strlist = st.split('\\*');
                    inv.Parent_Account__c = strlist[0];
                    if(strlist[1] == 'In transit'){
                        inv.Is_In_Transit__c = true;
                    }
                    else if(strlist[1] != 'null'){
                        inv.Location_Account__c = strlist[1];  
                    }
                    else{
                        inv.Iserror__c = true;
                    }
                    
                    if(strlist[2] != 'null'){
                    inv.Rack_Type__c = strlist[2];
                    }
                    inv.Asset_Count__c = inventorycombocount.get(st);  
                    
                    upsertlist.add(inv);
                }
            }
            if(upsertlist.size()>0){
                system.debug('system.debug upsertlist'+upsertlist.size());
                
                upsert upsertlist;    
            }
        }
        catch(Exception ex){
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'InventoryBatch', 'execute', 'Exception', null, null, true);
            //                RedesignNL_Helper.sendemail('RedesignNL_TemperatureAHCBatchError'+ '\n' + ' Error while Inserting AHC records-  '+ '\n' + 'error msg'+ex.getMessage()+'-Line-'+ex.getLineNumber()+'-Type-'+ ex.getTypeName());
        }
        
    }   
    global void finish(Database.BatchableContext bC){
    List<Inventory__c>invList= [SELECT Id, Name, LastModifiedDate
                                FROM Inventory__c
                                WHERE LastModifiedDate < :batchStartTime limit 5000];
    Database.delete(invList, false);
        Integer mins = Integer.valueof(System.label.Inventory_Batch_Interval_Time);
        Datetime sysTime = System.now().addMinutes(mins);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();          
          System.schedule('InventoryBatch '+ System.now().getTime(), cronExpression, New InventoryBatch());
    }
    global void execute(SchedulableContext sc) {
        InventoryBatch nextJob = new InventoryBatch();
        Database.executeBatch(nextJob,2000);
        
    }
    
}