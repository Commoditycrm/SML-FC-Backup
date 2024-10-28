({
    
    jsLoaded : function(component, event, helper) {
        // $A.enqueueAction(component.get('c.getuserLatLng'));
       // this.getuserLatLng(component, event, helper);  // Use 'self' to call the function
 
        var uslang1 = component.get("v.userLanguage");
        console.log("language--5"+uslang1);
        var map1 = component.get('v.map1');
        //console.log("map----",JSON.stringify(document.getElementById('map')));
        var container = document.getElementById('map1');
        var containerStr = JSON.stringify(document.getElementById('map1'));
        
        if (containerStr != "{}") {	
            //console.log("in if");
            container.outerHTML = "";
        }
        /*console.log("container",container);
        if (container != null) {
            container.outerHTML = ""; // Clear map generated HTML
            // container._leaflet_id = null; << didn't work for me
        }*/
        //console.log("Map--",L.map);
        map1 = L.map('map1', {zoomcontrol : false}).setView([43.813242, -91.192359], 3);
        L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
            }).addTo(map1);
        
        var smartlegend = L.control({ position: 'bottomright' });
        
        smartlegend.onAdd = function() {
              var inTransitText = $A.get("$Label.c.In_Transit");
              var KnownLocationText  = $A.get("$Label.c.Known_Location");
              var StartTimerecordText  = $A.get("$Label.c.Start_Time_record");
              var RecordsbetweenStartandEndtime  = $A.get("$Label.c.Records_between_Start_and_End_time");
              var EndTimerecord  = $A.get("$Label.c.End_Time_record ");
            var div = L.DomUtil.create('div', 'map1-legend');
                var astType = "Asset";
                var singleRackTransitText = "Single in Transit over rogue limit";
                div.innerHTML = `
                <div id="smartlegendContent" class="legend-content">
                    <span id="smartcloseLegend" style="cursor: pointer; float: right;" title="Close Legend">&times;</span>
                    <div class="slds-m-bottom_xx-small">
                        <p><span class="legend-icon startGreenTruck"></span> <span class="legend-icon blueBetweenTruck"></span> <span class="legend-icon endRedTruck"></span> ${inTransitText}</p>
                            </div>
                        <div class="slds-m-bottom_xx-small">
                            <p><span class="legend-icon startKnownLoc"></span> <span class="legend-icon blueBetweenLoc"></span> <span class="legend-icon endKnownLoc"></span>${KnownLocationText}</p>
                                </div>
                            <div class="slds-m-bottom_xx-small">
                                <p><span class="legend-icon startGreenTruck"></span> OR &nbsp;<span class="legend-icon startKnownLoc"></span> ${StartTimerecordText} </p>
                                </div>
                                <div class="slds-m-bottom_xx-small">
                                    <p><span class="legend-icon blueBetweenTruck"></span> OR &nbsp;<span class="legend-icon blueBetweenLoc"></span> ${RecordsbetweenStartandEndtime}</p>
                                    </div>
                                    <div class="slds-m-bottom_xx-small">
                                        <p><span class="legend-icon endRedTruck"></span> OR &nbsp;<span class="legend-icon endKnownLoc"></span> ${EndTimerecord}</p>
                                        </div>
                                        </div>
                                        <span id="smartopenLegend" class="info-button" style="cursor: pointer; display: none;" title="Show Legend">i</span>
                                        `;
            
            
            return div;
        };
        
        smartlegend.addTo(map1);
        
        component.set("v.map1", map1);  
        component.set("v.isMapLoaded", true);
        setTimeout(function() {
            document.getElementById('smartopenLegend').addEventListener('click', function() {
                document.getElementById('smartlegendContent').style.display = 'block';
                this.style.display = 'none';
            });
            
            document.getElementById('smartcloseLegend').addEventListener('click', function() {
                document.getElementById('smartlegendContent').style.display = 'none';
                document.getElementById('smartopenLegend').style.display = 'inline-block';
            });
        }, 0);      
        component.set("v.map1", map1);  
        component.set("v.isMapLoaded", true);
    },
    /*refreshView : function(component, event, helper) {
        var map = component.get('v.map');
        console.log("map-+-+",JSON.stringify(document.getElementById('map')));
        //console.log("latitude-+-+",JSON.stringify(document.getElementById('latitude')));
        //console.log("longitude-+-+",JSON.stringify(document.getElementById('longitude')));
        if(component.get("v.latitude") != undefined && component.get("v.longitude") != undefined){
            map.setView([component.get("v.latitude"),component.get("v.longitude")], 4); 
        }else{
            map.setView([43.813242,-91.192359], 4);    
        }
    },*/
    
    
    getuserLatLng : function(component, event, helper) {
        //console.log("in latlng---");
        var action = component.get("c.userlatlng");
        //console.log(action);
        
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
                var userLang = allValues.LanguageLocaleKey;
                component.set("v.userLanguage",allValues.LanguageLocaleKey); 
                console.log("here---"+userLang);
                if(allValues.LanguageLocaleKey == "es"){
                    component.set("v.MapView","Vista de mapa");
                    component.set("v.SatelliteView","Vista satelital");
                        //helper.jsLoaded(component, event, helper);
                }
                //console.log("response",response.getReturnValue());
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
                var map1 = component.get('v.map1');
                if(allValues.Latitude != undefined && allValues.Longitude != undefined){
                    //console.log("Inside if");
                    //console.log(allValues.Latitude.slice(0,9));
                    map1.setView([allValues.Latitude.slice(0,9),allValues.Longitude.slice(0,9)], 4);    
                }
                
       			 //var a = component.get('c.jsLoaded');
                 //$A.enqueueAction(a);
                 //this.jsLoaded(component, event, helper);
                /* else{
                    map.setView([43.813242,-91.192359],4)
                }*/
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
    
    loadAsset : function(component, event, helper) {
        
        var assethistory = event.getParam('assethist');
        var map1 = component.get('v.map1');
        if(component.get("v.latitude") != undefined && component.get("v.longitude") != undefined){
            map1.setView([component.get("v.latitude"),component.get("v.longitude")], 4); 
        }else{
            map1.setView([43.813242,-91.192359], 4);    
        }
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
            iconSize:     [38, 35], // size of the icon
            iconAnchor:   [22, 32],
        });
        var blueBuildingUrl = $A.get('$Resource.blueBuilding');
        var blueBuildingicon = L.icon({
            iconUrl: blueBuildingUrl,
            iconSize:     [28, 30], // size of the icon
            iconAnchor:   [14, 30],
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
        var assettype;
        map1.eachLayer(function (layer) {
            map1.removeLayer(layer);
        });
        var tl = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {zIndex:1,
             
            }); 
        map1.addLayer(tl);
        
        if(assethistory != null){
            var latlngs = [];   
            for (var i=0; i<assethistory.length; i++) {
                var assetHist = assethistory[i];
                if(assetHist.Asset_Type__c != null){
                    assettype = assetHist.Asset_Type__c;
                }
                else{
                    assettype = ' ';
                }
                console.log('hh'+assetHist.Asset_Type__c);
                
                if(assetHist.Latitude__c != null && assetHist.Longitude__c != null){
                    if(assetHist.Asset_Customer_ID__c==null){
                        assetHist.Asset_Customer_ID__c='';
                        if(assetHist.Location__c !='In Transit'){
                            var popvalue ='Asset Name: '+assetHist.Asset_Name__c+"<br/>"+'Customer ID: '+assetHist.Asset_Customer_ID__c+"<br/>"
                            +'Asset Type: '+assettype+"<br/>"
                            +'Start Time: '+assetHist.Start_Time_12_Hours__c+"<br/>"+'End Time: '+assetHist.End_Time_12_Hours__c+"<br/>"
                            +'Location: '+assetHist.Location__c;
                        }
                        if(assetHist.Location__c=='In Transit'){
                            var popvalue ='Asset Name: '+assetHist.Asset_Name__c+"<br/>"+'Customer ID: '+assetHist.Asset_Customer_ID__c+"<br/>"                       
                            +'Asset Type: '+assettype+"<br/>"
                            +'Start Time: '+assetHist.Start_Time_12_Hours__c+"<br/>"+'End Time: '+assetHist.End_Time_12_Hours__c+"<br/>"
                            +'Current Location Address: '+assetHist.Current_Location_Address__c;
                        }
                    }
                    else{
                        if(assetHist.Location__c!='In Transit'){
                            var popvalue ='Asset Name: '+assetHist.Asset_Name__c+"<br/>"+'Customer ID: '+assetHist.Asset_Customer_ID__c+"<br/>"                        
                            +'Asset Type: '+assettype+"<br/>"
                            +'Start Time: '+assetHist.Start_Time_12_Hours__c+"<br/>"+'End Time: '+assetHist.End_Time_12_Hours__c+"<br/>"
                            +'Location: '+assetHist.Location__c;
                        }
                        if(assetHist.Location__c=='In Transit'){
                            var popvalue ='Asset Name: '+assetHist.Asset_Name__c+"<br/>"+'Customer ID: '+assetHist.Asset_Customer_ID__c+"<br/>"
                            +'Asset Type: '+assettype+"<br/>"
                            +'Start Time: '+assetHist.Start_Time_12_Hours__c+"<br/>"+'End Time: '+assetHist.End_Time_12_Hours__c+"<br/>"
                            +'Current Location Address: '+assetHist.Current_Location_Address__c;
                        }
                    }
                    if(assetHist.Location__c!='In Transit'){
                        latlngs.push([assetHist.Current_Location__r.ShippingLatitude,assetHist.Current_Location__r.ShippingLongitude]);
                    }else{
                        latlngs.push([assetHist.Latitude__c,assetHist.Longitude__c]);
                    }
                    if(i==0){
                        //console.log('assethisstartnew'+assetHist.Start_Time__c);
                        
                        if(assetHist.Location__c!='In Transit'){
                            //console.log('assethisstart1'+assetHist.Start_Time__c);
                            //console.log('assethisstart1'+assetHist.	End_Time__c);
                            
                            marker = new L.marker([assetHist.Current_Location__r.ShippingLatitude,assetHist.Current_Location__r.ShippingLongitude],{icon:bluemarkericon}).bindPopup(popvalue).openPopup(); 
                            map1.addLayer(marker);  
                        }
                        else if(assetHist.Location__c=='In Transit'){
                            //console.log('assethisstart2'+assetHist.Start_Time__c);
                            //console.log('assethisstart2'+assetHist.End_Time__c);
                            marker = new L.marker([assetHist.Latitude__c,assetHist.Longitude__c],{icon:greenTruckicon}).bindPopup(popvalue).openPopup(); 
                            map1.addLayer(marker);   
                        }
                        
                    }else if(i==assethistory.length-1){
                        if(assetHist.Location__c!='In Transit'){
                            //console.log('assethisstart3'+assetHist.Start_Time__c);
                            //console.log('assethisstart3'+assetHist.End_Time__c);
                            marker = new L.marker([assetHist.Current_Location__r.ShippingLatitude,assetHist.Current_Location__r.ShippingLongitude],{icon:redmarkericon}).bindPopup(popvalue).openPopup(); 
                            map1.addLayer(marker);
                        }
                        else if(assetHist.Location__c=='In Transit'){
                            //console.log('assethisstart4'+assetHist.Start_Time__c);
                            //console.log('assethisstart4'+assetHist.End_Time__c);
                            marker = new L.marker([assetHist.Latitude__c,assetHist.Longitude__c],{icon:redTruckicon}).bindPopup(popvalue).openPopup(); 
                            map1.addLayer(marker);   
                            
                        }
                        
                    }else{
                        // alert('Location'+assetHist.Location);
                        if(assetHist.Location__c=='In Transit'){
                            marker = new L.marker([assetHist.Latitude__c,assetHist.Longitude__c],{icon:violetdoticon})
                            .bindPopup(popvalue).openPopup();          
                            markers.addLayer(marker);
                            map1.addLayer(markers);
                        }else if(assetHist.Location__c!='In Transit'){
                            marker = new L.marker([assetHist.Current_Location__r.ShippingLatitude,assetHist.Current_Location__r.ShippingLongitude],{icon:blueBuildingicon}).bindPopup(popvalue).openPopup(); 
                            markers.addLayer(marker);
                            map1.addLayer(markers);
                        }
                    }     
                }
                
            }
            
            var polyline = new L.polyline(latlngs, {color: 'blue', weight: '2',  dashArray: '6, 6', dashOffset: '0'});
            polyline.addTo(map1);
            
        }
        
    },
    validation2 : function(component, event, helper){
        var map1 = component.get('v.map1');
        var tl  = new L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        });
        map1.addLayer(tl);
        
        
        
    },
    validation3 : function(component, event, helper){
        var map1 = component.get('v.map1');
        var tl  = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
            }).addTo(map1);
        map1.addLayer(tl);
        
        
        
    },
    
})