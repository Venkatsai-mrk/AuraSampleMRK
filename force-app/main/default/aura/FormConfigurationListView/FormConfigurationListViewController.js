({
    init: function(component, event, helper) {
        helper.fetchListOfForms(component, event, helper);
    },
    handleComponentEvent :  function(component, event, helper) { 
        alert('received');
    },
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        component.set("v.actionName",action);
        console.log(action.name);
        var row = event.getParam('row');
         component.set("v.RowId",row.ElixirSuite__Form__c);
        component.set("v.SelectedRec", row);
        component.set("v.formRecordID", event.getParams().row["Id"]);
        component.set("v.formRecordName",event.getParams().row["ElixirSuite__Form__c"] );
        // console.log('form name '+event.getParams().row["ElixirSuite__Form__c"]);
        // console.log('id '+component.get("v.formRecordID"));
        
        switch (component.get("v.actionName").name) {
            case 'EDIT':
                /*component.set("v.editScreen", false);
                component.set("v.editScreen", true);*/
                component.set("v.Title", 'Edit Form');
                component.set("v.AllFlag", false);
                component.set("v.openSelectedForm", true);
                
                break;
                
            case 'recLink':
                component.set("v.AllFlag", true);
                component.set("v.openSelectedForm", true);
                component.set("v.editScreen", false);
                component.set("v.editScreen", true);
                component.set("v.SaveButton", false);
                component.set("v.Title", 'View Form');
                break;
                
            case 'DELETE':
                component.set("v.showConfirmDialog",true);         
                
                /*  var getStatus = event.getParams().row;
                if(!$A.util.isUndefinedOrNull(getStatus.Status__c)){
                    var getCurrent = getStatus.Status__c;
                    if(getCurrent == 'Completed' || getCurrent == "Under Review"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "info",
                            "title": "CANNOT DELETE AS STATUS IS "+getCurrent.toUpperCase(),
                            "message": "Status is not open!!"
                        });
                        toastEvent.fire();
                    }
                    else {
                        
                    }
                    
                } */
                break; 

            case 'ADD_APPROVER' : 
             component.set("v.openApprovalWindow",true);   
                break;

            case 'ACTIVATE_FORM':
                helper.toggleFormActivationStatus(
                    component, event, helper,
                    [event.getParams().row["ElixirSuite__Form__c"]],
                    true,
                    `Activated ${event.getParams().row["ElixirSuite__Form__c"]}`);
                break;
            
            case 'DEACTIVATE_FORM':
                helper.toggleFormActivationStatus(
                    component, event, helper,
                    [event.getParams().row["ElixirSuite__Form__c"]],
                    false,
                    `Deactivated ${event.getParams().row["ElixirSuite__Form__c"]}`);
                break;
                
            case 'ENABLE_VISIT_NOTE':
                if (!row.ElixirSuite__Enable_As__c || row.ElixirSuite__Enable_As__c !== 'VisitNote') {
                helper.toggleVisitNoteSetting(
                component, event, helper,
                [row.ElixirSuite__Form__c],
                'VisitNote', 
                `Enabled Visit Note for ${row.ElixirSuite__Form__c}`
            );
            }
            break;
            
            case 'DISABLE_VISIT_NOTE':
            if (row.ElixirSuite__Enable_As__c === 'VisitNote') {
                helper.toggleVisitNoteSetting(
                    component, event, helper,
                    [row.ElixirSuite__Form__c],
                    '',
                    `Disabled Visit Note for ${row.ElixirSuite__Form__c}`
                );
            }
            break;

            case 'SET_EXPIRY_DATE':
                component.set("v.showSetExpiryDateModal", true);
                break;
    
            case 'DEPLOY_FORM':
    			if (confirm("Ensure deployment is configured to target your desired org. Delete this form in target org. Press Ok to deploy")) {
                    helper.sendFormNameAndIdToDeploy(component);
                }
                break;
        }
        
        
    },
    deleteSelectedRows: function(component, event, helper) {
        var selectedRows = component.get("v.selectedconfigForms");
        console.log('Lab Order Id' + JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].ElixirSuite__Form__c);
        }
        helper.deleteSelectedHelper(component, event, helper ,selectedIds);
    },

    toggleFormActivationStatusController: function(component, event, helper) {
        // get names of all selected forms
        let formNames = [];
        let selectedRows = component.get("v.selectedconfigForms");
        for (let i in selectedRows) {
            formNames.push(selectedRows[i].ElixirSuite__Form__c);
        }

        console.log("helloThere: ", event.getSource().get("v.name"));
        switch (event.getSource().get("v.name")) {
            case "activate":
                helper.toggleFormActivationStatus(
                    component, event, helper,
                    formNames,
                    true,
                    'Activated all selected form templates');
                break;
            
            case "deactivate":
                helper.toggleFormActivationStatus(
                    component, event, helper,
                    formNames,
                    false,
                    'Deactivated all selected form templates');
                break;

            default:
                break;
        }
    },


    selectedRows: function(component, event, helper) {
        
        component.set("v.selectedconfigForms", event.getParam('selectedRows'));      
        var selectedRows =  event.getParam('selectedRows');

        component.set("v.foundActivatedFormsInSelection", false);
        component.set("v.foundDeactivatedFormsInSelection", false);

        for(var allRecords in selectedRows){
            if(selectedRows[allRecords].Status__c=='Completed' || selectedRows[allRecords].Status__c == "Under Review"){
                component.set("v.deletionAbility",true);  
            }

            if (selectedRows[allRecords].ElixirSuite__isActive__c) {
                component.set("v.foundActivatedFormsInSelection", true);
            }
            else {
                component.set("v.foundDeactivatedFormsInSelection", true);
            }
        }
        
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length >= 1) {
            component.set("v.showDeleteButton", true);
            component.set("v.showSetActivationStatus", true);
        } else {
            component.set("v.showDeleteButton", false);
            component.set("v.showSetActivationStatus", false);
        }
        if (selectedRows.length == 1) {
            component.set("v.enableExportAsPdf", true);
        } else {
            component.set("v.enableExportAsPdf", false);
        }
        
    },
    closeModel1 : function(component, event, helper) {
        component.destroy();
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        var action = component.get("c.deleteSavedForm");
        component.set("v.loaded",false);
        action.setParams({
            formName: component.get("v.RowId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.loaded",true);
                var actionbuttons=false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "FORM DELETED SUCCESSFULLY!",
                    "message": "Sucess!",
                    "type" : "success"
                });
                toastEvent.fire();
                helper.fetchListOfForms(component, event, helper);
                component.set("v.showConfirmDialog",false);
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

    closeSetExpiryDateModal: function(component) {
        component.set("v.showSetExpiryDateModal", false);
    },

    setExpiryDateModalSuccess: function(component, event, helper) {
        component.set("v.showSetExpiryDateModal", false);
        helper.fetchListOfForms(component, event, helper);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success",
            "type": "success",
            "message": "Expiry Date Updated"
        });
        toastEvent.fire();
    }
})