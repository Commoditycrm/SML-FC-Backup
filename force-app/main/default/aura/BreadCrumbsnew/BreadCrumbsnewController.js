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
        //alert(startdate);  
  var enddate = component.get("v.enddate");  
       // alert(enddate);  
  var recordid = component.find("asset").get("v.value");
  var action = component.get("c.asthis");
   
  action.setParams({startdate:startdate,enddate:enddate,recordid:recordid});
        
  action.setCallback(this, function(response) {
    //alert(response.getState());
      if (response.getState() === "SUCCESS") 
      {
       var assethistory = response.getReturnValue();
         // console.log(JSON.Stringify(assethistory));
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


redirect :  function(component, event, helper) {
    window.location.reload();
},
    
clearcomponent :  function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
},
    load : function(component, event, helper){
       // alert('test')
        var pageReference = component.get("v.pageReference.state.c__Id"); 
        if(!$A.util.isUndefinedOrNull(pageReference)) {
            var recordid = pageReference;
            component.set('v.recordId',recordid);
        }
        else {
            var parsedUrl = new URL(window.location.href);
            var params = parsedUrl.search;
            if(params.includes('c__Id=')) {
                var pos = params.indexOf('c__Id=');
                var id = params.substring(pos+6, pos+6+15);
                component.set("v.recordId", id);
            }
        }
    },
    
     getuserLatLng : function(component, event, helper) {
        //console.log("in latlng---");
        var action = component.get("c.getLanguage");
        //console.log(action);
      
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                console.log()
                var allValues = response.getReturnValue();
                var userLang = allValues.LanguageLocaleKey;
                 component.set("v.userLanguagechange",allValues.LanguageLocaleKey); 
                console.log("here---116"+userLang);
                if(allValues.LanguageLocaleKey == "es"){
                    component.set("v.StartDateparent" , "Fecha de inicio");
                     component.set("v.EndDateparent" , "Fecha de finalización");
                     component.set("v.Showparent" , "Espectáculo");
                }
            }
               
        });
        
        $A.enqueueAction(action);
        
     }
    
	

	
})