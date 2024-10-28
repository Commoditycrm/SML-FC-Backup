global class RedesignNL_AccountCheck implements Database.Batchable<sObject>, Database.Stateful {
    Map<String,Map<String,List<String>>> upstreamMap = new Map<String,Map<String,List<String>>>();
    Set<ID> count = new Set<ID>();
    List<Account>  allAccounts;
    Set<Account> filteredAccList;
    Map<String,Account> FirstCreatedACC;
    boolean filter;
    global  RedesignNL_AccountCheck(){
        this.upstreamMap = new Map<String,Map<String,List<String>>>();
        this.count = new Set<ID>();
        this.allAccounts= new List<Account>();
        this.filter= false;
        this.filteredAccList = new Set<Account>();
        this.FirstCreatedACC= new Map<String,Account>();
        
    }
    global  RedesignNL_AccountCheck(boolean filter){
        this.upstreamMap = new Map<String,Map<String,List<String>>>();
        this.count = new Set<ID>();
        this.allAccounts= new List<Account>();
        this.FirstCreatedACC= new Map<String,Account>();
        this.filter = filter;
        this.filteredAccList = new Set<Account>();
    }
    global Database.Querylocator start(Database.BatchableContext bc) {
        String query = 'select id,Name from Account where ID in (select Source_Account__c from Related_Customer__c ) order by Name , createddate asc,Portal_Account__c ';
        return Database.getQuerylocator(query);
    }
    global void execute(Database.BatchableContext bc, List<account> accList) {
        Map<string,List<Account>> accMap= new Map<string,List<Account>>();
        String AccountName= accList[0].Name;
        Set<id> checkID = new Set<id>();
        Set<id> accids = new Set<id>();
        for(Account acc:accList){
            if(acc.Id != null){
                accids.add(acc.ID);
                for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: acc.Id order by CreatedDate asc]){
                    accids.add(rc.Related_To__c);
                }
            }
        }
        //you have to order by name too
        //
        List<Account> AccountList = [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c,isdeleted, CreatedDate, Account_Unique1_ID__c,Account_ID__c   FROM Account where id IN : accids order by Name asc, createddate asc ];
        for(Account acc:AccountList){            
            List<Account> acList;
            acList = accMap.containsKey(acc.Name) ? accMap.get(acc.Name) : new List<Account>();
            acList.add(acc);
            accMap.put(acc.Name,acList);
        }
        //for loop on accMap 
        if(filter == false || filter == null){
            for(String acName : accMap.keySet()) {
                List<Account> accl = accMap.get(acName);
                if(accl.size() >1)
                    allAccounts.addAll(accl);
                //generate a csv 
                //with headers - account id, account name, shipping latitude, shipping longitude, address, geofence, createddate
                //rows will be the duplicate accounts list sorted by name, createddate
            }
        }
        else{
            for(Account acc:AccountList){
                
                List<Account> acList = accMap.get(acc.Name);
                for(Account ac:acList){
                    if(ac.Id != acc.Id){
                        
                        Location ac1 = Location.newInstance(ac.shippinglatitude, ac.shippinglongitude); //response
                        Location ac2 = Location.newInstance(acc.shippinglatitude,acc.shippinglongitude); //
                        Double result = Location.getDistance(ac1, ac2, 'mi');  
                        if(result < 2 && result > 0.0){
                            filteredAccList.add(acc);
                            filteredAccList.add(ac);
                            Account acc1;
                            if(acc.CreatedDate > ac.CreatedDate){
                                acc1 = ac;
                            }else{
                                acc1= acc;
                            }
                            
                            if(FirstCreatedACC.containskey(acc.Name)){
                                acc1 = acc1.CreatedDate < FirstCreatedACC.get(acc.Name).createdDate ? acc1 :  FirstCreatedACC.get(acc.Name);
                            }
                            FirstCreatedACC.put(acc.name,acc1);
                            
                        }
                    }    
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        if(allAccounts.size()>1){
            RedesignNL_CSVEmailSender.sendCSVAsEmail(allAccounts);
        }
        else if(filteredAccList.size()>1){
            allAccounts.addALL(filteredAccList);
            RedesignNL_CSVEmailSender.sendCSVAsEmail(allAccounts);
        }
        
        if(FirstCreatedACC.KeySet().size() > 0){
            List<Account> acc= New List<Account>(FirstCreatedACC.values());
            RedesignNL_CSVEmailSender.sendCSVAsEmail(acc);
        }
        /*  messaging.SingleEmailMessage msg = new messaging.SingleEmailMessage();
msg.toAddresses = new String[] { System.Label.Email_Address };
msg.setSubject('Nearby Account Records');
string body = 'Overall Mismatch : '+ count.size() + '\n' + '\n';
for(String accName : upstreamMap.keySet()){
body +=' Parent Account : '+ accName +'\n' + '\n';
Map<String,List<String>> mailMap = upstreamMap.get(accName);
for(String astName : mailMap.keySet()){
body += astName + ' : ' + '\n' + String.join(mailMap.get(astName), ' , ') + '\n';
}
}

msg.setPlainTextBody(body);
Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
system.debug('Email sent--');
*/
    }
}