({
    setDefaultJSON : function(component,icdVal) {
        let defaultJSON = 
            {'codeCategorySelected' : '',
             'procedureSelected' : '',
             'procedureDescription' : '',
             'procedureStart' : '',
             'procedureEnd' : '',
             'placeOfService' : '',
             'unitsDuration' : '',
             'diagnosisPointer' : '',
             'preAuthCode' : '',
             //'claimType' : '',
             'isReadyForBilling' : false,
             'claimNumber' : '',
             'claimStatus' : '',
              'referenceCPTCode' : '',
             'claimGenerated' : false,
             'patientProcedure' : false,
             'isBillable' : true,
             'Notes' : '',
             'isProcessed' : false,
             'typeOfPayment' : '',
             'surgeonValue' : '',
             'parentProcedureValue' : '',
             'anesthesiaCode' : '',
             'consentCode' : '',
             'bedValue' : '',
             'roomValue' : '',
             'facilityValue' : '',
             'Status' : '',
             'cancelationReason' : ''
            };
        component.set("v.recordDetail",defaultJSON);
        let sObj = {'modfier' : '',
                    'modfierId' : '',
                    'description' : '',
                    'notes' : ''};
        
        let arr = component.get("v.modifierData");
        arr.push(sObj);
        component.set("v.modifierData",arr);
    },

    setPlaceOfServiceAndCodeCategory : function(component,event,helper) {
        
        try{
            var action = component.get("c.getPlaceOfServiceAndCodeCategory");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var result = response.getReturnValue();
                    console.log('setPlaceOfService result***2',result);
                    component.set("v.defPlaceOfService",result.defPlaceOfServiceValue);
                    component.set("v.defCodeCategory",result.defCodeCategoryValue);
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

setTypeOfPayment : function(component,event,recId) {
        
        try{
            var action = component.get("c.getTypeOfPament");
            action.setParams({ recordId :  recId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var result = response.getReturnValue();
                    component.set("v.recordDetail.typeOfPayment",result);
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

    arrangeDate : function(component) {
        let result = component.get("v.recordDetail");
        if(result.DateDiagnised){
            result.DateDiagnised = result.DateDiagnised+ ' 00:00:00';           
        }
        if(result.DateOnset){
            result.DateOnset = result.DateOnset+ ' 00:00:00';
        }
    },
    checkModifiersCustomSetting : function(component) {
        try{
            var action = component.get("c.checkForExistingModifiers");
            console.log('codeCategorySelected '+component.get("v.recordDetail.codeCategorySelected"));
           // action.setParams({ procedureCode : component.get("v.recordDetail.codeCategorySelected") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    if(response.getReturnValue()){
                        component.set("v.AllFlag_Modfiers",false);
                      //    helper.emptyModifierData(component, event, helper);
                    }
                    else{
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
    emptyModifierData : function(component) {
     
    component.set("v.modifierData",[{'modfier' : '',
                                     'modfierId' : '',
                    'description' : '',
                    'notes' : ''}]);    
   
    },
    enableButton: function(component, event, helper,recordId) {
        let arr = component.get("v.accountRelatedDiagnosisData");
        let arrIndex = arr.findIndex(obj => obj.Id == recordId);
        arr[arrIndex].disabled=false;
        component.set("v.accountRelatedDiagnosisData",arr);
    },
    setPlaceOfServicePicklistVal:  function(component, event, helper,res) {
        let arr = [];
        let defvalue = component.get("v.defPlaceOfService");
        if(!$A.util.isEmpty(defvalue)){
        
            let sObj = {'label' : defvalue, 'value' : defvalue};
            arr.push(sObj);
        
        }else{
           var noneVal ={ 'value': "", 'label': "NONE" };
         arr.push(noneVal); 
        }
        
        for(let obj in res){
            if(defvalue!=obj){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        }
        console.log('list val 173 upd1'+JSON.stringify(arr));
        component.set("v.POSpicklist",arr); 
        console.log('defPlaceOfService**upd5**',component.get("v.defPlaceOfService"));
        component.set("v.recordDetail.placeOfService",component.get("v.defPlaceOfService")); 
    },
    setActiveCareEpisode : function(component,res) {
        if(res!=undefined){
        if(res.hasOwnProperty('ElixirSuite__Rendering_Provider__r')){
        var selectedRecord = {
            label: res.ElixirSuite__Rendering_Provider__r.Name,
            value: res.ElixirSuite__Rendering_Provider__r.Id
        };
        component.set("v.recordDetail.surgeonValue",res.ElixirSuite__Rendering_Provider__r.Id);
        component.set("v.selectedRecord",selectedRecord); 
    }
        }
       
    },
    setClaimTypePicklistVal:  function(component, event, helper,res, defvalue) {
        let arr = [];
        if(!$A.util.isEmpty(defvalue)){
        for(let obj in defvalue){
            let sObj = {'label' : obj, 'value' : defvalue[obj]};
            arr.push(sObj);
        }
        }else{
           var noneVal ={ 'value': "", 'label': "NONE" };
         arr.push(noneVal); 
        }
        for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        
        console.log('list val '+JSON.stringify(arr));
        component.set("v.claimType",arr); 
    },
    setStatusPicklistVal:  function(component,res,resDefault) {
        let arr = [];
        let defVal;
       if(!$A.util.isEmpty(resDefault)){
      for(let obj in resDefault){
          defVal = obj;
          let sObj = {'value' : obj, 'label' : resDefault[obj]};
          arr.push(sObj);
      }
      }
      for(let obj in res){
          if(defVal!=obj){
          let sObj = {'value' : obj, 'label' : res[obj]};
          arr.push(sObj);
          }
      }
      console.log('list val '+JSON.stringify(arr));
      console.log('line239***upd1');
      component.set("v.statusLst",arr);
    },
    
    setpaymentTypePicklistVal: function(cmp, event, helper,res) {
        let arr = [];
       /* for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }*/
        if(res.ElixirSuite__Private_Payments__c == true && res.ElixirSuite__Insurance_Payments__c ==true){
                
            arr = [];
            
            arr.push({'label' : 'Insurance Payment', 'value' : 'Insurance Payment'});
            arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
            
            cmp.set("v.paymentType",arr); 
            cmp.set("v.recordDetail.typeOfPayment",'Insurance Payment');
            
            
            }
            if(res.ElixirSuite__Private_Payments__c == false && res.ElixirSuite__Insurance_Payments__c ==true){
                arr = [];
                arr.push({'label' : 'Insurance Payment', 'value' : 'Insurance Payment'});
                
                cmp.set("v.paymentType",arr); 
                cmp.set("v.recordDetail.typeOfPayment",'Insurance Payment');
                
            
                
            }
            if(res.ElixirSuite__Private_Payments__c == true && res.ElixirSuite__Insurance_Payments__c ==false){
                arr = [];
                arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
                cmp.set("v.paymentType",arr); 
                cmp.set("v.recordDetail.typeOfPayment",'Private Payment');
                var ct =  cmp.get("v.recordDetail");
                console.log(ct);
                console.log(ct.typeOfPayment);
                ct.typeOfPayment = 'Private Payment';
                console.log(ct);
                //cmp.set("v.recordDetail",ct);
               // cmp.set("v.paymentType",arr); 
            
            }
       // component.set("v.paymentType",arr); 
    },
    CheckModifiers : function(component, event, helper, ModifierData, RefereceCode) {
          try{
        console.log('ModifierData '+JSON.stringify(ModifierData));
        console.log('RefereceCode '+RefereceCode);
        let selectedModifierNames = [];
         ModifierData.forEach(function(element) {
                          console.log(' element '+JSON.stringify(element));
                     if(!$A.util.isUndefinedOrNull(element.modfierId)){
                       selectedModifierNames.push(element.modfierId);  
                     }
                        }); 
         console.log('selectedModifierNames '+selectedModifierNames);
            var action = component.get("c.checkForModifierCombination");
            action.setParams({ lstModifiers :  selectedModifierNames,
                              strRefCPTCode : RefereceCode});
            //component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                  // var resp = response.getReturnValue();
                     console.log('return value'+ response.getReturnValue());
                        component.set("v.isModifierCombination",response.getReturnValue()); 
                    console.log('isModifierCombination value'+component.get("v.isModifierCombination"));
                     // console.log('return value'+ response.getReturnValue());
                  
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
    
    setDiagnosisRecords : function(component, event, helper,res) {
        let arr = [];
        let diagnosisIds = [];
        res.forEach((element) => {  
            element['disabled'] = false;
            element['description'] = element.ElixirSuite__Code_Description1__c;
            arr.push(element);
            diagnosisIds.push(element.Id);
        });  
            component.set("v.accountRelatedDiagnosisData",arr); 
            component.set("v.accountRelatedDiagnosisDataId",diagnosisIds); 
            console.log('diagnosis id '+JSON.stringify(component.get("v.accountRelatedDiagnosisDataId")));
        },
    
    addBlankRowInDiagnosisData: function(component) {
        // Initialize diagnosis data with empty values to get atleast one row by default
        let diagnosisData = component.get("v.diagnosisData");
        diagnosisData.push({
            "Id" : undefined,
            "diagnosis" : undefined,
            "description" : undefined,
            "diagnosisPointer" : undefined,
            "notes" : undefined
        });
        component.set("v.diagnosisData", diagnosisData);
    },

    removeThisRowFromDiagnosisData : function(component, event) {
        let diagnosisData = component.get("v.diagnosisData");

        if (diagnosisData && diagnosisData.length <= 1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Can not delete last row",
                "type" : "error"
            });
            toastEvent.fire();
            return;
        }

        let elementIndexToRemove = event.currentTarget.dataset.value;
        diagnosisData.splice(elementIndexToRemove, 1);
        component.set("v.diagnosisData", diagnosisData);
    },

    setIsDiagnosisCodeAvailableForThisAccount : function(component) {
        try {
            let action = component.get("c.isDiagnosisCodeAvailableForThisAccount");
            
            action.setParams({"accountId": component.get("v.accountId")});
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    component.set("v.isDiagnosisCodeAvailableForThisAccount", response.getReturnValue());
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Failed to query diagnosis for patient",
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                }
            });

            $A.enqueueAction(action);
            
        } catch (error) {
            
        }

    },
    getFieldSet : function(component) { 
        var action = component.get('c.getFieldData');
        action.setParams({
            "ObjectName" : 'ElixirSuite__Procedure__c',
            "fieldSetName" : 'ElixirSuite__Procedure_Code_Field_Set'
        });
        action.setCallback(this, function(response){
            var fieldSetData;
            var fieldPicklistOptionsMap;
            var anesthesiaPicklistOptions;
            var consentCodePicklistOptions;
            var state = response.getState();
            console.log(state+' state in get field data');
            if(state === 'SUCCESS'){
                console.log('in SUCCESS state');
                var resp = response.getReturnValue();
                console.log('resp resp'+JSON.stringify(resp));
                if(!$A.util.isUndefinedOrNull(resp)){
                   // var resp = response.getReturnValue();
                    if(resp[0].fieldSetOptions){
                        fieldSetData = resp[0].fieldSetOptions;
                         component.set("v.fieldSetData",fieldSetData);
                    }
                    if(resp[0].fieldPicklistOptionsMap){
                        fieldPicklistOptionsMap = resp[0].fieldPicklistOptionsMap;
                         component.set("v.fieldSetData",fieldSetData);
                    }
                    if(fieldPicklistOptionsMap){
                        anesthesiaPicklistOptions = fieldPicklistOptionsMap['ElixirSuite__Anesthesia_code__c'];
                    consentCodePicklistOptions = fieldPicklistOptionsMap['ElixirSuite__Consent_code__c'];
                    }
               
                component.set("v.anesthesiaPicklistOptions",anesthesiaPicklistOptions);
                    component.set("v.consentCodePicklistOptions",consentCodePicklistOptions);
            }
        }
        });
        $A.enqueueAction(action);
    },
    saveRecordHelper : function(component,event,helper){
        console.log('-----12------');
        component.set("v.loaded",false);
        let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
        console.log('data to save '+JSON.stringify(payloadToSave));
        console.log('diagnosisData '+JSON.stringify(component.get("v.diagnosisData")));
        console.log('modifierData '+JSON.stringify(component.get("v.modifierData")));
        
        let diagnosisData = component.get("v.diagnosisData");
        let filteredDiagnosisData = [];
        let allIds = [];
        for (const i of diagnosisData) {
            if (i.Id && i.Id.trim() != "" && !allIds.includes(i.Id)) {
                filteredDiagnosisData.push(i);
            }
            allIds.push(i.Id);
        }
        
        var action = component.get("c.saveProcedure");
        action.setParams({'payload' : JSON.stringify(payloadToSave),
                          'accountId' : component.get("v.accountId"),
                          'diagnosisData' : JSON.stringify(filteredDiagnosisData),
                          'modifierData' : JSON.stringify(component.get("v.modifierData"))});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.loaded",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PROCEDURE SAVED!",
                    "message": " ",
                    "type" : "success"
                });
                toastEvent.fire();
                var cmpEvent = component.getEvent("ElixirOEM_ProblemColumnsEvent");
                cmpEvent.fire();
                component.set("v.isConsoleView",false);
                //component.set("v.isView",false);
                var workspaceAPI = component.find("workspace");
                if (component.get("v.backPage") || component.get("v.backPageRCM")) { //NK---15/02/2023
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
    },
            
    saveAndNewRecordHelper : function(component,event,helper){
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
        
        var action = component.get("c.saveProcedure");
        action.setParams({'payload' : JSON.stringify(payloadToSave),
                          'accountId' : component.get("v.accountId"), 
                          'diagnosisData' : JSON.stringify(filteredDiagnosisData),
                          'modifierData' : JSON.stringify(component.get("v.modifierData"))});
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.loaded",true);
                var cmpEvent = component.getEvent("ElixirOEM_ProblemColumnsEvent");
                cmpEvent.fire();
                component.set("v.isView",false);   
                component.set("v.isView",true);     
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
})