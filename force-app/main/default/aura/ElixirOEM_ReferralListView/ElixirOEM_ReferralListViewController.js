({
    myAction: function(component, event, helper) {
        helper.fetchAccountName(component, event, helper) ;
        try {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                // var focusedTabId = response.tabId;
                // console.log('afcresponse',response);
                var focusedTabId = response.tabId;
                var issubTab = response.isSubtab;
                console.log('afctab', focusedTabId);
                if (issubTab) {
                    workspaceAPI.getTabInfo({
                        tabId: focusedTabId
                    }).then(function(response1) {
                        
                        console.log('afctabinfo', response1);
                    });
                    workspaceAPI.setTabLabel({
                        
                        label: "Referral List"
                    });                
                } else {
                    workspaceAPI.getTabInfo({
                        tabId: response.subtabs[0].tabId
                    }).then(function(response1) {
                        console.log('afctabinfo----', response1);
                    });
                    workspaceAPI.setTabLabel({
                        label: "Referral List"
                    });         
                }     
                
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "utility:answer",
                    iconAlt: "Referral List"
                });
            })
            
            console.log('in init');
            var actions = [
                
                {
                    label: 'Delete',
                    name: 'DELETE'
                },
                {
                    label: 'Edit',
                    name: 'EDIT'
                }

            ];
            component.set("v.loaded", false);
            var action = component.get("c.initpayloadForReferralListView");
            action.setParams({  
                accountId: component.get("v.recordVal"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded", true);
                    try {
                        console.log('res ' + JSON.stringify(response.getReturnValue()));
                        let csColumns = response.getReturnValue().columns;
                        let resp = response.getReturnValue().refeerralRecords;
                        resp.forEach(function(column) {
                            column['CreatedBy'] = column.CreatedBy.Name;
                            column['linkName'] = '/' + column.Id;
                            if (column.hasOwnProperty('ElixirSuite__Provider__r')) {
                                column['ElixirSuite__Provider__c'] = column.ElixirSuite__Provider__r.Name;
                            }
                            if (column.hasOwnProperty('ElixirSuite__Referred_Out_Organization__r')) {
                                column['ElixirSuite__Referred_Out_Organization__c'] = column.ElixirSuite__Referred_Out_Organization__r.Name;
                            }
                            if (column.hasOwnProperty('ElixirSuite__User__r')) {
                                column['ElixirSuite__User__c'] = column.ElixirSuite__User__r.Name;
                            }
                            if (column.hasOwnProperty('ElixirSuite__Referred_To__r')) {
                                column['ElixirSuite__Referred_To__c'] = column.ElixirSuite__Referred_To__r.Name;
                            }
                            
                        });
                        
                        component.set('v.mycolumns', [{
                                label: 'Referral Name',
                                fieldName: 'linkName',
                                type: 'url',
                                typeAttributes: {
                                    label: {
                                        fieldName: 'Name'
                                    }
                                }
                            },
                            
                            
                            
                        ]);
                            
                        console.log('response ' + JSON.stringify(response.getReturnValue()));
                            component.set("v.listDetails", resp);
                            let mapOfApiAndLabel = {
                            "ElixirSuite__Provider__c": "Location",
                            "ElixirSuite__Referred_Out_Organization__c": "Referred Out Organization",
                            "ElixirSuite__User__c": "Care Team Member",
                            "ElixirSuite__Referred_To__c": "Referred To",
                            "ElixirSuite__Email_CTM__c": "Email (CTM)",
                            "ElixirSuite__Phone_CTM__c": "Phone (CTM)",
                            "ElixirSuite__Email_Referred_To__c": "Email",
                            "ElixirSuite__Phone_Referred_To__c": "Phone",
                            "CreatedBy": "Created By "
                        };
                            
                            let toAddCol = component.get('v.mycolumns');
                        if (!$A.util.isUndefinedOrNull(csColumns)) {
                            let csColArr = csColumns.split(';');                      
                            if (csColumns) {
                                for (let recSObj in csColArr) {
                                    toAddCol.push({
                                        label: mapOfApiAndLabel[csColArr[recSObj]],
                                        fieldName: csColArr[recSObj],
                                        type: 'text'
                                    });
                    }
                    
                }
                
            }
                        toAddCol.push({
                            label: 'Created Date',
                            fieldName: 'CreatedDate',
                            type: 'date',
                            sortable: true,
                            typeAttributes: {
                                day: 'numeric',
                                month: 'short',
                                year: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit',
                                second: '2-digit',
                                hour12: true
                            }
                        });
          
           
                        toAddCol.push({
                            fieldName: 'Actions',
                            type: 'action',
                            typeAttributes: {
                                rowActions: actions
        }
                        });
                        component.set('v.mycolumns', toAddCol);
                        component.set("v.loaded", true);
                    } catch (e) {
            alert(e);
        }
        
        
                } else {
    console.log("failure");
}
 });
