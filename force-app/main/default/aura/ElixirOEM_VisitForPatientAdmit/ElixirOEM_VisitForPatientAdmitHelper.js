({
    callActionAsPromise : function(component, event, helper) {
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get("c.generateAutoNumber");
            action.setParams({
                patientID:  component.get("v.patientID")
                
            });
            action.setCallback(helper, function(actionResult) {
                if (actionResult.getState() === 'SUCCESS') {
                    console.log('actionResult.getReturnValue() '+ JSON.stringify(actionResult.getReturnValue()));
                    resolve({'c':component, 'h':helper, 'r':actionResult.getReturnValue()});
                } else {
                    let errors = actionResult.getError();
                    reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
                }
            });
            $A.enqueueAction(action);
        }));
    }
})