global class RedesignNlErrorMailSchedulerClass implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DateTime lastHourDateTime = DateTime.now().addHours(-1);
        
        // Fetch count of Api_Response__c records created in the last hour
        List<AggregateResult> arList = [SELECT COUNT(Id) total FROM Api_Response__c WHERE CreatedDate > :lastHourDateTime];
        
        // Check if the count of records is greater than 0
        Integer totalCount = (Integer)arList[0].get('total');
        if (totalCount > 0) {
            
        } else {
            sendEmailToCCRM('No new API responses received in the last hour');
        }
        List<AggregateResult> ahcList = [SELECT COUNT(Id) total FROM Asset_History_custom__c WHERE CreatedDate > :lastHourDateTime];
         Integer totalAhcCount = (Integer)ahcList[0].get('total');
        if (totalAhcCount > 0) {

        } else {
            sendEmailToCCRM('No new AHC Created in the last hour');
        }
    }

    public static void sendEmailToCCRM(String message) {
        String email = System.label.Email_address;
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[] { email, 'kacey@smartlogisticsinc.com'});
        String subject = message == 'No new AHC Created in the last hour' ? 'Issue with AHC' :'Issue with API Response';
        msg.setSubject(subject);

        String body = 'User/Org details: ' + UserInfo.getUserId() + '/' + UserInfo.getOrganizationId() + '\n\n' 
                    + Datetime.now() + '\n\n'
                    + 'Message: ' + message + '\n\n';
        msg.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }
}