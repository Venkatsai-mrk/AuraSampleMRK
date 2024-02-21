({
    doInit : function(component) {
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
            
        var patientId = component.get("v.patId");
        var action = component.get("c.BringData");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    /*  if(record.hasOwnProperty('ElixirSuite__Installment_Amount__c')){
                        record.ElixirSuite__Installment_Amount__c = '$ ' +   record.ElixirSuite__Installment_Amount__c
                    }
                    else {
                        record['ElixirSuite__Installment_Amount__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Net_Balance__c')){
                        record.ElixirSuite__Net_Balance__c = '$ ' +   record.ElixirSuite__Net_Balance__c
                    }
                    else {
                        record['ElixirSuite__Net_Balance__c'] = '$ 0'
                    }*/
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
        
        component.set('v.mycolumns', [
            
            {
            label: 'Payment Schedule Name',
            fieldName: 'linkName',
            type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_self'  ,variant:'Base'}
            },
            
            {label: 'Frequency', fieldName:'ElixirSuite__Pay_Frequency__c', type: 'text'},
            {label: 'Installment Amount($)', fieldName:   'ElixirSuite__Installment_Amount__c', type: 'currency'},
            {label: 'Total Amount($)', fieldName: 'ElixirSuite__Net_Balance__c', type: 'currency'},
            {label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                                                                             }}
        ]);
 
    },
    
    LoadViewAll : function(component) {
 
            component.set('v.mycolumns', [
            
            {
            label: 'Payment ScheduleName',
            fieldName: 'linkName',
            type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_self' ,variant:'Base'}
            },
            
            {label: 'Frequency', fieldName:'ElixirSuite__Pay_Frequency__c', type: 'text'},
            {label: 'Installment Amount($)', fieldName:   'ElixirSuite__Installment_Amount__c', type: 'currency'},
            {label: 'Total Amount($)', fieldName: 'ElixirSuite__Net_Balance__c', type: 'currency'},
            {label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                                                                             }}
        ]);
        var patientId = component.get("v.patId");
        var action = component.get("c.BringDataViewAll");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    /*  if(record.hasOwnProperty('ElixirSuite__Installment_Amount__c')){
                        record.ElixirSuite__Installment_Amount__c = '$ ' +   record.ElixirSuite__Installment_Amount__c
                    }
                    else {
                        record['ElixirSuite__Installment_Amount__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Net_Balance__c')){
                        record.ElixirSuite__Net_Balance__c = '$ ' +   record.ElixirSuite__Net_Balance__c
                    }
                    else {
                        record['ElixirSuite__Net_Balance__c'] = '$ 0'
                    }*/
                });
                
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    
    },
    
    selectedRows : function(component, event) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));        
        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
        //  var selectedRows = component.get('v.selectedRows');
        var selectedRows =  event.getParam('selectedRows');
        if(selectedRows.length>=1) 
        {
            component.set("v.showDeleteButton",true); 
        }
        else {
            component.set("v.showDeleteButton",false); 
        }
        
    },
    handleRowAction : function(component, event) {
        
        var recId = event.getParam('row').Id;
        //alert(recId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'lightning/r/ElixirSuite__Payment_Schedule__c/'+recId+'/view'
        });
        urlEvent.fire();
        
    },
    
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component) {
        // alert(component.get("v.RowId"));
        var action = component.get("");
        action.setParams({ recordToDelete : component.get("v.RowId") });
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
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
                //  component.set("v.data",res);
            }
        }); 
        
        $A.enqueueAction(action);
        
        
        
        
    },
    sendSelectedClaimId: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        console.log('claim IDs'+selectedIds);
        var action = component.get("c.generateXML");
        action.setParams({ claimIds : selectedIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                
            }
        });
        $A.enqueueAction(action);
        
    },
    deleteSelectedRows: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.deleteSelectedHelper(component, event, selectedIds);
    },
    updateSelectedRows: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.updateSelectedHelper(component, event, selectedIds);
    },
    createClaim : function() {
        var recordEvent=$A.get("e.force:createRecord");
        recordEvent.setParams({
            "entityApiName": "ElixirSuite__Claim__c",
            "defaultFieldValues":{
                
            }
        });
        recordEvent.fire();
    },
    FilteredData1 : function(component, event, helper) {
        let flag = helper.computeDates(component);
        if(flag == 1){
            return;
        }
        component.set("v.viewAllBool", false);
        component.set("v.viewAllBoolgo", true);
        
        var patientId = component.get("v.patId");
        
        var action = component.get("c.BringFilterData");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                           ids : patientId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                     /*  if(record.hasOwnProperty('ElixirSuite__Installment_Amount__c')){
                        record.ElixirSuite__Installment_Amount__c = '$ ' +   record.ElixirSuite__Installment_Amount__c
                    }
                    else {
                        record['ElixirSuite__Installment_Amount__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Net_Balance__c')){
                        record.ElixirSuite__Net_Balance__c = '$ ' +   record.ElixirSuite__Net_Balance__c
                    }
                    else {
                        record['ElixirSuite__Net_Balance__c'] = '$ 0'
                    }*/
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    },
      checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
    },
        FilteredViewAll : function(component) {
        
         var patientId = component.get("v.patId");
        var action = component.get("c.BringFilterDataViewAll");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          ids : patientId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                     /*  if(record.hasOwnProperty('ElixirSuite__Installment_Amount__c')){
                        record.ElixirSuite__Installment_Amount__c = '$ ' +   record.ElixirSuite__Installment_Amount__c
                    }
                    else {
                        record['ElixirSuite__Installment_Amount__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Net_Balance__c')){
                        record.ElixirSuite__Net_Balance__c = '$ ' +   record.ElixirSuite__Net_Balance__c
                    }
                    else {
                        record['ElixirSuite__Net_Balance__c'] = '$ 0'
                    }*/
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    },
    openPopUp : function(component){
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    
})