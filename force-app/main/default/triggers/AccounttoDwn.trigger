trigger AccounttoDwn on Account (after insert) {

if(Trigger.isInsert){

    List<Related_Customer__c> ct = new List <Related_Customer__c>();
Id profileId = UserInfo.getProfileId();
 Id UserId = UserInfo.getUserId();
String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
    String UserName =[select Id,Name,AccountId__c from User where Id =:UserId].AccountId__c;
    for(Account acc : trigger.new){
        if(profileName == 'Customer User'){
        Related_Customer__c c = new Related_Customer__c( );
       c.Source_Account__c=UserName;
         c.Related_To__c =acc.id;
        ct.add(c);
 
    }
    }
    insert ct; 
   
}

}