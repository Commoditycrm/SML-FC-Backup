({
    sdhide : function(component,event,helper){
        document.getElementsByClassName(divMessage)[0].style.display = 'none';
    },
    edhide : function(component,event,helper){
        var elements = document.getElementsByClassName("EndDateWarning");
        elements[0].style.display = 'none';
    },
     emptyhide : function(component,event,helper){
        var elements = document.getElementsByClassName("EmptyValue");
        elements[0].style.display = 'none';
    },
    
      validation: function(component, event, helper){
      var startdate = component.get("v.startdate");
      var enddate = component.get("v.enddate");       
  	  var isshow=component.get("v.isShow");
            
      if(isshow){
            if(!startdate && !enddate){
       			helper.warningMessage("EmptyValue");
            }else if(!startdate){
       			helper.warningMessage("StartDateWarning");
            }else if(!enddate) {
       			helper.warningMessage("EndDateWarning");
            }else{
                var show = component.get('c.senddate');
           		 $A.enqueueAction(show);
            }
    }
        
    },
    senddate : function(component, event, helper) {
        
//var expirationDate = component.find("StartDate").get("v.value");
  var startdate = component.get("v.startdate");
  var enddate = component.get("v.enddate");
  var recordid = component.get("v.recordId");
  //var isshow=component.get("v.isShow")
 //console.log(startdate);
  var action = component.get('c.getdatefromjs');
  action.setParams({strtDate:startdate,enDate:enddate,recordid:recordid});
  action.setCallback(this, function(response) {
  var assethistory = response.getReturnValue();  
      if (response.getState() === "SUCCESS" && assethistory.length>0) 
      {
	        var event = $A.get("e.c:eventforbreadcrumbs");
        		event.setParams({"assethist": assethistory});
        		event.fire();
      }else{
          		document.getElementsByClassName("WarningAlert")[0].style.display = 'block';
                setTimeout(function () {
                	document.getElementsByClassName("WarningAlert")[0].style.display = 'none';
            	}, 4000);
      }
  });
  //component.set("v.Spinner", !component.get("v.Spinner"));            
  $A.enqueueAction(action);
},
    clearcomponent :  function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
	
})