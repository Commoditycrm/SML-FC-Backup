//To update InventoryAccuracy AccountId Field 
global with sharing class updateinvaccuniqueid_batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
global Database.QueryLocator start(Database.BatchableContext bc) {
        String Query = 'select id,Account__c,Unique_ID__c from Inventory_Accuracy__c where Unique_ID__c = null and Account__c != null order by createddate desc limit 99';
        return Database.getQueryLocator(Query);     
        }
     global void execute(Database.BatchableContext bc, List<Inventory_Accuracy__c> invaccuracylist){
         List<String> accnamelist = new List<String>();
         Map<String,String> MaccnameId = new Map<String,String>();
         List<Inventory_Accuracy__c> upinvacclist = new List<Inventory_Accuracy__c>();
         
         for(Inventory_Accuracy__c invrec: invaccuracylist)
             accnamelist.add(invrec.Account__c);
         
         List<Account> acclist = [Select Id,Name,Account_Id__C from Account where Name in :accnamelist];
         for(Account accrec: acclist)
             MaccnameId.put(accrec.Name,accrec.Account_Id__C);
         
          for(Inventory_Accuracy__c invrec: invaccuracylist)
          {
              if(MaccnameId.get(invrec.Account__c) != null)
              {
                  invrec.Unique_ID__c = MaccnameId.get(invrec.Account__c);
                  upinvacclist.add(invrec);
          }//For
         
         update upinvacclist;
      }
    }//Execute Method
    global void finish(Database.BatchableContext bc){
    }  
}