({
    
    jsLoaded : function(component, event, helper) {
        var map = component.get('v.map');
        //console.log("map----",JSON.stringify(document.getElementById('map')));
        var container = document.getElementById('map');
        var containerStr = JSON.stringify(document.getElementById('map'));
        
        var i = 9;
        if (containerStr != "{}") {	
            //console.log("in if");
            container.outerHTML = "";
        }
        map = L.map('map', {zoomcontrol : false}).setView([43.813242, -91.192359], 4);
        L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
                
            }).addTo(map);
        
        component.set("v.map", map);
        component.set("v.isMapLoaded", true);
        
        let isAssetsLoaded = component.get("v.isAssetsLoaded");
        if(isAssetsLoaded) {
            console.log("Start Loading Assets="+ new Date()); 
            helper.loadAssetOnMap(component, event, helper);
            console.log("End Loading Assets="+ new Date()); 
        }
   }, 
    
  


    
    refreshView : function(component, event, helper) {
        var map = component.get('v.map');
        if(component.get("v.latitude") !== undefined && component.get("v.longitude") !== undefined){
            map.setView([component.get("v.latitude"),component.get("v.longitude")], 4); 
        }else{
            map.setView([43.813242,-91.192359], 4);    
        }
    },
    
    getuserLatLng : function(component, event, helper) {
        //console.log('kskjklgjgk'+window.screen.availHeight) 
        var mapheight=window.screen.availHeight;
        var mapheight2=mapheight*80/100;
        //console.log('mapheight'+mapheight2)
		component.set("v.mapstyle","align:right;height:"+mapheight2+"px;z-index:0 !important")

        //console.log("in latlng---");
        var action = component.get("c.userlatlng");
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                //console.log("response",response.getReturnValue());
                //console.log("shshshsh",allValues.Profile.Name)
                component.set("v.newId",allValues.Profile.Name);
                
                if(allValues.Latitude != undefined){
                    component.set("v.latitude",allValues.Latitude.slice(0,9));   
                }else{
                    component.set("v.latitude",43.813242);     
                }
                if(allValues.Longitude != undefined){
                    component.set("v.longitude",allValues.Longitude.slice(0,9));   
                }else{
                    component.set("v.longitude",-91.192359);     
                }
            }	 
        })
        $A.enqueueAction(action);
        
    },
    
    loadAsset : function(component, event, helper) {
        var assets = event.getParam('asset');
        component.set("v.assets", assets);
        component.set("v.isAssetsLoaded", true);
        
        let isMapLoaded = component.get("v.isMapLoaded");
        if(isMapLoaded) {
            console.log("Start Loading Assets="+ new Date()); 
            helper.loadAssetOnMap(component, event, helper);
            console.log("End Loading Assets="+ new Date()); 
        }
    },
    validation2 : function(component, event, helper){
        var map = component.get('v.map');
        var tl  = new L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        });
        map.addLayer(tl);
        
        
        
    },
    validation3 : function(component, event, helper){
        var map = component.get('v.map');
        var tl  = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
            }).addTo(map);
        map.addLayer(tl);       
        
    }  
    
    
})