({
    doinit : function(component, event, helper) {
        var action = component.get("c.assetListOptions"); //assetlistView
        action.setCallback(this, function(res){
            var allValues = res.getReturnValue();        
            var opts =[];
            
            
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
        component.set("v.loadingMessage", "Loading");
        component.set("v.showSpinner", true);
        
        var liviewvalue = component.find("option").get("v.value");
        var action = component.get("c.fetchAssets"); // assetlist
        // lstname
        action.setParams({
            "assetListId" : liviewvalue    
        }); 
        action.setCallback(this, function(response){
            // component.set("v.showSpinner", false);
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("Number of assets: " + allValues.length); // Log the count of assets
                component.set("v.assetListcount", allValues.length);
                var ccd=component.get("v.assetListcount");
                console.log('Number of Asset in cmp: '+ ccd);
                component.set("v.loadingMessage", "Loading");
                // var progress = 5;
                //  component.set("v.progress", progress);
                component.set("v.assets",allValues);
                if(ccd > 0){
                    helper.loadAssetOnMap(component, event, helper);
                }
                else{
                    component.set("v.showSpinner", false);
                    helper.loadAssetOnMap(component, event, helper);
                    component.set("v.loadingMessage", "Loading");
                }
            }	 
            
            
        })
        
        $A.enqueueAction(action);
        
        
    },
    jsLoaded: function(component, event, helper) {
        var action = component.get("c.getAccountByUserId");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var acc = response.getReturnValue();
                //console.log(acc.Name);
                
                var map = component.get('v.map');
                var container = document.getElementById('map');
                var containerStr = JSON.stringify(document.getElementById('map'));
                
                if (containerStr != "{}") {
                    container.outerHTML = "";
                }
                map = L.map('map', { zoomControl: false }).setView([43.813242, -91.192359], 4);
                L.tileLayer(
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
                        zIndex: 1,
                    }
                ).addTo(map);
                
                var legend = L.control({ position: 'bottomright' });
                
                legend.onAdd = function () {
                    var div = L.DomUtil.create('div', 'map-legend');
                    var astType = "Asset" ;
                    var singleRackTransitText = "Single " + astType + " in Transit over rogue limit";
                    if(acc != null){
                        astType =typeof acc.Map_PickList__c === "undefined"  ? "Asset" : acc.Map_PickList__c;
                        singleRackTransitText =typeof acc.Rogue_Asset_Day_Limit__c === "undefined" ? "Single " + astType + " in Transit over rogue limit" : 
                        `Single ${astType} in Transit over ${acc.Rogue_Asset_Day_Limit__c} days`;
                    }
                    
                    div.innerHTML = `
                    <div id="legendContent" class="legend-content">
                        <span id="closeLegend" style="cursor: pointer; float: right;" title="Close Lengend">&times;</span>
                        <div class="slds-m-bottom_xx-small"> <p><span class="legend-icon single-rack"></span> Single ${astType}</p></div>
                        <div class="slds-m-bottom_xx-small"> <p><span class="legend-icon single-rack-transit"></span> ${singleRackTransitText}</p></div>
                        <div class="slds-m-bottom_xx-small"> <p><span class="legend-icon many-racks"></span> Many ${astType}s (zoom in to see more detail)</p></div>
                        <div class="slds-m-bottom_xx-small"> <p><span class="legend-icon known-location"></span> Known Location</p></div>
                        </div>
                        <span id="openLegend" class="info-button" style="cursor: pointer; display: none;" title="Show Lengend">i</span>
                        `;
                    return div;
                };
                
                legend.addTo(map);
                component.set("v.map", map);
                component.set("v.isMapLoaded", true);
                
                let isAssetsLoaded = component.get("v.isAssetsLoaded");
                if (isAssetsLoaded) {
                    console.log("Start Loading Assets=" + new Date());
                    helper.loadAssetOnMap(component, event, helper);
                    console.log("End Loading Assets=" + new Date());
                }
                
                // Add the event listener to the toggle button after it's added to the DOM
                document.getElementById('openLegend').addEventListener('click', function() {
                    document.getElementById('legendContent').style.display = 'block';
                    this.style.display = 'none';
                });
                
                document.getElementById('closeLegend').addEventListener('click', function() {
                    document.getElementById('legendContent').style.display = 'none';
                    document.getElementById('openLegend').style.display = 'inline-block';
                });           
            } else {
                console.error("Failed to fetch account and contacts");
            }
        });
        $A.enqueueAction(action);
    },
    
    refreshView: function(component, event, helper) {
        var map = component.get('v.map');
        if (component.get("v.latitude") !== undefined && component.get("v.longitude") !== undefined) {
            map.setView([component.get("v.latitude"), component.get("v.longitude")], 4);
        } else {
            map.setView([43.813242, -91.192359], 4);
        }
    },
    
    getuserLatLng: function(component, event, helper) {
        var mapheight = window.screen.availHeight;
        var mapheight2 = mapheight * 80 / 100;
        component.set("v.mapstyle", "align:right;height:" + mapheight2 + "px;z-index:0 !important");
        
        var action = component.get("c.userlatlng");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.newId", allValues.Profile.Name);
                
                if (allValues.Latitude != undefined) {
                    component.set("v.latitude", allValues.Latitude.slice(0, 9));
                } else {
                    component.set("v.latitude", 43.813242);
                }
                if (allValues.Longitude != undefined) {
                    component.set("v.longitude", allValues.Longitude.slice(0, 9));
                } else {
                    component.set("v.longitude", -91.192359);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    validation2: function(component, event, helper) {
        var map = component.get('v.map');
        var tl = new L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', {
            maxZoom: 20,
            subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
        });
        map.addLayer(tl);
    },
    
    validation3: function(component, event, helper) {
        var map = component.get('v.map');
        var tl = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
                zIndex: 1,
            }
        ).addTo(map);
        map.addLayer(tl);
    }
    
    
})