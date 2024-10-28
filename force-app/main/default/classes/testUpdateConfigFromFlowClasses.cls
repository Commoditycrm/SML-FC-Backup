@isTest
public class testUpdateConfigFromFlowClasses {
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'at5-t16ee4491f50'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        insert ast;
        Asset ast1 = new Asset();
        ast1.Name = 'at5-t16ee4491f51'; 
        ast1.Device_Id__c = 'at5-t16ee4491f51';
        ast1.AccountId = acc.Id;
        insert ast1;
        
        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Asset__c = ast.Id;
        astCon.RecordTypeId = AssetRecType.Id;
        astCon.individual_Config__c = true;
        insert astCon;
        Asset_Configuration__c astCon1 = new Asset_Configuration__c();
        astCon1.Asset__c = ast1.Id;
        astCon1.RecordTypeId = AssetRecType.Id;
        astCon1.individual_Config__c = false;
        insert astCon1;
        Asset_Configuration__c acntConf = new Asset_Configuration__c();
        acntConf.Account__c = acc.Id;
        acntConf.RecordTypeId = AccountRecType.Id;
        insert acntConf;
    }
    @IsTest
    Public Static Void testRedesignAC_UpdateConfigFromFlow(){
        Account acnt = [SELECT Id FROM Account];
        RedesignAC_UpdateConfigFromFlow.AcntDetailList testAcntDetailWithTrue = new RedesignAC_UpdateConfigFromFlow.AcntDetailList();
        testAcntDetailWithTrue.acntId = acnt.Id;
        testAcntDetailWithTrue.individualConfig = true;
        
        RedesignAC_UpdateConfigFromFlow.AcntDetailList testAcntDetailWithFalse = new RedesignAC_UpdateConfigFromFlow.AcntDetailList();
        testAcntDetailWithFalse.acntId = acnt.Id;
        testAcntDetailWithFalse.individualConfig = false;
        
        Test.startTest();
        RedesignAC_UpdateConfigFromFlow.updateConfigurationParameters(new List<RedesignAC_UpdateConfigFromFlow.AcntDetailList>{testAcntDetailWithTrue});
        RedesignAC_UpdateConfigFromFlow.updateConfigurationParameters(new List<RedesignAC_UpdateConfigFromFlow.AcntDetailList>{testAcntDetailWithFalse});
        Test.stopTest();
    }
}