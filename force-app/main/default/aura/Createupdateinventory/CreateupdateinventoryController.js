({
	Updateinventories : function(component, event, helper) {
        // var recId = component.get("v.recordId");//
	    var action = component.get("c.createandUpdateInventory");	
      //  alert('In action'+action);
       action.setCallback(component,function(response){
            
            if(response.getState() == "SUCCESS"){ 
                
               // $A.get('e.force:refreshView').fire();
               
                 	component.set("v.msg","Inventory has been updated successfully");  
                                        
                    }
                else{
                 	component.set("v.msg","An Unexpected Error Occurred, Please contact system Administrator");    
                    
                
                }
	});
        $A.enqueueAction(action);
	}
})