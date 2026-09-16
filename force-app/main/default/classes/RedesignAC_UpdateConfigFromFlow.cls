public class RedesignAC_UpdateConfigFromFlow {
    @InvocableMethod(label='Update Config From Flow')
    public static void updateConfigurationParameters(List<AcntDetailList> acntInfo){
        try {
            if (!acntInfo.isEmpty()) {
                Id accId = acntInfo[0].acntId;
                Boolean individualConfig = acntInfo[0].individualConfig != null ? acntInfo[0].individualConfig : true;
                Database.executeBatch(new RedesignAC_UpdateConfigBatch(accId, individualConfig), 2000);
            }
        } catch (Exception exp) {
            RedesignNL_CaptureErrors.createErrorLogs(exp,'RedesignAC_UpdateConfigFromFlow', 'updateConfigurationParameters','Exception', null, null, true);
        }
    }

    public class AcntDetailList {
        @InvocableVariable(required=true)
        public Id acntId;
        @InvocableVariable(required=true)
        public Boolean individualConfig;
    }
}