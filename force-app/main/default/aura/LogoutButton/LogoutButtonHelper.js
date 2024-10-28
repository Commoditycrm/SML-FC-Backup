({
    
     getuserpermission : function(component, event, helper) {
        var action = component.get("c.ArmsUser");
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                var istrue = true;
                var armsUser = response.getReturnValue();
                console.log(armsUser);
                var buttonbolean = armsUser == false ? true : false;
                console.log('buttonbolean--'+buttonbolean);
                console.log('arms user--'+armsUser);
             
                component.set("v.isbutton", buttonbolean); 
                component.set("v.isEmail", armsUser); 
                var lang = component.get("v.userLanguage");
                if(lang == "es"){
                    component.set("v.emailtext" , "Preguntas? Correo electrónico");
                }
               
            }else{
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
     },

    // Update the user's language based on toggle input
    updateUserLanguage: function(component, newLanguage) {
        let action = component.get("c.updateuserLang");
        action.setParams({
            "newLanguage": newLanguage
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // Update the component with the new language
                component.set("v.userLanguage", newLanguage);
                window.location.reload();
            }else{
                let errors = response.getError();
                if (errors && errors.length > 0) {
                    // Log the first error message
                    console.error("Error message: " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    }


})