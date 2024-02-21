({
    init: function (component, event, helper) {
        //  alert('init '+component.get("v.enableSessionNotes"));
        console.log('init called');

        if ($A.util.isUndefinedOrNull(component.get("v.recordVal")) || $A.util.isEmpty(component.get("v.recordVal"))) {
            component.set("v.recordVal", component.get("v.recordId"));
        }
        //workspace code starts
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            console.log('afctab', focusedTabId);
            
            if (issubTab) {
                workspaceAPI.getTabInfo({ tabId: focusedTabId }).then(function (response1) {
                    console.log('afctabinfo', response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Notes"
                });
            } else if (response.subtabs && response.subtabs.length > 0) {
                workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                    console.log('tabId: response.subtabs[0].tabId: ' + response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Notes"
                });
            } else {
                console.error("No subtabs found");
            }
            
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:answer",
                iconAlt: "Notes"
            });
        }).catch(function (error) {
            console.error("Error:", error);
        });
        
        

        //workspace Code ends

        var dt = { 'date1': '', 'date2': '', 'date3': '' };
        component.set("v.AllDates", dt);
        var actionbuttons = false;
        var message = event.getParam("route");
        if (message == 'forRefresh') {
            component.set("v.openMedicationModal", false);
        }

        helper.initFunctionMovedToHelper(component, event, helper, actionbuttons);
        var action1 = component.get("c.sendFormsToPortalAbility");
        action1.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.fetchCustomSettingSendForm", response.getReturnValue());
            }
        });

        $A.enqueueAction(action1);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);  
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        var selectedRows = component.get("v.setRows");
        if(selectedRows.length > 0){
            console.log('New Acc' + JSON.stringify(selectedRows));
            var selectedIds = [];
            for (var i = 0; i < selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].formId);
            }
            helper.deleteSelectedHelper(component, event, helper, selectedIds);
            component.set("v.showConfirmDialog",false);
        }
        else{
            var action2 = component.get("c.DeleteSavedForm");
            action2.setParams({
                formUniqueId: component.get("v.PresId")
            });
            action2.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('delete status', response.getReturnValue());
                    var status = response.getReturnValue();
                    //nithin
                    var toastEvent = $A.get("e.force:showToast");
                    if (status.formValue == true && status.careValueStatus == 'Reopened') {
                        toastEvent.setParams({
                            "type": "Warning",
                            "title": "Error Message",
                            "message": "You cannot delete this Form/Note. Please contact your administrator "
                        });
                        toastEvent.fire();
                    }
                    else if (status.formValue == true && status.careValueStatus == 'Closed') {
                        //var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Warning",
                            "title": "Error Message",
                            "message": "You cannot delete this Form/Note as this is related to a closed care episode. Please contact your administrator "
                        });
                        toastEvent.fire();
                    }
                        else {
                            var actionbuttons = false;
                            //var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "success",
                                "title": "Deletion Successful!",
                                "message": "Form is successfully deleted"
                            });
                            toastEvent.fire();
                            helper.initFunctionMovedToHelper(component, event, helper, actionbuttons);
                        }
                }
                else if (state === "ERROR") {
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
            $A.enqueueAction(action2);
            component.set("v.showConfirmDialog",false);
        }
    },
                
           
    New: function (component) {
        component.set("v.openMedicationModal", true);
        component.set("v.openSendForsToPortal", false);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "ElixirSuite__Elixir_AllNewForms"
                },
                "state": {
                    c__customCategory: component.get("v.customCategory"),
                    c__isOpen: component.get("v.openMedicationModal"),
                    c__categorized: component.get("v.categorized"),
                    c__subCategorized: component.get("v.subCategorized"),
                    c__patientID: component.get("v.recordVal"),
                    c__forPatientPortal: component.get("v.forPatientPortal")
                }
            },
            focus: true
        }).then(function (subtabId) {
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "All Notes"
            });
        }).catch(function (error) {
            console.log(error);
        });


    },

    closeTab: function (component) {
        try {
            /*  var evt = $A.get("e.force:navigateToComponent");
                      evt.setParams({
                          componentDef:"c:Elixir_NewAccountAssociatedForms",
                          componentAttributes: {
                              recordVal : component.get("v.recordId"),
                              //  categorized : "Other",
                              subCategorized: "Assessment",
                              headingTitle: "All Notes"
                          }
                      });
              alert('Event in new account');
                      evt.fire();*/

            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
                console.log('im closed');
            })
                .catch(function (error) {
                    console.log('Not closed, check the error: ' + error);
                });

        }
        catch (e) {
            console.log('ERROR IN CLOSING TAB' + e)
        }

    },
    // added by Tanveer 
    sendFormToPatientPortal: function (component) {
        component.set("v.forPatientPortal", true);
        component.set("v.openSendForsToPortal", true);
        component.set("v.openMedicationModal", false);
    },
    // added by shivam
    DynamicNotes: function (component) {
        alert('Work in progress');
        component.set("v.openDynamicModal", true);
    },

    // End By Shivam
    handleRowAction: function (component, event, helper) {
        component.set("v.endString", '');
        var dt = { 'date1': '', 'date2': '', 'date3': '' };
        component.set("v.AllDates", dt);
        //var nameSpace = '';
        console.log('inside handleRow Action');
        var actionType = event.getParam('action');
        component.set("v.actionName", actionType);
        console.log(actionType.name);
        var row = event.getParam('row');
        component.set("v.SelectedRec", row);
        console.log('row');
        component.set("v.PresId", event.getParams().row["formId"]);
        component.set("v.PrevCareId", event.getParams().row["careEpisodeId"]);
        component.set("v.selectedFormName", event.getParams().row["recordTypeName"]);
        component.set("v.screenFormName", event.getParams().row["formName"]);
        console.log(event.getParams().row["formId"]);
        component.set("v.FormName", event.getParams().row["formName"]);
        console.log('**' + event.getParams().row["recordTypeName"]);
        let selectedFormName = component.get("v.FormName");
        switch (component.get("v.actionName").name) {
            case 'EDIT':
                console.log('FormId', component.get('v.PresId'));
                var action = component.get("c.checkCareEpisode");
                action.setParams({
                    formUniqueID: event.getParams().row["formId"]
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state status', state);
                    if (state === "SUCCESS") {
                        console.log('status', response.getReturnValue());
                        var status = response.getReturnValue();
                        if (status.careValueStatus === "Closed" && status.lockValue === true) {
                            component.set("v.AllFlag", true);
                            component.set("v.editScreen", false);
                            component.set("v.editScreen", true);
                            component.set("v.SaveButton", false);
                            component.set("v.viewMode", true);
                            component.set("v.Title", 'View Form');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "Warning",
                                "title": "Error message",
                                "message": "You cannot edit this Form/Note as this is related to a closed care episode. Please contact your administrator"
                            });
                            toastEvent.fire();
                        }
                        else {
                            // alert(' selectedFormName '+ JSON.stringify(component.get("v.selectedFormName")));
                            if (event.getParams().row["status"] == 'Waiting For Patient') {
                                component.set("v.AllFlag", true);
                                component.set("v.editScreen", false);
                                component.set("v.SaveButton", false);
                                component.set("v.viewMode", true);
                                component.set("v.Title", 'View Form');

                                helper.getCustomFormsHelper(component, event, helper, 'VIEW')
                                    .then(function (result) {
                                        if (result && component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c).includes(component.get("v.selectedFormName"))) {
                                            var workspaceAPI = component.find("workspace");
                                            workspaceAPI.openSubtab({
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "ElixirSuite__subscriberComponent"
                                                    },
                                                    "state": {
                                                        c__customFormCmp: component.get("v.customFormCmp"),
                                                        c__accountId: component.get("v.recordVal"),
                                                        c__formName: component.get("v.selectedFormName"),
                                                        c__formUniqueId: component.get("v.PresId"),
                                                        c__actionType: 'VIEW'
                                                    }
                                                },
                                                focus: true
                                            }).then(function (subtabId) {
                                                workspaceAPI.setTabLabel({
                                                    tabId: subtabId,
                                                    label: component.get("v.selectedFormName")
                                                });
                                            }).catch(function (error) {
                                                console.log(error);
                                            });
                                        } else {
                                            var workspaceAPI2 = component.find("workspace");
                                            workspaceAPI2.openSubtab({
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "ElixirSuite__Elixir_UpdateForm"
                                                    },
                                                    "state": {
                                                        c__clone: false,
                                                        c__isOpen: component.get("v.editScreen"),
                                                        c__recordId: component.get("v.recordVal"),
                                                        c__formUniqueId: component.get("v.PresId"),
                                                        c__changedFormName: component.get("v.screenFormName"),
                                                        c__formName: component.get("v.selectedFormName"),
                                                        c__viewMode: true
                                                    }
                                                },
                                                focus: true
                                            }).then(function (subtabId) {
                                                workspaceAPI2.setTabLabel({
                                                    tabId: subtabId,
                                                    label: component.get("v.selectedFormName")
                                                });
                                            }).catch(function (error) {
                                                console.log(error);
                                            });
                                        }
                                    })
                                    .catch(function (error) {
                                        console.error('Error occurred:', error);
                                    });         
                            }
                            else {
                                component.set("v.editScreen", false);
                                component.set("v.editScreen", true);
                                component.set("v.viewMode", false);
                                component.set("v.SaveButton", true);


                                helper.getCustomFormsHelper(component, event, helper, 'EDIT')
                                    .then(function (result) {
                                        if (result && component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c).includes(component.get("v.selectedFormName"))) {
                                            var workspaceAPI = component.find("workspace");
                                            workspaceAPI.openSubtab({
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "ElixirSuite__subscriberComponent"
                                                    },
                                                    "state": {
                                                        c__customFormCmp: component.get("v.customFormCmp"),
                                                        c__accountId: component.get("v.recordVal"),
                                                        c__formName: component.get("v.selectedFormName"),
                                                        c__formUniqueId: component.get("v.PresId"),
                                                        c__actionType: 'EDIT'
                                                    }
                                                },
                                                focus: true
                                            }).then(function (subtabId) {
                                                workspaceAPI.setTabLabel({
                                                    tabId: subtabId,
                                                    label: component.get("v.selectedFormName")
                                                });
                                            }).catch(function (error) {
                                                console.log(error);
                                            });
                                        } else {
                                            var workspaceAPI2 = component.find("workspace");
                                            workspaceAPI2.openSubtab({
                                                pageReference: {
                                                    "type": "standard__component",
                                                    "attributes": {
                                                        "componentName": "ElixirSuite__Elixir_UpdateForm"
                                                    },
                                                    "state": {
                                                        c__clone: false,
                                                        c__isOpen: component.get("v.editScreen"),
                                                        c__recordId: component.get("v.recordVal"),
                                                        c__formUniqueId: component.get("v.PresId"),
                                                        c__changedFormName: component.get("v.screenFormName"),
                                                        c__formName: component.get("v.selectedFormName"),
                                                        c__viewMode: component.get("v.viewMode"),
                                                        c__actionType: 'EDIT'
                                                    }
                                                },
                                                focus: true
                                            }).then(function (subtabId) {
                                                workspaceAPI2.setTabLabel({
                                                    tabId: subtabId,
                                                    label: component.get("v.selectedFormName")
                                                });
                                            }).catch(function (error) {
                                                console.log(error);
                                            });
                                        }
                                    })
                                    .catch(function (error) {
                                        console.error('Error occurred:', error);
                                    });
                            }


                        }

                    }
                });
                $A.enqueueAction(action);
                break;
            /*component.set("v.editScreen", false);
            component.set("v.editScreen", true);
            component.set("v.SaveButton", true);
            component.set("v.AllFlag", false);
            component.set("v.Title", 'Edit Form');
            component.set("v.viewMode",false);
            break;*/

            case 'CLONE':               

                helper.getFormExpiry(component, event, helper, selectedFormName)
                    .then(function (result) {
                        console.log('Call 1:', result);

                        console.log('Checking status of form', result);

                        if (result) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error',
                                message: 'This form template is no longer active. You can not clone this form',
                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        } else {
                            component.set("v.cloneScreen", false);
                            component.set("v.cloneScreen", true);
                            component.set("v.clone", true);
                            component.set("v.SaveButton", true);
                            component.set("v.AllFlag", false);
                            component.set("v.Title", 'Clone Form');
                            component.set("v.viewMode", false);
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.openSubtab({
                                pageReference: {
                                    "type": "standard__component",
                                    "attributes": {
                                        "componentName": "ElixirSuite__Elixir_UpdateForm"
                                    },
                                    "state": {
                                        c__clone: true,
                                        c__isOpen: component.get("v.editScreen"),
                                        c__recordId: component.get("v.recordVal"),
                                        c__formUniqueId: component.get("v.PresId"),
                                        c__changedFormName: component.get("v.screenFormName"),
                                        c__formName: component.get("v.selectedFormName"),
                                        c__viewMode: false,
                                        c__actionType: 'CLONE'
                                    }
                                },
                                focus: true
                            }).then(function (subtabId) {
                                workspaceAPI.setTabLabel({
                                    tabId: subtabId,
                                    label: component.get("v.selectedFormName")
                                });
                            }).catch(function (error) {
                                console.log(error);
                            });

                        }

                    })
                    .catch(function (error) {
                        console.error('Error occurred:', error);
                    });
                break;

            case 'edit_care':
                try {
                    // component.set("v.editingThisLabTestName", row.Name);
                    // component.set("v.editingThisMedicationId", row.Id);
                    // component.set("v.currentICD", row.ICD__c);

                    let inlineEditComponent = component.find("inlineEditCare");

                    let numberOfInlineEditComponents = inlineEditComponent.length;
                    if (numberOfInlineEditComponents) {
                        inlineEditComponent[0].open();
                    }
                    else {
                        inlineEditComponent.open();
                    }
                    // let newICD = prompt("Enter ICD");
                    // helper.updateLabTestICD(component, event, helper, row.Id, newICD);   
                } catch (error) {
                    console.log(error.message);
                }
                break;


            case 'recLink':
                component.set("v.AllFlag", true);
                component.set("v.editScreen", false);
                component.set("v.editScreen", true);
                component.set("v.SaveButton", false);
                component.set("v.viewMode", true);
                component.set("v.Title", 'View Form');

                helper.getCustomFormsHelper(component, event, helper, 'VIEW')
                    .then(function (result) {
                        if (result && component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c).includes(component.get("v.selectedFormName"))) {
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.openSubtab({
                                pageReference: {
                                    "type": "standard__component",
                                    "attributes": {
                                        "componentName": "ElixirSuite__subscriberComponent"
                                    },
                                    "state": {
                                        c__customFormCmp: component.get("v.customFormCmp"),
                                        c__accountId: component.get("v.recordVal"),
                                        c__formName: component.get("v.selectedFormName"),
                                        c__formUniqueId: component.get("v.PresId"),
                                        c__actionType: 'VIEW'
                                    }
                                },
                                focus: true
                            }).then(function (subtabId) {
                                workspaceAPI.setTabLabel({
                                    tabId: subtabId,
                                    label: component.get("v.selectedFormName")
                                });
                            }).catch(function (error) {
                                console.log(error);
                            });
                        } else {
                            var workspaceAPI2 = component.find("workspace");
                            workspaceAPI2.openSubtab({
                                pageReference: {
                                    "type": "standard__component",
                                    "attributes": {
                                        "componentName": "ElixirSuite__Elixir_UpdateForm"
                                    },
                                    "state": {
                                        c__clone: false,
                                        c__isOpen: component.get("v.editScreen"),
                                        c__recordId: component.get("v.recordVal"),
                                        c__formUniqueId: component.get("v.PresId"),
                                        c__changedFormName: component.get("v.screenFormName"),
                                        c__formName: component.get("v.selectedFormName"),
                                        c__viewMode: true
                                    }
                                },
                                focus: true
                            }).then(function (subtabId) {
                                workspaceAPI2.setTabLabel({
                                    tabId: subtabId,
                                    label: component.get("v.selectedFormName")
                                });
                            }).catch(function (error) {
                                console.log(error);
                            });
                        }
                    })
                    .catch(function (error) {
                        console.error('Error occurred:', error);
                    });
                break;

            case 'DELETE':
                
                component.set("v.showConfirmDialog",true);     
                break;
            /*if(!$A.util.isUndefinedOrNull(getStatus.Status__c)){
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
                            var action = component.get("c.DeleteSavedForm");
                            action.setParams({
                                formId: event.getParams().row["Id"]
                            });
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                     var actionbuttons=false;
                                    helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                                }
                            });
                            $A.enqueueAction(action);
                        }
                        
                    }   
                    break;*/
        }


    },
    handleApplicationEvent: function (component, event, helper) {
        var actionbuttons = false;
        helper.initFunctionMovedToHelper(component, event, helper, actionbuttons);

    },
    closeModel: function (component) {
        component.set("v.editScreen", false);
        component.set("v.showDetail", '');

    },
    selectedRows: function (component, event) {
        console.log('seleceted rows' + JSON.stringify(event.getParam('selectedRows')));

        console.log('all rows ' + JSON.stringify(component.get('v.selectedRows')));

        component.set("v.selectedLabOrders", event.getParam('selectedRows'));


        var selectedRows = event.getParam('selectedRows');
        for (var allRecords in selectedRows) {
            if (selectedRows[allRecords].Status__c == 'Completed' || selectedRows[allRecords].Status__c == "Under Review") {
                component.set("v.deletionAbility", true);
            }
        }

        /*var selectedRows = event.getParam('selectedRows');*/
        if (selectedRows.length >= 1) {
            component.set("v.showDeleteButton", true);
            component.set("v.sendFormsAbility", false);

        } else {
            component.set("v.showDeleteButton", false);
            var checkCustomSetting = component.get("v.fetchCustomSettingSendForm");
            if (checkCustomSetting) {
                component.set("v.sendFormsAbility", true);
            }
            else {
                component.set("v.sendFormsAbility", false);
            }
        }

        if (selectedRows.length == 1) {
            component.set("v.enableExportAsPdf", true);
        } else {
            component.set("v.enableExportAsPdf", false);
        }
        if (component.get("v.RestrictButtons") == true) {
            component.set("v.enableExportAsPdf", false);
        }
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++) {

            setRows.push(selectedRows[i]);

        }
        component.set("v.setRows", setRows);
        console.log('Rows', setRows);
        //component.set("v.selectedRows",selectedRows);
    },
    exportAsPDF: function (component) {
        var selectedRows = component.get("v.setRows");
        console.log('for exportPDF row selected is ' + JSON.stringify(selectedRows));
        var url = '/apex/ElixirSuite__Elixir_FormsPdfGenerator?aId=' + component.get("v.recordVal") + '&fName=' +
            selectedRows[0].recordTypeName + '&fId=' + selectedRows[0].formId + '&fCName=' + selectedRows[0].formName;
        console.log(url);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
    },
    deleteSelectedRows: function (component, event, helper) {
        component.set("v.showConfirmDialog",true);
    },

    handleRefresh: function () {
        $A.get('e.force:refreshView').fire();
    },

    /* closeModel1: function(component, event, helper) {
        component.set("v.isOpen1", false);
        
    },*/
    /*exportAsPDF: function(component, event, helper) {
        var nspc = '';
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('for exportPDF row selected is ' + JSON.stringify(selectedRows));
        var recordToExport = selectedRows[0].Id;
        var url = '/apex/'+nspc+'FormsPDFGenerator?formId=' + recordToExport;
        //alert(url + recordToExport);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
        
    },*/
    onCheck: function (component, event, helper) {
        if (component.get("v.isRestrict") == true) {
            component.set("v.isRestricted", true);
            var actionbuttons = true;
            helper.initFunctionMovedToHelper(component, event, helper, actionbuttons);
        }
        else {
            component.set("v.isRestricted", true);

        }
    },
    onCancel: function (component) {
        component.set("v.isRestricted", false);
        component.set("v.isRestrict", false);
    },
    onSubmit: function (component, event, helper) {
        //var nameSpace = 'ElixirSuite__';
        var action = component.get('c.Uinfo');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if (component.get("v.isRestrict") == true) {
                    var DataList = JSON.parse(JSON.stringify(component.get("v.listDetails")));
                    var NewDataList = [];
                    for (var i in DataList) {
                        NewDataList.push(DataList[i]);
                        /* if($A.util.isUndefinedOrNull(DataList[i][nameSpace+ 'Visit1__c'])){
                            NewDataList.push(DataList[i]);
                        }*/
                    }
                    component.set("v.listDetails", NewDataList)
                    var isValidate;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');
                    if ($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)) {
                        userName.set("v.errors", [{ message: 'Please Enter the Key!!' }]);
                        isValidate = false;
                    } else {
                        if (userNameVal == res.ElixirSuite__Verification_Code__c) {
                            userName.set("v.errors", null);
                            isValidate = true;
                        } else {
                            userName.set("v.errors", [{ message: 'Invalid Key!!' }]);
                        }
                    }

                    if (isValidate) {
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", true);
                        component.set("v.deletionAbility", true);
                        component.set("v.enableExportAsPdf", false);
                        console.log('hh', component.get("v.deletionAbility"))
                        component.set("v.SecurityKeys", "");
                    }
                }
                else {
                    var actionbuttons = false;
                    helper.initFunctionMovedToHelper(component, event, helper, actionbuttons);
                    var isValidate2;
                    var userName2 = component.find('userName');
                    var userNameVal2 = component.find('userName').get('v.value');
                    if ($A.util.isUndefinedOrNull(userNameVal2) || $A.util.isUndefined(userNameVal2) || $A.util.isEmpty(userNameVal2)) {
                        userName2.set("v.errors", [{ message: 'Please Enter the Key!!' }]);
                        isValidate2 = false;
                    } else {
                        if (userNameVal2 == res.ElixirSuite__Verification_Code__c) {
                            userName2.set("v.errors", null);
                            isValidate2 = true;
                        } else {
                            userName2.set("v.errors", [{ message: 'Invalid Key!!' }]);
                        }
                    }

                    if (isValidate2) {
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", false);
                        component.set("v.SecurityKeys", "");
                        component.set("v.deletionAbility", false);
                        component.set("v.enableExportAsPdf", false);
                    }
                }
            }
            else if (state === "ERROR") {

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

    navToListView: function () {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },

    navToAccRecord: function (component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordVal")
        });
        navEvt.fire();
    },
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        //alert(changeValue);
        if (changeValue == 'Forms') {
            cmp.set("v.Forms", true);
            cmp.set("v.heading", 'All Forms and Notes');
            cmp.set("v.EventNotesListView", false);
        }
        else if (changeValue == 'Notes') {
            cmp.set("v.EventNotesListView", true);
            cmp.set("v.heading", 'Event Notes View');
            cmp.set("v.Forms", false);
        }
    },

    registerSignature: function (component) {
        component.set("v.recordVal", component.get("v.recordId"));
        component.set("v.openSignature", true);
       
    },
})