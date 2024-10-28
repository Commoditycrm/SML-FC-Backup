@IsTest
public class Configuration_Ctrl_For_DeactivationTest {
    
    @IsTest
    public static void testFordeactivation() {
        // Arrange: Set up the data and input for the test
        List<String> deviceIDs = new List<String>{'at-s4b2f40cc'};
            
            // Act: Call the method being tested
            Configuration_Ctrl_For_Deactivation.Fordeactivation(deviceIDs);
        
        // Assert: Validate the results of the method call
        Test.startTest();
        
        // Mocking Utilityclass method
        UtilityclassMock mockUtility = new UtilityclassMock();
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        // Re-run the method under test within a Test context
        Configuration_Ctrl_For_Deactivation.Fordeactivation(deviceIDs);
        
        Test.stopTest();
        
        // Here, validate that the mocked method was called with the expected parameters.
        System.assertEquals(mockUtility.calledWithDeviceIds, null);
        System.assertEquals(mockUtility.calledWithAction, null);
    }
    
    @IsTest
    public static void testForactivation() {
        // Arrange: Set up the data and input for the test
        List<String> deviceIDs = new List<String>{'at-s442f40cc'};
            
            // Act: Call the method being tested
            Configuration_Ctrl_For_Activation.Foractivation(deviceIDs);
        
        // Assert: Validate the results of the method call
        Test.startTest();
        
        // Mocking Utilityclass method
        UtilityclassMock mockUtility = new UtilityclassMock();
        Test.setMock(HttpCalloutMock.class, mockUtility);
        
        // Re-run the method under test within a Test context
        Configuration_Ctrl_For_Activation.Foractivation(deviceIDs);
        
        Test.stopTest();
        
        // Here, validate that the mocked method was called with the expected parameters.
        System.assertEquals(mockUtility.calledWithDeviceIds, null);
        System.assertEquals(mockUtility.calledWithAction, null);
    }
    
    // Mock class for Utilityclass
    public class UtilityclassMock implements HttpCalloutMock {
        public List<String> calledWithDeviceIds;
        public String calledWithAction;
        
        public HttpResponse respond(HttpRequest req) {
            // Assuming the callout is a HTTP callout, we mock the response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
        
        public void calloutActivateDeactivate(List<String> deviceIds, String action) {
            this.calledWithDeviceIds = deviceIds;
            this.calledWithAction = action;
        }
    }
}