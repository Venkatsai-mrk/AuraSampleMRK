({
    myAction : function(component, event, helper) {
        
        if(component.get("v.flag") == true){
            var pageReference = component.get("v.pageReference");
            
            var isOpen = pageReference.state.c__isOpen;
            if(isOpen != null && isOpen != ''){
                component.set("v.isOpen", isOpen);
            }
            var recordId = pageReference.state.c__recordId;
            if(recordId != null && recordId != ''){
                console.log('recordId'+ recordId);
                component.set("v.recordId", recordId);
            }
            var formUniqueId = pageReference.state.c__formUniqueId;
            if(formUniqueId != null && formUniqueId != ''){
                component.set("v.formUniqueId", formUniqueId);
                console.log('formUniqueId'+ formUniqueId);
                console.log('formUniqueId'+ component.get("v.formUniqueId"));
            }
            var changedFormName = pageReference.state.c__changedFormName;
            if(changedFormName != null && changedFormName != ''){
                component.set("v.changedFormName", changedFormName);
            }
            var formName = pageReference.state.c__formName;
            if(formName != null && formName != ''){
                console.log('formName'+ formName);
                component.set("v.formName", formName);
                 console.log('formName'+ component.get("v.formName"));
            }
            var viewMode = pageReference.state.c__viewMode;
            console.log('viewMode'+viewMode);
            var actionType = pageReference.state.c__actionType;
            
            if(actionType == 'EDIT'){
                component.set("v.viewMode", false);
                component.set("v.clone", false);
            }
            
            if(actionType == 'VIEW'){
                component.set("v.viewMode", true);
                component.set("v.clone", false);
            }
            
            if(actionType == 'CLONE'){
                component.set("v.viewMode", false);
                component.set("v.clone", true);
            }
            var workspaceAPI = component.find("workspace");
            console.log('workspaceAPI'+workspaceAPI);
                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    console.log('ACD');
                                    var focusedTabId = response.tabId;
                                    console.log('focusedTabId'+ focusedTabId);
                                    var issubTab = response.isSubtab;
                                    console.log('issubTab'+ issubTab);
                                    
                                    if(issubTab)
                                    {
                                        workspaceAPI.getTabInfo(
                                            { tabId:focusedTabId}
                                        ).then(function(response1){
                                            
                                            console.log('response1',response1);
                                        });
                                        workspaceAPI.setTabLabel({
                                            
                                            label: component.get("v.changedFormName")
                                        });                
                                    }
                                    else 
                                    { 
                                        workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){
                                        console.log('response1',response1);
                                        });
                                        workspaceAPI.setTabLabel({
                                            label: component.get("v.changedFormName")
                                        });         
                                    }     
                                    
                                    workspaceAPI.setTabIcon({
                                        tabId: focusedTabId,
                                        icon: "utility:answer"
                                    });
                                })
        }
        component.set("v.flag",false);
        if(component.get("v.clone") == true){
            let changedFormName = component.get("v.changedFormName");
            changedFormName += ' - Clone';
            component.set("v.changedFormName",changedFormName);
        }
        component.set("v.patientID",component.get("v.recordId"));
        console.log('patient id '+JSON.stringify(component.get("v.recordId")));
        helper.fetchNspc(component, event, helper);//added by Anmol
        helper.fetchCustomSett(component, event, helper);//added by Anmol
        var today = new Date();
        component.set('v.today', today.getDate() + "-" + (today.getMonth() + 1) + "-" + today.getFullYear() );
        component.set("v.timeWrapper",{'startTime' : '','endTime' : '','paramSame' : false,'setEndTimeAsCurrent' : false});
        helper.fetchMedicationColumnsFromCustomSetting(component , event , helper);
        helper.buildParentWrapperForExternalComponents(component , event , helper);
        helper.buildNotesSpecificData(component , event , helper);
        helper.fetchProblemColumnsFromCustomSetting1(component , event , helper);
        helper.fetchProblemDataOnforms(component , event , helper);
        helper.fetchColumnsFromCustomSetting1(component , event , helper);
        helper.fetchDiagnosisDataOnforms(component , event , helper);
          helper.fetchMedicationsDataOnforms(component , event , helper);
        try{
            helper.helperInit(component , event , helper);
        }catch(ex){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                type: 'error',
                message: 'Data is not properly configured.',
            });
            toastEvent.fire();
            component.set("v.loaded",true);
            component.set("v.isOpen",false);
        }
         helper.fetchAllergyColumnsFromCustomSetting1(component , event , helper);
    
        helper.fetchExternalCmpData(component , event , helper);
        
       
        component.set("v.isLoadingComp",true);
    },
    closeModal : function(component, event, helper) {     
         component.set("v.showRelatedDiagnosis", false);
    },
     saveModal : function(component, event,helper) {     
         component.set("v.showRelatedDiagnosis", false);
         helper.fetchDiagnosisDataOnforms(component , event , helper);
                component.set("v.loaded",false);// Refresh data after save
    },
    showOptions:function(cmp){
        cmp.set("v.showOptions",true); 
    },
    showOptions1:function(cmp){
        cmp.set("v.showOptions1",true); 
    },
    handleAddOnlyProblem : function(component, event, helper) {        
       component.set("v.showAddOnlyProblem",true);
    },
    handleAddOnlyDiagnosis: function(component, event, helper) {
         component.set("v.showAddOnlyDiagnosis",true);
    },
    handleAddExistingProblem : function(component, event, helper) {        
       component.set("v.showAddExistingProblem",true);
    },
    handleAddExistingDiagnosis : function(component, event, helper) {        
       component.set("v.showAddExistingDiagnosis",true);
    },

    handleProblemColumnEvent : function(component, event, helper) {     
         helper.fetchProblemDataOnforms(component , event , helper);
    },
    handleAddProblemEvent1 : function(component, event, helper) {
            helper.fetchProblemDataOnforms(component , event , helper);
     },
    handleDaignosesDataEvent : function(component, event, helper) {     
         helper.fetchDiagnosisDataOnforms(component , event , helper);
    },
    handleAddDiagnosisEvent : function(component, event, helper) {
         component.set("v.loaded",true);
            helper.fetchDiagnosisDataOnforms(component , event , helper);
        component.set("v.loaded",false);
     },
     handleAddMedicationList: function(component, event, helper) {
        console.log('updated handleAddMedicationList');
         component.set("v.addMedicationList",true);
    },
    handleMedicationEvent : function(component, event, helper) {
         component.set("v.loaded",true);
            helper.fetchMedicationsDataOnforms(component , event , helper);
        component.set("v.loaded",false);
     },
    handleAddMedicationEvent : function(component, event, helper) {
         component.set("v.loaded",true);
            helper.fetchMedicationsDataOnforms(component , event , helper);
        component.set("v.loaded",false);
     },
    showOptionsForMedication:function(cmp){
        console.log('showOptionsForMedication');
        cmp.set("v.medicationConfiguration",true); 
    },
    handleRowAction : function(component, event, helper) { 
        var action = event.getParam('action');
        var row = event.getParam('row');

        // Assuming that 'Id' is the field API name for the record id
        var recordId = row['Id'];

        // Now you can use the recordId as needed
        console.log('Record Id:', recordId);
         // Set the selectedRecordId attribute
        component.set("v.selectedRecordId", recordId);
            if (action.name !== 'deleteRow') {
         component.set("v.showRelatedDiagnosis", true);
            }
       else if (action.name === 'deleteRow') {
            console.log('inside deleterow');
           component.set("v.showConfirmWarning",true); 
           
           //helper.deleteSelectedRows(component , event , helper);
        }
    },
     handleDiagnosisDelete :  function(component, event, helper) {
       
        component.set("v.showConfirmWarning", false); 
      helper.deleteSelectedRows(component , event , helper);
    },
     handleDiagnosisCancel:function(component, event, helper) {
        
        component.set("v.showConfirmWarning",false);  
    },
    handleProblemRowAction: function(component, event, helper) { 
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        // Assuming that 'Id' is the field API name for the record id
        var recordId = row['Id'];
        
        // Now you can use the recordId as needed
        console.log('Record Id:', recordId);
        
        // Set the selectedRecordId attribute
        component.set("v.selectedRecordId", recordId);
         if (action.name !== 'deleteRow') {
         component.set("v.showRelatedDiagnosis", true);
            }
       else if (action.name === 'deleteRow') {
             console.log('inside deleterow');
             component.set("v.showConfirmWarningProblem",true);  
          //helper.deleteSelectedProblemRows(component , event , helper);
         }
    },
