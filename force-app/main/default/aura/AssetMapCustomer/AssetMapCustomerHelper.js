({
    helperMethod : function() {
        
    },
    
    loadAssetOnMap: function(component, event, helper) {
        component.set("v.loadingMessage", "Loading");
        var assets = component.get("v.assets");
        var map = component.get('v.map');
        var newId = component.get("v.newId");
        if (!assets || !map) {
            console.log("Assets or map not defined");
            return;
        }
        console.log("Profile", newId);
        console.log("Initializing map view...");
        
        // Set initial view
        var latitude = component.get("v.latitude") || 43.813242;
        var longitude = component.get("v.longitude") || -91.192359;
        map.setView([latitude, longitude], 4);
        
        var Bluemarker = $A.get('$Resource.bluemarkerlg');
        var MarkerBlue = L.icon({
            iconUrl: Bluemarker,
            iconSize: [24, 40],
            iconAnchor: [14, 30],
        });
        var Redmarker = $A.get('$Resource.Redmarkernew');
        var MarkerRed = L.icon({
            iconUrl: Redmarker,
            iconSize: [24, 40],
            iconAnchor: [14, 30],
        });
        
        var WarehouseUrl = $A.get('$Resource.Warehouse');
        var Warehouseicon = L.icon({
            iconUrl: WarehouseUrl,
            iconSize: [28, 30],
            iconAnchor: [20, 26],
        });
        
        var marker = new L.Marker();
        var markers = new L.MarkerClusterGroup({
            maxClusterRadius: 80,
        });
        
        console.log("Removing existing layers...");
        // Remove existing layers
        map.eachLayer(function(layer) {
            if (layer instanceof L.MarkerClusterGroup) {
                layer.clearLayers();
            } else if (layer !== markers) {
                map.removeLayer(layer);
            }
        });
        
        var tileLayer = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
                zIndex: 1,
            }
        );
        map.addLayer(tileLayer);
        
        console.log("Grouping assets...");
        // Group assets by Current_Location_Name__c
        var groupedAssets = {};
        var inTransitAssets = [];
        var totalAssets = assets.length;
        component.set("v.totalAssets", totalAssets);
        console.log('total asset '+totalAssets);
        
        var loadedAssets = 0;
        
        component.set("v.loadedAssets", loadedAssets);
        assets.forEach(function(asset) {
            if(asset.Temporary_Latitude__c != null && asset.Temporary_Longitude__c != null){
                if (asset.Current_Location__c) {
                    if(asset.Current_Loc_Longitude__c != null && asset.Current_Loc_latitude__c != null){
                        if (!groupedAssets[asset.Current_Location__c]) {
                            groupedAssets[asset.Current_Location__c] = {
                                Account: asset.Related_Assets__c,
                                count: 0,
                                latitude: asset.Current_Loc_latitude__c,
                                longitude: asset.Current_Loc_Longitude__c,
                                rackTypes: {}
                            };
                        }
                        groupedAssets[asset.Current_Location__c].count++;
                        
                        var rackType = asset.Rack_Type__c;
                        if (!groupedAssets[asset.Current_Location__c].rackTypes[rackType]) {
                            groupedAssets[asset.Current_Location__c].rackTypes[rackType] = 0;
                        }
                        groupedAssets[asset.Current_Location__c].rackTypes[rackType]++;
                        
                        
                    }
                }
                else {
                    inTransitAssets.push(asset);
                }
            }
        });
        addMarkersBatch(0);
        console.log('inTransitAssets.length ' + inTransitAssets.length);
        console.log('groupedAssets.length ' + Object.keys(groupedAssets).length);
        Object.values(groupedAssets).forEach(function(accgroup) {
            var groupedcount = Object.keys(groupedAssets).length;
            var intransitcount = inTransitAssets.length;
            var totalCount = groupedcount+intransitcount;
            component.set("v.groupedAssets",groupedcount);
            component.set("v.inTransitAssets",intransitcount);
            component.set("v.totalAssetscount", totalCount);
            console.log('Account: ' + accgroup.Account);
            var rackTypeCounts = Object.keys(accgroup.rackTypes).map(function(rackType) {
                return rackType + ': ' + accgroup.rackTypes[rackType];
            }).join('<br>');
            
            var popupContent = 
                'Account: ' + accgroup.Account + '<br>' +
                'Number of Assets: ' + accgroup.count + '<br>' +
                rackTypeCounts;
            console.log('Lat: ' + accgroup.latitude + ' Lon : ' + accgroup.longitude);
            var marker = new L.marker([accgroup.latitude, accgroup.longitude], {
                icon: Warehouseicon // Use the warehouse icon for grouped locations
            }).bindPopup(popupContent);
            marker.addTo(map);
            
            //loadedAssets += accgroup.count;
            loadedAssets++;
            
            component.set("v.loadedAssetscount", loadedAssets);
            helper.updateProgressBar(component);
        });
        //console.log('groupedAssets.length ' + loadedAssets);
        
        console.log("Starting to add markers...");
        // Function to add markers in batches
        function addMarkersBatch(startIndex) {
            if (startIndex == 0) {
                console.log('Asset Load Started ' + new Date());
            } else if (startIndex == inTransitAssets.length) {
                console.log('Asset Load completed ' + new Date());
            }
            var batchSize = 100; // Number of markers to add in each batch
            var endIndex = Math.min(startIndex + batchSize, inTransitAssets.length); // Calculate end index for the batch
            for (var i = startIndex; i < endIndex; i++) {
                var asset = inTransitAssets[i];
                var formattedDate = helper.formatDate(asset.Last_Connected__c);
                if (i == 0) {
                    console.log(asset.Name + ' ' + formattedDate);
                }
                var marker;
                if (newId == 'Customer User' && asset.Total_Dwell_Days__c >= asset.Rogue_Asset_Day_Limit__c && asset.Rogue_Asset_Day_Limit__c > 0) {
                    var popupContent = 
                        'Asset Name: ' + asset.Asset_Name_URL__c + '<br>' +
                        'Customer ID: ' + asset.Field2__c + '<br>' +
                        'Asset Type: ' + asset.Rack_Type__c + '<br>' +
                        'Last Connected: ' + formattedDate + '<br>' +
                        'State of Asset: ' + asset.State_of_Pallet__c + '<br>' +
                        'Current Location Address: ' + asset.Current_Location_Address__c + '<br>' +
                        'SMART Tracks: ' + asset.smart_tracks__c ;
                    
                    marker = new L.marker([asset.Temporary_Latitude__c, asset.Temporary_Longitude__c], {
                        icon: MarkerRed // Use appropriate icon for individual assets
                    }).bindPopup(popupContent);
                } else {
                    var popupContent = 
                        'Asset Name: ' + asset.Asset_Name_URL__c + '<br>' +
                        'Customer ID: ' + asset.Field2__c + '<br>' +
                        'Asset Type: ' + asset.Rack_Type__c + '<br>' +
                        'Last Connected: ' + formattedDate + '<br>' +
                        'State of Asset: ' + asset.State_of_Pallet__c + '<br>' +
                        'Current Location Address: ' + asset.Current_Location_Address__c + '<br>' +
                        'SMART Tracks: ' + asset.smart_tracks__c ;
                    
                    marker = new L.marker([asset.Temporary_Latitude__c, asset.Temporary_Longitude__c], {
                        icon: MarkerBlue // Use appropriate icon for individual assets
                    }).bindPopup(popupContent); // Need to change blue marker here.
                }
                
                markers.addLayer(marker);
                loadedAssets++;
                
                component.set("v.loadedAssetscount", loadedAssets);
                helper.updateProgressBar(component);
            }
            map.addLayer(markers); // Add the batch of markers to the map
            
            if (endIndex < inTransitAssets.length) {
                setTimeout(function() {
                    addMarkersBatch(endIndex); // Schedule the next batch
                }, 100); // Adjust timeout as necessary to control performance
            }
        }
        
        // Start adding markers in batches
        // Initialize with the first batch
    },
    
    updateProgressBar: function(component) {
        var loadedAssets = component.get("v.loadedAssetscount");
        var totalAssets = component.get("v.totalAssetscount");
        var actualTotalAssets = component.get("v.totalAssets");
        var groupedcount = component.get("v.groupedAssets");
        var inTransitCount = component.get("v.inTransitAssets");
        var totalLenght = groupedcount + inTransitCount;
        //console.log('TotalLenght for bar---'+totalLenght);
        //console.log('here loadedAssets count---'+loadedAssets);
        var loadedAssestcount;
        if(totalLenght > 0 && groupedcount > 0){
            var percentage = (loadedAssets / totalLenght) * 100;
            loadedAssestcount = Math.round((actualTotalAssets * percentage) / 100);
        }else{
            loadedAssestcount = loadedAssets;
        }
        component.set("v.loadedAssets", loadedAssestcount);
        //console.log('Count for bar--->'+loadedAssestcount+ '  ===Total Assest in map ===>'+actualTotalAssets);
        var totalAssets = component.get("v.totalAssets");
        // var percentage = (loadedAssets / totalAssets) * 100;
        component.set("v.progress", percentage);
        component.set("v.loadingMessage", "Loading "+ loadedAssestcount + " out of "+ totalAssets);
        if(loadedAssestcount >= totalAssets){
            component.set("v.loadedAssetscount",0);
            component.set("v.totalAssetscount",0);
            component.set("v.totalAssets",0);
            component.set("v.loadedAssets",0);
            component.set("v.groupedAssets",0);
            component.set("v.inTransitAssets",0);
            component.set("v.showSpinner", false);
            component.set("v.loadingMessage", "Loading");
            //console.log(loadedAssets +'/' + totalAssets);
            
        }
    },
    
    formatDate: function(dateString) {
        if (!dateString) {
            return '';
        }
        
        var date = new Date(dateString);
        var timestamp = date.getTime();
        var sixHoursInMillis = 6 * 60 * 60 * 1000;
        
        // Determine if DST is in effect
        var currentYear = date.getFullYear();
        var dstStart = new Date(currentYear, 2, 8);
        var dstEnd = new Date(currentYear, 10, 1);
        var isDst = date > dstStart && date < dstEnd;
        
        if (isDst) {
            sixHoursInMillis -= 60 * 60 * 1000;
        }
        
        var finalTime = timestamp - sixHoursInMillis;
        var newDate = new Date(finalTime);
        var year = newDate.getFullYear();
        var month = String(newDate.getMonth() + 1).padStart(2, '0');
        var day = String(newDate.getDate()).padStart(2, '0');
        var hours = newDate.getHours();
        var minutes = String(newDate.getMinutes()).padStart(2, '0');
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        
        return `${year}-${month}-${day} ${hours}:${minutes} ${ampm}`;
    },
})