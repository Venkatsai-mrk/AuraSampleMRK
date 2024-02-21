({
    init: function(component, event, helper) {   
        var action = component.get("c.portalInitPayload");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('error '+JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('portal dtaa '+JSON.stringify(resp));
                if(resp.accountIdIfPortalUser){
                    component.set("v.recordVal",resp.accountIdIfPortalUser);
                }
                //workspace code starts
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
                            
                            label: "Notes"
                        });                
                    }
                    else 
                    { 
                        workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                            console.log('afctabinfo----',response1);
                        });
                        workspaceAPI.setTabLabel({
                            label: "Notes"
                        });         
                    }     
                    
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "utility:answer",
                        iconAlt: "Notes"
                    });
                })
                
                
                //workspace Code ends
                
                var dt = {'date1' : '', 'date2': '', 'date3':''};
                component.set("v.AllDates",dt);
                var actionbuttons=false;
                var message = event.getParam("route"); 
                if(message == 'forRefresh'){
                    component.set("v.openMedicationModal", false);            
                }
                
                helper.initFunctionMovedToHelper(component, event, helper,actionbuttons); 
                
            }
            else {
                console.log("failure for fetchCommunityUser");
            }
        });
        $A.enqueueAction(action);
        
        
    },

    New: function(component) {
        component.set("v.openMedicationModal", true);
    },
    // added by Tanveer 
    sendFormToPatientPortal: function(component) {
        component.set("v.forPatientPortal", true);
        component.set("v.openMedicationModal", true);
    },
    // added by shivam
     DynamicNotes: function(component){
        alert('Work in progress');
        component.set("v.openDynamicModal", true);
    },
    
    // End By Shivam
    handleRowAction: function(component, event, helper) {
        component.set("v.endString",'');
        var dt = {'date1' : '', 'date2': '', 'date3':''};
        component.set("v.AllDates",dt);
        console.log('inside handleRow Action');
        var action = event.getParam('action');
        component.set("v.actionName",action);
        console.log(action.name);
        var row = event.getParam('row');
        component.set("v.SelectedRec", row);
        console.log('row');
        component.set("v.PresId", event.getParams().row["formId"]);
        component.set("v.selectedFormName", event.getParams().row["recordTypeName"]);
        component.set("v.screenFormName", event.getParams().row["formName"]);
        
        console.log(event.getParams().row["formId"]);
        console.log('**'+event.getParams().row["recordTypeName"]);
        switch (component.get("v.actionName").name) {
            case 'recLink':
                if(event.getParams().row['status'] == 'Submitted to Provider'){
                    helper.getCustomFormsHelper(component, event, helper, 'VIEW')
                    .then(function(result) {
                        if(result){    
                            const customFormNames = component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c);
                            if (customFormNames.includes(component.get("v.selectedFormName"))) {
                                var baseUrl = window.location.href.split('/s')[0];
                                baseUrl = baseUrl + '/s/intake-form';

                                var accountId = "?c__accountId" + "=" + component.get("v.recordVal");
                                var formName = "&c__formName" + "=" + component.get("v.selectedFormName");
                                var formUniqueId = "&c__formUniqueId" + "=" + component.get("v.PresId");
                                var actionType = "&c__actionType" + "=" + 'View';
                                var customFormCmp = "&c__customFormCmp" + "=" + component.get("v.customFormCmp")[0].ElixirSuite__Component_name__c;


                                window.location.href = baseUrl + accountId + formName + formUniqueId + actionType + customFormCmp;
                


                            }
                            else {
                                component.set("v.AllFlag", false);
                                component.set("v.editScreen", false);
                                component.set("v.editScreen", true);
                                component.set("v.SaveButton", false);
                                component.set("v.viewMode",true);
                                component.set("v.isPortal",true);
                                component.set("v.Title", 'View Form');
                            }
                            
                        }else{
                            component.set("v.AllFlag", false);
                            component.set("v.editScreen", false);
                            component.set("v.editScreen", true);
                            component.set("v.SaveButton", false);
                            component.set("v.viewMode",true);
                            component.set("v.isPortal",true);
                            component.set("v.Title", 'View Form');
                        }
                    })
                    .catch(function(error) {
                        console.error('Error occurred:', error);
                    });
                }
                else {
                    helper.getCustomFormsHelper(component, event, helper, 'EDIT')
                    .then(function(result) {
                        if(result){
                            const customFormNames = component.get("v.customFormCmp").map(i => i.ElixirSuite__Form_name__c);
                            if (customFormNames.includes(component.get("v.selectedFormName"))) {
                                var baseUrl = window.location.href.split('/s')[0];
                                baseUrl = baseUrl + '/s/intake-form';

                                var accountId = "?c__accountId" + "=" + component.get("v.recordVal");
                                var formName = "&c__formName" + "=" + component.get("v.selectedFormName");
                                var formUniqueId = "&c__formUniqueId" + "=" + component.get("v.PresId");
                                var actionType = "&c__actionType" + "=" + 'EDIT';
                                var customFormCmp = "&c__customFormCmp" + "=" + component.get("v.customFormCmp")[0].ElixirSuite__Component_name__c;


                                window.location.href = baseUrl + accountId + formName + formUniqueId + actionType + customFormCmp;
                        

                            }
                            else {
                                component.set("v.editScreen", false);
                                component.set("v.editScreen", true);
                                component.set("v.SaveButton", true);
                                component.set("v.AllFlag", false);
                                component.set("v.isPortal",true);
                                component.set("v.Title", 'Edit Form');
                                component.set("v.viewMode",false);
                            }
                        }else{
                            component.set("v.editScreen", false);
                            component.set("v.editScreen", true);
                            component.set("v.SaveButton", true);
                            component.set("v.AllFlag", false);
                            component.set("v.isPortal",true);
                            component.set("v.Title", 'Edit Form');
                            component.set("v.viewMode",false);
                        }
                    })
                    .catch(function(error) {
                        console.error('Error occurred:', error);
                    });
                    
                }
                
                
                
                break;
            case 'STP' :
                if(event.getParams().row["status"] == 'Submitted to Provider'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Form already submitted to provider!",
                        "message": " ",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
                else {
                    helper.submitFormToProvider(component, event, helper,event.getParams().row["formId"],event.getParams().row["formName"]);
                }
               
             break;
           
                }
        
        
    },
    handleApplicationEvent: function(component, event, helper) {
        var actionbuttons=false;
        helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
        
    },
    closeModel: function(component) {
        component.set("v.editScreen", false);
        component.set("v.showDetail", '');
        
    },
    selectedRows: function(component, event) {
        console.log('seleceted rows' + JSON.stringify(event.getParam('selectedRows')));
        
        component.set("v.selectedLabOrders", event.getParam('selectedRows'));
        
        
        var selectedRows =  event.getParam('selectedRows');
        for(var allRecords in selectedRows){
            if(selectedRows[allRecords].Status__c=='Completed' || selectedRows[allRecords].Status__c == "Under Review"){
                component.set("v.deletionAbility",true);  
            }   
        }
        
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
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);
            
        }
        //var disableSubmitToProvider = true;
        var nonNewStatusSetRows = [];
        var newStatusSetRows = [];
        console.log('setRows data '+JSON.stringify(setRows));
        // for(var i=0; i<setRows.length; i++){
        //     if(setRows[i].status !== "New"){
        //         nonNewStatusSetRows.push(setRows[i]);
        //     }
        // }
        //   if(nonNewStatusSetRows.length > 0){
        //     disableSubmitToProvider = false;
        //   }
        // component.set("v.disableSubmitToProvider",disableSubmitToProvider);//trigger point 1
        console.log('dstp 1 '+component.get("v.disableSubmitToProvider"));
        if(setRows.length == 0){
            component.set("v.disableSubmitToProvider",true);//trigger point 2
        }
        console.log('dstp 2 '+component.get("v.disableSubmitToProvider"));
        component.set("v.setRows", setRows);
        console.log('Rows', setRows);
        var selectRows = component.get("v.setRows");
        var formsData = [];
        let flag = true;
        selectRows.forEach(function(element, index) {
            if(element.status == 'Submitted to Provider'){
                flag = false;
            }
            else {
            formsData.push({
                formId: element.formId,
                formName: element.formName
            });
            }
        });
       
        console.log("formsData is",formsData);
        if(formsData.length > 0 && flag == true){
            var action = component.get('c.getApprovalAndSignatureData');
              component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setParams({
                "formsData" : formsData
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log(state+' state for messages');
                if(state === 'SUCCESS'){
                      component.find("Id_spinner").set("v.class" , 'slds-hide');
                    component.set("v.disableSubmitToProvider",response.getReturnValue());
             //    alert('response.getReturnValue() '+JSON.stringify(response.getReturnValue()));
            }
        });
            $A.enqueueAction(action);
        }
        else {
             component.set("v.disableSubmitToProvider",true);
        }
        
    },  
    exportAsPDF :  function (component) {	
        var selectedRows = component.get("v.setRows");
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows));                	        	
        var url = '/apex/ElixirSuite__Elixir_FormsPdfGenerator?aId='+component.get("v.recordVal")  +'&fName=' +
            selectedRows[0].recordTypeName+'&fId=' +selectedRows[0].formId + '&fCName=' +selectedRows[0].formName;
        console.log(url);
        var newWindow;	
        newWindow = window.open(url);	
        newWindow.focus();
    },
    deleteSelectedRows: function(component, event, helper) {
        var selectedRows = component.get("v.setRows");
        console.log('New Acc' + JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].formId);
        }
        helper.deleteSelectedHelper(component, event, helper ,selectedIds);
    },
    
    handleRefresh : function() {
        $A.get('e.force:refreshView').fire();
    },
    
    /* closeModel1: function(component, event, helper) {
        component.set("v.isOpen1", false);
        
    },*/
    /*exportAsPDF: function(component, event, helper) {
        var nspc = '';
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('for exportPDF row selected is ' + JSON.stringify(selectedRows));
        var recordToExport = selectedRows[0].Id;
        var url = '/apex/'+nspc+'FormsPDFGenerator?formId=' + recordToExport;
        //alert(url + recordToExport);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
        
    },*/
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
    onCancel: function(component) {
        component.set("v.isRestricted", false);
        component.set("v.isRestrict", false);
    },
    onSubmit: function(component, event, helper) {
        var action = component.get( 'c.Uinfo' );
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(component.get("v.isRestrict") ==true){
                    var DataList =JSON.parse(JSON.stringify(component.get("v.listDetails"))) ;
                    var NewDataList=[];
                    for(var i in DataList){
                        NewDataList.push(DataList[i]);
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
                        component.set("v.enableExportAsPdf", false);
                        console.log('hh',component.get("v.deletionAbility"))
                        component.set("v.SecurityKeys", "");
                    }
                }
                else{
                    var actionbuttons=false;
                    helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                    let isValidate ;
                    let userName = component.find('userName');
                    let userNameVal = component.find('userName').get('v.value');        
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
                        component.set("v.enableExportAsPdf", false);
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
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        //alert(changeValue);
        if(changeValue =='Forms'){
            cmp.set("v.Forms",true);
            cmp.set("v.heading",'All Forms and Notes');
            cmp.set("v.EventNotesListView",false);
        }
        else if(changeValue =='Notes'){
            cmp.set("v.EventNotesListView",true);
            cmp.set("v.heading",'Event Notes View');
            cmp.set("v.Forms",false);
        }
    } ,
    
    registerSignature:function(component){
      
        component.set("v.recordVal" ,component.get("v.recordId"));
      component.set("v.openSignature",true);
  
    },
    multiFormsSubmitToProvider : function(component, event, helper){
        var selectedRows = component.get("v.setRows");
        console.log('selectedRows in multiFormsSubmitToProvider function '+selectedRows);
        var formattedSelectedRows = [];
        var submittedToProvider = [];
        for(var i = 0; i < selectedRows.length; i++) {
            console.log('formId '+selectedRows[i].formId);
            if(selectedRows[i].status != 'Submitted to Provider'){
                formattedSelectedRows.push({
                    formId: selectedRows[i].formId,
                    formName: selectedRows[i].formName,
                    status: selectedRows[i].status
                });
            }else{
                submittedToProvider.push({
                    formId: selectedRows[i].formId,
                    formName: selectedRows[i].formName,
                    status: selectedRows[i].status
                });
            }
            
        }
        if(submittedToProvider.length > 0){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "One of the selected forms has already been sent to the provider.",
                        "message": " ",
                        "type" : "error"
                    });
                    toastEvent.fire();
        }else{
            helper.submitSelectedFormsToProviders(component, event, helper,formattedSelectedRows);
        }
        

        
    }
})