({
    buildAttributeWrapper : function(component, event, helper) {
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : false,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false};
        component.set("v.setupKeyWrapper",masterTree);
        var mapOfApprovalUnit = {'CarePlan':'carePlanApprovalCount',
                                 'Prescription' : 'prescriptionApprovalCount',
                                 'LabOrder' : 'laborderApprovalCount'};
        component.set("v.mapOfApprovalUnit",mapOfApprovalUnit);
    },
    arrangelevaluesForSetupKey : function(component, event, helper,resp,setupKey) {
        var masterTree = component.get("v.setupKeyWrapper");
        switch (setupKey) {
            case 'User':
                
                masterTree.lstOfUser = resp.allUsers;
                masterTree.isUserSelected = true; 
                break;
                
            case 'Role':
                
                masterTree.lstofRole = resp.allUserRoles;
                masterTree.isRoleSelected = true;
                break;
                
            case 'Profile' : 
                
                masterTree.lstOfProfile = resp.allProfiles;
                masterTree.isProfileSelected = true;
                break;
        }
        component.set("v.setupKeyWrapper",masterTree);
    },
    initHelperCallback : function(component, event, helper) {
        component.set("v.loaded",false);
        var action = component.get('c.fetchApprovalLevelCount');      
        
        action.setParams({
            "selectedApprovalUnit": component.get("v.selectedApprovalUnit")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                
                console.log('resp 1234'+JSON.stringify(response.getReturnValue()));
                if(!$A.util.isUndefinedOrNull(response.getReturnValue())){ 
                    var mapOfApprovalUnit =  component.get("v.mapOfApprovalUnit");
                    var numberOfApprovalLevels = response.getReturnValue()[mapOfApprovalUnit[component.get("v.selectedApprovalUnit")]];
                    if(!$A.util.isUndefinedOrNull(numberOfApprovalLevels)){   
                        if(numberOfApprovalLevels<=5){                                                    
                            var arr = [];
                            for(let i=1;i<=numberOfApprovalLevels;i++){
                                var isOpen = false;
                                if(i==1){
                                    isOpen = true;
                                }
                                else {
                                    isOpen = false;
                                }
                                let tabSetRecordInstance = {'label' : 'Level '+i.toString(),'Id' : i.toString(),'isOpen':isOpen,'tabIndex':i};
                                arr.push(tabSetRecordInstance);
                            }
                            console.log('arr'+JSON.stringify(arr));
                            component.set("v.tabs",arr);
                            component.set("v.isInit",false);
                        }
                        else {
                            helper.approvalLevelsNotValid(component, event, helper);
                        }
                    }
                    else {
                        helper.noCustomSettingsDefinedForFormApprovalMessage(component, event, helper);
                    }
                }
                else {
                    helper.noCustomSettingsDefinedForFormApprovalMessage(component, event, helper);
                }
              
            } 
            else if (state === "ERROR") {
                  component.set("v.loaded",true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                      component.set("v.loaded",true);
                    console.log("Unknown error");
                }
                
                
            }
            
        });
        $A.enqueueAction(action);
    },
    noCustomSettingsDefinedForFormApprovalMessage : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "APPROVAL LEVEL NOT DEFINED IN CUSTOM SETTING!",
            "message": "Please define approval levels first!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    approvalLevelsNotValid : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "MAXIMUM 5 LEVEL OF APPROVAL IS ALLOWED!",
            "message": "Please define approval level less or equal to 5.",
            "type" : "error"
        });
        toastEvent.fire();
    } 
    
})