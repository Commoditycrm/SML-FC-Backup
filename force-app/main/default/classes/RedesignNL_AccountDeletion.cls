public class RedesignNL_AccountDeletion implements Database.Batchable<SObject>, Database.Stateful{
	 public Id currentAcc;
    public Account replAcc;
    public String objectName;
    public Map<Id, Account> accMap = new Map<Id, Account>();
    public List<Account> accList = new List<Account>();
    public DateTime batchStartTime;
    public List<string> failureMsgs = new List<String>();
    public static Integer totalFailureRecords = 0;
    public String batchStatus;
     public Integer totalRecords = 0;
    public set<id> accIds;
    public set<id> assetIds;
    
    // Constructor
    public RedesignNL_AccountDeletion(String objectName) {
        this.batchStartTime = system.Now();
        this.objectName = objectName;
    }
    public RedesignNL_AccountDeletion(List<Account> accList, String objectName) {
        this.accList = accList;
        this.objectName = objectName;
        this.batchStartTime = system.Now();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchStatus='Processing';
        Set<Id> replacedAccId = new  Set<Id>();
        Set<Id> deleteAccIds = new  Set<Id>() ;
        accList = accList != null? accList :[Select Id, Name, Address__c,Replaced_account__c from Account Where Replaced_account__c != null Limit 10000];
            if(accList.size()>0){
                for(Account loopVar : accList){
                    if(loopVar.Replaced_Account__c != 'In Transit'){
                    	replacedAccId.add(loopVar.Replaced_Account__c);
                    }
                    deleteAccIds.add(loopVar.Id);
                }
            }
        this.accIds = deleteAccIds;
        Map<Id, Account> replacedAccountsMap = New map<Id, Account>([Select Id, Name,Address__c, Replaced_Account__c  from Account where Id in :replacedAccId]);
        if(accList.size()>0){
        for(Account loopVar : accList){
            if(loopVar.Replaced_Account__c != 'In Transit'){
                accMap.put(loopVar.Id, replacedAccountsMap.get(loopVar.Replaced_Account__c));
            }
        }
        
        String query = 'SELECT Id, ';
        if (this.objectName == 'Api_Response_childs__c') {
            query += 'Asset__c ,Currentlocationid__c, Current_Location_Address__c, Location__c FROM ' + this.objectName + ' WHERE CurrentLocationId__c IN :deleteAccIds';
        } else if (this.objectName == 'Asset_History_custom__c') {
            query += 'Asset__c ,Location__c, Current_Location_Address__c, currentLocationId__c, Last_Known_Location__c, Last_Known_Location_Lookup__c FROM ' + this.objectName + ' WHERE currentLocationId__c IN :deleteAccIds OR Last_Known_Location_Lookup__c IN :deleteAccIds';
        } else if (this.objectName == 'Asset') {
            query += 'Current_Address__c, Current_Location__c, Last_Known_Location__c FROM ' + this.objectName + ' WHERE Current_Location__c IN :deleteAccIds OR Last_Known_Location__c IN :deleteAccIds';
        }
        
        return Database.getQueryLocator(query);
        }else{
            return null;
        }
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
         totalRecords += scope.size();
        if (this.objectName == 'Api_Response_childs__c') {
            updateArc((List<Api_Response_childs__c>)scope, accMap);
        } else if (this.objectName == 'Asset_History_custom__c') {
            updateHistory((List<Asset_History_custom__c>)scope, accMap);
        } else if (this.objectName == 'Asset') {
            updateAsset((List<Asset>)scope, accMap);
        }
        try{
            update scope;
        }catch(DMLException e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'RedesignNL_AccountDeletion', 'executeMethod', 'DML Error', null, null, true);

            failureMsgs.add('RedesignNL_AccountDeletion - updating ' + this.objectName + '. Error msg: '+e.getMessage());
			totalFailureRecords = totalFailureRecords + 1;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, 'RedesignNL_AccountDeletion', batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);

        if (this.objectName == 'Api_Response_childs__c') {
            Database.executeBatch(new RedesignNL_AccountDeletion(accList, 'Asset_History_custom__c'));

        } else if (this.objectName == 'Asset_History_custom__c') {
            Database.executeBatch(new RedesignNL_AccountDeletion(accList, 'Asset'));
        } else if (this.objectName == 'Asset') {
            Database.executeBatch(new RedesignNl_AssetPauseJob(accIds));  
           // delete accList;
            
        }
    }
    
    public static void updateArc(List<Api_Response_childs__c> arcList, Map<Id, Account> accMap) {
        for (Api_Response_childs__c arc : arcList) {
            Account acc = accMap.get(arc.Currentlocationid__c);
            if (acc != null) {
                arc.Currentlocationid__c = acc.Id;
                arc.Current_Location_Address__c = acc.Address__c;
                arc.Location__c = acc.Id;
            } else {
                arc.Currentlocationid__c = null;
                arc.Location__c = 'In transit';
            }
        }
    }
    
    public static void updateHistory(List<Asset_History_custom__c> historyList, Map<Id, Account> accMap) {
        for (Asset_History_custom__c history : historyList) {
            Account acc = accMap.get(history.currentLocationId__c);
            if (acc != null) {
                history.currentLocationId__c = acc.Id;
                history.Current_Location_Address__c = acc.Address__c;
                history.Location__c = acc.Name;
            } else {
                history.currentLocationId__c = null;
                history.Location__c = 'In transit';
            }
            
            Account accLKL = accMap.get(history.Last_Known_Location_Lookup__c);
            if (accLKL != null) {
                history.Last_Known_Location_Lookup__c = accLKL.Id;
                history.Last_Known_Location__c = accLKL.Name;
            } else {
                history.Last_Known_Location_Lookup__c = null;
                history.Last_Known_Location__c = null;
            }
        }
    }
    
    public static void updateAsset(List<Asset> assetList, Map<Id, Account> accMap) {
        for (Asset asset : assetList) {
            Account acc = accMap.get(asset.Current_Location__c);
            if (acc != null) {
                asset.Current_Address__c = acc.Address__c;
                asset.Current_Location__c = acc.Id;
            } else {
                asset.Current_Location__c = null;
            }
            
            Account accLKL = accMap.get(asset.Last_Known_Location__c);
            if (accLKL != null) {
                asset.Last_Known_Location__c = accLKL.Id;
            } else {
                asset.Last_Known_Location__c = null;
            }
        }
    }
}