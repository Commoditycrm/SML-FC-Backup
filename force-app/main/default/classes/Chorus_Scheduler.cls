public with sharing class Chorus_Scheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
         if(UserInfo.getOrganizationId() == System.label.Production_Org_Id) {
            Database.executeBatch(new Chorus_Controller(), 200);
        }else{
            Database.executeBatch(new Chorus_AhcBatch(), 15);
        }
    }
}