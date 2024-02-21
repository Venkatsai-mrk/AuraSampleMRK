({
	syncChargesHelper : function(component, event, helper) {
        
        
        var action = component.get("c.syncCharges");
        action.setParams({ careId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success for sync charges');
            }
            
        });
        
        $A.enqueueAction(action);
		
	}
})