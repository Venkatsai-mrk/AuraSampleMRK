({
    buildAttributeWrapper : function(component, event, helper) {
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : true,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false};
        component.set("v.setupKeyWrapper",masterTree);
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
        let arr = [{'label' : 'Account','value' : 'Account','tabIndex' : '1','isOpen' : true}
                 // {'label' : 'Opportunity','value' : 'Opportunity','tabIndex' : '2','isOpen' : false}
                 ];
        
      component.set("v.tabs",arr);
         component.set("v.loaded",true);
       
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