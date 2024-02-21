({
    doInit : function(component, event, helper) {
      //  helper.fetchUpcomingAppointmentsData(component, helper);
      
        var action = component.get("c.isEnableAppointment");
        var currentUserTimezone='';
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.isEnableAppointment", returnValue.enableAppointment);
                currentUserTimezone= returnValue.currentUserTimezone;
                console.log('currentUserTimezone: '+JSON.stringify(currentUserTimezone));
                component.set("v.currentUserTimezone", currentUserTimezone);
                component.set("v.enablePayNow", returnValue.enablePayNow);
                helper.fetchAppointmentColumns(component, helper);
                helper.columns(component,event);
                helper.filterList(component);
               
            }
                
        });
        $A.enqueueAction(action);
    },
    handleAppointmentColumnRefreshEvent : function(component, event, helper) {     
        helper.columns(component , event , helper);
   },
    dropdownTriggerClass : function(component) {
        if (component.get("v.isExpanded")) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open ';
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view';
        }
    },
    handleFilterClickExtend : function(component) {
        var isExpanded = !component.get("v.isExpanded");
        component.set("v.isExpanded",isExpanded);
    },
    handleFilterChangeButton : function(component, event, helper) {
        var value = event.target.dataset.filter;
        /*if(value == 'All'){
            component.set("v.isExpanded",!component.get("v.isExpanded"));
            component.set("v.currentFilter",value);
            helper.fetchAllAppointmentsData(component, event, helper);
        }*/
        if(value == 'Upcoming Appointments'){
            component.set("v.isExpanded",!component.get("v.isExpanded"));
            component.set("v.currentFilter",value);
            helper.fetchUpcomingAppointmentsData(component, helper);
        }
        if(value == 'Past Appointments'){
            component.set("v.isExpanded",!component.get("v.isExpanded"));
            component.set("v.currentFilter",value);
            helper.fetchPastAppointmentsData(component, helper);
        }
    },
    
    handleNewAppointment : function() {
        var url = "/" + 'schedule-appointments'; 
        url += "?key=" + 'AppointmentTab';
        var navigateEvent = $A.get("e.force:navigateToURL"); 
        navigateEvent.setParams({ "url": url, "isredirect": true }); 
        navigateEvent.fire();
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var actName = action.name;
        console.log('actName '+actName);
        var selectedAppointmentId = event.getParams().row["Id"];
        console.log('selectedAppointmentId '+selectedAppointmentId);
        if(actName=='Cancel'){
            console.log('actName is Cancel');
            component.set("v.selectedAppointmentId",selectedAppointmentId);
            component.set("v.cancelAppointment",true);
            
        }
        if(actName=='Visit Summary'){
            console.log('Visit summary clicked')
            component.set("v.selectedAppointmentId",selectedAppointmentId);
            helper.generateVisitSummary(component);
        }
        if(actName=='Visit Notes'){
			console.log('Visit Notes clicked')
            component.set("v.selectedAppointmentId",selectedAppointmentId);
            helper.generateVisitNote(component);            
        }
        if (actName === 'Subject') {
            component.set("v.selectedAppointmentId", selectedAppointmentId);
            let navService = component.find("navigationService");
            let pageReference = {
                type: "standard__webPage",
                attributes: {
                    url: "/appointment-details-page?appointmentId=" + selectedAppointmentId

                }
            };
            navService.navigate(pageReference);
        }
        if(actName === 'Pay Now'){
            var action = component.get("c.PayAppointment");
            action.setParams({
                EventId: selectedAppointmentId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var payNowDetails = response.getReturnValue();
                    console.log('payNowDetails: '+JSON.stringify(payNowDetails))
                    if ('Success' in payNowDetails) {
                        var successURL = payNowDetails['Success'];
                        console.log('successURL: '+successURL)
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": successURL
                        });
                        urlEvent.fire();
                    } else if ('Error' in payNowDetails) {
                        var errorMessage = payNowDetails['Error'];
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": errorMessage,
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                } 
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error:", errors[0].message);
                    } else {
                        console.error("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
        
    },
   
})