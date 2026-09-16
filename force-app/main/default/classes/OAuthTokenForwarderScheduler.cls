public class OAuthTokenForwarderScheduler implements Schedulable {

    public void execute(SchedulableContext context) {
        try {
            OAuthTokenForwarder.run('M2MD');
        } catch (Exception e) {
            System.debug('Error executing OAuthTokenForwarder: ' + e.getMessage());
        }
    }
}