({
	myAction : function(component, event, helper) {
      
   var action = component.get("c.facilitycount");

action.setCallback(this, function(response){
    var state = response.getState();
    if(state === 'SUCCESS'){
        var res = response.getReturnValue();
       
        component.set("v.productionCount",res);
           
    }
            
});
   var action1 = component.get("c.facilitycount1");

action1.setCallback(this, function(response){
    var state = response.getState();
    if(state === 'SUCCESS'){
        var res = response.getReturnValue();
       
        component.set("v.storageCount",res);
            
    }
            
});
                   
   $A.enqueueAction(action);                 
   $A.enqueueAction(action1); 
    }
    
})