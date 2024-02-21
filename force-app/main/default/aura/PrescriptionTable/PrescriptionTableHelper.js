({
    fetchPrescriptionOrders: function(component, event, helper) {
        const action = component.get("c.getPrescriptionOrders");

        console.log('prescriptionTable accountId : ',  component.get("v.accountId"));
        action.setParams({accountId : component.get("v.accountId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                response.getReturnValue().forEach(i => {
                    i.createdByName = i.CreatedBy.Name;
                });

                component.set("v.prescriptionOrders", response.getReturnValue());
                console.log("prescriptionOrders", component.get("v.prescriptionOrders"));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})