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
            console.log('Inside currentLevel ',filteredApprovalLevels[0]); 
            component.set("v.currentLevel",filteredApprovalLevels[0]);//Setting level that needs to be Approved
        }
    },
    saveSignFormApprovalHelper : function(component,event,formID){
       // alert('Inside saveSignFormApprovalHelper' + formID);
		const SignModal = component.find('signModalId'); 
                    //console.log('Inside Success Save '+formApp +'  ' +result);
        var comment = component.get('v.comment');
        var code = component.get('v.code');
        SignModal.saveSignature(formID,comment,code);
    }
})