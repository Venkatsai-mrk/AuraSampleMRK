({
	showToast : function(component,event,message) {
		
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            type: 'error',
                            message: message
                        });
                        toastEvent.fire();
	}
})