public class Configuration_Ctrl_For_Deactivation {
    
    @InvocableMethod
    //  @auraenabled
    public static List<result> Fordeactivation(list<string> deviceIDs){
        list<string> deviceIdslist = new list<string>();
        for(string st : deviceIDs){
            st = st.remove(' ');
            deviceIdslist = st.split(';');
        }
        system.debug('called'+ deviceIdslist);    
        string retunMesage = Utilityclass.calloutActivateDeactivate(deviceIdslist,'deactivate'); 
        result res = New result();
        list<result> returnList = New List<result>();
        res.returnMessage = retunMesage;
        returnList.add(res);
      //  sendEmailToCCRM(retunMesage);
        return returnList;
    }
    public class result{
        @InvocableVariable(label='returnMessage' description='returnMessage' required=true)
        public string returnMessage;
    }
    
  /*  public static void sendEmailToCCRM(String message) {
        String email = System.label.Email_address;
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[] { email,'murali@agilenautics.com','kacey@smartlogisticsinc.com'});
        String subject = 'Issue with Asset Deactivation';
        msg.setSubject(subject);
        
        String body = 'User/Org details: ' + UserInfo.getUserId() + '/' + UserInfo.getOrganizationId() + '\n\n' 
            + Datetime.now() + '\n\n'
            + 'Message: ' + message + '\n\n';
        msg.setPlainTextBody(body);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    } */
}