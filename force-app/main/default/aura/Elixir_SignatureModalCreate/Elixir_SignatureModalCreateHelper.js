({
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
    },
    closePopup : function(component) {
        component.set("v.openSignatureBox",false);
       // component.set("v.code",'');
       // component.set("v.comment",'');
    },
    formstatus : function(component, helper) {
        var action = component.get("c.getStatus");
        action.setParams({ 
                        "formId" :component.get("v.formId"),
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                component.set("v.status",result[0].ElixirSuite__Status__c);
                 console.log('result++++',result);
            }  
         });
        $A.enqueueAction(action);                 
    }
    
})