({
    myAction : function(component, event, helper) {
        try{
        var action = component.get("c.fetchApprovalLevels");
        action.setParams({ 'recordTypeName' :component.get('v.formName'), // form record type name
                        'formId' :component.get('v.formId')}); //formId is formUniqueId
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
            helper.getNotesFlagStatus(component, event, helper);
        $A.enqueueAction(action);   
        }catch(ex){}
    }
})