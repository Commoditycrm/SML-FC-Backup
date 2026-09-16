@isTest
public class Test_targetSummaryCTRL {
    @TestSetup
    static void testDataSetup(){
      // Account acc =new Account();
      /* Account acclist = new Account();
        accList.Name= 'Sample RDC';
        accList.Lane__c = 3735;
        insert accList;
        
        Account acc2 = new Account();
        acc2.Name= '3735 (Windsor)';
        acc2.Lane__c = 3735;
        insert acc2; 
		
        Asset ast = new Asset();
        ast.Name = '3712-asset';
        ast.Device_Id__c = '3712-asset';
        ast.Field2__c='3712';
        ast.AccountId = accList.Id;
        ast.Current_Location__c=accList.Id;
        insert ast;
        
        Asset ast2 = new Asset();
        ast2.Name = 'at5-s5-testing'; 
        ast2.Device_Id__c = 'at5-s5-testing';
        ast.Field2__c='3735';
        ast2.AccountId = acc2.Id;
        ast2.Current_Location__c=acc2.Id;
        insert ast2;
        
        Asset ast3 = new Asset();
        ast3.Name = 'at5-s6-testing'; 
        ast3.Device_Id__c = 'at5-s6-testing';
        ast.Field2__c='3735';
        ast3.AccountId = acclist.Id;
        ast3.Last_Known_Location__c = acclist.Id;
        ast3.Current_Location__c = acclist.Id;
        ast3.Current_Address__c = 'test';
        insert ast3;
        
        Asset ast4 = new Asset();
        ast4.Name = 'at5-s7-testing'; 
        ast4.Device_Id__c = 'at5-s7-testing';
        ast4.Current_Location__c= accList.Id;
        ast4.Field2__c='3735';
        ast4.AccountId =acclist.Id;
        //ast.Total_Dwell_Days_CL__c = 5;
        insert ast4;
        
        Asset ast5 = new Asset();
        ast5.Name = 'at5-s8-testing'; 
        ast5.Device_Id__c = 'at5-s8-testing';
        ast.Field2__c='3735';
        ast5.AccountId = acclist.Id;
        ast5.Last_Known_Location__c = acclist.Id;
        ast5.Current_Location__c= null;
        ast5.Current_Address__c = 'test';
        ast5.Capture_Movement_Event__c = true;
        //ast.Total_Dwell_Days_CL__c = 5;
        insert ast5;
        
        RecordType RecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];

        Asset_History_custom__c ahc1  = new Asset_History_custom__c ();
        ahc1.Asset__c = ast.id;
        ahc1.RecordTypeId = RecType.id;
        ahc1.Still_in_this_Location__c =true;
        insert ahc1;
        
        Asset_History_custom__c ahc2  = new Asset_History_custom__c ();
        ahc2.Asset__c = ast.id;
        ahc2.RecordTypeId = RecType.id;
        ahc2.Still_in_this_Location__c =true;
        ahc2.Consider_for_Dwell__c = true;
        insert ahc2;
        
        
        Asset_History_custom__c ahc3  = new Asset_History_custom__c ();
        ahc3.Asset__c = ast.id;
        ahc3.RecordTypeId = RecType.id;
        ahc3.Still_in_this_Location__c =true;
        //ahc3.Start_Time__c = 2020-06-02T15:19:05.000+0000;
        //ahc3.End_Time__c = 2020-06-02T15:19:05.000+0000;
        //insert ahc3;
        
        
        Asset_History_custom__c ahc5  = new Asset_History_custom__c ();
        ahc5.Asset__c = ast.id;
        ahc5.Location__c= '3735 (Windsor)';
        ahc5.RecordTypeId = RecType.id;
        ahc5.Still_in_this_Location__c =true;
        insert ahc5;
        
        
        Asset_History_custom__c ahc4  = new Asset_History_custom__c ();
        ahc4.Asset__c = ast4.id;
        ahc4.RecordTypeId = RecType.id;
        ahc4.Still_in_this_Location__c =true;
        insert ahc4;
        
         //TargetSummary_CTRL.updateCount();*/

        Account acc = new Account(Name = 'Test Account',
                                  lane__c = 2);
        insert acc;

        // Create some Asset records
        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < 5; i++) {
            Asset ast = new Asset(
                Name = 'Asset ' + i,
                Field2__c = String.valueOf(i),
                AccountId = acc.Id
                //Current_Location_Report__c = 'In Transit',
                //Total_Dwell_Days__c = i
                //CheckLane__c = false // Based on your filter condition
            );
            assets.add(ast);
        }
        insert assets;
        
        Target_Summary__c ts = new Target_Summary__c();
        insert ts;
        
        RecordType RecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_History_custom__c' AND DeveloperName = 'Location' LIMIT 1];

        // Create Asset History records matching the sweep lane filter
        List<Asset_History_custom__c> assetHistories = new List<Asset_History_custom__c>();
        for (Integer i = 0; i < 5; i++) {
            Asset_History_custom__c assetHistory = new Asset_History_custom__c(
                Asset__c = assets[i].Id,
                Still_in_this_Location__c = true,
                End_Time__c = DateTime.now().addDays(-5),
                Current_Location__c = acc.Id,
                Location__c = '3897 (Denton)',
                Consider_for_Dwell__c = true,
                RecordTypeId = RecType.Id,
                Last_Known_Location__c = acc.Id
            );
            assetHistories.add(assetHistory);
        }
        insert assetHistories;
        
       /* System.Label.Sweep_Lane_Exception = '';
        System.Label.Turn_Count = '';
        System.Label.Unknown_Location = '';
        System.Label.RDC = '';
        System.Label.Store_Location = '';*/
    }


	@isTest
    public static void testRestMethods() {
         Test.startTest();
        TargetSummery_CTRL targetCtrl = new TargetSummery_CTRL();
        String jobId = System.schedule('Test Job', '0 0 0 15 3 ?', targetCtrl); // scheduling the job
        Test.stopTest(); 
    }
}