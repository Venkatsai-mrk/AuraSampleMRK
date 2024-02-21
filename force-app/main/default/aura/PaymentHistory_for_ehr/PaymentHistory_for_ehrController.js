({
    doInit : function(component, event, helper) {
        helper.fetchAccountName(component, event, helper) ;
        
        
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
                    
                    label: "Payment"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Payment"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:payment_gateway",
                iconAlt: "Payment"
            });
        })
        
        
        
        var nameSpace='ElixirSuite__';
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        
        component.set('v.mycolumns', [
            
                         {
                 label: 'Transaction Number',
                 fieldName: 'linkName',
                 type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
             },
             {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                 day: 'numeric',  
                 month: 'short',  
                 year: 'numeric'  
              /*   hour: '2-digit',  
                 minute: '2-digit',  
                 second: '2-digit',  
                 hour12: true*/}},
             {label: 'Mode of Payment', fieldName:  nameSpace+ 'Mode_of_Payment__c', type: 'text'},
             //{label: 'Payment Type', fieldName:   'Payment_By__c', type: 'text'},
            /* {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                 day: 'numeric',  
                 month: 'short',  
                 year: 'numeric',  
                 hour: '2-digit',  
                 minute: '2-digit',  
                 second: '2-digit',  
                 hour12: true}},*/
           /*  {label: 'Received From', fieldName:  nameSpace+ 'Payment_Received_By__c', type: 'text'},*/
             {label: 'Amount Received ($)', fieldName:  nameSpace+ 'Total_Amount_Paid__c', type: 'currency',
             typeAttributes: { step: '0.00001', minimumFractionDigits: '2', maximumFractionDigits: '2'},
             }
            // {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
            
            
            
            
        ]);
        var patientId = component.get("v.patId");
        var action = component.get("c.BringData");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                });
                component.set("v.data", records);
                //console.log('final ' + JSON.stringify(res));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                
            }
        });
        
        $A.enqueueAction(action);
        
        
        
    },
    
    
    newPayment : function(component, event, helper) {
         var action = component.get("c.getPaymentSetting"); //added by jami
        action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            console.log('resp.ElixirSuite__Square_Payment__c'+resp.ElixirSuite__Square_Payment__c);
             console.log('resp.ElixirSuite__Elixir_Payment__c'+resp.ElixirSuite__Elixir_Payment__c);
            if(resp.ElixirSuite__Square_Payment__c == true && resp.ElixirSuite__Elixir_Payment__c ==true){
                component.set("v.collectPayment" , false);
                component.set("v.payPosting" , true);
                }
             if(resp.ElixirSuite__Square_Payment__c == true && resp.ElixirSuite__Elixir_Payment__c ==false){
                component.set("v.collectPayment" , true);
                component.set("v.payPosting" , false);
                }
            if(resp.ElixirSuite__Square_Payment__c == false && resp.ElixirSuite__Elixir_Payment__c ==true){
                component.set("v.collectPayment" , false);
                component.set("v.payPosting" , true);
            }
            });
		$A.enqueueAction(action);
        
         // component.set("v.openNewButton", true);
        
    },
    
    
    
    
    LoadViewAll : function(component, event, helper) {
        
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        var nameSpace ='ElixirSuite__';
         component.set('v.mycolumns', [
             
            {
                 label: 'Transaction Number',
                 fieldName: 'linkName',
                 type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
             },
             {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                 day: 'numeric',  
                 month: 'short',  
                 year: 'numeric'}},
             {label: 'Mode of Payment', fieldName:   nameSpace+'Mode_of_Payment__c', type: 'text'},
           /*  {label: 'Received From', fieldName:   nameSpace+'Payment_Received_By__c', type: 'text'},*/
             {label: 'Amount Received ($)', fieldName:   nameSpace+'Total_Amount_Paid__c', type: 'currency',
             typeAttributes: { step: '0.00001', minimumFractionDigits: '2', maximumFractionDigits: '2'},
             }
             // {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
             
             
             
             
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
                 var records =response.getReturnValue().transactions;
                 records.forEach(function(record){
                     record['linkName'] = '/'+record.Id;
                 });
                 component.set("v.data", records);
                 component.set("v.listDetails", records.formData);
                 component.set("v.totalCount",response.getReturnValue().totalCount);
             }
         });
         
         $A.enqueueAction(action);
         
     },
    
    
    selectedRows : function(component, event, helper) {
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
    handleRowAction : function(component, event, helper) {
        
        var recId = event.getParam('row').Id;
        //alert(recId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'lightning/r/ElixirSuite__Master_Transaction__c/'+recId+'/view'
        });
        urlEvent.fire();
        
    },
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component, event, helper) {
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
    sendSelectedClaimId: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        console.log('claim IDs'+selectedIds);
        var action = cmp.get("c.generateXML");
        action.setParams({ claimIds : selectedIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                
            }
        });
        $A.enqueueAction(action);
        
    },
    deleteSelectedRows: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.deleteSelectedHelper(component, event, selectedIds);
    },
    updateSelectedRows: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.updateSelectedHelper(component, event, selectedIds);
    },
    createClaim : function(component, event, helper) {
        var recordEvent=$A.get("e.force:createRecord");
        recordEvent.setParams({
            "entityApiName": "ElixirSuite__Claim__c",
            "defaultFieldValues":{
                
            }
        });
        recordEvent.fire();
    },
    FilteredData1 : function(component, event, helper) {
        let flag = helper.computeDates(component, event, helper);
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
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                //console.log('final ' + JSON.stringify(res));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
    },
    checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
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
                "recordId": component.get("v.patId")
            });
            navEvt.fire();
        },
    
    FilteredViewAll : function(component, event, helper) {
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
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                //console.log('final ' + JSON.stringify(res));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
    },
    openPopUp : function(component,event){
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    
})