@isTest
public class RedesignNl_DistanceAHCBatchTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Testing');
        insert acc;

        Asset a1 = new Asset(
            AccountId = acc.Id,
            Name = 'Test Asset 1',
            Capture_Distance_Records__c = true,
            rack_type__c = 'Rail Car 1'
        );
        Asset a2 = new Asset(
            AccountId = acc.Id,
            Name = 'Test Asset 2',
            Capture_Distance_Records__c = false,
            rack_type__c = 'Rail Car 1'
        );
        insert new List<Asset>{ a1, a2 };

        API_Response__c r1 = new API_Response__c(Asset__c = a1.Id);
        API_Response__c r2 = new API_Response__c(Asset__c = a2.Id);
        insert new List<API_Response__c>{ r1, r2 };

        List<RecordType> rts = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'API_Response_Childs__c' AND DeveloperName = 'Distance'
            LIMIT 1
        ];
        System.assert(!rts.isEmpty(), 'Missing RecordType Distance for API_Response_Childs__c in target org');
        Id rtId = rts[0].Id;

        API_Response_Childs__c c1 = new API_Response_Childs__c(
            Asset__c = a1.Id,
            api_response__c = r1.Id,
            RecordTypeId = rtId,
            Status__c = 'New',
            Distance__c = '50.0',
            Distance_Level__c = 'Low',
            async__c = true,
            Timestamp_DateTime__c = System.now(),
            ARC_External_Id__c = 'test-ARC1-' + String.valueOf(System.now().getTime())
        );

        API_Response_Childs__c c2 = new API_Response_Childs__c(
            Asset__c = a2.Id,
            api_response__c = r2.Id,
            RecordTypeId = rtId,
            Status__c = 'New',
            Distance__c = '60.0',
            Distance_Level__c = 'Low',
            async__c = true,
            Timestamp_DateTime__c = System.now(),
            ARC_External_Id__c = 'test-ARC2-' + String.valueOf(System.now().getTime())
        );

        insert new List<API_Response_Childs__c>{ c1, c2 };
    }

    @isTest
    static void testBatchExecution() {
        List<API_Response__c> apiResps = [SELECT Id, Asset__c, Asset__r.rack_type__c FROM API_Response__c];

        Test.startTest();
        Database.executeBatch(
            new RedesignNl_DistanceAHCBatch(new List<Id>(), System.now().addDays(-1), apiResps),
            100
        );
        Test.stopTest();

        // ✅ Assert ARC status updated
        for (API_Response_Childs__c arc : [SELECT Id, Status__c, Asset_History__c, Asset__r.Capture_Distance_Records__c
                                          FROM API_Response_Childs__c]) {
            System.assertEquals('Processed', arc.Status__c, 'ARC should be Processed');
            if (arc.Asset__r.Capture_Distance_Records__c) {
                System.assertNotEquals(null, arc.Asset_History__c, 'AHC should be linked when Capture=true');
            }
        }

        // ✅ Assert AHC inserted for Capture=true asset
        Integer ahcCount = [SELECT count() FROM Asset_History_custom__c WHERE Latest_API_Response_Child__c != null];
        System.assert(ahcCount > 0, 'Expected at least 1 Distance AHC');

        // ✅ Assert Asset updated
        for (Asset a : [SELECT Id, Distance_Datetime__c, Distance__c, Distance_Level__c, async__c FROM Asset]) {
            System.assertNotEquals(null, a.Distance_Datetime__c, 'Asset.Distance_Datetime__c should be updated');
            System.assertNotEquals(null, a.Distance__c, 'Asset.Distance__c should be updated');
        }
    }
}