public class BreadCrumbs_Controller {
    
    public class historyWrapper{
        
        @AuraEnabled        
        public Id AssetId;
        @AuraEnabled
        public string AssetName;
        @AuraEnabled
        public Decimal Latitude;
        @AuraEnabled
        public Decimal Longtitude;
        @AuraEnabled
        public String StartTime;
        @AuraEnabled
        public String EndTime;
        @AuraEnabled
        public String AssetNameHis;
        @AuraEnabled
        public String AssetAccount;
        @AuraEnabled
        public String CustomerID; 
        @AuraEnabled
        public String Location; 
        
        public historyWrapper(Id AssetId , String Name , Decimal lat , Decimal lng,String strt,String endt,String asstname,String accname,String cusid,String Loc){
            this.AssetId = AssetId;
            this.AssetName= Name;
            this.Latitude = lat;
            this.Longtitude = lng;            
            this.StartTime = strt;
            this.EndTime = endt;
            this.AssetNameHis = asstname;
            this.AssetAccount = accname;
            this.CustomerID = cusid;
            this.Location = Loc;
            
        }
    }
    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionId;
        // Get the content of the VF page
        String vfContent;
        if(!Test.isRunningTest()) {
            vfContent = reportPage.getContent().toString();	    
        }else{
            vfContent = '';
        }
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        if(!Test.isRunningTest()) {
            sessionId = vfContent.substring(startP, endP);
        }
        else{
            sessionId ='';
        }
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }
    
    
    @AuraEnabled
    public static List<historyWrapper> getdatefromjs(Date strtDate, Date enDate,id recordid) {
        DateTime StartDate = datetime.newInstance(strtDate, Time.newInstance(0,0,0,0));
        DateTime EndDate = datetime.newInstance(enDate, Time.newInstance(23,59,59,59));
        Id versionId;
        //Id RecordIds=Id.valueOf(recordid);
        
        /** Get Recent Dataset Version Id**/
        /**  String sessionId = fetchUserSessionId();
Id versionId;
HTTP h = new HTTP();
HTTPRequest req = new HTTPRequest();
req.setHeader('Authorization', 'Bearer ' + sessionId);
req.setMethod('GET');
req.setHeader('Content-Type', 'text/xml');
req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v44.0/wave/datasets/0Fb0v0000008svICAQ/versions');            
HTTPResponse resp = h.send(req);
System.debug(resp.getBody());
Map<String,Object> res = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
System.debug('res'+res);
List<Object> records = (List<Object>)res.get('versions');
for(Object o : records){
Map<String,Object> obj = (Map<String, Object>)o;
versionId = (Id)obj.get('id');
break;
}
System.debug('versionID'+versionId); **/
        
        /** List<Asset_History_custom__c> lAssetHistory= new List<Asset_History_custom__c>();

for(Asset_History_custom__c assethistory: [select id,Asset__c,Battery_Current__c,Dwell_Time__c,CreatedDate,Latitude__c,Longitude__c 
from Asset_History_custom__c where RecordType.developername='Location' 
and CreatedDate >=: StartDate and CreatedDate <=: EndDate and Asset__c=: recordid])
{
lAssetHistory.add(assethistory);
}    **/
        
        
        String AssetId = recordId;
        Date sDate = strtDate;
        Date eDate = enDate;
        string recordtype= Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Location').getRecordTypeId();
        versionId = [select Id,Name,Value__c from Data_Configuration__c where Name = 'DatasetVersionId' limit 1].value__c;
        system.debug('versionId'+versionId);
        string st;
        if(Test.isRunningTest()){
            st ='CreatedDate>=\"'+ startdate+ '\" and CreatedDate<=\"'+ enddate+ '\"';  
        }else{
            //st ='Asset__c==\"'+ AssetId + '\" and CreatedDate>=\"'+ startdate+ '\" and CreatedDate<=\"'+ enddate+ '\"';   
            st ='Asset__c==\"'+ AssetId +'\"and RecordTypeId==\"'+ recordtype + '\" and (( Start_Time_Map__c>\"'+ startdate + '\" and End_Time_Map__c<\"'+ enddate+ '\" and End_Time_Map__c>\"'+ startdate+ '\" and Start_Time_Map__c<\"'+ enddate+ '\" ) or ( Start_Time_Map__c>\"'+ startdate + '\" and End_Time_Map__c>\"'+ enddate+ '\" and End_Time_Map__c>\"'+ startdate+ '\" and Start_Time_Map__c<\"'+ enddate+ '\" )or ( Start_Time_Map__c<\"'+ startdate + '\" and End_Time_Map__c<\"'+ enddate+ '\" and End_Time_Map__c>\"'+ startdate+ '\" and Start_Time_Map__c<\"'+ enddate+ '\")or ( Start_Time_Map__c<\"'+ startdate + '\" and End_Time_Map__c>\"'+ enddate+ '\" and End_Time_Map__c>\"'+ startdate+ '\" and Start_Time_Map__c<\"'+ enddate+ '\"))';   
            //st = 'Asset__c==\"'+ AssetId + '\" and (( Start_Time__c>\"'+ startdate + '\" and End_Time__c<\"'+ enddate+ '\" and End_Time__c>\"'+ startdate+ '\" and Start_Time__c<\"'+ enddate+ '\" ) or ( Start_Time__c>\"'+ startdate + '\" and End_Time__c>\"'+ enddate+ '\" and End_Time__c>\"'+ startdate+ '\" and Start_Time__c<\"'+ enddate+ '\" ) or ( Start_Time__c<\"'+ startdate + '\" and End_Time__c<\"'+ enddate+ '\" and End_Time__c>\"'+ startdate+ '\" and Start_Time__c<\"'+ enddate+ '\" ) or ( Start_Time__c<\"'+ startdate + '\" and End_Time__c>\"'+ enddate+ '\" and End_Time__c>\"'+ startdate+ '\" and Start_Time__c<\"'+ enddate+ ')) \"'; 
        }
        
        system.debug('st'+st);
        
        Wave.ProjectionNode[] projs = new Wave.ProjectionNode[]{
            Wave.QueryBuilder.get('Name').alias('AssetName'),
                Wave.QueryBuilder.get('Asset__c').alias('AssetId'),
                Wave.QueryBuilder.get('Latitude__c').alias('Latitude'),
                Wave.QueryBuilder.get('Longitude__c').alias('Longtitude'),
                Wave.QueryBuilder.get('Battery_Current__c').alias('BatteryCurrent'),
                Wave.QueryBuilder.get('Start_Time_Formula__c').alias('StartTime'),
                Wave.QueryBuilder.get('End_Time_Formula__c').alias('EndTime'),
                Wave.QueryBuilder.get('Asset_Name__c').alias('AssetNameHis'),
                Wave.QueryBuilder.get('Asset_Account__c').alias('AssetAccount'),
                Wave.QueryBuilder.get('Asset_Customer_ID__c').alias('CustomerID'),
                Wave.QueryBuilder.get('CreatedDate').alias('CreatedDate'),
                Wave.QueryBuilder.get('Location__c').alias('Location')};
                    List<List<String>> orders = new List<List<String>>{new List<String>{'CreatedDate', 'asc'}};
                        id datasetid = system.label.DatasetId;
        ConnectApi.LiteralJson result = Wave.QueryBuilder.load(datasetid, versionId).filter(st).foreach(projs).order(orders).execute('q');
        String response = result.json;
        System.debug('Response  -- '+response);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response);
        system.debug('results--->>'+results);
        Map<String,Object> recs = (Map<String,Object>)results.get('results');
        system.debug('recs--->>'+recs);
        List<Object> lstCustomers = (List<Object>)recs.get('records');
        System.debug('lstCustomers'+lstCustomers);
        list<historyWrapper> finalLst = new List<historyWrapper>();
        for (Object customer : lstCustomers) {
            
            Map<String, Object> customerAttributes = (Map<String, Object>)customer;
            
            If((Decimal)customerAttributes.get('Latitude') != 0 && (Decimal)customerAttributes.get('Longtitude') != 0){
                
                finalLst.add(new historyWrapper((Id)customerAttributes.get('AssetId') , 
                                                (String)customerAttributes.get('AssetName'),
                                                (Decimal)customerAttributes.get('Latitude') , 
                                                (Decimal)customerAttributes.get('Longtitude'),
                                                (String)customerAttributes.get('StartTime'),
                                                (String)customerAttributes.get('EndTime'),
                                                (String)customerAttributes.get('AssetNameHis'),
                                                (String)customerAttributes.get('AssetAccount'),
                                                (String)customerAttributes.get('CustomerID'),
                                                (String)customerAttributes.get('Location')
                                               ));
                
            }
            system.debug('finalLst--->'+finalLst);
        }
        return finalLst;
    }
}