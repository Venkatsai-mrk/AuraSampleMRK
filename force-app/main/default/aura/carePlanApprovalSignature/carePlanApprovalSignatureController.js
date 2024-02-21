({
    myAction : function(component, event, helper) {
        var userValues = component.get("v.userValues");
        var currentLevel = component.get("v.currentLevel");
        let userId = userValues.UserId;
        let profileId = userValues.ProfileId;
        let roleId = userValues.RoleId;
        let patientId = userValues.PatientId;

        let approvalType = currentLevel.ElixirSuite__Approver__c;
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
        //let formID = component.get("v.formId");
        //let recordID = formID.substring(formID.indexOf(';')+0,-30);
        //console.log('formID: ',formID);
        //console.log('patientId: ',patientId);
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
        //helper.formstatus(component, event);
    },
    signAndApprove : function(component, event, helper) {
        //Enable box
        component.set("v.openSignatureBox",true);
    },
    saveSignature : function(component, event, helper) {
        if(component.get("v.approvalType") == 'Care Plan'){
            helper.saveSignatureCarePlanType(component, event, helper);
        }
        
    },
    cancel : function(component, event, helper) {
        //Disable box
        helper.closePopup(component);
    }
})