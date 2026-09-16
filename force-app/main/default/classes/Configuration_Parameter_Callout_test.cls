@istest
public class Configuration_Parameter_Callout_test {
    public static testmethod void configuration(){
        account acc=new account();
        acc.name='test';
        insert acc;
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.Id;
        insert ast;
        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];

        Asset_Configuration__c astCon = new Asset_Configuration__c(
            Asset__c = ast.Id,
            RecordTypeId = AssetRecType.Id,
            Accelerometer_Status_Desired__c = 'true',
            Individual_config__c = false,
            Current_Account_Name__c = acc.Id,
            NLResponseStatus__c = 'Processing'
        );
        insert astCon;

        Asset_Configuration__c acntConf = new Asset_Configuration__c(
            Account__c = acc.Id,
            RecordTypeId = AccountRecType.Id,
            Accelerometer_Status_Desired__c = 'true'
        );
        insert acntConf;
        test.startTest();
        Configuration_Parameter_Callout.getParameter(ast.Id);
        test.stopTest();
        
    }
}