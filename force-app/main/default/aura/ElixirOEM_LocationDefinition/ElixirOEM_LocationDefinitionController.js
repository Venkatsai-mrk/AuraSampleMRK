({
    doInit : function(component, event, helper) {  
        let approvalLevelValues = {'approver' : '','approverList' : []}; 
        component.set("v.approvalLevelValues",approvalLevelValues);
        helper.buildAttributeWrapper(component, event, helper);  
        helper.fetchDropdownValues(component);
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
        //    var validity = component.find("field").get("v.validity");
        //     if(validity.valid){
        let obj = helper.validateEmptyUser_Location(component, event, helper);
        if(obj.flag){
            if(component.get("v.isSetUpKeySelected")){
                component.set("v.loaded",false);
                
                let approvalLevelValues = {'approver' : '','approverList' : []}; 
                component.set("v.approvalLevelValues",approvalLevelValues);
                var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
                var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions"),
                                      };
                console.log('dropDownSelectedValueToName '+JSON.stringify(component.get("v.dropDownSelectedValueToName"))); 
                let locData = {'locDataToSave' : component.get("v.dropDownSelectedValueToName")};
                console.log('selected for location '+JSON.stringify(locData)); 
                console.log('setup key sent '+JSON.stringify(component.get("v.setupKeySelected"))); 
                var action = component.get('c.saveLocationForUser');        
                action.setParams({
                    locationData :JSON.stringify(locData), 
                    approver :  component.get("v.approvalLevelValues").approver,
                    approvalLevel : component.get("v.index"),
                    selectedApprovers : selectedApprovers.join(';'),
                    dropDownOptions : JSON.stringify(dropDownOptions),
                    formName : component.get("v.formName"),
                    approverNames : component.get("v.dropDownSelectedValueToName").join(';'),
                    setupKeySelected : component.get("v.setupKeySelected")
                });        
                action.setCallback(this, function(response) { 
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.closeForce",false);
                        component.set("v.loaded",true);
                        console.log(' inserted id is '+response.getReturnValue());
                        component.set("v.isdisAbled", true);
                        component.set("v.isApprovalLevelAdded",true);
                        component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                        component.set("v.toDelRecords",[]);
                        component.set("v.errorForApprovalLevelIndex",false);
                        component.set("v.enableSaveButton",false);
                        /*   let locationwrapper = {'selectedLocations':[],
                                               'locationOptions' : [],
                                               'selectedUser' : '',
                                               'selectedUserId' : ''  ,
                                               'searchString_Location' : '',
                                               'enableAbility' : false,
                                              };
                        
                        component.set("v.dropDownSelectedValueToName",locationwrapper);*/
                        helper.buildAttributeWrapper(component, event, helper);  
                        helper.helperMethod(component, event, helper);
                        if(response.getReturnValue()){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "NO USER DEFINED FOR THIS  "+ component.get("v.setupKeySelected")+"!",
                                "message": "No user defined!",
                                "type" : "error"
                            });
                            toastEvent.fire(); 
                            component.set("v.isdisAbled", false);
                            component.set("v.enableSaveButton",true);
                            component.set("v.isApprovalLevelAdded",false);
                        }
                        else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "LOCATION CONFIGURED FOR "+ component.get("v.setupKeySelected")+"!",
                                "message": "Location configuration successful!",
                                "type" : "success"
                            });
                            toastEvent.fire();
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
            }
            else {
                helper.setUpKeyNotSelected(component, event, helper);
            }
        }
        else {
            helper.locationNotSelected(component, event, helper,obj);
        }
        
    },
    proceedWithUpdateForApprovalProcess : function(component, event, helper) {
        try{
            let obj = helper.validateEmptyUser_Location(component, event, helper);
            if(obj.flag){
                if(component.get("v.isSetUpKeySelected")){
                    component.set("v.loaded",false);
                    
                    let approvalLevelValues = {'approver' : '','approverList' : []}; 
                    component.set("v.approvalLevelValues",approvalLevelValues);
                    var selectedApprovers = JSON.parse(JSON.stringify(component.get("v.dropDownSelectedValues")));
                    var dropDownOptions = {'keysToSave' : component.get("v.dropDownOptions"),
                                          };
                    console.log('dropDownSelectedValueToName '+JSON.stringify(component.get("v.dropDownSelectedValueToName"))); 
                    let locData = {'locDataToSave' : component.get("v.dropDownSelectedValueToName")};
                    console.log('selected for location '+JSON.stringify(locData)); 
                    console.log('setup key sent '+JSON.stringify(component.get("v.setupKeySelected"))); 
                    var action = component.get('c.updateLocation');        
                    action.setParams({
                        locationData :JSON.stringify(locData), 
                        approver :  component.get("v.approvalLevelValues").approver,
                        approvalLevel : component.get("v.index"),
                        selectedApprovers : selectedApprovers.join(';'),
                        dropDownOptions : JSON.stringify(dropDownOptions),
                        formName : component.get("v.formName"),
                        approverNames : component.get("v.dropDownSelectedValueToName").join(';'),
                        setupKeySelected : component.get("v.setupKeySelected"),
                        toDelRecords : component.get("v.toDelRecords")
                    });        
                    action.setCallback(this, function(response) { 
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set("v.closeForce",false);
                            component.set("v.loaded",true);
                            component.set("v.toDelRecords",[]);
                            console.log(' inserted id is '+response.getReturnValue());
                            component.set("v.isdisAbled", true);
                            component.set("v.isApprovalLevelAdded",true);
                            component.set("v.approvallevelIndexAfterSave",JSON.parse(JSON.stringify(component.get("v.index"))));
                            
                            component.set("v.errorForApprovalLevelIndex",false);
                            component.set("v.enableSaveButton",false);
                            /*   let locationwrapper = {'selectedLocations':[],
                                                   'locationOptions' : [],
                                                   'selectedUser' : '',
                                                   'selectedUserId' : ''  ,
                                                   'searchString_Location' : '',
                                                   'enableAbility' : false,
                                                  };
                            
                            component.set("v.dropDownSelectedValueToName",locationwrapper);*/
                            helper.buildAttributeWrapper(component, event, helper);  
                            helper.helperMethod(component, event, helper);
                            if(response.getReturnValue()){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "NO USER DEFINED FOR THIS  "+ component.get("v.setupKeySelected")+"!",
                                    "message": "No user defined!",
                                    "type" : "error"
                                });
                                toastEvent.fire(); 
                                component.set("v.isdisAbled", false);
                                component.set("v.enableSaveButton",true);
                                component.set("v.isApprovalLevelAdded",false);
                                component.set("v.enableEdit", true);        
                            }
                            else {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "LOCATION UPDATED FOR "+ component.get("v.setupKeySelected")+"!",
                                    "message": "Location updated successful!",
                                    "type" : "success"
                                });
                                toastEvent.fire();
                                component.set("v.enableEdit", false);  
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
                }
                else {
                    helper.setUpKeyNotSelected(component, event, helper);
                }
            }
            else {
                helper.locationNotSelected(component, event, helper,obj);
            }
        }
        catch(e){
            alert('error '+e);
        }
    },
    handleEditForSingleInstanceApprovalRecord :  function(component, event, helper) {
        try{
            component.set("v.isdisAbled", false);
            component.set("v.enableEditpencilIcon", false); 
            component.set("v.isApprovalLevelAdded",false);
            component.set("v.enableEdit", true);  
            let dropDownSelectedValueToName =   component.get("v.dropDownSelectedValueToName"); 
            dropDownSelectedValueToName.forEach( function(element, index) {                                  
                element.enableAbility = false;                                                      
            });
            component.set("v.dropDownSelectedValueToName",dropDownSelectedValueToName);
        }
        catch(e){
            alert('error '+e);
        }
    }
})