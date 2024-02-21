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
    // formstatus : function(component, helper) {
    //     var action = component.get("c.getStatus");
    //     action.setParams({ 
    //                     "formId" :component.get("v.formId"),
    //                     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //              var result = response.getReturnValue();
    //             component.set("v.status",result[0].ElixirSuite__Status__c);
    //              console.log('result++++',result);
    //         }
    //      });
    //     $A.enqueueAction(action);                 
    // },

    saveSignaturePrescriptionType : function(component, event, helper) {
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
            if (state === "SUCCESS") {

                // assuming new
                // {
                //     "dateOfApproval": "2023-04-19T12:48:55.938Z",
                //     "signatureContentDocumentId": "069N0000002DHmcIAG",
                //     "userName": "User User",
                //     "userRole": "CEO"
                // }
                
                if (component.get("v.prescriptionApprovalInNewMode") && result) {
                    // manually send approval data to parent
                    let prescriptionApprovalData = component.get("v.prescriptionApprovalData");
                    prescriptionApprovalData.push(result);
                    component.set("v.prescriptionApprovalData", prescriptionApprovalData);

                    let filteredApprovalLevels = component.get("v.filteredApprovalLevels");
                    filteredApprovalLevels.shift();
                    component.set("v.currentLevel", filteredApprovalLevels.length > 0 ? filteredApprovalLevels[0] : {});
                    helper.toastHelper('success','Order approved successfully!');
                    //Send component event to run init of Elixir_OrderApproval
                    helper.closePopup(component);

                }
                else {
                    // Not in new mode, just create approval records and refresh parent
                    let currentParentPrescriptionId = component.get("v.parentPrescriptionId");
                    let currentApprovedValues = component.get("v.prescriptionApprovalData");
                    currentApprovedValues.push(result);
                    
                    let action = component.get("c.attachApprovalDataToParentPrescriptionEditMode");
                    action.setParams({
                        parentPrescriptionId : currentParentPrescriptionId,
                        approvedValues : JSON.stringify(currentApprovedValues)
                    });

                    action.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                            helper.toastHelper('success','Order approved successfully!');
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

    saveSignatureLabOrderType : function(component, event, helper) {
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
            if (state === "SUCCESS") {

                // assuming new
                // {
                //     "dateOfApproval": "2023-04-19T12:48:55.938Z",
                //     "signatureContentDocumentId": "069N0000002DHmcIAG",
                //     "userName": "User User",
                //     "userRole": "CEO"
                // }
                
                if (component.get("v.labOrderApprovalInNewMode") && result) {
                    // manually send approval data to parent
                    let labOrderApprovalData = component.get("v.labOrderApprovalData");
                    labOrderApprovalData.push(result);
                    component.set("v.labOrderApprovalData", labOrderApprovalData);

                    let filteredApprovalLevels = component.get("v.filteredApprovalLevels");
                    filteredApprovalLevels.shift();
                    component.set("v.currentLevel", filteredApprovalLevels.length > 0 ? filteredApprovalLevels[0] : {});
                    helper.toastHelper('success','Order approved successfully!');
                    //Send component event to run init of Elixir_OrderApproval
                    helper.closePopup(component);

                }
                else {
                    // Not in new mode, just create approval records and refresh parent
                    let currentLabOrderId = component.get("v.labOrderId");
                    let currentApprovedValues = component.get("v.labOrderApprovalData");
                    currentApprovedValues.push(result);
                    
                    let action = component.get("c.attachApprovalDataToLabOrderEditMode");
                    action.setParams({
                        labOrderId : currentLabOrderId,
                        approvedValues : JSON.stringify(currentApprovedValues)
                    });

                    action.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                            helper.toastHelper('success','Order approved successfully!');
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