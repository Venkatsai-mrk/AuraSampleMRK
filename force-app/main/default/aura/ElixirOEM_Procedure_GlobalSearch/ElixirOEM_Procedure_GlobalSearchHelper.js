({
    setDescription : function(component, event, helper,recordId) {
        var action = component.get("c.recordSelected");
        action.setParams({
            "recordId" : recordId,
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {              
                component.set("v.selectRecordDescription", response.getReturnValue()[0].ElixirSuite__Code_Description__c);  
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {  
                    
                }
            }
            component.set("v.LoadingText", false);
        });
        $A.enqueueAction(action);
    }
})