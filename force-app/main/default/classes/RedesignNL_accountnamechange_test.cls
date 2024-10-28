@istest
public class RedesignNL_accountnamechange_test {
 static testmethod void accountnamechange(){
        account acc=new account();
        acc.name='Target Corporation, Inc.';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at5-t16ee4491f50';
        ast.AccountId=acc.Id;
        ast.Last_Known_Location__c=acc.Id;
        ast.Current_Location__c=acc.Id;
        ast.Current_Address__c='test';
        ast.Capture_Movement_Event__c=true;
        ast.Battery_Voltage__c=73;
        ast.alt__c=78787878;
        ast.signal__c=14141414;
        ast.rsrp__c=-77.00;
        ast.rsrq__c=-76.00;
        ast.rssi__c=-79.00;
        insert ast;
        
        Asset_History_custom__c ah= new Asset_History_custom__c();
        ah.Location__c = 'Test';
        ah.asset__c = ast.Id;
        ah.currentLocationId__c = acc.id;
        insert ah;
        test.starttest();
        RedesignNL_accountnamechange  batch = New RedesignNL_accountnamechange ();
        Database.executeBatch(batch, 40);
        test.stoptest();
    }
}