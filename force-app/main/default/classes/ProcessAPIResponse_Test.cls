@isTest
public with sharing class ProcessAPIResponse_Test {
    private static Pallet_Location_Event__e testEventPositionAP;
    private static void init() {
        //create testPallet
        testEventPositionAP = new Pallet_Location_Event__e(
            Device_Id__c='0',
            Asset_Group_Id__c='TestAssetGroupId',
            Humidity__c = 33.2,
            Temperature__c = 59.2,
            Shock_Threshold__c = 160,
            Shock_Count__c = 1,
            Shock_Max__c = 170,
            Shock_Max_Time__c = 2,
            Field1__c = '000000003445',
            Field2__c = 'RDF000000023',
            Position_Source__c = 'AP',
            Last_Connected__c = system.now().adddays(1)
        );
    }

        private static testMethod void process_insertAssets() {
            init();
            List<Pallet_Location_Event__e> lapi=new List<Pallet_Location_Event__e>();
            lapi.add(testEventPositionAP);
        ProcessAPIResponse api =new ProcessAPIResponse();

            test.startTest();
            ProcessAPIResponse.process(lapi);
            test.stopTest();
        }

}