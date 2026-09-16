/**
 * An apex page controller that exposes the site forgot password functionality
 */
public without sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
    
    @AuraEnabled
    public static boolean forgotPassword(String username){
        boolean result=false;
        try {
            List<user> usr = [select id from user where username=:username];
            if(usr!=null &&  usr.size()>0){
              result  = Site.forgotPassword(username);
            
            }else{
                result=false;
            }
            
        } catch (Exception e){
            result = false;
        }
        return result;
    }
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
}