({
    segregateSignatureSteps : function(component, helper, result) {
        let userId = result.userId;
        let profileId = result.profileId;
        let roleId = result.roleId;
        let patientId = component.get('v.patientId');
        let userValues = {};
        userValues['UserId'] = userId;
        userValues['ProfileId'] = profileId;
        userValues['RoleId'] = roleId;
        userValues['PatientId'] = patientId;
        component.set("v.userValues",userValues);// Setting user details
        let defaultApprovalLevels = result.defaultApprovalLevels;
        let approvedValues = result.approvedValues;

        for(let i in defaultApprovalLevels){
            for(let j in approvedValues){
                if(defaultApprovalLevels[i]['ElixirSuite__Approval_Level__c'] == approvedValues[j]['ElixirSuite__Approval_Level__c']){
                    approvedValues[j]['ElixirSuite__Approver_Custom_Label__c'] = defaultApprovalLevels[i]['ElixirSuite__Approver_Custom_Label__c'];
                }
            }
        }
        
        component.set("v.approvedValues",approvedValues);//Setting already approved Levels

        let approvedLevels = [];
        for(let idx in approvedValues){
            let approvalLevel = approvedValues[idx]['ElixirSuite__Approval_Level__c'];
            if(!$A.util.isUndefinedOrNull(approvalLevel)){      
                approvedLevels.push(parseInt(approvalLevel)); 
            }
        }
        console.log('approvedLevels '+approvedLevels);
        let filteredApprovalLevels = [];
        for(let idx in defaultApprovalLevels){
            let savedApprovalLevel = defaultApprovalLevels[idx]['ElixirSuite__Approval_Level__c'];
            if(!approvedLevels.includes(savedApprovalLevel)){
                filteredApprovalLevels.push(defaultApprovalLevels[idx]);
            }
        }
        if(filteredApprovalLevels.length>0){
            component.set("v.currentLevel",filteredApprovalLevels[0]);//Setting level that needs to be Approved
        }
    },
    getNotesFlagStatus : function(component, helper, result){
        //To notes on signature modal for portal users - Srihari
        let formID = component.get("v.formId");
        let patientId = component.get("v.patientId");
        var action = component.get("c.getNotesFlag");
        action.setParams({ "formId" :formID,
                          "accId" :patientId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(result=='Portal Form'){
                    component.set("v.notesFlag",false);
                    console.log('portal notes flag: ',result);
                component.set("v.portalFlag",result);
                console.log('portal flag: ',component.get("v.portalFlag"));
                }
            }
        }); 
        $A.enqueueAction(action); 
    }
})