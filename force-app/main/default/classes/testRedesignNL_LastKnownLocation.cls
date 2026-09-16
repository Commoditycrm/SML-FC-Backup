@isTest
public class testRedesignNL_LastKnownLocation {
 @testSetup 
    static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'lab';
        insert acc1;
        Related_Customer__c rc = new Related_Customer__c();
        rc.Source_Account__c = acc.Id;
        rc.Related_To__c = acc1.Id;
        insert rc;
        Asset ast = new Asset();
        ast.Name = 'at5-t16ee4491f50';
        ast.Device_Id__c = 'at5-t16ee4491f50';
        ast.AccountId = acc.Id;
        ast.Last_Known_Location__c = acc.Id;
        ast.Current_Location__c = acc.Id;
        ast.Current_Address__c = 'test';
        ast.Capture_Movement_Event__c = true;
        ast.Movement__c=  Datetime.now().addDays(-16);
        ast.Movement_End__c =Datetime.now().addHours(-5);
        insert ast;
        Asset ast1 = new Asset();
        ast1.Name = 'at5-t16e244491f50';
        ast1.Device_Id__c = 'at5-t16ee44491f50';
        ast1.AccountId = acc.Id;
        ast1.Last_Connected__c=Datetime.now().addDays(-46);
        ast1.Last_Known_Location__c = acc.Id;
        ast1.Current_Location__c = acc.Id;
        ast1.Current_Address__c = 'test';
        ast1.Capture_Movement_Event__c = true;
        ast1.Movement__c=  Datetime.now().addDays(-16);
        ast1.Movement_End__c =Datetime.now().addHours(-5);
        insert ast1;
        
        Id assetHistroyRecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByName().get('Location').getRecordTypeId(); 
        Asset_History_Custom__c ahc = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-15),
            End_time__c = system.now(),
            still_in_this_location__c = true,
            Last_Known_Location__c = acc1.Name,
            RecordTypeId = assetHistroyRecordTypeId
        );
        insert ahc;
        Asset_History_Custom__c ahc1 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-15),
            End_time__c = system.now(),
            still_in_this_location__c = false,
            Last_Known_Location__c = acc1.Name,
            RecordTypeId = assetHistroyRecordTypeId
        );
        insert ahc1;
        Asset_History_Custom__c ahc2 = new Asset_History_Custom__c(
            Asset__c = ast.Id,
            Start_Time__c = Datetime.now().addDays(-45),
            End_time__c = system.now(),
            still_in_this_location__c = true,
            Last_Known_Location__c = acc1.Name,
            RecordTypeId = assetHistroyRecordTypeId
        );
        insert ahc2;
    }
    @isTest
    static void method(){
        Test.startTest();
        database.executeBatch(new RedesignNL_LastKnownLocation(10),100);
        database.executeBatch(new RedesignNL_LastKnownLocation(true,48),100);
        Test.stopTest();
    }
}