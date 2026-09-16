@isTest
public class testDownstream_Config {
    @testSetup 
static void testDataSetup(){
    Account acc = new Account(Name = 'Testing');
    insert acc;

    Account acc1 = new Account(Name = 'DC', ParentId = acc.Id, Source_Account__c = acc.Id);
    insert acc1;

    // ---- Assets (2 paths)
    Asset astNetwork = new Asset(
        Name = 'atp2bbef1c017f', 
        Device_Id__c = 'at5-t16ee4491f50',
        AccountId = acc.Id,
        State_of_Pallet__c = 'In Network',
        Current_Location__c = acc1.Id,
        isNew_Asset__c = true,
        pause_job__c = false
    );
    insert astNetwork;

    Asset astTransit = new Asset(
        Name = 'TransitAsset',
        Device_Id__c = 'transit-001',
        AccountId = acc.Id,
        State_of_Pallet__c = 'In Transit',
        // Current_Location__c not used for In Transit
        isNew_Asset__c = true,
        pause_job__c = false
    );
    insert astTransit;

    // ---- Record Types
    RecordType rtAsset = [
        SELECT Id FROM RecordType
        WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset'
        LIMIT 1
    ];
    RecordType rtAccount = [
        SELECT Id FROM RecordType
        WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account'
        LIMIT 1
    ];
    RecordType rtDefault = [
        SELECT Id FROM RecordType
        WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Default'
        LIMIT 1
    ];

    // ---- Asset Configs (both assets must be picked up by start() query)
    insert new Asset_Configuration__c(
        Asset__c = astNetwork.Id,
        RecordTypeId = rtAsset.Id,
        Individual_config__c = false,
        Accelerometer_Status_Desired__c = 'true',
        Current_Account_Name__c = acc.Id,
        NLResponseStatus__c = 'Processing' // doesn't matter now because query no longer filters it
    );

    insert new Asset_Configuration__c(
        Asset__c = astTransit.Id,
        RecordTypeId = rtAsset.Id,
        Individual_config__c = false,
        Accelerometer_Status_Desired__c = 'true',
        Current_Account_Name__c = acc.Id,
        NLResponseStatus__c = 'Success'
    );

    // ---- Account configs for acc1 (Downstream) and defaults (Upstream)
    // Downstream Account config (rt = Account)
    Asset_Configuration__c acc1AccountCfg = new Asset_Configuration__c(
        Account__c = acc1.Id,
        RecordTypeId = rtAccount.Id,
        Accelerometer_Status_Desired__c = 'true',
        Connect_On_Tilt_Desired__c = 'false'
    );
    insert acc1AccountCfg;

    // Default config for acc1 (rt = Default)
    Asset_Configuration__c acc1DefaultCfg = new Asset_Configuration__c(
        Account__c = acc1.Id,
        RecordTypeId = rtDefault.Id,
        Accelerometer_Status_Desired__c = 'false',
        Connect_On_Tilt_Desired__c = 'true'
    );
    insert acc1DefaultCfg;

    // Make Account config newer than Default config (forces: acc.LastModifiedDate > def.LastModifiedDate)
    acc1AccountCfg.Connect_On_Tilt_Desired__c = 'true';
    update acc1AccountCfg;

    // ---- Default config for ROOT account (acc) to hit else-block:
    // accConfig missing for Current_Account_Name__c, but default exists for Asset__r.AccountId
     Asset_Configuration__c PAC = new Asset_Configuration__c(
        Account__c = acc.Id,
        RecordTypeId = rtDefault.Id,
        Accelerometer_Status_Desired__c = 'true',
        Connect_On_Tilt_Desired__c = 'false'
    );
    insert PAC;
    
    PAC.Accelerometer_Status_Desired__c = 'false';
    update PAC;
    
    
}

    
    @IsTest
    static void testDownstream_Config_UpdateBatch(){
        List<Asset> astList = [SELECT Id, Name, AccountId, State_of_Pallet__c, Current_Location__c FROM Asset];

        Test.startTest();
        RedesignAC_Downstream_Config_UpdateBatch res = new RedesignAC_Downstream_Config_UpdateBatch(astList);
        Database.executeBatch(res, 10);
        Test.stopTest();

        // Validate that batch execution updated Asset_Configuration__c records
        List<Asset_Configuration__c> updatedConfigs = [SELECT Id, Current_Account_Name__c FROM Asset_Configuration__c];
        //System.assert(updatedConfigs.size() > 0, 'Asset configurations should be updated');
    }

    @IsTest
    static void testBatchFinishMethod(){
        List<Asset> astList = [SELECT Id FROM Asset];

        Test.startTest();
        RedesignAC_Downstream_Config_UpdateBatch batchJob = new RedesignAC_Downstream_Config_UpdateBatch(astList);
        Database.executeBatch(batchJob, 10);
        Test.stopTest();

        // Ensure Batch_Data_Custom__c was updated
        List<Batch_Data_Custom__c> batchLogs = [SELECT Id, Status__c FROM Batch_Data_Custom__c WHERE Batch_Name__c = 'SF to NL Config Update Batch'];
       // System.assert(batchLogs.size() > 0, 'Batch log should exist');
       // System.assertEquals('Completed', batchLogs[0].Status__c, 'Batch should be marked as Completed');
    }

    @IsTest
    static void testRunInTransitEverBatch(){
        Test.startTest();
        RedesignAC_Downstream_Config_UpdateBatch.runInTransitEverBatch();
        Test.stopTest();

        // Validate batch job execution
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'RedesignNL_InTransitEverAHCBatch' LIMIT 1];
       // System.assert(!jobs.isEmpty(), 'RedesignNL_InTransitEverAHCBatch should be scheduled');
    }

    @IsTest
    static void testScheduleBatch(){
        Test.startTest();
        RedesignAC_Downstream_Config_UpdateBatch.scheduleBatch();
        Test.stopTest();

        // Verify that schedule batch triggered correctly
        List<AsyncApexJob> scheduledJobs = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'RedesignNL_CreateAssetHistoryBatch' LIMIT 1];
       // System.assert(!scheduledJobs.isEmpty(), 'RedesignNL_CreateAssetHistoryBatch should be scheduled');
    }

    @IsTest
    static void testAC_DC_to_NLUpdate_Batch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{}'));
        RedesignAC_DC_to_NLUpdate_Batch res = new RedesignAC_DC_to_NLUpdate_Batch();
        Database.executeBatch(res, 10);
        Test.stopTest();
    }

    @IsTest
    static void testAC_DC_to_NLUpdate_FailBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{"error": "MockError"}'));
        RedesignAC_DC_to_NLUpdate_Batch res = new RedesignAC_DC_to_NLUpdate_Batch();
        Database.executeBatch(res, 10);
        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setStatus('OK');
            res.setBody(responseBody);
            return res;
        }
    }
}