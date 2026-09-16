public class compareGoogleAPIData {
    
    public static boolean performAction(decimal cirlat,decimal cirlong,asset ast ){
        string lat = string.valueof(cirlat).left(7);
        string lng = string.valueof(cirlong).left(7);
        //list<Debug_Logs__c> dllist = new list<Debug_Logs__c>();
        boolean returnVal = false;
        try{
            for(Google_API_Data__c api : [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lng+'%' ]){
                if(!String.isBlank(api.Current_Address__c) ||
                   !String.isBlank(api.Current_City__c) ||
                   !String.isBlank(api.Current_State__c) ||
                   !String.isBlank(api.Current_Street_Address__c)){
                       ast.Current_Address__c = api.Current_Address__c;
                       ast.Current_City__c = api.Current_City__c;
                       ast.Current_State__c = api.Current_State__c;
                       ast.Current_Street_Address__c = api.Current_Street_Address__c;
                       ast.Current_Zip_Code__c = api.Current_Zip_Code__c;
                       
                     /*  Debug_Logs__c dc = new Debug_Logs__c();
                       dc.Asset_Device_ID__c = ast.Device_Id__c;
                       dc.Last_connected_Time__c =ast.Last_Connected__c;
                       dc.Latitude__c = decimal.valueof(string.valueof(ast.Temporary_Latitude__c).left(7));
                       dc.Longitude__c = decimal.valueof(string.valueof(ast.Temporary_Longitude__c).left(7));
                       dc.Last_Modified_Date__c = ast.LastModifiedDate; 
                       dc.Type__c = 'Google API Data';
                       dllist.add(dc);*/
                       
                       returnVal = true;
                   }

        }
        /*if(label.DebugLogsForAsset == 'true' && dllist.size()>0)
            insert dllist;*/
        return returnVal;
        }
            catch(exception ex){
                Utilityclass.sendemailtoadmin(ex);
                return null;
        } 
    }
    //NEW FUNCTION
     public static boolean performAction(decimal cirlat,decimal cirlong,Asset_History_custom__c ast ){
        string lat = string.valueof(cirlat).left(7);
        string lng = string.valueof(cirlong).left(7);
        boolean returnVal = false;
        try{
        for(Google_API_Data__c api : [select id,Current_City__c,Current_State__c,Current_Address__c,Current_Street_Address__c,Current_Zip_Code__c,Latitude__c,Longitude__c from Google_API_Data__c where Latitude__c like: '%'+lat+'%' and Longitude__c like: '%'+lng+'%' ]){
            
            if(!String.isBlank(api.Current_Address__c)){
                ast.Current_Location_Address__c = api.Current_Address__c;
                
                returnVal = true;
            } 
            
        }
        
        return returnVal;
        }
            catch(exception ex){
                Utilityclass.sendemailtoadmin(ex);
                return null;
        } 
    }
}