({
    myAction : function(component, event, helper) {
       // alert('Inside Sign Model');
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        let userId = userValues.UserId;
        let profileId = userValues.ProfileId;
        let roleId = userValues.RoleId;
        let patientId = userValues.PatientId;
        let approvalType = currentLevel.ElixirSuite__Approv__c;
        let allEligibleApprovers = currentLevel.ElixirSuite__Approval_Members__c; /*all Approvers 
                                                                                    are ; separated*/
        let eligibleApprovers = allEligibleApprovers.split(';');
        let isEligible = false;
        switch(approvalType) {
            case 'User':
                isEligible = eligibleApprovers.includes(userId);
              break;
            case 'Profile':
                isEligible = eligibleApprovers.includes(profileId);
              break;
            case 'Role':
                isEligible = eligibleApprovers.includes(roleId);
              break;
            case 'Patient':
                isEligible = eligibleApprovers.includes('Patient');
              break;
          }
        component.set("v.isEligible",isEligible);
    },
    signAndApprove : function(component, event, helper) {
        //Enable box
        component.set("v.openSignatureBox",true);
    },
    
    verifySignature : function(component, event, helper) {
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        var action = component.get("c.verifyForm");
       
        action.setParams({ "formName" :component.get('v.formName'),
                        "changedFormName" :component.get("v.changedFormName"),
                        "formId" :component.get("v.formId"),
                        "userValues" :JSON.stringify(userValues),
                        "currentLevel" :JSON.stringify(currentLevel),
                        "code":component.get('v.code'),
                        "comments":component.get('v.comment')});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.toastHelper('success','Form Verified successfully!');
                //Send component event to run init of Elixir_FormApproval
               // var refreshEvt = component.getEvent("FormSignatureRefresh");
               // refreshEvt.fire();
                helper.closePopup(component);
                component.set('v.signatureId', result.ImgId);
                component.set('v.signedBy', result.signedBy);
                component.set("v.isEligible", false);
                component.set("v.openSignatureBox", false);
                component.set("v.verifiedSuccessfully", true);
            }
            else{
                component.set("v.enableVerify",false);
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    helper.toastHelper('error',errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);   
        component.set("v.enableVerify",true);
    },
    saveSignature : function(component, event, helper) {
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        var action = component.get("c.approveForm");
        var params = event.getParam('arguments');
       // alert('Inside saveSignature '+params.formId);
       
       // alert(' ChangesFormName'+component.get("v.changedFormName"));
      //  alert(' userValues'+ JSON.stringify(userValues) );
      //  alert('currentLevel '+JSON.stringify(currentLevel) );
      //  alert('Code' + params.code);
      //  alert('Comment '+params.comment);
        
        action.setParams({ "formName" :component.get('v.formName'),
                        "changedFormName" :component.get("v.changedFormName"),
                        "formId" :params.formId,
                        "userValues" :JSON.stringify(userValues),
                        "currentLevel" :JSON.stringify(currentLevel),
                        "code":params.code,
                        "comments":params.comment});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.toastHelper('success','Form approved successfully!');
                //Send component event to run init of Elixir_FormApproval
                var refreshEvt = component.getEvent("FormSignatureRefresh");
                refreshEvt.fire();
                helper.closePopup(component)
            }
            else{
                component.set("v.enableVerify",false);
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    helper.toastHelper('error',errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);   
        component.set("v.enableVerify",true);
    },
    cancel : function(component, event, helper) {
        //Disable box
        helper.closePopup(component);
    }
})