@isTest
public class updateinvaccuniqueid_batch_Test {
static testMethod void updatetestMethod() 
    {
        Account accrec= new Account(Name='Test');
        insert accrec;
        
        Inventory_Accuracy__c invrec = new Inventory_Accuracy__c(Account__c='Test');
        insert invrec;
        
        Test.startTest();

            updateinvaccuniqueid_batch obj = new updateinvaccuniqueid_batch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}