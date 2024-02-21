({
    
    fetchListOfForms : function(component, event, helper) {
        component.set("v.openSelectedForm",false);
        var action = component.get("c.fetchListOfFormsAsRecords");
        //    component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.loaded",false);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //   component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.loaded",true);
                var nameSpace = 'ElixirSuite__';
                var res = response.getReturnValue().allFormsAsRecords;
                component.set("v.allRecTypesOnMDTObject",response.getReturnValue().allRecordTypesOfMDTObject);  
                component.set("v.acctChildObjects",response.getReturnValue().accountChildObject); 
                component.set("v.essentialLookupFields",response.getReturnValue().essentialLookupFields); 
                
                console.log('res values '+JSON.stringify(res));
                console.log('column values  '+JSON.stringify(component.get('v.mycolumns')));
                
                // No need to filter out duplicates, as we are only fetching section 1 in res
                // and each form configration will only have one section 1 so values in res will be unique
                //var holdItems = [];
                //var itemsName = [];
                
                //for(var rec in res){
                //    if(!itemsName.includes(res[rec].ElixirSuite__Form__c)){
                //        holdItems.push(res[rec]);
                //        itemsName.push(res[rec].ElixirSuite__Form__c);
                //    }
                //}
                //console.log('lv res '+JSON.stringify(holdItems));
                //component.set("v.listDetails",holdItems);
                
                component.set("v.listDetails",res);
                
                
                //var actions = [
                //    {label: 'Edit', name: 'EDIT' },
                //    {label: 'Delete', name: 'DELETE'},
                //    {label: 'Define Approvers', name: 'ADD_APPROVER'}
                //];
                
                var actions = helper.getRowActions.bind(this, component);
                
                var tableColumns = [];
                tableColumns.push(
                    {
                        label: 'Form Name',
                        fieldName: 'ElixirSuite__Form__c',
                        type: 'button' ,typeAttributes:  {label: { fieldName: 'ElixirSuite__Form__c' }, target: '_blank' , name: 'recLink',variant:'Base' }
                    },
                    {
                        label: 'Form Template Status',
                        fieldName: 'ElixirSuite__Form_Template_Status__c',
                    }
                );

                
                    /****************DYNAMIC APPROVAL LEVEL HANDLING ********************/
                    if(!$A.util.isEmpty(response.getReturnValue().totalApprovalLevel)){
                    var numberOfApprovalLevels = response.getReturnValue().totalApprovalLevel[0].ElixirSuite__Maximum_Level_For_Approval__c;
                if(!$A.util.isUndefinedOrNull(numberOfApprovalLevels)){
                      if(numberOfApprovalLevels<=5){
                    for(let i=1;i<=numberOfApprovalLevels;i++){
                        var obj = {
                            "label": "Approval Level " +i,
                            "fieldName": "ApprovalLevel"+i,

                            "cellAttributes": {
                                "class": {
                                    "fieldName": "showClass1"
                                },
                                "iconName": {
                                    "fieldName": "displayIconName1"
                                }
                            }
                        }
                        tableColumns.push(obj);
                    }
                      }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "MAXIMIUM 5 LEVELS OF APPROVAL ALLOWED!",
                    "message": "Approval Level cannot be more than 5",
                    "type" : "error"
                });
                toastEvent.fire(); 
                    }
                }
                else {
                    
                }
            }
            else {
                
            }
            
            tableColumns.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }); 
            
            /************************************************************/
            component.set('v.mycolumns',tableColumns); 
            /****************DYNAMIC APPROVAL LEVEL VALUE HANDLING ********************/
            var relatedApprovalRecord = response.getReturnValue().mapOfApprovalRecord;
            var listDetails = component.get("v.listDetails");
            for(let createApprovalNode in listDetails){
                for(let i=1;i<=numberOfApprovalLevels;i++){
                    var lstOfApprovalRecords = relatedApprovalRecord[listDetails[createApprovalNode].ElixirSuite__Form__c];                    
                    const mapOfApprovalRecordInLevel = new Map();
                    for(let createApprovalNodeChild in lstOfApprovalRecords){                       
                        mapOfApprovalRecordInLevel.set(lstOfApprovalRecords[createApprovalNodeChild].ElixirSuite__Approval_Level__c,lstOfApprovalRecords[createApprovalNodeChild]);
                    }
                    console.log('map is '+mapOfApprovalRecordInLevel);
                    var value = '';
                    if(mapOfApprovalRecordInLevel.has(i)){
                        if(mapOfApprovalRecordInLevel.get(i).hasOwnProperty('ElixirSuite__Approval_Members_Name__c')){
                            value = mapOfApprovalRecordInLevel.get(i).ElixirSuite__Approval_Members_Name__c;
                        }  
                    }
                    
                    listDetails[createApprovalNode]['ApprovalLevel'+i] = value;
                }
            }
            component.set("v.listDetails",listDetails); 
            console.log('total set  '+JSON.stringify(component.get("v.listDetails")));
            /************************************************************/
        }
                           
                           });
        
        $A.enqueueAction(action); 
    },
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        
        var action = component.get( 'c.deleteAllForms' );
        component.set("v.loaded",false);
        action.setParams({
            "lstRecordId": selectedIds,
        });
        console.log("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "FORM DELETED SUCCESSFULLY!",
                    "message": "Sucess!",
                    "type" : "success"
                });
                toastEvent.fire();
                helper.fetchListOfForms(component, event, helper);            
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

    getRowActions: function (component, row, doneCallback) {
        var actions = [
            {label: 'Edit', name: 'EDIT' },
            {label: 'Delete', name: 'DELETE'},
            {label: 'Define Approvers', name: 'ADD_APPROVER'},
        ];
        if (row.ElixirSuite__isActive__c) {
            actions.push({
                label: 'Deactivate Form Template', name:'DEACTIVATE_FORM'
            });
        }
        else {
            actions.push({
                label: 'Activate Form Template', name:'ACTIVATE_FORM'
            }); 
        }
        actions.push({
            label: 'Deploy Form', name: 'DEPLOY_FORM'            	
        },
        {                 
            label: 'Set Form Template for Expiration', name: 'SET_EXPIRY_DATE'
        });
            if (row.ElixirSuite__Enable_As__c === 'VisitNote') {
            actions.push({ label: 'Disable as Visit Note', name: 'DISABLE_VISIT_NOTE' });
            } else {
            actions.push({ label: 'Enable as Visit Note', name: 'ENABLE_VISIT_NOTE' });
            }
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            console.log('helloThere: ', row);
            doneCallback(actions);
        }), 200);
    },

    toggleFormActivationStatus: function(component, event, helper, selectedFormNames, activationStatus, message) {
        let action = component.get("c.setFormActivationStatus");
        action.setParams({
            formNames : selectedFormNames,
            status : activationStatus
        });

        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log("inside success");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type": "success",
                    "message": message
                });
                toastEvent.fire();
                helper.fetchListOfForms(component, event, helper);
            }
            else if (response.getState() == "ERROR") {
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
        toggleVisitNoteSetting: function (component, event, helper, selectedFormNames, enableAs, message) {
            let action = component.get("c.toggleVisitNoteSetting");
            action.setParams({
                formNames: selectedFormNames,
                enableAs: enableAs
            });
            
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": message
                    });
                    toastEvent.fire();
                    helper.fetchListOfForms(component, event, helper);
                } else if (response.getState() == "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
        },

    sendFormNameAndIdToDeploy: function(component) {
        let action = component.get("c.deployForm");
        component.set("v.loaded",false);

        action.setParams({
            formName : component.get("v.formRecordName"),
            formId : component.get("v.formRecordID")
        });

        action.setCallback(this, function(response) {
            component.set("v.loaded",true);
            var toastEvent = $A.get("e.force:showToast");

            if (response.getState() === "SUCCESS") {
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Form deployed",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        
                        toastEvent.setParams({
                            "title": "Error",
                            "message": `${errors[0].message}`,
                            "type" : "error",
                            "mode" : "sticky"
                        });
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error",
                        "message": 'Unknown Error',
                        "type" : "error",
                        "mode" : "sticky"
                    });
                }
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})