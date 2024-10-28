@istest
public class DeleteApiResponseBatch_test {
    public static testmethod void deleteapi(){
        List<Api_Response__c> apiList=new List<Api_Response__c>();
        Api_Response__c api=new Api_Response__c();
        api.Accel__c='test';
        apiList.add(api);
        insert apiList;
        test.startTest();
        DeleteApiResponseBatch deleteapi=new DeleteApiResponseBatch();
        database.executeBatch(deleteapi);
        test.stopTest();
    }
}