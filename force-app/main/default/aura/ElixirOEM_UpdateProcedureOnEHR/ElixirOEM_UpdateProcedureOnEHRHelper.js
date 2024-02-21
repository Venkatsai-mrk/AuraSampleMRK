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
             'claimType' : '',
             'isReadyForBilling' : '',
             'claimNumber' : '',
             'claimStatus' : '',
             'claimGenerated' : false,
             'patientProcedure' : false,
             'isBillable' : false,
             'Notes' : '',
             'isProcessed' : false,
             'typeOfPayment' : '', 
             'Id' : '', 
             'careEpisode':'',
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
    checkModifiers : function(component, event, helper) {
        try{
            var action = component.get("c.checkForExistingModifiers");
            action.setParams({ procedureCode : component.get("v.recordDetail.codeCategorySelected") });
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.loaded",true);
                    if(response.getReturnValue()){
                        component.set("v.AllFlag_Modfiers",true);
                        helper.emptyModifierData(component, event, helper);
                    }
                    else{
                        component.set("v.AllFlag_Modfiers",false);
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
    
    enableCareEpisode : function(component) {
        try{
            var action = component.get("c.getCareEpisodeCustomSetting");
            //  component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    //component.set("v.loaded",true);
                    if(response.getReturnValue()){
                        component.set("v.enableCareEpisode",true);
                    }
                    else{
                        component.set("v.enableCareEpisode",false);
                    }
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
    
    deleteProcedure: function(component, event, helper,deleteRec) {
        try{
            var action = component.get("c.deleteProcedureDiagnosis");
            action.setParams({ deleterecordId : deleteRec});
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    //$A.get('e.force:refreshView').fire();
                    //alert('Diagnosis Deleted Successfully');
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
    
    updateProcedureDiagnosis: function(component, event, helper,updateRec) {
        try{
            var action = component.get("c.updateDiagnosis");
            action.setParams({ updaterecordId : updateRec});
            component.set("v.loaded",false);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    
                    //alert('Diagnosis Updated Successfully');
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
      setStatusPicklistVal:  function(component,res,resDefault) {
          let arr = [];
        /* if(!$A.util.isEmpty(resDefault)){
        for(let obj in resDefault){
            let sObj = {'label' : obj, 'value' : resDefault[obj]};
            arr.push(sObj);
        }
        }*/
        for(let obj in res){
            let sObj = {'value' : obj, 'label' : res[obj]};
            arr.push(sObj);
        }
        console.log('list val '+JSON.stringify(arr));
        component.set("v.statusLst",arr); 
    },
    setPlaceOfServicePicklistVal:  function(component, event, helper,res) {
        let arr = [];
        for(let obj in res){
            let sObj = {'label' : obj, 'value' : res[obj]};
            arr.push(sObj);
        }
        console.log('list val '+JSON.stringify(arr));
        component.set("v.POSpicklist",arr); 
    },
    setProcedureData :  function(component, event, helper,res) {
        console.log('res '+ JSON.stringify(res));
        if(!$A.util.isEmpty(res)){
            let data = res[0];
            component.set("v.procedureName",data.Name); 
            console.log('data.Name '+data.Name);
            if(!$A.util.isEmpty(data.ElixirSuite__Reference_CPT_Code__c)){
                component.set("v.ProcedureCodeLabel",data.ElixirSuite__Reference_CPT_Code__c);
            }
            else{
                component.set("v.ProcedureCodeLabel",data.Name);
            }
            
            console.log('data.ElixirSuite__Reference_CPT_Code__c '+data.ElixirSuite__Reference_CPT_Code__c);
            component.set("v.recordDetail.codeCategorySelected",data.ElixirSuite__Code_Category__c); 
            component.set("v.recordDetail.procedureSelected",data.Name); 
            component.set("v.recordDetail.Id",data.Id); 
            component.set("v.recordDetail.procedureDescription",data.ElixirSuite__Code_Description__c); 
            component.set("v.recordDetail.procedureStart",data.ElixirSuite__From_Date_of_Service__c); 
            component.set("v.recordDetail.procedureEnd",data.ElixirSuite__To_Date_of_Service__c); 
            component.set("v.recordDetail.unitsDuration",data.ElixirSuite__Days_Units__c); 
            component.set("v.recordDetail.placeOfService",data.ElixirSuite__Place_Of_Service_Picklist__c); 
            component.set("v.recordDetail.preAuthCode",data.ElixirSuite__Pre_auth_Code__c); 
            component.set("v.recordDetail.isReadyForBilling",data.ElixirSuite__Ready_for_Billing__c); 
            component.set("v.recordDetail.isBillable",data.ElixirSuite__Is_Billable__c); 
            component.set("v.recordDetail.codeCategorySelected",data.ElixirSuite__Code_Category__c); 
            component.set("v.recordDetail.claimType",data.ElixirSuite__Claim_type__c); 
            component.set("v.recordDetail.anesthesiaCode",data.ElixirSuite__Anesthesia_code__c);
            component.set("v.recordDetail.consentCode",data.ElixirSuite__Consent_code__c); 
            component.set("v.recordDetail.typeOfPayment",data.ElixirSuite__Type_of_Procedure__c);
             component.set("v.recordDetail.Status",data.ElixirSuite__Status__c);
             component.set("v.recordDetail.cancelationReason",data.ElixirSuite__Cancelation_Reason__c);
            if(data.ElixirSuite__Visits__c) {
                component.set("v.recordDetail.careEpisode",data.ElixirSuite__Visits__c);
                var careEpisodePopupRecord = {'label':data.ElixirSuite__Visits__r.Name, 'value':data.ElixirSuite__Visits__c};
                component.set("v.careEpisodeSelectedRecord",careEpisodePopupRecord);
            }
            if(data.ElixirSuite__Parent_Procedure__c) {
                component.set("v.recordDetail.parentProcedureValue",data.ElixirSuite__Parent_Procedure__c);
                var parentProcedureSelectedRecord = {'label':data.ElixirSuite__Parent_Procedure__r.Name, 'value':data.ElixirSuite__Parent_Procedure__c};
                component.set("v.parentProcedureSelectedRecord",parentProcedureSelectedRecord);
            }
            if(data.ElixirSuite__Surgeon__c) {
                component.set("v.recordDetail.surgeonValue",data.ElixirSuite__Surgeon__c);
                var surgeonSelectedRecord = {'label':data.ElixirSuite__Surgeon__r.Name, 'value':data.ElixirSuite__Surgeon__c};
                component.set("v.surgeonSelectedRecord",surgeonSelectedRecord);
            }
            if(data.ElixirSuite__Bed_1__c) {
                component.set("v.recordDetail.bedValue",data.ElixirSuite__Bed_1__c);
                var bedSelectedRecord = {'label':data.ElixirSuite__Bed_1__r.Name, 'value':data.ElixirSuite__Bed_1__c};
                component.set("v.bedSelectedRecord",bedSelectedRecord);
            }
            if(data.ElixirSuite__Room_1__c) {
                component.set("v.recordDetail.roomValue",data.ElixirSuite__Room_1__c);
                var roomSelectedRecord = {'label':data.ElixirSuite__Room_1__r.Name, 'value':data.ElixirSuite__Room_1__c};
                component.set("v.roomSelectedRecord",roomSelectedRecord);
            }
            if(data.ElixirSuite__Facility_1__c) {
                component.set("v.recordDetail.facilityValue",data.ElixirSuite__Facility_1__c);
                var facilitySelectedRecord = {'label':data.ElixirSuite__Facility_1__r.Name, 'value':data.ElixirSuite__Facility_1__c};
                component.set("v.facilitySelectedRecord",facilitySelectedRecord);
            }
            helper.setModfierData(component, event, helper,res[0]);
        }
    },
    setModfierData :  function(component, event, helper,data) {
        //debugger;
        let totalModfiers = data.ElixirSuite__Count_of_total_modifiers_used__c;
        console.log('totalModfiers '+totalModfiers);
        let modData = component.get("v.modifierData");
        console.log('data '+JSON.stringify(data));
        console.log('modData '+JSON.stringify(modData));
        //console.log('Name '+data.ElixirSuite__Modifier1__r.Name);
        if(totalModfiers!=0){
            modData = [];
            for(let i = 1 ; i<= 4 ; i++ ){
                if(['ElixirSuite__Modifier'+i+'__c'] in data){
                    console.log('i---- '+ data['ElixirSuite__Modifier'+i+'__c']);
                    modData.push({'modfier' : data['ElixirSuite__Modifier'+i+'__r'].Name,
                                  'modfierId' : data['ElixirSuite__Modifier'+i+'__c'],
                                  //'description' :   data['ElixirSuite__Description_'+i+'__c'],
                                  'notes' : data['ElixirSuite__Notes_'+i+'__c']});
                    console.log('inside loop '+modData);
                }
                
            }
            component.set("v.modifierData",modData);
        }
    },
    setDiagnosisData :  function(component, event, helper,res) {
        if(!$A.util.isEmpty(res)){
            let idArr = [];
            let diagnosisData =  component.get("v.diagnosisData");
            res.forEach((element) => {  
                diagnosisData.push({'diagnosis'  : element.ElixirSuite__ICD_Codes__r.Name,
                'description' : element.ElixirSuite__Description__c,
                'notes' : element.ElixirSuite__Notes__c,'Id' :  element.ElixirSuite__ICD_Codes__c}); 
            idArr.push(element.ElixirSuite__ICD_Codes__c);
        });
        component.set("v.diagnosisData",diagnosisData);
        component.set("v.procedureRelatedDiagnosisDataId",idArr);
    }
    else {
    helper.addBlankRowInDiagnosisData(component, event, helper);
}
 },
 
 setpaymentTypePicklistVal: function(component, event, helper,res) {
    let arr = [];
    for(let obj in res){
        let sObj = {'label' : obj, 'value' : res[obj]};
        arr.push(sObj);
    }
    component.set("v.paymentType",arr); 
},
    
    setIsProcessed : function(component, event, helper,res) {
        if(res){
            component.set("v.recordDetail.isProcessed",true); 
        }
    },
        setClaimData : function(component, event, helper,res) {
            if(!$A.util.isUndefinedOrNull(res)){
                component.set("v.claimData",res); 
                // component.set("v.AllFlag",true);  
                //  component.set("v.AllFlag_Modfiers",true);  
                component.set("v.recordDetail.claimGenerated",true);
                helper.disableAccountRelatedDiagnosisData(component, event, helper);
            }
            else{
                let sObj = {'Name': 'Claim not yet generated',
                            'ElixirSuite__Claim_Status__c' : 'Claim not yet generated'};
                component.set("v.claimData",sObj); 
            }
        }, 
            disableAccountRelatedDiagnosisData : function(component) {
                let res = component.get("v.accountRelatedDiagnosisData");
                res.forEach((element) => {            
                    element['disabled'] = true;
                });  
                    component.set("v.accountRelatedDiagnosisData",res); 
                    
                },
                    setClaimTypePicklistVal:  function(component, event, helper,res) {
                        let arr = [];
                        for(let obj in res){
                            let sObj = {'label' : obj, 'value' : res[obj]};
                            arr.push(sObj);
                        }
                        //  alert('list setClaimTypePicklistVal '+JSON.stringify(arr)); 
                        component.set("v.claimType",arr); 
                    },
                    setDiagnosisRecords : function(component, event, helper,res) {
                        let idAr = component.get("v.procedureRelatedDiagnosisDataId");
                        let arr = [];
                        let diagnosisIds = [];
                        res.forEach((element) => { 
                            if(idAr.includes(element.Id)){
                            element['disabled'] = true;
                        }
                                    else{ 
                                    element['disabled'] = false;
                                    }                
                                    element['description'] = element.ElixirSuite__Code_Description1__c;
                                    arr.push(element);
                        diagnosisIds.push(element.Id);
                    });  
                    component.set("v.accountRelatedDiagnosisData",arr); 
                    component.set("v.accountRelatedDiagnosisDataId",diagnosisIds); 
                    console.log('diagnosis id '+JSON.stringify(component.get("v.accountRelatedDiagnosisDataId")));
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
                        // if(selectedModifierNames.length>0){
                        var action = component.get("c.checkForModifierCombination");
                        action.setParams({ lstModifiers :  selectedModifierNames,
                                          strRefCPTCode : RefereceCode});
                        //component.set("v.loaded",false);
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {  
                                //  var resp = response.getReturnValue();
                                console.log('return value'+ response.getReturnValue());
                                component.set("v.isModifierCombination",response.getReturnValue()); 
                                console.log('isModifierCombination value'+component.get("v.isModifierCombination"));
                                // console.log('return value'+ response.getReturnValue());
                                
                            }
                            else{
                                
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && online[0].message) {
                                        console.log("Error message: " +
                                                    errors[0].message);
                                    }        }
                            }
                            
                        });
                        
                        $A.enqueueAction(action); 
                        // }else{
                        //    component.set("v.isModifierCombination",true);   
                        // }
                    }
                    catch(e){
                        alert('error '+e);
                    }
                    
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
                                console.log("error in update diagnosis: ", error.message);
                            }
                        },
                            updateRecordHelper : function(component,event,helper){
                                component.set("v.loaded",false);
                                let payloadToSave = {'keysToSave' : component.get("v.recordDetail")};      
                                console.log('data to update '+JSON.stringify(payloadToSave));
                                console.log('modifierData data to update '+JSON.stringify(component.get("v.modifierData")));
                                console.log('deleteDiagnosisData '+JSON.stringify(component.get("v.deleteDiagnosisData")));
                                
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
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "PROCEDURE UPDATED!",
                                            "message": " ",
                                            "type" : "success"
                                        });
                                        toastEvent.fire();
                                        component.set("v.isConsoleView",false);
                                        var cmpEvent = component.getEvent("ElixirOEM_ProblemColumnsEvent");
                                        cmpEvent.fire();
                                        component.set("v.isView",false);
                                        
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
                            }
            })