({
    doInit: function (component, event, helper) {
        var url = window.location.href;
        var urlParams = new URL(url);
        var appointmentId = urlParams.searchParams.get("appointmentId");
        component.set("v.appointmentId", appointmentId);
        var action = component.get("c.getEvent");
        action.setParams({
            appointmentId: appointmentId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var appointmentDetails = response.getReturnValue();
                component.set("v.appointment", appointmentDetails);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
         var action1 = component.get("c.isEnablePayNow");
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isEnablePayNow", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
    },

    handleBackToListView: function (component, event, helper) {
        var navService = component.find("navigationService");
        var pageReference = {
            type: "standard__webPage", 
            attributes: {
                url: "/myappointments"
            }
        }
        navService.navigate(pageReference);
    },
    handlePayNow: function (component, event, helper) {
    var EventId = component.get("v.appointmentId");
    var action = component.get("c.PayAppointment");
    action.setParams({
        EventId: EventId
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
},
    handleCancel: function (component, event, helper) {
        component.set("v.cancelAppointment",true);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.cancelAppointment",false);  
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        var action = component.get('c.cancelAppointment');
        action.setParams({
            "selectedAppointmentId" : component.get("v.appointmentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                component.set("v.cancelAppointment",false);  
                var navService = component.find("navigationService");
        var pageReference = {
            type: "standard__webPage", 
            attributes: {
                url: "/myappointments"
            }
        }
        navService.navigate(pageReference);
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
    }
})