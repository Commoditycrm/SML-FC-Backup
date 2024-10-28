/**
 * @author -- Gokulprasath
 * @date -- 02/20/2019
 * @description -- This Class provide test coverage to utility class.
 **/
@isTest
global class Utilityclass_Test {
	 global Static testmethod void utilityclass()
    {
           account acc = new account(name = 'test',GeoFence_Radius_in_Miles__c = 1);
        insert acc;
         Asset ast = new Asset();
        ast.Name='atp2bbef1c017f';
        ast.Device_Id__c='at-atp2bbef1c017f';
        ast.AccountId=acc.Id;
        insert ast;
        
       
         
         try
        {
           if(Test.isRunningTest())  //Condition to ensure test is running
           integer intTest =1/0;    //This will throw some exception, 
           //Since the Statement is in try block, It will cover both the cases. 
           // And clears complexity in test class.
        } catch(exception e)// exception handling
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, e.getMessage());
                ApexPages.addMessage(msg);
                //Utilityclass.sendemailtoadmin(e);
                Utilityclass.sendemailtoccrm(e, ast.Name, 'response');
            }
                 
        
        //   Utilityclass.generatetoken();
      
        Utilityclass.stopTrigger();
        Utilityclass.stoptrigger1();
        Utilityclass.canIRun();
        Utilityclass.toaddress();
        Utilityclass.canIEnter();
        Utilityclass.inventorycheck();
        Utilityclass.executeInventory();
        Utilityclass.currentLocName(acc.Id, 44.46143795, -92.15831856);
        Utilityclass.currentLocDetail(acc.Id, 44.46143795, -92.15831856);
        Utilityclass.currentLocId(acc.Id, 44.46143795, -92.15831856);
        List<String> devIdList = new List<String>();
        string tk = utilityclass.generatetoken();
        devIdList.add(ast.Name);
        Utilityclass.calloutActivateDeactivate(devIdList , 'deactivate');
        List<Account> accList =  new List<Account>();
        set<Id> accIdSet = new set<Id>();
        accList.add(acc);
        accIdSet.add(acc.Id);
        List<Nested_Geofence__mdt> mdtLst = new List<Nested_Geofence__mdt>();
        Utilityclass.currentLocDetail(accIdSet, 44.46143795, -92.15831856, accList, mdtLst);
       
        Utilityclass.caldistance(acc.id, 44.46143795, -92.15831856);
    }
   /* global class MockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
         System.assertEquals('https://api.iot.nimbelink.net/v1/auth', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"username": "bpxovqretvihgvli","password": "q-CH4tcqLXb59sSqSiSTX4AmQygrTch2TA22gCmTch94LtmInK-W7gnTRHp4Qf5n"}');
        res.setStatusCode(200);
        return res;

         
 
    }
}*/
  
}