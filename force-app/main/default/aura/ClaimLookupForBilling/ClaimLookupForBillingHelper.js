({
    searchWithPatientParam : function(component, event, helper) {
        var action = component.get("c.claimLstWithFilter");
        action.setParams({
            "searchKeyWord" : component.get("v.selectRecordName"),
            "patientId" : component.get("v.patientId")
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                
                component.set("v.searchRecords", response.getReturnValue());
                
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