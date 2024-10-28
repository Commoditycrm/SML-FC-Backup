@isTest
public class testDownstream_Config {
    @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'DC';
        acc1.ParentId = acc.Id;
        insert acc1;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.State_of_Pallet__c = 'In Network';
        ast.Current_Location__c = acc1.id;
        insert ast;
        
        RecordType AssetRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Asset' LIMIT 1];
        RecordType AccountRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Configuration__c' AND DeveloperName = 'Account' LIMIT 1];
        Asset_Configuration__c astCon = new Asset_Configuration__c();
        astCon.Asset__c = ast.Id;
        astCon.RecordTypeId = AssetRecType.Id;
        astCon.Accelerometer_Status_Desired__c = 'true';
        astCon.Connect_On_Tilt_Desired__c      = 'true';
        astCon.ConnectMovementEnd_Desired__c = 'true';
        astCon.ConnectMovementStart_Desired__c = 'false';
        astCon.Location_Sampling_Period_Desired__c = '86400';
        astCon.Location_Status_Desired__c = 'true';
        astCon.Log_Every_n_Desired__c = 0;
        astCon.Measurement_Period_desired__c = '900';
        astCon.Network_Check_in_period_Desired__c = '86400';
        astCon.Reference_X_Desired__c = 0;
        astCon.Reference_Y_Desired__c = 0;
        astCon.Reference_Z_Desired__c = 0;
        astCon.Temperature_Check_in_Period_Desired__c = '86400';
        astCon.Temperature_Status_Desired__c = 'true';
        astCon.Tilt_Degrees_Desired__c = 15;
        astCon.Tracking_Location_Period_desired__c = '7200';
        astCon.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        astCon.Trackmode_Desired__c = '3';
        astCon.Use_Cell_Desired__c = 'true';
        astCon.Use_GPS_Desired__c = 'false';
        astCon.Use_WiFi_Desired__c = 'true';
        astCon.Individual_config__c = false;
        astCon.Current_Account_Name__c = acc.Id;
        astCon.NLResponseStatus__c = 'Processing';
        insert astCon;
        Asset_Configuration__c acntConf = new Asset_Configuration__c();
        acntConf.Account__c = acc1.Id;
        acntConf.RecordTypeId = AccountRecType.Id;
        acntConf.Accelerometer_Status_Desired__c = 'true';
        acntConf.Connect_On_Tilt_Desired__c      = 'true';
        acntConf.ConnectMovementEnd_Desired__c = 'true';
        acntConf.ConnectMovementStart_Desired__c = 'false';
        acntConf.Location_Sampling_Period_Desired__c = '86400';
        acntConf.Location_Status_Desired__c = 'true';
        acntConf.Log_Every_n_Desired__c = 0;
        acntConf.Measurement_Period_desired__c = '900';
        acntConf.Network_Check_in_period_Desired__c = '86400';
        acntConf.Reference_X_Desired__c = 0;
        acntConf.Reference_Y_Desired__c = 0;
        acntConf.Reference_Z_Desired__c = 0;
        acntConf.Temperature_Check_in_Period_Desired__c = '86400';
        acntConf.Temperature_Status_Desired__c = 'true';
        acntConf.Tilt_Degrees_Desired__c = 15;
        acntConf.Tracking_Location_Period_desired__c = '7200';
        acntConf.Tracking_Locations_per_Check_Ins_Desired__c = '1';
        acntConf.Trackmode_Desired__c = '3';
        acntConf.Use_Cell_Desired__c = 'true';
        acntConf.Use_GPS_Desired__c = 'false';
        acntConf.Use_WiFi_Desired__c = 'true';
        insert acntConf;
    }
    
    @IsTest
    Static Void testDownstream_Config_UpdateBatch(){
        //Account acnt = [Select Id from Account Limit 1];
        List<Asset> astList = [Select Id, Name, AccountId, State_of_Pallet__c, Current_Location__c from Asset];
        Test.startTest();
        
        RedesignAC_Downstream_Config_UpdateBatch res = new RedesignAC_Downstream_Config_UpdateBatch(astList);
        Database.executeBatch(res,100);
        Test.stopTest();
    }
     @IsTest
    Static Void testAC_DC_to_NLUpdate_Batch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{}'));
        RedesignAC_DC_to_NLUpdate_Batch res = new RedesignAC_DC_to_NLUpdate_Batch();
        Database.executeBatch(res,100);
        Test.stopTest();
    }
     @IsTest
    Static Void testAC_DC_to_NLUpdate_FailBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{"error": "MockError"}'));
        RedesignAC_DC_to_NLUpdate_Batch res = new RedesignAC_DC_to_NLUpdate_Batch();
        Database.executeBatch(res,100);
        Test.stopTest();
    }
    /*private class MockErrorHttpResponseGenerator implements HttpCalloutMock {
public HTTPResponse respond(HTTPRequest req) {
HttpResponse res = new HttpResponse();
res.setStatusCode(400);
res.setStatus('OK');
res.setBody('{"error": "MockError"}');
return res;
}
}*/
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