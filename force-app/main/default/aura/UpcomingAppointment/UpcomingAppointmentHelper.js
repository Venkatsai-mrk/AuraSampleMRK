({
	initialize : function(component, event, helper) {
        
		var action = component.get("c.getData");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.listShow", true);
                component.set("v.eventList", result);
                console.log('test');
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
})