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
    }
})