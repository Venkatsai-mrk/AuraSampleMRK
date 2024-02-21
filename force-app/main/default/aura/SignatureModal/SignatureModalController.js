({
    myAction : function(component, event, helper) {
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
        let formID = component.get("v.formId");
        let recordID = formID.substring(formID.indexOf(';')+0,-30);
        console.log('formID: ',formID);
        console.log('patientId: ',patientId);
        /*To display insert signature img for portal users - Srihari
        var action = component.get("c.getPortalFlag");
        action.setParams({ "formId" :formID,
                          "accId" :patientId});
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
               if(result=='Portal Form'){
                    console.log('portal notes flag: ',result);
                component.set("v.portalFlag",result);
                console.log('portal flag: ',component.get("v.portalFlag"));
                }
            }
            });        
          
        console.log('portal flag:after ',component.get("v.formId"));
        
        helper.formstatus(component, event);
        $A.enqueueAction(action); */
        helper.formstatus(component, event);
    },
    signAndApprove : function(component, event, helper) {
        //Enable box
        component.set("v.openSignatureBox",true);
    },
    saveSignature : function(component, event, helper) {
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        var action = component.get("c.approveForm");
        action.setParams({ "formName" :component.get('v.formName'),
                        "changedFormName" :component.get("v.changedFormName"),
                        "formId" :component.get("v.formId"),
                        "userValues" :JSON.stringify(userValues),
                        "currentLevel" :JSON.stringify(currentLevel),
                        "code":component.get("v.code"),
                        "comments":component.get("v.comment")});
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