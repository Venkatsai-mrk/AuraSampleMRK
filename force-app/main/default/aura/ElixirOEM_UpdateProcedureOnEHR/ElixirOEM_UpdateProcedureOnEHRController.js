({
    doInit : function(component, event, helper) {
        try{ 
            helper.setIsDiagnosisCodeAvailableForThisAccount(component,event, helper);
            helper.getFieldSet(component, event, helper); 
            helper.setDefaultJSON(component,'');
            helper.enableCareEpisode(component, event, helper);
            if(component.get("v.AllFlag")){
                component.set("v.AllFlag_Modfiers",true);
            }
            var action = component.get("c.fetchRecordInView");
            action.setParams({ accountId : component.get("v.accountId"),
                              recordId :component.get("v.RowId") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    component.set("v.patientName", response.getReturnValue().patientName);                   
                    let res = response.getReturnValue().mapPickListValues;  
                    let procedureRecordTypeId = response.getReturnValue().procedureRecordTypeId;
                    component.set("v.procedureRecordTypeFilter","RecordTypeId='" + procedureRecordTypeId + "'");
                    
                    let practitionerRecTypeId = response.getReturnValue().practitionerRecTypeId;
                    component.set("v.practitionerRecordTypeFilter","RecordTypeId='" + practitionerRecTypeId + "'");
                    
                    let bedRecordTypeId = response.getReturnValue().bedRecordTypeId;   
                    component.set("v.bedRecordTypeFilter","RecordTypeId='" + bedRecordTypeId + "'");
                    
                    let roomRecordTypeId = response.getReturnValue().roomRecordTypeId;   
                    component.set("v.roomRecordTypeFilter","RecordTypeId='" + roomRecordTypeId + "'");
                    
                    let suiteRecordTypeId = response.getReturnValue().suiteRecordTypeId;   
                    component.set("v.suiteRecordTypeFilter","RecordTypeId='" + suiteRecordTypeId + "'");
                    let arr = [];
                    for(let obj in res){
                        let sObj = {'label' : obj, 'value' : res[obj]};
                        arr.push(sObj);
                    }
                    console.log('list val '+JSON.stringify(arr));
                    component.set("v.codeCategory",arr);   
                    let procRec = response.getReturnValue().procedureRecords;
                    console.log('procRec.ElixirSuite__Notes__c***upd1',procRec[0].ElixirSuite__Notes__c);
                    component.set("v.recordDetail.Notes",procRec[0].ElixirSuite__Notes__c);
                    helper.setPlaceOfServicePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_placeOfService);
                    helper.setClaimTypePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_claimType); 
                    helper.setStatusPicklistVal(component,response.getReturnValue().mapPickListValues_status,response.getReturnValue().mapPickListValues_defaultStatus);
                    helper.setDiagnosisData(component, event, helper,response.getReturnValue().junctionData); // on screen data
                    helper.setDiagnosisRecords(component, event, helper,response.getReturnValue().patientICDs); // templates
                    helper.setpaymentTypePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_paymentType);                 
                    helper.setClaimData(component, event, helper,response.getReturnValue().obj);
                    helper.setProcedureData(component, event, helper,response.getReturnValue().procedureRecords);    
                    helper.setIsProcessed(component, event, helper,response.getReturnValue().isProcessed);
                    console.log('rec detail '+JSON.stringify(component.get("v.recordDetail")));
                    if(component.get("v.AllFlag")){
                        helper.disableAccountRelatedDiagnosisData(component, event, helper);  
                        component.set("v.AllFlag_Modfiers",true);
                    }
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    
    recordIdChange: function(component, event, helper) {
        console.log('recordIdChange***');
        console.log("recordIdChange***old value: ", event.getParam("oldValue"));
        console.log("recordIdChange***current value: ", event.getParam("value"));
        var currentVal = event.getParam("value");
        if(currentVal!=null){
            helper.setTypeOfPayment(component, event, currentVal);
        }
    },
    
    handleCategoryChange: function(component, event) {
        if(event.getSource().get("v.value")){                  
            component.set("v.recordDetail.procedureSelected",'');         
            component.set("v.AllFlag_Procedure",false);
        }
        else{
            component.set("v.AllFlag_Procedure",true);
        }
        // helper.checkModifiers(component, event, helper);
    },
    closeModel : function(component) {
        component.set("v.isConsoleView",false);
        component.set("v.isView",false);
    },
    createObjectData: function(component) {
        var RowItemList = component.get("v.modifierData");      
        RowItemList.push({'modfier' : '',
                          'modfierId' : '',
                          'description' : '',
                          'notes' : ''});                     
        component.set("v.modifierData", RowItemList);
        console.log('RI LIST '+ component.get("v.modifierData"));        
    },
    removeDeletedRow: function(component, event, helper) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;
            var AllRowsList = component.get("v.modifierData");
            if(AllRowsList.length!=1){
                AllRowsList.splice(index, 1);
                component.set("v.modifierData", AllRowsList);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "CANNOT DELETE LAST ROW",
                    "message": " ",
                    "type" : "error"
                });
                toastEvent.fire();
            }
            helper.CheckModifiers(component, event, helper,component.get("v.modifierData"),component.get("v.ProcedureCodeLabel"));
        }
        catch(e){
            alert('error '+e);
        }
    },
    addDiagnosisToProcedure : function(component, event) {
        try{
            var index =  event.getSource().get("v.name");          
            var array = index.split('$');
            var sectionIndex = array[0];
            var recordId = array[1];
            let arr = component.get("v.accountRelatedDiagnosisData");
            let arrIndex = arr.findIndex(obj => obj.Id == recordId);
            let record = arr[arrIndex];
            var sectionLst = component.get("v.diagnosisData");
            sectionLst.push({'diagnosis' :record.Name,'description' :record.ElixirSuite__Code_Description1__c,
                             'Id' :record.Id,'notes' : '','type':'New'}); // 'type':'New' added in JSON for LX3-5537
            component.set("v.diagnosisData",sectionLst);
            let acctDiagnosisData =  component.get("v.accountRelatedDiagnosisData");
            acctDiagnosisData[sectionIndex].disabled = true;
            component.set("v.accountRelatedDiagnosisData",acctDiagnosisData);
        }
        catch(e){
            alert('error '+e);
        }
    },
    removeProcedureDiagnosis: function(component, event) {
        try{
            /*var ctarget = event.currentTarget;
            //alert('ctarget-->'+ctarget);
            var recId = ctarget.id;
            component.set("v.recordError" , recId);*/
            //alert('recId-->'+recId);
            /*if(deleteRec)
            {
                helper.deleteProcedure(component, event, helper, recId);
            }*/       
            
            /**var AllRowsList = component.get("v.accountRelatedDiagnosisData");
			alert('AllRowsList '+AllRowsList);
            let arr = component.get("v.diagnosisData");

            let arrIndex = arr.findIndex(obj => obj.Id == recId);
          
            AllRowsList.splice(arrIndex, 1);
            component.set("v.diagnosisData", AllRowsList); **/
            // LX3-6311
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;
            //helper.enableButton(component, event, helper,index);
            var AllRowsList = component.get("v.diagnosisData");
            if (AllRowsList.length <= 1) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Cannot delete the last row",
                    "type" : "error"
                });
                toastEvent.fire();
                return;
            }
            let arr = component.get("v.diagnosisData");
            let arrIndex = arr.findIndex(obj => obj.Id == index);
            console.log('res '+JSON.stringify(AllRowsList[arrIndex]));
            
            var deleteRecord = component.get("v.deleteDiagnosisData");
            deleteRecord.push(AllRowsList[arrIndex]);
            component.set("v.deleteDiagnosisData", deleteRecord);
            console.log('deleteDiagnosisData '+JSON.stringify(component.get("v.deleteDiagnosisData")));
            
            AllRowsList.splice(arrIndex, 1);
            component.set("v.diagnosisData", AllRowsList);
            console.log('diagnosisData '+JSON.stringify(component.get("v.diagnosisData")));            
        }
        catch(e){
            alert('error '+e);
        }
    },
    openProcedure:  function(component) {
        component.set("v.openProblem",true);
    },
    handleComponentEvent:  function(component, event, helper) {
        component.set("v.modifierData",component.get("v.modifierData"));
        console.log('modifierData '+ component.get("v.modifierData"));
        helper.CheckModifiers(component, event, helper,component.get("v.modifierData"),component.get("v.ProcedureCodeLabel"));
    },
    updateRecord : function(component, event, helper) {
        try{
            var checkSave  = true;
            component.set("v.errorMessage",'');

            var diagnosisDataLst = component.get("v.diagnosisData");
            console.log('diagnosisDataLst ' + JSON.stringify(diagnosisDataLst));
            let hasBlankDiagnosis = false; 		
            diagnosisDataLst.forEach(function(element, index) {
            console.log('element ' + JSON.stringify(element));
            console.log('element.Id ' + JSON.stringify(element.Id));
            console.log('element.diagnosis ' + JSON.stringify(element.diagnosis));
        
            if ((!element.Id || !element.diagnosis)  && diagnosisDataLst.length > 1) {
                hasBlankDiagnosis = true;
            }
           });
            if(component.get("v.recordDetail").isBillable == true && (component.get("v.recordDetail").typeOfPayment =='NONE' || component.get("v.recordDetail").typeOfPayment =="")){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE SELECT TYPE OF PAYMENT",
                    "message": "Please select type of payment!",
                    "type" : "error"
                });
                toastEvent.fire(); 
                checkSave = false ;
            }
            else if(component.get("v.recordDetail").isBillable == false){
                checkSave = true;
            }
            else if(hasBlankDiagnosis) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Please fill the value",
                    "message": "Please add diagnosis code or remove any empty row(s).",
                    "type": "ERROR"
                });
                toastEvent.fire();
                checkSave = false;
                }
            console.log('modifierData '+JSON.stringify(component.get("v.modifierData")));
            console.log('modifierData '+JSON.stringify(component.get("v.modifierData")));
            var ModifierData = component.get("v.modifierData");
            //let selectedModifierNames = [];
            ModifierData.forEach(function(element) {
                console.log(' element '+JSON.stringify(element));
                console.log(' element.modfierId '+JSON.stringify(element.modfierId));
                if($A.util.isUndefinedOrNull(element.modfierId) || $A.util.isEmpty(element.modfierId)){
                    component.set("v.isModifierCombination",true);   
                }
            }); 
            if(component.get("v.isModifierCombination")){
                if(component.get("v.recordDetail").procedureSelected && checkSave == true){
                    if(component.get("v.recordDetail").typeOfPayment == 'Insurance Payment' &&
                      component.get("v.recordDetail").Status  == 'Canceled' &&
                      component.get("v.recordDetail").isReadyForBilling == true &&
                      component.get("v.recordDetail").claimGenerated == false )
                    {
                        var errorMessageValue = $A.get("$Label.c.ProcedureCancelation");
            			component.set("v.errorMessage",errorMessageValue);
                         component.set("v.showConfirmation", true);
                    }
                    else if(component.get("v.recordDetail").typeOfPayment == 'Insurance Payment' &&
                      component.get("v.recordDetail").Status  == 'Canceled' &&
                      component.get("v.recordDetail").isReadyForBilling == true &&
                      component.get("v.recordDetail").claimGenerated == true)
                    {
                        var errorMessageValue = $A.get("$Label.c.ProcedureClaimCancelation");
            			component.set("v.errorMessage",errorMessageValue);
                         component.set("v.showConfirmation", true);
                    }else{
                        helper.updateRecordHelper(component,event,helper);
                    }
                }
                else if(component.get("v.recordDetail").procedureSelected == false){
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        "title": "PLEASE SELECT PROCEDURE",
                        "message": "Please search for procedures!",
                        "type" : "error"
                    });
                    toastEvent1.fire();   
                }
                /* For Deleting the Diagnosis Record starts---
            let deleteRec = component.get('v.recordError');
            helper.deleteProcedure(component, event, helper, deleteRec);
            // For Deleting the Diagnosis Record ends---*/
                
                // For Updating the Diagnosis Record starts---
                /*let updateRec = component.get('v.recordError');
            alert('updateRec'+updateRec);
            helper.updateProcedureDiagnosis(component, event, helper, updateRec);*/
                // For Updating the Diagnosis Record ends---
                
                
            }else{
                var toastEvet = $A.get("e.force:showToast");
                toastEvet.setParams({
                    "title": "No data available for the combination of Procedure Code & Modifiers.",
                    "message": "Please contact your system administrator",
                    "type" : "error"
                });
                toastEvet.fire(); 
            }
        }
        catch(e){
            alert('error '+e);
        }
    },
    
    handleNo: function(component) {
        component.set("v.showConfirmation", false);
    },
    
    handleYes: function(component,event,helper) {
        component.set("v.showConfirmation", false);
		helper.updateRecordHelper(component,event,helper);
   
    },
    renderDown:function(){
        var intervalID = setInterval(function() {
            document.getElementById('modal-content-id-1').scrollTop =  document.getElementById('modal-content-id-1').scrollHeight;
        }, 150);
        setInterval(function() {
            clearInterval(intervalID);
        }, 1000);
    },
    isBillableChange : function(component){
        if(component.get("v.recordDetail.isBillable") == false){
            component.set("v.recordDetail.typeOfPayment", 'NONE');   
        }
    },
    
    updateAndNew : function(component) {
        try{
            var checkSave  = true;
            if(component.get("v.recordDetail").isBillable == true && (component.get("v.recordDetail").typeOfPayment =='NONE' || component.get("v.recordDetail").typeOfPayment =="")){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PLEASE SELECT TYPE OF PAYMENT",
                    "message": "Please select type of payment!",
                    "type" : "error"
                });
                toastEvent.fire(); 
                checkSave = false ;
            }
            else if(component.get("v.recordDetail").isBillable == false){
                checkSave = true;
            }
            if(component.get("v.recordDetail").procedureSelected && checkSave == true){
                component.set("v.loaded",false);
                let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                console.log('data to save '+JSON.stringify(payloadToSave));
                
                let diagnosisData = component.get("v.diagnosisData");
                let filteredDiagnosisData = [];
                let allIds = [];
                for (const i of diagnosisData) {
                    if (i.Id && i.Id.trim() != "" && !allIds.includes(i.Id)) {
                        filteredDiagnosisData.push(i);
                    }
                    allIds.push(i.Id);
                }
                
                var action = component.get("c.updateProcedure");
                action.setParams({'payload' : JSON.stringify(payloadToSave),
                                  'accountId' : component.get("v.accountId"),
                                  'diagnosisData' : JSON.stringify(filteredDiagnosisData),
                                  'modifierData' : JSON.stringify(component.get("v.modifierData")),
                                  'procedureId' : component.get("v.RowId"),
                                  'deletediagnosisData' : JSON.stringify(component.get("v.deleteDiagnosisData"))});
                action.setCallback(this, function(response) { 
                    var state = response.getState();
                    if (state === "SUCCESS") {                
                        component.set("v.loaded",true);
                        var cmpEvent = component.getEvent("ElixirOEM_ProblemColumnsEvent");
                        cmpEvent.fire();
                        component.set("v.isView",false);
                        component.set("v.newProcView",true);
                    }
                    else{
                        component.set("v.loaded",true); 
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0]) {
                                console.log("Error message: " +
                                            errors[0].message);
                            }        }
                    }
                    
                });
                
                $A.enqueueAction(action); 
            }
            else if(component.get("v.recordDetail").procedureSelected == false){
                var toastEvent3 = $A.get("e.force:showToast");
                toastEvent3.setParams({
                    "title": "PLEASE SELECT PROCEDURE",
                    "message": "Please search for procedures!",
                    "type" : "error"
                });
                toastEvent3.fire();   
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    
    /*onChange: function(component) {
        var input = component.find("editName");
        var newName = component.get("v.bufferName");
        if (newName.length > 254) {
            input.setCustomValidity("You can't type over 255-symbols name");
            input.reportValidity();
        } else {
            input.setCustomValidity("");
            input.reportValidity();
        }
    },*/
    RowUpdate: function(component) {
        try{
            
            var recU = JSON.stringify(component.get("v.diagnosisData"));
            // var re = String.valueOf(mapOfDiagnosis.get('description'));
            //console.log('recU--> '+recU);
            // console.log('re--> '+re);
            /*var ctarget = event.currentTarget;
            alert('ctarget-->'+ctarget);
            var updateRecId = ctarget.id;
            component.set("v.recordError" , updateRecId);
            alert('updateRecId-->'+updateRecId);*/
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    
    callAddBlankRowInDiagnosisData : function(component, event, helper) {
        helper.addBlankRowInDiagnosisData(component, event, helper);
    },
    navToAccRecord: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.accountId")
        });
        navEvt.fire();
    },
    navToListView: function() {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },
})