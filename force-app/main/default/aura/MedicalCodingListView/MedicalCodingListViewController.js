({
    
    init: function(component, event, helper) {
        helper.fetchAccountName(component, event, helper) ;
        helper.fetchTimeZoneofUser(component, event, helper);
        //  var recId = component.get("v.recordVal");
        // var nameSpace = 'ElixirSuite__';
        //helper.fetchNspc(component, event, helper);
        component.set("v.inProcessProc",true);
        console.log(component.get("v.isOpen"));
        console.log('upd3****');
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
                    label: "Medical Coding"
                });
            } else if (response.subtabs && response.subtabs.length > 0) {
                workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                    console.log('tabId: response.subtabs[0].tabId: ' + response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Medical Coding"
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
        
        
        var actions = [
            {label: 'Edit', name: 'EDIT'},
            {label: 'Delete', name: 'DELETE'}
        ];
        component.set("v.loaded",false);        
        var action = component.get("c.procedureList");
        action.setParams({  
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                let csColumns  = response.getReturnValue().columns;
                let resp = response.getReturnValue().lstOfAllProcedures;
                resp.forEach(function(column){                    
                    column['procedureName'] = column.Name; //proc code/name 
                    column['procDesc'] = column.ElixirSuite__Code_Description__c;
                    //venkat Changed as per LX3-6384
                    //  column['modifier2']= column.ElixirSuite__Modifier2__c;
                    //column['modifier3']= column.ElixirSuite__Modifier3__c;
                    // column['modifier4']= column.ElixirSuite__Modifier4__c;
                    column['diagCode']= ' ';
                    column['procStart']= column.ElixirSuite__From_Date_of_Service__c;
                    column['procEnd']= column.ElixirSuite__To_Date_of_Service__c;
                    column['duration']= column.ElixirSuite__Days_Units__c;
                    column['placeOfService']= column.ElixirSuite__Place_Of_Service_Picklist__c;
                    if(column.ElixirSuite__Claim__c !== undefined)
                        column['claimStatus']= column.ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c;       
                    column['readyForBilling']= column.ElixirSuite__Ready_for_Billing__c;     
                    column['claimGenerated']= column.ElixirSuite__Claim_Generation__c;      
                    column['isProcessed']= column.ElixirSuite__Is_Processed__c;  
                      // added by jami for LX3-11839
                      column['status']= column.ElixirSuite__Status__c; 
                      column['cancelationReason']= column.ElixirSuite__Cancelation_Reason__c;
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Modifier1__r)){
                        column['modifier1']= column.ElixirSuite__Modifier1__r.Name;
                    }
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Visits__r)){
                        column['careEpisode']= column.ElixirSuite__Visits__r.Name;
                    }
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Modifier2__r)){
                        column['modifier2']= column.ElixirSuite__Modifier2__r.Name;
                    }
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Modifier3__r)){
                        column['modifier3']= column.ElixirSuite__Modifier3__r.Name;
                    }
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Modifier4__r)){
                        column['modifier4']= column.ElixirSuite__Modifier4__r.Name;
                    }
                    var column2 = [];
                    column2 = column.ElixirSuite__Procedure_Diagnosis__r ;
                    if(!$A.util.isUndefinedOrNull(column2)){
                        column2.forEach(function(col2){
                            if(column['diagCode'] === ' ')
                                column['diagCode']= col2.ElixirSuite__ICD_Codes__r.Name;  
                            else{
                                column['diagCode']= column['diagCode'] + ', ' + col2.ElixirSuite__ICD_Codes__r.Name; 
                            }
                        });
                    }
                    
                    
                });
                component.set('v.mycolumns', [                        
                    { label: 'Procedure Code', fieldName: 'procedureName', type:'button' ,typeAttributes:  {label: { fieldName: 'procedureName' }, target: '_blank',name:'recLink',variant:'Base' } },
                    { label: 'Procedure Description', fieldName: 'procDesc', type: 'text' },   
                    
                    
                ]);
                    
                    let mapOfApiAndLabel = 
                    {"modifier1" :"Modifier 1",
                    "modifier2" :"Modifier 2",
                    "modifier3" :"Modifier 3",
                    "modifier4" :"Modifier 4",
                    "diagCode" : "Diagnosis Codes",
                    "procStart" :"Procedure Start Date/Time",
                    "procEnd" :"Procedure End Date/Time",
                    "duration" :"Units/Duration",
                    "placeOfService" :"Place Of Service",
                    "claimStatus" :"Claim Status",
                    "readyForBilling" :"Is Ready For Billing",
                    "claimGenerated" :"Claim Generated",
                    "isProcessed" :"Is Processed",
                    "careEpisode" : "Care Episode",
                    "status":"Status",
                            "cancelationReason":"Cancelation Reason"
                    //   "CreatedBy" :"Created By",
                    };
                    let toAddCol = component.get('v.mycolumns');
                    if(!$A.util.isUndefinedOrNull(csColumns)){
                    let csColArr = csColumns.split(';');                      
                    if(csColumns){
                    for(let recSObj in csColArr){
                    if(csColArr[recSObj] == 'procStart' || csColArr[recSObj] == 'procEnd'){
                    toAddCol.push({label: mapOfApiAndLabel[csColArr[recSObj]], fieldName: csColArr[recSObj],type: 'date',
                                   typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true, timeZone: component.get('v.timeZone')}
                                  });
                    
                }
                else if(csColArr[recSObj] == 'readyForBilling' || csColArr[recSObj] == 'claimGenerated' || csColArr[recSObj] == 'isProcessed'){
                    toAddCol.push({label:  mapOfApiAndLabel[csColArr[recSObj]], fieldName:  csColArr[recSObj],type: 'boolean'});
                }
                else if(csColArr[recSObj] == 'careEpisode'){
                        toAddCol.push({
                label: mapOfApiAndLabel[csColArr[recSObj]],
                title:mapOfApiAndLabel[csColArr[recSObj]],
                fieldName: csColArr[recSObj],
                type: 'button', typeAttributes:
                { label: { fieldName: csColArr[recSObj]}, title: 'Click to edit Care Episode', 
                variant:'base', 
                name: 'edit_care', 
                iconName: 'utility:edit', 
                class: 'slds-align_absolute-center'}
            }); 
                    }
                    else{
                        toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]], 
                                       fieldName: csColArr[recSObj], type: 'text' , title:mapOfApiAndLabel[csColArr[recSObj]] }); 
                    }
            }
        }
                           }
                           toAddCol.push({label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
                           typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true, timeZone: component.get('v.timeZone')}});
