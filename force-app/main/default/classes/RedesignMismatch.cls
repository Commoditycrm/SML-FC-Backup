public class RedesignMismatch implements Database.Batchable<sobject>,Database.Stateful {

public Map<String, List<String>> achNamesByAsset;
public String astQuery;
public String achQueryFilter;
public Set<String> assetIds = new Set<String>();
public Set<String> assetMismatch = new Set<String>();
public Integer totalMisMatchCount;
 public Boolean forAHC = False;
public RedesignMismatch() {
    this.totalMisMatchCount = 0;
    this.achNamesByAsset = new Map<String, List<String>>();
    this.assetMismatch = assetMismatch;
}
public RedesignMismatch(string astQuery){
        this.astQuery = astQuery;
        this.totalMisMatchCount = 0;
        this.achQueryFilter = '';
        this.achNamesByAsset = new Map<String, List<String>>();
        
    }
    public RedesignMismatch(String achQueryFilter,Boolean forAHC){
    this.achQueryFilter = achQueryFilter;
    this.totalMisMatchCount = 0;
    this.achNamesByAsset = new Map<String, List<String>>();
    this.assetMismatch = null;
    this.forAhc = true;
    
    for(Asset_History_custom__c obj : DataBase.Query(achQueryFilter)){
        assetIds.add(obj.Asset__c);
    }       
}

public Database.QueryLocator start(Database.BatchableContext bc){
    if(String.isBlank(astQuery)) {
    astQuery = 'Select Id, Name from Asset';
    }
    return database.getQueryLocator(astQuery);
}

public void execute(Database.BatchableContext bc, List<Asset> assets){ 
    Integer ds = Integer.valueof(System.Label.check_for_Mismatch);
    DateTime CheckDate = Date.today().addDays(-ds) ; 
    List<Asset_History_custom__c> achList;
    for(Asset ast : assets) {
        achList = null;
        String qry = 'SELECT Id, Name, Start_Time__c, End_Time__c,Asset__c,Delete_check__c,createdDate FROM Asset_History_custom__c WHERE Asset__c  = \''+ast.Id +'\' AND Recordtype.developerName = \'Location\' AND isDeleted = false ORDER BY start_time__c desc limit 100';
        achList = DataBase.Query(qry);
        List<String> temp = new List<String>();
        for(Integer i=1; i<achList.size(); i++){
        
       if(achList[i-1].Start_Time__c != achList[i].End_Time__c){
                totalMisMatchCount = totalMisMatchCount + 1;
                assetMismatch.add(ast.Name);
                if(achList[i].Asset__c == ast.Id && (achList[i-1].createdDate >= CheckDate )){
                    temp.add( achList[i].Name + '---' + achList[i].Start_Time__c + '||' + achList[i-1].Name + '--'+ achList[i-1].End_Time__c);
                }
            }
        }
        
        if(temp.size()>0)
            achNamesByAsset.put(ast.Name, temp);
        
    }
}

public void finish(Database.BatchableContext bc){
    messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
    msg.toAddresses = new String[] {System.Label.Email_Address};
        //'commodityccrm@gmail.com',
        //'murali@agilenautics.com', 'tripathisn5363@gmail.com'};
            msg.setSubject('ACH MisMatch Start/End Time Reports');
    string body = 'Overall Mismatched : '+achNamesByAsset.keySet().size() + '\n';
    
    for(String astName : achNamesByAsset.keySet()){
        body += astName + ' : ' + String.join(achNamesByAsset.get(astName), ',') + '\n';
    }
    
    msg.setPlainTextBody(body);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
    system.debug('Email sent--');
}
}