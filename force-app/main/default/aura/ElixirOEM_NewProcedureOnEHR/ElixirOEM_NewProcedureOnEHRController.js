({
    doInit : function(component, event, helper) {
        try{
            helper.setPlaceOfServiceAndCodeCategory(component, event, helper);
            var errorMessageValue = $A.get("$Label.c.ProcedureCancelation");
            console.log('ehrproc****upd2');
            component.set("v.errorMessage",errorMessageValue);
            helper.setIsDiagnosisCodeAvailableForThisAccount(component,event, helper);
            helper.addBlankRowInDiagnosisData(component, event, helper);
            helper.getFieldSet(component, event, helper);
            helper.setDefaultJSON(component,'');
            var action = component.get("c.newScreenProcedureDomain");
            action.setParams({ accountId : component.get("v.accountId") });
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
                    
                        component.set("v.recordDetail.codeCategorySelected",component.get("v.defCodeCategory"));   
                        component.set("v.recordDetail.procedureSelected",'');         
                        component.set("v.AllFlag_Procedure",false);
                    
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
                    helper.setPlaceOfServicePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_placeOfService);
                    helper.setClaimTypePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_claimType,response.getReturnValue().mapPickListValues_defaultClaimType);  
                    helper.setStatusPicklistVal(component,response.getReturnValue().mapPickListValues_status,response.getReturnValue().mapPickListValues_defaultStatus); 
                    //  alert('s_ClaimType '+JSON.stringify(response.getReturnValue().mapPickListValues_claimType));
                    // alert('s_defaultClaimType '+JSON.stringify(response.getReturnValue().mapPickListValues_defaultClaimType));
                    // helper.setpaymentTypePicklistVal(component, event, helper,response.getReturnValue().mapPickListValues_paymentType);
                    helper.setpaymentTypePicklistVal(component, event, helper,response.getReturnValue().paymentType);
                    helper.setDiagnosisRecords(component, event, helper,response.getReturnValue().patientICDs);
                    helper.setActiveCareEpisode(component, response.getReturnValue().activeCareEpisode);
                    console.log('rec detail '+JSON.stringify(component.get("v.recordDetail")));
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
    
    handleCategoryChange: function(component, event, helper) {
        if(event.getSource().get("v.value")){                  
            component.set("v.recordDetail.procedureSelected",'');         
            component.set("v.AllFlag_Procedure",false);
        }
        else{
            component.set("v.AllFlag_Procedure",true);
        }
        helper.checkModifiersCustomSetting(component, event, helper);
    },
    closeModel : function(component) {
        component.set("v.isConsoleView",false);
        var workspaceAPI = component.find("workspace");
        if(component.get("v.backPage") || component.get("v.backPageRCM")) {  //NK---15/02/2023
            component.set("v.isView",false);
        } else {
            window.history.go(-2);
        }
        
        workspaceAPI.getFocusedTabInfo()
        .then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    createObjectData: function(component) {
        var RowItemList = component.get("v.modifierData");      
        RowItemList.push({'modfier' : '',
                          'modfierId':'',
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
                             'Id' :record.Id,'notes' : ''});
            component.set("v.diagnosisData",sectionLst);
            let acctDiagnosisData =  component.get("v.accountRelatedDiagnosisData");
            acctDiagnosisData[sectionIndex].disabled = true;
            component.set("v.accountRelatedDiagnosisData",acctDiagnosisData);
        }
        catch(e){
            alert('error '+e);
        }
    },
    removeProcedureDiagnosis: function(component, event, helper) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;
            helper.enableButton(component, event, helper,index);
            var AllRowsList = component.get("v.diagnosisData");
            let arr = component.get("v.diagnosisData");
            let arrIndex = arr.findIndex(obj => obj.Id == index);
            console.log('res '+JSON.stringify(AllRowsList[index]));
            AllRowsList.splice(arrIndex, 1);
            component.set("v.diagnosisData", AllRowsList);
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
        component.set("v.recordDetail.referenceCPTCode",component.get("v.ProcedureCodeLabel"));
        helper.CheckModifiers(component, event, helper,component.get("v.modifierData"),component.get("v.ProcedureCodeLabel"));
        
    },
    checkEndDate : function(component) { // added by jami as per LX3-6820,  Procedure End Date should not be less than Procedure Start Date. 
        var strDate = component.get("v.recordDetail.procedureStart");
        var endDate = component.get("v.recordDetail.procedureEnd");
        if(endDate<strDate){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": " Procedure End Date should not be less than Procedure Start Date.",
                "message": " ",
                "type" : "error"
            });
            toastEvent.fire(); 
            component.set("v.recordDetail.procedureEnd",'');
        }
    },
    saveRecord : function(component,event,helper) {
        try{
            var checkSave  = true;
            var strDate = component.get("v.recordDetail.procedureStart");
            console.log('strDate***',strDate);
            
            var diagnosisDataLst = component.get("v.diagnosisData");
            console.log('diagnosisDataLst ' + JSON.stringify(diagnosisDataLst));
            let hasBlankDiagnosis = false; 		
            diagnosisDataLst.forEach(function(element, index) {
            console.log('element ' + JSON.stringify(element));
                console.log('length ' + diagnosisDataLst.length);
            console.log('element.Id ' + JSON.stringify(element.Id));
            console.log('element.diagnosis ' + JSON.stringify(element.diagnosis));
           if ((!element.Id || !element.diagnosis) && diagnosisDataLst.length > 1) {
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
            
            else if(strDate==null || strDate==''){
                
                var toastEvent1 = $A.get("e.force:showToast");
                toastEvent1.setParams({
                    "title": "PLEASE SELECT PROCEDURE START DATE",
                    "message": "Please select procedure start date!",
                    "type" : "error"
                });
                toastEvent1.fire(); 
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
            var ModifierData = component.get("v.modifierData");
            let selectedModifierNames = [];
            let blankMod;  
            let InderNo;
            ModifierData.forEach(function(element, index) {
                console.log(' element '+JSON.stringify(element));
                console.log(' element.modfierId '+JSON.stringify(element.modfierId));
                if($A.util.isUndefinedOrNull(element.modfierId) || $A.util.isEmpty(element.modfierId)){
                    console.log('modfierId '+JSON.stringify(element.modfierId));
                    component.set("v.isModifierCombination",true);   
                }
                if((element.modfierId == '' || element.modfier == '') &&  ModifierData.length !== 1){
                    blankMod = true;
                    InderNo = parseInt(index)+ 1;
                    component.set("v.isModifierCombination",false);   
                    
                    
                }
                
            }); 
            
            
            
            
            console.log('selectedModifierNames '+selectedModifierNames);
            console.log('isModifierCombination contro '+component.get("v.isModifierCombination"));
            if(component.get("v.isModifierCombination")){
                if(component.get("v.recordDetail").procedureSelected && checkSave == true){
                    
                    if(component.get("v.recordDetail").typeOfPayment == 'Insurance Payment' &&
                      component.get("v.recordDetail").Status  == 'Canceled' &&
                      component.get("v.recordDetail").isReadyForBilling == true)
                    {
                         component.set("v.showConfirmation", true);
                    }else{
                        helper.saveRecordHelper(component,event,helper);
                    }
                    
                }
                else if(component.get("v.recordDetail").procedureSelected == false){
                    var toastEvnt = $A.get("e.force:showToast");
                    toastEvnt.setParams({
                        "title": "PLEASE SELECT PROCEDURE",
                        "message": "Please search for procedures!",
                        "type" : "error"
                    });
                    toastEvnt.fire();   
                }
            }else{
                console.log('AK '+ModifierData.length);
                if(blankMod == true && ModifierData.length !== 1){
                    console.log('AKAN');
                    var toastEvet = $A.get("e.force:showToast");
                    toastEvet.setParams({
                        "title": "Please fill the value",
                        "message": "please either fill or delete the blank row of modifier." ,
                        "type" : "ERROR"
                    });
                    toastEvet.fire();
                    
                }else if((component.get("v.isModifierCombination")) == false){
                    console.log('AKANksha');
                    var toatEvent = $A.get("e.force:showToast");
                    toatEvent.setParams({
                        "title": "No data available for the combination of Procedure Code & Modifiers.",
                        "message": "Please contact your system administrator",
                        "type" : "error"
                    });
                    toatEvent.fire(); 
                }
            }
            
        }
        catch(e){
            console.log('error '+e);
        }
    },
    
    handleNo: function(component) {
        component.set("v.showConfirmation", false);
    },
    
    handleYes: function(component,event,helper) {
        component.set("v.showConfirmation", false);
        if(component.get("v.saveAndNew") == true){
            console.log('saveNew');
            component.set("v.saveAndNew", false);
            helper.saveAndNewRecordHelper(component,event,helper);
        }else{
            helper.saveRecordHelper(component,event,helper);
        }
         
        
    },
    isBillableChange : function(component, event, helper){
        if(component.get("v.recordDetail.isBillable") == false){
            console.log('v.recordDetail.typeOfPayment '+ component.get("v.recordDetail.typeOfPayment"));
            component.set("v.recordDetail.typeOfPayment", 'NONE');   
        }else{
            var action = component.get("c.newScreenProcedureDomain");
            action.setParams({ accountId : component.get("v.accountId") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    console.log('payment type val '+JSON.stringify(response.getReturnValue().paymentType));
                    helper.setpaymentTypePicklistVal(component, event, helper,response.getReturnValue().paymentType);
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
            console.log('v.recordDetail.typeOfPayment '+ component.get("v.recordDetail.typeOfPayment"));
        }
    },
    
    saveAndNew: function(component, event, helper) {
        try{
            var checkSave  = true;
            var strDate = component.get("v.recordDetail.procedureStart");
            
            console.log('strDate***',strDate);
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
            
            else if(strDate==null || strDate==''){
                
                var toastEent = $A.get("e.force:showToast");
                toastEent.setParams({
                    "title": "PLEASE SELECT PROCEDURE START DATE",
                    "message": "Please select procedure start date!",
                    "type" : "error"
                });
                toastEent.fire(); 
                checkSave = false ;
            }
            
                else if(component.get("v.recordDetail").isBillable == false){
                    checkSave = true;
                }
            if(component.get("v.recordDetail").procedureSelected && checkSave == true){
                if(component.get("v.recordDetail").typeOfPayment == 'Insurance Payment' &&
                      component.get("v.recordDetail").Status  == 'Canceled' &&
                      component.get("v.recordDetail").isReadyForBilling == true)
                {
                    component.set("v.showConfirmation", true);
                    component.set("v.saveAndNew", true);
                    
                }else{
                    helper.saveAndNewRecordHelper(component,event,helper);
                }
            }
            else if(component.get("v.recordDetail").procedureSelected == false){
                var toastEven = $A.get("e.force:showToast");
                toastEven.setParams({
                    "title": "PLEASE SELECT PROCEDURE",
                    "message": "Please search for procedures!",
                    "type" : "error"
                });
                toastEven.fire();   
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    
    callAddBlankRowInDiagnosisData : function(component, event, helper) {
        helper.addBlankRowInDiagnosisData(component, event, helper);
    },
    
    callRemoveThisRowFromDiagnosisData : function(component, event, helper) {
        helper.removeThisRowFromDiagnosisData(component, event, helper);
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