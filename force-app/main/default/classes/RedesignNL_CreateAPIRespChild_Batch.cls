global class RedesignNL_CreateAPIRespChild_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
    public string query;
    public List<string> idList = new List<String>();
    
    public RedesignNL_CreateAPIRespChild_Batch() {
    }
    public RedesignNL_CreateAPIRespChild_Batch(String query) {
        this.query = query;
    }
    public RedesignNL_CreateAPIRespChild_Batch(List<String> idList) {
        this.idList = idList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(query) && idList.size() == 0) {
            String assetId = '02iEk0000004YazIAE';
            query = 'Select Id, Incoming_Messsage__c, Status__c from API_Response__c where Asset__c =: assetId AND check_class__c !=\'Process Data\' AND Status__c != null ' ;//CreatedDate = LAST_7_DAYS';
        }
        else if(idList.size() > 0){
            query = 'Select Id, Incoming_Messsage__c, Status__c from API_Response__c where Id in: idList AND check_class__c !=\'Process Data\' AND Status__c != null';
            
        }
     	return Database.getQueryLocator(query);
     }
    global void execute(Database.BatchableContext BC, List<API_Response__c> scope) {
        for(API_Response__c ar: scope) {
            System.debug('resp Id -- '+ar.Id);
            String result = RedesignNL_Controller.parseRequestBody(ar.Incoming_Messsage__c, ar, true);
  			System.debug(result);
        }

    }
    global void finish(Database.BatchableContext bC){
    }
    
}