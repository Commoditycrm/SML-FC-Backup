@isTest
public class Trigger_Helper_Test {
    
    static testMethod void setupData() {
        // Insert Accounts with different conditions
        Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert new List<Account>{acc1, acc2};

        // Insert Assets
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEV123', AccountId = acc1.Id, Date_Shipped__c=System.now()-10,
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc2.id, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Network',
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc1.id,
        Rack_Type__c='84" A-Frame Rack',
        Track_Full_History__c=true,
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        Asset asset2 = new Asset(Name = 'Test Asset 2', Device_Id__c = 'DEV456', AccountId = acc2.Id, State_of_Pallet__c = 'In Transit',
                                 Temporary_Latitude__c = 44.1234, Temporary_Longitude__c = -108.1234,Track_Full_History__c=false,Date_Shipped__c=System.now()-10,
                                 Last_Connected__c = System.now(), Is_NimbeLink_Asset__c = false,Last_Known_Location__c=acc2.id,
         Rack_Type__c='84" A-Frame Rack',
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        insert new List<Asset>{asset1, asset2};

        // Insert Related Customer
        Related_Customer__c relCust = new Related_Customer__c(Source_Account__c = acc1.Id, Related_To__c = acc2.Id);
        insert relCust;
 
        List< Asset_History_custom__c>ashislst = new list< Asset_History_custom__c>();
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c= asset2.id;
        assetHsitory.Current_Location_Address__c =asset1.id;
        
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Message_Count__c = 0;        
        
        assetHsitory.Still_in_this_Location__c=true;
       
        //insert assetHsitory;
        
        Asset_History_custom__c assetHsitorym=new Asset_History_custom__c();
        assetHsitorym.Asset__c=asset2.id;
        assetHsitorym.Location__c='In Network';
        assetHsitorym.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym.Start_Time__c=system.now()-2;
        assetHsitorym.End_Time__c=system.now();
        //insert assetHsitorym;
        
        Asset_History_custom__c assetHsitory1=new Asset_History_custom__c();
        assetHsitory1.Asset__c=asset2.id;
        assetHsitory1.Location__c='In Network';
        assetHsitory1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory1.Start_Time__c=system.now()-2;
        assetHsitory1.End_Time__c=system.now();
        assetHsitory1.Still_in_this_Location__c=true;
        
        //insert assetHsitory1;
        
        Asset_History_custom__c assetHsitorym1=new Asset_History_custom__c();
        assetHsitorym1.Asset__c=asset2.id;
        assetHsitorym1.Location__c=asset2.Current_Location_Name__c;
          assetHsitorym1.Current_Location_Address__c = asset1.id;
        assetHsitorym1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym1.Start_Time__c=system.now()-2;
        assetHsitorym1.End_Time__c=asset2.Last_Connected__c;
   
        ashislst.add(assetHsitory);
         ashislst.add(assetHsitorym);
         ashislst.add(assetHsitory1);
         ashislst.add(assetHsitorym1);
      
        insert ashislst;
    }

    static testMethod void testUpdateAddress() {
        setupData();
        
        List<Asset> assetList = [SELECT Id, Device_Id__c, AccountId, Temporary_Latitude__c, Temporary_Longitude__c FROM Asset];
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();

        Test.startTest();
        Trigger_Helper.updateAddress(assetList, oldAssetMap, true, false, true);
          Trigger_Helper.updateAddress(assetList, oldAssetMap, false, true, true);
        Test.stopTest();
    }
    
    static testMethod void testUpdateLastConnectedField() {
        //setupData();
        
        List<Asset> assetList=new List<Asset>();
         Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert new List<Account>{acc1, acc2};

        // Insert Assets
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEV1231', AccountId = acc1.Id, Date_Shipped__c=System.now()-10,
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc2.id, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Network',
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc1.id,
        Rack_Type__c='84" A-Frame Rack',
        Track_Full_History__c=true,
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        Asset asset2 = new Asset(Name = 'Test Asset 2', Device_Id__c = 'DEV456', AccountId = acc2.Id, State_of_Pallet__c = 'In Transit',
                                 Temporary_Latitude__c = 44.1234, Temporary_Longitude__c = -108.1234,Track_Full_History__c=false,Date_Shipped__c=System.now()-10,
                                 Last_Connected__c = System.now(), Is_NimbeLink_Asset__c = false,Last_Known_Location__c=acc2.id,
         Rack_Type__c='84" A-Frame Rack',
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        assetList.add(asset1);
        assetList.add(asset2);
        insert assetList;

        Test.startTest();
        Trigger_Helper.updateLastconnectedfield(assetList);
        Test.stopTest();
    }

    static testMethod void testCreateAssetForInsert() {
       // setupData();
                 Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert acc1;
        insert acc2;
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEV1232', AccountId = acc1.Id, Date_Shipped__c=System.now()-10,
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc1.id, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Network',Account_to_Update__c =null,
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc2.id,
        Rack_Type__c='84" A-Frame Rack',
        Track_Full_History__c=true,
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        insert asset1;
        Asset asset2 = new Asset(Name = 'Test Asset21', Device_Id__c = 'tes1232', AccountId = acc1.Id, Date_Shipped__c=System.now()-10,
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Transit',
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc2.id,
        Rack_Type__c='84" A-Frame Rack',
        Track_Full_History__c=true,
        Start_Time__c = system.now(),
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        insert asset2;
        Test.startTest();
        Trigger_Helper.createAssetForInsert(asset1, 'both');
        Trigger_Helper.createAssetForInsert(asset1, 'location');
      
         Trigger_Helper.createAssetForInsert(asset2, 'both');
        Trigger_Helper.createAssetForInsert(asset2, 'location');
        Test.stopTest();
    }

    static testMethod void testCreateHistoryRec() {
         Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert new List<Account>{acc1, acc2};

        // Insert Assets
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEVt123', AccountId = acc1.Id, Date_Shipped__c=System.now()-10,
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc2.id, 
                                 Last_Connected__c = System.now()-10, State_of_Pallet__c = 'In Network',
                                 Is_NimbeLink_Asset__c = false, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc1.id,
        Rack_Type__c='84" A-Frame Rack',
        Track_Full_History__c=true,
        Start_Time__c = system.now()-10,
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        Asset asset2 = new Asset(Name = 'Test Asset 2', Device_Id__c = 'DEVt456', AccountId = acc2.Id, State_of_Pallet__c = 'In Transit',
                                 Temporary_Latitude__c = 44.1234, Temporary_Longitude__c = -108.1234,Track_Full_History__c=false,Date_Shipped__c=System.now()-10,
                                 Last_Connected__c = System.now()-10, Is_NimbeLink_Asset__c = false,Last_Known_Location__c=acc2.id,
         Rack_Type__c='84" A-Frame Rack',
        Start_Time__c = system.now()-10,
        signal__c=-72.02,
        estBattPct__c=40.02,
       Humidity__c=39.00,
        rsrp__c=-79.01,
        rsrq__c=10.01,
        rssi__c=-72.02,
        eventName__c='Start1',
       Temperature__c= 30.01,
        src__c='g');
        List<Asset> astlist = New List<Asset>();
         List<Asset> astlist1 = New List<Asset>();
        astlist.add(asset1);
        astlist.add(asset2);
        insert  astlist;

        // Insert Related Customer
        Related_Customer__c relCust = new Related_Customer__c(Source_Account__c = acc1.Id, Related_To__c = acc2.Id);
        insert relCust;
        
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        Map<Id, Asset> oldAssetMap1 = new Map<Id, Asset>();
        for (Asset ast : astlist) {
            oldAssetMap.put(ast.Id, ast); // Simulated previous coordinates
        }
        for (Asset ast : astlist) {
            ast.Last_Connected__c=system.now();
            ast.Current_Location__c=acc2.id;
            ast.Temporary_Latitude__c = ast.Temporary_Latitude__c+6;
            ast.Temporary_Longitude__c = ast.Temporary_Longitude__c-10;
        }
        update astlist;

        List< Asset_History_custom__c>ashislst = new list< Asset_History_custom__c>();
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c= asset2.id;
        //assetHsitory.Current_Location_Address__c =asset1.id;
        
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Message_Count__c = 0;        
        
        assetHsitory.Still_in_this_Location__c=true;
       
        //insert assetHsitory;
        
        Asset_History_custom__c assetHsitorym=new Asset_History_custom__c();
        assetHsitorym.Asset__c=asset2.id;
        assetHsitorym.Location__c='In Network';
        assetHsitorym.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym.Start_Time__c=system.now()-2;
        assetHsitorym.End_Time__c=system.now();
        //insert assetHsitorym;
        
        Asset_History_custom__c assetHsitory1=new Asset_History_custom__c();
        assetHsitory1.Asset__c=asset2.id;
        assetHsitory1.Location__c='In Network';
        assetHsitory1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory1.Start_Time__c=system.now()-2;
        assetHsitory1.End_Time__c=system.now();
        assetHsitory1.Still_in_this_Location__c=true;
        
        //insert assetHsitory1;
        
        Asset_History_custom__c assetHsitorym1=new Asset_History_custom__c();
        assetHsitorym1.Asset__c=asset2.id;
        assetHsitorym1.Location__c=asset2.Current_Location_Name__c;
          //assetHsitorym1.Current_Location_Address__c = asset1.id;
        assetHsitorym1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym1.Start_Time__c=system.now()-2;
        assetHsitorym1.End_Time__c=asset2.Last_Connected__c;
   
        ashislst.add(assetHsitory);
         ashislst.add(assetHsitorym);
         ashislst.add(assetHsitory1);
         ashislst.add(assetHsitorym1);
      
        insert ashislst;
        
        Test.startTest();
        //Trigger_Helper.createHistoryrec(astList, null, true);
        //Trigger_Helper.createHistoryrec(astList, null, false);
       // Trigger_Helper.createHistoryrec(astList1, null, true);
        //Trigger_Helper.createHistoryrec(astList1, null, false);
        Test.stopTest();
    }

    static testMethod void testCreateAndUpdateInventory() {
        setupData();

        Test.startTest();
        Trigger_Helper.createandUpdateInventory();
        Test.stopTest();
    }

    static testMethod void testCreateAndUpdateInventoryNimbelink() {
        //setupData();
         // 1. Setup Test Data
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{acc1, acc2};

        Inventory__c inv1 = new Inventory__c(Parent_Account__c = acc1.Id, Location_Account__c = acc1.id, Rack_Type__c = 'Type X', Asset_Count__c = 0);
        Inventory__c inv2 = new Inventory__c(Parent_Account__c = acc2.Id, Is_In_Transit__c = true, Rack_Type__c = 'Type Y', Asset_Count__c = 0);
        insert new List<Inventory__c>{inv1, inv2};

        List<Asset> assets = new List<Asset>();
        // Assets for existing Inventory 1
        assets.add(new Asset(Name='testDev1',AccountId = acc1.Id, Current_Location__c = acc1.Id, Rack_Type__c = 'Type X', Is_Access_Point__c = false));
        assets.add(new Asset(Name='testDev2',AccountId = acc1.Id, Current_Location__c = acc1.Id, Rack_Type__c = 'Type X', Is_Access_Point__c = false));
        // Assets for existing Inventory 2 (In Transit)
        assets.add(new Asset(Name='testDev3',AccountId = acc2.Id, State_of_Pallet__c = 'In transit', Rack_Type__c = 'Type Y', Is_Access_Point__c = false));
        // Assets for new Inventory (Location B, Type Z, Account 1)
        assets.add(new Asset(Name='testDev4',AccountId = acc1.Id, Current_Location__c = acc2.Id, Rack_Type__c = 'Type Z', Is_Access_Point__c = false));
        insert assets;
        Test.startTest();
        Trigger_Helper.createandUpdateInventoryNimbelink();
        Test.stopTest();
    }

    static testMethod void testUpdateDwellDays() {
        setupData();
        
        List<Asset> assetList = [SELECT Id, Total_Dwell_Days__c FROM Asset];
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();

        Test.startTest();
        Trigger_Helper.updatedwelldays(assetList, oldAssetMap);
        Test.stopTest();
    }

    static testMethod void testUpdateFacilityLocation() {
        //setupData();
        Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert new List<Account>{acc1, acc2};

        // Insert Assets
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEV123', AccountId = acc1.Id, 
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc2.id, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Network',
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc1.id);

        Asset asset2 = new Asset(Name = 'Test Asset 2', Device_Id__c = 'DEV456', AccountId = acc2.Id, State_of_Pallet__c = 'In Transit',
                                 Temporary_Latitude__c = 44.1234, Temporary_Longitude__c = -108.1234,Track_Full_History__c=false,
                                 Last_Connected__c = System.now(), Is_NimbeLink_Asset__c = false,Last_Known_Location__c=acc2.id);

       List<Asset> astlist= New  List<Asset>{asset1, asset2};
        insert astlist;

        //List<Asset> assetList = [SELECT Id,AccountId, Temporary_Latitude__c, Temporary_Longitude__c FROM Asset];
        //Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
         Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        for (Asset ast : astlist) {
            oldAssetMap.put(ast.Id, new Asset(Id = ast.Id, Temporary_Latitude__c = 35.0000, Temporary_Longitude__c = -110.0000)); // Simulated previous coordinates
        }
        Test.startTest();
        Trigger_Helper.updateFacilityLocation(astlist, oldAssetMap, true, false);
        
        Trigger_Helper.updateFacilityLocation(astlist, oldAssetMap, false, true);
        Trigger_Helper.updateFacilityLocation(astlist, oldAssetMap, true, false);

        
        Test.stopTest();
    }

    static testMethod void testUpdateLastKnownLocation() {
        setupData();
        
        List<Asset> assetList = [SELECT Id,AccountId, Current_Location__c FROM Asset];
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>([SELECT Id,AccountId, Current_Location__c FROM Asset]);

        Test.startTest();
        Trigger_Helper.updateLastKnownLocation(assetList, oldAssetMap);
        Test.stopTest();
    }

    static testMethod void testUpdateEstBatteryPercentage() {
        setupData();
        
        List<Asset> assetList = [SELECT Id, Battery_Replaced_Date__c, Power_Reset_Time__c FROM Asset];
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();

        Test.startTest();
        Trigger_Helper.updateEstBatteryPercentage(assetList, oldAssetMap);
        Test.stopTest();
    }

    static testMethod void testUpdateStartAndEndTime() {
        setupData();
                List<Asset> assetList = [SELECT Id, Battery_Replaced_Date__c, Power_Reset_Time__c FROM Asset];

        List<Asset_History_custom__c> historyList = new List<Asset_History_custom__c>{
            new Asset_History_custom__c(Asset__c=assetList[0].id,Start_Time__c = System.now(), End_Time__c = System.now().addHours(2))
        };
        insert historyList;

        Test.startTest();
        Trigger_Helper.updatestartandaendtime(historyList);
        Test.stopTest();
    }

    static testMethod void testUpdatedDwell() {
        //setupData();
         Account acc1 = new Account(Name = 'Test Account 1', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 33.1234, shippinglongitude = -96.1234);
        Account acc2 = new Account(Name = 'Test Account 2', GeoFence_Radius_in_Miles__c = 1, shippinglatitude = 35.1234, shippinglongitude = -97.1234);
        insert new List<Account>{acc1, acc2};

        // Insert Assets
        Asset asset1 = new Asset(Name = 'Test Asset 1', Device_Id__c = 'DEV123', AccountId = acc1.Id, 
                                 Temporary_Latitude__c = 33.1234, Temporary_Longitude__c = -96.1234,Current_Location__c=acc2.id, 
                                 Last_Connected__c = System.now(), State_of_Pallet__c = 'In Network',
                                 Is_NimbeLink_Asset__c = true, Battery_Voltage__c = 12.5,Last_Known_Location__c=acc1.id);

        Asset asset2 = new Asset(Name = 'Test Asset 2', Device_Id__c = 'DEV456', AccountId = acc2.Id, State_of_Pallet__c = 'In Transit',
                                 Temporary_Latitude__c = 44.1234, Temporary_Longitude__c = -108.1234,Track_Full_History__c=false,
                                 Last_Connected__c = System.now(), Is_NimbeLink_Asset__c = true,Last_Known_Location__c=acc2.id);
        //insert asset1;
        List<Asset> astlist= New  List<Asset>{asset2,asset1};
        insert astlist;

        // Insert Related Customer
        Related_Customer__c relCust = new Related_Customer__c(Source_Account__c = acc1.Id, Related_To__c = acc2.Id);
        insert relCust;
 
        List< Asset_History_custom__c>ashislst = new list< Asset_History_custom__c>();
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c= asset2.id;
        assetHsitory.Current_Location_Address__c ='test Address';
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory.Start_Time__c=system.now()-1;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Message_Count__c = 0;       
        assetHsitory.Consider_for_Dwell__c=true;
        
        assetHsitory.Still_in_this_Location__c=true;
       
        //insert assetHsitory;
        
        Asset_History_custom__c assetHsitorym=new Asset_History_custom__c();
        assetHsitorym.Asset__c=asset2.id;
        assetHsitorym.Location__c='In Network';
        assetHsitorym.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym.Start_Time__c=system.now()-1;
        assetHsitorym.End_Time__c=system.now();
         assetHsitory.Consider_for_Dwell__c=true;
        //insert assetHsitorym;
        
        Asset_History_custom__c assetHsitory1=new Asset_History_custom__c();
        assetHsitory1.Asset__c=asset2.id;
        assetHsitory1.Location__c='In Network';
        assetHsitory1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitory1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitory1.Start_Time__c=system.now()-1;
        assetHsitory1.End_Time__c=system.now();
         assetHsitory.Consider_for_Dwell__c=true;
        assetHsitory1.Still_in_this_Location__c=true;
        
        //insert assetHsitory1;
        
        Asset_History_custom__c assetHsitorym1=new Asset_History_custom__c();
        assetHsitorym1.Asset__c=asset2.id;
        assetHsitorym1.Location__c=asset2.Current_Location_Name__c;
          assetHsitorym1.Current_Location_Address__c = 'test Address';
        assetHsitorym1.Latitude__c=asset2.Current_Location__r.shippinglatitude;
        assetHsitorym1.Longitude__c=asset2.Current_Location__r.shippinglongitude;
        assetHsitorym1.Start_Time__c=system.now()-1;
         assetHsitory.Consider_for_Dwell__c=true;
        assetHsitorym1.End_Time__c=asset2.Last_Connected__c;
   
        ashislst.add(assetHsitory);
         ashislst.add(assetHsitorym);
         ashislst.add(assetHsitory1);
         ashislst.add(assetHsitorym1);
      
        insert ashislst;

        //List<Asset> assetList = [SELECT Id FROM Asset];
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
        oldAssetMap.put(asset2.id,asset2);
        Test.startTest();
        Trigger_Helper.updateddwell(astlist, oldAssetMap);
         Trigger_Helper.updatedwelldays(astlist, oldAssetMap);
        assetHsitory.Start_Time__c=system.now()-16;
        assetHsitorym.Start_Time__c=system.now()-17;
        assetHsitory1.Start_Time__c=system.now()-16;
        assetHsitorym1.Start_Time__c=system.now()-18;
        update assetHsitory;
         update assetHsitory1;
         update assetHsitorym;
         update assetHsitorym1;
       Map<Id, Asset> newMapofAssr = new Map<Id, Asset>();
        for (Asset ast : astlist) {
            oldAssetMap.put(ast.Id, new Asset(Id = ast.Id, Last_Known_Location__c = ast.Last_Known_Location__c));
        }
         //Map<Id, Asset> newMapofAssr = new Map<Id, Asset>();
        newMapofAssr.put(asset2.id,asset2);
        Trigger_Helper.updateddwell(astlist, newMapofAssr);
         Trigger_Helper.updatedwelldays(astlist, newMapofAssr);
        Test.stopTest();
    }

    static testMethod void testUpdateExceptionHandling() {
        setupData();
        
        // Force an error by providing null values
        List<Asset> assetList = new List<Asset>{new Asset()};
        Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();

        Test.startTest();
        try {
            Trigger_Helper.updateAddress(assetList, oldAssetMap, true, false, true);
        } catch (Exception ex) {}

        try {
            //Trigger_Helper.createHistoryrec(assetList, oldAssetMap, true);
            // Trigger_Helper.createHistoryrec(assetList, oldAssetMap, false);
        } catch (Exception ex) {}

        Test.stopTest();
    }
}