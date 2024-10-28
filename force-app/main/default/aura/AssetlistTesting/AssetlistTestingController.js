({
	doinit : function(component, event, helper) {
		var action = component.get("c.assetListOptions"); //assetlistView
        action.setCallback(this, function(res){
        var allValues = res.getReturnValue();        
        var opts =[];
          
            /*if(allValues.includes('Cardinal Glass Spring Green - All Racks')) {
                opts.push({
                    Class:"optionclass",
                    label:'Cardinal Glass Spring Green - All Racks',
                    value:'Cardinal Glass Spring Green - All Racks' 
                });
            }*/

        for (var i = 0; i < allValues.length; i++) {
           //if(allValues[i] != 'Cardinal Glass Spring Green - All Racks') {
                             opts.push({
                        class: "optionClass",
                        label: allValues[i].List_view_Name__c,
                        value: allValues[i].Id
                    });
           //}
        }
       
                        console.log('Total List View = ' + opts.length);
        component.find("option").set("v.options", opts);
        var a = component.get('c.onPicklistChange');
       	$A.enqueueAction(a);
        });
        $A.enqueueAction(action);
  	      
	},

	
    
    onPicklistChange : function(component, event, helper) {
		component.set("v.showSpinner", true);		
        var liviewvalue = component.find("option").get("v.value");
        var action = component.get("c.fetchAssets"); // assetlist
        // lstname
        action.setParams({
            "assetListId" : liviewvalue    
        }); 
        action.setCallback(this, function(response){
            component.set("v.showSpinner", false);
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
                var event = $A.get("e.c:assetEvent");
        		event.setParams({"asset": allValues});
        		event.fire();
            }	 
        })
   
         $A.enqueueAction(action);
       
   
	}
})