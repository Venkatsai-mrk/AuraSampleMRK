({
    init: function(component, event, helper) {
        helper.fetchAccountName(component, event, helper) ;
        var recId = component.get("v.recordVal");
        var nameSpace = 'ElixirSuite__';
        helper.fetchNspc(component, event, helper);
        console.log(component.get("v.isOpen")); 
        
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
                    label: "Prescriptions"
                });
            } else if (response.subtabs && response.subtabs.length > 0) {
                workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                    console.log('tabId: response.subtabs[0].tabId: ' + response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Prescriptions"
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
        
		helper.fetchColumns(component, event, helper);        
        console.log('accountId'+component.get("v.recordVal"));
        var action = component.get("c.fetchMedications");
        action.setParams({  
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('accountId' +recId);
                console.log("success");
             component.set('v.mycolumns', [{
                label: 'Medication Name',
                fieldName: nameSpace+'DynamicMedicationField__c',
                type: 'button' ,typeAttributes:  {label: { fieldName: nameSpace+'DynamicMedicationField__c' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            {
                label: 'Days',
                fieldName:  nameSpace+'Number_of_Times_Days_Weeks__c',
                type: 'text'
            }, {
                label: 'Type',
                fieldName: nameSpace+'Type__c',
                type: 'text'
            
            }, {
                label: 'Route',
                fieldName: nameSpace+'DynamicRouteField__c',
                type: 'text'
            },
	                                       {
                fieldName: nameSpace+"After_Discharge__c",
                label: "After Discharge",
                type: "boolean",
                cellAttributes: {
                    iconName: {
                        fieldName: nameSpace+"After_Discharge__c"
                    },
                    iconPosition: "left"
                }
            },
                                           {
                label: 'Order',
                fieldName: nameSpace+"DynamicCreatedFieldOrder__c",
                type: 'text'
            
            },
               {label: 'LastModified Date', fieldName: 'formattedLastModifiedTime', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            second: '2-digit',  
                                                                            hour12: false}},

        ]);
                var allData = response.getReturnValue();
                for(var key in allData){
                    if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Prescription_Order__r'])){
                    allData[key][nameSpace+'DynamicCreatedFieldOrder__c']  = allData[key][nameSpace+'Prescription_Order__r'].Name;
}
                if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Medication__r'])){
                    allData[key][nameSpace+'DynamicMedicationField__c']  = allData[key][nameSpace+'Medication__r'].Name;
                    }
 
                if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Route_New_1__r'])){
                    allData[key][nameSpace+'DynamicRouteField__c']  = allData[key][nameSpace+'Route_New_1__r'].Name;
                    }
                if (!$A.util.isUndefinedOrNull(allData[key]['LastModifiedDate'])) {
                    var lastModifiedDateTime = new Date(allData[key]['LastModifiedDate']);
                    var lastModifiedYear = lastModifiedDateTime.getFullYear();
                    var lastModifiedMonth = String(lastModifiedDateTime.getMonth() + 1).padStart(2, '0');
                    var lastModifiedDay = String(lastModifiedDateTime.getDate()).padStart(2, '0');
                    var lastModifiedHours = String(lastModifiedDateTime.getHours() % 12 || 12).padStart(2, '0');
                    var lastModifiedMinutes = String(lastModifiedDateTime.getMinutes()).padStart(2, '0');
                    var lastModifiedAMPM = lastModifiedDateTime.getHours() >= 12 ? 'PM' : 'AM';
                    var formattedLastModifiedTime = `${lastModifiedYear}-${lastModifiedMonth}-${lastModifiedDay}, ${lastModifiedHours}:${lastModifiedMinutes} ${lastModifiedAMPM}`;

                    // Update the result array with formatted date
                    allData[key]['formattedLastModifiedTime'] = formattedLastModifiedTime;
                    }
                }
   
               
            component.set("v.listDetails", allData);
          
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);  
    },
    New : function(component, event, helper){      
        component.set("v.AlertScreen",true);   
       helper.checkCareEpisodehelper(component, event, helper,component.get("v.recordVal"));//NK----LX3-5932
      
        
      
    },
    handleRowAction : function(component, event) {
        
        component.set("v.editScreen",false);
        console.log('inside handleRow Action');
        var action = event.getParam('action');
        console.log(action.name);
        var row = event.getParam('row');
         component.set("v.RowId",row.Id);
        component.set("v.SelectedRec",row);
        component.set("v.PresId",event.getParams().row["Id"]);
        console.log('row '+JSON.stringify(event.getParams()));
        
      
        switch (action.name) {
            case 'EDIT':
                 component.set("v.openingMode",'Edit');
                component.set("v.editScreenDisabled",false);
                component.set("v.editScreen",true);
                break;
                
            case 'recLink':
                component.set("v.openingMode",'View');
                component.set("v.editScreenDisabled",true);
                component.set("v.editScreen",true);
                break;
            case 'DELETE' : 
                component.set("v.showConfirmDialog",true);
                
        }
    },
    handleRowAction1 : function(component, event) {
       
        var action = event.getParam('action').name;
        var row = event.getParam('row');
        component.set("v.SelectedOrderRec",row); 
        component.set("v.OrderID",event.getParams().row["presId"]); 
        if ( action == 'Edit' ) {
             component.set("v.openingMode",'Edit ');
             component.set("v.dynamicLabel",'Update');
              component.set("v.orderName",event.getParams().row["presName"]);
            component.set("v.EditPrescriptionOrder",true); 
        }
        else{
             component.set("v.openingMode",'View ');
            component.set("v.dynamicLabel",'Submit');
             component.set("v.orderName",event.getParams().row["presName"]);
             component.set("v.ViewPrescriptions",true); 
        }
      //  
        
    },
    //Added by Ashwini
    navToListView: function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
        },
        navToAccRecord: function(component) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordVal")
            });
            navEvt.fire();
        },
      //End  
    handleApplicationEvent	: function() {
        $A.get('e.force:refreshView').fire();
        
    },
    selectedRowsForMedication : function(component, event) {
         component.set("v.selectedMedications",event.getParam('selectedRows'));
    },
    selectedRows : function(component, event) {
	console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));
      
     	var selectedRows =  event.getParam('selectedRows');
        component.set("v.selectedOrders",selectedRows);
        
        if(selectedRows.length>=1) 
        {
           component.set("v.showDeleteButton",true); 
             
        }
        else {
             component.set("v.showDeleteButton",false); 
            
        }
        if(selectedRows.length==1) {
            component.set("v.enableExportAsPdf",true);
        }
        else{
            component.set("v.enableExportAsPdf",false); 
        }
        
    },
    deleteSelectedRows: function (component) {
        
        var selectedRows = component.get("v.selectedOrders");
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].presId);
        }
         var action = component.get('c.deleteAllOrder');
    action.setParams({
        "lstRecordId": selectedIds,
    });
    action.setCallback(this, function(response) { 
         var state = response.getState();
                if (state === "SUCCESS") {

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "RECORD(S) DELETED SUCCESSFULLY!",
                        "message": "Deletion Successfull!"
                    });
                    toastEvent.fire();
                  
                    $A.get('e.force:refreshView').fire();
                } else if (state === "ERROR") {

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
    exportAsPDF :  function (component) {
          var selectedRows = component.get("v.selectedOrders");
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows));                
        var orderId=selectedRows[0].presId;          
        var url = '/apex/ElixirSuite__PrescriptionOrderPDFGenerator?orderId='+orderId;
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
  
    },
   
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        if(changeValue =='Medication'){
            cmp.set("v.Medication",true);
            cmp.set("v.heading",'Medication');
            cmp.set("v.Prescription",false);
        }
        else if(changeValue =='Prescription'){
           cmp.set("v.Prescription",true);
              cmp.set("v.heading",'Prescription');
            cmp.set("v.Medication",false);
        }
    },
     handleConfirmDialogYes :  function(component, event, helper) {     
            var arrToDelete  = [];
            arrToDelete.push(component.get("v.selectedMedicationRecords"));
            var selectedRows = component.get("v.selectedMedicationRecords");
            console.log('UA Id'+JSON.stringify(selectedRows));
            var selectedIds = [];
            for (var i = 0; i < selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].Id);
            }
            helper.deleteSelectedHelper(component, event, helper,selectedIds);
        
    },
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
        
    }
})