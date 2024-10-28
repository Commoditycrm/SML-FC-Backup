public class FacilityLocation_ctrl {
    @AuraEnabled
     public static integer facilitycount (){
        List<Asset>asts =new list<Asset>();
       
         List<Asset>aslist =[select id,Facility_Location__c from Asset where Facility_Location__c IN ('Production','Storage') ];
         for(asset ast: aslist){
             if(ast.Facility_Location__c == 'Production'){
                 asts.add(ast);
             }
         
         }
      
  return asts.size();
         
     }
     @AuraEnabled
     public static integer facilitycount1 (){
       
         List<Asset>astsnew =new list<Asset>(); 
         List<Asset>aslist =[select id,Facility_Location__c from Asset where Facility_Location__c IN ('Production','Storage') ];
         for(asset ast: aslist){
          
             if(ast.Facility_Location__c == 'Storage'){
                 astsnew.add(ast);
              
             }
            
         }
     
      return astsnew.size();
        
         
     }

}