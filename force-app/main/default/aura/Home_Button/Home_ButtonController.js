({

    Recordpage : function(component, event, helper) {
        window.location.replace("https://smartlogisticsinc--fullcopy.sandbox.my.site.com/s/");
		
	},
      getuserLang: function(component, event, helper) {
     
        var action = component.get("c.userlatlng");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var allValues = response.getReturnValue();
                if(allValues.LanguageLocaleKey == 'es'){
                    component.set("v.Home", "Hogar");
                   
                }
                           }
        });
        $A.enqueueAction(action);
    },
})