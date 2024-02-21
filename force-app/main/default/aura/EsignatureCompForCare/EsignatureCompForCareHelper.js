({
	getProfileName : function(component, event, helper) {
		  var action = component.get('c.getProfileName');
        action.setParams({
        });
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var profileName = response.getReturnValue();
                console.log('profileName '+profileName);
                component.set("v.profileName",profileName);
            }
        });
        $A.enqueueAction(action);
	}
})