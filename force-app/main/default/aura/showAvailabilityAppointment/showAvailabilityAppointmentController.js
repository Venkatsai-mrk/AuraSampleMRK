({
    doInit : function(component, event, helper) {
        helper.getPatientId(component, event, helper);
        var route = component.get("v.route");
        console.log('route ** '+route);
        var paramName = 'key';
        let value = helper.getUrlParameter(component, event, helper, paramName);
        console.log('value URL : ',value);
        console.log('route URL : ',route);
        
        if(value != '' && value != null && route == '' && value.includes(';')){
            console.log('for my care team');
            var urlParam = value.split(';');
            console.log('urlParam '+urlParam[0]);
            console.log('helper getPracDataForPortal called');
            helper.getPracDataForPortal(component, event, helper, urlParam[0]);
            component.set("v.route",'homePageAppointment');
        }else{
            helper.fetchAppointmentType(component,event,helper);
        }
    },
    onAppointmentTypChangeForPortal : function(component, event, helper) {
        
        try{
            component.set("v.aptTypevalue",component.find('appselectPortal').get('v.value'));
            console.log("Selected appselectPortal " + component.find('appselectPortal').get('v.value'));
            var picklistOptions = component.get("v.portalTypeAppList");
            console.log('picklistOptions for portal: '+JSON.stringify(picklistOptions))
            console.log('picklistOptions of EHR: '+JSON.stringify(component.get("v.appTypeOptions")))
            var selectedLabel = '';
            
            for (var i = 0; i < picklistOptions.length; i++) {
                if (picklistOptions[i].value === component.find('appselectPortal').get('v.value')) {
                    selectedLabel = picklistOptions[i].Label;
                    break;
                }
            }
            console.log("Selected Picklist Label fpr portal: " + selectedLabel);
            component.set("v.aptTypeLabel",selectedLabel);
            
        }
        
        catch(e){
            console.log('Error: '+e)
        }
        helper.fetchData(component, event, helper);
    },
    onAppointmentTypChange : function(component, event, helper) {
        
        component.set("v.aptTypevalue",component.find('appselect').get('v.value'));
        var picklistOptions = component.get("v.appTypeOptions");
        
        var selectedLabel = '';
        
        for (var i = 0; i < picklistOptions.length; i++) {
            if (picklistOptions[i].value === component.find('appselect').get('v.value')) {
                selectedLabel = picklistOptions[i].Label;
                break;
            }
        }
        console.log("Selected Picklist Label: " + selectedLabel);
        component.set("v.aptTypeLabel",selectedLabel);
        helper.fetchData(component, event, helper);
        
    },
    handlePrev : function(component) {
        
        component.set("v.showAppointment", true);
         
    },
    handleNext : function(component){
       
        if(!(component.get("v.selectedSlot"))){
          var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Please select a slot to proceed further.",
                "message": " ",
                "type" : "error"
            });
            toastEvent.fire();  
        }else{
           component.set("v.confirmAppointment", true);  
        }
        
    },
    handlePrevButton : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        pageNumber--;
        component.set("v.pageNumber", pageNumber);
        var currentDate = component.get("v.startDate");
        var nextDate = new Date(currentDate);
        nextDate.setDate(nextDate.getDate() - 7);
        component.set("v.startDate", nextDate.toISOString());
        console.log('startDate '+component.get("v.startDate"));
        helper.updateColumnData(component, nextDate.toISOString());
        helper.fetchData(component, event, helper);
    },
    handleNextButton : function(component, event, helper){
        var pageNumber = component.get("v.pageNumber");
        pageNumber++;
        component.set("v.pageNumber", pageNumber);
        var currentDate = component.get("v.startDate");
        var nextDate = new Date(currentDate);
        nextDate.setDate(nextDate.getDate() + 7);
        component.set("v.startDate", nextDate.toISOString());
        console.log('startDate '+component.get("v.startDate"));
        helper.updateColumnData(component, nextDate.toISOString());  
        helper.fetchData(component, event, helper);
    },
    handleDateChange: function(component, event, helper){
        var startDate =  event.getSource().get("v.value");
        var startDateObj = new Date(Date.parse(startDate));
        var today = new Date();
        
        // Get the day, month and year values
        startDateObj.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        // Format the date as a string in the desired format
        if(today.getTime()<=startDateObj.getTime()){
            helper.updateColumnData(component,startDate);
            helper.fetchData(component, event, helper);
        }else{
            console.log('Invalid Start Date: '+startDate);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Start search on date shouldn’t be before today’s date",
                "message": " ",
                "type" : "error"
            });
            toastEvent.fire();
        }
        
    },
    handleSlot : function(component, event){
        console.log('is running for portal');
        console.log('Hututu '+JSON.stringify(event.getSource().get("v.value")));
        console.log('Hututu 1.1 '+JSON.stringify((event.getSource().get("v.value")).startTime));
        component.set("v.selectedSlot" ,event.getSource().get("v.value"));
        component.set("v.selectedDateTime" ,JSON.stringify(event.getSource().get("v.value")));
    
    },
})