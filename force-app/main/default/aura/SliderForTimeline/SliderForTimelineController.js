({
    doInit : function(component, event, helper) {
        helper.fetchAccountName(component, event, helper) ;
        
        try{
            
            var action = component.get("c.parentMethod_FetchAllData");
            action.setParams({ 
                acctId : component.get("v.recordVal")
            });
            component.find("Id_spinner").set("v.class" , 'slds-show'); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {         
                    var resp = response.getReturnValue();
                    for(let rec in resp.rootDataObject){                    
                        var subData = resp.rootDataObject[rec].data;
                        for(var subchild in subData){
                            //subData[subchild]['style'] = '.onHoverSection .slds-form-element:first-child span.slds-checkbox_faux:first-child { background-color:'+subData[subchild]['ElixirSuite__Object_Color__c']+ '!important; }';
                            subData[subchild]['style'] = 'background-color:'+subData[subchild]['ElixirSuite__Object_Color__c'];
                        }
                    }
                    console.log('parent problem  '+JSON.stringify(resp));
                    component.set("v.allObjectsCopy",JSON.parse(JSON.stringify(resp.rootDataObject)));
                    component.set("v.allObjects",resp.rootDataObject);
                    component.set("v.baseURL",resp.baseURL);
                    console.log('123 '+JSON.stringify(resp.rootDataObject));
                    var rootObjectTree = resp.rootDataObject;
                    component.set("v.mapOfObjectNameAndData",JSON.parse(JSON.stringify(resp.objectNameAndDataMap)));
                    
                    var recordsDataArray = [];
                    var count = 0;
                    var dataTreeParentArray = [];
                    for(let rec in rootObjectTree){                    
                        var subData = rootObjectTree[rec].data;
                        for(var subchild in subData){
                            if(count<=2){
                                subData[subchild]['isObjectOnGraph'] = true;
                            }
                            else {
                                subData[subchild]['isObjectOnGraph'] = false;
                            }                   
                            count++;
                        }
                        //recordsDataArray = recordsDataArray.concat(rootObjectTree[rec].allObjectDataForGraph);                    
                    }
                    console.log('keys set  '+JSON.stringify(rootObjectTree));
                    var recordsDataArray =  helper.setObjectColors(component, event, helper,rootObjectTree);
                    helper.legendUtility(component, event, helper,resp.allObjectsToDisplayOnTimeline);
                    console.log('data tree array   '+JSON.stringify(dataTreeParentArray));  
                    //component.set("v.dataTree",dataTreeParentArray);
                    //var getDataTree =  component.get("v.dataTree");
                    console.log('rec data array '+JSON.stringify(recordsDataArray));
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    
                    // var data =  helper.setJSONData(component, event, helper);
                    var dps1 = [], dps2= [];
                    var h = 0;
                    //<img src="http://img.youtube.com/vi/dKrVegVI0Us/0.jpg" height="30" width="30" >
                    for(var i = 0; i < recordsDataArray.length; i++){ 
                        if(recordsDataArray[i].hasOwnProperty('Subject')){
                        recordsDataArray[i]['Name'] = recordsDataArray[i].Subject;
                    }
                        dps1.push({x: new Date(recordsDataArray[i].CreatedDate), url:  component.get("v.baseURL")+"/"+recordsDataArray[i].Id, y: h*99+3,name:recordsDataArray[i].Name,toolTipcornerRadius:4, toolTipContent: '<div style="background-color:#d2f0f0;"> <b>Created Date:</b>{x}</div><b>Name: </b>{name}</br><a href = {url} target="_blank">More</a>',color:recordsDataArray[i].recordColor,indexLabel:recordsDataArray[i].Name,indexLabelFontSize:12.5});
                        dps2.push({x: new Date(recordsDataArray[i].CreatedDate), y:h*99+3});
                        h+=10;
                    }
                    
                    var firstItem = new Date(dps1[0].x).toISOString().slice(0,10);
                    var lastItem = new Date(dps1[dps1.length-1].x).toISOString().slice(0,10);
                    //   component.set("v.toDate",lastItem);
                    //   component.set("v.fromDate",firstItem);
                    var stockChart = new CanvasJS.StockChart("chartContainer",{
                        animationEnabled: true,
                        zoomEnabled: false,
                        theme: "light2",
                        exportEnabled: true,
                        
                        title:{
                            text:""
                        },
                        charts: [{
                            axisX: {
                                labelFontSize: 12,
                                labelFontColor: "black",
                                crosshair: {
                                    enabled: true,
                                    snapToDataPoint: true
                                },
                                
                            },
                            axisY:{
                                title: "",
                                tickLength: 0,
                                lineThickness:0,
                                gridThickness:0,
                                margin:0,
                                gridColor: '#000000',
                                tickColor: '#000000', 
                                valueFormatString:" " //comment this to show numeric values
                            },
                            toolTip: {
                                borderColor: '#ccc',   //change color
                                cornerRadius: 5,
                            },
                            data: [{
                                type: "scatter",
                                markerType: "circle", 
                                markerSize: 11.5,
                                indexLabelWrap: true,
                                click: function(e){
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": e.dataPoint.url
                                    });
                                    urlEvent.fire();
                                },
                                // toolTipContent: "<b>Created Date:</b>{x}</br><b>Name: </b>{name}</br><a href = {url} target='_blank'>More</a>",
                                dataPoints : dps1
                            }]
                            
                        }],
                        rangeSelector: {
                            enabled: false, //Change it to true to enable Range Selector
                            
                        },
                        rangeChanging: function(e) { 
                            //  component.set("v.fromDate",new Date(stockChart.navigator.slider.get("minimum")).toISOString().slice(0,10));
                            //  component.set("v.toDate",new Date(stockChart.navigator.slider.get("maximum")).toISOString().slice(0,10));
                            
                        },
                        navigator: {
                            verticalAlign: "top",
                            height: 50,
                            dynamicUpdate: true,
                            
                            data: [{
                                indexLabelPlacement: "inside",
                                type: "scatter",
                                dataPoints: dps2
                            }],
                            slider: {
                                handleBorderColor: "red",
                                outlineInverted: true, //Change it to false
                                minimum: new Date(2018, 04, 01),
                                maximum: new Date(2018, 06, 01),
                                maskColor:"#d2f0f0",
                                outlineColor: "#dedede",
                                outlineThickness: 2
                            }
                        }
                    });
                    //console.log('chart var '+JSON.stringify(stockChart));
                    component.set("v.stockChartVariable",stockChart);
                    component.set("v.datapointsArray",recordsDataArray);      
                    stockChart.render();
                    /*copyAxis("chartContainer", "overlayedAxis");
                
                function copyAxis(containerId, destId){
                    var chartCanvas = $("#chartContainer .canvasjs-chart-canvas").get(0);  
                    var destCtx = $("#" + destId).get(0).getContext("2d");
                    
                    var axisWidth = 30;
                    var axisHeight = 335;
                    
                    destCtx.canvas.width = axisWidth;
                    destCtx.canvas.height = axisHeight;
                    
                    destCtx.drawImage(chartCanvas, 0, 0, axisWidth, axisHeight, 0, 0, axisWidth, axisHeight);
                }*/
                    
                }
                else{
                    
                    
                }
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e)
        }
        
        // component.find("Id_spinner").set("v.class" , 'slds-hide');
        
        
    },
    //Added by Ashwini
    navToListView: function(component, event, helper) {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },
    navToAccRecord: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordVal")
        });
        navEvt.fire();
    },
    handleObjectCheckbox :  function(component, event, helper) {
        var getMap_ObjectNameAndData = JSON.parse(JSON.stringify(component.get("v.mapOfObjectNameAndData")));
        var getCurrentKeyList =  component.get("v.uncheckedKeys");
        let listOfIndexedStrings = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        let indexedList = listOfIndexedStrings.split("$");
        let indexParent  = indexedList[0];
        let indexChild = indexedList[1];        
        let parentRoot = component.get("v.allObjects");
        console.log('value  '+JSON.stringify(value));
        // console.log('name  '+JSON.stringify(index));
        if(event.getSource().get("v.checked")){
            helper.removeA(component, event, helper,getCurrentKeyList,value.ElixirSuite__Object_API_Name__c);
            var action = component.get("c.fetchObjectdataIfChecked");
            action.setParams({ 
                acctId : '0011y00000WIXk0AAH',
                lookupField : value.ElixirSuite__Patient_Account_Lookup__c,
                objectName : value.ElixirSuite__Object_API_Name__c
            });
            component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {      
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var resp = response.getReturnValue();
                    //   parentRoot[indexParent].allObjectDataForGraph = resp;
                    parentRoot[indexParent].data[indexChild].isObjectOnGraph =  event.getSource().get("v.checked");
                    component.set("v.allObjects",parentRoot);
                    helper.setDataFromMap(component, event, helper,value);
                    
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && online[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        }
        else {
            getCurrentKeyList.push(value.ElixirSuite__Object_API_Name__c);
            component.set("v.uncheckedKeys",getCurrentKeyList);
            var allObjectDataIndexTree =  parentRoot[indexParent].allObjectDataForGraph;
            var recordsDataArray = [];
            var listOfUncheckedKeys = component.get("v.uncheckedKeys");
            parentRoot[indexParent].data[indexChild].isObjectOnGraph =  event.getSource().get("v.checked");
            component.set("v.allObjects",parentRoot);
            helper.setDataFromMap(component, event, helper,value);
            
        }
    },
    controlGridLinesVisibility : function(component, event, helper) {
        component.set("v.isGridLinesEnabled",event.getSource().get("v.checked"));
        var recordsDataArray =  component.get("v.datapointsArray"); 
        helper.plotDataOnGraphUtility(component, event, helper,recordsDataArray,event.getSource().get("v.checked"));
        
    },
    
    fetchData : function(component, event, helper) {
        try{
            var sDate= new Date(component.get("v.fromDate")).getDay();
            var eDate= new Date(component.get("v.toDate")).getDay();
            //   var startDate = new Date(sDate).toDateString();
            //   var endDate = new Date(sDate).toDateString();
            if(helper.validateDates(component, event, helper)){
                //  component.find("Id_spinner").set("v.class" , 'slds-show');
                var Data = component.get("v.datapointsArray");
                console.log('rec data 1 '+JSON.stringify(Data));
                
                var Result = Data.filter(function(obj) {
                  //  return new Date(obj.CreatedDate).getDay() >= sDate && new Date(obj.CreatedDate).getDay() <= eDate;
                  return (new Date(obj.CreatedDate) >= new Date(component.get("v.fromDate")) || new Date(obj.CreatedDate).toDateString() === new Date(component.get("v.fromDate")).toDateString())
       && (new Date(obj.CreatedDate) <= new Date(component.get("v.toDate")) || new Date(obj.CreatedDate).toDateString() === new Date(component.get("v.toDate")).toDateString());
                    
                });
                console.log('filter'+JSON.stringify(Result));
                var dps1 = [], dps2= [];
                var h = 0;
                for(var i = 0; i < Result.length; i++){ 
                    if(Result[i].hasOwnProperty('Subject')){
                        Result[i]['Name'] = Result[i].Subject;
                    }
                    dps1.push({x: new Date(Result[i].CreatedDate), 
                               url: component.get("v.baseURL")+"//"+Result[i].Id, 
                               y: h*99+3,name:Result[i].Name, 
                               toolTipContent: ' <b>Created Date:</b>{x}</br><b>Name: </b>{name}</br><a href = {url} target="_blank">More</a>', 
                               color:Result[i].recordColor,indexLabel:Result[i].Name,indexLabelFontSize:12.5 ,indexLabelPlacement: "auto"});
                    console.log('dps10'+JSON.stringify(dps1));
                    dps2.push({x: new Date(Result[i].CreatedDate), y:h*99+3});
                    h+=10;
                }
                if(!$A.util.isEmpty(dps1)){
                    var stockChart = new CanvasJS.StockChart("chartContainer",{
                        animationEnabled: true,
                        zoomEnabled: false,
                        theme: "light2",
                        exportEnabled: true,
                        
                        title:{
                            text:""
                        },
                        charts: [{
                            axisX: {
                                labelFontSize: 12,
                                labelFontColor: "black",
                                crosshair: {
                                    enabled: true,
                                    snapToDataPoint: true
                                },
                                
                            },
                            axisY:{
                                title: "",
                                tickLength: 0,
                                lineThickness:0,
                                gridThickness:0,
                                margin:0,
                                gridColor: '#000000',
                                tickColor: '#000000', 
                                valueFormatString:" " //comment this to show numeric values
                            },
                            toolTip: {
                                borderColor: '#ccc',   //change color
                                cornerRadius: 5,
                            },
                            data: [{
                                type: "scatter",
                                markerType: "circle", 
                                markerSize: 11.5,
                                indexLabelWrap: true,
                                click: function(e){
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": e.dataPoint.url
                                    });
                                    urlEvent.fire();
                                },
                                // toolTipContent: "<b>Created Date:</b>{x}</br><b>Name: </b>{name}</br><a href = {url} target='_blank'>More</a>",
                                dataPoints : dps1
                            }]
                            
                        }],
                        rangeSelector: {
                            enabled: false, //Change it to true to enable Range Selector
                            
                        },
                        rangeChanging: function(e) { 
                            //  component.set("v.fromDate",new Date(stockChart.navigator.slider.get("minimum")).toISOString().slice(0,10));
                            //  component.set("v.toDate",new Date(stockChart.navigator.slider.get("maximum")).toISOString().slice(0,10));
                            
                        },
                        navigator: {
                            verticalAlign: "top",
                            height: 50,
                            dynamicUpdate: true,
                            
                            data: [{
                                indexLabelPlacement: "inside",
                                type: "scatter",
                                dataPoints: dps2
                            }],
                            slider: {
                                handleBorderColor: "red",
                                outlineInverted: true, //Change it to false
                                minimum: new Date(2018, 04, 01),
                                maximum: new Date(2018, 06, 01),
                                maskColor:"#d2f0f0",
                                outlineColor: "#dedede",
                                outlineThickness: 2
                            }
                        }
                    });
                    stockChart.render(); 
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                } 
                else {
                    helper.globalFlagToast(component, event, helper,'NOTHING FOUND IN THIS RANGE!', ' ','error'); 
                }
                
                /* var action = component.get("c.tryCallback");
            component.find("Id_spinner").set("v.class" , 'slds-show'); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {         
                  
                }
                else{
                    
                    
                }
            });
            $A.enqueueAction(action);*/
                
                
            }
        }
        catch(e){
            alert(e);
        }
        
        
        
    }
})