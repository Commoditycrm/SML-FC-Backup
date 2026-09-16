global class RedesignNL_createBulkArc_batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
  	public string query;
    global RedesignNL_createBulkArc_batch(String query) {
        this.query = query;
    }    
	 global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query == null){
            query = 'Select Id, Incoming_Messsage__c, Status__c from API_Response__c where asset__r.isnew_Asset__c = true and status__c=\'Pending\' limit 1';
            
        }
     	return Database.getQueryLocator(query);
     }
    global void execute(Database.BatchableContext BC, List<API_Response__c> scope) {
        for(API_Response__c ar: scope) {
            System.debug('resp Id -- '+ar.Id);
            String result = RedesignNL_Controller.parseRequestBody(ar.Incoming_Messsage__c, ar, true);
  			System.debug(result);
        }

    }
    global void finish(Database.BatchableContext bC){
        /*
        List<API_response__c> apilist = [select id,status__c,Asset__c from API_response__c 
                                         where Asset__r.isNew_Asset__C = true  and 
                                         status__c = 'NEW' Order by createddate asc limit 1];
        if(apilist.size()>0){
            string assetid = apilist[0].Asset__c; 
            
            // Enclose the assetid value in quotes within the query
            string query = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ' +
                'LastActivityDate, LastViewedDate, LastReferencedDate, Access_Point_Id__c, Access_Point_Type__c, Area_Id__c, Area_Name__c, ' +
                'Asset_Group_Id__c, Asset_Product__c, Battery_Level__c, Device_Id__c, Field1__c, Field2__c, Humidity__c, Is_Test_Record__c, ' +
                'Last_Connected__c, Latitude__c, Longitude__c, Message_Count__c, Msg_Type__c, Needs_Repair__c, Position_Source__c, ' +
                'Ready_for_Pickup__c, Shock_Count__c, Shock_Max_Time__c, Shock_Max__c, Start_Time__c, Temperature__c, Unprocessed_Response__c, ' +
                'UpdateResponseToAsset__c, Zone_Id__c, Zone_Name__c, Accel__c, Base__c, Data__c, Device_Status__c, Events__c, Info__c, ' +
                'Is_Nimbelink_Asset__c, Loc__c, Temp__c, Incoming_Messsage__c, Asset_Created_Date__c, Asset__c, Account__c, ' +
                'AfterAssetProcDttime__c, AfterAssetProcTime__c, BefAssetProcDttime__c, BefAssetProcTime__c, ResEnteringDttime__c, ' +
                'ResEnteringTime__c, Location_TimeStamp__c, check_class__c, isprocesses__c, isnimble__c, Api_Callouts__c, API_Processing_Time__c, ' +
                'Created_Hour__c, Status__c, createddatedt__c, Powerup_TIme__c, Resprotime__c, Message_ID__c, Redesigned_Processed__c, ' +
                'Created_Date__c, Redesign_Createddate__c, Cardinal_Response1__c, Cardinal_Response2__c, Cardinal_Response3__c, ' +
                'Cardinal_Response4__c, Cardinal_Response5__c ' +
                'FROM Api_Response__c WHERE Asset__c = \'' + assetid + '\' AND Status__c = \'NEW\'';
            
           // RedesignNL_createBulkArc_batch bac = new RedesignNL_createBulkArc_batch(query);
            //Database.executeBatch(bac, 1);

            }*/
    }
}