({
	navigateToPortalHomePage: function(component) {
        var navService = component.find("navigationService");
        let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: "/"
                }
            }
        navService.navigate(pageReference);
    },
	getPatientId: function(component) {
	var action = component.get("c.getPatientId");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var patientID = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(patientID)){
                    component.set("v.portalAccountId",patientID);
                }
            }
        });
		$A.enqueueAction(action); 
	},
    getScheduleZoomMeetingValue: function(component) {
	var action = component.get("c.enableScheduleZoomMeeting");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('enableScheduleZoomMeeting'+response.getReturnValue());
                component.set("v.enableScheduleZoomMeeting", response.getReturnValue());
            }
        });
		$A.enqueueAction(action); 
	},
    getConflictRoom:function(component, locId,praId,message) {
         var action = component.get("c.getNextAvailableSlot");
        action.setParams({
            'locationId' : locId,
            'practitonerId' : praId,
            'roomId' : (component.get("v.selectedRoomRecord")).value
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var res = response.getReturnValue();
                 var toastEvent1 = $A.get("e.force:showToast");
                            toastEvent1.setParams({
                                "title": message,
                                "message": 'The next available time for the room would be on: '+res,
                                "type" : "error"
                            });
                toastEvent1.fire();   
            }
                
        });
        $A.enqueueAction(action);
    }
})