$A.enqueueAction(action);
        } catch (e) {
            alert('error ' + e);
}


},
    New: function(component, event, helper) {
       //component.set("v.openMedicationModal", true);
       //console.log('@@@@@@@@@@@---'+component.get("v.recordVal"));
       helper.checkCareEpisodehelper(component, event, helper,component.get("v.recordVal"));//NK----LX3-5925
    },
    openNewCarePlanModal: function(component, event, helper) {
        console.log('before setting val', component.get("v.newEncounter"));
            component.set("v.newEncounter", true);
        console.log('after value set', component.get("v.newEncounter"));
            helper.helperMethod(component, event, helper);
            
        },
    updateSelectedText: function(component, event, helper) {
                var selectedRows = event.getParam('selectedRows');
                console.log(JSON.stringify(selectedRows));
                //  console.log('selectedRows'+selectedRows);
        component.set("v.selectedRowsCount", selectedRows.length);
        let obj = [];
        if (selectedRows.length >= 1) {
            component.set("v.showDeleteButton", true);
        } else {
            component.set("v.showDeleteButton", false);
                }
        for (var i = 0; i < selectedRows.length; i++) {
                    
            obj.push({
                Name: selectedRows[i].Name
            });
                    
                }
                
                
                //component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
        component.set("v.selectedRowsList", event.getParam('selectedRows'));
                
            },
                handleRowAction: function(component, event, helper) {
       // component.set("v.selectedRowsList", event.getParam('selectedRows'));
        try {
                        var action = event.getParam('action');
            component.set("v.actionName", action);
                        console.log(action.name);
                        var row = event.getParam('row');
            console.log(JSON.stringify(row));
            component.set("v.RowId", row.Id);
            component.set("v.referralNam", row.Name);

            component.set("v.recordVal", row.Id);
            
                        component.set("v.SelectedRec", row);
                        
                        
                        switch (component.get("v.actionName").name) {
                            case 'EDIT':
                                component.set("v.Title", 'Edit ');
                                component.set("v.AllFlag", false);
                                component.set("v.openSelectedRecord", true);                    
                                break;                    
                            case 'recLink':
                                component.set("v.Title", 'View ');
                                component.set("v.AllFlag", true);
                    component.set("v.openSelectedRecord", true);
                                break;   
                            case 'DELETE':
                    component.set("v.showConfirmDialog", true);
                                break;
                                
                        }
        } catch (e) {
            //alert('error ' + e);
                    }
                    
                    
                    
                },
    selectedRowsHandler: function(component, event, helper) {
        console.log('seleceted rows' + JSON.stringify(event.getParam('selectedRows')));
        if(event.getParam('selectedRows')!==undefined){
            component.set('v.selectedRowsList',event.getParam('selectedRows')); 
        }
        console.log('all rows ' + JSON.stringify(component.get('v.selectedRowsList')));

        component.set("v.selectedLabOrders", event.getParam('selectedRows'));
        var selectedRows = event.getParam('selectedRows');
                        
        for (var allRecords in selectedRows) {
            if (selectedRows[allRecords].Status__c == 'Completed' || selectedRows[allRecords].Status__c == "Under Review") {
                component.set("v.deletionAbility", true);
            }
        }
                        
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length >= 1) {
            component.set("v.showDeleteButton", true);
        } else {
            component.set("v.showDeleteButton", false);
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
                        
                    }, 
        //Added by Ashwini
        navToListView: function(component, event, helper) {
            // Sets the route to /lightning/o/Account/home
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/o/Account/home'
            });
            urlEvent.fire();
            },
            navToAccRecord: function(component, event, helper) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordVal")
                });
                navEvt.fire();
            },

    deleteButton: function(component, event, helper) {
        try{
                            var rowsList = component.get('v.selectedRowsList');
        console.log(rowsList.length);
                            var setOfIds = [];

        if(rowsList.length === 0 || rowsList.length == 0 ){
            helper.globalFlagToast(component, event, helper,'Please Select Referral', ' ', 'error');

        }else{
            
        for (var row in rowsList) {
                                setOfIds.push(rowsList[row].Id);
                            }
                console.log('for delete row selected is ' + JSON.stringify(rowsList));

        console.log('setOfIds ' + setOfIds);
                            var action = component.get('c.deleteAllReferral');
                            action.setParams({
            parentId: setOfIds
                            });
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "Success",
                                        "title": "RECORD DELETED SUCCESSFULLY!",
                                        "message": "Deletion Successfull!"
                                    });
                                    toastEvent.fire();
                                    $A.get('e.force:refreshView').fire();
                                }
                            });
                            $A.enqueueAction(action);    
        }
        }catch(error){
            console.log(error);
        }
                        },
    handleConfirmDialogNo: function(component, event, helper) {
        component.set("v.showConfirmDialog", false);
                            },
    handleConfirmDialogYes: function(component, event, helper) {
                                    helper.deleteSelectedRecordRecord(component, event, helper);
        component.set("v.showConfirmDialog", false);
                                },
                                    closeModel: function(component, event, helper) {
                                        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
                                        component.set("v.openCareplan", false);
                                    },
                                        
    showOptions: function(cmp) {
        cmp.set("v.showOptions", true);
                                        },
    sortColumn: function(component, event, helper) {
        try {
                                                    var fieldName = event.getParam('fieldName');
                                                    var sortDirection = event.getParam('sortDirection');
                                                    component.set("v.sortedBy", fieldName);
                                                    component.set("v.sortedDirection", sortDirection);
                                                    helper.sortData(component, fieldName, sortDirection);
        } catch (e) {
            alert('error ' + e);
                                                }
                                                
                                            },

    exportAsPDF: function(component, event, helper) {
        console.log('chetan1');
        console.log(component.get('v.selectedRowsList'));
        var selectedRows = component.get("v.selectedRowsList");

        if(selectedRows.length !== 1  ){
            helper.globalFlagToast(component, event, helper,'Please Select One  Referral Record', ' ', 'error');
        }else{
        
        //var selectedRows = component.get("v.setRows");
        console.log('for exportPDF row selected is ' + JSON.stringify(selectedRows));
        console.log('chetan2');
        var url = '/apex/ElixirSuite__ElixirOEM_ReferralFormPDF?aId=' + component.get("v.recordVal") + '&fName=' +
            selectedRows[0].recordTypeName + '&referralId=' + selectedRows[0].Id + '&fCName=' + selectedRows[0].Attachments[0].Name;
        console.log(url);
        
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
        }
    },
    openProc: function(component, event, helper) {
        component.set("v.openProcNew", true);
                                                },
    editProcedure: function(component, event, helper) {
        component.set("v.openProcEdit", true);
                                                    },  
})