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
                    
                    label: "Cost Of Care"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Cost Of Care"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:money",
                iconAlt: "Cost Of Care"
            });
        })
        
        
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        var actions = [
            { label: 'Delete', name: 'delete' } ];
        
        component.set('v.mycolumns', [
            
            {
                label: 'Estimate Record Name',
                fieldName: 'Name',
                type: 'button' ,typeAttributes: {label:  { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            
            
            {label: 'Patient Responsibility($)', fieldName: 'ElixirSuite__Patient_responsibility__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Insurer Responsibility($)', fieldName: 'ElixirSuite__Insurer_Responsibility__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            /*{label: 'In-Use', fieldName: 'Status__c ', type: 'text'},*/
            
            {fieldName: 'ElixirSuite__In_Use__c',label: "In-Use",type: "boolean",cellAttributes: {
                iconName: {
                    fieldName: 'IconName'
                },
                iconPosition: "left"
            }},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'
            }},
            {label: 'Created Time', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true
            }} ,
            
            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);
        var patientId = component.get("v.patId");
        var recordId = component.get("v.recdId");
        var action = component.get("c.BringData");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams ({
            patientIds : patientId,
            VOBId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().estimates;
                records.forEach(function(record){  
                   /* if(record.hasOwnProperty('ElixirSuite__Patient_responsibility__c')){
                        record.ElixirSuite__Patient_responsibility__c = '$ ' +   record.ElixirSuite__Patient_responsibility__c
                    }
                    else {
                        record['ElixirSuite__Patient_responsibility__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Insurer_Responsibility__c')){
                        record.ElixirSuite__Insurer_Responsibility__c = '$ ' +   record.ElixirSuite__Insurer_Responsibility__c
                    }
                    else {
                        record['ElixirSuite__Insurer_Responsibility__c'] = '$ 0'
                    }*/
                    if (record.ElixirSuite__In_Use__c == false) {
                        record.IconName = 'utility:close';
                    }
                    
                    record['linkName'] = '/'+record.Id;
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
            else {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        });
        
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                //alert('wrap List '+JSON.stringify(wrapList));
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action3);
        $A.enqueueAction(action);
    },
    LoadViewAll : function(component, event, helper) {
        var actions = [
            { label: 'Delete', name: 'delete' } ];
        
        
        component.set('v.mycolumns', [
            
            {
                label: 'Estimate RecordName',
                fieldName: 'Name',
                type: 'button' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            
            
            {label: 'Patient Responsibility($)', fieldName: 'ElixirSuite__Patient_responsibility__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Insurer Responsibility($)', fieldName: 'ElixirSuite__Insurer_Responsibility__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            /*{label: 'In-Use', fieldName: 'Status__c ', type: 'text'},*/
            
            {fieldName: 'ElixirSuite__In_Use__c',label: "In-Use",type: "boolean",cellAttributes: {
                iconName: {
                    fieldName: 'IconName'
                },
                iconPosition: "left"
            }},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'
            }},
            
            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);
        var patientId = component.get("v.patId");
        // var patientId = '0015Y00002k54MBQAY';
        var recordId = component.get("v.recordId");
        var action = component.get("c.BringDataViewAll");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams ({
            patientIds : patientId,
            VOBId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().estimates;
                records.forEach(function(record){  
                    /*if(record.hasOwnProperty('ElixirSuite__Patient_responsibility__c')){
                        record.ElixirSuite__Patient_responsibility__c = '$ ' +   record.ElixirSuite__Patient_responsibility__c
                    }
                    else {
                        record['ElixirSuite__Patient_responsibility__c'] = '$ 0'
                    }
                    if(record.hasOwnProperty('ElixirSuite__Insurer_Responsibility__c')){
                        record.ElixirSuite__Insurer_Responsibility__c = '$ ' +   record.ElixirSuite__Insurer_Responsibility__c
                    }
                    else {
                        record['ElixirSuite__Insurer_Responsibility__c'] = '$ 0'
                    }*/
                    if (record.ElixirSuite__In_Use__c == false) {
                        record.IconName = 'utility:close';
                    }
                    
                    record['linkName'] = '/'+record.Id;
                    /*var rec =  record.Status__c;
                    record.Status__c = rec.valueOf();*/
                    
                });
                component.set("v.data", records);
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
            else {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
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
        component.set("v.isConsoleView",true);
        component.set("v.estmateRecordId",event.getParam('row').Id);  
        component.set("v.recordName",event.getParam('row').Name); 
        var action = event.getParam( 'action' );
        var recId = component.get("v.estmateRecordId");
        if($A.util.isUndefinedOrNull(action.name)){
            component.set("v.openCOCViewMode",true);  
        }
        switch (action.name) {
            case 'recLink':
                component.set("v.openCOCViewMode",true);
                break; 
            case 'delete':
                var action1 = component.get("c.deleteEstimate");
                action1.setParams({
                    "toDelete": recId 
                });
                $A.enqueueAction(action1);
                $A.enqueueAction(component.get('c.doInit'));
                break;
        }
    },
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleRefreshInit : function(component, event, helper) {
        helper.helperMethod(component, event, helper);
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
        //End
    FilteredData1 : function(component, event, helper) {
        let flag = helper.computeDates(component, event, helper);
        if(flag == 1){
            return;
        }
        component.set("v.viewAllBool", false);
        component.set("v.viewAllBoolgo", true);
        var recordId = component.get("v.recordId");
        var patientId = component.get("v.patId");
        var action = component.get("c.BringDataViewAll");
        //  alert(component.get("v.Fdate"));   
        var action = component.get("c.BringFilterData");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          // recId :  component.get("v.patId")
                          patientIds : patientId,
                          VOBId : recordId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                if($A.util.isEmpty(response.getReturnValue())){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "NO RECORDS PRESENT IN THE SPECIFIED DATE!",
                        "message": "Please input different filter.",
                        
                    });
                    toastEvent.fire(); 
                }
                else {
                    
                    // helper.helperMethod(component, event, helper);
                    /*  component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(res));
                component.set("v.listDetails", records.formData);*/
                    
                    console.log('form data '+JSON.stringify(response.getReturnValue()));                
                    var records =response.getReturnValue().estimates;
                    records.forEach(function(record){  
                        if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Patient_responsibility__c)){
                            record.ElixirSuite__Patient_responsibility__c = '$ ' +   record.ElixirSuite__Patient_responsibility__c
                        }
                        else {
                            record.ElixirSuite__Patient_responsibility__c = '$ 0'
                        }
                        if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Insurer_Responsibility__c)){
                            record.ElixirSuite__Insurer_Responsibility__c = '$ ' +   record.ElixirSuite__Insurer_Responsibility__c
                        }
                        else {
                            record.ElixirSuite__Insurer_Responsibility__c = '$ 0'
                        }
                        /* if (record.In_Use__c) {
                        record.IconName = 'utility:check';
                    } else {
                        record.IconName = 'utility:close';
                    }*/
                    if (record.ElixirSuite__In_Use__c == false) {
                        record.IconName = 'utility:close';
                    }
                    //record.linkName = '/'+record.Id;
                    /*var rec =  record.Status__c;
                    record.Status__c = rec.valueOf();*/
                    
                });
                    component.set("v.data", records);
                    component.set("v.totalCount",response.getReturnValue().totalCount);
                    component.set("v.listDetails", records.formData);
                }
                
            }
            else {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        });
        
        $A.enqueueAction(action);
    },
    checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
    },
    FilteredViewAll : function(component, event, helper) {
        var patientId = component.get("v.patId");
        // var patientId = '0015Y00002k54MBQAY';
        var recordId = component.get("v.recordId");
        //  alert(component.get("v.Fdate"));   
        var action = component.get("c.BringFilterDataViewAll");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          patientId :  patientId,
                          VOBId : recordId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                if($A.util.isEmpty(response.getReturnValue().estimates)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "NO RECORDS PRESENT IN THE SPECIFIED DATE!",
                        "message": "Please input different filter.",
                        
                    });
                    toastEvent.fire(); 
                }
                else {
                    
                    // helper.helperMethod(component, event, helper);
                    /*  component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(res));
                component.set("v.listDetails", records.formData);*/
                    
                    console.log('form data '+JSON.stringify(response.getReturnValue()));                
                    var records =response.getReturnValue().estimates;
                    records.forEach(function(record){  
                        if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Patient_responsibility__c)){
                            record.ElixirSuite__Patient_responsibility__c = '$ ' +   record.ElixirSuite__Patient_responsibility__c
                        }
                        else {
                            record.ElixirSuite__Patient_responsibility__c = '$ 0'
                        }
                        if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Insurer_Responsibility__c)){
                            record.ElixirSuite__Insurer_Responsibility__c = '$ ' +   record.ElixirSuite__Insurer_Responsibility__c
                        }
                        else {
                            record.ElixirSuite__Insurer_Responsibility__c = '$ 0'
                        }
                        /* if (record.In_Use__c) {
                        record.IconName = 'utility:check';
                    } else {
                        record.IconName = 'utility:close';
                    }*/
                    if (record.ElixirSuite__In_Use__c == false) {
                        record.IconName = 'utility:close';
                    }
                    //record.linkName = '/'+record.Id;
                    /*var rec =  record.Status__c;
                    record.Status__c = rec.valueOf();*/
                    
                });
                    /* var data1=component.get("v.data"); //Added by Avani Jain
                data1.push(records); //Added by Avani Jain
                component.set("v.data", data1); //changed by Avani Jain*/
                    component.set("v.data", records);
                    // console.log("Data is:"+JSON.stringify(records));
                    component.set("v.totalCount",response.getReturnValue().totalCount);
                    component.set("v.listDetails", records.formData);
                }
                
            }
            else {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        });
         
         $A.enqueueAction(action);
     },
    openPopUp : function(component,event){
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    opennew:function(component,event){
        component.set("v.isConsoleView",true);
        component.set("v.openCOCNewMode",true);
    }
    
})