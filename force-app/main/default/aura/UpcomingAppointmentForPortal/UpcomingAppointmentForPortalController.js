({
	doInit : function(component) {
        var action = component.get('c.getAllUpcomingAppointments');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();

				console.log('result '+JSON.stringify(result));
				component.set("v.upcomingAppointmentsList",result);
            }
        });
        $A.enqueueAction(action);
		
var action1 = component.get("c.isEnableAppointment");

        action1.setCallback(this, function(response) {
            var state1 = response.getState();
            if (state1 === "SUCCESS") {
                component.set("v.isEnableAppointment", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
		
	},
    navToMoreAppointments : function(component) {
        var navService = component.find("navigationService");
        let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: "/myappointments"
                }
            }
        navService.navigate(pageReference);
    },
    handleNewAppointment : function() {
        var url = "/" + 'schedule-appointments'; 
        url += "?key=" + 'homePageAppointment';
        var navigateEvent = $A.get("e.force:navigateToURL"); 
        navigateEvent.setParams({ "url": url, "isredirect": true }); 
        navigateEvent.fire();
    },
    cancelAppointment : function(component, event) {
        var selectedAppointmentId = event.target.getAttribute("data-appointment-id");
        component.set("v.selectedAppointmentId",selectedAppointmentId);
        component.set("v.cancelAppointment",true);
    }
})