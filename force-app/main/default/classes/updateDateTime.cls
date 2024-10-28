public class updateDateTime {
    public static void UpdateLRIRecordsEndTimeToAsset(List<asset_history_custom__C> ahHis){
        Map<Id, asset_history_custom__C> astHisMap = new Map<Id, asset_history_custom__C>();
        list<asset> astlst=new list<asset>();
        for(asset_history_custom__C record: ahHis) {
            if(record.Inserted_From__c=='Location Record' && record.location__c!='In Transit'){
                astHisMap.put(record.asset__c, record);
            }
        }
        for(asset ast:[select id,Current_address_date_time__c from asset where Id=:astHisMap.keySet()]){
            if(astHisMap.get(ast.Id).end_time__C > ast.Current_address_date_time__c && ast.Current_address_date_time__c!=null){
                
                if(!astHisMap.get(ast.Id).Still_in_this_Location__c){
                    ast.Current_address_date_time__c=astHisMap.get(ast.Id).end_time__C;
                    astlst.add(ast);
                }
                else{
                    ast.Current_address_date_time__c=null;
                    astlst.add(ast); 
                }
            }
        }
        if(astlst.size() > 0){
            update astlst;
        }
    }
}