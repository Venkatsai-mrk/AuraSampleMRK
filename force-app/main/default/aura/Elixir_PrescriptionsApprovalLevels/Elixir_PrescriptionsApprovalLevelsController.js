({
    doInit : function(component, event, helper) {  
        helper.buildAttributeWrapper(component, event, helper);  
        helper.helperMethod(component, event, helper);
    },
    fetchRelatedOptions : function(component, event, helper) {
        // if(event.getSource().get("v.value")!='Patient'){
        console.log('ABC',event.getSource().get("v.value"));
        if(event.getSource().get("v.value")!='None'){
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
            component.set("v.ApproverCustomLabel", " ");
        }
      
    },
    proceedWithSaveForApprovalProcess : function(component, event, helper) {
        var validity = component.find("field").get("v.validity");
        if(validity.valid){
            if(component.find("field").get("v.value") != 'None'){
            if(component.get("v.isSetUpKeySelected")){
                component.set("v.loaded",false);
                console.log('selected '+component.get("v.approvalLevelValues").approver); 
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
                    ApprovalFor : component.get("v.ApprovalFor"),
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
                        /*var toastEvent = $A.get("e.force:showToast");
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
                        component.set("v.enableSaveButton",false);
                        helper.buildAttributeWrapper(component, event, helper);  
                        helper.helperMethod(component, event, helper);
                      /*  var cmpEvent = component.getEvent("RefreshApprovalMembers");                               
                        cmpEvent.fire(); */
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
    }
   
})