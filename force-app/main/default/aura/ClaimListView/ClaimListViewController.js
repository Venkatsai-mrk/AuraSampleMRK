({
    doInit : function(component, event, helper) {
        helper.disableNewButton(component); //Anusha - 02/11/22
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        var patientId = component.get("v.patId");
        component.set('v.mycolumns', [
            
            {
                label: 'Claim Name',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
            },
          /*  {label: 'Claim Status ', fieldName:   'ElixirSuite__Claim_Status__c', type: 'text'},*/
            {label: 'Payer Name', fieldName:   'ElixirSuite__Payor__c', type: 'text'},
            {label: 'Charges($)', fieldName:   'ElixirSuite__Total_Charge__c', type: 'currency'},
            {label: 'Insurance Payments($)', fieldName:   'ElixirSuite__Total_Paid__c', type: 'currency'},
            {label: 'Adjustments($)', fieldName:   'ElixirSuite__Total_Adjustment__c', type: 'currency'}]);
        
        var action = component.get("c.BringDataFirst");
        action.setParams({
            "recId": patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                //console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().ClaimToPost;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    /*   if(record.hasOwnProperty('ElixirSuite__Total_Charge__c')){
                        record.ElixirSuite__Total_Charge__c = '$ ' +   record.ElixirSuite__Total_Charge__c
                    }
                    else {
                        record['ElixirSuite__Total_Charge__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Total_Paid__c')){
                        record.ElixirSuite__Total_Paid__c = '$ ' +   record.ElixirSuite__Total_Paid__c
                    }
                    else {
                        record['ElixirSuite__Total_Paid__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Total_Adjustment__c')){
                        record.ElixirSuite__Total_Adjustment__c = '$ ' +   record.ElixirSuite__Total_Adjustment__c
                    }
                    else {
                        record['ElixirSuite__Total_Adjustment__c'] = '$ 0'
                    }*/
                     if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Payor__c)){
                    record['ElixirSuite__Payor__c'] = record.ElixirSuite__Payor__r.Name;    
                    }
                });
                component.set("v.data", records);
                component.set("v.parentData",JSON.parse(JSON.stringify(records)));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
        
        
        
    },
    
    
    
    LoadViewAll : function(component) {
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        var patientId = component.get("v.patId");
        component.set('v.mycolumns', [
            
            {
                label: 'Claim Name',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
            },
           /* {label: 'Claim Status ', fieldName:   'ElixirSuite__Claim_Status__c', type: 'text'},*/
            {label: 'Payer Name', fieldName:   'ElixirSuite__Payor__c', type: 'text'},
            {label: 'Charges($)', fieldName:   'ElixirSuite__Total_Charge__c', type: 'currency'},
            {label: 'Insurance Payments($)', fieldName:   'ElixirSuite__Total_Paid__c', type: 'currency'},
            {label: 'Adjustments($)', fieldName:   'ElixirSuite__Total_Adjustment__c', type: 'currency'}]);
        
        var action = component.get("c.BringDataViewAll");
        action.setParams({
            "recId": patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().ClaimToPost;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    /*  if(record.hasOwnProperty('ElixirSuite__Total_Charge__c')){
                        record.ElixirSuite__Total_Charge__c = '$ ' +   record.ElixirSuite__Total_Charge__c
                    }
                    else {
                        record['ElixirSuite__Total_Charge__c'] = '$ 0'
                    }
                     if(record.hasOwnProperty('ElixirSuite__Total_Paid__c')){
                        record.ElixirSuite__Total_Paid__c = '$ ' +   record.ElixirSuite__Total_Paid__c
                    }
                    else {
                        record['ElixirSuite__Total_Paid__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Total_Adjustment__c')){
                        record.ElixirSuite__Total_Adjustment__c = '$ ' +   record.ElixirSuite__Total_Adjustment__c
                    }
                    else {
                        record['ElixirSuite__Total_Adjustment__c'] = '$ 0'
                    }*/
                     if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Payor__c)){
                    record['ElixirSuite__Payor__c'] = record.ElixirSuite__Payor__r.Name;    
                    }
                });
                component.set("v.data", records);
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount", response.getReturnValue().totalCount);
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
            "url": 'lightning/r/ElixirSuite__Claim__c/'+recId+'/view'
        });
        urlEvent.fire();
        
        /*  switch (action.name) {

            case 'DELETE':
                component.set("v.showConfirmDialog",true);                
                break;
        }*/
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
        var action = component.get("c.BringFilterData");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          "recId": component.get("v.patId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().ClaimToPost;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                     /*    if(record.hasOwnProperty('ElixirSuite__Total_Charge__c')){
                        record.ElixirSuite__Total_Charge__c = '$ ' +   record.ElixirSuite__Total_Charge__c
                    }
                    else {
                        record['ElixirSuite__Total_Charge__c'] = '$ 0'
                    }
                     if(record.hasOwnProperty('ElixirSuite__Total_Paid__c')){
                        record.ElixirSuite__Total_Paid__c = '$ ' +   record.ElixirSuite__Total_Paid__c
                    }
                    else {
                        record['ElixirSuite__Total_Paid__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Total_Adjustment__c')){
                        record.ElixirSuite__Total_Adjustment__c = '$ ' +   record.ElixirSuite__Total_Adjustment__c
                    }
                    else {
                        record['ElixirSuite__Total_Adjustment__c'] = '$ 0'
                    }*/
                     if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Payor__c)){
                    record['ElixirSuite__Payor__c'] = record.ElixirSuite__Payor__r.Name;    
                    }
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    },
    checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
    },
    FilteredViewAll : function(component) {
        //  alert(component.get("v.Fdate"));   
        var action = component.get("c.BringFilterDataViewAll");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          "recId": component.get("v.patId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records = response.getReturnValue().ClaimToPost;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                     /*    if(record.hasOwnProperty('ElixirSuite__Total_Charge__c')){
                        record.ElixirSuite__Total_Charge__c = '$ ' +   record.ElixirSuite__Total_Charge__c
                    }
                    else {
                        record['ElixirSuite__Total_Charge__c'] = '$ 0'
                    }
                     if(record.hasOwnProperty('ElixirSuite__Total_Paid__c')){
                        record.ElixirSuite__Total_Paid__c = '$ ' +   record.ElixirSuite__Total_Paid__c
                    }
                    else {
                        record['ElixirSuite__Total_Paid__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Total_Adjustment__c')){
                        record.ElixirSuite__Total_Adjustment__c = '$ ' +   record.ElixirSuite__Total_Adjustment__c
                    }
                    else {
                        record['ElixirSuite__Total_Adjustment__c'] = '$ 0'
                    }*/
                     if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Payor__c)){
                    record['ElixirSuite__Payor__c'] = record.ElixirSuite__Payor__r.Name;    
                    }
                });
                component.set("v.data", records);
                component.set("v.totalCount", response.getReturnValue().totalCount);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData); 
            }
        });
        
        $A.enqueueAction(action);
    },
    openPopUp : function(component){
        if(component.get("v.disableNewButton")){
            var toastEvent = $A.get("e.force:showToast"); //Anusha -start -02/10/22
                toastEvent.setParams({
                    "type": "Error",
                    "title": "No claim Form has been Enabled",
                    "message": "Please Enable atleast one claim Form from custom settings"
                });
                toastEvent.fire(); //Anusha -End -02/10/22 
            return;
        } //Anusha - 02/11/22
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    fetchFilteredList: function(component){
        let parentData = component.get("v.parentData");
        let searchKeyword = component.get("v.searchKeyword");
      //  let listDetails =  component.get("v.data");
        var fillData = parentData.filter(function(dat) {
            return (dat.Name.toLowerCase()).includes(searchKeyword.toLowerCase());
        });
        component.set("v.data",fillData);
    }
})