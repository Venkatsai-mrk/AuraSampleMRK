({
    helperMethod : function(component, event, helper) {
        let approvalLevelValues = {'approver' : '','approverList' : []}; 
        component.set("v.approvalLevelValues",approvalLevelValues);
        component.set("v.loaded",false);
        console.log('index is  '+JSON.stringify(component.get("v.index")));
        console.log('ApprovalFor is  '+JSON.stringify(component.get("v.ApprovalFor")));
        var action = component.get('c.fetchExistingApprovalRecord');
		     
        action.setParams({
            "approvalLevel": component.get("v.index"),
            "ApprovalFor" : component.get("v.ApprovalFor")
        });    
       
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('All Setup Key '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().isPreviousRecAvailable){
                    component.set("v.errorForApprovalLevelIndex",false);
                    if(!$A.util.isEmpty(response.getReturnValue().records)){
                        var record  = response.getReturnValue().records;
                        var approvalTree =  component.get("v.approvalLevelValues");
                        component.set("v.recordID",record[0].Id);
                        console.log('recordID'+ component.get("v.recordID"));
                        console.log('rec for pre  '+JSON.stringify(record));
                        console.log('rec id pre populated  '+component.get("v.recordID"));
                        var approvalMemeber = record[0].ElixirSuite__Approval_Members__c;
                        var allApproverMembers = approvalMemeber.split(';');
                        approvalTree.approver = record[0].ElixirSuite__Approver__c;
                        component.set("v.dropdownLabel",'Select '+approvalTree.approver);
                        component.set("v.setupKeySelected",approvalTree.approver);
                        component.set("v.ApproverCustomLabel",record[0].ElixirSuite__Approver_Custom_Label__c);
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
                        if(allApproverMembers.length==5){
                            isDisabled = true;
                        }
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
                else {
                    
                    if(component.get("v.index")!=1){
                        let indexLevel = JSON.parse(JSON.stringify(component.get("v.index")));
                        component.set("v.indexLevelNotDefined", (indexLevel-1).toString()); 
                        component.set("v.errorForApprovalLevelIndex",true);
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
        
        /*let masterTree = {'lstOfUser' : [], 'isUserSelected' : false,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false,
                          'lstOfPatient' : 'Patient' , 'isPatientselected' : false,
                          'setupKeyMap' : mapOfSetUpKey};*/
        
        let masterTree = {'lstOfUser' : [], 'isUserSelected' : false,
                          'lstOfProfile' : [],'isProfileSelected' : false,
                          'lstofRole' : [],'isRoleSelected' : false,
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
        
    },
    approverNotSelected : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Approver is mandatory",
            "message": "Please select approver first",
            "type" : "error"
        });
        toastEvent.fire();
    },
    setUpKeyNotSelected : function(component, event, helper) {
        var approver = component.get("v.setupKeySelected");
        if(approver == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Approver is mandatory",
                "message": "Please select approver",
                "type" : "error"
            });
            toastEvent.fire();

        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": component.get("v.setupKeySelected") +" is mandatory",
                "message": "Please select "+ component.get("v.setupKeySelected") +"  or choose approver as none",
                "type" : "error"
            });
            toastEvent.fire();

        }
       
    },
    openValuesForPatient : function(component, event, helper) {
        
    },
    CheckPrevLevelBeforeUpdate : function(component, event, helper) {
        var action = component.get( 'c.checkUpdateLegitimacy' );
        console.log("index value befor update"+component.get("v.index"))
        action.setParams({
             "approvalLevel": component.get("v.index"),
             "ApprovalFor" : component.get("v.ApprovalFor")
            
         });        
         action.setCallback(this, function(response) { 
             var state = response.getState();
             if (state === "SUCCESS") {
                 var res= response.getReturnValue();
                 //This if bock will run if user operating on last level
                 if(res){
                         var validity = component.find("field").get("v.validity");
                         if(validity.valid){
                             //This if block will run if user updating last level
                         if(component.find("field").get("v.value") != 'None'){
                         if(component.get("v.isSetUpKeySelected")){
                             component.set("v.loaded",false);
                             console.log('selected for update '+component.get('v.dropDownSelectedValues')); 
                             helper.setSetupKeyName(component, event, helper);
                             var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
                             var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions")};
                             console.log('rec id update  '+component.get("v.recordID"));
                             var action = component.get('c.updateApprovalProcess');        
                             action.setParams({
                                 approver :  component.get("v.approvalLevelValues").approver,
                                 approvalLevel : component.get("v.index"),
                                 selectedApprovers : selectedApprovers.join(';'),
                                 dropDownOptions : JSON.stringify(dropDownOptions),
                                 ApprovalFor : component.get("v.ApprovalFor"),
                                 recordId : component.get("v.recordID"),
                                 approverNames : component.get("v.dropDownSelectedValueToName").join(';'),
                                 ApproverCustomLabel : component.get("v.ApproverCustomLabel")
                             });        
                             action.setCallback(this, function(response) { 
                                 var state = response.getState();
                                 if (state === "SUCCESS") {
                                     component.set("v.loaded",true);
                                     console.log('id updated is '+response.getReturnValue());
                                     component.set("v.isdisAbled", true);
                                     component.set("v.isApprovalLevelAdded",true);
                                     component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                                     component.set("v.enableEdit", false);
                                    /* var toastEvent = $A.get("e.force:showToast");
                                     toastEvent.setParams({
                                         "title": "APPROVAL LEVEL "+ component.get("v.approvallevelIndexAfterSave") +" UPDATED !",
                                         "message": "APPROVAL LEVEL UPDATED!",
                                         "type" : "success"
                                     });
                                     toastEvent.fire();*/
                                     var toastEvent = $A.get("e.force:showToast");
                                     toastEvent.setParams({
                                         "title": "",
                                         "message": "Approval level updated",
                                         "type" : "success"
                                     });
                                     toastEvent.fire();
                                     component.set("v.errorForApprovalLevelIndex",false);
                                     helper.buildAttributeWrapper(component, event, helper);  
                                     helper.helperMethod(component, event, helper);
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
                         }
                         else {
                             helper.setUpKeyNotSelected(component, event, helper);
                         }
                         }
                         //Below else block will run if user delete last level
                         else{
                             var action1 = component.get('c.deleteApprovalLevel');        
                             action1.setParams({
                                 recordId : component.get("v.recordID")
                             });        
                             action1.setCallback(this, function(response) { 
                                 var state = response.getState();
                                 if (state === "SUCCESS") {
                                     component.set("v.loaded",true);
                                     component.set("v.isdisAbled", false);
                                     component.set("v.isApprovalLevelAdded",true);
                                     component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                                     component.set("v.ApproverCustomLabel","");
                                     //Starting here to make the post deletion screen editable
                                     component.set("v.enableEdit",false);
                                     component.set("v.lastLevelDeleted",true);
                                    component.set("v.enableEditpencilIcon",false);
                                     // Ending here to make the post deletion screen editable
                                    /* var toastEvent = $A.get("e.force:showToast");
                                     toastEvent.setParams({
                                         "title": "APPROVAL LEVEL "+ component.get("v.approvallevelIndexAfterSave") +" SAVED!",
                                         "message": "APPROVAL LEVEL SAVED",
                                         "type" : "success"
                                     });
                                     toastEvent.fire();*/
                                     var toastEvent = $A.get("e.force:showToast");
                                     toastEvent.setParams({
                                         "title": "",
                                         "message": "Approval level saved",
                                         "type" : "success"
                                     });
                                     toastEvent.fire();
                                     component.set("v.errorForApprovalLevelIndex",false);
                                     component.set("v.enableSaveButton",true);
                                     helper.buildAttributeWrapper(component, event, helper);  
                                     helper.helperMethod(component, event, helper);
     
                                 }
                             });
                             $A.enqueueAction(action1);
                         } //meghna ends
                     }
                         else {
                             helper.approverNotSelected(component, event, helper);  
                     }
                 }
                 //Below else block will run if User operating on previous levels. 
                   else{
                     var validity = component.find("field").get("v.validity");
                     if(validity.valid){
                     //Below If block will run if user update previous levels
                     if(component.find("field").get("v.value") != 'None'){
                     if(component.get("v.isSetUpKeySelected")){
                         component.set("v.loaded",false);
                         console.log('selected for update '+component.get('v.dropDownSelectedValues')); 
                         helper.setSetupKeyName(component, event, helper);
                         var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
                         var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions")};
                         console.log('rec id update  '+component.get("v.recordID"));
                         var action = component.get('c.updateApprovalProcess');        
                         action.setParams({
                             approver :  component.get("v.approvalLevelValues").approver,
                             approvalLevel : component.get("v.index"),
                             selectedApprovers : selectedApprovers.join(';'),
                             dropDownOptions : JSON.stringify(dropDownOptions),
                             ApprovalFor : component.get("v.ApprovalFor"),
                             recordId : component.get("v.recordID"),
                             approverNames : component.get("v.dropDownSelectedValueToName").join(';'),
                             ApproverCustomLabel : component.get("v.ApproverCustomLabel")
                         });        
                         action.setCallback(this, function(response) { 
                             var state = response.getState();
                             if (state === "SUCCESS") {
                                 component.set("v.loaded",true);
                                 console.log('id updated is '+response.getReturnValue());
                                 component.set("v.isdisAbled", true);
                                 component.set("v.isApprovalLevelAdded",true);
                                 component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                                 component.set("v.enableEdit", false);
                               /*  var toastEvent = $A.get("e.force:showToast");
                                 toastEvent.setParams({
                                     "title": "APPROVAL LEVEL "+ component.get("v.approvallevelIndexAfterSave") +" UPDATED !",
                                     "message": "APPROVAL LEVEL UPDATED!",
                                     "type" : "success"
                                 });
                                 toastEvent.fire();*/
                                  var toastEvent = $A.get("e.force:showToast");
                                 toastEvent.setParams({
                                     "title": "",
                                     "message": "Approval level updated",
                                     "type" : "success"
                                 });
                                 toastEvent.fire();
                                 component.set("v.errorForApprovalLevelIndex",false);
                                 helper.buildAttributeWrapper(component, event, helper);  
                                 helper.helperMethod(component, event, helper);
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
                     }
                     else {
                         helper.setUpKeyNotSelected(component, event, helper);
                     }
                     }
                     //Below else will run if user trying to delete previous levels
                      else{
                        
                          var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "Updation denied!",
                         "message": "Only the last approval level can be deleted",
                         "type" : "ERROR"
                     });
                     toastEvent.fire();
                          
                     } //meghna ends
                 }
                     else {
                          helper.approverNotSelected(component, event, helper);  
                         }
                 
                 }
             }
                 
             
         });
         $A.enqueueAction(action);
    }
})