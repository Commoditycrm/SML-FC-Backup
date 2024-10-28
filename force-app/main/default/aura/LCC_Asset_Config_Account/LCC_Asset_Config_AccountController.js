({
    doinit: function (component, event, helper) {
        var isDisabled = component.get("v.isDisabled");
        var recId = component.get("v.recordId");

        if (!isDisabled) {

            var action = component.get("c.getAccountId");

            action.setParams({
                'accountId': '' + recId + ''
            });

             action.setCallback(this, function(response) {
            var state = response.getState();
                 component.set("v.isDisabled", true);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.message", returnValue);
                
                /*if(returnValue == 'no-records-found') {
                    component.set("v.message", "Save Desired Configuration prior to update");
                }
                else if (returnValue == "batch-already-running") {
                    // Handle the scenario when the batch is already running
                    component.set("v.message", "Another Sync is already running. Please try to click this button after 10 mins.");
                   
                } else {
                    // Handle success scenario
                    component.set("v.message", "Batch started successfully. Check status in Account related tab."); 
                }*/
            } else {
                console.error("Error occurred: " + state);
            }
        });
            $A.enqueueAction(action);
        } else {
            console.log("Component is disabled. getAccountId method not executed.");
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})