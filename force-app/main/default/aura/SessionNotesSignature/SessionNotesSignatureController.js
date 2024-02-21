({
	myAction : function(component, event, helper) {
        console.log('Action');
        var action = component.get("c.checkValidation");
        action.setParams({"eventid" :component.get('v.eventId')});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('state111',state);
            if (state === "SUCCESS") {
                component.set('v.openSignatureBox',true);
                component.set('v.buttonClicked',true);
            }
            else{
                component.set('v.openSignatureBox',false);
                component.set('v.buttonClicked',false);
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    helper.toastHelper('error',errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
	},
    saveSignature : function(component, event, helper) {
        console.log('eventid',component.get('v.eventId'));
        console.log('code',component.get('v.code'));
        console.log('comments',component.get('v.comment'));
        var action = component.get("c.approveForm");
        action.setParams({"eventid" :component.get('v.eventId'),
                        "code":component.get("v.code"),
                        "comments":component.get("v.comment")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                helper.toastHelper('success','Signed successfully!');
                helper.closePopup(component)
        		component.set('v.buttonClicked',false);
            }
            else{
                component.set('v.buttonClicked',false);
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    helper.toastHelper('error',errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);   
    },
     cancel : function(component, event, helper) {
        //Disable box
        helper.closePopup(component);
        component.set('v.buttonClicked',false);
    }
})