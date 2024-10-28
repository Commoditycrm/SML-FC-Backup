trigger RedesignAC_AssetConfigTriggerHandler on Asset_Configuration__c (before insert) {    
    
    Id AccRecTypeId = Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
    Id AstRecTypeId = Schema.SObjectType.Asset_Configuration__c.getRecordTypeInfosByDeveloperName().get('Asset').getRecordTypeId();
    
    Map<ID, Asset_Configuration__c> accIdAssetConfigMap = new Map<ID, Asset_Configuration__c>();
    Map<ID, Asset_Configuration__c> assetIdAssetConfigMap = new Map<ID, Asset_Configuration__c>();
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            for(Asset_Configuration__c astconfig : Trigger.new) {
                if(astconfig.RecordTypeId == AccRecTypeId) {
                    accIdAssetConfigMap.put(astconfig.Account__c, astconfig);
                }
                else if(astconfig.RecordTypeId == AstRecTypeId) {
                    assetIdAssetConfigMap.put(astconfig.Asset__c, astconfig);
                }
            }
        }
    }
    
    if(accIdAssetConfigMap.size() > 0) {
        List<Asset_Configuration__c> existAccRecords = [
            SELECT Id, Asset__c, Account__c  FROM Asset_Configuration__c WHERE Account__c in :accIdAssetConfigMap.keySet() AND RecordTypeId = :AccRecTypeId];
        Map<Id, Id> accAstConfigMap = new Map<Id, Id>();
        for(Asset_Configuration__c ac : existAccRecords) {
            accAstConfigMap.put(ac.Account__c, ac.Id);
        }
        if(accAstConfigMap.size() > 0) {
            for(Id accID : accIdAssetConfigMap.keySet()) {
                Asset_Configuration__c ac = accIdAssetConfigMap.get(accID);
                if(accAstConfigMap.containsKey(accID))
                    ac.addError('An Asset Configuration already exists for this account');
            }
        }
    }
    if(assetIdAssetConfigMap.size() > 0) {
        List<Asset_Configuration__c> existAccRecords = [
            SELECT Id, Asset__c, Account__c  FROM Asset_Configuration__c WHERE Asset__c in :assetIdAssetConfigMap.keySet() AND RecordTypeId = :AstRecTypeId];
        Map<Id, Id> astAstConfigMap = new Map<Id, Id>();
        for(Asset_Configuration__c ac : existAccRecords) {
            astAstConfigMap.put(ac.Asset__c, ac.Id);
        }
        if(astAstConfigMap.size() > 0) {
            for(Id astID : assetIdAssetConfigMap.keySet()) {
                Asset_Configuration__c ac = assetIdAssetConfigMap.get(astID);
                if(astAstConfigMap.containsKey(astID))
                    ac.addError('An Asset Configuration already exists for this asset');
            }
        }
    }    
    
}