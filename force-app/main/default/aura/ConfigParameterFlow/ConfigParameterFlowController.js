({
    doinit : function (component,event,helper) {
        
        var recId = component.get("v.recordId");
        
        var action =component.get("c.getParameter");
        
        action.setParams({'recordId' : recId});
        
        action.setCallback(this,function(response){
            component.set('v.loaded',true);
            if(response.getState() == "SUCCESS"){

                $A.get('e.force:refreshView').fire();
                var ress =response.getReturnValue();
                
                component.set("v.msg",ress);
                console.log( 'Data - ' + JSON.stringify(ress) );
                
            }
          
        });
        $A.enqueueAction(action);
    }
    
})