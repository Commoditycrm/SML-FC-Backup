/**
 * @description Test class for TmsIntegrationService
 * @author RadialSpark
 */
@isTest
private class TmsIntegrationServiceTest {

    private static Account sourceLocation;
    private static Account targetLocation;
    private static Account carrierLocation;

    private static void init() {
        // Insert TMS Credentials (mocked)
        insert new TMS_Credentials__c(
            Username__c = 'tmsUsername',
            Password__c = 'tmsPassword',
            Is_Production__c = false,
            Endpoint__c = 'https://www.testTmsEndpoint.com'
        );

        String sourceLabel = '';

        // Parent Account
        Account parentAccount = AccountTestDataFactory.createParentAccount(
            'Parent Account',
            true
        );

        // Carrier, Source, and Target locations
        carrierLocation = AccountTestDataFactory.createAccount(
            'Carrier Location',
            'Location',
            '123 Carrier St',
            'Chandler',
            'AZ',
            '85226',
            33.307501,
            -111.9421107,
            parentAccount.Id,
            sourceLabel,
            false,
            null
        );
        carrierLocation.ShippingCountry = 'United States';
        insert carrierLocation;

        sourceLocation = AccountTestDataFactory.createAccount(
            'Source Location',
            'Location',
            '123 Source St',
            'Chandler',
            'AZ',
            '85226',
            33.307501,
            -111.9421107,
            parentAccount.Id,
            sourceLabel,
            false,
            null
        );
        sourceLocation.ShippingCountry = 'United States';
        insert sourceLocation;

        targetLocation = AccountTestDataFactory.createAccount(
            'Target Location',
            'Location',
            '123 Target St',
            'Chandler',
            'AZ',
            '85226',
            33.307501,
            -111.9421107,
            parentAccount.Id,
            sourceLabel,
            false,
            null
        );
        targetLocation.ShippingCountry = 'United States';
        insert targetLocation;
    }

    /**
     * @description verify that when a Source Location account is posted, it is processed correctly
     */
    @isTest
    private static void postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateSourceLocationExternalId() {
        init();
        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));

        System.Test.startTest();
        Account updatedAccount = TmsIntegrationService.postTradingPartner(sourceLocation.Id);
        System.Test.stopTest();

    }

    @isTest
    private static void testGetLoads_ShouldReturnSuccessfulResponses() {
        // Arrange test records
        TmsIntegrationServiceTest.init(); // your init() to create Accounts + Credentials
    
        BOL__c testBol = new BOL__c(
            Pickup__c = Date.today(),
            Dropoff__c = Date.today().addDays(2),
            Total_Pallets__c = 5,
            Source_Location__c = sourceLocation.Id,
            Target_Location__c = targetLocation.Id
        );
        insert testBol;
    
        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));
    
        // Act
        Test.startTest();
        TmsIntegrationService.getLoads(new List<BOL__c>{testBol});
        Test.stopTest();
    
        // Assert
    }

    /**
     * @description verify that when a Target Location account is posted, it is processed correctly
     */
    @isTest
    private static void postTradingPartner_ShouldSuccessfullyPostTradingPartnerAndUpdateTargetLocationExternalId() {
        init();
        System.Test.setMock(HttpCalloutMock.class, new HttpMockResponse_PostTradingPartner(true));

        System.Test.startTest();
        Account updatedAccount = TmsIntegrationService.postTradingPartner(targetLocation.Id);
        System.Test.stopTest();

    }
}