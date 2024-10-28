public without sharing class CustomerLightningController {
    
    @auraEnabled
    public static List<Asset_List__c> assetListOptions(){
        List<Asset_List__c> records = new List<Asset_List__c>();
        
        list<user> userrec = [select id,name from user where id = : userinfo.getUserId() and IsActive = true];
        List<Asset_List__c> als;
        if(userrec != null) {
            String conId = userrec[0].Id;
            list<Contact> con = [Select id,Asset_List_Views_Shared__c from contact where Customer_User__c =: conId];
            if(con.size() >0){
            if (con[0].Asset_List_Views_Shared__c == null){//Fetching all listViews
                als = [select Id, List_View_Developer_Name__c, List_view_Name__c from Asset_List__c order by List_view_Name__c];
            }
            else {//Fetching listViews mentioned in Asset_List_Views_Shared__c
                String[] multipleValues = con[0].Asset_List_Views_Shared__c.split(',');
                als = [select Id, List_View_Developer_Name__c, List_view_Name__c from Asset_List__c where List_View_Developer_Name__c in: multipleValues order by List_view_Name__c];
            }
            
            for(AccountContactRelation accrec : [SELECT AccountId, Id, ContactId, account.Account_Id__c,IsDirect FROM AccountContactRelation 
                                                 where contactId =: con[0].Id]){
                                                     if(accrec.account.Account_ID__c != null ){
                                                         for(Asset_List__c obj : als){
                                                             if(obj.List_View_Developer_Name__c != null){
                                                                 if(obj.List_View_Developer_Name__c.contains(accrec.account.Account_ID__c.remove('A-'))){
                                                                     records.add(obj);   
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
        }
        else {
            records = [select Id,List_view_Name__c from Asset_List__c order by List_view_Name__c];
        }
        }
        return records;
    }
    
    @auraEnabled
    public static List<asset> fetchAssets(String assetListId){
        List<asset> retlist = new List<asset>();
        List<Asset_List__c> records = [select Id,List_view_Name__c,List_View_Query__c from Asset_List__c Where Id =: assetListId];
        if(records != null && records[0].List_View_Query__c != null) {
            String soql = 'SELECT id FROM Asset WHERE ' + records[0].List_View_Query__c;
            
            List<asset> assets = DataBase.Query(soql);
            Map<Id, Asset> assetMap = new Map<Id, Asset>(assets);
            if(assetMap != null){               
                for(asset ast :[select id,Total_Dwell_Days__c,Smart_Tracks__c,  Smart_Tracks2__c,name,IschangedTrue__c,Current_Location_Address__c,accountid,Field2__c,
                                Is_Access_Point__c,Last_Connected_Map__c,Last_Connect_Map_Formula__c,Current_City__c,Asset_Name_formula__c,Current_State__c,
                                Temporary_Latitude__c,Current_Loc_Assets_count__c,Current_Loc_latitude__c,Current_Loc_Longitude__c,Temporary_Longitude__c,
                                Current_Location__c,Current_Location_Name__c,State_of_Pallet__c,Last_Connected__c,Rack_Type__c, Asset_Name_URL__c,
                                Related_Assets__c,Rogue_Asset_Day_Limit__c  from asset where  id IN : assetMap.KeySet() and Is_Access_Point__c = false and Current_Address__c != null]){
                                    retlist.add(ast);  
                                }
            }
        }
        return retlist;
    }
    
    @auraEnabled
    public static list<asset> assetlist(string lstname){
        set<id> recordids = new set<id>();
        list<asset> assetlist = new list<asset>();
        string selListViewId = '';
        if(lstname != null)
            selListViewId = [select Id, Name FROM ListView Where SobjectType = 'asset' and name =: lstname order by createddate desc limit 1].id;
        string objectName = 'asset';
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v50.0/sobjects/'+ objectName +'/listviews/'+ selListViewId +'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        Http http = new Http();
        if(!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionId));
        }
        HttpResponse res = http.send(req);
        if( res.getStatusCode() == 200 ) {            
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());     
            String query = (String) tokenResponse.get('query');
            assetlist = database.query(query);
        }
        for(asset ast:assetlist){
            recordids.add(ast.Id); 
        }
        for(asset ast :[select id,Smart_Tracks__c,Total_Dwell_Days__c,Smart_Tracks2__c,name,IschangedTrue__c,Current_Location_Address__c,accountid,Field2__c,Is_Access_Point__c,Last_Connected_Map__c,Last_Connect_Map_Formula__c,Current_City__c,Asset_Name_formula__c,Current_State__c,Temporary_Latitude__c,Current_Loc_Assets_count__c,Current_Loc_latitude__c,Current_Loc_Longitude__c,Temporary_Longitude__c,Current_Location__c,Current_Location_Name__c,State_of_Pallet__c,Last_Connected__c,Rack_Type__c, Asset_Name_URL__c,Related_Assets__c,Rogue_Asset_Day_Limit__c  from asset where  id IN :recordids and Is_Access_Point__c = false]){
            
            assetlist.add(ast);    
        }
        if(assetlist.size()>0){
            return assetlist;    
        }else{
            return null;
        }
    }
    @auraEnabled
    public static list<string> assetlistView(){
        list<string> lstnames = new list<string>();
        set<string> finallstnames = new set<string>();
        map<string,id> lstviewmap = new map<string,id>();
        map<string,string> maplvnamelabel = new map<string,string>();//To get List view API Name
        map<string,string> lstviewNameMap = new map<string,string>();
        for(listview lst : [select Id, Name,DeveloperName  FROM ListView Where SobjectType = 'asset' order by name asc]){
            lstnames.add(lst.DeveloperName); 
            lstviewmap.put(lst.DeveloperName,lst.id);
            lstviewNameMap.put(lst.DeveloperName, lst.Name);
            maplvnamelabel.put(lst.Name,lst.DeveloperName); //If you know label,get the list view API Name
        }
        for(user usr : [select id,name from user where id = : userinfo.getUserId() and IsActive = true] ){
            string query = 'select id,name,accountid,Temporary_Latitude__c,Last_Connected_Map__c,Last_Connect_Map_Formula__c,Temporary_Longitude__c,Current_Location_Name__c,State_of_Pallet__c,Last_Connected__c, Asset_Name_URL__c,Related_Assets__c, Rogue_Asset_Day_Limit__c,Total_Dwell_Days__c from asset limit 10000';
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(database.getQueryLocator(query));
            
            for(string str : lstnames){
                sc.setFilterId(lstviewmap.get(str));
                if(sc.getResultSize()>0){
                    if(usr.ContactId == null){ 
                        finallstnames.add(str);  
                    }
                    else{
                        for(string str1 : str.split(' ')){
                            string uniqueId = usr.contact.account.Account_ID__c;
                            if(str1.contains(uniqueId.remove('A-'))){
                                finallstnames.add(str);   
                                
                            }//IF
                        }//FOR
                    }//ELSE
                }//IF
            }//FOR
        }
        
        //Related Account List View 27-10-2021
        list<user> userrec = [select id,name from user where id = : userinfo.getUserId() and IsActive = true];
        string usrconId;
        usrconId = userrec[0].id;
        string accuniqueId;
        list<Contact> con = [Select id,Asset_List_Views_Shared__c from contact where Customer_User__c =: usrconId];
        if(con.size() >= 1)
        {
            list<AccountContactRelation > acccontlist =  [SELECT AccountId, Id, ContactId, account.Account_Id__c,IsDirect FROM AccountContactRelation where contactId =  : con[0].id];
            if(acccontlist.size() >= 1)
            {
                for(AccountContactRelation accrec : acccontlist)
                {
                    accuniqueId = accrec.account.Account_ID__c;
                    for(string str : lstnames){
                        if(accuniqueId != null){
                            if(str.contains(accuniqueId.remove('A-'))){
                                finallstnames.add(str);   
                            }
                        }
                    }//For lstnames
                }//FOR
            }
        }//IF
        //Related End   
        //Added the listview in the contact to the final list name 
        list<string> returnstr = new list<string>();
        for(string st : finallstnames){
            if(lstviewNameMap.containskey(st))
                returnstr.add(lstviewNameMap.get(st));
        }
        return returnstr;
    }   
    @auraEnabled
    public static user userlatlng(){      
        return [SELECT Id, Name, Latitude, Longitude,Profile.Name FROM User where id = : UserInfo.getUserId() limit 1];
    }
    
    @auraEnabled
    public static list<string> assetListViewOption(){
        Set<String> finallstnames = new Set<String>();
        Map<String, Listview> listViewMap = new Map<String, Listview>();
        list<user> users = [select id,name from user where id = : userinfo.getUserId() and IsActive = true];
        Set<String> accuniqueIds = new Set<String>(); 
        list<Contact> con = [Select id,Asset_List_Views_Shared__c from contact where Customer_User__c =: users[0].id];
        
        for(AccountContactRelation acr : [SELECT AccountId, Id, ContactId, account.Account_Id__c,IsDirect FROM AccountContactRelation 
                                          WHERE contactId =: con[0].id AND account.Account_ID__c != null]){
                                              accuniqueIds.add(acr.account.Account_ID__c.remove('A-'));
                                          }
        string query = 'select id,name,accountid,Temporary_Latitude__c,Last_Connected_Map__c,Last_Connect_Map_Formula__c,Temporary_Longitude__c,Current_Location_Name__c,State_of_Pallet__c,Last_Connected__c, Asset_Name_URL__c,Related_Assets__c,  Rogue_Asset_Day_Limit__c  from asset limit 1';
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(database.getQueryLocator(query));
        String uniqueId = con[0].account.Account_ID__c;
        for(listview lst : [select Id, Name,DeveloperName  FROM ListView Where SobjectType = 'asset' order by Name asc]){
            listViewMap.put(lst.DeveloperName, lst);
            for(String str : accuniqueIds){
                if(lst.DeveloperName.contains(str)){
                    finallstnames.add(lst.DeveloperName);   
                }
            }
            
            sc.setFilterId(lst.Id);
            if(sc.getResultSize()>0) {
                if(con[0].id == null){ 
                    finallstnames.add(lst.DeveloperName);  
                }
                else{
                    for(string str1 : lst.DeveloperName.split(' ')){
                        if(str1.contains(uniqueId.remove('A-'))){
                            finallstnames.add(lst.DeveloperName);   
                            
                        }
                    }
                }
            }
        }
        
        list<string> returnstr = new list<string>();
        for(string st : finallstnames){
            if(listViewMap.containskey(st))
                returnstr.add(listViewMap.get(st).Name);
        }
        return returnstr;
    }
    
    @auraEnabled
    public static Account getAccountByUserId() {
        // Get the user record for the current user
        User currentUser = [
            SELECT Id, Name
            FROM User 
            WHERE Id = :UserInfo.getUserId() AND IsActive = true 
            LIMIT 1
        ];
        List<Contact> con = [Select id,Asset_List_Views_Shared__c from contact where Customer_User__c =: currentUser.Id];
        // Check if the user record is found
        if (con.size()>0) {
            // Get the associated account record
            
            List<AccountContactRelation> acrList =[select AccountId,IsDirect from AccountContactRelation where ContactId =: con[0].Id];
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
                List<AccountContactRelation> accList =[ select AccountId,IsDirect from AccountContactRelation where ContactId =: con[0].Id and AccountId in (select Source_Account__c from Related_Customer__c)];
                
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
            return userAccount != null ? userAccount : null;
        } else {
            // Return null if no user or account record is found
            return null;
        }
    }
    
    
    
}