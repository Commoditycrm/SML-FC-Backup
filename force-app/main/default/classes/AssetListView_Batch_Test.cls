@istest
public class AssetListView_Batch_Test {
    static testmethod void nimbeLink_CTRL6(){
         List<ListView> lc=[select Id, Name, DeveloperName from ListView where sobjecttype='asset' limit 1];
        
        AssetListView_Batch  updatebatch = new AssetListView_Batch();
        DataBase.executeBatch(updatebatch);
       //  List<ListView> assetlist = [select Id, Name, DeveloperName from ListView where sobjecttype='asset' limit 1];
       // system.assertEquals(1, assetlist.size()); 
    }
}