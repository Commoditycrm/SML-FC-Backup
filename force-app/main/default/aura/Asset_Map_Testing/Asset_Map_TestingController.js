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
        console.log('loadAsset Start Time='+ new Date().getSeconds());
        var newId = component.get("v.newId");
        //console.log("ssssss",newId)
        var assets = event.getParam('asset');
        console.log('size '+assets.length);
        
        var map = component.get('v.map');
        if(component.get("v.latitude") !== "undefined" && component.get("v.longitude") !== "undefined"){
            map.setView([component.get("v.latitude"),component.get("v.longitude")], 4); 
        }else{
            map.setView([43.813242,-91.192359], 4);    
        }
        
        var marker = new L.Marker();
        var Redmarker = $A.get('$Resource.Redmarkernew');
        var MarkerRed = L.icon({
            iconUrl: Redmarker,
            iconSize:     [24, 40], // size of the icon
            iconAnchor:   [14, 30],
        });
        var WarehouseUrl = $A.get('$Resource.Warehouse');
        var Warehouseicon = L.icon({
            iconUrl: WarehouseUrl,
            iconSize:     [28, 30], // size of the icon
            iconAnchor:   [20, 26],
        });
        var markers = new L.MarkerClusterGroup({
            maxClusterRadius: 80,
        });
        
        map.eachLayer(function (layer) {
            map.removeLayer(layer);
        });
        var tl = new L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {zIndex:1,
             
            }); 
        map.addLayer(tl);
        var set1 = new Set(); 
        
        var currentlocmap = new Map();
        var currentlocmap1 = new Map();
        //console.log('CLmap--'+currentlocmap);
        //alert(assets);
        if(assets != null){
            console.log('assssset1'+assets.length);
            for (var i=0; i<assets.length; i++) {
                var asset = assets[i];
                
                var statepallet;
                var CusId;
                var lstcnt;
                let count;  
                let count1; 
                if(asset.Current_Location_Name__c != null){
                    //console.log('assssset3'+assets);
                    
                    // alert('Lng'+asset.Current_Loc_latitude__c +'lat'+asset.Current_Loc_Longitude__c);
                    if(asset.Current_Loc_latitude__c != null && asset.Current_Loc_Longitude__c != null){
                        
                        //console.log('asset.Rack_Type__c----'+asset.Rack_Type__c);
                        //console.log(currentlocmap.has(asset.Current_Location__c));
                        
                        if(currentlocmap.has(asset.Current_Location__c)){
                            if(currentlocmap1.has(asset.Current_Location__c+'*'+asset.Rack_Type__c)){
                                count = currentlocmap.get(asset.Current_Location__c)+1;
                                count1 = currentlocmap1.get(asset.Current_Location__c+'*'+asset.Rack_Type__c)+1;
                                
                                // var popupValue1 = 'Account: '+ asset.Current_Location_Name__c +"<br/>"+'Number of Assets: '+ count +"<br/>";
                                var popupValue1 = 'Account: '+ asset.Related_Assets__c +"<br/>"+'Number of Assets: '+ count +"<br/>";
                                //console.log('pop up 1');
                                
                                // count = currentlocmap.get(asset.Current_Location_Name__c)+1;
                                // count1 = currentlocmap1.get(asset.Current_Location_Name__c+'*'+asset.Rack_Type__c)+1;
                                currentlocmap.set(asset.Current_Location__c,count); 
                                currentlocmap1.set(asset.Current_Location__c+'*'+asset.Rack_Type__c,count1);
                                var popupValue2 = '';
                                for(let racktype of currentlocmap1.keys()){
                                    //console.log('racktype--'+racktype); 
                                    if(racktype.includes(asset.Current_Location__c)){
                                        let secondPart;
                                        for(let rackname of racktype.split("*") ){
                                            if(secondPart == 1){
                                                if(popupValue2 == '')
                                                    popupValue2 = rackname + ': '+ currentlocmap1.get(racktype);  
                                                else
                                                    popupValue2 = popupValue2 +"<br/>"+ rackname + ': '+ currentlocmap1.get(racktype);        
                                            }
                                            secondPart = 1;
                                            
                                        }     
                                    }
                                    
                                    
                                }   
                                var popvalue = popupValue1 + popupValue2;
                                
                            }else{
                                
                                count = currentlocmap.get(asset.Current_Location__c)+1;
                                currentlocmap1.set(asset.Current_Location__c+'*'+asset.Rack_Type__c,1);
                                currentlocmap.set(asset.Current_Location__c,count); 
                                //var popvalue = 'Account: '+ asset.Current_Location_Name__c +"<br/>"+'Number of Assets: '+count+"<br/>"+asset.Rack_Type__c+': 1';    
                                var popupValue1 = 'Account: '+ asset.Related_Assets__c +"<br/>"+'Number of Assets: '+count+"<br/>";
                                //console.log('pop up 2');
                                
                                var popupValue2 = '';
                                for(let racktype of currentlocmap1.keys()){
                                    //console.log('racktype--'+racktype); 
                                    if(racktype.includes(asset.Current_Location__c)){
                                        let secondPart;
                                        for(let rackname of racktype.split("*") ){
                                            if(secondPart == 1){
                                                if(popupValue2 == '')
                                                    popupValue2 = rackname + ': '+ currentlocmap1.get(racktype);  
                                                else
                                                    popupValue2 = popupValue2 +"<br/>"+ rackname + ': '+ currentlocmap1.get(racktype);        
                                            }
                                            secondPart = 1;
                                            
                                        }     
                                    }
                                    
                                    
                                }   
                                var popvalue = popupValue1 + popupValue2;
                            }
                        }else{
                            //var popvalue = 'Account: '+ asset.Current_Location_Name__c +"<br/>"+'Number of Assets: '+1+"<br/>"+asset.Rack_Type__c+': 1';    
                            var popvalue = 'Account: '+ asset.Related_Assets__c  +"<br/>" + 'Number of Assets: '+1+"<br/>"+asset.Rack_Type__c+': 1'+ "<br/>";    
                            currentlocmap.set(asset.Current_Location__c,1);
                            currentlocmap1.set(asset.Current_Location__c+'*'+asset.Rack_Type__c,1);
                            //console.log('pop up 3');
                        }
                        
                        //var popvalue = 'Account: '+ asset.Current_Location_Name__c +"<br/>"+'Number of Assets: '+asset.Current_Loc_Assets_count__c;
                        
                        marker = new L.marker([asset.Current_Loc_latitude__c,asset.Current_Loc_Longitude__c],{icon:Warehouseicon})
                        .bindPopup(popvalue).openPopup();
                        // alert('above map marker');
                        marker.addTo(map);
                        set1.add(asset.Current_Location__c);
                        set1.add(asset.Rack_Type__c);
                        
                        
                        //markerClusters.addLayer(marker);
                    }
                } else{
                    
                    if(asset.State_of_Pallet__c != null){
                        statepallet = asset.State_of_Pallet__c;
                    }else{
                        statepallet = '';
                    }
                    if(asset.Field2__c != null){
                        CusId = asset.Field2__c;
                    }else{
                        CusId = '';
                    }
                    if(asset.Last_Connect_Map_Formula__c != null){
                        lstcnt = asset.Last_Connect_Map_Formula__c;
                    }else{
                        lstcnt = '';
                    }
                    
                    //alert('ELng'+asset.Temporary_Latitude__c +'Elat'+asset.Temporary_Longitude__c);
                    if(asset.Temporary_Latitude__c != null && asset.Temporary_Longitude__c != null){
                        if(newId=='Customer User'){
                            //console.log("dhvbvjbvjsbvjbv",newId)
                            if(asset.IschangedTrue__c>=asset.Rogue_Asset_Day_Limit__c && asset.Rogue_Asset_Day_Limit__c > 0){
                                
                                /*  var popvalue = 'Asset Name: '+ asset.Asset_Name_formula__c +"<br/>"+'Customer ID: '+ CusId +"<br/>"+'Last Connected: '+lstcnt+"<br/>"
                        + 'State of Asset : '+statepallet+"<br/>"+'Current City: '+ asset.Current_City__c +"<br/>"+'Current State: '+ asset.Current_State__c;*/
                            
                            //alert('else above marker');
                            
                            var popvalue = 'Asset Name: '+ asset.Asset_Name_URL__c + "<br/>" + 'Customer ID: '+ CusId +"<br/>"+'Last Connected: '+lstcnt+"<br/>"
                            + 'State of Asset: '+statepallet+"<br/>"+'Current Location Address: '+ asset.Current_Location_Address__c+"<br/>"+'SMART Tracks: '+ asset.Smart_Tracks2__c;
                            
                            // marker = new L.marker([asset.Temporary_Latitude__c,asset.Temporary_Longitude__c]),{icon:MarkerRed}).bindPopup(popvalue).openPopup();
                            marker = new L.marker([asset.Temporary_Latitude__c,asset.Temporary_Longitude__c],{icon:MarkerRed}).bindPopup(popvalue).openPopup(); 
                            
                            markers.addLayer(marker);
                            map.addLayer(markers);
                        }
                            
                            /*  var popvalue = 'Asset Name: '+ asset.Asset_Name_formula__c +"<br/>"+'Customer ID: '+ CusId +"<br/>"+'Last Connected: '+lstcnt+"<br/>"
                        + 'State of Asset : '+statepallet+"<br/>"+'Current City: '+ asset.Current_City__c +"<br/>"+'Current State: '+ asset.Current_State__c;*/
                            
                            //alert('else above marker');
                            else{ 
                                var popvalue = 'Asset Name: '+ asset.Asset_Name_URL__c + "<br/>" + 'Customer ID: '+ CusId +"<br/>"+'Last Connected: '+lstcnt+"<br/>"
                                + 'State of Asset: '+statepallet+"<br/>"+'Current Location Address: '+ asset.Current_Location_Address__c+"<br/>"+'SMART Tracks: '+ asset.	Smart_Tracks2__c;
                                
                                marker = new L.marker([asset.Temporary_Latitude__c,asset.Temporary_Longitude__c]).bindPopup(popvalue).openPopup();
                                markers.addLayer(marker);
                                map.addLayer(markers);
                                
                            }
                        }
                        else{
                            var popvalue = 'Asset Name: '+ asset.Asset_Name_URL__c + "<br/>" + 'Customer ID: '+ CusId +"<br/>"+'Last Connected: '+lstcnt+"<br/>"
                            + 'State of Asset: '+statepallet+"<br/>"+'Current Location Address: '+ asset.Current_Location_Address__c+"<br/>"+'SMART Tracks: '+ asset.smart_tracks__c;
                            
                            marker = new L.marker([asset.Temporary_Latitude__c,asset.Temporary_Longitude__c]).bindPopup(popvalue).openPopup();
                            markers.addLayer(marker);
                            map.addLayer(markers); 
                        }
                    }
                    // alert('else above map marker');
                    
                    
                }	 
            }
            //console.log(!set1.has('Cardinal Glass Hudson')); 
        }
        
        console.log('loadAsset End Time='+new Date().getSeconds());
    },
    validation2 : function(component, event, helper){
        var map = component.get('v.map');
        var tl  = new L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
            maxZoom: 20,
            subdomains:['mt0','mt1','mt2','mt3']
        });
        map.addLayer(tl);
        
        
        
    }  
    
    
})