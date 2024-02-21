({
    helperMethod : function(component, event, helper) {
        let approvalLevelValues = {'approver' : '','approverList' : []}; 
        component.set("v.approvalLevelValues",approvalLevelValues);
        component.set("v.loaded",false);
        console.log('emailSettingName is  '+component.get("v.emailSettingName"));
        var action = component.get('c.fetchExistingPatientPortalApprovalRecord');        
        action.setParams({
            "emailSettingName": component.get("v.emailSettingName")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('All Setup Key '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().isRecAvailable){
                    component.set("v.errorForApprovalLevelIndex",false);
                    if(!$A.util.isEmpty(response.getReturnValue().records)){
                        var record  = response.getReturnValue().records;
                        var approvalTree =  component.get("v.approvalLevelValues");
                        component.set("v.recordID",record[0].Id);
                        console.log('records is '+JSON.stringify(record));
                        console.log('rec id is '+component.get("v.recordID"));
                        var approvalMemeber = record[0].ElixirSuite__Approval_Members__c;
                        var allApproverMembers = approvalMemeber.split(';');
                        approvalTree.approver = record[0].ElixirSuite__Approver__c;
                        component.set("v.dropdownLabel",'Select '+approvalTree.approver);
                        component.set("v.setupKeySelected",approvalTree.approver);
                        //component.set("v.ApproverCustomLabel",record[0].ElixirSuite__Approver_Custom_Label__c);
                        
                        /*****************CREATE MAP OF SETUP KEY ***********************/
                        var mapOfsetUp = {};
                        var allValues = response.getReturnValue().keylist;
                        if(!$A.util.isUndefinedOrNull(allValues)){
                            for (var i = 0; i < allValues.length; i++) {
                                mapOfsetUp[allValues[i].Id] = allValues[i].Name;                            
                            }
                        }
                        
                        component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);                        
                        /*****************************************************************/
                        
                        
                        /*****************DEFINE ROLE/PROFILE/USER VISIBILITY ************/
                        var masterTree = component.get("v.setupKeyWrapper");
                        if(approvalTree.approver.includes('User')){
                            masterTree.isUserSelected = true;
                            component.set("v.isSetUpKeySelected",false);
                        }
                        else if(approvalTree.approver.includes('Profile')){
                            masterTree.isProfileSelected = true;
                            component.set("v.isSetUpKeySelected",false);
                        }
                            else if(approvalTree.approver.includes('Role')){
                                masterTree.isRoleSelected = true;
                                component.set("v.isSetUpKeySelected",false);
                            }
                        component.set("v.setupKeyWrapper",masterTree); 
                        /*****************************************************************/
                        approvalTree.approverList = JSON.parse(record[0].ElixirSuite__Approver_List__c);
                        var opts= [];
                        var allValues = approvalTree.approverList;
                        var count = 0;
                        var dropDownSelectedValues = [];
                        var isDisabled = false;
                       /* if(allApproverMembers.length==5){
                            isDisabled = true;
                        }*/
                         if(allApproverMembers.length>=1){
                              component.set("v.isSetUpKeySelected",true);
                         }
                        for (var i = 0; i < allValues.length; i++) {
                            if(allApproverMembers.includes(allValues[i].value)){
                                count++;
                                opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : true,
                                           'disabled' :isDisabled });
                                dropDownSelectedValues.push(allValues[i].value);
                            }
                            else {
                                opts.push({'label':allValues[i].label,'value' : allValues[i].value,'selected' : false,
                                           'disabled' :isDisabled});
                            }
                        }
                        component.set("v.dropDownSelectedValues", dropDownSelectedValues);
                        component.set("v.dropDownOptions", opts);
                        component.set('v.searchString', count + ' options selected');
                        console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		
                        component.set("v.approvalLevelValues", approvalTree);
                        component.set("v.isdisAbled", true);
                        component.set("v.isApprovalLevelAdded", true); 
                        component.set("v.enableEditpencilIcon", true);
                        component.set("v.enableSaveButton", false);
                    }
                }
                
            }
            else if (state === "ERROR") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
	buildAttributeWrapper : function(component, event, helper) {
        let mapOfSetUpKey = {'User' : 'allUsers', 'Role':'allUserRoles','Profile':'allProfiles'};
        
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : false,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false,
                          'lstOfPatient' : 'Patient' , 'isPatientselected' : false,
                          'setupKeyMap' : mapOfSetUpKey};
        component.set("v.setupKeyWrapper",masterTree);
        
        
        
    },
    
    arrangelevaluesForSetupKey : function(component, event, helper,resp,setupKey) {
        var masterTree = component.get("v.setupKeyWrapper");
        switch (setupKey) {
            case 'User':
                
                masterTree.lstOfUser = resp.allUsers;
                masterTree.isUserSelected = true; 
                component.set("v.isSetUpKeySelected",false);
                break;
                
            case 'Role':
                
                masterTree.lstofRole = resp.allUserRoles;
                masterTree.isRoleSelected = true;
                component.set("v.isSetUpKeySelected",false);
                break;
                
            case 'Profile' : 
                
                masterTree.lstOfProfile = resp.allProfiles;
                masterTree.isProfileSelected = true;
                component.set("v.isSetUpKeySelected",false);
                break;
        }
        component.set("v.setupKeyWrapper",masterTree);
    },
    fetchDropdownValues :  function(component){
        var param = component.get("v.setupKeySelected");
        var masterTree = component.get("v.setupKeyWrapper").setupKeyMap;
        var setupKey = component.get('v.setupKeyWrapper');
        var action = component.get( 'c.fetchOptions_SetupKey' );
        component.set("v.loaded",false);
        
        action.setParams({
            "setUpKey": param
        });
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                console.log('mpl options '+JSON.stringify(response.getReturnValue()));
                console.log('mpl options set'+ JSON.stringify(response.getReturnValue()[masterTree[param]]));	
                component.set("v.mapOfSetUpKey_MarkupAttibute", response.getReturnValue()[masterTree[param]]);
                var opts = [];
                var mapOfsetUp = {};
                var allValues = response.getReturnValue()[masterTree[param]];
                for (var i = 0; i < allValues.length; i++) {
                    mapOfsetUp[allValues[i].Id] = allValues[i].Name;
                    opts.push({'label':allValues[i].Name,'value' : allValues[i].Id});
                }
                component.set("v.mapOfSetUpKey_MarkupAttibute", mapOfsetUp);
                component.set("v.dropDownOptions", opts);
                console.log('mpl options set'+ JSON.stringify(component.get("v.dropDownOptions")));		  
                
            } 
            else if (state === "ERROR") {
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
                
            }
            
        });
        $A.enqueueAction(action);
    },
    setUpKeyNotSelected : function(component, event, helper) {
        var approver = component.get("v.setupKeySelected");
        if(approver == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Approver is Mandatory",
                "message": "Please select Approver",
                "type" : "error"
            });
            toastEvent.fire();

        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": component.get("v.setupKeySelected") +" is Mandatory",
                "message": "Please select "+ component.get("v.setupKeySelected") +"  or choose Approver as None",
                "type" : "error"
            });
            toastEvent.fire();

        }
       
    },
    approverNotSelected : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "APPROVER IS MANDATORY",
            "message": "Please select approver first",
            "type" : "error"
        });
        toastEvent.fire();
    },
    setSetupKeyName : function(component, event, helper) {
        var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
        var mapOfselectedApproversIdAndName = component.get("v.mapOfSetUpKey_MarkupAttibute");
        if(!$A.util.isUndefinedOrNull(mapOfselectedApproversIdAndName)){
            var nameArray = [];
            for(let rec in selectedApprovers){
                nameArray.push(mapOfselectedApproversIdAndName[selectedApprovers[rec]]);
            }
            component.set("v.dropDownSelectedValueToName",nameArray);
            console.log('name array  '+nameArray); 
        }
    }
})