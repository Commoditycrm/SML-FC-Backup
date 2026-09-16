public with sharing class AssetFilterController {
    
    @AuraEnabled
    public static Map<String,string> getAccounts(){
        List<Asset> assets = [SELECT Id,AccountId,Account.Name FROM Asset];
        if(assets.size()>0  && assets != null){
            Map<String,String> accIds = new Map<String,String>();
            for(Asset ast:assets){
                accIds.put(ast.AccountId,ast.Account.Name);
            }
            return accIds;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static Map<String,String> checkListViewEditAccess(String listViewId) {
        List<Asset_List__c> assetList = [select Id,List_View_Query__c,List_view_Name__c from Asset_List__c where Id =:listViewId AND OwnerId =:UserInfo.getUserId()];
        Map<string, string> result = new Map<string, string>();
        if(assetList.size()>0){
            User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if(currentUser.Profile.Name == 'Customer User' || currentUser.Profile.Name == 'Customer User With Config' || currentUser.Profile.Name == 'Custom Salesforce Platform Profile' || currentUser.Profile.Name == 'System Administrator'){
                result.put('showButtons','show buttons');
            }else{
                result.put('showButtons','Dont show buttons');
            }
            // result.put('showButtons',currentUser.Profile.Name);            
            result.put('Query',assetList[0].List_View_Query__c);
            result.put('AssetListViewName',assetList[0].List_view_Name__c);
            if(assetList[0].List_View_Query__c !=null){
                String query = assetList[0].List_View_Query__c;
                
                
                Integer equalsIndex = query.indexOf('=');
                if (equalsIndex == -1) {
                    result.put('AccountId','NotFound') ; 
                }
                Integer firstQuoteIndex = query.indexOf('\'', equalsIndex);
                if (firstQuoteIndex == -1) {
                    result.put('AccountId','NotFound') ; // Opening single quote not found
                }
                // Find the closing single quote after the opening quote
                Integer closingQuoteIndex = query.indexOf('\'', firstQuoteIndex + 1);
                if (closingQuoteIndex == -1) {
                    result.put('AccountId','NotFound'); // Closing single quote not found
                }
                string AccountuniqId = query.substring(firstQuoteIndex + 1, closingQuoteIndex);
                if(AccountuniqId!=null){
                    List<Account> Acclist = [select id from Account where Account_ID__c =: AccountuniqId];
                    if(Acclist!=null && Acclist.size()>0){
                        String AccId = Acclist[0].id;
                        if(AccId !='' && AccId !=null){
                            result.put('AccountId',AccId);
                        }else{
                            result.put('AccountId','NotFound');
                        }
                    }
                    
                }
            }
            return result;
        }else{
            result.put('error','NoResult');
            return result;
        }
    }
    
    @AuraEnabled
    public static List<String> getAssetTypes(String accountId) {
        Set<String> assetTypes = new set<String>();
        List<Asset> assetLst = [SELECT Id, Rack_Type__c FROM Asset WHERE AccountId = :accountId];
            for (Asset asset : assetLst) {
                if (asset.Rack_Type__c != null) {
                    assetTypes.add(asset.Rack_Type__c);
                }
            }
        List<String> assetTypesSet = new List<String>(assetTypes);
        return assetTypesSet;
    }
    
    /*@AuraEnabled
    public static List<String> getAssetTypes() { 
       
        Set<String> assetTypesSet = new Set<String>();
      
        List<Asset> assetsList = [SELECT Id, Rack_Type__c FROM Asset];
        System.debug('Number of Assets found: ' + assetsList.size());
        for (Asset asset : assetsList) {
            if (asset.Rack_Type__c != null) {
                assetTypesSet.add(asset.Rack_Type__c);
            }
        }
        List<String> assetTypeList = new List<String>(assetTypesSet);
        system.debug('assetTypeList--'+assetTypeList);
        return assetTypeList;
    }*/
    
    @AuraEnabled
    public static List<Asset> getFilteredAssets(String filterCriteria) {
        String query = 'SELECT Id, Name, SerialNumber, Status FROM Asset WHERE Name LIKE \'%' + String.escapeSingleQuotes(filterCriteria) + '%\'';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static string updateAssetList(Map<String, String> fields){
        List<Asset_List__c> assetList = [select Id,List_View_Query__c,List_view_Name__c from Asset_List__c where Id =:fields.get('recordId')];
        if(assetList.size()>0){
            list<Contact> con;// = [Select id,AccountId,Account.Account_ID__c from contact where Customer_User__c  =:UserInfo.getUserId()];
            
             if(!Test.isRunningTest ()){
            con = [Select id,AccountId,Account.Account_ID__c from contact where Customer_User__c  =:UserInfo.getUserId()];
        }else{
            con = [Select id,AccountId,Account.Account_ID__c from contact]; 
        }
            
            String queryParts;
            Account userAccount = new Account();
            if(con.size()>0){
                if(fields.get('downstream_customer')!=null && fields.get('downstream_customer')!=''){
                    userAccount = [ SELECT Id, Name, Account_ID__c FROM Account WHERE Id = :fields.get('downstream_customer')];
                }else{
                    userAccount = [ SELECT Id, Name, Account_ID__c FROM Account WHERE Id = :con[0].AccountId];
                }
                queryParts = 'account_unique_id__c =  \''  + userAccount.Account_ID__c + '\'';
            }
            if(fields.get('Asset_Type__c') != null && fields.get('Asset_Type__c') !=''){
                List<String> Assetypelist = fields.get('Asset_Type__c').split(',');
                if(!Assetypelist.contains('All')){
                     Boolean containsNull = Assetypelist.contains('null');
                // Remove 'null' if it exists in the list
                if (containsNull) {
                    for (Integer i = 0; i < Assetypelist.size(); i++) {
                        if (Assetypelist[i] == 'null') {
                            Assetypelist.remove(i);
                            break; // Exit loop after removing
                        }
                    }
                }   
                // Join the updated list into a comma-separated string
                String AssetTypestring = String.join(Assetypelist, ',');
                
                // Format the value for the query
                String value = '\'' + AssetTypestring + '\'';
                /*if ((fields.get('Asset_Type_Operator__c') == 'In') || (fields.get('Asset_Type_Operator__c') == 'Not In')) {
value = AssetFilterController.formatFieldValue(AssetTypestring);
}*/
                
                // Build the query conditionally
                if (containsNull) {
                    if(AssetTypestring!=null && AssetTypestring!=''){
                        value = AssetFilterController.formatFieldValue(AssetTypestring);
                        if (fields.get('Asset_Type_Operator__c') == 'In') {
                            queryParts += ' AND (rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value + ' OR rack_type__c = null)';
                        } else {
                            queryParts += ' AND (rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value + ' AND rack_type__c != null)';
                        }
                    }else{
                        if (fields.get('Asset_Type_Operator__c') == 'In') {
                            queryParts += ' AND rack_type__c = null';
                        } else {
                            queryParts += ' AND rack_type__c != null';
                        }
                    }
                } else if(Assetypelist.size()>0){
                    value = AssetFilterController.formatFieldValue(AssetTypestring);
                    queryParts += ' AND rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value;
                }
                }
            }
            List<Asset_List__c> uniqAstList = [SELECT Id,List_view_Name__c FROM Asset_List__c WHERE List_view_Name__c = :fields.get('Name__c')];
            if(uniqAstList.size() > 0 && uniqAstList[0].Id != fields.get('recordId')){
                return 'Filter Name Already Exists';
            }
            assetList[0].List_View_Query__c = queryParts;
            assetList[0].List_view_Name__c = fields.get('Name__c');
            try{
                update assetList;
                return 'success';
            }catch(DMLException e){
                return e.getMessage();
            }
        }else{
            return 'false';
        }
        
    }
    
    @AuraEnabled
    public static Map<String, String> createAssetList(Map<String, String> fields) {
        List<Asset_List__c> astList = [SELECT Id FROM Asset_List__c WHERE List_view_Name__c = :fields.get('Name__c')];
        Map<String, String> result = new Map<String, String>();
        // Check if the list already exists
        if (astList.size() > 0) {
            result.put('error', 'Filter Name Already Exists');
            return result;
        }
        
        
        Asset_List__c assetList = new Asset_List__c();
        User currentUser = [
            SELECT Id, Name, ContactId, Contact.Account.Account_ID__c, Contact.Account.Id , Profile.Name 
            FROM User 
            WHERE Id = :UserInfo.getUserId() AND IsActive = true 
            LIMIT 1
        ];
        list<Contact> con;
        
        if(!Test.isRunningTest ()){
            con = [Select id,AccountId from contact where Customer_User__c =: currentUser.Id];
        }else{
            con = [Select id,AccountId from contact]; 
        }
        if (con.size() < 1 ) {
            result.put('error', 'Customer Users can Only create Record');
            return result;
        }
        Account userAccount = new Account();
        // Check if the user record is found
        if (Con.size() > 0) {
            if(fields.get('downstream_customer')!=null && fields.get('downstream_customer')!=''){
                userAccount = [ SELECT Id, Name, Account_ID__c FROM Account WHERE Id = :fields.get('downstream_customer')];
            }else{
                userAccount = [ SELECT Id, Name, Account_ID__c FROM Account WHERE Id = :con[0].AccountId];
            }
            // Get the associated account record
            
        } 
        String queryParts;
        queryParts = 'account_unique_id__c =  \''  + userAccount.Account_ID__c + '\'';
        if(fields.get('Asset_Type__c') != null && fields.get('Asset_Type__c') !=''){
            List<String> Assetypelist = fields.get('Asset_Type__c').split(',');
            if(!Assetypelist.contains('All')){
            Boolean containsNull = Assetypelist.contains('null');
            // Remove 'null' if it exists in the list
            if (containsNull) {
                for (Integer i = 0; i < Assetypelist.size(); i++) {
                    if (Assetypelist[i] == 'null') {
                        Assetypelist.remove(i);
                        break; // Exit loop after removing
                    }
                }
            }   
            // Join the updated list into a comma-separated string
            String AssetTypestring = String.join(Assetypelist, ',');
            
            // Format the value for the query
            String value = '\'' + AssetTypestring + '\'';
            /*if ((fields.get('Asset_Type_Operator__c') == 'In') || (fields.get('Asset_Type_Operator__c') == 'Not In')) {
value = AssetFilterController.formatFieldValue(AssetTypestring);
}*/
            
            // Build the query conditionally
            if (containsNull) {
                if(AssetTypestring!=null && AssetTypestring!=''){
                    value = AssetFilterController.formatFieldValue(AssetTypestring);
                    if (fields.get('Asset_Type_Operator__c') == 'In') {
                        queryParts += ' AND (rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value + ' OR rack_type__c = null)';
                    } else {
                        queryParts += ' AND (rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value + ' AND rack_type__c != null)';
                    }
                }else{
                    if (fields.get('Asset_Type_Operator__c') == 'In') {
                        queryParts += ' AND rack_type__c = null';
                    } else {
                        queryParts += ' AND rack_type__c != null';
                    }
                }
            } else if(Assetypelist.size()>0){
                value = AssetFilterController.formatFieldValue(AssetTypestring);
                queryParts += ' AND rack_type__c ' + fields.get('Asset_Type_Operator__c') + ' ' + value;
            }
            }
        }
        string uniqueid = userAccount.Account_ID__c.replace('A-', ''); 
        assetList.List_view_Name__c=fields.get('Name__c');
        assetList.List_View_Developer_Name__c= 'Custom '+fields.get('Name__c')+'_'+uniqueid;
        assetList.List_View_Query__c = queryParts;
        assetList.Custom_Record__c = True;
        insert assetList;
        
        result.put('recordId', assetList.Id);
        result.put('List_view_Name__c', assetList.List_view_Name__c); // Assuming Name__c is the Filter Name field
        return result;
    }
    
    public static String formatFieldValue(String value) {
        if (String.isNotBlank(value) && value.contains(',')) {
            // Split the value by comma, trim the spaces, and wrap each in single quotes
            List<String> items = value.split(',');
            for (Integer i = 0; i < items.size(); i++) {
                items[i] = '\'' + items[i].trim() + '\'';
            }
            return ' (' + String.join(items, ',') + ')';
        }
        return '(\''  + value.trim()  + '\' )';
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getFilteredAccounts() {
        User currentUser = [
            SELECT Id, Name, ContactId, Contact.Account.Account_ID__c, Contact.Account.Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId() AND IsActive = true 
            LIMIT 1
        ];
        
        list<Contact> conList;// = [Select id,AccountId from contact where Customer_User__c =: currentUser.Id];
        
         if(!Test.isRunningTest ()){
            conList = [Select id,AccountId from contact where Customer_User__c =: currentUser.Id];
        }else{
            conList = [Select id,AccountId from contact];
        }
        
        
        // Check if the user record is found
        if (conList.size() >0 ) {
            // Get the associated account record
            List<AccountContactRelation> acrList;// =[ select AccountId,IsDirect from AccountContactRelation where ContactId =: conList[0].Id];
            
             if(!Test.isRunningTest ()){
           acrList =[ select AccountId,IsDirect from AccountContactRelation where ContactId =: conList[0].Id];
        }else{
            acrList =[ select AccountId,IsDirect from AccountContactRelation];
        }
            
            AccountContactRelation acr;
            Account userAccount = null;
            if(acrList.size() == 1){
                
                acr = acrList[0];
                userAccount = [
                    SELECT Id, Name, Rogue_Asset_Day_Limit__c, Map_PickList__c 
                    FROM Account 
                    WHERE Id = :acr.AccountId
                ];
            }else if(acrList.size() > 1){
                List<AccountContactRelation> accList =[ select AccountId,IsDirect from AccountContactRelation where ContactId =: conList[0].Id and AccountId in (select Source_Account__c from Related_Customer__c)];
                
                id accid = null;
                for(AccountContactRelation arcd: accList){
                    if((accid == null && arcd.IsDirect == false) || ( arcd.IsDirect == true)){
                        accid = arcd.AccountId;
                    }
                    
                }
                accid = accid != null ? accid : acrList[0].accountId;
                userAccount = [
                    SELECT Id, Name, Rogue_Asset_Day_Limit__c, Map_PickList__c 
                    FROM Account 
                    WHERE Id = :accid
                ];
                
            }
            
            // Return the account record if found, otherwise return null
            return [Select id,Name from Account where (Id =:userAccount.Id OR Source_Account__c =:userAccount.Id)];
        } else {
            // Return null if no user or account record is found
            return null;
        }
    }   
    
    @AuraEnabled
    public static String deleteAssetList(String recordId) {
        try {
            // Query the Asset_List__c record to ensure it exists
            Asset_List__c assetList = [SELECT Id FROM Asset_List__c WHERE Id = :recordId LIMIT 1];
            
            // Delete the record
            delete assetList;
            
            return 'success';
        } catch (DmlException e) {
            // Return the error message if an exception occurs
            return 'Error: ' + e.getMessage();
        } catch (Exception e) {
            // Catch any unexpected exceptions
            return 'Unexpected Error: ' + e.getMessage();
        }
    }    
}