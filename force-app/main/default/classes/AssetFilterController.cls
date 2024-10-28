public with sharing class AssetFilterController {
    @AuraEnabled
    public static List<Asset> getFilteredAssets(String filterCriteria) {
        String query = 'SELECT Id, Name, SerialNumber, Status FROM Asset WHERE Name LIKE \'%' + String.escapeSingleQuotes(filterCriteria) + '%\'';
        return Database.query(query);
    }
    @AuraEnabled
    public static Map<String, String> createAssetList(Map<String, String> fields) {
        List<Asset_List__c> astList = [SELECT Id FROM Asset_List__c WHERE List_view_Name__c = :fields.get('Name__c')];
        
        // Check if the list already exists
        if (astList.size() > 0) {
            Map<String, String> result = new Map<String, String>();
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
        list<Contact> con = [Select id,AccountId from contact where Customer_User__c =: currentUser.Id];
        
        
         if (con.size() < 1 ) {
            Map<String, String> result = new Map<String, String>();
            result.put('error', 'Customer Users can Only create Record');
            return result;
        }
        Account userAccount = new Account();
        // Check if the user record is found
        if (Con.size() > 0) {
            // Get the associated account record
            userAccount = [
                SELECT Id, Name, Account_ID__c 
                FROM Account 
                WHERE Id = :con[0].AccountId
            ];
        } 
        String queryParts;
        queryParts = 'account_unique_id__c =  \''  + userAccount.Account_ID__c + '\'';
        
        if (fields.get('Asset_Type__c') != null && fields.get('Asset_Type__c') != '') {
            string value= '\''  + fields.get('Asset_Type__c')+ '\'';
            if((fields.get('Asset_Type_Operator__c') == 'In') || (fields.get('Asset_Type_Operator__c') == 'Not In')){
                value= AssetFilterController.formatFieldValue(fields.get('Asset_Type__c'));
            }
            queryParts+=' AND rack_type__c  ' + fields.get('Asset_Type_Operator__c') +  value;
        }
        
     
        
     
        
        if (fields.get('Account__c') != null && fields.get('Account__c') != '') {
            queryParts+=' AND AccountId ' + fields.get('Account_Operator__c') + '\''  + fields.get('Account__c')+ '\'';
        }
        
        string uniqueid = userAccount.Account_ID__c.replace('A-', ''); 
        assetList.List_view_Name__c=fields.get('Name__c');
        assetList.List_View_Developer_Name__c= 'Custom '+fields.get('Name__c')+'_'+uniqueid;
        assetList.List_View_Query__c = queryParts;
        assetList.Custom_Record__c = True;
        insert assetList;
        
        Map<String, String> result = new Map<String, String>();
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
        return value;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Account> getFilteredAccounts() {
        User currentUser = [
            SELECT Id, Name, ContactId, Contact.Account.Account_ID__c, Contact.Account.Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId() AND IsActive = true 
            LIMIT 1
        ];
        
        list<Contact> conList = [Select id,AccountId from contact where Customer_User__c =: currentUser.Id];
        
         
        // Check if the user record is found
        if (conList.size() >0 ) {
            // Get the associated account record
           List<AccountContactRelation> acrList =[ select AccountId,IsDirect from AccountContactRelation where ContactId =: conList[0].Id];
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
}