public with sharing class AccountSearchController {
    static String token;
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchKey) {
        return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + searchKey + '%') LIMIT 10];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAcc(boolean astType) {
        return [SELECT Id, Name FROM Account WHERE Id in (Select AccountId from Asset where is_loco_Asset__c=:astType)];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAllAssets() {
        return [SELECT Id, Name, Account_Name__c, Last_Connected__c FROM Asset LIMIT 50000];
    }
	@AuraEnabled(cacheable=true)
    public static List<Asset> getAssetsByAccountId(String accountId, boolean islocoAsset) {
        return [SELECT Id, Name, Account_Name__c, Last_Connected__c ,LastModifiedDate FROM Asset 
                WHERE AccountId = :accountId and is_loco_Asset__c=:islocoAsset order by CreatedDate LIMIT 50000];
    }
    @AuraEnabled(cacheable=true)
    public static Integer getTotalAssets() {
        return [SELECT COUNT() FROM Asset];
    }
    
    @AuraEnabled(cacheable=true)
    public static void calloutActivateDeactivate(List<String> deviceIDs, String status) {
        List<String> strlist = new List<String>();
        for (Asset Ast : [SELECT Id, Name, Device_Id__c FROM Asset WHERE Name IN :deviceIDs]) {
            strlist.add(Ast.Device_Id__c);
        }
        String loopval = String.join(strlist, ',');
        
        try {
            token = generatetoken();
            String authorize = 'Bearer ' + token;
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setTimeout(60000);
            req1.setMethod('POST');
            req1.setHeader('content-type', 'application/json');
            req1.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34');
            req1.setHeader('Authorization', authorize);

            String endpt1 = (status == 'Activate') 
                ? 'https://api.iot.nimbelink.net/v1/devices/activate' 
                : 'https://api.iot.nimbelink.net/v1/devices/deactivate';
            
            String resbody = '{"devices": [' + loopval + ']}';
            req1.setBody(resbody);
            
            HttpResponse res1 = h1.send(req1);
            System.debug('Response: ' + res1.getBody());
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }
    
    public static String generatetoken() {
        String username1;
        String password1;
        assetConfigUsername__mdt OwnedDeviceMdt = [ SELECT Password__c, UserName__c FROM assetConfigUsername__mdt WHERE Unique_Id__c = 'Leased'];
        username1 = OwnedDeviceMdt.UserName__c;
        password1 = OwnedDeviceMdt.Password__c;
        
        Http h = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setMethod('POST');
       
        req.setHeader('content-type', 'application/json');
        req.setHeader('x-api-key', 'c4X3jIqTbzakxQe3OreSk12co0D4QcRIWq1SLQ34');
        
        String obj = '{"username": "' + username1 + '","password": "' + password1 + '"}';
        req.setBody(obj);
        req.setEndpoint('https://api.iot.nimbelink.net/v1/auth');
        HttpResponse res = h.send(req);
        Map<String, Object> tokenobj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        return (String) tokenobj.get('token');
    }
}