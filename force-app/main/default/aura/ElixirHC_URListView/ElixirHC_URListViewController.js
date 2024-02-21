({
    doInit: function(component, event, helper) {
   
        helper.fetchAccountName(component, event, helper) ;
        
        var nameSpace = 'ElixirSuite__';
          
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            // var focusedTabId = response.tabId;
            // console.log('afcresponse',response);
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Utilization Review"
                });                
            }
            else if (response.subtabs && response.subtabs.length > 0) {
                     console.log('status tab: ', response.subtabs);
                     console.log('length '+ response.subtabs.length)
                     workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                         console.log('tabId: response.subtabs[0].tabId: ' + response1);
                     });
                     workspaceAPI.setTabLabel({
                         label: "Utilization Review"
                     });
                 } 
                else {
                     console.error("No subtabs found");
                 }    
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:moneybag",
                iconAlt: "Utilization Review"
            });
        })
         
        
        var actions = [
            {label: 'Edit', name: 'Edit'},
            {label: 'Delete', name: 'Delete'},
            
        ];
          
            component.set('v.mycolumns', [
            
            
            {
            label: 'Name',
            fieldName: 'Name',
            type: 'button' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            {label: 'Type', fieldName:  nameSpace + 'Type__c', type: 'text',sortable: true},
            {label: 'Status', fieldName:  nameSpace + 'Status__c', type: 'text',sortable: true},
            {label: 'Auth Number', fieldName: nameSpace + 'Authorization_Number__c', type: 'text',sortable: true},
            {label: 'Approved LOC', fieldName:  nameSpace + 'Approved_LOC__c', type: 'text',sortable: true},
            {label: 'Approved Days', fieldName: nameSpace + 'Approved_Number_of_Days__c', type: 'number',sortable: true},
           /* {
            fieldName: nameSpace + "Discharge__c",
            label: "Discharge",
            type: "boolean",
            cellAttributes: {
            iconName: {
            fieldName: nameSpace + "Discharge__c"
            },
            iconPosition: "left"
            }
            },*/
            {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }  ]);
        
        var action = component.get("c.fetchAllRelatedUtlizationRecordsForAccount");
        action.setParams({ accountId : component.get("v.patientID") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log('UR  data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue();
                if(records.length==0 || $A.util.isEmpty(records)){
                    component.set("v.handleReviewButtonAsConcurrent",true);
                }
                else {
                    component.set("v.handleReviewButtonAsInitial",true); 
                }
                var falgForDischargeForm = false;
                for(var key in records){
                    if(records[key][nameSpace + 'Discharge__c']){
                        falgForDischargeForm= true; 
                        component.set("v.handleReviewButtonAsConcurrent",true);
                        component.set("v.handleReviewButtonAsConcurrent",true)
                    } 
                    break;
                }
                
                /* records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });*/
                
                component.set("v.data", records);
                //  console.log('final ' + JSON.stringify(res));
                // component.set("v.listDetails", records.formData);
                //  component.set("v.data",res);
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    New : function(component, event, helper){
        //component.set("v.recordValForMedication" ,component.get("v.recordId"));
        component.set("v.AlertScreen",true);
        
        component.set("v.openMedicationModal",true); 
        
        
    },
    handleRowAction : function(component, event, helper) {
        component.set("v.editScreen",false);
        console.log('inside handleRow Action');
        var action = event.getParam('action');
        console.log(action.name);
        var row = event.getParam('row');
        component.set("v.SelectedRec",row);
        component.set("v.PresId",event.getParams().row["Id"]);
        component.set("v.RowId",row.Id);
        console.log('row '+JSON.stringify(event.getParams()));
        
        var nameSpace = 'ElixirSuite__';
      
        switch (action.name) {
            case 'Edit':
                 if(row[nameSpace + 'Status__c']=='Closed') {
                     var toastEvent = $A.get("e.force:showToast");
                      toastEvent.setParams({
                        "type": "info",
                        "title": "CANNOT EDIT AS STATUS IS CLOSED!",
                        "message": "Status is closed!!"
                    });
                    toastEvent.fire();
                
                 }
                else {
                component.set("v.editScreenDisabled",false);
                component.set("v.editScreen",true); 
                }
                break;
                
            case 'recLink':
                component.set("v.editScreenDisabled",true);
                component.set("v.editScreen",true);
                break;
            case 'Delete':
                if(row[nameSpace + 'Status__c']=='Open') {
                    /* var arrToDelete  = [];
                    arrToDelete.push(row.Id);
                   helper.deleteSelectedHelper(component, event, helper,arrToDelete);
                   */
                     component.set("v.showConfirmDialog",true);
                 }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "info",
                        "title": "CANNOT DELETE AS STATUS IS "+row[nameSpace + 'Status__c'].toUpperCase(),
                        "message": "Status is not open!!"
                    });
                    toastEvent.fire();
                    
                }
                break;
                
                
                
        }
    }, 
    
    
    selectedRows : function(component, event, helper) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));        
        component.set("v.selectedURRecords",event.getParam('selectedRows'));
        //  var selectedRows = component.get('v.selectedRows');
        var selectedRows =  event.getParam('selectedRows');
            var nameSpace = 'ElixirSuite__';
            
        var falg = false;
        for(var allRecords in selectedRows){
            if(selectedRows[allRecords][nameSpace + 'Status__c']!='Open'){
                falg = true;
            }   
        }
        component.set("v.deletionAbility",falg);                 
        if(selectedRows.length>=1) 
        {
            component.set("v.showDeleteButton",true); 
        }
        else {
            component.set("v.showDeleteButton",false); 
        }
   
     },
    deleteSelectedRows: function (component, event, helper) {
        component.set("v.showConfirmDialog",true);    
    },
    exportAsPDF :  function (component, event, helper) {
        var selectedRows = component.get("v.selectedOrders");
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows));                
        var orderId=selectedRows[0].Id;          
        var url = '/apex/PrescriptionOrderPDFGenerator?orderId='+orderId;
        // alert(url);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
        
    },
    
    createReview : function (component, event, helper) {
      var flagReview =  component.get("v.handleReviewButtonAsInitial");
        if(flagReview){
            component.set("v.showLastReviewInfo",true);
        }
       // component.set("v.openUtilizationReview",true);
        helper.checkCareEpisodehelper(component, event, helper,component.get("v.patientID"));//NK----LX3-5932
 
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        // component.set('v.IsSpinner',true);
        var row  = component.get("v.RowId");
        if(typeof(row)=="string" && !$A.util.isUndefinedOrNull(row)){
            helper.deleteSelectedHelper(component, event, helper,row);
        }
        else {         
            var arrToDelete  = [];
            arrToDelete.push(component.get("v.selectedURRecords"));
            var selectedRows = component.get("v.selectedURRecords");
            console.log('UA Id'+JSON.stringify(selectedRows));
            var selectedIds = [];
            for (var i = 0; i < selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].Id);
            }
            helper.deleteSelectedHelper(component, event, helper,selectedIds);
        }
        
        
    },
   // Added by Ashwini
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
            "recordId": component.get("v.patientID")
        });
        navEvt.fire();
    },

    //end


    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    }
})