/*  toAddCol.push( { label: 'Created By ', fieldName: 'createdBy', type: 'text'});
        toAddCol.push({label: 'LastModifiedDate', fieldName: 'LastModifiedDate',type: 'date',
                       typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
        */
toAddCol.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }); 
component.set('v.mycolumns',toAddCol); 

component.set("v.listDetails", resp);
component.set("v.loaded",true);

}
else
{
    console.log("failure");
}
});
$A.enqueueAction(action);
helper.getDetails(component,event,helper);

},
    historicData:function(component,event,helper){
        helper.getDetails(component,event,helper);
    } ,
        
        showOptions:function(cmp){
            cmp.set("v.showOptions",true); 
        },
            showOptionsHistorical : function(cmp){
                cmp.set("v.showOptionsHistoric",true); 
            },
                New : function(component, event, helper){
                    component.set("v.isConsoleView",true);
                    var action = component.get("c.getProblemRecords");
                    action.setParams({  
                        recId : component.get("v.recordVal") ,
                    });
                    action.setCallback(this, function(response){
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            //  let resp  = response.getReturnValue();
                            /*if(resp == false){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "No Problems Available",
                        "message": "No problems defined for the patient. Please define a problem first!"
                    });
                    toastEvent.fire();
                }
                else{*/
                //component.set("v.openNewProcedure",true); 
                helper.checkCareEpisodehelper(component,event,helper,component.get("v.recordVal"));//NK----LX3-5932
                //}
            }
            else{
                console.log("failure");
            }
        });
            $A.enqueueAction(action);
            
        },
            
            handleChange: function (cmp, event) {
                var changeValue = event.getParam("value");
                //alert(changeValue);
                if(changeValue =='In Process Procedures'){
                    cmp.set("v.inProcessProc",true);
                    cmp.set("v.heading",'Medical Coding (In Process Procedures)');
                    cmp.set("v.historicalProc",false);
                }
                else if(changeValue =='Historical Procedures'){
                    cmp.set("v.historicalProc",true);
                    cmp.set("v.heading",'Medical Coding (Historical Procedures)');
                    cmp.set("v.inProcessProc",false);
                }
            },
                handleRowAction: function(component, event) {
                    try{
                         component.set("v.isConsoleView",true);
                        var action = event.getParam('action');
                        component.set("v.actionName",action);
                        console.log(action.name);
                        var row = event.getParam('row');
                        component.set("v.RowId",row.Id);
                        component.set("v.PrevCareId",row.ElixirSuite__Visits__c);
                        component.set("v.SelectedRec", row);
                        
                        
                        switch (component.get("v.actionName").name) {
                            case 'EDIT':
                                component.set("v.mode", 'Edit ');
                                component.set("v.AllFlag", false);
                                component.set("v.openSelectedRecord", true);                    
                                break;  
                            case 'edit_care':
                                let inlineEditComponent = component.find("inlineEditCare");
                                inlineEditComponent.open();
                                component.set("v.isConsoleView", false);
                                break;
                            case 'recLink':
                                component.set("v.mode", 'View ');
                                component.set("v.AllFlag", true);
                                component.set("v.openSelectedRecord", true) ;
                                break;   
                            case 'DELETE':
                                component.set("v.showConfirmDialog",true);                                                 
                                break;
                                
                        }
                    }
                    catch(e){
                        alert('error '+e);
                    }
                    
                    
                    
                }, 
                    
                    handleRowActionHistoric: function(component, event) {
                        try{
                            var action = event.getParam('action');
                            component.set("v.actionName",action);
                            console.log(action.name);
                            var row = event.getParam('row');
                            component.set("v.RowId",row.Id);
                            component.set("v.PrevCareId",row.ElixirSuite__Visits__c);
                            component.set("v.SelectedRec", row);
                            
                            
                            switch (component.get("v.actionName").name) {
                                    
                                case 'recLink':
                                    component.set("v.mode", 'View ');
                                    component.set("v.AllFlag", true);
                                    component.set("v.openSelectedRecord", true) ;
                                    break;   
                                case 'edit_care':
                                let inlineEditComponent = component.find("inlineEditCare");
                                inlineEditComponent.open();
                                component.set("v.isConsoleView", false);
                                break;
                                    
                            }
                        }
                        catch(e){
                            alert('error '+e);
                        }
                        
                        
                        
                    }, 
                        
                        sortColumn : function (component, event, helper) {
                            try{
                                var fieldName = event.getParam('fieldName');
                                var sortDirection = event.getParam('sortDirection');
                                component.set("v.sortedBy", fieldName);
                                component.set("v.sortedDirection", sortDirection);
                                helper.sortData(component, fieldName, sortDirection);
                            }
                            catch(e){
                                alert('error '+e);
                            }
                            
                        },
                            
                            
                            sortColumnHist : function (component, event, helper) {
                                try{
                                    var fieldName = event.getParam('fieldName');
                                    var sortDirection = event.getParam('sortDirection');
                                    component.set("v.sortedByHist", fieldName);
                                    component.set("v.sortedDirectionHist", sortDirection);
                                    helper.sortDataHist(component, fieldName, sortDirection);
                                }
                                catch(e){
                                    alert('error '+e);
                                }
                                
                            },
                                
                                handleConfirmDialogNo : function(component) {
                                    component.set("v.showConfirmDialog",false);  
component.set("v.isConsoleView", false);
                                },
                                    handleConfirmDialogYes : function(component) {
                                        var action = component.get("c.deleteRecord");
                                        action.setParams({  
                                            recId : component.get("v.RowId") ,
                                        });
                                        action.setCallback(this, function(response){
                                            var state = response.getState();
                                            if (state === "SUCCESS") {
                                                let resp  = response.getReturnValue();
                                                component.set("v.showConfirmDialog",false);  
                                                var toastEvent = $A.get("e.force:showToast");
                                                if(resp == true){
                                                    toastEvent.setParams({
                                                        "type": "Success",
                                                        "title": "RECORD DELETED SUCCESSFULLY!",
                                                        "message": "Deletion Successfull!"
                                                    });
                                                    toastEvent.fire();
                                                }
                                                else{
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
                                        
                                        var action2 = component.get("c.init");
                                        $A.enqueueAction(action2);
component.set("v.isConsoleView", false);
                                    },
                                        //Added by Ashwini//
                                        navToListView: function() {
                                            // Sets the route to /lightning/o/Account/home
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
                                                
})