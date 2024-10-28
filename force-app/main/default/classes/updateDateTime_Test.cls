@istest
public class updateDateTime_Test {
    static testmethod void storeLocationmethod(){
        list<asset_history_custom__c> ahlist=new list<asset_history_custom__c>();
        account acc=new account();
        acc.name='test';
        insert acc;
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Current_address_date_time__c=system.today();
        insert ast;
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today()+2;
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Inserted_From__c='Location Record';
        ah.location__c='test';
        ah.Still_in_this_Location__c=false;
        ahlist.add(ah);
        insert ahlist;      
        test.startTest();
        updateDateTime.UpdateLRIRecordsEndTimeToAsset(ahlist);
        test.stopTest();
        
    }
}