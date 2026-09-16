@isTest
private class WXE_SmartPallet_ctrl_Test {

    @isTest
    static void test_parseSmartPalletResponse() {
        // Create a test Asset with Name (LPN)
        Account acc = New Account(Name='Test SmartPallets');
        insert acc;
        Asset ast = new Asset(
            Name = 'LPN123456',
            AccountId = acc.id,
            Field2__c = 'LPN123456'
        );
        insert ast;

        // Construct mock JSON payload
        String payload = '{' +
            '"bolnumber": "12345",' +
            '"ordertype": "Express",' +
            '"zipcodefrom": "94107",' +
            '"zipcodeto": "94043",' +
            '"shipclosedate": "2024-06-14",' +
            '"shipmethod": "Air",' +
            '"customername": "Test Customer",' +
            '"smartpallets": [' +
                '{"lpn": "LPN123456"},' +
                '{"lpn": "INVALID_LPN"}' +
            ']' +
        '}';

        // Set up REST request context
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ProcessSmartPalletData/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(payload);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST method
        String responseMessage = WXE_SmartPallet_ctrl.parseSmartPalletResponse();

        // Assert response
        System.assert(responseMessage.contains('Successfully received'));

        // Verify that the API response was inserted
        List<Api_Response__c> responses = [SELECT Id, smart_pallets__c, Unavailable_SmartPallets__c FROM Api_Response__c];
    }
}