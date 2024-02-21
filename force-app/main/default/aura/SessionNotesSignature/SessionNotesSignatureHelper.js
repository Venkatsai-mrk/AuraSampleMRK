({
	closePopup : function(component) {
        component.set("v.openSignatureBox",false);
        component.set("v.code",'');
        component.set("v.comment",'');
    },
    toastHelper : function(type, message) {
        let toastParams = {
            title: type.toUpperCase(),
            message: message,
            type: type
        };
        // Fire toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})