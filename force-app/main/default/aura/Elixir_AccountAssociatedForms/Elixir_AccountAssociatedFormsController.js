({
    init: function(component, event, helper) {
        
        var dt = {'date1' : '', 'date2': '', 'date3':''};
        component.set("v.AllDates",dt);
        var actionbuttons=false;
        helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
        
    },
    New: function(component, event, helper) {
        component.set("v.openMedicationModal", true);
    },

    handleRowAction: function(component, event, helper) {
        component.set("v.endString",'');
        var dt = {'date1' : '', 'date2': '', 'date3':''};
        component.set("v.AllDates",dt);
        //var nameSpace = '';
        console.log('inside handleRow Action');
        var action = event.getParam('action');
        component.set("v.actionName",action);
        console.log(action.name);
        var row = event.getParam('row');
        component.set("v.SelectedRec", row);
        component.set("v.PresId", event.getParams().row["Id"]);
        component.set("v.selectedFormName", event.getParams().row["Name"]);
                switch (component.get("v.actionName").name) {
                    case 'EDIT':
                        component.set("v.editScreen", false);
                        component.set("v.editScreen", true);
                        component.set("v.SaveButton", true);
                        component.set("v.AllFlag", false);
                        component.set("v.Title", 'Edit Form');
                        break;
                        
                    case 'recLink':
                        component.set("v.AllFlag", true);
                        component.set("v.editScreen", false);
                        component.set("v.editScreen", true);
                        component.set("v.SaveButton", false);
                        component.set("v.Title", 'View Form');
                        break;
                        
                    case 'DELETE':
                        var getStatus = event.getParams().row;
                        if(!$A.util.isUndefinedOrNull(getStatus.ElixirSuite__Status__c)){
                            var getCurrent = getStatus.ElixirSuite__Status__c;
                            if(getCurrent == 'Completed' || getCurrent == "Under Review"){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "info",
                                    "title": "CANNOT DELETE AS STATUS IS "+getCurrent.toUpperCase(),
                                    "message": "Status is not open!!"
                                });
                                toastEvent.fire();
                            }
                            else {
                                var action = component.get("c.DeleteSavedForm");
                                component.find("Id_spinner").set("v.class" , 'slds-show');
                                action.setParams({
                                    formId: event.getParams().row["Id"]
                                });
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                                         var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "success",
                                    "title": "RECORD DELETED SUCCESSFULLY",
                                    "message": "Deletion Successfull."
                                });
                                toastEvent.fire();
                                         var actionbuttons=false;
                                        helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                                    }
                                });
                                $A.enqueueAction(action);
                            }
                            
                        }   
                        break;
                }
                
      
    },
    handleApplicationEvent: function(component, event, helper) {
         var actionbuttons=false;
        helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
        
    },
    closeModel: function(component, event, helper) {
        component.set("v.editScreen", false);
        component.set("v.showDetail", '');
        
    },
    selectedRows: function(component, event, helper) {
        console.log('seleceted rows' + JSON.stringify(event.getParam('selectedRows')));
        
        console.log('all rows ' + JSON.stringify(component.get('v.selectedRows')));
        
        component.set("v.selectedLabOrders", event.getParam('selectedRows'));
        
        //var nameSpace = component.get('v.nameSpace') ;
        //Var Status = nameSpace +'Status__c';
        component.set("v.deletionAbility",false)
        var selectedRows =  event.getParam('selectedRows');
        for(var allRecords in selectedRows){
            if(selectedRows[allRecords].ElixirSuite__Status__c=='Completed' || selectedRows[allRecords].ElixirSuite__Status__c == "Under Review"){
                component.set("v.deletionAbility",true);  
            }
           
        }
           
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length >= 1) {
            component.set("v.showDeleteButton", true);
        } else {
            component.set("v.showDeleteButton", false);
        }
        if (selectedRows.length == 1) {
            component.set("v.enableExportAsPdf", true);
        } else {
            component.set("v.enableExportAsPdf", false);
        }
        
    },
    
    
    deleteSelectedRows: function(component, event, helper) {
        var selectedRows = component.get("v.selectedRows");
        console.log('Lab Order Id' + JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        helper.deleteSelectedHelper(component, event, helper ,selectedIds);
    },
    
    handleRefresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    closeModel1: function(component, event, helper) {
        component.set("v.isOpen1", false);
        
    },
    exportAsPDF: function(component, event, helper) {
       // var nspc = '';
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('for exportPDF row selected is ' + JSON.stringify(selectedRows));
        var recordToExport = selectedRows[0].Id;
        var url = '/apex/'+'ElixirSuite__FormsPDFGenerator?formId=' + recordToExport;
        //alert(url + recordToExport);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
        
    },
    onCheck: function(component, event, helper) {
        if(component.get("v.isRestrict") ==true){
            component.set("v.isRestricted", true);
            var actionbuttons=true;
            helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
        }
        else{
            component.set("v.isRestricted", true);
             
        }
    },
    onCancel: function(component, event, helper) {
        component.set("v.isRestricted", false);
         component.set("v.isRestrict", false);
    },
    onSubmit: function(component, event, helper) {
        var nameSpace = component.get("v.nameSpace") ;
        var action = component.get( 'c.Uinfo' );
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(component.get("v.isRestrict") ==true){
                    var DataList =JSON.parse(JSON.stringify(component.get("v.listDetails"))) ;
                    var NewDataList=[];
                    for(var i in DataList){
                        if($A.util.isUndefinedOrNull(DataList[i][nameSpace+ 'Visit1__c'])){
                            NewDataList.push(DataList[i]);
                        }
                    }
                    component.set("v.listDetails",NewDataList)
                    var isValidate ;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                       if(userNameVal == res.ElixirSuite__Verification_Code__c){
                          userName.set("v.errors",null);
                            isValidate = true;
                    }else{
                        userName.set("v.errors",[{message:'Invalid Key!!'}]);
                    }
                    }
                    
                    if(isValidate){
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", true);
                        component.set("v.deletionAbility", true);
                        console.log('hh',component.get("v.deletionAbility"))
                        component.set("v.SecurityKeys", "");
                    }
                }
                else{
                    var actionbuttons=false;
            helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                    var isValidate ;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                        if(userNameVal == res.ElixirSuite__Verification_Code__c){
                          userName.set("v.errors",null);
                            isValidate = true;
                    }else{
                        userName.set("v.errors",[{message:'Invalid Key!!'}]);
                    }
                    }
                     
                    if(isValidate){
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", false);
                        component.set("v.SecurityKeys", "");
                        component.set("v.deletionAbility", false);
                    }
                }
            } 
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }   
            }  
        });
        $A.enqueueAction(action);    
    },
    
})