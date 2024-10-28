@istest
public class DeletionofAssetHistory_test {
        public static testmethod void deleteapi(){
            account acc=new account();
            acc.name='test';
            insert acc;
            asset ast=new asset();
            ast.name='tsest';
            ast.AccountId=acc.id;
            insert ast;
asset_history_custom__C ahhis=new asset_history_custom__C();
           // ahhis.Name='tset';
            ahhis.asset__c=ast.id;
            insert ahhis;
             test.startTest();
        DeletionofAssetHistory deleteapi=new DeletionofAssetHistory();
        database.executeBatch(deleteapi);
        test.stopTest();
            
        }
}