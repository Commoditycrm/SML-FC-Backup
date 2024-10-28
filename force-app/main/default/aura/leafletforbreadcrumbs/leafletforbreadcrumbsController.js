({
    jsLoaded : function(component, event, helper) {
        //alert('called jsLoaded');
        var map = component.get('v.map');
        var container = document.getElementById('map');
        var containerStr = JSON.stringify(document.getElementById('map'));
        
        if (containerStr != "{}") {	
            console.log("in if");
            container.outerHTML = "";
        }
        map = L.map('map', {zoomcontrol : false}).setView([43.813242, -91.192359], 3);
        L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
            }).addTo(map);
        
        component.set("v.map", map);  
    },

    refreshView : function(component, event, helper) {
	         var map = component.get('v.map');
        	map.setView([43.813242, -91.192359], 3);
    },


   loadAsset : function(component, event, helper) {

      var assethistory = event.getParam('assethist');
        
      var map = component.get('v.map');
      map.setView([43.813242, -91.192359], 3);
      var marker = new L.Marker();
      var markers = new L.MarkerClusterGroup({
       
        maxClusterRadius: 80,
           
       });
       // Icons
       
      var violetdotUrl = $A.get('$Resource.violetdot');
      var violetdoticon = L.icon({
            iconUrl: violetdotUrl,
            iconSize:     [26, 26], // size of the icon
            iconAnchor:   [14, 30],
        });
      var redmarkerUrl = $A.get('$Resource.redmarker');
      var redmarkericon = L.icon({
            iconUrl: redmarkerUrl,
            iconSize:     [38, 35], // size of the icon
            iconAnchor:   [22, 32],
        });
      var bluemarkerUrl = $A.get('$Resource.bluemarker');
      var bluemarkericon = L.icon({
            iconUrl: bluemarkerUrl,
            iconSize:     [28, 30], // size of the icon
            iconAnchor:   [14, 30],
        });
       var blueBuildingUrl = $A.get('$Resource.blueBuilding');
        var blueBuildingicon = L.icon({
            iconUrl: blueBuildingUrl,
            iconSize:     [34, 35], // size of the icon
            iconAnchor:   [18, 38],
        });
       var redTruckUrl = $A.get('$Resource.redTruck');
        var redTruckicon = L.icon({
            iconUrl: redTruckUrl,
            iconSize:     [30, 30], // size of the icon
            iconAnchor:   [20, 30],
        });
       var greenTruckUrl = $A.get('$Resource.greenTruck');
        var greenTruckicon = L.icon({
            iconUrl: greenTruckUrl,
            iconSize:     [40,40], // size of the icon
            iconAnchor:   [22, 32],
        });
       map.eachLayer(function (layer) {
    			map.removeLayer(layer);
			});
            var tl = new L.tileLayer(
       'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          {zIndex:1,
             
       }); 
       map.addLayer(tl);
       
       if(assethistory != null){
            var latlngs = [];   
       		for (var i=0; i<assethistory.length; i++) {
            var assetHist = assethistory[i];
                
               if(assetHist.Latitude != null && assetHist.Longtitude != null){
                   if(assetHist.CustomerID==null){
                       assetHist.CustomerID='';
                   var popvalue ='Asset Name: '+assetHist.AssetNameHis+"<br/>"+'Customer ID: '+assetHist.CustomerID+"<br/>"
                   					+'Start Time: '+assetHist.StartTime+"<br/>"+'End Time: '+assetHist.EndTime+"<br/>"
                   					+'Account: '+assetHist.AssetAccount;
                   }
                   else{
                        var popvalue ='Asset Name: '+assetHist.AssetNameHis+"<br/>"+'Customer ID: '+assetHist.CustomerID+"<br/>"
                   					+'Start Time: '+assetHist.StartTime+"<br/>"+'End Time: '+assetHist.EndTime+"<br/>"
                   					+'Account: '+assetHist.AssetAccount;
                   }
                   latlngs.push(
                       [assetHist.Latitude,assetHist.Longtitude]);
                   if(i==0){
                       //check 2 conditions - 1 start with intransit or 2. if it start=s with current location
                      if(assetHist.Location!='In Transit'){
                       marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:bluemarkericon}).bindPopup(popvalue).openPopup(); 
                          map.addLayer(marker);  
                      }
                       else if(assetHist.Location=='In Transit'){
                       marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:greenTruckicon}).bindPopup(popvalue).openPopup(); 
                          map.addLayer(marker);  
                      }
                   }else if(i==assethistory.length-1){
                       if(assetHist.Location!='In Transit'){
                       marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:redmarkericon}).bindPopup(popvalue).openPopup(); 
                   	   map.addLayer(marker);
                       }
                       else if(assetHist.Location=='In Transit'){
                       marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:redTruckicon}).bindPopup(popvalue).openPopup(); 
                   	   map.addLayer(marker);
                       }
                       
                   }else{
                      // alert('Location'+assetHist.Location);
						if(assetHist.Location=='In Transit'){
                        marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:violetdoticon})
                       .bindPopup(popvalue).openPopup();          
                       	markers.addLayer(marker);
                            map.addLayer(markers);
                        }else if(assetHist.Location!='In Transit'){
                        marker = new L.marker([assetHist.Latitude,assetHist.Longtitude],{icon:blueBuildingicon}).bindPopup(popvalue).openPopup(); 
                        markers.addLayer(marker);
                            map.addLayer(markers);
                        }
                   }     
                }
              
      		}
          
         var polyline = new L.polyline(latlngs, {color: 'blue', weight: '2',  dashArray: '6, 6', dashOffset: '0'});
        		polyline.addTo(map);
           
          }
           
    }
})