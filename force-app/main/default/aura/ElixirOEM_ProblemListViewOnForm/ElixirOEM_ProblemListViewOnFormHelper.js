({
    sortData: function (cmp, helper, fieldName, sortDirection) {
        var data = cmp.get("v.allData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.allData", data);
        helper.buildData(cmp, helper);
    },
    
    //for selecting order of sorting
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    setTime: function(cmp,helper){
        var currentTime = cmp.get("v.time");
        cmp.set("v.time", (currentTime+1));
    },
    helperMethod : function(component, event, helper) {
        component.set("v.newEncounter",false);         
    },
    fetchListViewData : function(component, event, helper) {
        var action = component.get("c.problemList");
        action.setParams({  
            accountId : component.get("v.recordVal") ,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('res '+JSON.stringify(response.getReturnValue()));
                let resp = response.getReturnValue().lstOfAllProblemPerAccount;
                resp.forEach(function(column){ 
                    column['ProblemName'] = column.ElixirSuite__Problem__r.Name;
                    column['ICD'] = column.ElixirSuite__Diagnosis_Code__r.Name;
                    console.log('sre '+JSON.stringify(column));
                });
                
                console.log('response '+JSON.stringify(response.getReturnValue()));
                component.set("v.listDetails", resp);
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
    },
    deleteSelectedRecordRecord : function(component, event, helper) {
        var action = component.get("c.deleteRecord");
        action.setParams({  
            recId : component.get("v.RowId") ,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response after del '+JSON.stringify(response.getReturnValue()));
               
                helper.doiInitReplica(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "RECORD DELETED SUCCESSFULLY!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.listDetails");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.listDetails", data);
    },
    
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    doiInitReplica : function(component, event, helper) {
        try{
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                // var focusedTabId = response.tabId;
                // console.log('afcresponse',response);
                var focusedTabId = response.tabId;
                var issubTab = response.isSubtab;
                console.log('afctab',focusedTabId);
                if(issubTab)
                {
                    workspaceAPI.getTabInfo(
                        { tabId:focusedTabId}
                    ).then(function(response1){
                        
                        console.log('afctabinfo',response1);
                    });
                    workspaceAPI.setTabLabel({
                        
                        label: "Master Problem List"
                    });                
                }
                else 
                { 
                    workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                        console.log('afctabinfo----',response1);
                    });
                    workspaceAPI.setTabLabel({
                        label: "Master Problem List"
                    });         
                }     
                
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "utility:answer",
                    iconAlt: "Master Problem List"
                });
            })
            
            console.log('in init');
            var actions = [
                {label: 'EDIT', name: 'EDIT'},
                {label: 'Delete', name: 'DELETE'}
            ];
            component.set("v.loaded",false);
            var action = component.get("c.problemList");
            action.setParams({  
                accountId : component.get("v.recordVal") ,
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded",true);
                    console.log('res '+JSON.stringify(response.getReturnValue()));
                    let csColumns  = response.getReturnValue().columns;
                    let resp = response.getReturnValue().lstOfAllProblemPerAccount;
                    resp.forEach(function(column){                       
                        column['ProblemName'] = column.ElixirSuite__Problem__r.Name;
                        column['ICD'] = column.ElixirSuite__Diagnosis_Code__r.Name;
                        column['icdVersion']= column.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;
                        column['snowmedCtCode']= column.ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c;
                        column['status']= column.ElixirSuite__Problem__r.ElixirSuite__Status__c;
                        column['problemType']= column.ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c;
                        column['dateDiagonised']= column.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c;
                        column['description']= column.ElixirSuite__Problem__r.ElixirSuite__ICD_Description__c;
                        column['diagnosisType']= column.ElixirSuite__Problem__r.ElixirSuite__Diagnosis_Type__c;
                        column['dateOnset']= column.ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c;
                        column['Notes']= column.ElixirSuite__Problem__r.ElixirSuite__Note__c;
                        column['diagnosisId']= column.ElixirSuite__Diagnosis_Code__r.Id;       
                        column['createdBy']= column.CreatedBy.Name;       
                    });
                    component.set('v.mycolumns', [                        
                        { label: 'Problem Name', fieldName: 'ProblemName', type:'button' ,typeAttributes:  {label: { fieldName: 'ProblemName' }, target: '_blank',name:'recLink',variant:'Base' } },
                        { label: 'ICD ', fieldName: 'ICD', type: 'text'},   
                        
                        
                    ]);
                        // icdVersion;snowmedCtCode;status;problemType;dateDiagonised;dateOnset;Notes	
                        let mapOfApiAndLabel =  {"icdVersion" :"ICD Version",
                        "snowmedCtCode" :"SNOMED CT Code",
                        "status" :"Status",
                        "problemType" :"Problem Type",
                        "dateDiagonised" :"Date Diagonised",
                        "dateOnset" :"Date Onset",
                        "Notes" :"Notes",
                        };
                        let toAddCol = component.get('v.mycolumns');
                        if(!$A.util.isUndefinedOrNull(csColumns)){
                        let csColArr = csColumns.split(';');                      
                        if(csColumns){
                        for(let recSObj in csColArr){
                        toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]], 
                                  fieldName: csColArr[recSObj], type: 'text'});  
                }
                
            }
                               
                               }
                               toAddCol.push({label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
                               typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
            toAddCol.push( { label: 'Created By ', fieldName: 'createdBy', type: 'text'});
            toAddCol.push({label: 'LastModifiedDate', fieldName: 'LastModifiedDate',type: 'date',
                           typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
            toAddCol.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }); 
            component.set('v.mycolumns',toAddCol); 
            
            /*     var columns = event.getParam("columns");
                    var columnsToShow = [];
                    if(!$A.util.isUndefinedOrNull(columns)){
                        alert('inside columns');
                        tableColumns.forEach(function(column){ 
                            if(columns.includes(column.fieldName)){
                                columnsToShow.push(column);
                            }        
                        });
                        //   columnsToShow = [nameOfForm,...columnsToShow,dateOfCreation,actionToShow];
                        component.set('v.mycolumns',columnsToShow); 
                    }*/
            console.log('response '+JSON.stringify(response.getReturnValue()));
            component.set("v.listDetails", resp);
            component.set("v.loaded",true);
            
        }else{
            console.log("failure");
        }
      });
    $A.enqueueAction(action);
}
 catch(e){
    alert('error '+e);
}


},
})