global class TargetSummery_CTRL implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        List<Target_Summary__c> targetSummeryList = [Select Id from Target_Summary__c limit 5000];
        if(targetSummeryList.size()>0){
            Database.DeleteResult[] delResults = Database.delete(targetSummeryList, false);
        }
        //Sweep Lane Exception
        Map<String, Integer> sweepLaneCount = new Map<String, Integer>();
        String sweepLaneFilter = System.Label.Sweep_Lane_Exception ;
        System.debug('Custom Label Value: sweepLaneFilter == ' + sweepLaneFilter);
        string sweeplaneQuery = 'SELECT Asset__r.Field2__c fieldAlias, COUNT(Id) cnt  FROM Asset_History_custom__c WHERE '+ sweepLaneFilter + ' GROUP BY Asset__r.Field2__c';
        List<AggregateResult> sweepLaneCountresult = Database.query(sweeplaneQuery);
        
        for (AggregateResult result : sweepLaneCountresult) {
            String fieldValue = (String) result.get('fieldAlias');
            Integer countValue = (Integer) result.get('cnt');
            sweepLaneCount.put(fieldValue, countValue); 
        }
        
        //Trun Count
        Map<String, Integer> turnCount = new Map<String, Integer>();
        String turnCountFilter = System.Label.Turn_Count  ;
        System.debug('Custom Label Value: turnCountFilter== ' + turnCountFilter);
        string turnCountQuery = 'SELECT Asset__r.Field2__c fieldAlias, COUNT(Id) cnt FROM Asset_History_custom__c WHERE '+ turnCountFilter +' GROUP BY Asset__r.Field2__c';
        List<AggregateResult> turnCountresult = Database.query(turnCountQuery);
        
        for (AggregateResult result : turnCountresult) {
            String fieldValue = (String) result.get('fieldAlias');
            Integer countValue = (Integer) result.get('cnt'); 
            turnCount.put(fieldValue, countValue);
        }
        
        //unknown Location 
        Map<String, Integer> unknownLocationCount = new Map<String, Integer>();
        String unknownLocationFilter = System.Label.Unknown_Location   ;
        System.debug('Custom Label Value: unknownLocationFilter ==' + unknownLocationFilter);
        string unknownLocationQuery = 'SELECT Asset__r.Field2__c fieldAlias, COUNT(Id) cnt FROM Asset_History_custom__c WHERE '+ unknownLocationFilter +' GROUP BY Asset__r.Field2__c';
        List<AggregateResult> unknownLocationCountresult = Database.query(unknownLocationQuery);
        
        for (AggregateResult result : unknownLocationCountresult) {
            String fieldValue = (String) result.get('fieldAlias');
            Integer countValue = (Integer) result.get('cnt'); 
            unknownLocationCount.put(fieldValue, countValue);
        }
        
        //RDC 
        Map<String, Integer> RDCCount = new Map<String, Integer>();
        String RDCFilter = System.Label.RDC   ;
        System.debug('Custom Label Value: RDCFilter ==' + RDCFilter);
        string RDCQuery = 'SELECT Asset__r.Field2__c fieldAlias, COUNT(Id) cnt FROM Asset_History_custom__c WHERE '+ RDCFilter +' GROUP BY Asset__r.Field2__c';
        List<AggregateResult> RDCCountresult = Database.query(RDCQuery);
        
        
        for (AggregateResult result : RDCCountresult) {
            String fieldValue = (String) result.get('fieldAlias');
            Integer countValue = (Integer) result.get('cnt'); 
            RDCCount.put(fieldValue, countValue);
        }
        
        //Store
        Map<String, Integer> storeCount = new Map<String, Integer>();
        String storeFilter = System.Label.Store_Location    ;
        System.debug('Custom Label Value: storeFilter ==' + storeFilter);
        string storeQuery = 'SELECT Asset__r.Field2__c fieldAlias, COUNT(Id) cnt FROM Asset_History_custom__c WHERE '+ storeFilter +' GROUP BY Asset__r.Field2__c';
        List<AggregateResult> storeCountresult = Database.query(storeQuery);
        
        for (AggregateResult result : storeCountresult) {
            String fieldValue = (String) result.get('fieldAlias');
            Integer countValue = (Integer) result.get('cnt'); 
            storeCount.put(fieldValue, countValue);
        }
        
        Map<decimal,Target_Summary__c> tsMap = New Map<decimal,Target_Summary__c>();
        /* List<Target_Summary__c> targetSummeryList = [Select Id,  RDC__c, Store__c, Sweep_Lane_Exeception__c, Turn_Count__c, Unknown_Location__c, Asset_ID__c from Target_Summary__c ];
if(targetSummeryList.size()>0){
for(Target_Summary__c ts : targetSummeryList){
tsMap.put(ts.Asset_ID__c,ts);
}
}*/
        //sweep Lane Exception Loop
        For(string k : sweepLaneCount.keyset()){
            decimal dc =  Decimal.valueOf(k);
            integer count = sweepLaneCount.get(k);
            Target_Summary__c newTs = New Target_Summary__c();
            newTs.Asset_ID__c = dc;
            newTs.Sweep_Lane_Exeception__c = count;
            tsMap.put(newTs.Asset_ID__c,newTs);
            
        }
        
        //Turn Count Loop
        For(string k : turnCount.keyset()){
            decimal dc =  Decimal.valueOf(k);
            integer count = turnCount.get(k);
            Target_Summary__c ts = tsMap.get(dc);
            if(ts!=null){
                ts.Turn_Count__c = count;
            }else{
                Target_Summary__c newTs = New Target_Summary__c();
                newTs.Asset_ID__c = dc;
                newTs.Turn_Count__c = count;
                tsMap.put(newTs.Asset_ID__c,newTs);
            }
        }
        
        //Unknown Location Loop
        For(string k : unknownLocationCount.keyset()){
            decimal dc =  Decimal.valueOf(k);
            integer count = unknownLocationCount.get(k);
            Target_Summary__c ts = tsMap.get(dc);
            if(ts!=null){
                ts.Unknown_Location__c = count;
            }else{
                Target_Summary__c newTs = New Target_Summary__c();
                newTs.Asset_ID__c = dc;
                newTs.Unknown_Location__c = count;
                tsMap.put(newTs.Asset_ID__c,newTs);
            }
        }
        
        //RDC Loop
        For(string k : RDCCount.keyset()){
            decimal dc =  Decimal.valueOf(k);
            integer count = RDCCount.get(k);
            Target_Summary__c ts = tsMap.get(dc);
            if(ts!=null){
                ts.RDC__c = count;
            }else{
                Target_Summary__c newTs = New Target_Summary__c();
                newTs.Asset_ID__c = dc;
                newTs.RDC__c = count;
                tsMap.put(newTs.Asset_ID__c,newTs);
            }
        }
        
        //Store Loop
        For(string k : storeCount.keyset()){
            decimal dc =  Decimal.valueOf(k);
            integer count = storeCount.get(k);
            Target_Summary__c ts = tsMap.get(dc);
            if(ts!=null){
                ts.Store__c = count;
            }else{
                Target_Summary__c newTs = New Target_Summary__c();
                newTs.Asset_ID__c = dc;
                newTs.Store__c = count;
                tsMap.put(newTs.Asset_ID__c,newTs);
            }
        }
        //asset count
        Map<String, Integer> assetCount = new Map<String, Integer>();
        List<AggregateResult> assetCountlist = [SELECT Field2__c fieldvalue, COUNT(Id) cnt FROM Asset  WHERE Account_Unique_Id__c  = 'A-000589' GROUP BY Field2__c];
        if(assetCountlist.size()>0){
            for (AggregateResult result : assetCountlist) {
                String fieldValue = (String) result.get('fieldvalue'); //Asset_Count__c 
                Integer countValue = (Integer) result.get('cnt'); 
                assetCount.put(fieldValue, countValue);
                decimal dc =  Decimal.valueOf(fieldValue);
                Target_Summary__c ts = tsMap.get(dc);
                if(ts!=null){
                    ts.Asset_Count__c = countValue;
                }else{
                    Target_Summary__c newTs = New Target_Summary__c();
                    newTs.Asset_ID__c = dc;
                    newTs.Asset_Count__c = countValue;
                    tsMap.put(newTs.Asset_ID__c,newTs);
                }
            }
        }
        List<Target_Summary__c> targetToinst = New List<Target_Summary__c>();
        for(Target_Summary__c ts : tsMap.values()){
            targetToinst.add(ts);
        }
        if(targetToinst.size()>0){
            Database.SaveResult[] insertResults = Database.insert(targetToinst, false); 
        }
        
       
    }

}