/**
 * @author -- Gokulprasath
 * @date -- 02/20/2019
 * @description -- This Class provide test coverage to Trigger Helper.
 **/

@isTest
public class TriggerHelper_Test 
{
    
    
   public static testmethod void createAssetForInsert()
    {
       List< Message_Type__c>msglst = new list< Message_Type__c>();
        Message_Type__c msgtype=new Message_Type__c();
        msgtype.Battery_Current_Use__c=0.5369;
        msgtype.Description__c='HeartBeat';
        msgtype.Name='2';
       // insert msgtype;
       
        
        Message_Type__c msgtype1=new Message_Type__c();
        msgtype1.Battery_Current_Use__c=0.5369;
        msgtype1.Description__c='HeartBeat1';
        msgtype1.Name='3';
        //insert msgtype1;
        msglst.add(msgtype);
        msglst.add(msgtype1);
        insert msglst;
        
       List<Account>acclist = new list<Account>(); 
        Account Acc = new Account();
         Acc.Name ='Cardinal Glass';
         Acc.phone='9600205548';
        Acc.BillingCity='Chennai';
        Acc.BillingCountry='India';
        Acc.BillingPostalCode='123456';
        Acc.BillingState='Tamil Nadu';
        Acc.BillingStreet='1st Street';
        Acc.shippinglatitude=40.1823;
        Acc.shippinglongitude=80.1562;
        Acc.Type='Location';
        
        //Acc.RecordTypeId=accRecordTypeId;
        //insert Acc;
        
        Account Acc1 = new Account();
         Acc1.Name ='Cardinal Glass Spring Green';
        Acc1.ParentId=Acc.Id;
         Acc1.phone='9600205548';
        Acc1.BillingCity='Spring Green';
        Acc1.BillingCountry='United States';
        Acc1.BillingPostalCode='53588';
        Acc1.BillingState='WI';
        Acc1.BillingStreet='1011 East Madison Street';
        Acc1.shippinglatitude=43.174395;
        Acc1.shippinglongitude=-90.058477;
        //ACC1.RecordTypeId=accRecordTypeId1;
        ACC1.External_Location_Id__c='1';
       // insert Acc1;
        
         Account Acc2 = new Account();
         Acc2.Name ='Eagle Window & Door - TEST';
         Acc2.Type='Location';   
        //Acc2.ParentId=Acc.Id;
         Acc2.phone='9600205548';
        Acc2.BillingCity='Dubuque';
        Acc2.BillingCountry='United States';
        Acc2.BillingPostalCode='52001';
        Acc2.BillingState='IA';
        Acc2.BillingStreet='2045 Kerper Boulevard';
        Acc2.shippinglatitude=42.516301;
        Acc2.shippinglongitude=-90.657592;
        //ACC2.RecordTypeId=accRecordTypeId1;
        ACC2.External_Location_Id__c='2';
       // insert Acc2;
        acclist.add(Acc);
        acclist.add(Acc1);
        acclist.add(Acc2);
        insert acclist;
        
        Related_Customer__c Rc = new Related_Customer__c();
        rc.Source_Account__c = acclist[0].id;
        rc.Related_To__c = acclist[1].Id;
        insert rc;
        
        Related_Customer__c Rc1 = new Related_Customer__c();
        rc1.Source_Account__c = acclist[0].Id ;
        rc1.Related_To__c = acclist[2].Id;
        insert rc1;
        list<asset> astlist = new list<asset>();
        Asset asst=new Asset(Name='Test');
        asst.AccountId=acclist[0].Id;
        asst.Current_Location__c=acclist[0].Id;
        
        asst.Message_Types__c=msglst[0].Id;
        asst.Last_Connected__c=system.now();
        asst.State_of_Pallet__c='In Transit';
        asst.Temporary_Latitude__c=42.515732;
        asst.Temporary_Longitude__c= -90.658826;
        asst.Facility_Location__c ='SGIG Production';
        asst.Device_Id__c='12345678';
        asst.Field2__c='123465';
        asst.Rack_Type__c='84" A-Frame Rack';
        asst.Message_Types__c=msglst[1].Id;
        asst.Track_Full_History__c=true;
        asst.Start_Time__c = system.now();
        asst.Message_Count__c = 1;
        
        asst.alt__c=285.062;
        asst.Battery_Voltage__c=40;
        asst.signal__c=-72.02;
        asst.estBattPct__c=40.02;
       asst.Humidity__c=39.00;
        asst.rsrp__c=-79.01;
        asst.rsrq__c=10.01;
        asst.rssi__c=-72.02;
        asst.eventName__c='Start1';
        asst.Temperature__c= 30.01;
        asst.src__c='g';
        //asst.Is_NimbeLink_Asset__c = true;
        //insert asst; 
        

        Asset asst1=new Asset(Name='Test1');
        asst1.AccountId=acclist[0].Id;
       // asst1.Device_Id__c='at-atp2bbef1c017f';
        asst1.Current_Location__c=Acc1.Id;
        asst1.Message_Types__c=msglst[0].Id;
        asst1.Last_Connected__c=system.now();
        asst1.State_of_Pallet__c='In Transit';
        asst1.Temporary_Latitude__c=40.1823;
        asst1.Temporary_Longitude__c=-90.058477;
        asst1.Device_Id__c='1234567';
        asst1.Field2__c='123465';
        asst1.Rack_Type__c='84" A-Frame Rack';
        asst1.Message_Types__c=msglst[1].Id;
        asst1.Track_Full_History__c=false;
        asst1.Start_Time__c = system.now();
        asst1.Message_Count__c = 1;
        asst1.alt__c=285.062;
        asst1.signal__c=-72.02;
        asst1.estBattPct__c=40.02;
       asst1.Humidity__c=39.00;
        asst1.Battery_Voltage__c=40;
        asst1.rsrp__c=-79.01;
        asst1.rsrq__c=10.01;
        asst1.rssi__c=-72.02;
        asst1.eventName__c='Start1';
        asst1.Temperature__c= 30.01;
        asst1.src__c='g';
                asst1.Trackmode__c='2';
        
        
        asst1.Is_NimbeLink_Asset__c = true;
       // insert asst1;
		astlist.add(asst);
        astlist.add(asst1);
        Test.startTest();
        insert astlist;
        list<Asset_History_Field__mdt>mdtlst = new list<Asset_History_Field__mdt>();
        
        List< Asset_History_custom__c>ashislst = new list< Asset_History_custom__c>();
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c= astlist[0].id;
        assetHsitory.Current_Location_Address__c =acclist[0].id;
        
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitory.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Battery_Current__c=0.2165489653;
		assetHsitory.Message_Count__c = 0;        
        
        assetHsitory.Still_in_this_Location__c=true;
       
		//insert assetHsitory;
        
        Asset_History_custom__c assetHsitorym=new Asset_History_custom__c();
        assetHsitorym.Asset__c=astlist[0].id;
        assetHsitorym.Changed_Field__c='Message Description';
        assetHsitorym.Location__c='In Network';
        assetHsitorym.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitorym.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitorym.Start_Time__c=system.now()-2;
        assetHsitorym.End_Time__c=system.now();
        assetHsitorym.Battery_Current__c=0.2165489653;
        assetHsitorym.Current_Message_Type__c=true;
        assetHsitorym.New_Value__c=String.valueOf(asst.Message_Types__c);
        assetHsitorym.Message_Count__c = 0;   
		//insert assetHsitorym;
        
        Asset_History_custom__c assetHsitory1=new Asset_History_custom__c();
        assetHsitory1.Asset__c=astlist[1].id;
        assetHsitory1.Changed_Field__c='Location';
        assetHsitory1.Location__c='In Network';
        assetHsitory1.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitory1.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitory1.Start_Time__c=system.now()-2;
        assetHsitory1.End_Time__c=system.now();
        assetHsitory1.Battery_Current__c=0.2165489653;
        assetHsitory1.Still_in_this_Location__c=true;
        
		//insert assetHsitory1;
        
        Asset_History_custom__c assetHsitorym1=new Asset_History_custom__c();
        assetHsitorym1.Asset__c=astlist[1].id;
        assetHsitorym1.Changed_Field__c='Message Description';
        assetHsitorym1.Location__c=asst.Current_Location_Name__c;
          assetHsitorym1.Current_Location_Address__c = astlist[0].id;
        assetHsitorym1.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitorym1.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitorym1.Start_Time__c=system.now()-2;
        assetHsitorym1.End_Time__c=asst.Last_Connected__c;
        assetHsitorym1.Battery_Current__c=0.2165489653;
        assetHsitorym1.Current_Message_Type__c=true;
        assetHsitorym1.New_Value__c=String.valueOf(asst.Message_Types__c);
		//insert assetHsitorym1;
        ashislst.add(assetHsitory);
         ashislst.add(assetHsitorym);
         ashislst.add(assetHsitory1);
         ashislst.add(assetHsitorym1);
      
        insert ashislst;
        list<Asset>asts = new list<asset>();
        asst.Field2__c = '123';
        asst.Temporary_Latitude__c=40.1824;
        asst.Temporary_Longitude__c=-90.058478;
        asst.Last_Connected__c=system.now()-1;
        asst.Message_Types__c = msglst[1].id;
        asst.Track_Full_History__c=false;
        asst.Start_Time__c = system.now();
        asst.Message_Count__c = 1;
        asst.alt__c=285.062;
        asst.signal__c=-72.02;
        asst.estBattPct__c=40.02;
        asst.Humidity__c=39.00;
        asst.Battery_Voltage__c=40;
        asst.rsrp__c=-79.01;
        asst.rsrq__c=10.01;
        asst.rssi__c=-72.02;
        asst.eventName__c='Start1';
        asst.Temperature__c= 30.01;
        asst.src__c='g';
       // update asst;
      
        
       list<asset> newasset=new list<asset>();
    
        asst1.Field2__c = '123';
        asst1.Temporary_Latitude__c=40.1824;
        asst1.Temporary_Longitude__c=-90.058478;
        asst1.Message_Types__c = msglst[1].id;
        asst1.Current_Location__c=Acc.Id;
        asst1.Last_Connected__c=system.now()-1;
        asst1.Track_Full_History__c=false;
        asst1.Start_Time__c = system.now();
        asst1.Message_Count__c = 1;
        asst1.Date_Shipped__c=system.today();
        asst1.alt__c=285.062;
        asst1.signal__c=-72.02;
        asst1.estBattPct__c=40.02;
       asst1.Humidity__c=39.00;
        asst1.Battery_Voltage__c=40;
        asst1.rsrp__c=-79.01;
        asst1.rsrq__c=10.01;
        asst1.rssi__c=-72.02;
        asst1.eventName__c='Start1';
        asst1.Temperature__c= 30.01;
        asst1.src__c='g';
        //asst1.Current_Location_Name__c
        //update asst1;
       // newasset.add(asst1);
        asts.add(asst);
        asts.add(asst1);
       
       
            
        Trigger_Helper.createandUpdateInventoryNimbelink();
        Trigger_Helper.createAssetForInsert(asst1,'both');
        update asts;
        
       Test.stopTest();
        
       
    
    }
    public static testmethod void createAssetForInsert2()
    {
       List< Message_Type__c>msglst = new list< Message_Type__c>();
        Message_Type__c msgtype=new Message_Type__c();
        msgtype.Battery_Current_Use__c=0.5369;
        msgtype.Description__c='HeartBeat';
        msgtype.Name='2';
       // insert msgtype;
       
        
        Message_Type__c msgtype1=new Message_Type__c();
        msgtype1.Battery_Current_Use__c=0.5369;
        msgtype1.Description__c='HeartBeat1';
        msgtype1.Name='3';
        //insert msgtype1;
        msglst.add(msgtype);
        msglst.add(msgtype1);
        insert msglst;
        
       List<Account>acclist = new list<Account>(); 
        Account Acc = new Account();
         Acc.Name ='Cardinal Glass';
         Acc.phone='9600205548';
        Acc.BillingCity='Chennai';
        Acc.BillingCountry='India';
        Acc.BillingPostalCode='123456';
        Acc.BillingState='Tamil Nadu';
        Acc.BillingStreet='1st Street';
        Acc.shippinglatitude=40.1823;
        Acc.shippinglongitude=80.1562;
        Acc.Type='Location';
        
        //Acc.RecordTypeId=accRecordTypeId;
        //insert Acc;
        
        Account Acc1 = new Account();
         Acc1.Name ='Cardinal Glass Spring Green';
        Acc1.ParentId=Acc.Id;
         Acc1.phone='9600205548';
        Acc1.BillingCity='Spring Green';
        Acc1.BillingCountry='United States';
        Acc1.BillingPostalCode='53588';
        Acc1.BillingState='WI';
        Acc1.BillingStreet='1011 East Madison Street';
        Acc1.shippinglatitude=43.174395;
        Acc1.shippinglongitude=-90.058477;
        //ACC1.RecordTypeId=accRecordTypeId1;
        ACC1.External_Location_Id__c='1';
       // insert Acc1;
        account Acc4=new account();
        Acc4.Name='test';
        Acc4.ParentId=Acc.Id;
         Acc4.phone='9600205548';
        Acc4.BillingCity='Spring Green';
        Acc4.BillingCountry='United States';
        Acc4.BillingPostalCode='53588';
        Acc4.BillingState='WI';
        Acc4.BillingStreet='1011 East Madison Street';
        Acc4.shippinglatitude=43.174395;
        Acc4.shippinglongitude=-90.058477;
        //ACC1.RecordTypeId=accRecordTypeId1;
        Acc4.External_Location_Id__c='1';
       insert Acc4;
        
         Account Acc2 = new Account();
         Acc2.Name ='Eagle Window & Door - TEST';
         Acc2.Type='Location';   
        //Acc2.ParentId=Acc.Id;
         Acc2.phone='9600205548';
        Acc2.BillingCity='Dubuque';
        Acc2.BillingCountry='United States';
        Acc2.BillingPostalCode='52001';
        Acc2.BillingState='IA';
        Acc2.BillingStreet='2045 Kerper Boulevard';
        Acc2.shippinglatitude=42.516301;
        Acc2.shippinglongitude=-90.657592;
        //ACC2.RecordTypeId=accRecordTypeId1;
        ACC2.External_Location_Id__c='2';
       // insert Acc2;
        acclist.add(Acc);
        acclist.add(Acc1);
        acclist.add(Acc2);
        insert acclist;
        
        Related_Customer__c Rc = new Related_Customer__c();
        rc.Source_Account__c = acclist[0].id;
        rc.Related_To__c = acclist[1].Id;
        insert rc;
        
        Related_Customer__c Rc1 = new Related_Customer__c();
        rc1.Source_Account__c = acclist[0].Id ;
        rc1.Related_To__c = acclist[2].Id;
        insert rc1;
        list<asset> astlist = new list<asset>();
        Asset asst=new Asset(Name='Test');
        asst.AccountId=acclist[0].Id;
        asst.Current_Location__c=acclist[0].Id;
        
        asst.Message_Types__c=msglst[0].Id;
        asst.Last_Connected__c=system.now();
        asst.State_of_Pallet__c='In Transit';
        asst.Temporary_Latitude__c=42.515732;
        asst.Temporary_Longitude__c= -90.658826;
        asst.Facility_Location__c ='SGIG Production';
        asst.Device_Id__c='12345678';
        asst.Field2__c='123465';
        asst.Rack_Type__c='84" A-Frame Rack';
        asst.Message_Types__c=msglst[1].Id;
        asst.Track_Full_History__c=true;
       // asst.Start_Time__c = system.now();
      //  asst.Message_Count__c = 1;
        
        asst.alt__c=285.062;
        asst.Battery_Voltage__c=40;
        asst.signal__c=-72.02;
        asst.estBattPct__c=40.02;
       asst.Humidity__c=39.00;
        asst.rsrp__c=-79.01;
        asst.rsrq__c=10.01;
        asst.rssi__c=-72.02;
        asst.eventName__c='Start1';
        asst.Temperature__c= 30.01;
        asst.src__c='g';
        //asst.Is_NimbeLink_Asset__c = true;
        //insert asst; 
        

        Asset asst1=new Asset(Name='Test1');
        asst1.AccountId=acclist[0].Id;
        asst1.Current_Location__c=Acc1.Id;
        asst1.Trackmode__c='3';
        asst1.Message_Types__c=msglst[0].Id;
        asst1.Last_Connected__c=system.now();
        asst1.State_of_Pallet__c='In Transit';
        asst1.Temporary_Latitude__c=40.1823;
        asst1.Temporary_Longitude__c=-90.058477;
        asst1.Device_Id__c='at-att193418b0ae9';
        asst1.Field2__c='123465';
        asst1.Rack_Type__c='84" A-Frame Rack';
        asst1.Message_Types__c=msglst[1].Id;
        asst1.Track_Full_History__c=false;
        //asst1.Start_Time__c = system.now();
        //asst1.Message_Count__c = 1;
        //asst1.Current_Location_Name__c = 'test';
        asst1.alt__c=285.062;
        asst1.signal__c=-72.02;
        asst1.estBattPct__c=40.02;
       asst1.Humidity__c=39.00;
        asst1.Battery_Voltage__c=40;
        asst1.rsrp__c=-79.01;
        asst1.rsrq__c=10.01;
        asst1.rssi__c=-72.02;
        asst1.eventName__c='Start1';
        asst1.Temperature__c= 30.01;
        asst1.src__c='g';
        asst1.Battery_Replaced_Date__c=date.parse('12/27/2022');
        asst1.Power_Reset_Time__c=date.parse('12/25/2022');
        asst1.Is_NimbeLink_Asset__c = true;
        asst1.Power_Reset_Occurred__c = true;
       // insert asst1;
		astlist.add(asst);
        astlist.add(asst1);
        Test.startTest();
        insert astlist;
        list<Asset_History_Field__mdt>mdtlst = new list<Asset_History_Field__mdt>();
        
        List< Asset_History_custom__c>ashislst = new list< Asset_History_custom__c>();
        Asset_History_custom__c assetHsitory=new Asset_History_custom__c();
        assetHsitory.Asset__c= astlist[0].id;
        assetHsitory.Current_Location_Address__c =acclist[0].id;
        
        assetHsitory.Changed_Field__c='Location';
        assetHsitory.Location__c='In Network';
        assetHsitory.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitory.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitory.Start_Time__c=system.now()-2;
        assetHsitory.End_Time__c=system.now();
        assetHsitory.Battery_Current__c=0.2165489653;
		assetHsitory.Message_Count__c = 0;        
        
        assetHsitory.Still_in_this_Location__c=true;
       
		//insert assetHsitory;
        
        Asset_History_custom__c assetHsitorym=new Asset_History_custom__c();
        assetHsitorym.Asset__c=astlist[0].id;
        assetHsitorym.Changed_Field__c='Message Description';
        assetHsitorym.Location__c='In Network';
        assetHsitorym.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitorym.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitorym.Start_Time__c=system.now()-2;
        assetHsitorym.End_Time__c=system.now();
        assetHsitorym.Battery_Current__c=0.2165489653;
        assetHsitorym.Current_Message_Type__c=true;
        assetHsitorym.New_Value__c=String.valueOf(asst.Message_Types__c);
        assetHsitorym.Message_Count__c = 0;   
		//insert assetHsitorym;
        
        Asset_History_custom__c assetHsitory1=new Asset_History_custom__c();
        assetHsitory1.Asset__c=astlist[1].id;
        assetHsitory1.Changed_Field__c='Location';
        assetHsitory1.Location__c='In Network';
        assetHsitory1.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitory1.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitory1.Start_Time__c=system.now()-2;
        assetHsitory1.End_Time__c=system.now();
        assetHsitory1.Battery_Current__c=0.2165489653;
        assetHsitory1.Still_in_this_Location__c=true;
        
		//insert assetHsitory1;
        
        Asset_History_custom__c assetHsitorym1=new Asset_History_custom__c();
        assetHsitorym1.Asset__c=astlist[1].id;
        assetHsitorym1.Changed_Field__c='Message Description';
        assetHsitorym1.Location__c=asst.Current_Location_Name__c;
          assetHsitorym1.Current_Location_Address__c = astlist[0].id;
        assetHsitorym1.Latitude__c=asst.Current_Location__r.shippinglatitude;
        assetHsitorym1.Longitude__c=asst.Current_Location__r.shippinglongitude;
        assetHsitorym1.Start_Time__c=system.now()-2;
        assetHsitorym1.End_Time__c=asst.Last_Connected__c;
        assetHsitorym1.Battery_Current__c=0.2165489653;
        assetHsitorym1.Current_Message_Type__c=true;
        assetHsitorym1.New_Value__c=String.valueOf(asst.Message_Types__c);
		//insert assetHsitorym1;
        ashislst.add(assetHsitory);
         ashislst.add(assetHsitorym);
         ashislst.add(assetHsitory1);
         ashislst.add(assetHsitorym1);
      
        insert ashislst;
        list<Asset>asts = new list<asset>();
        asst.Field2__c = '123';
        asst.Temporary_Latitude__c=40.1824;
        asst.Temporary_Longitude__c=-90.058478;
        asst.Last_Connected__c=system.now()-1;
        asst.Message_Types__c = msglst[1].id;
        asst.Track_Full_History__c=false;
        asst.Start_Time__c = system.now();
        asst.Message_Count__c = 1;
        asst.alt__c=285.062;
        asst.signal__c=-72.02;
        asst.estBattPct__c=40.02;
        asst.Humidity__c=39.00;
        asst.Battery_Voltage__c=40;
        asst.rsrp__c=-79.01;
        asst.rsrq__c=10.01;
        asst.rssi__c=-72.02;
        asst.eventName__c='Start1';
        asst.Temperature__c= 30.01;
        asst.src__c='g';
       // update asst;
      
        
       list<asset> newasset=new list<asset>();
      //  asst1.Current_Location_Address__c=acc4.id;
        asst1.Field2__c = '123';
        asst1.Temporary_Latitude__c=40.1824;
        asst1.Temporary_Longitude__c=-90.058478;
        asst1.Message_Types__c = msglst[1].id;
        asst1.Current_Location__c=Acc.Id;
        asst1.Last_Connected__c=system.now()-1;
        asst1.Track_Full_History__c=false;
       // asst1.Start_Time__c = system.now();
        asst1.Message_Count__c = 1;
        asst1.Date_Shipped__c=system.today();
        asst1.alt__c=285.062;
        asst1.signal__c=-72.02;
        asst1.estBattPct__c=40.02;
       asst1.Humidity__c=39.00;
        asst1.Battery_Voltage__c=40;
        asst1.rsrp__c=-79.01;
        asst1.rsrq__c=10.01;
        asst1.rssi__c=-72.02;
        asst1.eventName__c='Start1';
        asst1.Temperature__c= 30.01;
        //asst1.Consider_for_Dwell__c=true;
        asst1.src__c='g';
        //asst1.Current_Location_Name__c
        //update asst1;
       // newasset.add(asst1);
        asts.add(asst);
        asts.add(asst1);
       
      // asset ast= [select id from asset where id='02iEk0000000UPVIA2'];
            
        Trigger_Helper.createandUpdateInventoryNimbelink();
        Trigger_Helper.createAssetForInsert(asst1,'both');
        Trigger_Helper.createHistoryrec(asts, null, true);
        Trigger_Helper.createandUpdateInventory();
       Trigger_Helper.createandUpdateInventoryNimbelink();
       // Trigger_Helper.Updateasset(asst1.Id);
        update asts;
        
       Test.stopTest();
        
       
    
    }
}