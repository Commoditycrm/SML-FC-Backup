global class Redesign_nearAccountCheck implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, String> duplicateAccountsMap;
	Set<id> accidset;
    global Redesign_nearAccountCheck() {
        this.duplicateAccountsMap = new Map<String, String>();
        this.accidset = new Set<Id>();
    }

    global Database.Querylocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, ShippingLatitude, GeoFence_Radius_in_Miles__c, ShippingLongitude FROM Account WHERE Id IN (SELECT Source_Account__c FROM Related_Customer__c) ORDER BY Name, CreatedDate ASC, Portal_Account__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accLst) {
        Set<id> accids = new Set<id>();
        for(Account acc:accLst){
            if(acc.Id != null){
                accids.add(acc.ID);
                for(Related_Customer__c rc : [SELECT Id, Name, Source_Account__c, Related_To__c FROM Related_Customer__c where Source_Account__c =: acc.Id order by CreatedDate asc]){
                    accids.add(rc.Related_To__c);
                }
            }
        }
        List<Account> accList = [select id,name,shippinglatitude,GeoFence_Radius_in_Miles__c,parentid, shippinglongitude,Address__c,isdeleted, CreatedDate, Account_Unique1_ID__c,Account_ID__c   FROM Account where id IN : accids order by Name asc, createddate asc ];
		for (Integer i = 0; i < accList.size(); i++) {
            Account accountA = accList[i];
            String duplicates = '';

            for (Integer j = i+1; j < accList.size(); j++) {
                if (i != j) {
                    Account accountB = accList[j];

                    if (accountA.ShippingLatitude != null && accountA.ShippingLongitude != null &&
                        accountB.ShippingLatitude != null && accountB.ShippingLongitude != null) {

                        Location ac1 = Location.newInstance(accountA.ShippingLatitude, accountA.ShippingLongitude);
                        Location ac2 = Location.newInstance(accountB.ShippingLatitude, accountB.ShippingLongitude);
                        Double distance = Location.getDistance(ac1, ac2, 'mi');

                        if (distance <= accountA.GeoFence_Radius_in_Miles__c && distance > 0.0 && accountB.Name != accountA.Name) {
                            duplicates += accountB.Name + ' ' + accountB.Id + ' (' + distance + ' miles), \n';
                            accidset.add(accountA.Id);
                            accidset.add(accountB.Id);
                        }
                    }
                }
            }

            if (duplicates != '') {
                duplicates = duplicates.substring(0, duplicates.length() - 2); // Remove trailing comma and space
                duplicateAccountsMap.put(accountA.Name + ' ' + accountA.Id, duplicates);
            }
        }
    
}

    global void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[]{System.Label.Email_Address});
        msg.setSubject('Nearby Account Records');
        String body = formatDuplicateAccountsMap(duplicateAccountsMap,accidset);
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
        System.debug('Email sent--');
    }

    private static String formatDuplicateAccountsMap(Map<String, String> duplicateAccountsMap,Set<Id> accidset) {
        String formattedString = duplicateAccountsMap.keySet().size()  + ' Duplicate Accounts Report: Affected Accounts:'+ accidset.size() +' \n\n';
        for (String key : duplicateAccountsMap.keySet()) {
            formattedString += key + ' ->\n ' + duplicateAccountsMap.get(key) + '\n\n';
        }
        return formattedString;
    }
}