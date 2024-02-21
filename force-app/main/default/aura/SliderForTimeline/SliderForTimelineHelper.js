({
    //Added by Ashwini
    fetchAccountName:function(component, event, helper){
        var action = component.get("c.fetchAccountName");
           action.setParams({ accountId : component.get("v.recordVal") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   
                   console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
                   var records =response.getReturnValue();
                   component.set("v.accName", records);
                   
               }
           
            });
           
           $A.enqueueAction(action);
       },
       filterByDate : function (component, event, helper,menuItems) {
        let today = new Date();
        let dd = today.getDate();
        let mm = today.getMonth();
        let yyyy = today.getFullYear();
        if (dd < 10) {
          dd = '0' + dd;
        }
        if (mm < 10) {
          mm = '0' + mm;
        }
        today = mm + '-' + dd + '-' + yyyy;
        return menuItems.filter((item) => item.CreatedDate > today)
      },
    plotDataOnGraphUtility  :  function(component, event, helper,recordsDataArray,gridLinesEnabled) {   
        var dps1 = [], dps2= [];
        var h = 0;
        for(var i = 0; i < recordsDataArray.length; i++){ 
            dps1.push({x: new Date(recordsDataArray[i].CreatedDate), url: component.get("v.baseURL")+"//"+recordsDataArray[i].Id, y: h*99+3,name:recordsDataArray[i].Name, color:recordsDataArray[i].recordColor,indexLabel:recordsDataArray[i].Name,indexLabelFontSize:12.5 ,indexLabelPlacement: "auto"});
            dps2.push({x: new Date(recordsDataArray[i].CreatedDate), y:h*99+3});
            h+=10;
        }
        
        if(gridLinesEnabled){
            var stockChart =   helper.stockChartVariable(component, event, helper,dps1,dps2);
            stockChart.render();
        }
        else {
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
                    component.set("v.fromDate",new Date(stockChart.navigator.slider.get("minimum")).toISOString().slice(0,10));
                    component.set("v.toDate",new Date(stockChart.navigator.slider.get("maximum")).toISOString().slice(0,10));
                    
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
            
        }
        component.set("v.stockChartVariable",stockChart);
        component.set("v.datapointsArray",recordsDataArray); 
        
        
    },
    removeA  :function(component, event, helper,arr) {
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax= arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    },
    setbooleankeys : function(component, event, helper,rootObjectTree){
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
    },
    updateMapOfKeysForCheckbox : function(component, event, helper,rootObjectTree){
        var getCurrentKeyList =  component.get("v.uncheckedKeys");        
        for(let rec in rootObjectTree){                    
            var subData = rootObjectTree[rec].data;
            for(var subchild in subData){
                if(subData[subchild]['isObjectOnGraph']){
                    getCurrentKeyList.push(value.ElixirSuite__Object_API_Name__c);
                }
            }                    
        }
        component.set("v.uncheckedKeys",getCurrentKeyList);
    },
    setDataFromMap :  function(component, event, helper,value){
        var rootObjectTree =  component.get("v.allObjects");   
        var recordsDataArray = [];
        var getMap_ObjectNameAndData = JSON.parse(JSON.stringify(component.get("v.mapOfObjectNameAndData")));
        var checkedList = [];
        for(let rec in rootObjectTree){                    
            var subData = rootObjectTree[rec].data;
            for(var subchild in subData){
                if(subData[subchild]['isObjectOnGraph']){
                    checkedList.push(subData[subchild].ElixirSuite__Object_API_Name__c);
                }
            }                    
        }
        for(var key in getMap_ObjectNameAndData) {
            if(checkedList.includes(key)){
                recordsDataArray = recordsDataArray.concat(getMap_ObjectNameAndData[key]); 
            }
        }
        console.log('setDataFromMap   '+JSON.stringify(recordsDataArray));
        helper.plotDataOnGraphUtility(component, event, helper,recordsDataArray,component.get("v.isGridLinesEnabled"));
    },
    setObjectColors :  function(component, event, helper,rootObjectTree) {
        var recordsDataArray = [];
        var getMap_ObjectNameAndData = JSON.parse(JSON.stringify(component.get("v.mapOfObjectNameAndData")));
        for(let rec in rootObjectTree){                    
            var subData = rootObjectTree[rec].data;
            for(var subchild in subData){   
                var instanceObjectRecords = getMap_ObjectNameAndData[subData[subchild].ElixirSuite__Object_API_Name__c];
                for(var updateColor in instanceObjectRecords){
                    instanceObjectRecords[updateColor]['recordColor'] = subData[subchild].ElixirSuite__Object_Color__c;
                }
                recordsDataArray = recordsDataArray.concat(instanceObjectRecords);  
            }                   
        }
        component.set("v.mapOfObjectNameAndData",getMap_ObjectNameAndData);
        console.log('map orignal   '+JSON.stringify(component.get("v.mapOfObjectNameAndData")));
        return recordsDataArray;
        
    },
    legendUtility :  function(component, event, helper,objectData) {
        var legendArr = [];
        for(var rec in objectData){
            var cssString = 'background:'+objectData[rec].ElixirSuite__Object_Color__c+';';
            var legendInstance = {'objectName':objectData[rec].Name , 'style' : cssString };
            legendArr.push(legendInstance);
        }
        component.set("v.legendRoot",legendArr);
    },
    stockChartVariable :  function(component, event, helper,dps1,dps2) {
        var stockChart = new CanvasJS.StockChart("chartContainer",{
            animationEnabled: true,
            zoomEnabled: false,
            theme: "light2",
            exportEnabled: true,
            title:{
                text:""
            },
            subtitles: [{
                text: ""
            }],
            charts: [{
                axisX: {
                    labelFontSize: 12,
                    crosshair: {
                        enabled: false,
                        snapToDataPoint: true
                    },
                   
                },
                axisY:{
                    title: "",
                    tickLength: 0,
                    lineThickness:0,
                    margin:0,
                    valueFormatString:" " //comment this to show numeric values
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
                    toolTipContent:  ' <b>Created Date:</b>{x}</br><b>Name: </b>{name}</br><a href = {url} target="_blank">More</a>',
                    dataPoints : dps1
                }]
            }],
            rangeSelector: {
                enabled: false, //Change it to true to enable Range Selector
                
            },
            rangeChanging: function(e) { 
                component.set("v.fromDate",new Date(stockChart.navigator.slider.get("minimum")).toISOString().slice(0,10));
                component.set("v.toDate",new Date(stockChart.navigator.slider.get("maximum")).toISOString().slice(0,10));
                
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
        return stockChart;
    },
    
    validateDates :function(component, event, helper) {
        let fromDate =  component.get("v.fromDate");
        let toDate =  component.get("v.toDate");
        var isValid = true;
        if(!fromDate){
            helper.globalFlagToast(component, event, helper,'PLEASE FILL FROM DATE!', ' ','error');  
            isValid = false;
        }
        else if(!toDate){
            helper.globalFlagToast(component, event, helper,'PLEASE FILL TO DATE!', ' ','error');  
            isValid = false;
        }
        return isValid;
    },
    globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    
})