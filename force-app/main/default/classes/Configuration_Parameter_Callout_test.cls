@istest
public class Configuration_Parameter_Callout_test {
    public static testmethod void configuration(){
        account acc=new account();
        acc.name='test';
        insert acc;
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.Id;
        ast.Measurement_Period_desired__c='1900';
        ast.Trackmode__c='3';
        ast.Accel_Enabled__c='true';
        ast.ConnectMovementStart__c='true';
        ast.ConnectMovementEnd__c='true';
        ast.LocationPeriod__c='7200';
        ast.Locations_per_Check_Ins__c='12';
        ast.Loc_Enabled__c='true';
        ast.Sampling_Period__c='86400';
        ast.Use_GPS__c='true';
        ast.Use_Cell__c='true';
        ast.Use_WiFi__c='true';
        ast.Check_in_period__c='86400';
        ast.Temperature_Check_in_Period__c='300';
        ast.Temp_Enabled__c='true';
        insert ast;
        test.startTest();
        Configuration_Parameter_Callout.getParameter(ast.Id);
        test.stopTest();
        
    }
}