//created by: prithivi
//purpose : for Asset Activation & Deactivation flow
public with sharing class AssetController {
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetsByAccount(Id accountId) {
        return [SELECT Id, Name, SerialNumber FROM Asset WHERE AccountId = :accountId];
    }
}