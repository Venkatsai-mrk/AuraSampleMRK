({
    getPatientId: function (component, event, helper) {
        var action = component.get("c.getPatientId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var patientID = response.getReturnValue();
                console.log('patientID: ' + patientID);
                if (!$A.util.isUndefinedOrNull(patientID)) {
                    component.set("v.portalAccountId", patientID);
                    console.log('Value of portalAccountId:', component.get("v.portalAccountId"));
                    helper.getAppointmentTypeForPortal(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchAppointmentType : function(component,event,helper) {
        
        var today = new Date();
        
        // LX3-9468
        var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var currentDate = todayDate;
        var nextDate = new Date(currentDate);
        nextDate.setDate(nextDate.getDate() + 7);
                
        var action = component.get("c.getAppointmentType");
        
        action.setParams({ practName :  component.get("v.pracId"),
                          locName : component.get("v.locId"),
                          startDate: component.get("v.startDate"),
                          endDate: nextDate.toISOString()
                         });      
          
        action.setCallback(this,function(response) {
            var minDays;
            var maxDays;
            var state = response.getState();
                        if (state === "SUCCESS") {
                var result = response.getReturnValue();                
minDays = parseInt(result.minDays);
                maxDays = parseInt(result.maxDays);
                console.log('maxDays '+maxDays);
                if(parseInt(maxDays) != 0){
                 component.set("v.maxDateAvail", true);       
                }
                
                var minDate = new Date(currentDate);
                minDate.setDate(minDate.getDate() + minDays);
                component.set("v.minDate", minDate.toISOString());
                var maxDate = new Date(currentDate);
                maxDate.setDate(maxDate.getDate() + maxDays);
                component.set("v.maxDate", maxDate.toISOString());                
                component.set("v.startDate",minDate.toISOString());
                
                var resultData = result.appList;  
                component.set("v.appTypeOptions", resultData);
                                component.set("v.aptTypevalue", resultData[0].value);
                component.set("v.aptTypeLabel", resultData[0].Label);
                            if(component.get("v.portalAccountId")){
                                console.log('Value of portalAccountId2:', component.get("v.portalAccountId"));
                                var portalAppointmentList = result.appTypeOptions;  
                                
                                var options = [];
                                
                                    var appointmentTypes = JSON.parse(portalAppointmentList);
                                    appointmentTypes.forEach(function(appType) {
                                        options.push({ Label: appType.label, value: appType.value });
                                    });
                                
                              //  component.set("v.portalTypeAppList", options);
                                component.set("v.aptTypeLabel", options[0].Label);
                                component.set("v.aptTypevalue", options[0].value);
                            }      
                
                this.setColumnsData(component, component.get("v.startDate"));

                
            }
            
        });
        $A.enqueueAction(action);
        
        
        /*
        var action = component.get("c.getAppointmentType");
         this.setColumnsData(component,today);        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.appTypeOptions", resultData);
                console.log('resultData-- '+JSON.stringify(resultData));
                component.set("v.aptTypevalue", resultData[0]);
                console.log('resultData-- '+component.get("v.aptTypevalue"));
               
                this.fetchData(component, event, helper);
            }
            
        });
        $A.enqueueAction(action);*/
        
    },
    
    getAppointmentTypeForPortal: function(component, event, helper) {
        
        var action = component.get("c.getAppointmentTypePortal");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                var options = [];
                if (result) {
                    var appointmentTypes = JSON.parse(result);
                    appointmentTypes.forEach(function(appType) {
                        options.push({ Label: appType.label, value: appType.value });
                    });
                }
                component.set("v.portalTypeAppList", options);
                console.log('portalTypeAppList in portal: ' + JSON.stringify(component.get("v.portalTypeAppList")));
            }
        });
        $A.enqueueAction(action);
    },
    setColumnsData : function(component,TodayDate) {
        try{
            var today = new Date(TodayDate);
            
            // Get the day, month and year values
            var day = today.getDate();
            var month = today.getMonth() + 1; // Months start from 0, so add 1
            var year = today.getFullYear();
            
            // Format the date as a string in the desired format
            var formattedDate = year + '-' + month + '-' + day;
            console.log('formattedDate '+formattedDate);
            var startDate = new Date(formattedDate);
            
            var endDate = new Date(startDate.getTime() + 6 * 24 * 60 * 60 * 1000); // add 6 days to start date
            
            var finalResult = [];
            var weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            //var month = startDate.getMonth();
            var startMonth = monthNames[startDate.getMonth()];
            var startDay = startDate.getDate();
            var endMonth = monthNames[endDate.getMonth()];
            var endDay = endDate.getDate();
            
            var dateRange = startMonth + ' ' + startDay + ',' + startDate.getFullYear() + ' - ' + endMonth + ' ' + endDay + ',' + endDate.getFullYear();
            
            component.set("v.dateRange", dateRange);
            for (var i = 0; i < 7; i++) {
                var date = new Date(startDate.getTime());
                date.setDate(startDate.getDate() + i);
                var weekDay = weekDays[date.getDay()];
                var finalDate = date.getDate();
                var finalOutput = weekDay + ' ' + finalDate ;
                finalResult.push(finalOutput);
            }
            console.log(' finalResult '+finalResult);
            component.set("v.tableColumns", finalResult);
            this.fetchData(component);
            console.log('tableColumns '+component.get("v.tableColumns"));
        }catch(e){
            alert(e.stack);
        }
        
    },
    updateColumnData: function(component,selectedDate) {
        var startDate = new Date(selectedDate);
        var endDate = new Date(startDate.getTime() + 6 * 24 * 60 * 60 * 1000); // add 6 days to start date
        
        var finalResult = [];
        var weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        //var month = startDate.getMonth();
        var startMonth = monthNames[startDate.getMonth()];
        var startDay = startDate.getDate();
        var endMonth = monthNames[endDate.getMonth()];
        var endDay = endDate.getDate();
        
        var dateRange = startMonth + ' ' + startDay + ',' + startDate.getFullYear() + ' - ' + endMonth + ' ' + endDay + ',' + endDate.getFullYear();
        
        component.set("v.dateRange", dateRange);
        for (var i = 0; i < 7; i++) {
            var date = new Date(startDate.getTime());
            date.setDate(startDate.getDate() + i);
            var weekDay = weekDays[date.getDay()];
            var finalDate = date.getDate();
            var finalOutput = weekDay + ' ' + finalDate ;
            finalResult.push(finalOutput);
        }
        component.set("v.tableColumns", finalResult);
    },
    fetchData: function(component) {
        var currentDate;
        var minDate = component.get("v.minDate");
        var startDate = component.get("v.startDate");
        
        if(minDate > startDate){
          currentDate = minDate;
        }else{
          currentDate = component.get("v.startDate");
        }
        
        
        
        var maxDate = component.get("v.maxDate"); 
        var nextDate;
        nextDate = new Date(currentDate);
        nextDate.setDate(nextDate.getDate() + 7);
        if(component.get("v.maxDateAvail") && maxDate < nextDate.toISOString()){
            nextDate = maxDate; 
            console.log('nextDate inside '+nextDate);
        }else{
            nextDate = nextDate.toISOString();
        }
        var action = component.get("c.workslot");
        action.setParams({ practName :  component.get("v.pracId"),
                          locName : component.get("v.locId"),
                          startDate: currentDate,
                          endDate: nextDate,
                          aptType: component.get("v.aptTypevalue")
                         });
        
        action.setCallback(this,function(response){
var state = response.getState();
            if (state === "SUCCESS") {
            var res = response.getReturnValue();
            var currentDate = component.get("v.startDate");
            console.log('currentdate- '+currentDate);
            var k = [];
            for(var i=0;i<7;i++){
                var nextDate = new Date(currentDate);
                nextDate.setDate(nextDate.getDate() + i);
                var newDate = (nextDate.toISOString()).split('T')[0];
                
                //var nextDate = nextDate1.toISOString();
                                var timeList = res[newDate];
                                for(var tt in timeList){
                    if(k[tt]!=null){
                        let dd = k[tt];
                        dd['day'+i]=timeList[tt];
                        k[tt]=dd;
                    }
                    else{
                        let dd={};
                        dd['day'+i]=timeList[tt];
                        k[tt]=dd;
                    }
                }
                
            }
                        component.set('v.tableData',k);
            
            
            }else if(state === "ERROR"){
                console.log(response.getError());
            }   
        });
        $A.enqueueAction(action,false);
        
    },
    getUrlParameter: function(component, event, helper, paramName) {
        var url = window.location.href;
        console.log('url** '+url);
        var paramStartIndex = url.indexOf('?');
        if (paramStartIndex === -1) return '';
        var paramsString = url.slice(paramStartIndex + 1);
        var params = new URLSearchParams(paramsString);
        return params.get(paramName);
    },
    getPracDataForPortal : function(component, event, helper, paramName) {
        console.log('getPracDataForPortal called 1');
        var today = new Date();
        
        var startDate = today.toISOString();
        component.set("v.startDate",startDate);
        var endDate = new Date(startDate);
        endDate.setDate(endDate.getDate() + 7);
        var action = component.get('c.getPracDataForPortal');
        console.log('paramName in getPracDataForPortal'+paramName);
        console.log('startDate getPracDataForPortal'+startDate);
        console.log('endDate getPracDataForPortal'+endDate.toISOString());
        this.setColumnsData(component,today);
        action.setParams({
            "practitionerId" : paramName,
            "startDate" : startDate,
            "endDate" : endDate.toISOString()
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                console.log('state success');
                var res = response.getReturnValue();
                console.log('res for portal '+JSON.stringify(res));
                if(!$A.util.isUndefinedOrNull(res)){
                    component.set("v.pracName",res[0].practitionerName);
                    component.set("v.locName",res[0].locationName);
                    component.set("v.locId",res[0].locationId);
                    component.set("v.pracId",res[0].practitionerId);
                    component.set("v.specName",res[0].specialityName);
                    
                    
                    console.log('res[0].appointmentType '+res[0].appointmentType);
                    var appointType = res[0].appointmentType;
                    component.set("v.appTypeOptions", appointType);
                    console.log('res[0].appointmentType '+JSON.stringify(appointType[0]));
                    component.set("v.aptTypevalue", appointType[0].value);
                    component.set("v.aptTypeLabel", appointType[0].Label);
                    
                this.fetchData(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);
    },

})