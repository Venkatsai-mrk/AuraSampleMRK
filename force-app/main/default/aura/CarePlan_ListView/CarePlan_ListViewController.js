({
    myAction : function(component, event, helper) {
        console.log('in the careplan listview')
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            console.log('afctab', focusedTabId);
            console.log('issubTab: ', issubTab);
            
            if (issubTab) {
                workspaceAPI.getTabInfo({ tabId: focusedTabId }).then(function (response1) {
                    console.log('afctabinfo', response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Care Plan"
                });
            } else if (response.subtabs && response.subtabs.length > 0) {
                workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                    console.log('tabId: response.subtabs[0].tabId: ' + response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Care Plan"
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
        console.log('component.get("v.recordVal"): '+component.get("v.recordVal"))
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = mm + '/' + dd + '/' + yyyy;
        
        var upDate = new Date();
        upDate.setDate(upDate.getDate() + 10);
        var ddu = String(upDate.getDate()).padStart(2, '0');
        var mmu = String(upDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyyu = upDate.getFullYear();
        
        upDate = mmu + '/' + ddu + '/' + yyyyu;
        component.set("v.NextDate",upDate);
        component.set("v.TodayDate",today);
        var columns = event.getParam("columns");
        console.log('init columns'+columns);
        helper.fetchColumns(component, event, helper) ;
        var action = component.get("c.CareplanRecords");
        action.setParams({  
            accountId : component.get("v.recordVal") ,
        });
        /*var actions = [
            {label: 'Delete', name: 'DELETE'}
        ];*/
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response INIT '+JSON.stringify(response.getReturnValue()));   
                //  var nameSpace = response.getReturnValue().nameSpace;
                /*  var nameSpace =  'ElixirSuite__';
                component.set('v.mycolumns', [
                    { label: 'Care Plan Name', fieldName: 'ElixirSuite__Treatment_Plan_Name__c', type:'button',typeAttributes:  {label: { fieldName: 'ElixirSuite__Treatment_Plan_Name__c' }, target: '_blank' , name: 'recLink',variant:'Base' } },
                    { label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text', "cellAttributes": { "class": { "fieldName": "showClass" }  } },
                    
                    
                    /*     {label: 'LastModified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {  
                        day: 'numeric',  
                        month: 'short',  
                        year: 'numeric',  
                        hour: '2-digit',  
                        minute: '2-digit',  
                        second: '2-digit',  
                        hour12: true}},*/
                
                /* {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
                    
                ]);*/
                
                /*   var tableColumns = component.get('v.mycolumns');
                    tableColumns.push({ label: 'Start Date', fieldName:'ElixirSuite__Start_Date__c', type: 'Date',typeAttributes:{ month: "2-digit", day: "2-digit" } });
                    tableColumns.push({ label: 'End Date', fieldName: 'ElixirSuite__End_Date__c', type: 'Date',typeAttributes:{ month: "2-digit", day: "2-digit" } });
                    tableColumns.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } });
                    component.set('v.mycolumns',tableColumns);*/
                /*      var allData = response.getReturnValue().listOfCase;
                    component.set("v.customSetting", response.getReturnValue().careplanCustomSettingHeirarchy); 
                    console.log('response '+JSON.stringify(response.getReturnValue()));
                    let numberOfApprovalLevels = response.getReturnValue().totalApprovalLevels;
                    
                
                /***************************************************************/
                
                /*   console.log('all data'+JSON.stringify(allData));
                component.set("v.Caselist", JSON.parse(JSON.stringify(allData)));
                
                var listDetails=component.get("v.Caselist"); 
                console.log('list detail '+JSON.stringify(listDetails));
                listDetails.forEach(function(record){ 
                    // if(record.Level1 == 'Patient'){
                    //  record.showClass1 = (record.Level1 == 'Patient' ? 'blue' : 'close');
                    if(record['ElixirSuite__Approval_Level_1__c'] == true){
                        record.displayIconName1 ="utility:check";
                        record.displayIconName2 ="utility:close";
                        record.displayIconName3 ="utility:close";
                        record.displayIconName4 ="utility:close";
                        record.displayIconName5 ="utility:close";
                        //   record.ElixirSuite__Status__c = 'Open';
                        //   record.showClass = (record.ElixirSuite__Status__c == 'Open' ? 'open' : 'close');
                    } 
                    else{
                        record.displayIconName1 ="utility:close";
                        record.displayIconName2 ="utility:close";
                        record.displayIconName3 ="utility:close";
                        record.displayIconName4 ="utility:close";
                        record.displayIconName5 ="utility:close";
                        //  record.ElixirSuite__Status__c = 'Open';
                        //  record.showClass = (record.ElixirSuite__Status__c == 'Open' ? 'open' : 'close');
                    }
                    // }
                    //if(record.Level2 == 'Primary Therapist'){
                    // record.showClass1 = (record.Level2 === 'Primary Therapist' ? 'blue' : 'open');
                    if(record['ElixirSuite__Approval_Level_2__c'] == true){
                        record.displayIconName1 ="utility:check";
                        record.displayIconName2 ="utility:check";
                        record.displayIconName3 ="utility:close";
                        record.displayIconName4 ="utility:close";
                        record.displayIconName5 ="utility:close";
                        //    record.ElixirSuite__Status__c = 'In-Progress';
                        //    record.showClass = (record.ElixirSuite__Status__c === 'In-Progress' ? 'inprogress' : 'open');
                    }
                    //  }
                    //  if(record.Level3 == 'Clinical Supervisor'){
                    //   record.showClass1 = (record.Level3 === 'Clinical Supervisor' ? 'blue' : 'inprogress');
                    if(record['ElixirSuite__Approval_Level_3__c'] == true){
                        record.displayIconName1 ="utility:check";
                        record.displayIconName2 ="utility:check";
                        record.displayIconName3 ="utility:check";
                        record.displayIconName4 ="utility:close";
                        record.displayIconName5 ="utility:close";
                        //     record.ElixirSuite__Status__c = 'Completed';
                        //    record.showClass = (record.ElixirSuite__Status__c === 'Completed' ? 'close' : 'open');
                    }
                    if(record['ElixirSuite__Approval_Level_4__c'] == true){
                        record.displayIconName1 ="utility:check";
                        record.displayIconName2 ="utility:check";
                        record.displayIconName3 ="utility:check";
                        record.displayIconName4 ="utility:check";
                        record.displayIconName5 ="utility:close";
                    }
                    if(record['ElixirSuite__Approval_Level_5__c'] == true){
                        record.displayIconName1 ="utility:check";
                        record.displayIconName2 ="utility:check";
                        record.displayIconName3 ="utility:check";
                        record.displayIconName4 ="utility:check";
                        record.displayIconName5 ="utility:check"; 
                    }
                    //   }
                    
                });
                component.set("v.listDetails", listDetails);*/
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
        
    },
    openNewCarePlanModal:function(component) {
        component.set("v.openNewCarePlan",true);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "ElixirSuite__Elixir_CarePlan"
                },
                "state": {
                    c__recordVal: component.get("v.recordVal")
                }
            },
            focus: true
        }).then(function (subtabId) {
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Care Plan"
            });
        }).catch(function (error) {
            console.log(error);
        });
    }, 
    updateSelectedText : function(component, event){
        console.log('updateSelectedText');
        var selectedRows = event.getParam('selectedRows');
        var arrToIterate = JSON.parse(JSON.stringify(selectedRows));
        console.log(JSON.stringify(selectedRows));
        var flag = false;
        for(var allRecords in arrToIterate){
            if(arrToIterate[allRecords].ElixirSuite__Status__c=='In Progress' ){
                flag = true;
            }   
        }
        component.set("v.delButtonEnabled",flag);   
        
        console.log('selectedRows'+selectedRows);
        
        component.set("v.selectedRowsCount" ,selectedRows.length);
        console.log('selectedRows length'+selectedRows.length);
        let obj =[] ; 
        if(selectedRows.length>=1) 
        { 
            var ElixirSuite__Status__c = selectedRows[0]["carePlanStatus"];
            console.log('selected row status',ElixirSuite__Status__c);
            if(selectedRows.length == 1 && ElixirSuite__Status__c.toLowerCase() == 'completed'){	
                component.set("v.showPdfbutton",true);	
            }else{
                console.log('inside else 169');
                component.set("v.showPdfbutton",false);	
            }	
            component.set("v.showDeleteButton",true);
        }	
        else {	
            
            component.set("v.showDeleteButton",false); 	
            // component.set("v.showPdfbutton",false);	
        }
        
        
        /*************************************************************/
        // EXPORT AS DELETE ENABLE HANDLE
        if(selectedRows.length>1) {
            component.set("v.showPdfbutton",true);	 
        }
        else {
            var allowProceed = true;
            for(let rec in selectedRows){
                if(selectedRows[rec]['carePlanStatus']!='Completed'){
                    component.set("v.showPdfbutton",false);  
                    allowProceed = false;
                    break;
                }
            }
            if(allowProceed){
                component.set("v.showPdfbutton",false); 
            }
            
        }
        
        if(selectedRows.length==0) {
            component.set("v.showPdfbutton",true); 
        }
        /*************************************************************/
        for (var i = 0; i < selectedRows.length; i++){
            
            obj.push({Name:selectedRows[i].Name});
            
        }
        
        
        //component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
        
    },
    handleRowAction : function(component, event, helper) {
        try{
            var action1 = event.getParam('action');
            var row = event.getParam('row');    
            var id = event.getParams().row["carePlanId"];
            //  var ElixirCS__ElixirSuite__Status__c = event.getParams().row["ElixirCS__ElixirSuite__Status__c"];
            var status = event.getParams().row["carePlanStatus"];
            component.set("v.selectedRow",id);
            //   alert(id);
            console.log('action1',action1);
            console.log('row',row);
            console.log('id',id);
            console.log('action1.name',action1.name);
            console.log('v.decisionTree',component.get("v.decisionTree"));
            console.log('v.openApproval',component.get("v.openApproval"));
            console.log('v.selectedRow',component.get("v.selectedRow"));
            switch (action1.name) {
                case '' :    
                    if(status == 'Open' || status.toLowerCase() == 'in use' || status.toLowerCase() == 'in progress'){
                        component.set("v.Elixir_OpenStatusEditComponent",true); 
                        let workspaceAPI = component.find("workspace");
                        workspaceAPI.openSubtab({
                            pageReference: {
                                "type": "standard__component",
                                "attributes": {
                                    "componentName": "ElixirSuite__Elixir_OpenStatusEditComponent"
                                },
                                "state": {
                                    c__decisionTree: component.get("v.decisionTree"),
                                    c__openApproval: component.get("v.openApproval"),
                                    c__selectedRow: component.get("v.selectedRow"),
                                    c__recordVal: component.get("v.recordVal")
                                }
                            },
                            focus: true
                        }).then(function (subtabId) {
                            workspaceAPI.setTabLabel({
                                tabId: subtabId,
                                label: "Care Plan"
                            });
                        }).catch(function (error) {
                            console.log(error);
                        });
                    }else if(status.toLowerCase() == 'closed' || status.toLowerCase() == 'completed'){
                        component.set("v.openViewCarePlanModal",true);
                        let workspaceAPI = component.find("workspace");
                        workspaceAPI.openSubtab({
                            pageReference: {
                                "type": "standard__component",
                                "attributes": {
                                    "componentName": "ElixirSuite__Elixir_ViewCarePlan"
                                },
                                "state": {
                                    c__decisionTree: component.get("v.decisionTree"),
                                    c__countOfApprovalLevel: component.get("v.approvalLevelCount"),
                                    c__selectedRow: component.get("v.selectedRow"),
                                    c__recordVal: component.get("v.recordVal")
                                }
                            },
                            focus: true
                        }).then(function (subtabId) {
                            workspaceAPI.setTabLabel({
                                tabId: subtabId,
                                label: "Care Plan"
                            });
                        }).catch(function (error) {
                            console.log(error);
                        });
                    }               
                    break;
                    
                case 'DELETE':
                    alert('Are you sure you want to delete this item?');
                    var action = component.get("c.deleteRecords");
                    action.setParams({ caseId : event.getParams().row["Id"] });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {   
                            helper.initCopy(component,event, helper , 'isDeleted');
                            //  $A.get('e.force:refreshView').fire();
                            
                        }
                    });
                    $A.enqueueAction(action);
                    break;     
            }
            
        }
        catch(e){
            alert(e);
        }
        
        
    },
    selectedRows : function(component, event) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));
        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));
        
        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
        var selectedRows =  event.getParam('selectedRows');
        var ElixirSuite__Status__c = event.getParams().row["ElixirSuite__Status__c"];	
        if(selectedRows.length>=1) 	
        {	
            if(selectedRows.length == 1 && ElixirSuite__Status__c.toLowerCase() == 'completed'){	
                component.set("v.showPdfbutton",true);	
            }else{	
                component.set("v.showPdfbutton",false);	
            }	
            
            component.set("v.showDeleteButton",true); 	
            
        }	
        else {	
            component.set("v.showDeleteButton",false); 	
            component.set("v.showPdfbutton",false);	
        }
        
    }, 
    
    exportAsPDF :  function (component) {	
        var selectedRows = component.get("v.selectedRowsList");	
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows));                	
        var caseId=selectedRows[0].carePlanId; 
        
        var url = '/apex/ElixirSuite__ElixirOEM_CarePlanPDFGenerator?treatmentPlanID='+caseId;	
        // alert(url);	
        var newWindow;	
        newWindow = window.open(url);	
        newWindow.focus();	
    },
    
    deleteButton : function(component){
        component.set("v.showConfirmDialog",true);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);  
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        //var lstdetails= component.get("v.listDetails");
        var rowsList = component.get('v.selectedRowsList');
        var setOfIds = []; 
        for(var row in rowsList){
            setOfIds.push(rowsList[row].carePlanId);
        }
        console.log('set of ids'+setOfIds);
        var action = component.get('c.deleteCarePlans');
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({
            carePlansId : setOfIds
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                
                component.set("v.selectedRows", []);
                $A.get('e.force:refreshView').fire();
                
                
                //this.myAction(component, event, helper);
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The record has been deleted successfully."
                });
                toastEvent.fire(); 
                //helper.initCopy(component, event, helper,'isDeleted');
                //component.find("Id_spinner").set("v.class" , 'slds-hide'); 
                
                // $A.get('e.force:refreshView').fire();
                // component.set('v.selectedRowsList' , ' ');
                
                
                /* window.setTimeout(
                                    $A.getCallback(function() {
                                        console.log('after 5 ');
                                    if(component.isValid()){
                                        console.log('delted ');
                                        helper.initCopy(component, event, helper);                           
                                    }
                                    }), 5000
                                    );*/
                
                
            }
        });
        $A.enqueueAction(action);
        component.set("v.showConfirmDialog",false);
    },
    
    /*closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.openCareplan", false);
    },*/
    handleRefresh : function(component, event, helper) {
        helper.initCopy(component, event, helper,'');
        
    }
})