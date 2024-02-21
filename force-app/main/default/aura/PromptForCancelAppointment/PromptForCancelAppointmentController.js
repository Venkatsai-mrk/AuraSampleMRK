({
	doInit : function(component, event, helper) {
        console.log('cancelAppointment value '+component.get("v.cancelAppointment"));
    },
    handleYes : function(component, event, helper) {
		var action = component.get('c.cancelAppointment');
        action.setParams({
            "selectedAppointmentId" : component.get("v.selectedAppointmentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                console.log('Success');
                component.set("v.cancelAppointment",false);
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
	},
    handleNo : function(component, event, helper) {
		component.set("v.cancelAppointment",false);
	}
})