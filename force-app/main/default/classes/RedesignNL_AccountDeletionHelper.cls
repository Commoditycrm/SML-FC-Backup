public class RedesignNL_AccountDeletionHelper {
@InvocableMethod
    Public Static List<String> getDeleteAcc(List<Account> accList){
        String Cannot_delete_Account_owning_Assets = system.label.Cannot_delete_Account_owning_Assets;
        String Cannot_delete_parent_Account = system.label.Cannot_delete_parent_Account;
        String accId = accList[0].Id;
        List<String> result = new List<String>();
        List<Related_Customer__c> recParentList= [Select id from Related_Customer__c where Source_Account__c =:accId];
        if(recParentList.size()>0){
            result.add(Cannot_delete_parent_Account);
            return result;
        }
        else{
            List<Asset> astList = [Select Id from Asset where AccountId=: accId];
            if(astList.Size()== 0 || astList.IsEmpty()){
                result.add('True');
                return result;
            }else{
                result.add(Cannot_delete_Account_owning_Assets);
                return result;
            }
        }
    }
}