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
        console.log('result',result);
        console.log('defaultApprovalLevels in care plan approval',defaultApprovalLevels);
        console.log('approvedValues in care plan approval',approvedValues);
        
        for(let i in defaultApprovalLevels){
            for(let j in approvedValues){
                if(defaultApprovalLevels[i]['ElixirSuite__Approval_Level__c'] == approvedValues[j]['ElixirSuite__Approval_Level__c']){
                    approvedValues[j]['ElixirSuite__Approver_Custom_Label__c'] = defaultApprovalLevels[i]['ElixirSuite__Approver_Custom_Label__c'];
                }
            }
        }
 
        component.set("v.approvedValues",approvedValues);//Setting already approved Levels
        //console.log('approvedValues in care plan approval',approvedValues);
        
        let approvedLevels = [];
        for(let idx in approvedValues){
            let approvalLevel = approvedValues[idx]['approvalLevel'];
            if(!$A.util.isUndefinedOrNull(approvalLevel)){      
                approvedLevels.push(parseInt(approvalLevel)); 
            }
        }
        console.log('approvedLevels in care plan approval',approvedLevels);
        let filteredApprovalLevels = [];
        for(let idx in defaultApprovalLevels){
            let savedApprovalLevel = defaultApprovalLevels[idx]['ElixirSuite__Approval_Level__c'];
            if(!approvedLevels.includes(savedApprovalLevel)){
                filteredApprovalLevels.push(defaultApprovalLevels[idx]);
            }
        }
        console.log('filteredApprovalLevels in care plan approval',filteredApprovalLevels);
        if(filteredApprovalLevels.length>0){
            component.set("v.currentLevel",filteredApprovalLevels[0]);//Setting level that needs to be Approved
            component.set("v.filteredApprovalLevels", filteredApprovalLevels);
        }
        console.log('currentLevel in care plan approval',component.get("v.currentLevel"));
    },
    getNotesFlagStatus : function(component){
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