({
    myAction : function(component, event, helper) {
        try{
        var action = component.get("c.fetchApprovalLevelsOnCreate");
        action.setParams({ 'recordTypeName' :component.get('v.formName')});  
           
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            //Show all aproved values on UI
            //SHow value to be approved if Current User is Eligible
            var state = response.getState();
            if (state === "SUCCESS") {  
               
                component.set("v.currentLevel",{});
                 console.log('result new---- '+JSON.stringify(result));
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
        $A.enqueueAction(action);   
        }catch(ex){}
    },
    saveSign : function(component, event, helper) {
        var params = event.getParam('arguments');
        var approvalLevel = component.get('v.currentLevel.ElixirSuite__Approval_Level__c');
        if(typeof approvalLevel !== 'undefined'){
      	helper.saveSignFormApprovalHelper(component, event, params.formId);
        }
    
	}, 
   
})