handleProblemCancel:function(component, event, helper) {
        
        component.set("v.showConfirmWarningProblem",false);  
    },
    handleProblemDeleteRecord: function(component, event, helper) {
        console.log("handleProblemDeleteRecord");
        var recordId = component.get("v.recordToDeleteId");
        component.set("v.showConfirmWarningProblem", false); 
      helper.deleteSelectedProblemRows(component , event , helper);
    },
                
     handleEditDiagnosisSave: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveChanges(component,  event, helper, draftValues);
         
          
    },
    handleEditProblemSave: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.savePChanges(component, event, helper, draftValues);  
    },
    handleEditMedicationSave: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveMedicationChanges(component,  event, helper, draftValues);   
    },
     validateStartTime : function(component, event, helper) {
        try{
            let val = JSON.parse(JSON.stringify(event.getSource().get("v.value")));
            let result = new Date(val);
            var inputCmp = component.find("startTimeOnForm");
            console.log('inputCmp'+inputCmp);
            if(result.setSeconds(0, 0)>new Date().setSeconds(0, 0)){
                helper.globalFlagToast(component, event, helper,'Start Time cannot be greater than the Current Time', ' ','error');
                component.set("v.RestrictButtons",true); 
            }
            else {
                component.set("v.RestrictButtons",false); 
            }
        }
        catch(e){
            alert(e)
        }
        
    },

    //added by Anmol for LX3-5770
    addPresc: function(component) {
        
        component.set("v.addPresc", true);
    },
    //end by Anmol for LX3-5770

    // Added by Anmol for LX3-5676
    addInv: function(component) {
        
    /*    var defTyp = event.getSource().get("v.name");
        component.set("v.defInvTyp",defTyp);
        var Val = event.getSource().get("v.value");
        component.set("v.defLotReq",Val);
        
         var action = component.get("c.getOriginLot");
        
         action.setParams({ 'ty' :defTyp,'lt' :Val});
        
        action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
            if (state === "SUCCESS") {
                var len = result.length;
                var av = parseInt(result[len-1]);
                var eqid = result[len-2];
                var lotnumber=[];
                for(var i=0;i<len-2;i++){
                    lotnumber.push(result[i]);
                }
               
                component.set("v.invAvail",av);
                component.set("v.defEqpId",eqid);
                component.set("v.prevLotLst",lotnumber);
                
            }
            component.set("v.addInv", true);
        component.set("v.ShowModal", true);
        
        });
            $A.enqueueAction(action);*/

            component.set("v.addInv", true);
        component.set("v.ShowModal", true);
        
    },
    // End by Anmol for LX3-5676

    validateEndTime : function(component, event, helper) {
        try{
            let val = JSON.parse(JSON.stringify(event.getSource().get("v.value")));
            if(val){
                 let result = new Date(val);
            let startTime = component.get("v.timeWrapper").startTime;
            if(result.setSeconds(0, 0)>new Date().setSeconds(0, 0)){
                helper.globalFlagToast(component, event, helper,'End Time cannot be greater than the Current Time', ' ','error');
                component.set("v.RestrictButtons",true); 
            }
             else if(result.setSeconds(0, 0)< new Date(startTime).setSeconds(0, 0)){
               helper.globalFlagToast(component, event, helper,'End Time cannot be less than the Start Time', ' ','error');
                component.set("v.RestrictButtons",true);  
            }
            else {
                component.set("v.RestrictButtons",false); 
            } 
            }
          
        }
        catch(e){
            alert(e)
        }
        
    },
      handleClick : function(component, event, helper) {
        if(helper.runValidationForms(component, event, helper)){
            helper.saveUpdatededForm(component, event, helper,false);
        }
    },

    handleClickOnSubmitToProvider : function(component, event, helper) {
        var formName =  component.get("v.formName");
        var formUniqueId = component.get("v.formUniqueId");
        var action = component.get('c.submitToProvider');
        action.setParams({
            formName: formName,
            formUniqueId:formUniqueId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('resp in submitToProvider: '+resp);
                if(resp){
                    helper.toastHelper('Submitted to provider!','Submit it to provider.','success');
                    if(helper.runValidationForms(component, event, helper)){
                        helper.saveUpdatededForm(component, event, helper,true);
                    }
                }else{
                    helper.toastHelper('Signature required before submitting to provider!','Please sign the form before you submit it to provider.','error');    
                }
            }
        });
        $A.enqueueAction(action); 
    },
    handleConfirmDialogYes : function(component, event, helper) {
         component.set("v.showConfirmDialog",false); 
        var timeObj = component.get("v.timeWrapper");
        timeObj.setEndTimeAsCurrent = true;
        component.set("v.timeWrapper",timeObj);
        helper.saveUpdatededForm(component, event, helper,false); 
    },
    handleConfirmDialogNo : function(component) {
        component.set("v.showConfirmDialog",false);
    },
    handleCancel : function(component, event, helper) {
        try{
            helper.deleteProblemsIfAny(component, event, helper);
        }
        catch(e){
            console.log(e);
        }
        var appEvent = $A.get("e.c:FormsRefreshEvt");
        appEvent.setParams({"cancel" : true});
        appEvent.fire();

        helper.closeTabAndNavigate(component, event, helper);
        component.set("v.isOpen",false);
    },
    handleAddAllergy : function(component) {         
    component.set("v.showNewAllergy",true);
    /*var elements = document.getElementsByClassName("allergySection");
        elements[0].style.display = 'block';       */
    },
    hideAllergySection : function(component, event) {
        var message = event.getParam("path");
        if(message == 'allergy'){
            var elements = document.getElementsByClassName("allergySection");
            console.log('elements'+elements);
            elements[0].style.display = 'none'; 
        }
        else if(message == 'glucose'){
            let elements = document.getElementsByClassName("glucoseSection");
            console.log('elements'+elements);
            elements[0].style.display = 'none';   
        }
            else if(message == 'vital'){
                console.log('Vital sign message'+message)
                let elements = document.getElementsByClassName("vitalSection");
                console.log('elements'+elements);
                elements[0].style.display = 'none';   
            }
                else if( message == 'problem'){
                    let elements = document.getElementsByClassName("problemSection");
                    console.log('elements'+elements);
                    elements[0].style.display = 'none';   
                }
        
    },
    handleAddGlucose : function() {        
        var elements = document.getElementsByClassName("glucoseSection");
        elements[0].style.display = 'block'; 
    },
    handleAddVitals : function(component) {     
        var elements = document.getElementsByClassName("vitalSection");
        component.set("v.openVitalSign",true); /*Added by pratiksha*/
        component.set("v.isListVisible", true);
        // elements[0].style.display = 'block'; 
    },
      handleUpdateVitalList : function(component, event, helper) {
        try {
        console.log('handleCallMethodEvent: ')
        var childLwc2 = component.find("childLwc2");
        if (childLwc2) {
            childLwc2.callMethodInLwc2();
        }

        var childLwc3 = component.find("childLwc3");
        if (childLwc3) {
            childLwc3.callMethodInLwc3();
        }
    } catch (error) {
        console.error('Error:', error);
    }
},
      handleCallMethodEvent: function(component, event, helper) {
    try {
        console.log('parenroflwc12');

        var childLwc2 = component.find("childLwc2");
        if (childLwc2) {
            childLwc2.callMethodInLwc2();
        }

        var childLwc3 = component.find("childLwc3");
        if (childLwc3) {
            childLwc3.callMethodInLwc3();
        }
    } catch (error) {
        console.error('Error:', error);
    }
},
     handleCloseVital:function(cmp){
        cmp.set("v.isListVisible",false); 
    },
    handleAddProblem : function(component) {     
        component.set("v.existingProblems",component.get("v.problemDiagnosesData")); 
        component.set("v.openListOfProblems",true);
    },
    handleproblemDaignosesDataEvent :  function(component)  {
        console.log('refrenced data   '+JSON.stringify(component.get("v.problemDiagnosesData")));
        var checkHasValue  = component.get("v.problemDiagnosesData");
        checkHasValue.hasValue = true ; 
        var holdCleanArr = JSON.parse(JSON.stringify(checkHasValue.data));
        for(var i = checkHasValue.data.length - 1; i >= 0; i--){
            if(!checkHasValue.data[i].problemIsChecked && !$A.util.isUndefinedOrNull(checkHasValue.data[i].problemIsChecked)){
                holdCleanArr.splice(i,1); 
            }
        }
        checkHasValue.data = holdCleanArr ; 
        component.set("v.problemDiagnosesData",checkHasValue);
        component.set("v.problemDiagnosesData.data",component.get("v.problemDiagnosesData").data);
        //  $A.get('e.force:refreshView').fire();
        console.log('getdata for problem '+JSON.stringify(component.get("v.problemDiagnosesData").data));
        
        component.set("v.openListOfProblems",false);
        component.set("v.showDefaultProcedureNotification",true);        
        
    },
    
    onCheck: function(component, event, helper) {
        if(component.get("v.isRestrict") ==true){
            component.set("v.isRestricted", true);
            //var actionbuttons=true;
            helper.helperInit(component, event, helper);
        }
        else{
            component.set("v.isRestricted", true);
        }
    },
    
    onCancel: function(component) {
        if(component.get("v.isRestrict") ==true){
            component.set("v.isRestricted", false);
            component.set("v.isRestrict", false);
            component.set("v.SecurityKeys", "");
        }
        else{
            component.set("v.isRestricted", false);
            component.set("v.isRestrict", true);
            component.set("v.SecurityKeys", "");

        }
    },
    handleDrawAnnotateMC: function(component, message) {
        try {
            if (message != null && message.getParam("isLoaded") != null) {
                if (message.getParam("isLoaded")) {
                    component.set("v.numberOfImagesToLoad", parseInt(component.get("v.numberOfImagesToLoad")) - 1);
                }
                else {
                    // LWC tried to load this image but failed, error was already shown in console by LWC
                    // let's stop the spinner, else it will keep showing indefinitely
                    component.set("v.numberOfImagesToLoad", 0);
                }
            }   

 

            if (parseInt(component.get("v.numberOfImagesToLoad")) === 0) {
                setTimeout(() => {
                    component.set("v.loaded",true);
                }, "300");
            }
        } catch (error) {
            console.error("error in handleDrawAnnotateMC: ", error.message);
            // Let's stop the spinner else it will keep showing indefinitely
            component.set("v.loaded",true);
        }
    },
    
    onSubmit: function(component, event, helper) {
        var nameSpace = 'ElixirSuite__' ;
        console.log('nameSpace'+nameSpace);
        var action = component.get( 'c.UinfoNew' );
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(component.get("v.isRestrict") ==true){
                    var DataList =JSON.parse(JSON.stringify(component.get("v.listDetails"))) ;
                    var NewDataList=[];
                    for(var i in DataList){
                        NewDataList.push(DataList[i]);
                        /* if($A.util.isUndefinedOrNull(DataList[i][nameSpace+ 'Visit1__c'])){
                            NewDataList.push(DataList[i]);
                        }*/
                    }
                    component.set("v.listDetails",NewDataList)
                    var isValidate ;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                        if(userNameVal == res[0].ElixirSuite__Verification_Code_New__c){
                            userName.set("v.errors",null);
                            isValidate = true;
                        }else{
                            userName.set("v.errors",[{message:'Invalid Key!!'}]);
                        }
                    }
                    
                    if(isValidate){
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", true);
                        //component.set("v.deletionAbility", true);
                        //component.set("v.enableExportAsPdf", false);
                        component.set("v.SecurityKeys", "");
                    }
                }
                else{
                    //var actionbuttons=false;
                    helper.helperInit(component, event, helper);
                    let isValidate ;
                    let userName = component.find('userName');
                    let userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                        if(userNameVal == res[0].ElixirSuite__Verification_Code_New__c){
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
                        //component.set("v.deletionAbility", false);
                        //component.set("v.enableExportAsPdf", false);
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
    
    handleMedication :  function(component)  {
        component.set("v.openUpdateMedication",true);
    },
    handleMedicationDataEvent : function(component, event)  {
        var buffer  = component.get("v.medicationData");
        buffer.hasValue=true;
        var jsonList = event.getParam("jsonList");
        
        component.set("v.medicationJSON",event.getParam("jsonList"));
        component.set("v.selectedUser",event.getParam("selectedUser")) ;
        component.set("v.selectedVia",event.getParam("selectedVia")) ;
        console.log('JSON LIST RECEIVED '+JSON.stringify(jsonList));
        
        var allData  = [];
        allData.push(jsonList.jsonListForTaper);
        allData.push(jsonList.jsonListForPRN);
        allData.push(jsonList.jsonListForAOrder);
        
        
        var nameSpace = 'ElixirSuite__' ;
        var selectedUser = event.getParam("selectedUser");
        console.log('selectedUser'+selectedUser);
        var selectedVia = event.getParam("selectedVia");
        console.log('selectedVia'+selectedVia);
        for (var j=0;j<allData.length;j++) {
            for(var i=0;i<allData[j].length;i++) {
                var obj = {};
                if(allData[j][i].Days.length>0){
                    obj[nameSpace + 'Frequency__c'] = allData[j][i].Days[0].textMessage;  
                }
                else {
                    obj[nameSpace + 'Frequency__c'] = '';
                }
                
                obj[nameSpace + 'Type__c'] = allData[j][i].types;
                obj[nameSpace+'Drug_Name__c'] = allData[j][i].medicationName;
                obj[nameSpace + 'Route_New__c'] = allData[j][i].Route;
                obj[nameSpace+'Reason_new__c'] = allData[j][i].reasonLabel;
                buffer.data.push(obj);
                
            }
            
        }
        
        component.set("v.medicationData",buffer);
        console.log('buffer data after set ' +JSON.stringify( component.get("v.medicationData")));
        
    },
    // TEXT GENERATION 
    textGenerateMultiPicklist : function(component, event, helper) {  
        try{
            let name = event.getSource().get("v.name");
            let names = name.split('#');
            
            let sectionIdx = names[0];
            let fieldName = names[1];
            console.log('fieldName'+fieldName);
            let dataType = names[2];
            let idxRow = names[3];
            let idxCol = names[4];
            let cssRecords = component.get("v.cssRecords");
            let section = cssRecords[parseInt(sectionIdx)];            
            var controllerValue = event.getSource().get("v.value");
            if(dataType=='PICKLIST'){//Multipicklist can never be controlling
                let column = cssRecords[parseInt(sectionIdx)].ElixirSuite__Object_1_css__r[parseInt(idxRow)].Columns[parseInt(idxCol)];
                console.log('column controller 1st '+column);
                helper.findDependentField(component, column,cssRecords,controllerValue);
            }if(section['ElixirSuite__Enable_Auto_text__c'] == false || $A.util.isUndefinedOrNull(section['bluePrint'])){
                return;
            }
            
            let defaultText = section['DefaultAutoText'];   
            console.log('defaultText'+defaultText);
            let sectionList = section.ElixirSuite__Object_1_css__r;
            var allValues = {};
            for(let idx in sectionList){
                let columns = [];
                if(!$A.util.isUndefinedOrNull(sectionList[idx].Columns)){
                    columns = sectionList[idx].Columns;
                }
                if(columns.length > 0){
                    for(let idxColumn in columns){
                        let fieldName = columns[idxColumn]['ElixirSuite__Field_Name__c'];
                        if(!$A.util.isUndefinedOrNull(fieldName) && !$A.util.isUndefinedOrNull(columns[idxColumn].value)){
                            allValues[fieldName] = columns[idxColumn].value;
                        }
                    }
                }
            }
            console.log('allValues ' +JSON.stringify(allValues));
            let bluePrint = JSON.parse(JSON.stringify(section['bluePrint']));
            var finalSetOfValues = [];
            for(let idx in bluePrint){
                let allFieldsInText = bluePrint[idx];
                let value;
                if(allFieldsInText.includes('*')){
                    value = helper.createListForAutoText('*',allFieldsInText,allValues);
                }else if(allFieldsInText.includes('@')){
                    value = helper.createListForAutoText('@',allFieldsInText,allValues);
                }else if(allFieldsInText.includes('+')){
                    value = helper.createListForAutoText('+',allFieldsInText,allValues);
                }else{
                    value = helper.createListForAutoText(';',allFieldsInText,allValues);
                }
                finalSetOfValues.push(value);
            }    
            
            // AutoText Population
            //let autoText = helper.setBrackets(finalSetOfValues, section, helper);
            
            // Auto Text UI 
            let autoTextUi = section['AutoText'];
            autoTextUi = autoTextUi.replaceAll('{', '[');
            autoTextUi = autoTextUi.replaceAll('}', ']');
            if(autoTextUi){// FROM UI
                let count = 0;
                while(autoTextUi.lastIndexOf("[") != -1){
                    var extractedTextWithinBrackets = autoTextUi.substring(
                        autoTextUi.lastIndexOf("[") + 1,
                        autoTextUi.lastIndexOf("]")
                    );
                    console.log('extractedTextWithinBrackets'+extractedTextWithinBrackets);
                    let startIdx = autoTextUi.lastIndexOf("[");
                    let endIdx = autoTextUi.lastIndexOf("]")+1;
                    let firstPart = autoTextUi.substr(0, startIdx);
                    let lastPart = autoTextUi.substr(endIdx);
                    let textAfterExtraction = firstPart + ' ' + finalSetOfValues[count] + ' ' + lastPart;
                    autoTextUi = textAfterExtraction;
                    count++;       
                }
            }
            section['AutoText'] = autoTextUi;
            component.set("v.cssRecords", cssRecords);
        }
        catch(exe){
            // alert(exe);
        }
    },
    handleValueChange : function (component) {
         console.log("kk---" , JSON.stringify(component.get("v.selectedVal")));
    },

    updateModularMatrixData: function(component, event) {
        let modularMatrixData = component.get("v.modularMatrixData");
        modularMatrixData[event.getParam('sectionNumber')] = event.getParam('data');

        component.set("v.modularMatrixData", modularMatrixData);

        //console.log("updateform: value updated: ", JSON.stringify(component.get("v.modularMatrixData")));
    },
                    showAllergyColumn:function(cmp){
                        cmp.set("v.showAllergyColumnOptions",true); 
                    },
                    sortAllergyColumn : function (component, event, helper) {
                        try{
                            var fieldName = event.getParam('fieldName');
                            var sortDirection = event.getParam('sortDirection');
                            component.set("v.sortedByAllergy", fieldName);
                            component.set("v.sortedDirectionAllergy", sortDirection);
                            helper.sortAllergyData(component, fieldName, sortDirection);
                        }
                        catch(e){
                            console.log('error '+e);
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
                            console.log('error '+e);
                        }
                        
                    }, 
                    sortDiagnosisColumn : function (component, event, helper) {
                        try{
                            var fieldName = event.getParam('fieldName');
                            var sortDirection = event.getParam('sortDirection');
                            component.set("v.sortedByDiagnosis", fieldName);
                            component.set("v.sortedDirectionDiagnosis", sortDirection);
                            helper.sortDiagnosisData(component, fieldName, sortDirection);
                        }
                        catch(e){
                            console.log('error '+e);
                        }
                        
                    },
                    sortMedicationColumn : function (component, event, helper) {
                        try{
                            var fieldName = event.getParam('fieldName');
                            var sortDirection = event.getParam('sortDirection');
                            component.set("v.sortedByMedications", fieldName);
                            component.set("v.sortedDirectionMedications", sortDirection);
                            helper.sortMedicationData(component, fieldName, sortDirection);
                        }
                        catch(e){
                            console.log('error '+e);
                        }
                        
                    },
                    refresColumnForAllergy1 : function(component, event, helper) {
                        console.log('Entering updated refresColumnForAllergy1...');
                        var allergyList = event.getParam("allergyList");
                        console.log('allergyList in parent event: '+JSON.stringify(allergyList));
                        component.set("v.loaded",true);
                        console.log('Setting loaded to true...');
                        helper.fetchExternalCmpData(component , event , helper);
                        console.log('Setting loaded to false...');
                        component.set("v.loaded",false);
                    },
                    refresColumnForAllergy : function(component, event, helper) {
                        console.log('Entering refresColumnForAllergy...');
                        component.set("v.loaded",true);
                        console.log('Setting loaded to true...');
                        helper.fetchExternalCmpData(component , event , helper);
                        console.log('Setting loaded to false...');
                        component.set("v.loaded",false);
                    },
                    handleEditAllergySave: function(component, event, helper) {
                        var draftValues = event.getParam('draftValues');
                        console.log('draftValues: '+draftValues);
                        helper.saveChangesOfAllergy(component,  event, helper, draftValues);
                          
                    },
                    
})