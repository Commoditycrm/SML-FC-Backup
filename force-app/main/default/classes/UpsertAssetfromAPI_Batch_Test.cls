@IsTest
public class UpsertAssetfromAPI_Batch_Test {
    private static Api_Response__c testEventPositionAP;
    private static Api_Response__c testEventPositionAP1;
    private static Api_Response__c testEventPositionGEO;
    private static Account parentAccount;
    private static Account testAccount;
    private static Account testAccount1;
    private static Product2 testProduct;
    private static Asset accessPoint;
    private static Asset accessPoint1;
    private static Asset tag;
    private static Asset testasset;
    private static Asset testasset1;

    private static void init() {
         String sourceLabel = Account.Location_Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        
		Account parentAccount = AccountTestDataFactory.createParentAccount(
			'Parent Account',
			true
		);

        Message_Type__c msgtype=new Message_Type__c();
        msgtype.Battery_Current_Use__c=0.5369;
        msgtype.Description__c='HeartBeat';
        msgtype.Name='2';
        insert msgtype;
        
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
            'Location ID 1'
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
            Msg_Type__c = 2,
            Battery_Level__c = 2.454,
            Access_Point_Id__c=String.valueOf(accessPoint.Id),
            Last_Connected__c = system.now().adddays(-2)
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
            Last_Connected__c = system.now().adddays(-1),
            Access_Point_Id__c=String.valueOf(accessPoint.Id)
        );
        

         testEventPositionGEO = new Api_Response__c(
            Device_Id__c='45fgf352',
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
            Last_Connected__c = system.now().adddays(1),
            Access_Point_Id__c=String.valueOf(accessPoint.Id)
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
        
        testasset = new Asset();
			testasset.Current_Location__c = testAccount.id;
			testasset.State_of_Pallet__c = 'In Network';
			testasset.Temporary_Latitude__c = null;
			testasset.Temporary_Longitude__c = null;
			//testasset.Last_Known_Location__c = lastKnownLocation;
			testasset.Temperature__c = 34.7;
			testasset.Last_Connected__c = DateTime.newInstance(2019, 9, 16);
			testasset.Device_Id__c = '12sd2sf';
			//testasset.Product2Id = palletType;
			testasset.Name = 'Pallet';
			testasset.AccountId = parentAccount.Id;
        testasset.Access_Point__c=accessPoint.Id;
        testasset.Message_Types__c=msgtype.Id;
		        
        testasset1 = new Asset();
			testasset1.Current_Location__c = testAccount.id;
			testasset1.State_of_Pallet__c = 'In Network';
			testasset1.Temporary_Latitude__c = 43.76;
			testasset1.Temporary_Longitude__c = -89.767;
			//testasset1.Last_Known_Location__c = lastKnownLocation;
			testasset1.Temperature__c = 34.7;
			testasset1.Last_Connected__c = DateTime.newInstance(2019, 9, 16);
			testasset1.Device_Id__c = '45fgf352';
			//testasset1.Product2Id = palletType;
			testasset1.Name = 'Pallet';
			testasset1.AccountId = parentAccount.Id;
       		testasset1.Access_Point__c=accessPoint.Id;
			testasset1.Is_Access_Point__c=false;
    }
    private static testmethod void upsert_BatchTest(){
        init();
        insert accessPoint;
        insert accessPoint1;
        //testEventPositionAP.Access_Point_Id__c ='12sd2sf';
        //testEventPositionAP.Access_Point_Id__c = String.ValueOf(accessPoint.Id);
        insert testEventPositionAP;
        insert testEventPositionAP1;
        insert testEventPositionGEO;
        //insert testasset1;
        insert testasset;
        
        List<Api_Response__c> events = new List<Api_Response__c>();
        events.add(testEventPositionAP);
        events.add(testEventPositionGEO);
        events.add(testEventPositionAP1);

        test.startTest();
        UpsertAssetfromApi_Batch  updatebatch = new UpsertAssetfromApi_Batch();
        DataBase.executeBatch(updatebatch);
        //system.assertEquals(0, historyRecords.size());
        test.stopTest();
    }
    
}