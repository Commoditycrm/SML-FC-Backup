public class RedesignAC_checkVendors {
    @InvocableMethod(label='Check Vendor')
    public static List<String> checkDevices(List<AcntDetailList> acntDetail){
        try{
                String accId = acntDetail[0].acntId;
                
                List<Asset_Configuration__c> astList = [SELECT Id, Asset__r.Name, Asset__r.Is_loco_Asset__c FROM Asset_Configuration__c  WHERE Asset__r.AccountId = :accId];
                Boolean Loco = False;
                Boolean Nl = False;
            	List<String> returnBoth = new List<String>{'Both'};
                List<String> returnLoco = new List<String>{'Loco'};
                List<String> returnNl = new List<String>{'NL'};
                
                if(astList.size() == 0) {
                    
                    return returnBoth;
                }else{
                    for(Asset_Configuration__c ast : astList){
                        if(ast.Asset__r.Is_loco_Asset__c)
                            Loco = true;
                        else
                            Nl = true;
                    }
                }
                return Loco == true && Nl == true ? returnBoth: Loco == true ? returnLoco : returnNl;
            
        }catch(Exception exp) {
            RedesignNL_CaptureErrors.createErrorLogs(exp,'RedesignAC_UpdateConfigFromFlow', 'checkDevices', 'Exception', null, null, true);
        }
        return null;
    }
    
    public class AcntDetailList{
        @InvocableVariable(required=true)
        public Id acntId;
    }
}