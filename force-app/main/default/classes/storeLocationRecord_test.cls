@IsTest
public class storeLocationRecord_test {
    static testmethod void storeLocationmethod(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();        
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
      
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=date.parse('01/11/2022');
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lrlist.add(lr);
        insert lrlist;
        
          asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today()+2;
        system.debug('start and end'+ah.Start_Time__c+'   '+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        insert ah;
        list<Id> lstAsset = new list<Id>();
        asset ast1=new asset();
        ast1.Name='test';
        ast1.AccountId=acc.id; 
        insert ast1;
        lstAsset.add(ast1.Id); 
        test.startTest();
       storeLocationRecord  updatebatch = new storeLocationRecord(lstAsset,'Others');
        DataBase.executeBatch(updatebatch);
        //system.assertEquals(0, historyRecords.size());
        test.stopTest();
        
    }
    static testmethod void storeLocationmethod2(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

       
       
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id; 
      
        insert ast;
        list<id> lstAsset = new list<id>();
        lstAsset.add(ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today();
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Unable To Lock Row';
        lr.Location_Captured_Time__c=date.parse('01/22/2023');
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
       
        test.startTest();
        storeLocationRecord  updatebatch = new storeLocationRecord(lstAsset,'Others');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        lr.Reason__c='Out of Order TS';
        update lr;
        DataBase.executeBatch(new storeLocationRecord(lstAsset,'Others'));
        //Cover storeLocationRecordProd
        lr.Location_Captured_Time__c = system.today().addDays(1);
        update lr; 
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        update ah; 
        DataBase.executeBatch(new storeLocationRecordProd());
        //updatebatch.errors = new Exception[0];
        updatebatch.finish(null);
        //Cover reason = 
        test.stopTest();
        
    }
    static testmethod void storeLocationmethod3(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        List<id> lstAsset = new List<id>();
        lstAsset.add(ast.id);
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(lstAsset,'other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationmethod4(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
         List<id> lstAsset = new List<id>();
        lstAsset.add(ast.id);
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Unable To Lock Row';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
       storeLocationRecord  updatebatch = new storeLocationRecord(lstAsset,'other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(lstAsset,'other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationmethod5(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Power_Reset_Occurred__c = True;
        ast.Battery_Replaced_Date__c = null;
        insert ast;
         List<id> lstAsset = new List<id>();
        lstAsset.add(ast.id);
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='In Transit';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Unable To Lock Row';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsrp__c = null;
        lr.rsrq__c = 1.2;
        lr.rsri__c = null;
        lr.voltage__c = 123;
        lr.cellular_signal__c=23;
        lr.Accuracy__c=1;
        lr.src__c = '123';
        lr.Location__c='In Transit';
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        storeLocationRecord  updatebatch = new storeLocationRecord(lstAsset,'other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(lstAsset,'other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationmethod6(){
        //To cover Battery_Replaced_Date__c present
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Power_Reset_Occurred__c = True;
        ast.Battery_Replaced_Date__c = system.today();
        insert ast;
         List<id> lstAsset = new List<id>();
        lstAsset.add(ast.id);
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='In Transit';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Unable To Lock Row';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsrp__c = null;
        lr.rsrq__c = 1.2;
        lr.rsri__c = null;
        lr.voltage__c = 123;
        lr.cellular_signal__c=23;
        lr.Accuracy__c=1;
        lr.src__c = '123';
        lr.Location__c='In Transit';
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
       storeLocationRecord  updatebatch = new storeLocationRecord(lstAsset,'other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(lstAsset,'other'));
        system.assertEquals(1, lrlist.size());
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        test.stopTest();
    }
    static testmethod void storeLocationmethod7(){
        //To cover Battery_Replaced_Date__c present
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Power_Reset_Occurred__c = True;
        ast.Battery_Replaced_Date__c = system.today();
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='In Transit';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Unable To Lock Row';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsrp__c = null;
        lr.rsrq__c = 1.2;
        lr.rsri__c = null;
        lr.voltage__c = 123;
        lr.cellular_signal__c=23;
        lr.Accuracy__c=1;
        lr.src__c = '123';
        lr.Location__c='In Transit';
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
       system.debug(Utilityclass.currentLocName(ast.AccountId,lr.Latitude__c,lr.Longitude__c));
       storeLocationRecord  updatebatch = new storeLocationRecord(new List<Id>{ast.Id},'Other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        system.assertEquals(1, lrlist.size());
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        test.stopTest();
    }
    static testmethod void storeLocationmethod8(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
       storeLocationRecord  updatebatch = new storeLocationRecord(new List<Id>{ast.Id},'Other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationmethod9(){
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
                list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Power_Reset_Occurred__c = True;
        ast.Battery_Replaced_Date__c = null;
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='In Transit';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsrp__c = null;
        lr.rsrq__c = 1.2;
        lr.rsri__c = null;
        lr.voltage__c = 123;
        lr.cellular_signal__c=23;
        lr.Accuracy__c=1;
        lr.src__c = '123';
        lr.Location__c='In Transit';
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        storeLocationRecord  updatebatch = new storeLocationRecord(new List<Id>{ast.Id},'Other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationmethod10(){
        //To cover Battery_Replaced_Date__c present
         account acc=new account();
            acc.name='test';
            insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        ast.Power_Reset_Occurred__c = True;
        ast.Battery_Replaced_Date__c = system.today();
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='In Transit';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsrp__c = null;
        lr.rsrq__c = 1.2;
        lr.rsri__c = null;
        lr.voltage__c = 123;
        lr.cellular_signal__c=23;
        lr.Accuracy__c=1;
        lr.src__c = '123';
        lr.Location__c='In Transit';
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
       storeLocationRecord  updatebatch = new storeLocationRecord(new List<Id>{ast.Id},'Other');
        DataBase.executeBatch(updatebatch);
        system.assertEquals(1, lrlist.size());
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        system.assertEquals(1, lrlist.size());
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        test.stopTest();
    }
    static testmethod void storeLocationRecordProd1(){
        account acc=new account();
        acc.name='test';
        insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        
        
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        //Cover storeLocationRecordProd 
        Id ids = [SELECT Id,Asset__c FROM Location_Record_Ignored__c][0].Asset__c;
        System.debug('ids--'+ids);
        storeLocationRecordProd slrp = new storeLocationRecordProd();
        try{
            slrp.totalRecords = 0;
            slrp.execute(null,new List<Location_Record_Ignored__c>{new Location_Record_Ignored__c(Asset__c=ast.Id)});
            //slrp.execute(null,new List<Location_Record_Ignored__c>{new Location_Record_Ignored__c(Asset__c=ast.Id)});
        }
        catch(Exception ex){
            try{
                slrp.finish(null);
            }
            catch(Exception ex1){
                
            }
        }
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    static testmethod void storeLocationRecordProd2(){
        account acc=new account();
        acc.name='test';
        insert acc;
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        
        
        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        system.debug('ah.Start_Time__c--'+ah.Start_Time__c);
        system.debug('ah.End_Time__c--'+ah.End_Time__c);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        insert ashislist;
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        test.startTest();
        //Cover storeLocationRecordProd 
        DataBase.executeBatch(new storeLocationRecordProd());
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
    
    static testmethod void storeLocationmethod11(){
        account acc=new account();
        acc.name='Testing';
        insert acc;
        
        list<Location_Record_Ignored__c> lrlist=new list<Location_Record_Ignored__c>();    
        list<asset_history_custom__c> ashislist=new list<asset_history_custom__c>();        

        asset ast=new asset();
        ast.Name='test';
        ast.AccountId=acc.id;
        insert ast;
        
        system.debug('ast.Id--'+ast.Id);
        asset_history_custom__c ah=new asset_history_custom__c();
        ah.Asset__c=ast.Id;
        ah.Start_Time__c=system.today();
        ah.End_Time__c=system.today().addDays(2);
        ah.Latitude__c=44.37994355;
        ah.Longitude__c=-92.03575066;
        ah.Location__c='test';
        ah.Still_in_this_Location__c = true;
        ashislist.add(ah);
        
        asset_history_custom__c ah2 = ah.clone(false, true);
        ah.Latitude__c= 41.37994355;
        ah.Longitude__c=-91.03575066;
        insert ashislist;
        
        Location_Record_Ignored__c lr=new Location_Record_Ignored__c();
        lr.Asset__c=ast.Id;
        lr.Reason__c='Out of Order TS';
        lr.Location_Captured_Time__c=system.today().addDays(1);
        lr.Latitude__c=44.37994356;
        lr.Longitude__c=-92.03575063;
        lr.Altitude__c=777.000;
        lr.rsri__c=6.99;
        lr.rsrp__c=5.99;
        lrlist.add(lr);
        insert lrlist;
        
        test.startTest();
        //Cover storeLocationRecord
        DataBase.executeBatch(new storeLocationRecord(new List<Id>{ast.Id},'Other'));
        system.assertEquals(1, lrlist.size());
        test.stopTest();
    }
}