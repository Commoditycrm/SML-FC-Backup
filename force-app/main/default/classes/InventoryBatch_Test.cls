@isTest
public class InventoryBatch_Test {
    static testmethod  void testmethod1(){
        List<Asset>astlist = new list<Asset>();
     
          Account acc = new account();
          acc.name ='Cardinal Glass Spring Green';
          insert acc;
       
            Asset ast = new Asset(name = 'Test');
            ast.AccountId = acc.id;
           // ast.Current_Location__c = acc.id;
            ast.State_of_Pallet__c ='In Transit';
            ast.Rack_Type__c ='26 Slot Bungee Rack';
            
           
        Asset ast1 = new Asset(name ='Test');
        ast1.AccountId = acc.id;
        ast1.Current_Location__c = acc.id;
        ast1.State_of_Pallet__c ='In Network';
        ast1.Rack_Type__c ='52 Slot Bungee Rack';
        astlist.add(ast);
        astlist.add(ast1);
        
         insert astlist;
     
       List<Inventory__c>Inlist = new list<Inventory__c>();
        
        Inventory__c Inv = new Inventory__c();
        Inv.Location_Account__c = acc.id;
        Inv.Is_In_Transit__c =False;
        Inv.Parent_Account__c =acc.id;
        Inv.Rack_Type__c ='52 Slot Bungee Rack';
        Inv.Asset_Count__c =0;
        
        Inventory__c Inv1 = new Inventory__c();
        Inv1.Is_In_Transit__c =True;
        Inv1.Parent_Account__c =acc.id;
        Inv1.Rack_Type__c ='52 Slot Bungee Rack';
        Inv1.Asset_Count__c =0;
        
        Inlist.add(Inv);
        Inlist.add(Inv1);
        
        upsert Inlist;
       
      
     Test.startTest();
      InventoryBatch x = new InventoryBatch();
      database.executeBatch(x);
      Test.stopTest();

    

      
          
         
       
            
    }
}