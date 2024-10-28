({
    validation: function(component, event, helper){
      var startdate = component.get("v.startdate");
      var enddate = component.get("v.enddate");       
      var recordId = component.get("v.recordId");;
  	  var isshow=component.get("v.isShow");
       if(isshow){
            if(!startdate && !enddate){	
       			helper.warningMessage("EmptyValue");	

            }
           else{
                var show = component.get('c.senddate');
                $A.enqueueAction(show);
            }
       }
    },
    
    senddate : function(component, event, helper) {
      
  var startdate = component.get("v.startdate");
        //alert(startdate);  
  var enddate = component.get("v.enddate");  
       // alert(enddate);  
  var recordId = component.get("v.recordId");
        console.log('log   '+recordId);
  var action = component.get("c.asthis");
   
  action.setParams({startdate:startdate,enddate:enddate,recordid:recordId});
        console.log('log22 '+recordId);
  action.setCallback(this,function(response) {
    //alert(response.getState());
      if (response.getState() === "SUCCESS") 
      {
       var assethistory = response.getReturnValue();
       //   console.log(JSON.Stringify(assethistory));
          if(assethistory.length>0){
            var event = $A.get("e.c:eventforbreadcrumbs1");
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