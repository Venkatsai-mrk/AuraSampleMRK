({
    doInit: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var nameSpace = 'ElixirSuite__';
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            // var focusedTabId = response.tabId;
            console.log('afcresponse',response);
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
                    
                    label: "Urine Analysis"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Urine Analysis"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:underline",
                iconAlt: "Urine Analysis"
            });
        })
        
        var actions = [
            {label: 'EDIT', name: 'EDIT'},
            {label: 'DELETE', name: 'DELETE'},
            
        ];
            //var nameSpace = '' ;
            component.set('v.mycolumns', [{
            label: 'Analysis',
            fieldName: 'Name',
            type: 'button' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            {label: 'Physical Analysis Result', fieldName:  'AnalysisResult', type: 'text',sortable: true},
            {label: 'Status', fieldName:  nameSpace+'Status__c', type: 'text',sortable: true},
            {label: 'Physical Analysis Date', fieldName: 'ExaminedDate', type: 'Date',sortable: true},
        /*    {label: 'Laboratory Analysis Date', fieldName:  'LabExaminedDate', type: 'Date',sortable: true},*/
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'}},
            {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }  ]);
        
        var action = component.get("c.fetchAllRelatedUrineAnalysisRecordsForAccount");
        action.setParams({ accountId : component.get("v.patientID") });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                console.log('UA  data '+JSON.stringify(response.getReturnValue()));                              
                var rows = response.getReturnValue().toReturnList;
                
                component.set("v.nameSpace" , response.getReturnValue().namespace);
                
                var nmsp = 'ElixirSuite__';
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    console.log('row 1234 ' + JSON.stringify(row)); 
                    
                /*    if ($A.util.isUndefinedOrNull(row['Laboratory_Analysis_Date__c']) && $A.util.isEmpty(row['Laboratory_Analysis_Date__c'])) {
                        row.LabExaminedDate = 'Currently Unavailable' ; 
                    }
                    else{
                        if(!$A.util.isUndefinedOrNull(row['Laboratory_Analysis_Date__c'])) {
                            row.LabExaminedDate = row['Laboratory_Analysis_Date__c'];
                        }
                    }*/
                    
                    if ($A.util.isUndefinedOrNull(row[nmsp+'Sample_Analysis__r']) && $A.util.isEmpty(row[nmsp+'Sample_Analysis__r'])) {
                        row.AnalysisResult= 'Currently Unavailable';
                        row.ExaminedDate= 'Currently Unavailable' ; 
                    //    console.log('abc' , row['Sample_Analysis__r'][0]['Lab_Sample_Examined_Datetime__c']);
                  //      row.LabExaminedDate = 'Currently Unavailable' ; 
                    }
                    else {
                        if(!$A.util.isUndefinedOrNull(row[nmsp+'Sample_Analysis__r'][0][nmsp+'Status__c'])) {
                            row.AnalysisResult = row[nmsp+'Sample_Analysis__r'][0][nmsp+'Status__c'];
                        }
                        if(!$A.util.isUndefinedOrNull(row[nmsp+'Sample_Analysis__r'][0][nmsp+'Examined_Datetime__c'])) {
                            row.ExaminedDate = row[nmsp+'Sample_Analysis__r'][0][nmsp+'Examined_Datetime__c'].substring(0, 10);
                        }
                    /*   if(!$A.util.isUndefinedOrNull(row['Sample_Analysis__r'][0]['Lab_Sample_Examined_Datetime__c'])) {
                           alert('abv' , row['Sample_Analysis__r'][0]['Lab_Sample_Examined_Datetime__c'].substring(0, 10));
                            row.LabExaminedDate = row['Sample_Analysis__r'][0]['Lab_Sample_Examined_Datetime__c'].substring(0, 10);
                        } */
                    }
                    
                }
                
               
             /*   for(var rec in rows){
                    rows[rec].LastModifiedDate= rows[rec].LastModifiedDate.substring(0, 10);
                    
                }
                var labResults  = response.getReturnValue().toReturnList;
                for(var rec in rows){
                    for(var childRec in labResults){
                        if(childRec == rows[rec].Id){
                            if(!$A.util.isUndefinedOrNull(labResults[rows[rec].Id])){
                                var trimmedDate  = labResults[rows[rec].Id].substring(0, 10);
                                rows[rec]['Laboratory_Analysis_Date__c'] = trimmedDate;
                            }
                            else {
                                rows[rec]['Laboratory_Analysis_Date__c'] = '';
                            }
                        }
                        else {
                            rows[rec]['Laboratory_Analysis_Date__c'] = 'Currently Unavailable';

                    }
                    
                } */
                
           /*     if($A.util.isEmpty(labResults)){
                    for(var rec in rows){
                        rows[rec]['Laboratory_Analysis_Date__c'] = 'Currently Unavailable';
                    }
                }   */             
                component.set("v.data", rows);
                
                
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
    createUA : function(component, event, helper) {
         helper.checkCareEpisodehelper(component, event, helper,component.get("v.patientID"));//NK----LX3-5932
        //component.set("v.showUA",true);
    },
    selectedRows : function(component, event, helper) {
        
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));        
        component.set("v.selectedUARecords",event.getParam('selectedRows'));
        //  var selectedRows = component.get('v.selectedRows');
        var selectedRows =  event.getParam('selectedRows');
        var falg = false;
        for(var allRecords in selectedRows){
            if(selectedRows[allRecords].ElixirSuite__Status__c!='Open'){
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
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        console.log(action.name);
        var row = event.getParam('row');
        component.set("v.RowId",row.Id);
        console.log('row is 99 '+JSON.stringify(row.Id));
        component.set("v.SelectedRec",row);
        // component.set("v.PresId",event.getParams().row["Id"]);
        console.log('row3456 '+JSON.stringify( component.get("v.PresId")));    
        switch (action.name) {
            case 'EDIT':
                
                component.set("v.isEnabledEditButton",false);
                component.set("v.editScreenDisabled",false);
                component.set("v.editScreen",true);
                console.log('UA Id'+JSON.stringify(component.get("v.RowId")));
                
                break;
                
            case 'recLink':
                component.set("v.isEnabledEditButton",true);
                //component.set("v.editScreenDisabled",true);
                component.set("v.editScreen",true);
                // console.log('Lab Order Id'+JSON.stringify(component.get("v.RowId")));               
                break;
                
            case 'DELETE':
                
                if(row.ElixirSuite__Status__c=='Open'|| $A.util.isUndefinedOrNull(row.ElixirSuite__Status__c)) {
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
                        "title": "CANNOT DELETE AS STATUS IS "+row.ElixirSuite__Status__c.toUpperCase(),
                        "message": "Status is not open!!"
                    });
                    toastEvent.fire();
                    
                }
                break;
        }
    },
    handleClick : function(component, event, helper) {
        component.set("v.openNewForm",true);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        // component.set('v.IsSpinner',true);
        var row  = component.get("v.RowId");
        if(typeof(row)=="string" && !$A.util.isUndefinedOrNull(row)){
            helper.deleteSelectedHelper(component, event, helper,row);
        }
        else {         
            var arrToDelete  = [];
            arrToDelete.push(component.get("v.selectedUARecords"));
            var selectedRows = component.get("v.selectedUARecords");
            console.log('UA Id'+JSON.stringify(selectedRows));
            var selectedIds = [];
            for (var i = 0; i < selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].Id);
            }
            helper.deleteSelectedHelper(component, event, helper,selectedIds);
        }
        
    },
   
    deleteSelectedRows: function (component, event, helper) {    
        var cmpEvent = component.getEvent("LandingPage"); 
                    cmpEvent.fire();
        
        
        component.set("v.showConfirmDialog",true);  
    },
    sendToLab : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "UA Test has been successfully sent to the Lab",
                        "message": "Successfully sent"
                    });
                    toastEvent.fire();
                  
                    $A.get('e.force:refreshView').fire();
    }
    
})