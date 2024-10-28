({
    handleClick : function(component, event, helper) {
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": 'https://smart-app-prod.herokuapp.com/' 
        });
        eUrl.fire();
    }
})