({
	toastFunction : function(component, event, helper ,message) {
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: message,
                    duration:' 4000',
                    type: 'error'
                });
                toastEvent.fire();
	}
})