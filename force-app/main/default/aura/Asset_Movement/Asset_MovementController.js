({
    validation: function(component, event, helper){
      var startdate = component.get("v.startdate");
      var enddate = component.get("v.enddate");       
      var recordid = component.find("asset").get("v.value");
  	  var isshow=component.get("v.isShow");
       if(isshow){
            if(!startdate && !enddate && !recordid){
				helper.toastFunction(component, event, helper,'Please enter Start Date, End Date and Asset');        
                isshow=false;
            }else if(!startdate && !enddate){
                helper.toastFunction(component, event, helper,'Please enter Start Date and End Date');        
                isshow=false;
            }else if(!startdate && !recordid){
                helper.toastFunction(component, event, helper,'Please enter Start Date and Asset');        
                isshow=false;
            }else if(!recordid && !enddate){
                helper.toastFunction(component, event, helper,'Please enter End Date and Asset');        
                isshow=false;
            }else if(!startdate){
                helper.toastFunction(component, event, helper,'Please enter Start Date');        
                isshow=false;
            }else if(!enddate){
                helper.toastFunction(component, event, helper,'Please enter End Date');        
                isshow=false;
            }else if(!recordid){
                helper.toastFunction(component, event, helper,'Please enter Asset');        
                isshow=false;
            }else{
                var show = component.get('c.senddate');
                $A.enqueueAction(show);
            }
            }
    },
    
    senddate : function(component, event, helper) {
        
  var startdate = component.get("v.startdate");
  var enddate = component.get("v.enddate");       
  var recordid = component.find("asset").get("v.value");
  var action = component.get('c.getdatefromjs');
  action.setParams({strtDate:startdate,enDate:enddate,recordid:recordid});
  action.setCallback(this, function(response) {
    
      if (response.getState() === "SUCCESS") 
      {
       var assethistory = response.getReturnValue();
          if(assethistory.length>0){
	        var event = $A.get("e.c:eventforbreadcrumbs");
        		event.setParams({"assethist": assethistory});
        		event.fire();
          }
      	 else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message:'No Data Available...!!!',
                    messageTemplate: 'No Data Available...!!!',
                    duration:' 4000',
                    key: 'info_alt',
                    type: 'Warning',
                    mode: 'pester'
                });
                toastEvent.fire();

      }
      }
  });
  //component.set("v.Spinner", !component.get("v.Spinner"));            
  $A.enqueueAction(action);
},
    clearcomponent :  function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
	
})