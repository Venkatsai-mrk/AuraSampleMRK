({
    doInit : function(component, event, helper) {
        if(component.get("v.callClaimSubmit") == true){
            var action = component.get("c.entryPointCallout");
            action.setCallback(this, function(response){
                var state = response.getState();
                var res = response.getReturnValue();
                console.log('ott'+state);
                if(state === "SUCCESS"){      
                    helper.fireToast('SUCCESS','Process Initiated');
                    helper.viewName(component);
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('p0'+JSON.stringify(errors));
                    if (errors) {
                        console.log('o');
                        if (errors[0] && errors[0].message) {
                            helper.fireToast('ERROR',errors[0].message);
                            helper.viewName(component);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
})