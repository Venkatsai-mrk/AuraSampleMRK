({
    doInit : function(component) {
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        console.log('line6***Proc25');
        var actions = [
            {label: 'Edit', name: 'EDIT'},
            {label: 'Delete', name: 'DELETE'}
        ];
        var patientId = component.get("v.patId");
        component.set('v.mycolumns', [ 
            { label: 'Procedure Code', fieldName: 'linkName', type:'button' ,typeAttributes:  {label: { fieldName: 'Name' }, target: '_blank',name:'recLink',variant:'Base' } },
            { label: 'Care Episode', fieldName: 'careName', type:'button' ,typeAttributes:  {label: { fieldName: 'careEpisode' }, target: '_blank',name:'careRecLink',variant:'Base' } },
            {label: 'Is Billable ', fieldName:   'ElixirSuite__Is_Billable__c', type: "boolean",cellAttributes: {
                iconName: {
                    fieldName: 'IconName'
                },
                iconPosition: "left"
            }},
            {label: 'Type of Billing', fieldName:   'ElixirSuite__Type_of_Procedure__c', type: 'text'},
            {label: 'Procedure Description', fieldName:   'ElixirSuite__Code_Description__c', type: 'text'},
            {label: 'DOS', fieldName:   'ElixirSuite__From_Date_of_Service__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'
            }},
            {fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions }}]);
        
        var action = component.get("c.BringDataFirst");
        action.setParams({
            "recId": patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                //console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().procToPost;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    if (record.ElixirSuite__Is_Billable__c == false) {
                        record.IconName = 'utility:close';
                    }

                    if (record.ElixirSuite__Visits__c != null) {
                        record.careEpisode = record.ElixirSuite__Visits__r.Name;
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
        var patientId = component.get("v.patId");
        var actions = [
            {label: 'Edit', name: 'EDIT'},
            {label: 'Delete', name: 'DELETE'}
        ];
        component.set('v.mycolumns', [
            
            { label: 'Procedure Code', fieldName: 'linkName', type:'button' ,typeAttributes:  {label: { fieldName: 'Name' }, target: '_blank',name:'recLink',variant:'Base' } },
            { label: 'Care Episode', fieldName: 'careName', type:'button' ,typeAttributes:  {label: { fieldName: 'careEpisode' }, target: '_blank',name:'careRecLink',variant:'Base' } },
            {label: 'Is Billable ', fieldName:   'ElixirSuite__Is_Billable__c', type: "boolean",cellAttributes: {
                iconName: {
                    fieldName: 'IconName'
                },
                iconPosition: "left"
            }},
            {label: 'Type of Billing', fieldName:   'ElixirSuite__Type_of_Procedure__c', type: 'text'},
            {label: 'Procedure Description', fieldName:   'ElixirSuite__Code_Description__c', type: 'text'},
            {label: 'DOS', fieldName:   'ElixirSuite__From_Date_of_Service__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'
            }},
         {fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions }}]);
        
        var action = component.get("c.BringDataViewAll");
        action.setParams({
            "recId": patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                //console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().procToPost;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    if (record.ElixirSuite__Is_Billable__c == false) {
                        record.IconName = 'utility:close';
                    }
            if (record.ElixirSuite__Visits__c != null) {
                        record.careEpisode = record.ElixirSuite__Visits__r.Name;
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
        
        var recId = event.getParam('row');
        var action = event.getParam('action');
        component.set("v.RowId",recId.Id);
        component.set("v.SelectedRec", recId);
        
        if($A.util.isUndefinedOrNull(action.name)){
            component.set("v.medicalCodingScreenEdit",true);  
        }
        switch (action.name) {
            case 'recLink':
                component.set("v.mode", 'View ');
                component.set("v.AllFlag", true);
                component.set("v.medicalCodingScreenEdit",true);
                break;      
                
        case 'careRecLink':
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recId.ElixirSuite__Visits__c
                });
                navEvt.fire();
                break;   
                
            case 'EDIT':
                component.set("v.mode", 'Edit ');
                component.set("v.AllFlag", false);
                component.set("v.medicalCodingScreenEdit",true);
                break;  
                
            case 'DELETE':
                component.set("v.showConfirmDialog",true);          
                break;  
        }
    },
    
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component) {
       var action = component.get("c.deleteRec");
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({  
            recId : component.get("v.RowId") ,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               let resp  = response.getReturnValue();
                component.set("v.showConfirmDialog",false);  
                if(resp == true){
                //var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "RECORD DELETED SUCCESSFULLY!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
                }
                else{
                 //   var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "RECORD COULD NOT BE DELETED!",
                    "message": "This procedure is added to a claim. You can not delete this procedure!"
                });
                toastEvent.fire();
                }
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
        var action2 = component.get("c.doInit");
          $A.enqueueAction(action2);
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
        console.log('flag**',flag);
        if(flag == 1){
            return;
        }
        component.set("v.viewAllBool", false);
        component.set("v.viewAllBoolgo", true);
        var action = component.get("c.BringFilterData");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          recId: component.get("v.patId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data****'+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().procToPost;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
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
                          recId: component.get("v.patId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records = response.getReturnValue().procToPost;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
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
        component.set("v.medicalCodingScreen",true);  
    },
    fetchFilteredList: function(component){
        let parentData = component.get("v.parentData");
        let searchKeyword = component.get("v.searchKeyword");
       // let listDetails =  component.get("v.data");
        var fillData = parentData.filter(function(dat) {
            return (dat.Name.toLowerCase()).includes(searchKeyword.toLowerCase());
        });
        component.set("v.data",fillData);
    }
})