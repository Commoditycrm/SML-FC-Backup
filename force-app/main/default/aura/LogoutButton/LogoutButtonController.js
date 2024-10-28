({
    logout : function(component, event, helper) {
        window.location.replace("https://smartlogisticsinc--fullcopy.sandbox.my.site.com/secur/logout.jsp");
    },
    Custom : function(component, event, helper) {
        window.open("https://smartlogisticsinc.com/contact/");
    },
    getuserLatLng : function(component, event, helper) {
        var action = component.get("c.userlatlng");
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
                var userLang = allValues.LanguageLocaleKey;
                component.set("v.userLanguage",allValues.LanguageLocaleKey); 
                console.log("here---"+userLang);
                if(allValues.LanguageLocaleKey == "es"){
                    component.set("v.ContactSupport","Contactar con soporte");
                    component.set("v.Logout","Cerrar sesión");
                    component.set("v.userLanguage",allValues.LanguageLocaleKey);
                    component.set("v.toggleLabel","Switch to English");
                }else{
                    component.set("v.toggleLabel","Switch to Spanish");
                }
                helper.getuserpermission(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    // Handle the toggle switch and update the user language
    handleLanguageToggle: function(component, event, helper) {
        let isChecked = event.getSource().get("v.checked");
        var uslang = component.get("v.userLanguage");
        let newLanguage = uslang == "es" ? "en_US" : "es";
        helper.updateUserLanguage(component, newLanguage);
    }
})