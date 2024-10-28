public class RedesignNL_createApiResponseChild {
    public static Redesign_NL__mdt RedesignMetadata = RedesignNL_Helper.getRedesignMetadata('Default');
    
    @Invocablemethod
    public static void createApiResponseChild(list<wrapper> Record){
        system.debug('test'+Record);
        String recordid = Record[0].recordid;        
        String longitude = Record[0].longitude;        
        String latitude = Record[0].latitude;   
        datetime timestamp = Record[0].timestamp;   
        List<Asset> assetList = [select id,accountid, Device_Id__c, name,src__c, Accuracy_meters__c, alt__c from asset where id =: recordid];
        List<Debug_Logs__c> debugLogsToInset = new List<Debug_Logs__c>();
        
        try {
            
            if(assetList.size() > 0) {
                
                //Create new API Response
                Api_Response__c apires = new Api_Response__c();
                apires.Status__c = 'NEW';
                apires.Asset__c = assetList[0].id;
                apires.Device_Id__c = assetList[0].Device_Id__c != null ? assetList[0].Device_Id__c :null;
                apires.Incoming_Messsage__c = 'Manual Update';
                
                list<API_Response_Childs__c> apiChildLst = new list<API_Response_Childs__c> ();
                API_Response_Childs__c apichildCreate = new API_Response_Childs__c();
                Long Updatedtimestamp = convertToUnixTimestamp(timestamp);
                apichildCreate.RecordTypeId = RedesignNL_Helper.getAPIChildRecordTypeID(RedesignNL_Helper.ArcLocationRecordtype);
                apichildCreate.Latitude__c = latitude;
                apichildCreate.Status__c = 'New';
                apichildCreate.Timestamp_DateTime__c = timestamp;
                apichildCreate.Longitude__c = longitude;
                apichildCreate.Timestamp__c = Updatedtimestamp;
                apichildCreate.haccRank__c = 0;
                apichildCreate.Asset__c = assetList[0].id != null ? assetList[0].id :null ;
                apichildCreate.Alt__c= assetList[0].alt__c != null ?assetList[0].alt__c :null ;
                apichildCreate.Accuracy_meters__c= assetList[0].Accuracy_meters__c != null ? assetList[0].Accuracy_meters__c :null;
                apichildCreate.Message_Type__c= assetList[0].src__c != null ? assetList[0].src__c :null ;
                apichildCreate.ARC_External_Id__c =  recordid + '~' + Updatedtimestamp + '~Location';            
                
                apiChildLst.add(apichildCreate);
                RedesignNL_Controller.createGoogleAPIRecords(apiChildLst, assetList[0].Device_Id__c);
                
                insert apires;
                
                list<api_response__c> apireslist = [select id,name from api_response__c where id =: apires.id];
                if(apiChildLst.size() > 0){
                    for(API_Response_Childs__c arc : apiChildLst) {
                        arc.API_Response__c = apires.Id;
                        arc.Name = apireslist[0].name + '-' + RedesignNL_Helper.ArcLocationRecordtype;
                        
                    }
                    insert apiChildLst;
                }
            }
        }
        catch(Exception ex) {
            RedesignNL_CaptureErrors.createErrorLogs(ex, 'RedesignNL_createApiResponseChild', 'createApiResponseChild', 'Exception', recordid, null, true);
            
        }
    }
    public static Long convertToUnixTimestamp(DateTime dateTimeValue) {
        // Convert DateTime to Unix timestamp (milliseconds since January 1, 1970)
        Long unixTimestamp = dateTimeValue.getTime();
        unixTimestamp = unixTimestamp / 1000;
        return unixTimestamp;
    }
    
    public class wrapper{
        @InvocableVariable(required=true)
        public string recordid;
        
        @InvocableVariable(required=true)
        public string latitude;
        
        @InvocableVariable(required=true)
        public string longitude;  
        
        @InvocableVariable(required=true)
        public datetime timestamp;   
        
    }
}