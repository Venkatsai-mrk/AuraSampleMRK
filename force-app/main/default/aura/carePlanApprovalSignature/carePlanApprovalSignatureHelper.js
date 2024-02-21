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
        component.set("v.code",'');
        component.set("v.comment",'');
    },
    saveSignatureCarePlanType : function(component, event, helper) {
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        var action = component.get("c.approveOrder");
        action.setParams({
                        "userValues" :JSON.stringify(userValues),
                        "currentLevel" :JSON.stringify(currentLevel),
                        "code":component.get("v.code"),
                        "comments":component.get("v.comment")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('Signature state '+state);
            if (state === "SUCCESS") {

                                
                if (component.get("v.carePlanApprovalInNewMode") && result) {
                    // manually send approval data to parent
                    let carePlanApprovalData = component.get("v.carePlanApprovalData");
                    carePlanApprovalData.push(result);
                    component.set("v.carePlanApprovalData", carePlanApprovalData);

                    let filteredApprovalLevels = component.get("v.filteredApprovalLevels");
                    filteredApprovalLevels.shift();
                    component.set("v.currentLevel", filteredApprovalLevels.length > 0 ? filteredApprovalLevels[0] : {});
                    helper.toastHelper('success','CarePlan approved successfully!');
                    //Send component event to run init of Elixir_OrderApproval
                    helper.closePopup(component);

                }
                else {
                    // Not in new mode, just create approval records and refresh parent
                    let currentParentCarePlanId = component.get("v.parentcarePlanId");
                    let currentApprovedValues = component.get("v.carePlanApprovalData");
                    currentApprovedValues.push(result);
                    
                    let action = component.get("c.attachApprovalDataToParentCarePlan");
                    action.setParams({
                        parentcarePlanId : currentParentCarePlanId,
                        approvedValues : JSON.stringify(currentApprovedValues)
                    });

                    action.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                            helper.toastHelper('success','CarePlan approved successfully!');
                            //Send component event to run init of Elixir_OrderApproval
                            helper.closePopup(component);
    
                            var refreshEvt = component.getEvent("FormSignatureRefresh");
                            refreshEvt.fire();
                        }
                        else {
                            console.log("Failed to save approval data edit mode: ", response.getError());
                        }

                    });

                    $A.enqueueAction(action);
                }
            }
            else{
                component.set("v.disableVerify",false);
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    helper.toastHelper('error',errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);   
    },
})