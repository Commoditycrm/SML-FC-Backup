@isTest
public with sharing class UpsertAssetfromApi_Test {
    private static Api_Response__c testEventPositionAP;
    private static Api_Response__c testEventPositionAP1;
    private static Api_Response__c testEventPositionGEO;
    private static Account parentAccount;
    private static Account testAccount;
    private static Account testAccount1;
    private static Product2 testProduct;
    private static Asset accessPoint;
    private static Asset accessPoint1;
    private static Asset accessPoint2;
    private static Asset tag;
    
    private static void init() {
                /*testEventPositionAP1 = new Pallet_Location_Event__e(
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
            Position_Source__c = 'AP'
        );*/
        
       
        //get picklist option 'Source' for Account.Location_Type__c
       	String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        
		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
            'TestAssetGroupId',
			true
		);

		testAccount = AccountTestDataFactory.createAccount(
			'SMART',
			'Location',
			'7366 E Shea Blvd',
			'Scottsdale',
			'AZ',
			'85260',
			33.5837301,
			-111.9244083,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 0',
            'TestAssetGroupId'
		);

		testAccount1 = AccountTestDataFactory.createAccount(
			'radialSpark',
			'Location',
			'5710 W Chandler Blvd',
			'Chandler',
			'AZ',
			'85226',
			33.307501,
			-111.9421107,
			parentAccount.Id,
			sourceLabel,
			true, 
            'Location ID 1',
            'TestAssetGroupId1'
		);

		testProduct = ProductTestDataFactory.createProduct('Unknown Tag', 'Pallet', true);

		accessPoint = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.307501, 
            -111.9421107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test-ap-Id', 
            testProduct.Id
        );
        
        accessPoint2 = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.307501, 
            -111.9421107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test-ap-Id', 
            testProduct.Id
        );
        
       /* accessPoint1 = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.3546501, 
            -111.9456107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test-ap-Id', 
            testProduct.Id
        );*/
        
        
        //create testPallet
        testEventPositionAP = new Api_Response__c(
            Device_Id__c='12sd2sf',
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
            Msg_Type__c = 1,
            Battery_Level__c = 2.454,
            Last_Connected__c = system.now().adddays(1)
        );
        testEventPositionAP1 = new Api_Response__c(
            Device_Id__c='12sd2sf',
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
            Msg_Type__c = 1,
            Battery_Level__c = 2.454,
            Last_Connected__c = system.now().adddays(1)
        );

         testEventPositionGEO = new Api_Response__c(
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
            Position_Source__c = 'GPS',
            Latitude__c = 33.5837301,
            Longitude__c = -111.9244083,
            Msg_Type__c = 2,
            Battery_Level__c = 2.454,
            Last_Connected__c = system.now().adddays(1)
        );
        
        accessPoint1 = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.307501, 
            -111.9421107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test-gp-Id', 
            null
        );
        
        
        tag = AssetTestDataFactory.createPallet(
            testAccount.Id, 
            'In Network', 
            33.307501, 
            -111.9421107, 
            testAccount1.Id, 
            67.89, 
            DateTime.newInstance(2018, 1, 1), 
            'test-tag-Id', 
            testProduct.Id
        );
	}

    private static testMethod void process_insertAssets() {
        init();
        insert accessPoint;
        insert accessPoint1;
        testEventPositionAP.Access_Point_Id__c = accessPoint.Device_Id__c;
        testEventPositionAP1.Access_Point_Id__c = accessPoint.Device_Id__c;
        insert testEventPositionAP;
        insert testEventPositionAP1;
        insert testEventPositionGEO;
       
        List<Api_Response__c> events = new List<Api_Response__c>();
        events.add(testEventPositionAP);
        events.add(testEventPositionAP1);
        events.add(testEventPositionGEO);
        
        System.Test.startTest();
        UpsertAssetfromApi ap = new UpsertAssetfromApi();
        ap.AssetEventProcessor(events);

        testEventPositionGEO.Latitude__c = 43.565701;
        testEventPositionGEO.Longitude__c = -89.976083;
        testEventPositionGEO.Last_Connected__c=date.today();
        testEventPositionAP.Access_Point_Id__c = accessPoint1.Device_Id__c;
        update testEventPositionGEO;
        update testEventPositionAP;
        ap.AssetEventProcessor(events);
        ap.AssetEventProcessor(events);
        System.Test.stopTest();
        
		List<Asset> findAsset = [SELECT Id, Temporary_Latitude__c FROM Asset];
        //System.assertEquals(1, findAsset.size());
        //System.assertEquals(testEventPositionGEO.Latitude__c, findAsset[0].Temporary_Latitude__c);
    }
    
   /* private static testMethod void process_updateAssets() {
		init();
        insert accessPoint;
        //insert accessPoint1;
        insert tag;
        
        testEventPositionAP.Device_Id__c = tag.Device_Id__c;
        testEventPositionAP.Temperature__c = 59.2;
        testEventPositionAP.Access_Point_Id__c = accessPoint.Device_Id__c;
        //testEventPositionAP1.Access_Point_Id__c = accessPoint1.Device_Id__c;
        
        List<Pallet_Location_Event__e> events = new List<Pallet_Location_Event__e>();
        events.add(testEventPositionAP);
        //events.add(testEventPositionAP1);

        AssetEventProcessor ap = new AssetEventProcessor(events);
        
        System.Test.startTest();
        ap.process();
        System.Test.stopTest();
        
		Asset findAsset = [SELECT Id, Temperature__c FROM Asset WHERE ID = :tag.Id];
        //System.assertEquals(testEventPositionAP.Temperature__c, findAsset.Temperature__c);
    }*/
    
}