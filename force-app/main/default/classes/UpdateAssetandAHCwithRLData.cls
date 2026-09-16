public class UpdateAssetandAHCwithRLData implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    public  set<id> assetIds = new set<id>();
    //BatchLog fields
    public String batchName;
    public DateTime batchStartTime;
    Public String batchStatus;
    public Integer totalRecords = 0;
    public static Integer totalFailureRecords = 0;
    public static List<String> failureMsgs = new List<String>();
    public static Map<Id, Railway_Line_Information__c> railMap ;
    
   
    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.batchName='UpdateAssetandAHCwithRLData';
        this.batchStartTime = system.Now();
        this.batchStatus = 'Processing';     
        railMap = New Map<Id, Railway_Line_Information__c>([select id,Name from Railway_Line_Information__c]);
        DateTime lastFiveMins = system.now().addMinutes(-15);
        string query = 'select id,Asset__c,Latitude__c,Longitude__c,Railway_Line__c,End_Time__c,Still_in_this_Location__c from Asset_History_Custom__c where Asset__r.Account.Check_Railway_Geofence__c = true '+
                        ' and Railway_Line__c=null and createddate >= :lastFiveMins and Longitude__c!=null and Latitude__c!=null ORDER BY End_Time__c DESC';
     	return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Asset_History_Custom__c> scope) {
        Map<Id, Railway_Line_Information__c> railwayMap  = New Map<Id, Railway_Line_Information__c>([select id,Name from Railway_Line_Information__c]);
        totalRecords += scope.size();
        List<Asset> astList = New List<Asset>();
        set<id> astIds = New set<id>();
        try{
            for(Asset_History_Custom__c ahc: scope){
                astIds.add(ahc.asset__c);
            }
            set<id> astsupdatedwithRL = New Set<id>();
            Map<id, Asset> astMap = New Map<id,Asset>([select id,Current_Railway_Line__c from Asset where Id IN :astIds]);
            for(Asset_History_Custom__c ahc : scope){
                id Railwayid = nearestRL(ahc.Latitude__c,ahc.Longitude__c);
                if(Railwayid!=null && railwayMap.containsKey(Railwayid)){
                    system.debug('nearestRailwayLine--->'+railwayMap.get(Railwayid).Name);
                    ahc.Railway_Line__c = railwayMap.get(Railwayid).Name;
                }
                if(!astsupdatedwithRL.contains(ahc.Asset__c) && ahc.Still_in_this_Location__c==true){
                    asset ast = astMap.get(ahc.Asset__c);
                    ast.Current_Railway_Line__c = ahc.Railway_Line__c;
                    astsupdatedwithRL.add(ahc.Asset__c);
                    astList.add(ast);
                }
                
            }
            try{
                update scope;
                update astList;
            }catch(exception e){
                RedesignNL_CaptureErrors.createErrorLogs(e, 'UpdateAssetandAHCwithRLData', 'execute', 'DML Error', null, null, true);
                system.debug('error message--'+e);
                failureMsgs.add('UpdateAssetandAHCwithRLData - update records. Error msg: '+e.getMessage());
                totalFailureRecords = totalFailureRecords + 1;

            }
            
        }catch(exception e){
            RedesignNL_CaptureErrors.createErrorLogs(e, 'UpdateAssetandAHCwithRLData', 'execute', 'DML Error', null, null, true);
			  failureMsgs.add('UpdateAssetandAHCwithRLData - ExecuteMethod. Error msg: '+e.getMessage());
                	totalFailureRecords = totalFailureRecords + 1;
        }
        
    }
    public void finish(Database.BatchableContext bC) {
        if(batchStatus == 'Processing'){
            batchStatus = 'Completed';
        }
        else if(totalFailureRecords > 0 || this.batchStatus == 'Failed'){
            batchStatus = 'Failed';
        }
        RedesignNL_Helper.createBatchDataCustom(bC,null, batchName, batchStartTime, failureMsgs, totalFailureRecords, batchStatus, totalRecords);
    }
    
     public static id nearestRL(decimal lat, decimal lng){
        id result;
        
        // Define constants for 2 miles in degrees (latitude and longitude changes)
        Decimal milesToDegreesLat = 1 / 69.0;  // 1 degree of latitude ≈ 69 miles
        Decimal latInRadians = lat * Math.PI / 180;  // Convert latitude to radians manually
        Decimal milesToDegreesLon = 1 / (69.0 * Math.cos(latInRadians));  // Adjust longitude for latitude
        
        // Calculate the change in latitude and longitude for a 2-mile radius
        Decimal latDiff = 2.0 * milesToDegreesLat;
        Decimal lonDiff = 2.0 * milesToDegreesLon;
        
        // Calculate the bounding box (min/max latitudes and longitudes)
        Decimal minLat = lat - latDiff;
        Decimal maxLat = lat + latDiff;
        Decimal minLon = lng - lonDiff;
        Decimal maxLon = lng + lonDiff;
        
        // Query records within the bounding box 
        result = getEAData.queryAnalyticsDataset(lat, lng, minLat, maxLat, minLon, maxLon);
        
        return result;
    }
}