@istest
public class testRedesignNL_UpdateAsset {
 @testSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Testing1';
        insert acc1;
        
        Asset ast = new Asset();
        ast.Name = 'atp2bbef1c017f'; 
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Account_to_Update__c = acc1.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Date_Shipped__c = system.now();
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Accuracy_meters__c =null ;
        ast.Temporary_Longitude__c= null;
     	ast.Power_Reset_Occurred__c = true;
     	ast.Power_Reset_Time__c = System.now();
     //   ast.tot = System.now().addhours(-1);
        ast.Temporary_Latitude__c= null;
        ast.State_of_Pallet__c = 'In Transit';
        insert ast;
        
       
        RecordType ahcLocationRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];  
        Asset_History_custom__c ahc = new Asset_History_custom__c(
            Start_Time__c = Datetime.now().addHours(-1),
            End_Time__C = Datetime.now().addHours(1),
            Asset__c = ast.Id,
            RecordTypeId = ahcLocationRecordType.Id,
            Still_in_this_Location__c = true,
            Current_Location_Address__c = 'test',
            location__c = 'In Transit',
            Accuracy_meters__c =12345 ,
            Longitude__c = -83.55054479 ,
            Latitude__c= 41.59104532 ,
            Consider_for_Dwell__c = true,
            rssi__c=null ,
            rsrp__c=null ,
            rsrq__c=null ,
            Cellular_Signal__c= null,
            Battery_Current__c=null ,
            Altitude__c=null ,
            PowerUptime__c=null ,
            power_Reset_Time__c = System.now().addhours(-1),
            Est_Remaining_Battery__c=null,
            Power_Reset_Occurred__c = true
        );
        insert ahc;
        
      
        AssetHistory  objHistory = new AssetHistory();
        objHistory.AssetId =ast.Id;
        objHistory.Field = 'Last_Connected__c'; 
        insert objHistory;     
    } 
     @isTest
    public static void testRedesignNL_CreateAssetHistoryBatch() {
        List<Asset> aset = [Select Id, Name from Asset];
        List<String>AssetID= new List<String>();
        for(Asset ast:aset){
            AssetID.add(ast.Name);
        }
        Database.ExecuteBatch(new RedesignNL_UpdateAsset(AssetID),1);
    }
}