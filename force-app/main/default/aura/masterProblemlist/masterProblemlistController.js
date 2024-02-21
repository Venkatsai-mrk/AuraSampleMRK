({
  myAction : function(component, event, helper) {
    helper.fetchAccountName(component, event, helper) ;
    try{
      var workspaceAPI = component.find("workspace");
      workspaceAPI.getFocusedTabInfo().then(function(response) {
        // var focusedTabId = response.tabId;
        // console.log('afcresponse',response);
        var focusedTabId = response.tabId;
        var issubTab = response.isSubtab;
        console.log("afctab", focusedTabId);
        if (issubTab)
         {
          workspaceAPI
            .getTabInfo({ tabId: focusedTabId })
            .then(function(response1) {
              console.log("afctabinfo", response1);
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
        { label: "Edit", name: "EDIT" },
        { label: "Delete", name: "DELETE" }
      ];
      component.set("v.loaded", false);
      var action = component.get("c.problemList");
      action.setParams({
        accountId : component.get("v.recordVal")
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.loaded", true);
          console.log("res " + JSON.stringify(response.getReturnValue()));
          let csColumns = response.getReturnValue().columns;
          console.log("Childselectedvalues" + csColumns);
          let resp = response.getReturnValue().lstOfAllProblemPerAccount;
          console.log("Response" + resp);
          resp.forEach(function(column) {
            /* column['ProblemName'] = column.Name;
                        column['ICD'] = '';
                        column['icdVersion']= '';
                        column['snowmedCtCode']= column.ElixirSuite__SNOMED_CT_Code__c;
                        column['status']= column.ElixirSuite__Status__c;
                        column['problemType']= column.ElixirSuite__Problem_Type__c;
                        column['dateDiagonised']= column.ElixirSuite__Date_Diagonised__c;
                        column['dateOnset']= column.ElixirSuite__Date_Onset__c;
                        column['Notes']= column.ElixirSuite__Note__c;
                        column['diagnosisId']= '';       
                        column['createdBy']= column.CreatedBy.Name;*/

            // commented as added the code for getting problems from dataset_1__c
                      // console.log('ElixirSuite__Problem__r.Name '+JSON.stringify(column.ElixirSuite__Problem__r.Name))
                      //  console.log('ElixirSuite__Problem__r.Id '+JSON.stringify(column.ElixirSuite__Problem__r.Id))
                        
                        column['ICD'] = column.ElixirSuite__Diagnosis_Code__r.Name;
                        column['icdVersion']= column.ElixirSuite__Diagnosis_Code__r.ElixirSuite__Version__c;
                        
                        column['diagnosisId']= column.ElixirSuite__Diagnosis_Code__r.Id;       
                        column['createdBy']= column.CreatedBy.Name;
                        if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Problem__r)){
                         if((column.ElixirSuite__Problem__r.Id).includes((column.ElixirSuite__Problem__r.Name))){
                       column['ProblemName'] = '';
                        }else{
                        column['ProblemName'] = column.ElixirSuite__Problem__r.Name;
                        } 
                         column['snowmedCtCode']= column.ElixirSuite__Problem__r.ElixirSuite__SNOMED_CT_Code__c;
                        column['status']= column.ElixirSuite__Problem__r.ElixirSuite__Status__c;
                        column['problemType']= column.ElixirSuite__Problem__r.ElixirSuite__Problem_Type__c;
                        column['dateDiagonised']= column.ElixirSuite__Problem__r.ElixirSuite__Date_Diagonised__c;
                        column['dateOnset']= column.ElixirSuite__Problem__r.ElixirSuite__Date_Onset__c;
                        column['Notes']= column.ElixirSuite__Problem__r.ElixirSuite__Note__c; 
                        }
          });
                    
                    
          //commented by sagili siva as per the requirement in LX3-5767
          /* component.set('v.mycolumns', [                        
                        { label: 'Problem Name', fieldName: 'ProblemName', type:'button' ,typeAttributes:  {label: { fieldName: 'ProblemName' }, target: '_blank',name:'recLink',variant:'Base' } },
                        { label: 'ICD Code', fieldName: 'ICD', type: 'text'},   
                        
                        
                    ]);*/
                        // icdVersion;snowmedCtCode;status;problemType;dateDiagonised;dateOnset;Notes	
                        let mapOfApiAndLabel =  {"icdVersion" :"ICD Version",
                        "snowmedCtCode" :"SNOMED CT Code",
                        "status" :"Status",
                        "problemType" :"Problem Type",
                        "dateDiagonised" :"Date Diagonised",
                        "dateOnset" :"Date Onset",
                       // "Notes" :"Notes",
                         "ICD"  :"Diagnosis Code",
                        "ProblemName" :"Problem Name",
                        };
                        console.log('mahi'+mapOfApiAndLabel.ProblemName)
                        let toAddCol = [];
                        if(!$A.util.isUndefinedOrNull(csColumns)){
                        let csColArr = csColumns.split(';'); 
                            console.log('ABC'+csColArr);
                            const allButtonColumns = ["ICD","ProblemName"];
                            const allTextColumns = ["snowmedCtCode","status","icdVersion","dateDiagonised","problemType","dateOnset"//,"Notes"
                                                   ];
                        if(csColumns){
                        for(let recSObj in csColArr){
                            console.log('csColArr[recSObj]'+csColArr[recSObj]);
                            console.log('recSObj'+recSObj);
                              if(allButtonColumns.includes(csColArr[recSObj])){
                               toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]],
                                  fieldName: csColArr[recSObj], type:'button' ,typeAttributes:  {label: { fieldName: csColArr[recSObj] }, target: '_blank',name:'recLink',variant:'Base' }});    
                              console.log('sachin1');
                              }
                         
                               if(allTextColumns.includes(csColArr[recSObj])){
                                  toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]],
                                  fieldName: csColArr[recSObj], type: 'text'});
                                  console.log('sachin2');
                                  
                                  
                              }
                     
                }
              }
            }
          
          toAddCol.push({
            label: "Created Date",
            fieldName: "CreatedDate",
            type: "date",
            sortable: true,
            typeAttributes: {
              day: "numeric",
              month: "short",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
              second: "2-digit",
              hour12: true
            }
          });
          toAddCol.push({
            label: "Created By ",
            fieldName: "createdBy",
            type: "text"
          });
          toAddCol.push({
            label: "Modified Date",
            fieldName: "LastModifiedDate",
            type: "date",
            typeAttributes: {
              day: "numeric",
              month: "short",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
              second: "2-digit",
              hour12: true
            }
          });
          toAddCol.push({
            fieldName: "Actions",
            type: "action",
            typeAttributes: { rowActions: actions }
          });
          component.set("v.mycolumns", toAddCol);

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
          console.log("response " + JSON.stringify(response.getReturnValue()));
          component.set("v.listDetails", resp);
          console.log("shiva" + resp);
          component.set("v.loaded", true);
        } else {
          console.log("failure");
        }
      });
      $A.enqueueAction(action);
      
    } 
    catch (e) {
      alert("error " + e);
    }
  },
  New: function(component, event, helper) {
    //component.set("v.openMedicationModal", true);    
    helper.checkCareEpisodehelper(component, event, helper,component.get("v.recordVal"));//NK----LX3-5932
 
    },
        openNewCarePlanModal	:function(component, event, helper) {
            console.log('before setting val' , component.get("v.newEncounter"));
            component.set("v.newEncounter", true);
            console.log('after value set' , component.get("v.newEncounter"));
            helper.helperMethod(component, event, helper);
            
        },
            updateSelectedText : function(component, event, helper){
                var selectedRows = event.getParam('selectedRows');
                console.log(JSON.stringify(selectedRows));
                //  console.log('selectedRows'+selectedRows);
                component.set("v.selectedRowsCount" ,selectedRows.length );
                let obj =[] ; 
                if(selectedRows.length>=1) 
                {
                    component.set("v.showDeleteButton",true); 
                }
                else {
                    component.set("v.showDeleteButton",false); 
                }
                for (var i = 0; i < selectedRows.length; i++){
                    
                    obj.push({Name:selectedRows[i].Name});
                    
                }
                
                
                //component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
                component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
                
            },
                handleRowAction: function(component, event, helper) {
                    try{
                        var action = event.getParam('action');
                        component.set("v.actionName",action);
                        console.log(action.name);
                        var row = event.getParam('row');
                        component.set("v.RowId",row.Id);
                        component.set("v.SelectedRec", row);
                        
                        
                        switch (component.get("v.actionName").name) {
                            case 'EDIT':
                                component.set("v.Title", 'Edit ');
                                component.set("v.AllFlag", false);
                                component.set("v.openSelectedRecord", true);                    
                                break;                    
                            case 'recLink':
                                component.set("v.Title", 'View ');
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
                    selectedRows : function(component, event, helper) {
                        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));
                        
                        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));
                        
                        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
                        var selectedRows =  event.getParam('selectedRows');
                        if(selectedRows.length>=1) 
                        {
                            component.set("v.showDeleteButton",true); 
                        }
                        else {
                            component.set("v.showDeleteButton",false); 
                        }
                        
                    }, 
                        deleteButton : function(component , helper , event){
                            var rowsList = component.get('v.selectedRowsList');
                            var setOfIds = [];
                            for(var row in rowsList){
                                setOfIds.push(rowsList[row].Id);
                            }
                            console.log('setOfIds '+setOfIds);
                            var action = component.get('c.deleteAllProbelm');
                            action.setParams({
                                lstRecordId : setOfIds
                            });
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
                                    $A.get('e.force:refreshView').fire();
                                }
                            });
                            $A.enqueueAction(action);    
                            
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
            "recordId": component.get("v.recordVal")
        });
        navEvt.fire();
    },
    //end
                            handleConfirmDialogNo : function(component, event, helper) {
                                component.set("v.showConfirmDialog",false);  
                            },
                                handleConfirmDialogYes : function(component, event, helper) {
                                    helper.deleteSelectedRecordRecord(component, event, helper);
                                    component.set("v.showConfirmDialog",false);  
                                },
                                    closeModel: function(component, event, helper) {
                                        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
                                        component.set("v.openCareplan", false);
                                    },
                                        parentComponentEvent: function(component, event, helper) {
                                            let message = event.getParam("columns"); 
                                            component.set('v.configListFields',JSON.parse(JSON.stringify(message)));
                                            let mapOfApiAndLabel =  {"icdVersion" :"ICD Version",
                                                                     "snowmedCtCode" :"SNOMED CT Code",
                                                                     "status" :"Status",
                                                                     "problemType" :"Problem Type",
                                                                     "dateDiagonised" :"Date Diagonised",
                                                                     "dateOnset" :"Date Onset"
                                                                    // "Notes" :"Notes"
                                                                    };
                                            let cols =    component.get('v.mycolumns');
                                            cols = [  { label: 'Problem Name', fieldName: 'ProblemName', type:'button' ,typeAttributes:  {label: { fieldName: 'ProblemName' }, target: '_blank',name:'recLink',variant:'Base' } },
                                                    { label: 'ICD ', fieldName: 'ICD', type: 'text'},   ];
                                                    
                                                    for(let rec in message){
                                                    cols.push({ label: mapOfApiAndLabel[message[rec]], fieldName: message[rec], type: 'text'});
}
component.set('v.mycolumns',cols);
//      helper.fetchListViewData();
console.log('data set'+JSON.stringify( component.get('v.mycolumns')));             
console.log('data '+JSON.stringify(message));        
},
    showOptions:function(cmp){
        cmp.set("v.showOptions",true); 
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
            openProc: function (component, event, helper) {
                component.set("v.openProcNew",true);
            },
                editProcedure: function (component, event, helper) {
                    component.set("v.openProcEdit",true);
                },  
})