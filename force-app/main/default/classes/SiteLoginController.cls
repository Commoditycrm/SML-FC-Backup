/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    
    @AuraEnabled
    public static String login(String username, String password) {
        String startUrl = '/';
        try {
        Tableau_User__mdt siteUser = [SELECT Id, Email__c FROM Tableau_User__mdt Where Email__c = :username];
        if (siteUser != null ) {
			return 'TABLEAU_REDIRECT::https://tableau-dashboard-nine.vercel.app/?user='
    				+ siteUser.Email__c;
        }else{
            PageReference ref = Site.login(username, password, startUrl);
            return ref != null ? ref.getUrl() : '/';
        }
        } catch (Exception e) {
            throw new AuraHandledException('Login failed: ' + e.getMessage());
        }
    }

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    
   	global SiteLoginController () {}
}