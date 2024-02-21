({
    myAction : function(component, event, helper) {
        try{
        var action = component.get("c.fetchApprovalLevels");
        // type of approval(lab/presc)
        let orderId;
        
        switch (component.get("v.approvalType")) {
            
            case 'Care Plan':
                orderId = component.get("v.parentcarePlanId")
                break;

            default:
                break;
        }

        action.setParams({
            'typeOfApproval' : component.get("v.approvalType"),
            'orderId' : orderId
        }); //formId is formUniqueId
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            //Show all aproved values on UI
            //SHow value to be approved if Current User is Eligible
            var state = response.getState();
            if (state === "SUCCESS") {  
                component.set("v.currentLevel",{});
                helper.segregateSignatureSteps(component, helper, result);
            }
            else{
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
            }
        });
            //helper.getNotesFlagStatus(component, event, helper);
        $A.enqueueAction(action);   
        }catch(e){
            alert('error '+e);
        }
    }
})