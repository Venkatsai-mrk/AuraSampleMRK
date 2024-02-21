({
    doInit : function(component, event, helper) {  
        helper.buildAttributeWrapper(component, event, helper);  
        helper.helperMethod(component, event, helper);
    },
    fetchRelatedOptions : function(component, event, helper) {
        if(event.getSource().get("v.value")!='Patient'){
            component.set("v.setupKeySelected",event.getSource().get("v.value"));
            component.set("v.dropdownLabel",'Select '+event.getSource().get("v.value"));
            var action = component.get( 'c.fetchOptions_SetupKey' );
            // component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setParams({
                "setUpKey": event.getSource().get("v.value") 
            });       
            action.setCallback(this, function(response) { 
                var state = response.getState();
                if (state === "SUCCESS") {
                    //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                    console.log('All Setup Key '+JSON.stringify(response.getReturnValue()));
                    component.set("v.dropDownOptions",[]);
                    component.set("v.dropDownSelectedValues",[]);
                    component.set('v.searchString','');
                    component.set('v.isdisAbled',false);
                    helper.buildAttributeWrapper(component, event, helper);  
                    helper.arrangelevaluesForSetupKey(component, event, helper,response.getReturnValue(),
                                                      event.getSource().get("v.value")); 
                    helper.fetchDropdownValues(component);
                    
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
            helper.buildAttributeWrapper(component, event, helper);  
            helper.arrangelevaluesForSetupKey(component, event, helper,'',
                                              event.getSource().get("v.value")); 
        }
        
    },
    proceedWithSaveForApprovalProcess : function(component, event, helper) {
        var validity = component.find("field").get("v.validity");
        if(validity.valid){
            if(component.find("field").get("v.value") != 'None'){
            if(component.get("v.isSetUpKeySelected")){
                component.set("v.loaded",false);
                console.log('selected '+component.get('v.dropDownSelectedValues')); 
                helper.setSetupKeyName(component, event, helper);
                var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
                var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions"),
                                      };
                 console.log('dropDownSelectedValues '+ JSON.stringify(dropDownOptions)); 
                var action = component.get('c.saveApprovalProcess');        
                action.setParams({
                    approver :  component.get("v.approvalLevelValues").approver,
                    approvalLevel : component.get("v.index"),
                    selectedApprovers : selectedApprovers.join(';'),
                    dropDownOptions : JSON.stringify(dropDownOptions),
                    formName : component.get("v.formName"),
                    approverNames : component.get("v.dropDownSelectedValueToName").join(';'),
                    ApproverCustomLabel : component.get("v.ApproverCustomLabel")
                });        
                action.setCallback(this, function(response) { 
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true);
                        console.log(' inserted id is '+response.getReturnValue());
                        component.set("v.isdisAbled", true);
                        component.set("v.isApprovalLevelAdded",true);
                        component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Approval level saved",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        component.set("v.errorForApprovalLevelIndex",false);
                        component.set("v.enableSaveButton",false);
                        helper.buildAttributeWrapper(component, event, helper);  
                        helper.helperMethod(component, event, helper);
                        var cmpEvent = component.getEvent("RefreshApprovalMembers");                               
                        cmpEvent.fire(); 
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
            else {
            helper.approverNotSelected(component, event, helper);
        }
        }
        else {
            helper.approverNotSelected(component, event, helper);
        }
        
    },
    proceedWithUpdateForApprovalProcess : function(component, event, helper) {
         helper.CheckPrevLevelBeforeUpdate(component, event, helper);
       /* var isUpdationAllowed = component.get("v.IsUpdationAllowed");
        if(isUpdationAllowed){
        	var validity = component.find("field").get("v.validity");
       		 if(validity.valid){
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
                        formName : component.get("v.formName"),
                        recordId : component.get("v.recordID"),
                        approverNames : component.get("v.dropDownSelectedValueToName").join(';')
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
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "APPROVAL LEVEL "+ component.get("v.approvallevelIndexAfterSave") +" UPDATED !",
                                "message": "APPROVAL LEVEL UPDATED!",
                                "type" : "success"
                            });
                            toastEvent.fire();
                            component.set("v.errorForApprovalLevelIndex",false);
                            helper.buildAttributeWrapper(component, event, helper);  
                            helper.helperMethod(component, event, helper);
                            var cmpEvent = component.getEvent("RefreshApprovalMembers");                               
                            cmpEvent.fire(); 
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
             else{
                var action1 = component.get('c.deleteApprovalLevel');        
                action1.setParams({
                    recordId : component.get("v.recordID")
                });        
                action1.setCallback(this, function(response) { 
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true);
                        component.set("v.isdisAbled", true);
                        component.set("v.isApprovalLevelAdded",true);
                        component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "APPROVAL LEVEL "+ component.get("v.approvallevelIndexAfterSave") +" SAVED!",
                            "message": "APPROVAL LEVEL SAVED",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        component.set("v.errorForApprovalLevelIndex",false);
                        component.set("v.enableSaveButton",false);
                        helper.buildAttributeWrapper(component, event, helper);  
                        helper.helperMethod(component, event, helper);
                        var cmpEvent = component.getEvent("RefreshApprovalMembers");                               
                        cmpEvent.fire();   
                    }
                });
                $A.enqueueAction(action1);
            } //meghna ends
        }
        else {
            helper.approverNotSelected(component, event, helper);  
        }
        }*/
        
    },
    handleEditForSingleInstanceApprovalRecord :  function(component, event, helper) {
        component.set("v.isdisAbled", false);
        component.set("v.enableEditpencilIcon", false); 
        component.set("v.isApprovalLevelAdded",false);
       // component.set("v.enableEdit", true); 
       //made below changes to make post deletion screen editable
       if(component.get("v.lastLevelDeleted")){
        component.set("v.enableSaveButton", true);  
      }
      else{
          component.set("v.enableEdit", true);
      }     
    },
    removePill : function(component, event, helper) {
             console.log(component.get("v.setupKeyWrapper.isPatientselected"));
       		 component.set("v.setupKeyWrapper.isPatientselected", false);
        	 component.set("v.approvalLevelValues.approver", "None");
       
    }
})