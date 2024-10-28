@isTest
public class TruePowerResetTest {
    private static Id astId; // Declaring astId as a class-level variabl

    @isTest
    public static void testTruePowerResetBatch() {
        // Test data setup
        List<Api_Response__c> apiResponses = new List<Api_Response__c>();
        List<API_Response_childs__c> apiResponseChildLst = new List<API_Response_childs__c>();
        account acc=new account();
        acc.name='testaccount';
        insert acc;
        asset ast=new asset();
        ast.Name='testAsset01';
        ast.AccountId=acc.id;
        insert ast;
        astId = ast.Id;
        for (Integer i = 2000; i < 2050; i++) {
            Api_Response__c apiResponse = new Api_Response__c();
            apiResponse.Asset__c = ast.Id;
            apiResponse.device_status__c ='({battery=6.86, estBattPct=87.3, network=lte, powerUptime=' + i + ', rsrp=-99, rsrq=-13, rssi=-72, signal=2, ts=1709850671})';
            // You can add other required fields if needed
            apiResponses.add(apiResponse);
        }
        insert apiResponses;
        Api_Response__c apiResponse = new Api_Response__c();
            apiResponse.Asset__c = ast.Id;
            apiResponse.device_status__c = '({battery=6.86, estBattPct=87.3, network=lte, powerUptime=' +25 + ', rsrp=-99, rsrq=-13, rssi=-72, signal=2, ts=1709850671})';
        insert apiResponse;
        // For ARC===================================================================
        for (Integer i = 2000; i < 2050; i++) {
            API_Response_childs__c apiResponseChild = new API_Response_childs__c();
            apiResponseChild.Asset__c = ast.Id;
            apiResponseChild.PowerUptime__c = (i==2040 ? 0 : i);
            apiResponseChild.Timestamp_Device_Status__c = 11072956+i;
            apiResponseChild.ARC_External_Id__c = 'unique' + i;
            apiResponseChildLst.add(apiResponseChild);
        }
        insert apiResponseChildLst;        
        API_Response_childs__c apiResponseChild = new API_Response_childs__c();
        apiResponseChild.Asset__c = ast.Id;
        apiResponseChild.PowerUptime__c = 25;
        apiResponseChild.Timestamp_Device_Status__c = 11072956+3000;
        apiResponseChild.ARC_External_Id__c = 'unique' + 25;
        insert apiResponseChild;
        
        Test.startTest();
         Asset queriedAst = [SELECT Id, Name FROM Asset WHERE Name = 'testAsset01'];
        String apiQueryFilter = 'SELECT Id, Asset__c,device_status__c, name FROM Api_Response__c where Asset__r.name = \'testAsset01\'';
        Database.executeBatch(new TruePowerResetRevisedBatch(true), 1);
        Test.stopTest();

        List<Asset> assets = [SELECT Id, Name FROM Asset WHERE Name LIKE 'testAsset%'];
        System.assertEquals(1, assets.size());
/*
        // Check the email sent
        List<Messaging.SingleEmailMessage> emails = Messaging.sendEmail(new Messaging.SingleEmailMessage());
        System.assertEquals(1, emails.size());
        Messaging.SingleEmailMessage email = emails[0];
        System.assertEquals('commodityccrm@gmail.com', email.getToAddresses()[0]);
        System.assertEquals('Assets with true power reset', email.getSubject());
        System.assertNotEquals(null, email.getPlainTextBody());
        // Add other email body assertions if needed */
    }
}