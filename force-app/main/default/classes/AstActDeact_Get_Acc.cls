public class AstActDeact_Get_Acc {
    @InvocableMethod
    public static List<list<String>> GetAccount() {
        // Get all accounts that have related assets
        List<Account> accList = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Asset)];
        List<List<String>> accIdList  = new List<List<String>>();
        // Collect the Account IDs
        List<String> accIds = new List<String>();
        for (Account acc : accList) {
            accIds.add(acc.Id);
        }
        
       
        accIdList.add(accIds);
        
        // Return the list of Account IDs
        return accIdList;
    }
    /* public class result{
@InvocableVariable(label='returnMessage' description='returnMessage' required=true)
public List<string> AccountIds;
}*/
}