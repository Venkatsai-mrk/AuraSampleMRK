({
	fireToast : function(state, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": state,
			"type": state,
			"duration":' 1000',
			"message": message
		});
		toastEvent.fire();
    },
	sendCallOut : function(component){
        var action = component.get('c.calloutMethod');
        action.setParams({
            claimId : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                this.fireToast(state,'Your request has been submitted');
                 this.refreshViewIn2Sec();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.fireToast(state,errors[0].message);
                    }
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
	},
	refreshViewIn2Sec : function(){
		window.setTimeout($A.getCallback(function() {
			var dismissActionPanel = $A.get("e.force:closeQuickAction");
			dismissActionPanel.fire();
			$A.get('e.force:refreshView').fire();
			}), 2000);
	}
})