trigger downstreamTrigger on Related_Customer__c (before insert,after delete) {
    if(trigger.isbefore){
        if(trigger.isinsert){
            
            system.debug('in downstream trigger');
            map<id,id> accountMap = new map<id,id>();
            map<id,string> relatedAccountMap = new map<id,string>();
            list<account> updateAccountList = new list<account>();
            for(Related_Customer__c rc : trigger.new){
                accountMap.put(rc.Related_To__c,rc.Source_Account__c);	    
            }
            for(account acc : [select id,name from account where id IN : accountMap.values()]){
                relatedAccountMap.put(acc.id,acc.name);    
            } 
            //  accountMap.keySet() contains downstream customers Id
            for(account acc : [select id,UpStream_Account__c,Source_Account__c from account where id IN : accountMap.keySet()]){
                 if(acc.Source_Account__c !=null){
                            acc.Source_Account__c = acc.Source_Account__c +','+accountMap.get(acc.id);
                        }
                else{
                    						acc.Source_Account__c = accountMap.get(acc.id);                        

                }
                if(acc.UpStream_Account__c != null){
                    if(accountMap.containskey(acc.id) && relatedAccountMap.containskey(accountMap.get(acc.id))){
                        acc.UpStream_Account__c = acc.UpStream_Account__c +','+relatedAccountMap.get(accountMap.get(acc.id));
                       
                    }
                }
                else{
                    if(accountMap.containskey(acc.id) && relatedAccountMap.containskey(accountMap.get(acc.id))){
                        acc.UpStream_Account__c = relatedAccountMap.get(accountMap.get(acc.id));
                    }
                    
                }   
                updateAccountList.add(acc);
            }
            if(updateAccountList != null && updateAccountList.size()>0)
                update updateAccountList;
        }
    }
    if(trigger.isafter){
        if(trigger.isdelete){
            list<account> updateAccountList = new list<account>();
            set<Id> lstId = new set<Id>();
            String str1, str2;
            for(Related_Customer__c rc : trigger.old){
                lstId.add(rc.Related_To__c);
                 str1 = rc.Source_Account__c;
            }
            for(account acc : [select id,Source_Account__c,UpStream_Account__c,name from account where id IN : lstId]){
                    if(acc.Source_Account__c!=null){
                        str2 = acc.Source_Account__c; 
                        acc.Source_Account__c = acc.Source_Account__c.remove(str1);
                    }
                system.debug('acc ups'+acc.UpStream_Account__c);
                updateAccountList.add(acc);
            }
            
            
            if(updateAccountList != null && updateAccountList.size()>0){
                update updateAccountList;
            }  
        }
    }
}