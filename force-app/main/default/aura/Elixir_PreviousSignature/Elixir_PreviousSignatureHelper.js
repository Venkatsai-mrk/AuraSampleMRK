({
    approvalLevels : function(component, helper, result) {
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
        let previousApprovedValues = result.previousApprovedValues;
         console.log('previousApprovedValues '+JSON.stringify(previousApprovedValues));        

        for(let i in defaultApprovalLevels){
            for(let j in approvedValues){
                if(defaultApprovalLevels[i]['ElixirSuite__Approval_Level__c'] == approvedValues[j]['ElixirSuite__Approval_Level__c']){
                    approvedValues[j]['ElixirSuite__Approver_Custom_Label__c'] = defaultApprovalLevels[i]['ElixirSuite__Approver_Custom_Label__c'];
                }
            }
        }
        
        for(let i in defaultApprovalLevels){
            for(let j in previousApprovedValues){
                for(let k in previousApprovedValues[j]){
                    if(defaultApprovalLevels[i]['ElixirSuite__Approval_Level__c'] == previousApprovedValues[j][k]['ElixirSuite__Approval_Level__c']){          
                    previousApprovedValues[j][k]['ElixirSuite__Approver_Custom_Label__c'] = defaultApprovalLevels[i]['ElixirSuite__Approver_Custom_Label__c'];
                }
                }  
            }
        }
        
        component.set("v.previousApprovedValues",previousApprovedValues);
        
        
        component.set("v.approvedValues",approvedValues);

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
    }
})