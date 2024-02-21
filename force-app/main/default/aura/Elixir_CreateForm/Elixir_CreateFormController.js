({
    myAction : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: component.get("v.changedFormName")
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: component.get("v.changedFormName")
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:answer",
                iconAlt: "All Notes"
            });
        })
        console.log(component.get("v.isActualNotes"));
        component.set("v.changedFormName",component.get("v.formName"));
        component.set("v.patientID",component.get("v.recordId"));
        var today = new Date();
        component.set('v.today', today.getDate() + "-" + (today.getMonth() + 1) + "-" + today.getFullYear() );
        let date  = new Date();
        helper.fetchNspc(component, event, helper);//added by Anmol
        helper.fetchCustomSett(component, event, helper);//added by Anmol
        console.log('timeWrapper '+JSON.stringify(component.get("v.timeWrapper")));
        helper.buildParentWrapperForExternalComponents(component , event , helper);
        helper.buildNotesSpecificData(component , event , helper);
        helper.fetchAllergyColumnsFromCustomSetting1(component , event , helper);
        helper.fetchExternalCmpData(component , event , helper);
        
        helper.fetchProblemColumnsFromCustomSetting1(component , event , helper);
      //  helper.fetchColumnsForProblemsFromCustomSetting(component , event , helper);
        helper.fetchProblemDataOnformsinit(component , event , helper); //changing this as per request LX3-12304
        helper.fetchColumnsFromCustomSetting1(component , event , helper);
        helper.fetchDiagnosisDataOnformsinit(component , event , helper); //changing this as per request LX3-12304
          helper.fetchMedicationColumnsFromCustomSetting(component , event , helper);
          helper.fetchMedicationsDataOnformsinit(component , event , helper); //changing this as per request LX3-12304
         //helper.fetchColumnsFromCustomSetting(component , event , helper);
         //fetchColumnsFromCustomSetting1
        
        
        try{
            helper.helperInit(component , event , helper);
        }catch(ex){
            helper.showError(component, JSON.stringify(ex));
            component.set("v.loaded",true);
            component.set("v.isOpen",false);
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
    
    
    handleUpdateVitalList : function(component, event, helper) {
        try {
            console.log('handleCallMethodEvent: ');
            console.log('@@@@####!!!',event.getParam("vitalData").vitalData);
            if(!$A.util.isUndefinedOrNull(component.get("v.notesSpecificData"))){
                let notesSpecificDataObj = component.get("v.notesSpecificData");
                notesSpecificDataObj.vitalData = notesSpecificDataObj.vitalData.concat(event.getParam("vitalData").vitalData);
                component.set("v.notesSpecificData", notesSpecificDataObj);
            }
            console.log('component.set("v.notesSpecificData", notesSpecificDataObj);',component.get("v.notesSpecificData"));
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
    handleProblemColumnEvent : function(component, event, helper) {     
         helper.fetchProblemDataOnforms(component , event , helper);
    },
    handleDaignosesDataEvent : function(component, event, helper) {     
         helper.fetchDiagnosisDataOnforms(component , event , helper);
    },
    closeModal : function(component, event, helper) {     
         component.set("v.showRelatedDiagnosis", false);
    },
    saveModal : function(component, event,helper) {     
         component.set("v.showRelatedDiagnosis", false);
         helper.fetchDiagnosisDataOnforms(component , event , helper);
                component.set("v.loaded",false);// Refresh data after save
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
                
    
    
 /*   handleAddProblemEvent: function(component, event, helper) {
        try {
        var problemData = event.getParam("problemList");
        console.log('calling Event');
        console.log('problemData'+JSON.stringify(problemData));
        // Convert the object to an array of objects
        var problemArray = [];
        for (var key in problemData) {
            if (problemData.hasOwnProperty(key)) {
                var problemItem = {'key': key, 'value': problemData[key]};
                problemArray.push(problemItem);
            }
        }

        // Add the array to problemListCopy
        var parentProblemListCopy = component.get("v.problemListCopy");
        parentProblemListCopy = parentProblemListCopy.concat(problemArray);
        console.log('parentProblemListCopy'+JSON.stringify(parentProblemListCopy));
        component.set("v.problemListCopy", parentProblemListCopy);
    } catch (e) {
        console.error(e);
    }
    },*/
     refresColumnForAllergy : function(component, event, helper) {
           console.log('Entering refresColumnForAllergy...');
         component.set("v.loaded",true);
         console.log('Setting loaded to true...');
       	helper.fetchExternalCmpData(component , event , helper);
         console.log('Setting loaded to false...');
         component.set("v.loaded",false);
     },
     refresColumnForAllergy1 : function(component, event, helper) {
           console.log('Entering refresColumnForAllergy1...');
         var allergyList = event.getParam("allergyList");
         console.log('allergyList in parent event: '+JSON.stringify(allergyList));
         component.set("v.loaded",true);
         console.log('Setting loaded to true...');
       	helper.fetchExternalCmpData(component , event , helper);
         console.log('Setting loaded to false...');
         component.set("v.loaded",false);
     },
    handleAddProblemEvent : function(component, event, helper) {
         component.set("v.loaded",true);
            helper.fetchProblemDataOnforms(component , event , helper);
        component.set("v.loaded",false);
     },
    
    handleAddDiagnosisEvent : function(component, event, helper) {
         component.set("v.loaded",true);
            helper.fetchDiagnosisDataOnforms(component , event , helper);
        component.set("v.loaded",false);
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
    validateStartTime : function(component, event, helper) {
        try{
            let val = JSON.parse(JSON.stringify(event.getSource().get("v.value")));
            let result = new Date(val);
            let endTime = new Date(component.get("v.timeWrapper").endTime);
            if(result.setSeconds(0, 0)>new Date().setSeconds(0, 0)){
                helper.globalFlagToast(component, event, helper,'Start Time cannot be greater than the Current Time', ' ','error');
                component.set("v.RestrictButtons",true); 
            }
            else if(endTime){
               if(endTime.setSeconds(0, 0)>new Date().setSeconds(0, 0)){
                    helper.globalFlagToast(component, event, helper,'End Time cannot be greater than the Current Time', ' ','error');
                    component.set("v.RestrictButtons",true); 
                }
                 else if(endTime.setSeconds(0, 0)< new Date(startTime).setSeconds(0, 0)){
                   helper.globalFlagToast(component, event, helper,'End Time cannot be less than the Start Time', ' ','error');
                    component.set("v.RestrictButtons",true);  
                }
            }
            
            else {
                component.set("v.RestrictButtons",false); 
            }
        }
        catch(e){
            alert(e)
        }
        
    },
    validateEndTime : function(component, event, helper) {
        try{
            let val = JSON.parse(JSON.stringify(event.getSource().get("v.value")));
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
        catch(e){
            alert(e)
        }
        
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

    // Added by Anmol for LX3-5770
    addPresc: function(component, event, helper) {
        
        component.set("v.addPresc", true);
    },
    // End by Anmol for LX3-5770

    // Added by Anmol for LX3-5676
    addInv: function(component, event, helper) {
        
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
    
    onCancel: function(component, event, helper) {
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
    
    onSubmit: function(component, event, helper) {
        var nameSpace = 'ElixirSuite__' ;
        var action = component.get( 'c.UinfoNew' );
        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(component.get("v.isRestrict") ==true){
                    var dataList =JSON.parse(JSON.stringify(component.get("v.listDetails"))) ;
                    var newDataList=[];
                    for(var i in dataList){
                        newDataList.push(dataList[i]);
                        /* if($A.util.isUndefinedOrNull(DataList[i][nameSpace+ 'Visit1__c'])){
                            NewDataList.push(DataList[i]);
                        }*/
                    }
                    component.set("v.listDetails",newDataList)
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
    
    handleClick : function(component, event, helper) {
        if(helper.runValidationForms(component, event, helper)){
            helper.savecreatedForm(component, event, helper);
        }
    },
    handleConfirmDialogYes : function(component, event, helper) {
         component.set("v.showConfirmDialog",false); 
        var timeObj = component.get("v.timeWrapper");
        timeObj.setEndTimeAsCurrent = true;
        component.set("v.timeWrapper",timeObj);
        helper.savecreatedForm(component, event, helper); 
    },
    handleConfirmDialogNo : function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
    },
    handleCancel : function(component, event, helper) {
        helper.deleteProblemsIfAny(component, event, helper);
        var appEvent = $A.get("e.c:FormsRefreshEvt");
        appEvent.setParams({"cancel" : true}); 
        appEvent.fire();
        component.set("v.isOpen",false);
    },
    handleAddAllergy : function(component, event, helper) {        
        component.set("v.showNewAllergy",true);
      /* var elements = document.getElementsByClassName("allergySection");
       elements[0].style.display = 'block';*/
    },
    hideAllergySection : function(component, event, helper) {
        var message = event.getParam("path");
        console.log('message1'+message);
        if(message == 'allergy'){
            var elements = document.getElementsByClassName("allergySection");
            elements[0].style.display = 'none';
        }
        else if(message == 'glucose'){
            var elements = document.getElementsByClassName("glucoseSection");
            elements[0].style.display = 'none';   
        }
            else if(message == 'vital'){
                console.log('Vital message2'+message);
                var elements = document.getElementsByClassName("vitalSection");
                elements[0].style.display = 'none';
            }
                else if( message == 'problem'){
                    var elements = document.getElementsByClassName("problemSection");
                    elements[0].style.display = 'none';   
                }
        
    },
    handleAddGlucose : function(component, event, helper) {        
        var elements = document.getElementsByClassName("glucoseSection");
        elements[0].style.display = 'block'; 
    },
    handleAddVitals : function(component, event, helper) {     
        var elements = document.getElementsByClassName("vitalSection");
        component.set("v.openVitalSign",true);
         component.set("v.isListVisible", true);
        //elements[0].style.display = 'block'; 
    },
     handleAddVitalClick: function(component, event, helper) {
        component.set("v.isListVisible", true);
    },
    handleAddProblem : function(component, event, helper) {     
        component.set("v.existingProblems",component.get("v.problemDiagnosesData")); 
        component.set("v.openListOfProblems",true);
    },
    handleproblemDaignosesDataEvent :  function(component, event, helper)  {
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
        console.log('getdata for problem '+JSON.stringify(component.get("v.problemDiagnosesData").data));
        
        component.set("v.openListOfProblems",false);
        component.set("v.showDefaultProcedureNotification",true);        
        
    },
    handleMedication :  function(component, event, helper)  {
        component.set("v.openUpdateMedication",true);
    },
    handleMedicationDataEvent : function(component, event, helper)  {
        var buffer  = component.get("v.medicationData");
        if (!buffer) {
            buffer = {};
        }
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
        var selectedVia = event.getParam("selectedVia");
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
            }
            
            if(section['ElixirSuite__Enable_Auto_text__c'] == false || $A.util.isUndefinedOrNull(section['bluePrint'])){
                return;
            }
            let defaultText = section['DefaultAutoText'];   
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
                console.log('allFieldsInText ',allFieldsInText);
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
            alert(exe);
        }
    },
    handleValueChange : function (component, event, helper) {
        // console.log("kk---" , JSON.stringify(component.get("v.selectedVal")));;
    },
    addProblem: function (component, event, helper) {
        try{
            let name = event.getSource().get("v.name");
            let forProbelm =  component.get("v.cssRecords");
            forProbelm[name].addProblem = true;
            component.set("v.cssRecords",forProbelm);
        }
        catch(exe){
            alert(exe);
        }
    },

    updateModularMatrixData: function(component, event) {
        let modularMatrixData = component.get("v.modularMatrixData");
        modularMatrixData[event.getParam('sectionNumber')] = event.getParam('data');

        component.set("v.modularMatrixData", modularMatrixData);

        //console.log("createform: value updated: ", JSON.stringify(component.get("v.modularMatrixData")));
    },

    handleDrawAnnotateMC: function(component, message, helper) {
        try {
            console.log("inside handleDrawAnnotateMC");
            console.log("message: ", JSON.stringify(message));
            console.log("isLoaded: ", message.getParam("isLoaded"));

            if (message != null && message.getParam("isLoaded") != null) {
                if (message.getParam("isLoaded")) {
                    component.set("v.numberOfImagesToLoad", parseInt(component.get("v.numberOfImagesToLoad")) - 1);
                    //console.log("yet to load ", parseInt(component.get("v.numberOfImagesToLoad")), " images");
                }
                else {
                    // LWC tried to load this image but failed, error was already shown in console by LWC
                    // let's stop the spinner, else it will keep showing indefinitely
                    component.set("v.numberOfImagesToLoad", 0);
                }
            }

            if (parseInt(component.get("v.numberOfImagesToLoad")) === 0) {
                // setTimeout(() => {
                //     component.set("v.loaded",true);
                //   }, "300");
                component.set("v.loaded",true);
                
            }
        } catch (error) {
            console.error("error in handleDrawAnnotateMC: ", error.message);
            // Let's stop the spinner else it will keep showing indefinitely
            component.set("v.loaded",true);
        }
    },
    showAllergyColumn:function(cmp){
        cmp.set("v.showAllergyColumnOptions",true); 
    },
    
    showOptions:function(cmp){
        cmp.set("v.showOptions",true); 
    },
    showOptions1:function(cmp){
        cmp.set("v.showOptions1",true); 
    },
    showOptionsForMedication:function(cmp){
        console.log('showOptionsForMedication');
        cmp.set("v.medicationConfiguration",true); 
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
    handleAddMedicationList: function(component, event, helper) {
        console.log('updated handleAddMedicationList');
         component.set("v.addMedicationList",true);
    },
    handleCloseVital:function(cmp){
        cmp.set("v.isListVisible",false); 
    },
    handleEditAllergySave: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveChangesOfAllergy(component,  event, helper, draftValues);
        
    },
    
})