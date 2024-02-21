({
    fetchProblemColumnsFromCustomSetting1: function(component, event, helper) {
    component.set("v.loaded", false);
    var action = component.get("c.getProblemColumns1");
    action.setCallback(this, function(response) {
        var state = response.getState();
        
        if (state === "SUCCESS") {
            console.log("res " + JSON.stringify(response.getReturnValue()));
            var res = response.getReturnValue();
            console.log('res========= ' + JSON.stringify(res));
            	var resCol  = res.problemColumns;
            	console.log('Custom setting problem columns ==**',JSON.stringify(resCol));
               
                var reqFieldsMap  = res.mapRequiredFields;
                console.log('Parent Component LabelToAPI',reqFieldsMap);
                console.log('Parent Component LabelToAPI ==**',JSON.stringify(reqFieldsMap));
            
            	var reqMapDataTypeToApi  = res.mapDataTypeToApi;
                console.log('Parent Component DataTypeToApi',reqMapDataTypeToApi);
                console.log('Parent Component DataTypeToApi ==**',JSON.stringify(reqMapDataTypeToApi));
            
            if (!$A.util.isUndefinedOrNull(resCol)) {
                let csColArr = resCol.split(';');
                console.log('csColArr ' + JSON.stringify(csColArr));
                
                // Set the split array to the component attribute
                component.set("v.parentProblemColumns", csColArr);
            }
            // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
    		console.log('Parent Component reqFieldsList ==', JSON.stringify(reqFieldsList));
                
                component.set("v.problemColumnsLst", reqFieldsList);
            
            // Convert reqMapDataTypeToApi to a list of objects with label and value properties
                var dataTypeToApiList = [];
                for (var key in reqMapDataTypeToApi) {
                    if (reqMapDataTypeToApi.hasOwnProperty(key)) {
                        dataTypeToApiList.push({ labels: key, type: reqMapDataTypeToApi[key] });
                    }
                }
    		console.log('Parent Component dataTypeToApiList ==', JSON.stringify(dataTypeToApiList));
                
                component.set("v.problemdataTypeToApi", dataTypeToApiList);
            

            component.set("v.loaded", true);
        } else if (state === "ERROR") {
            var errors = response.getError();
            
            if (errors && errors[0] && errors[0].message) {
                console.error("Error:", errors[0].message);
            } else {
                console.error("Unknown error");
            }
        }
    });

    $A.enqueueAction(action);
},
    
    fetchProblemDataOnforms : function(component, event ,helper){
        component.set("v.loaded",false);
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns problem***',csColumns);
        console.log('finColumnsApi problem***',finColumnsApi);
        console.log('finColumnsLabel problem***',finColumnsLabel);
        
        var columnsFromCustomSetting = component.get('v.parentProblemColumns');
        console.log('columnsFromCustomSetting for problems***',columnsFromCustomSetting);
        var labelToApiList = component.get('v.problemColumnsLst');
        //var dataTypeToApiList = component.get('v.problemdataTypeToApi');
        
         var action = component.get("c.fetchAccountProblems");
         action.setParams({
             acctId: component.get("v.patientID"),
             formUniqueId: component.get("v.formUniqueId")
         });
         
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 component.set("v.loaded",true);
                 var masterProblemList = response.getReturnValue();
                 console.log('masterProblemList 1: '+JSON.stringify(masterProblemList))
                 component.set("v.problemListCopy", masterProblemList);
                 
                 var nameSpace = 'ElixirSuite__';                 
                 
                 let toAddCol = [];
                 toAddCol.push( { label: 'Name ', fieldName: 'Name', type: 'text',sortable:true});
                 if(component.get("v.viewMode") == true){
                    toAddCol.push( { label: 'SNOMED CT Code ', fieldName: 'ElixirSuite__SNOMED_CT_Code__c', type: 'text',sortable:true,editable:false});
                }
                else{
                    toAddCol.push( { label: 'SNOMED CT Code ', fieldName: 'ElixirSuite__SNOMED_CT_Code__c', type: 'text',sortable:true,editable:true});
                }
                 
                 toAddCol.push( { label: 'Problem Type', fieldName: 'ElixirSuite__Problem_Type__c', type: 'picklist',sortable:true,editable:false});
               //  toAddCol.push( { label: 'Problem Name ', fieldName: 'Name', type: 'text'});
                 if(csColumns!=null){
                     component.set('v.parentProblemColumns', csColumns);
                     console.log('csColumns!null problem: '+csColumns);
                 }
                 if(csColumns==null){
                     csColumns = component.get('v.parentProblemColumns');
                     console.log('csColumnsisNull problem----'+csColumns);
                 }
                 var labelToApiList = component.get('v.problemColumnsLst');
                 var dataTypeToApiLst = component.get('v.problemdataTypeToApi');
                 
                 if (csColumns && csColumns.length > 0 ) {
                        for (let i = 0; i < csColumns.length; i++) {
                            let fieldName = csColumns[i];
                    		console.log('csColumns[i] problem:', csColumns[i]);
							//console.log('field.value:', field.value);

                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField problem:', reqField);
                            let dataTypeToApi = dataTypeToApiLst.find(field => field.labels == fieldName);
                            // Find the corresponding entry in dataTypeToApiLst
                            //let dataTypeToApi = dataTypeToApiLst.find(field => field.value == fieldName);
                    		//console.log('dataTypeToApi:', dataTypeToApi);
                            if (reqField) {
                                let label = reqField.label;
                                //let dataType = dataTypeToApi.DataType;
                                if(component.get("v.viewMode") == true){
                                    if (dataTypeToApi.type === 'DATE'){
                                toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Set the type as 'date' for date fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                    
                },
                sortable: true,
                editable : false

 // You can customize this based on your requirements
            });
                                
                            }
                            else if(dataTypeToApi.type === 'PICKLIST'){
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'picklist', 
                                sortable: true,
                                editable:false
                            });}
                            else if(dataTypeToApi.type === 'DATETIME'){
                            
                            toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Assuming these fields are datetime fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    hour12: true
                },
                sortable: true,
                editable : false
            });}else{

                                    
                                    
                                    toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: false,
                                    sortable:true// You can customize this based on your requirements
                                });
            }}
                                else{
                                    if (dataTypeToApi.type === 'DATE'){
                                toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Set the type as 'date' for date fields
                editable: false,
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                    
                },
                sortable: true

 // You can customize this based on your requirements
            });
                                
                            }
                            else if(dataTypeToApi.type === 'PICKLIST'){       
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'picklist', 
                                sortable: true,
                                editable:false
                            });}
                            else if(dataTypeToApi.type === 'DATETIME'){
                            
                            toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Assuming these fields are datetime fields
                editable: false,                
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    hour12: true
                },
                sortable: true
                            });}else{
                                toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: true,
                                    sortable:true// You can customize this based on your requirements
                                });}}
                            } else {
                                console.error(`Field "${fieldName}" not found in labelToApiList.`);
                            }
                        }
                    }
                 toAddCol.push({
                                label: 'Action',
                                type: 'button',
                                typeAttributes: {
                                    label: '',
                                    name: 'deleteRow',
                                    title: 'Delete',
                                    iconName: 'utility:delete',
                                    disabled: component.get("v.viewMode")
                                }
                            });
                 
                 
                 console.log('toAddCol for problems: '+toAddCol)
                 
                 component.set('v.problemColumnsOnForms', toAddCol);
                 component.set("v.problemListCopy", masterProblemList);
                 
             }else if (state === "ERROR") {
                 var errors = response.getError();
                 if (errors && errors[0] && errors[0].message) {
                     console.error("Error:", errors[0].message);
                 } else {
                     console.error("Unknown error");
                 }
             }
         });
         
         $A.enqueueAction(action);
         
     },
    
    fetchColumnsFromCustomSetting1: function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getDiagnosisColumns1");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log("res " + JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                console.log('res========= ' + JSON.stringify(res));
                var resCol  = res.diagnosisColumns;
                console.log('Custom setting Diagnosis columns ==**',JSON.stringify(resCol));
                
                var reqFieldsMap  = res.mapRequiredFields;
                console.log('Parent Component LabelToAPI',reqFieldsMap);
                console.log('Parent Component LabelToAPI ==**',JSON.stringify(reqFieldsMap));
                
                var reqMapDataTypeToApi  = res.mapDataTypeToApi;
                console.log('Parent Component DataTypeToApi',reqMapDataTypeToApi);
                console.log('Parent Component DataTypeToApi ==**',JSON.stringify(reqMapDataTypeToApi));
                
                if (!$A.util.isUndefinedOrNull(resCol)) {
                    let csColArr = resCol.split(';');
                    console.log('csColArr ' + JSON.stringify(csColArr));
                    
                    // Set the split array to the component attribute
                    component.set("v.parentColumns", csColArr);
                }
                // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
                console.log('Parent Component reqFieldsList ==', JSON.stringify(reqFieldsList));
                
                component.set("v.diagnosisColumnsLst", reqFieldsList);
                
                // Convert reqMapDataTypeToApi to a list of objects with label and value properties
                var dataTypeToApiList = [];
                for (var key in reqMapDataTypeToApi) {
                    if (reqMapDataTypeToApi.hasOwnProperty(key)) {
                        dataTypeToApiList.push({ labels: key, type: reqMapDataTypeToApi[key] });
                    }
                }
                console.log('Parent Component dataTypeToApiList ==', JSON.stringify(dataTypeToApiList));
                
                component.set("v.diagnosisdataTypeToApi", dataTypeToApiList);
                
                
                component.set("v.loaded", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchDiagnosisDataOnforms : function(component, event ,helper){
        component.set("v.loaded",false);
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns***',csColumns);
        console.log('finColumnsApi***',finColumnsApi);
        console.log('finColumnsLabel***',finColumnsLabel);
        
        var columnsFromCustomSetting = component.get('v.parentColumns');
        console.log('columnsFromCustomSetting***',columnsFromCustomSetting);
        var labelToApiList = component.get('v.diagnosisColumnsLst');
        console.log('labelToApiList***',labelToApiList);
        
        
        
        var action = component.get("c.fetchAccountDiagnosis");
        action.setParams({
            acctId: component.get("v.patientID"),
            formUniqueId: component.get("v.formUniqueId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var diagnosisList = response.getReturnValue();
                console.log('diagnosisList: '+diagnosisList);
                console.log('diagnosisList Data==: '+JSON.stringify(diagnosisList))
                component.set("v.diagnosisListCopy", diagnosisList);
                var nameSpace = 'ElixirSuite__';
                
                let toAddCol = [];
                if(component.get("v.viewMode") == true){
                toAddCol.push( { label: 'Code Label', fieldName: 'Name', type: 'text',sortable:true,editable:false});
                toAddCol.push( { label: 'Code Description', fieldName: 'ElixirSuite__Code_Description1__c', type: 'text',sortable:true,editable:false});
                }
                else{
                toAddCol.push( { label: 'Code Label', fieldName: 'Name', type: 'text',sortable:true,editable:true});
                toAddCol.push( { label: 'Code Description', fieldName: 'ElixirSuite__Code_Description1__c', type: 'text',sortable:true,editable:true});
                }
                toAddCol.push( { label: 'ICD Version', fieldName: 'ElixirSuite__Version__c', type: 'picklist',sortable:true,editable:false});
                
                if(csColumns!=null){
                    console.log('csColumns'+csColumns);
                    component.set('v.parentColumns', csColumns);
                }
                if(csColumns==null){
                    csColumns = component.get('v.parentColumns');
                    console.log('csColumns----'+csColumns);
                }
                var labelToApiList = component.get('v.diagnosisColumnsLst');
                console.log('labelToApiList***',labelToApiList);
                console.log('csColumns length :', csColumns.length);
                console.log('labelToApiList length:', labelToApiList.length);
                
                var dataTypeToApiLst = component.get('v.diagnosisdataTypeToApi');
                console.log('dataTypeToApiLst***',dataTypeToApiLst);
                console.log('dataTypeToApiLst length:', dataTypeToApiLst.length);
                
let labelTransformations = new Map([
                    ['Created By ID', 'Created By']]);
                
                if (csColumns && csColumns.length > 0 ) {
                    for (let i = 0; i < csColumns.length; i++) {
                        let fieldName = csColumns[i];
                        console.log('csColumns[i]:', csColumns[i]);
                        //console.log('field.value:', field.value);
                        
                        // Find the corresponding entry in reqFieldsList
                        let reqField = labelToApiList.find(field => field.value == fieldName);
                        console.log('reqField:', reqField);
                        let reqType = dataTypeToApiLst.find(field => field.labels == fieldName);
                        
                        if (reqField) {
                            let label = reqField.label;
                            if (labelTransformations.has(label)) {
                            label = labelTransformations.get(label);
                        }
                            //let dataType = dataTypeToApi.DataType;
                             if(component.get("v.viewMode") == true){
                                 if (reqType.type === 'DATE'){
                                toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Set the type as 'date' for date fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                    
                },
                sortable: true,
                editable : false

 // You can customize this based on your requirements
            });
                                
                            }
                            else if(reqType.type === 'DATETIME'){
                            
                            toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Assuming these fields are datetime fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    hour12: true
                },
                sortable: true,
                editable : false
            });}
                            else if(reqType.type === 'PICKLIST'){
                                                    
                                        toAddCol.push({
                                        label: label,
                                        fieldName: fieldName,
                                        type: 'picklist', 
                                        sortable: true,
                                        editable : false
                                    });}
            else{
                                 
                                 
                            toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: "text",
                                editable: false,
                                sortable:true// You can customize this based on your requirements
                            });}}
                            else{
                                if (reqType.type === 'DATE'){
                                toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Set the type as 'date' for date fields
                editable: false,
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                    
                },
                sortable: true

 // You can customize this based on your requirements
            });
                                
                            }
                            else if(reqType.type === 'PICKLIST'){
                                                    
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'picklist', 
                                sortable: true,
                                editable : false
                            });}
                            else if(reqType.type === 'DATETIME'){
                            
                            toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Assuming these fields are datetime fields
                editable: false,
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    hour12: true
                },
                sortable: true
                            });}else{
                                 toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: "text",
                                editable: true,
                                sortable:true// You can customize this based on your requirements
                            });
                            }}
                        } else {
                            console.error(`Field "${fieldName}" not found in labelToApiList.`);
                        }
                    }
                }
                
                toAddCol.push({
                    label: 'Related Problems',
                    fieldName: 'linkName',
                    type: 'button',
                    typeAttributes: {
                        label: { fieldName: 'linkLabel' },
                        iconName: { fieldName: 'iconName' },
                        iconPosition: 'right',
                        target: '_blank',
                        name: 'recLink',
                        variant: 'Base',
                        disabled: component.get("v.viewMode")
                    }
                });
                
                toAddCol.push({
                    label: 'Action',
                    type: 'button',
                    typeAttributes: {
                        label: '',
                        name: 'deleteRow',
                        title: 'Delete',
                        iconName: 'utility:delete',
                        disabled: component.get("v.viewMode")
                    }
                });
                
                console.log('response for diagnosisList Data==: ' + JSON.stringify(diagnosisList));
                
                var allData = component.get('v.diagnosisListCopy');
                
                console.log('response for all Data==: ' + JSON.stringify(allData));
                
                allData.forEach(function (diagnosis) {
                    if (diagnosis.ElixirSuite__Diagnosis_Codes__r && 
                        diagnosis.ElixirSuite__Diagnosis_Codes__r.length > 0) {
                        diagnosis.linkName = 'Related Problems';
                        console.log('inside if 1');
                        
                        // Check if ElixirSuite__Problem__r exists before accessing its properties
                        diagnosis.linkLabel = diagnosis.ElixirSuite__Diagnosis_Codes__r
                        .map(function (problem) {
                            return problem.ElixirSuite__Problem__r ? problem.ElixirSuite__Problem__r.Name : 'Related Problems';
                        })
                        .join(', ');
                        
                        diagnosis.iconName = 'utility:edit';
                    } else {
                        diagnosis.linkName = 'Related Problems';
                        diagnosis.linkLabel = 'Related Problems'; // Set 'Related Problems' when there are no problems
                        diagnosis.iconName = undefined;
                    }
                });
                
                console.log('After modification diagnosisList Data==: ' + JSON.stringify(allData));
                
                // Use JSON.stringify to log the entire structure
                console.log('toAddCol for diagnosis: ' + JSON.stringify(toAddCol));
                
                // Remove the redundant variable declaration
                component.set('v.diagnosisColumnsOnForms', toAddCol);
                component.set('v.diagnosisListCopy', allData);
                console.log('diagnosis', allData);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchMedicationColumnsFromCustomSetting: function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getMedicationColumns");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log("res " + JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                console.log('res========= ' + JSON.stringify(res));
                var resCol  = res.medicationColumns;
                console.log('Custom setting Medication columns ==**',JSON.stringify(resCol));
                
                var reqFieldsMap  = res.mapRequiredFields;
                var mapMedicationApiAndType = res.mapFieldsApiAndType;
                
                if(!$A.util.isUndefinedOrNull(mapMedicationApiAndType)){
                    //map of fields Api and fields type
                    component.set("v.medicationApiAndType", mapMedicationApiAndType);
                }
                
               if (!$A.util.isUndefinedOrNull(resCol)) {
                    let csColArr = resCol.split(';');
                    console.log('csColArr ' + JSON.stringify(csColArr));
                    
                    // Set the split array to the component attribute
                    component.set("v.medicationColumns", csColArr);
                }
                // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
                console.log('Parent Component reqFieldsList ==', JSON.stringify(reqFieldsList));
                
                component.set("v.medicationColumnsLst", reqFieldsList);
                
                var reqTypeList = [];
                for (var key in mapMedicationApiAndType) {
                    if (mapMedicationApiAndType.hasOwnProperty(key)) {
                        reqTypeList.push({ labels: key, values: mapMedicationApiAndType[key] });
                    }
                }
                console.log('Parent Component reqTypeList ==**', JSON.stringify(reqTypeList));
                
                component.set("v.medicationTypeColumnsLst", reqTypeList);
                
                component.set("v.loaded", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchMedicationsDataOnforms : function(component, event ,helper){
        component.set("v.loaded",false);
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns***',csColumns);
        console.log('finColumnsApi***',finColumnsApi);
        console.log('finColumnsLabel***',finColumnsLabel);
        
        var columnsFromCustomSetting = component.get('v.medicationColumns');
        console.log('columnsFromCustomSetting***',columnsFromCustomSetting);
        var labelToApiList = component.get('v.medicationColumnsLst');
        console.log('labelToApiList***',labelToApiList);
        var action = component.get("c.fetchAccountMedication");
        action.setParams({
            acctId: component.get("v.patientID"),
             formUniqueId: component.get("v.formUniqueId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var medicationList = response.getReturnValue();
                console.log('medicationList: '+medicationList);
                console.log('medicationList Data==: '+JSON.stringify(medicationList))
                component.set("v.medicationListCopy", medicationList);
                var nameSpace = 'ElixirSuite__';
                var fieldApiAndType = component.get("v.medicationApiAndType");
                console.log('fieldApiAndType***',fieldApiAndType);
                
                let toAddCol = [];
                if(component.get("v.viewMode") == true){
                    toAddCol.push( { label: 'Medication Name', fieldName: 'ElixirSuite__Medication__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Medication__c') ? fieldApiAndType.ElixirSuite__Medication__c : 'text', editable: false, sortable:true});
                    toAddCol.push( { label: 'Strength', fieldName: 'strength', type: fieldApiAndType.hasOwnProperty('strength') ? fieldApiAndType.strength : 'text', editable: false, sortable:true});
                    toAddCol.push( { label: 'Directions', fieldName: 'ElixirSuite__Direction__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Direction__c') ? fieldApiAndType.ElixirSuite__Direction__c : 'text', editable: false, sortable:true});
                }
                else{
                    toAddCol.push( { label: 'Medication Name', fieldName: 'ElixirSuite__Medication__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Medication__c') ? fieldApiAndType.ElixirSuite__Medication__c : 'text', editable: (fieldApiAndType.hasOwnProperty('ElixirSuite__Medication__c') && (fieldApiAndType.ElixirSuite__Medication__c == 'REFERENCE' || fieldApiAndType.ElixirSuite__Medication__c == 'DATETIME' || fieldApiAndType.ElixirSuite__Medication__c == 'DATE')) ? false : true, sortable:true});
                    toAddCol.push( { label: 'Strength', fieldName: 'strength', type: fieldApiAndType.hasOwnProperty('strength') ? fieldApiAndType.strength : 'text', editable: false, sortable:true});
                    toAddCol.push( { label: 'Directions', fieldName: 'ElixirSuite__Direction__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Direction__c') ? fieldApiAndType.ElixirSuite__Direction__c : 'text', editable: (fieldApiAndType.hasOwnProperty('ElixirSuite__Direction__c') && (fieldApiAndType.ElixirSuite__Direction__c == 'REFERENCE' || fieldApiAndType.ElixirSuite__Direction__c == 'DATETIME' || fieldApiAndType.ElixirSuite__Direction__c == 'DATE')) ? false : true, sortable:true});
                }
                
                
                if(csColumns!=null){
                    console.log('csColumns'+csColumns);
                    component.set('v.medicationColumns', csColumns);
                }
                if(csColumns==null){
                    csColumns = component.get('v.medicationColumns');
                    console.log('csColumns----'+csColumns);
                }
                var labelToApiList = component.get('v.medicationColumnsLst');
                console.log('labelToApiList***',labelToApiList);
                console.log('csColumns length :', csColumns.length);
                console.log('labelToApiList length:', labelToApiList.length);
                var typeToApiList = component.get('v.medicationTypeColumnsLst');
                
                let mapOfApiAndLabel =  {
                                             "strength":"Strength"                                             
                                            };  
let labelTransformations = new Map([
                    ['Created By ID', 'Created By']]);
                
                console.log('csColumns----'+JSON.stringify(csColumns));
               
                
                if (csColumns && csColumns.length > 0 ) {
                    const allTextColumns = ["strength"];
                    for (let i = 0; i < csColumns.length; i++) {
                        let fieldName = csColumns[i];
                        let reqField = labelToApiList.find(field => field.value == fieldName);
                        console.log('reqField:', reqField);
                        let reqType = typeToApiList.find(field => field.labels == fieldName);
                        console.log('reqTypeMedication:', reqType);
                        
                        if (reqField) {
                           let label;
                            if(reqField.label ==='Direction'){
                                label='Directions';
                            }else{
                              label=reqField.label;
                            }
                            if (labelTransformations.has(label)) {
                            label = labelTransformations.get(label);
                        }
                            if (reqType.values === 'DATE'){
                                toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Set the type as 'date' for date fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                    
                },
                sortable: true

 // You can customize this based on your requirements
            });
                                
                            }
                            else if(reqType.values === 'DATETIME'){
                            
                            toAddCol.push({
                label: label,
                fieldName: fieldName,
                type: 'date', // Assuming these fields are datetime fields
                typeAttributes: {
                    day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    hour12: true
                },
                sortable: true
            });}
                                else if(reqType.values === 'PICKLIST'){       
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'picklist', 
                                sortable: true,
                                editable:false
                            });}
                            
                            else{
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: fieldApiAndType.hasOwnProperty(fieldName) ? fieldApiAndType[fieldName] : "text",
                                editable: component.get("v.viewMode") == true ? false : (fieldApiAndType.hasOwnProperty(fieldName) && (fieldApiAndType[fieldName] == 'REFERENCE' || fieldApiAndType[fieldName] == 'DATETIME' || fieldApiAndType[fieldName] == 'DATE' || fieldApiAndType[fieldName] == 'ID')) ? false : true,
                                sortable:true // You can customize this based on your requirements
                            });
                                
                            }
            
                        }else if(csColumns){
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: fieldApiAndType.hasOwnProperty(csColumns[recSObj]) ? fieldApiAndType[csColumns[recSObj]] : 'text',sortable:true,editable: component.get("v.viewMode") == true ? false : (fieldApiAndType.hasOwnProperty(csColumns[recSObj]) && (fieldApiAndType[csColumns[recSObj]] == 'REFERENCE' || fieldApiAndType[csColumns[recSObj]] == 'DATETIME' || fieldApiAndType[csColumns[recSObj]] == 'DATE' || fieldApiAndType[csColumns[recSObj]] == 'ID')) ? false : true});  
                                }   
                            }
                        } else {
                            console.error(`Field "${fieldName}" not found in labelToApiList.`);
                        }
                    }
                }
               /*  if(!$A.util.isUndefinedOrNull(csColumns)){
                       const allTextColumns = ["strength"];
                        if(csColumns){
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: 'text',});  
                                }   
                            }
                        }   
                    }*/
                console.log('response for medicationList Data==: ' + JSON.stringify(medicationList));
                
                var allData = component.get('v.medicationListCopy');
                
                console.log('response for all Data==: ' + JSON.stringify(allData));
                allData.forEach(function(column){
                    console.log('ElixirSuite__Medication__r==: ');
                    if (column && column.hasOwnProperty('ElixirSuite__Medication__r')) {
                        column['ElixirSuite__Medication__c'] = column.ElixirSuite__Medication__r.Name;
                        console.log('=== ElixirSuite__Medication__r ===: ');
                        }
                    if (column.ElixirSuite__Frequency__r && column.ElixirSuite__Frequency__r.length > 0) {
                        // Update the Strength field with the value from the first Frequency record
                        column['strength'] = column.ElixirSuite__Frequency__r[0].ElixirSuite__Strength__c;
                    }
                    if (column.CreatedById) {
                        // Update the Strength field with the value from the first Frequency record
                        column['CreatedById'] = column.CreatedBy.Name;
                    }
                   });
                console.log('ElixirSuite__Medication__r ===: ');
                component.set('v.medicationColumnsOnForms', toAddCol);
                component.set('v.medicationListCopy', allData);
               
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
     saveChanges: function(component, event, helper, draftValues) {
        // Call an Apex method to save changes
        var action = component.get("c.saveRecords");
        action.setParams({
            "updates": draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record(s) updated successfully."
                });
                toastEvent.fire(); 
                helper.fetchDiagnosisDataOnforms(component , event , helper);
                component.set("v.loaded",false);// Refresh data after save
            } else {
                // Handle error
                console.error("Error saving records");
            }
        });
        $A.enqueueAction(action);
    },
    savePChanges: function(component, event, helper, draftValues) {
        // Call an Apex method to save changes
        var action = component.get("c.saveRecords");
        action.setParams({
            "updates": draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record(s) updated successfully."
                });
                toastEvent.fire();
                helper.fetchProblemDataOnforms(component , event , helper);
                component.set("v.loaded",false);
            } else {
                // Handle error
                console.error("Error saving records");
            }
        });
        $A.enqueueAction(action);
    },
    saveMedicationChanges: function(component, event, helper, draftValues) {
        // Call an Apex method to save changes
        var action = component.get("c.saveRecords");
        action.setParams({
            "updates": draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record(s) updated successfully."
                });
                toastEvent.fire();
                helper.fetchMedicationsDataOnforms(component , event , helper);
                component.set("v.loaded",false);
            } else {
                // Handle error
                console.error("Error saving records");
            }
        });
        $A.enqueueAction(action);
    },
    helperInit: function (component, event, helper) {
        var action = component.get("c.buildForm");
        console.log(component.get("v.formTemplateId"));
        action.setParams({
            formName: component.get("v.formName"), accountId: component.get("v.recordId"),
            formUniqueId: component.get("v.formUniqueId")
        });
        console.log('CallBack before');
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('CallBack', JSON.stringify(result));
            try {
                if (!$A.util.isUndefinedOrNull(result)) {
                    var colMap = {
                        1: 'slds-size_12-of-12',
                        2: 'slds-size_6-of-12',
                        3: 'slds-size_4-of-12',
                        4: 'slds-size_3-of-12',
                        6: 'slds-size_2-of-12'
                    };
                    var cssRecords = result.cssRecords;
                    var allFields = result.allFields;
                    var objToValues = result.objToValues;
                    var labelstoShow = result.labelstoShow;
                    var autoTextFormValues = result.autoTextFormValues;
                    var uploadedImages = result.versionBasedOnUniqueName;
                    var patientName = result.AccountName;
                    var consentData = result.consentData;
                    var formCssToFxValue = result.formCssToFxValue;
                    var objToData = result.objToData;
                    var formDefaultValues = result.formDefaultValues;
                    console.log('formDefaultValues'+JSON.stringify(formDefaultValues));
                    console.log('Himanshu Fx value = ', formCssToFxValue)
                    component.set("v.consentData", consentData);

                    // for getting macro template data
                    var macroFormValues = result.formTemp;
                    var macroFormDataValues = result.formTempData;
                    component.set("v.FormData", macroFormValues);

                    var problemNoteDataValues = result.problemNoteData;
                    component.set("v.problemNoteData", problemNoteDataValues);

                    //Added by Nithin
                    var flag = result.fetchFlag;
                    for (var i = 0; i < flag.length; i++) {
                        if (flag[i].ElixirSuite__Is_Old__c == true) {
                            component.set("v.isOld", true);
                        }
                    }
                    console.log('isOld', component.get("v.isOld"));

                    // Added by Anmol for LX3-5676
                    var invRecordsValues = result.invRecords;
                    var invValues = [];
                    for (let i = 0; i < invRecordsValues.length; i++) {

                        var singleObj = {};
                        if (invRecordsValues[i].ElixirSuite__Lot_Number__c == null) {
                            singleObj['Lot'] = 'N/A';
                        }
                        else if (invRecordsValues[i].ElixirSuite__Lot_Number__c != null) {
                            singleObj['Lot'] = invRecordsValues[i].ElixirSuite__Lot_Number__c;
                        }
                        singleObj['Name'] = invRecordsValues[i].ElixirSuite__Inventory_Item_Name__c;
                        singleObj['Avail'] = invRecordsValues[i].ElixirSuite__Units_Available__c;
                        singleObj['req'] = invRecordsValues[i].ElixirSuite__Units_Procured__c;
                        singleObj['totalPrice'] = invRecordsValues[i].ElixirSuite__Total_Price__c;
                        singleObj['rid'] = invRecordsValues[i].Id;

                        singleObj['modetype'] = 'Normal';

                        invValues.push(singleObj);

                    }
                    component.set("v.invRecords", invValues);

                    for (let i = 0; i < cssRecords.length; i++) {

                        if (cssRecords[i].ElixirSuite__Select_Form_Component__c == 'Enable Inventory Order') {

                            component.set("v.invData", true);
                        }

                    }

                    // End by Anmol for LX3-5676

                    var diagnosisNoteDataValues = result.diagnosisNoteData;
                    component.set("v.diagnosisNoteData", diagnosisNoteDataValues);

                    var procedureNoteDataValues = result.procedureNoteData;
                    component.set("v.procedureNoteData", procedureNoteDataValues);

                    if (!$A.util.isUndefinedOrNull(result.modularMatrixData[0])) {
                        var modularMatrixData = result.modularMatrixData[0].ElixirSuite__Modular_Matrix_Data_JSON__c;
                        var modularMatrixDataObj = JSON.parse(modularMatrixData);
                        component.set("v.modularMatrixData", modularMatrixDataObj);

                        //console.log("modularMatrixData: ", modularMatrixData);
                        //console.log("modularMatrixDataObj", modularMatrixDataObj);
                    }

                    component.set("v.accName", patientName);
                    component.set("v.uploadedImages", uploadedImages);
                    var obj;
                    if (!$A.util.isUndefinedOrNull(labelstoShow)) {
                        console.log(labelstoShow);
                        labelstoShow = labelstoShow.replaceAll('&quot;_reg_', '"');
                        obj = JSON.parse(labelstoShow);
                        console.log('labelstoShow Parsed' + labelstoShow);
                    }
                    console.log('************* obj parsed' + JSON.stringify(obj));
                    var sec_row_columns = result.sec_row_columns;
                    //var formDefaultValues = result.formDefaultValues;
                    //var objToData = result.objToData;

                    component.set("v.patientModeCheckboxVisible", result.isPatientModeEnabled);
                    var sectionHasUploadedImage = result.sectionHasUploadedImage;

                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if (!$A.util.isUndefinedOrNull(cssRecords)) {
                            for (let record in cssRecords) {
                                if (cssRecords[record].ElixirSuite__Section_Number__c == 1) {
                                    component.set("v.enableTime", cssRecords[record].ElixirSuite__Is_Time_Enabled__c);
                                }
                                var isAutoTextEnabled = cssRecords[record]['ElixirSuite__Enable_Auto_text__c'];
                                if (!$A.util.isUndefinedOrNull(cssRecords[record].ElixirSuite__Indentation__c)) {
                                    let indent = cssRecords[record].ElixirSuite__Indentation__c;
                                    if (indent.toLowerCase() == 'heading') {
                                        cssRecords[record].ElixirSuite__Css__c += ';margin-left:25px';
                                    } else if (indent.toLowerCase() == 'subheading') {
                                        cssRecords[record].ElixirSuite__Css__c += ';margin-left:50px';
                                    }
                                }
                                if (cssRecords[record].ElixirSuite__Add_Problem__c) {
                                    component.set("v.isProblemEnabled", true);
                                }
                                if (cssRecords[record].ElixirSuite__Add_Procedure__c) {
                                    component.set("v.isProcedureEnabled", true);
                                }
                                //meghna macro section
                                if (!$A.util.isEmpty(macroFormDataValues)) {
                                    let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                    // console.log('&&rohit meghna'+JSON.stringify(macroFormDataValues));
                                    for (let z in macroFormDataValues) {
                                        let sNo = macroFormDataValues[z]['ElixirSuite__Section_Number__c'];
                                        if (parseInt(sNo) == sectionNo) {
                                            cssRecords[record]['formMacro'] = macroFormDataValues[z]['ElixirSuite__Form_Data_Description__c'];

                                        }
                                    }

                                }
                                //meghna macro section end

                                //problem note section
                                if (!$A.util.isEmpty(problemNoteDataValues)) {
                                    let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                    for (let z in problemNoteDataValues) {
                                        let sNo = problemNoteDataValues[z]['ElixirSuite__Section_Number__c'];
                                        if (parseInt(sNo) == sectionNo) {
                                            cssRecords[record]['problemNote'] = problemNoteDataValues[z]['ElixirSuite__Form_Data_Description__c'];

                                        }
                                    }

                                }
                                //problem note section end

                                //diagnosis note section
                                if (!$A.util.isEmpty(diagnosisNoteDataValues)) {
                                    let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                    for (let z in diagnosisNoteDataValues) {
                                        let sNo = diagnosisNoteDataValues[z]['ElixirSuite__Section_Number__c'];
                                        if (parseInt(sNo) == sectionNo) {
                                            cssRecords[record]['diagnosisNote'] = diagnosisNoteDataValues[z]['ElixirSuite__Form_Data_Description__c'];

                                        }
                                    }

                                }
                                //diagnosisdiagnosis note section end

                                //procedure note section
                                if (!$A.util.isEmpty(procedureNoteDataValues)) {
                                    let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                    for (let z in procedureNoteDataValues) {
                                        let sNo = procedureNoteDataValues[z]['ElixirSuite__Section_Number__c'];
                                        if (parseInt(sNo) == sectionNo) {
                                            cssRecords[record]['procedureNote'] = procedureNoteDataValues[z]['ElixirSuite__Form_Data_Description__c'];

                                        }
                                    }

                                }
                                //procedure note section end

                                //TEXT GENERATION - START
                               
                                try {
                                    if (isAutoTextEnabled) {
                                        //cssRecords[record]['AutoText'] = cssRecords[record].ElixirSuite__Auto_text__c;
                                        let defaultAutoText = cssRecords[record].ElixirSuite__Auto_text__c;
                                        helper.getBrackets(JSON.parse(JSON.stringify(defaultAutoText)), cssRecords[record], helper, autoTextFormValues, component);
                                        console.log('****' + JSON.stringify(cssRecords[record]));
                                    }
                                }
                                catch (exe) {
                                    // alert(exe);
                                }
                                //MATRIX-HEAD START
                                let sectionInfo = cssRecords[record];
                                let isMatrix = sectionInfo.ElixirSuite__Is_matrix__c;
                                console.log('isMatrix'+isMatrix);
                                let headings = sectionInfo.ElixirSuite__Headings__c;
                                try {
                                    if (!$A.util.isUndefinedOrNull(headings)) {
                                        let separatedHeads = headings.split(';');
                                        sectionInfo['ElixirSuite__Headings__c'] = separatedHeads;
                                        let columnsInSection = cssRecords[record].ElixirSuite__Columns_In_Section__c;
                                        sectionInfo['colsize'] = helper.fetchColSize(parseInt(columnsInSection), colMap);
                                    }
                                } catch (e) { 
                                console.log('e'+e);
                                }
                                //MATRIX-HEAD END
                                //TEXT GENERATION - END
                                let section = cssRecords[record].ElixirSuite__Object_1_css__r;
                                let columnsInSection = cssRecords[record].ElixirSuite__Columns_In_Section__c;
                                let oldRowNumber = -1;
                                console.log('oldRowNumber'+oldRowNumber);
                                let oldRow = 0;
                                console.log('oldRow'+oldRow);
                                if (!$A.util.isUndefinedOrNull(section)) {
                                    for (let rowParent = 0; rowParent < section.length; rowParent++) {
                                        let escapeFToFpass = false;
                                        //Object - Form values - START
                                        if(component.get("v.isPortal")){
                                            console.log('Map_object_console '+section[rowParent]['ElixirSuite__Map_object__c']);
                                            if(!$A.util.isUndefinedOrNull(section[rowParent]['ElixirSuite__Map_object__c'])){
                                                let objName = section[rowParent]['ElixirSuite__Map_object__c'];
                                                let fldName = section[rowParent]['ElixirSuite__Map_field__c'];
                                                let dataType = section[rowParent]['ElixirSuite__Data_Type__c'];
                                                if(!$A.util.isUndefinedOrNull(objToData[objName])){
                                                    console.log('jj'+JSON.stringify(objToData[objName]));
                                                    if(dataType.toLowerCase() == 'multipicklist'){
                                                        if(!$A.util.isUndefinedOrNull(objToData[objName][fldName])){
                                                            section[rowParent]['value'] = objToData[objName][fldName].split(';');
                                                            escapeFToFpass = true;
                                                        }
                                                    }else{
                                                        console.log('map_obj_depth');
                                                        if(!$A.util.isUndefinedOrNull(objToData[objName][fldName])){
                                                            section[rowParent]['value'] = objToData[objName][fldName];
                                                            escapeFToFpass = true;
                                                        }
                                                    }
                                                }
                                            }
                                            //Object - Form values - END
                                            //Default values - START
                                            console.log('12'+JSON.stringify(section[rowParent]));
                                            if(!$A.util.isUndefinedOrNull(section[rowParent]['ElixirSuite__Field_Name__c']) && escapeFToFpass == false){
                                                console.log(section[rowParent]['ElixirSuite__Field_Name__c']);
                                                if(section[rowParent]['ElixirSuite__Field_Name__c'] != 'undefined'){
                                                    let index = formDefaultValues.findIndex( field => field.ElixirSuite__Field_Api_Name__c.toLowerCase() == section[rowParent].ElixirSuite__Field_Name__c.toLowerCase());                                        
                                                    console.log('special'+index);
                                                    if(index!=-1 && section[rowParent]['ElixirSuite__IsCommon__c'] == true){
                                                        console.log('special true');
                                                        let allValues = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                        let dataType = section[rowParent]['ElixirSuite__Data_Type__c'];
                                                        console.log('allValues ',allValues);
                                                        if(dataType == 'MULTIPICKLIST'){
                                                            if(!$A.util.isUndefinedOrNull(allValues)){
                                                                section[rowParent]['value'] = allValues.split(';');
                                                            }
                                                        }else if(dataType == 'BOOLEAN'){
                                                            let val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                            let myBool = (val === 'true');
                                                            section[rowParent]['value'] = myBool;
                                                        }
                                                            else{
                                                                let val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                                section[rowParent]['value'] = val;
                                                            }
                                                    }
                                                }
                                            }
                                            console.log('2');
                                            //Default values - END
                                        }



                                        //FORM LABEL - START
                                        let objectName = section[rowParent].ElixirSuite__Object_Name__c;
                                        let fieldName = section[rowParent].ElixirSuite__Field_Name__c;
                                        console.log('**' + obj);
                                        console.log('***' + objectName);

                                        if (!$A.util.isUndefinedOrNull(obj) && !$A.util.isUndefinedOrNull(objectName) && !$A.util.isUndefinedOrNull(section[rowParent]) && !$A.util.isUndefinedOrNull(obj[objectName])) {
                                            if (!$A.util.isUndefinedOrNull(obj[objectName][fieldName])) {
                                                section[rowParent]['ElixirSuite__Field_Label_Long__c'] = obj[objectName][fieldName];
                                            }
                                        }
                                        //FORM LABEL - END



                                        //CONSENT FORM - START
                                        if (!$A.util.isEmpty(sec_row_columns)) {
                                            let rowNumber = section[rowParent].ElixirSuite__Row__c;
                                            let columnNo = section[rowParent].ElixirSuite__Column__c;
                                            let isConsent = section[rowParent].ElixirSuite__Is_Consent__c;
                                            let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                            if (isConsent && !$A.util.isUndefinedOrNull(sectionNo)) {
                                                if (!$A.util.isUndefinedOrNull(sec_row_columns[sectionNo])) {
                                                    if (!$A.util.isUndefinedOrNull(sec_row_columns[sectionNo][rowNumber])) {
                                                        let cols = sec_row_columns[sectionNo][rowNumber];
                                                        for (let z in cols) {
                                                            if (cols[z]['ElixirSuite__Column_Number__c'] == columnNo) {
                                                                section[rowParent]['ElixirSuite__Default_text__c'] = '#';
                                                                section[rowParent]['bluePrint'] = cols[z]['ElixirSuite__Consent_Default_Text__c'];
                                                                section[rowParent]['defaultText'] = cols[z]['ElixirSuite__Consent_Default_Text__c'];
                                                                section[rowParent]['inputJSON'] = cols[z]['ElixirSuite__Consent_Input_JSON__c'];
                                                                section[rowParent]['consentPdf'] = cols[z]['ElixirSuite__Consent_Pdf__c'];
                                                                section[rowParent]['savedId'] = cols[z].Id;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        //CONSENT FORM - END

                                        var row = rowParent;
                                        let rowAdd = 0;
                                        for (let i = 0; i < parseInt(columnsInSection); i++) {
                                            if ($A.util.isUndefinedOrNull(section[rowParent + i])) {
                                                continue;//Saviour
                                            }
                                            if(component.get("v.isPortal")){
                                                //Object - Form values - START
                                                console.log('3');
                                                console.log('4 '+JSON.stringify(section[rowParent+i]));
                                                if(!$A.util.isUndefinedOrNull(section[rowParent+i])){
                                                    section[rowParent+i]['consentValue'] = ['#']; 
                                                }
                                                if(!$A.util.isUndefinedOrNull(section[rowParent+i]['ElixirSuite__Map_object__c'])){
                                                    let objName = section[rowParent+i]['ElixirSuite__Map_object__c'];
                                                    let fldName = section[rowParent+i]['ElixirSuite__Map_field__c'];
                                                    let dataType = section[rowParent+i]['ElixirSuite__Data_Type__c'];
                                                    console.log('**objToData'+JSON.stringify(objToData));
                                                    console.log('**objName'+objName);
                                                    console.log('**fldName'+fldName);
                                                    console.log('**dataType'+dataType);
                                                    let index = allFields.findIndex( field => field.apiName.toLowerCase() == section[rowParent+i].ElixirSuite__Field_Name__c.toLowerCase() );
                                                    var limitLength = allFields[index].lengthOfField;
                                                    if(!$A.util.isUndefinedOrNull(objToData[objName])){
                                                        if(dataType.toLowerCase() == 'multipicklist'){
                                                            if(!$A.util.isUndefinedOrNull(objToData[objName][fldName])){
                                                                section[rowParent+i]['value'] = objToData[objName][fldName].split(';');
                                                                escapeFToFpass = true;
                                                            }
                                                        }else{
                                                            if(fldName.includes('.')){
                                                                let l = fldName.split('.');
                                                                let nestedProperty = objToData[objName];
                                                                let j = 0;
                                                                
                                                                do {
                                                                    nestedProperty = nestedProperty[l[j]];
                                                                    console.log('nestedPropertyInLoop = ', nestedProperty);
                                                                    j++;
                                                                } while (j < l.length);
                                                                console.log('nestedProperty = ', nestedProperty);
                                                                
                                                                section[rowParent + i]['value'] = nestedProperty.substring(0, limitLength);
                                                            }
                                                            if(!$A.util.isUndefinedOrNull(objToData[objName][fldName])){
                                                                if(dataType.toUpperCase() == 'STRING' || dataType.toUpperCase() == 'TEXTAREA'){
                                                                    console.log('@@inside if',objToData[objName][fldName].substring(0,limitLength));
                                                                    section[rowParent+i]['value'] = objToData[objName][fldName].substring(0,limitLength);
                                                                }else{
                                                                    console.log('@@@383',objToData[objName][fldName]);
                                                                    section[rowParent+i]['value'] = objToData[objName][fldName];
                                                                }
                                                                escapeFToFpass = true;
                                                            }
                                                        }
                                                    }
                                                }
                                                if(!$A.util.isUndefinedOrNull(section[rowParent+i]['ElixirSuite__Map_object__c'])){
                                                    let objName = section[rowParent+i]['ElixirSuite__Map_object__c'];
                                                    console.log('objName',objName);
                                                    let fldName = section[rowParent+i]['ElixirSuite__Map_field__c'];
                                                    let dataType = section[rowParent+i]['ElixirSuite__Data_Type__c'];
                                                    console.log('**'+JSON.stringify(formCssToFxValue));
                                                    let index = allFields.findIndex( field => field.apiName.toLowerCase() == section[rowParent+i].ElixirSuite__Field_Name__c.toLowerCase() );
                                                    let limitLength = allFields[index].lengthOfField;
                                                    console.log('limitLength',limitLength);
                                                    var fetchId = section[rowParent+i]['Id'];
                                                    if(!$A.util.isUndefinedOrNull(formCssToFxValue)){
                                                        if(!$A.util.isUndefinedOrNull(formCssToFxValue[fetchId])){
                                                            var sObjData = formCssToFxValue[fetchId];
                                                            if(dataType.toLowerCase() == 'multipicklist'){
                                                                if(!$A.util.isUndefinedOrNull(sObjData[fldName])){
                                                                    section[rowParent+i]['value'] = sObjData[fldName].split(';');
                                                                    escapeFToFpass = true;
                                                                }
                                                            }else{
                                                                if(!$A.util.isUndefinedOrNull(sObjData[fldName])){
                                                                    if(dataType.toUpperCase() == 'STRING' || dataType.toUpperCase() == 'TEXTAREA'){
                                                                        console.log('@@inside if 409',sObjData[fldName].substring(0,limitLength));
                                                                        section[rowParent+i]['value'] = sObjData[fldName].substring(0,limitLength);
                                                                    }else{
                                                                        console.log('@@412',sObjData[fldName]);
                                                                        section[rowParent+i]['value'] = sObjData[fldName];
                                                                    }
                                                                    escapeFToFpass = true;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                //Object - Form values - END
                                                //Default values - START
                                                if(!$A.util.isUndefinedOrNull(section[rowParent+i]['ElixirSuite__Field_Name__c']) && escapeFToFpass == false){
                                                    if(section[rowParent+i]['ElixirSuite__Field_Name__c'] != 'undefined'){
                                                        let index = formDefaultValues.findIndex( field => field.ElixirSuite__Field_Api_Name__c.toLowerCase() == section[rowParent+i].ElixirSuite__Field_Name__c.toLowerCase());
                                                        console.log('Field '+section[rowParent]['ElixirSuite__Field_Name__c']);
                                                        console.log('index '+index);
                                                        if(index!=-1 && section[rowParent+i]['ElixirSuite__IsCommon__c'] == true){
                                                            let allValues = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                            let dataType = section[rowParent+i]['ElixirSuite__Data_Type__c'];
                                                            if(dataType == 'MULTIPICKLIST'){
                                                                if(!$A.util.isUndefinedOrNull(allValues)){
                                                                    section[rowParent+i]['value'] = allValues.split(';');
                                                                }else{
                                                                    section[rowParent+i]['value'] = [];
                                                                }
                                                            }else if(dataType == 'BOOLEAN'){
                                                                let val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                                let myBool = (val === 'true');
                                                                section[rowParent+i]['value'] = myBool;
                                                            }
                                                                else{
                                                                    let val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                                    section[rowParent+i]['value'] = val;
                                                                }
                                                        }
                                                    }
                                                }
                                                //Default values - END
                                            }
                                            

                                            let rowNumber = section[rowParent + i].ElixirSuite__Row__c;
                                            if ($A.util.isUndefinedOrNull(rowNumber) || rowNumber == 0) {
                                                rowAdd++;
                                                continue;
                                            }
                                            if ($A.util.isUndefinedOrNull(section[row]['Columns'])) {
                                                section[row]['Columns'] = [];
                                            }
                                            let index = -1;
                                            if (section[rowParent + i]['ElixirSuite__Field_Label_Long__c'] != 'nbsp' && !$A.util.isUndefinedOrNull(section[rowParent + i].ElixirSuite__Field_Name__c)) {
                                                index = allFields.findIndex(field => field.apiName.toLowerCase() == section[rowParent + i].ElixirSuite__Field_Name__c.toLowerCase());
                                            }
                                            //CONSENT FORM - START
                                            console.log('Consent');
                                            if (!$A.util.isEmpty(sec_row_columns)) {
                                                let rowNumber = section[rowParent + i].ElixirSuite__Row__c;
                                                let columnNo = section[rowParent + i].ElixirSuite__Column__c;
                                                let isConsent = section[rowParent + i].ElixirSuite__Is_Consent__c;
                                                let sectionNo = cssRecords[record].ElixirSuite__Section_Number__c;
                                                console.log('&&' + JSON.stringify(sec_row_columns));
                                                if (isConsent && !$A.util.isUndefinedOrNull(sectionNo) && !$A.util.isUndefinedOrNull(sec_row_columns[sectionNo])) {
                                                    if (!$A.util.isUndefinedOrNull(sec_row_columns[sectionNo][rowNumber])) {
                                                        let cols = sec_row_columns[sectionNo][rowNumber];
                                                        console.log('@@' + JSON.stringify(cols));
                                                        for (let z in cols) {
                                                            if (cols[z]['ElixirSuite__Column_Number__c'] == columnNo) {
                                                                section[rowParent + i]['ElixirSuite__Default_text__c'] = cols[z]['ElixirSuite__Consent_Text__c'];
                                                                section[rowParent + i]['defaultText'] = cols[z]['ElixirSuite__Consent_Default_Text__c'];
                                                                section[rowParent + i]['bluePrint'] = cols[z]['ElixirSuite__Consent_Default_Text__c'];
                                                                section[rowParent + i]['inputJSON'] = cols[z]['ElixirSuite__Consent_Input_JSON__c'];
                                                                section[rowParent + i]['consentPdf'] = cols[z]['ElixirSuite__Consent_Pdf__c'];
                                                                section[rowParent + i]['savedId'] = cols[z].Id;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            //CONSENT FORM - END

                                            //FORM LABEL - START
                                            console.log('LABELLING');
                                            var formDataType = section[rowParent + i]['ElixirSuite__Form_Data_Type__c'];
                                            let objectName = section[rowParent + i].ElixirSuite__Object_Name__c;
                                            let fieldName = section[rowParent + i].ElixirSuite__Field_Name__c;
                                            if (!$A.util.isUndefinedOrNull(obj) && !$A.util.isUndefinedOrNull(objectName) && !$A.util.isUndefinedOrNull(fieldName) && !$A.util.isUndefinedOrNull(section[rowParent + i]) && !$A.util.isUndefinedOrNull(obj[objectName])) {
                                                console.log('objectName**' + obj[objectName]);
                                                if (!$A.util.isUndefinedOrNull(obj[objectName][fieldName])) {
                                                    console.log('fieldName**' + obj[objectName][fieldName]);
                                                    section[rowParent + i]['ElixirSuite__Field_Label_Long__c'] = obj[objectName][fieldName];
                                                }
                                            }
                                            //FORM LABEL - END
                                            console.log('#' + index);
                                            if (index != -1) {

                                                var dataTypeValue = allFields[index].dataType.toUpperCase();
                                                var lengthOfField = allFields[index].lengthOfField;
                                                let objName = section[rowParent + i].ElixirSuite__Object_Name__c;
                                                let fieldName = section[rowParent + i].ElixirSuite__Field_Name__c;
                                                if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][fieldName])) {
                                                    var sObjValue = objToValues[objName][fieldName];
                                                    if (dataTypeValue == 'MULTIPICKLIST') {
                                                        var values = [];
                                                         console.log('values**' + values);
                                                        values = sObjValue.split(';');
                                                    }
                                                }
                                                if (dataTypeValue == 'PICKLIST' && formDataType != 'Radio') {
                                                    section[rowParent + i]['PicklistValues'] = [];
                                                    if (allFields[index].isDependent && allFields[index].isControlling) {
                                                        section[rowParent + i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;
                                                        section[rowParent + i]['dependentField'] = allFields[index].dependentField;
                                                        section[rowParent + i]['isControlling'] = allFields[index].isControlling;
                                                        section[rowParent + i]['isDependent'] = allFields[index].isDependent;
                                                        let controllingfield = allFields[index].controllingField;
                                                        let controllingfieldIdx = allFields.findIndex(field => field.apiName.toLowerCase() == controllingfield.toLowerCase());
                                                        if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][controllingfield])) {
                                                            let sObjValue = objToValues[objName][controllingfield];
                                                            if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                                let controllingMap = allFields[controllingfieldIdx].controllingValueToDependentValues;
                                                                section[rowParent + i]['PicklistValues'] = controllingMap[sObjValue];
                                                            }
                                                        }
                                                    }
                                                    else if (allFields[index].isDependent) {
                                                        section[rowParent + i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;
                                                        section[rowParent + i]['isDependent'] = allFields[index].isDependent;
                                                        let controllingfield = allFields[index].controllingField;
                                                        if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][controllingfield])) {
                                                            let sObjValue = objToValues[objName][controllingfield];
                                                            if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                                let controllingMap = allFields[index].controllingValueToDependentValues;
                                                                section[rowParent + i]['PicklistValues'] = controllingMap[sObjValue];
                                                            }
                                                        }
                                                        //section[rowParent+i]['controllingField'] = allFields[index].controllingField;                                                 
                                                    }
                                                    else if (allFields[index].isControlling) {
                                                        section[rowParent + i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;
                                                        section[rowParent + i]['dependentField'] = allFields[index].dependentField;
                                                        section[rowParent + i]['isControlling'] = allFields[index].isControlling;
                                                        section[rowParent + i]['PicklistValues'] = allFields[index].picklistValues;
                                                    }
                                                    else {
                                                        section[rowParent + i]['PicklistValues'] = allFields[index].picklistValues;
                                                    }
                                                }
                                                else if (formDataType == 'Radio') {
                                                    section[rowParent + i]['PicklistValues'] = [];
                                                    if (allFields[index].isDependent && allFields[index].isControlling) {
                                                        section[rowParent + i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;
                                                        section[rowParent + i]['dependentField'] = allFields[index].dependentField;
                                                        section[rowParent + i]['isControlling'] = allFields[index].isControlling;
                                                        section[rowParent + i]['isDependent'] = allFields[index].isDependent;
                                                        let controllingfield = allFields[index].controllingField;
                                                        let controllingfieldIdx = allFields.findIndex(field => field.apiName.toLowerCase() == controllingfield.toLowerCase());
                                                        if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][controllingfield])) {
                                                            let sObjValue = objToValues[objName][controllingfield];
                                                            if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                                let controllingMap = allFields[controllingfieldIdx].controllingValueToDependentValues;
                                                                let picklistValues = controllingMap[sObjValue];
                                                                for (let pickValue in picklistValues) {
                                                                    section[rowParent + i]['PicklistValues'].push({ 'value': picklistValues[pickValue], 'label': picklistValues[pickValue] });
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else if (allFields[index].isControlling) {
                                                        section[rowParent + i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;
                                                        section[rowParent + i]['dependentField'] = allFields[index].dependentField;
                                                        section[rowParent + i]['isControlling'] = allFields[index].isControlling;
                                                        let radioPicklistValues = allFields[index].picklistValues;
                                                        for (let pickValue in radioPicklistValues) {
                                                            section[rowParent + i]['PicklistValues'].push({ 'value': radioPicklistValues[pickValue], 'label': radioPicklistValues[pickValue] });
                                                        }
                                                    }
                                                    else if (allFields[index].isDependent) {
                                                        let controllingfield = allFields[index].controllingField;
                                                        if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][controllingfield])) {
                                                            let sObjValue = objToValues[objName][controllingfield];
                                                            if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                                let controllingMap = allFields[index].controllingValueToDependentValues;
                                                                let picklistValues = controllingMap[sObjValue];
                                                                for (let pickValue in picklistValues) {
                                                                    section[rowParent + i]['PicklistValues'].push({ 'value': picklistValues[pickValue], 'label': picklistValues[pickValue] });
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else {
                                                        section[rowParent + i]['PicklistValues'] = [];
                                                        let picklistValues = allFields[index].picklistValues;
                                                        for (let pickValue in picklistValues) {
                                                            section[rowParent + i]['PicklistValues'].push({ 'value': picklistValues[pickValue], 'label': picklistValues[pickValue] });
                                                        }
                                                    }
                                                }
                                                else if (dataTypeValue == 'BOOLEAN') {
                                                    if ($A.util.isUndefinedOrNull(section[rowParent + i]['value'])) {
                                                        section[rowParent + i]['value'] = false;
                                                    }
                                                } else if (dataTypeValue == 'TEXTAREA' || dataTypeValue == 'STRING') {
                                                    if ($A.util.isUndefinedOrNull(section[rowParent + i]['lengthOfField'])) {
                                                        section[rowParent + i]['lengthOfField'] = lengthOfField;
                                                        console.log(section[rowParent + i]['lengthOfField'] + ' mahi');
                                                    }
                                                }
                                                else if (dataTypeValue == 'MULTIPICKLIST') {
                                                    if ($A.util.isUndefinedOrNull(section[rowParent + i]['value'])) {
                                                        section[rowParent + i]['value'] = [];
                                                    }

                                                    section[rowParent + i]['PicklistValues'] = [];
                                                    if (allFields[index].isDependent) {
                                                        let controllingfield = allFields[index].controllingField;
                                                        if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][controllingfield])) {
                                                            let sObjValue = objToValues[objName][controllingfield];
                                                            if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                                let controllingMap = allFields[index].controllingValueToDependentValues;

                                                                var childValueList = controllingMap[sObjValue];
                                                                let multiList = [];
                                                                for (let child in childValueList) {
                                                                    let obj = { 'value': childValueList[child], 'label': childValueList[child] };
                                                                    multiList.push(obj);
                                                                }
                                                                section[rowParent + i]['PicklistValues'] = multiList;
                                                            }
                                                        }
                                                    }
                                                    else if (allFields[index].isControlling) {
                                                        let picklistValues = allFields[index].picklistValues;
                                                        for (let pickValue in picklistValues) {
                                                            section[rowParent + i]['PicklistValues'].push({ 'value': picklistValues[pickValue], 'label': picklistValues[pickValue] });
                                                        }
                                                        section[rowParent + i]['isControlling'] = allFields[index].isControlling;
                                                        section[rowParent + i]['dependentField'] = allFields[index].dependentField;
                                                    }
                                                    else {
                                                        let picklistValues = allFields[index].picklistValues;
                                                        for (let pickValue in picklistValues) {
                                                            section[rowParent + i]['PicklistValues'].push({ 'value': picklistValues[pickValue], 'label': picklistValues[pickValue] });
                                                        }
                                                    }
                                                }

                                                if (!$A.util.isUndefinedOrNull(objToValues[objName]) && !$A.util.isUndefinedOrNull(objToValues[objName][fieldName])) {
                                                    let sObjValue = objToValues[objName][fieldName];
                                                    console.log('@@@@objToValues',objToValues);
                                                    console.log('@@@@objName',objName);
                                                    console.log('@@@@fieldName',fieldName);
                                                    if (dataTypeValue == 'MULTIPICKLIST') {
                                                        let values = [];
                                                        values = sObjValue.split(';');
                                                        
                                                        section[rowParent + i]['value'] = values;
                                                    }
                                                    else if (dataTypeValue == 'TIME') {
                                                        if (!$A.util.isUndefinedOrNull(sObjValue)) {
                                                            // time value comes as milliseconds convert it to hours
                                                            let hourString = `${sObjValue / 3600000}`;

                                                            if (hourString.includes('.')) {
                                                                // hours is float, so whole number part will be hours and
                                                                // the decimal part when taken as percent of an hour will give minutes
                                                                // so 2.75 is 2 hours and (75/100 * 60) = 45 mins
                                                                let hourSplit = hourString.split('.');

                                                                let wholeHours = hourSplit[0];
                                                                // hours need to be 2 chars long, for 1 char hours pad them with zero
                                                                wholeHours = wholeHours.padStart(2, '0');

                                                                let minutes = Number.parseFloat('.' + hourSplit[1]) * 60;
                                                                // lets take Int part of this minutes only, mostly it will be Integer(as time picker only allows picking specific times) only but anyway
                                                                minutes = Math.trunc(minutes);

                                                                // convert minutes to string and
                                                                // minutes need to be 2 chars long, for 1 char minutes pad them with zero
                                                                minutes = `${minutes}`;
                                                                minutes = minutes.padStart(2, '0');

                                                                section[rowParent + i]['value'] = `${wholeHours}:${minutes}:00.000Z`;
                                                            }
                                                            else {
                                                                // we have whole hours only in hourString
                                                                // hours need to be 2 chars long, for 1 char hours pad them with zero
                                                                hourString = hourString.padStart(2, '0');

                                                                section[rowParent + i]['value'] = `${hourString}:00:00.000Z`;
                                                            }
                                                        }
                                                    }

                                                    else {
                                                        console.log('@@@@sObjValue',sObjValue);
                                                        section[rowParent + i]['value'] = sObjValue;
                                                    }
                                                }
                                            }
                                            var currentRow = -1;
                                            var sectionToPush = section[parseInt(row) + parseInt(i)];
                                            if (!$A.util.isUndefinedOrNull(sectionToPush)
                                                && (currentRow == -1 || currentRow == sectionToPush.ElixirSuite__Row__c)) {
                                                currentRow = sectionToPush.ElixirSuite__Row__c;
                                                //Handling NO Label - START
                                                if (sectionToPush.ElixirSuite__No_Label__c) {
                                                    sectionToPush.ElixirSuite__Field_Label_Long__c = '';
                                                }
                                                //Handling NO Label - END
                                                sectionToPush['colsize'] = helper.fetchColSize(parseInt(columnsInSection), colMap);
                                                section[row]['Columns'].push(JSON.parse(JSON.stringify(sectionToPush)));
                                                console.log('section ' + JSON.stringify(section[row]));
                                                rowAdd++;
                                            }
                                        }
                                        rowParent = parseInt(rowParent) + parseInt(rowAdd) - 1;
                                    }
                                    /*//AUTO TEXT GENERATION - FINAL STRING MAKING - START
                                    try{
                                        console.log('apiNameToValues '+JSON.stringify(apiNameToValues));
                                        if(isAutoTextEnabled && !$A.util.isUndefinedOrNull(cssRecords[record]['bluePrint'])){
                                            let bluePrint = JSON.parse(JSON.stringify(cssRecords[record]['bluePrint']));
                                            var finalSetOfValues = [];
                                            for(let idx in bluePrint){
                                                let allFieldsInText = bluePrint[idx];
                                                let value;
                                                if(allFieldsInText.includes('*')){
                                                    value = helper.createListForAutoText('*',allFieldsInText,apiNameToValues);
                                                }else if(allFieldsInText.includes(',')){
                                                    value = helper.createListForAutoText(',',allFieldsInText,apiNameToValues);
                                                }else if(allFieldsInText.includes('+')){
                                                    value = helper.createListForAutoText('+',allFieldsInText,apiNameToValues);
                                                }else{
                                                    value = helper.createListForAutoText(';',allFieldsInText,apiNameToValues);
                                                }
                                                finalSetOfValues.push(value);
                                            }         
                                            cssRecords[record].AutoText = helper.setBrackets(finalSetOfValues, cssRecords[record], helper);
                                        }
                                    }catch(exe){
                                    }
                                    //AUTO TEXT GENERATION - FINAL STRING MAKING - END*/
                                }

                                // add hasImage to each upload & annotate section
                                if (cssRecords[record].ElixirSuite__Select_Form_Component__c == 'Enable Upload And Annotate') {
                                    cssRecords[record].hasImage = sectionHasUploadedImage[cssRecords[record].Id];
                                }

                                // count number of annotate components start
                                try {
                                    if (cssRecords[record].ElixirSuite__Select_Form_Component__c == "Enable Draw And Annotate") {
                                        component.set("v.numberOfImagesToLoad", parseInt(component.get("v.numberOfImagesToLoad")) + 1);
                                        console.log("numberOfImagesToLoad: ", component.get("v.numberOfImagesToLoad"));
                                    }
                                } catch (error) {
                                    console.error("error while counting annotate components: ", error.message);
                                    component.set("v.numberOfImagesToLoad", 0);
                                }
                                // count number of annotate components end
                            }
                            // If there are no annotate components mark form as loaded,
                            // else v.loaded will be marked true by handleDrawAnnotateMC in JS controller
                            if (parseInt(component.get("v.numberOfImagesToLoad")) === 0) {
                                component.set("v.loaded", true);
                            }
                            component.set("v.objNameToValue", objToValues);
                            component.set("v.cssRecords", cssRecords);
                            helper.setTimings(component, event, helper, result.procedureOfForm); // SET TIMINGS ON FORMS
                            console.log('css records final json ' + JSON.stringify(cssRecords));

                            console.log('objToValues final json ' + JSON.stringify(objToValues));
                        }
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");

                    if (response.getState() === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                toastEvent.setParams({
                                    title: 'Error',
                                    type: 'error',
                                    message: errors[0].message,
                                });
                            }
                        }
                        else {
                            toastEvent.setParams({
                                title: 'Error',
                                type: 'error',
                                message: 'Unknown error.',
                            });
                        }
                    }
                    toastEvent.fire();
                    component.set("v.loaded", true);
                    component.set("v.isOpen", false);
                }
            }
            catch (e) {
                alert(e)
            }
        });
        $A.enqueueAction(action);
    },
    setTimings: function (component, event, helper, procedureOfForm) {
        if (!$A.util.isUndefinedOrNull(procedureOfForm)) {
            let timeObj = component.get("v.timeWrapper");
            timeObj.startTime = procedureOfForm.ElixirSuite__Start_Time__c;
            timeObj.endTime = procedureOfForm.ElixirSuite__End_Time__c;
            component.set("v.timeWrapper", timeObj);
        }
    },
    //added by Anmol for LX3-5770
    fetchNspc: function (component) {
        var action = component.get("c.fetchNameSpace");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.orgWideValidNamespace", response.getReturnValue());
            }
            else {
                console.log("failure for namespace");
            }
        });
    },
    //end by Anmol for LX3-5770

    //added by Anmol for LX3-6263
    fetchCustomSett: function (component) {
        var action = component.get("c.fetchCustomSettingsPrescription");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("update success for fetchCustomSettingsPrescription", result);
                if (result == 'Dummy Prescription') {

                    component.set("v.prescButton", true);

                }

            }
            else {
                console.log("failure for namespace");
            }
        });
        $A.enqueueAction(action);
    },
    //end by Anmol for LX3-6263

    globalFlagToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    //TEXT Generator
    getBrackets: function (defaultText, section, helper, autoTextFormValues, component) {
        try {
            var bluePrints = helper.bracketsBuilder(defaultText, section, autoTextFormValues, component);
            section['bluePrint'] = bluePrints;
        } catch (e) {//alert(e);
        }
    },
    bracketsBuilder: function (defaultText, section, autoTextFormValues, component) {
        var sectionNo = section.ElixirSuite__Section_Number__c;
        let index = autoTextFormValues.findIndex(field => field.ElixirSuite__Section_Number__c == sectionNo);
        if (index == -1) {
            return;
        }
        //For Blue Prints
        /*while(defaultText.lastIndexOf("[") != -1){
            var extractedTextWithinBrackets = defaultText.substring(
                defaultText.lastIndexOf("[") + 1,
                defaultText.lastIndexOf("]")
            );
            let firstPart = defaultText.substr(0, defaultText.lastIndexOf("["));
            let lastPart = defaultText.substr(defaultText.lastIndexOf("]")+1);
            let textAfterExtraction = firstPart + lastPart;
            defaultText = textAfterExtraction;
            bluePrints.push(extractedTextWithinBrackets.replace( /(<([^>]+)>)/ig, ''));  
            
        }*/

        // For Edit/View Blue Print Values   
        var bluePrinting = autoTextFormValues[index].ElixirSuite__Blue_Print__c;

        if ($A.util.isUndefinedOrNull(bluePrinting)) {
            let textFromDB = autoTextFormValues[index].ElixirSuite__Auto_text__c;
            section['AutoText'] = textFromDB;
            return;
        }

        bluePrinting = bluePrinting.replaceAll('&quot;', '');
        bluePrinting = bluePrinting.replace('[', '');
        bluePrinting = bluePrinting.replace(']', '');
        var bluePrints = bluePrinting.split(',');
        var textFromDB = autoTextFormValues[index].ElixirSuite__Auto_text__c;
        if (component.get("v.viewMode")) {
            textFromDB = textFromDB.replaceAll('{', '');
            textFromDB = textFromDB.replaceAll('}', '');
        }
        section['AutoText'] = textFromDB;// Setting Auto Text From DB
        let count = 0;
        while (textFromDB.lastIndexOf("{") != -1) {
            let firstPart = textFromDB.substr(0, textFromDB.lastIndexOf("{"));
            let lastPart = textFromDB.substr(textFromDB.lastIndexOf("}") + 1);
            textFromDB = firstPart + '[' + bluePrints[count] + ']' + lastPart;
            count++;
        }
        if (bluePrints.length > 0) {
            section['DefaultAutoText'] = textFromDB;
            return bluePrints;
        }
    },
    createListForAutoText: function (separator, allFieldsInText, allValues) {
        console.log('createListForAutoText START');
        let apiNames = allFieldsInText.split(separator);

        var finalValues = [];
        var count = 0;
        for (let idx in apiNames) {
            console.log(apiNames[idx]);
            console.log(JSON.stringify(allValues));
            if (allValues.hasOwnProperty(apiNames[idx])) {
                var dataToInsert = allValues[apiNames[idx]];
                if (separator == '+') {
                    count += parseInt((dataToInsert == undefined || dataToInsert == "") ? 0 : dataToInsert);
                } else if (separator == '*') {
                    count *= parseInt((dataToInsert == undefined || dataToInsert == "") ? 0 : dataToInsert);
                } else if (separator == '@') {
                    finalValues.push(dataToInsert);
                } else {
                    dataToInsert = this.addSpacesWithinMultiSelect(dataToInsert);
                    finalValues.push(dataToInsert);
                }
            }
        }
        console.log('finalValues ' + finalValues);
        let finalString = '{';
        if (finalValues.length > 0) {
            finalString += finalValues.join(',\r');
        } else if (separator == '+' || separator == '*') {
            finalString += count;
        }
        finalString += '}';
        console.log('createListForAutoText END');
        return finalString;
    },
    addSpacesWithinMultiSelect: function (dataToInsert) {
        try {
            if (dataToInsert.length > 0) {
                var eachRec = [];
                dataToInsert.forEach(function (record) {
                    if (eachRec.length != 0) {
                        record = '\r' + record;
                    }
                    eachRec.push(record);
                });
            }
            return eachRec.join(',');
        } catch (e) {
            return dataToInsert;
        }
    },
    fetchColSize: function (columns, colMap) {
        if (!$A.util.isUndefinedOrNull(colMap[columns])) {
            return colMap[columns];
        } else {
            return 'slds-size_2-of-12';
        }
    },
    buildParentWrapperForExternalComponents: function (component) {
        var wrapperExternalObjet = {
            'allergyData': [],
            'allergyDataFormSpecific': [],
            'glucoseData': [],
            'glucoseDataFormSpecific': [],
            'vitalSignsData': [],
            'vitalSignsDataFormSpecific': []
        };
        component.set("v.ExternalcmpData", wrapperExternalObjet);
        var wrapperExternalAuraIf = {
            'allergyData': false,
            'glucoseData': false,
            'vitalSignsData': false
        };
        component.set("v.ExternalcmpParentAuraIf", wrapperExternalAuraIf);
        component.set("v.procedureWrapper", { 'insertedProcedure': [], 'updatedProcedure': [], 'toDelProcRecords': [] });
    },
    buildNotesSpecificData : function (component , event , helper) {
        var wrapperNotesSpecificData = {'allergyData' : [],
                                    'medicationData' : [],
                                    'vitalData' : [],
                                    'diagnosisData' : [],
                                    'problemData': []
                                       };
        
        
        component.set("v.notesSpecificData",wrapperNotesSpecificData);
    },
    fetchAllergyColumnsFromCustomSetting1: function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getAllergyColumns1");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log("res " + JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                console.log('res========= ' + JSON.stringify(res));
                var resCol  = res.allergyColumns;
                console.log('Custom setting  Allergy columns ==**',JSON.stringify(resCol));
                
                var reqFieldsMap  = res.mapRequiredFields;
                console.log('Parent Component LabelToAPI',reqFieldsMap);
                console.log('Parent Component LabelToAPI ==**',JSON.stringify(reqFieldsMap));
                
                var reqTypeMap = res.mapDataTypeToApi;
                console.log('parent comp type of allergy==*',reqTypeMap);
                
                if (!$A.util.isUndefinedOrNull(resCol)) {
                    let csColArr = resCol.split(';');
                    console.log('csColArr ' + JSON.stringify(csColArr));
                    
                    // Set the split array to the component attribute
                    component.set("v.parentallergyColumns", csColArr);
                }
                // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
                console.log('Parent Component reqFieldsList ==', JSON.stringify(reqFieldsList));
                
                component.set("v.allergyColumnsLst", reqFieldsList);
                
                var reqTypeList = [];
                for (var key in reqTypeMap) {
                    if (reqTypeMap.hasOwnProperty(key)) {
                        reqTypeList.push({ label: key, value: reqTypeMap[key] });
                    }
                }
                console.log('Parent Component reqAllergyTypeList ==**=', JSON.stringify(reqTypeList));
                
                component.set("v.allergydataTypeToApi", reqTypeList);
                console.log('Datatype of allergy====',JSON.stringify(component.get("v.allergydataTypeToApi")));
                
                
                
                component.set("v.loaded", true);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    fetchExternalCmpData: function (component, event, helper) {
        
        component.set("v.loaded",false);
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns***',csColumns);
        console.log('finColumnsApi***',finColumnsApi);
        console.log('finColumnsLabel***',finColumnsLabel);
        
        var columnsFromCustomSetting = component.get('v.parentallergyColumns');
        console.log('columnsFromCustomSetting***',columnsFromCustomSetting);
        
        var action = component.get("c.externalCmpDataForEditScreen");
        action.setParams({
            acctId: component.get("v.recordId"),
            formUniqueID: component.get("v.formUniqueId")
        });
         action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                    component.set("v.loaded",true);
                    var res = response.getReturnValue();
                    console.log('res data============'+JSON.stringify(res));
                	console.log('allergyDat============'+JSON.stringify( res.allergyData));
                    var nameSpace = 'ElixirSuite__';                 
                    let toAddCol = [];
                	toAddCol.push( { label: 'Allergy Name', fieldName: 'ElixirSuite__Allergy_Name1__c', type: 'text',editable: false,sortable:true,});
                    toAddCol.push( { label: 'Substance', fieldName: 'ElixirSuite__Substance1__c', type: 'text',editable: false,sortable:true,});
                if(component.get("v.viewMode") == true){
                    toAddCol.push( { label: 'Substance Code', fieldName: 'ElixirSuite__Substance_Code__c', type: 'text',editable: false,sortable:true});
                }
                else{
                    toAddCol.push( { label: 'Substance Code', fieldName: 'ElixirSuite__Substance_Code__c', type: 'text',editable: false,sortable:true});                    
                }
            
                
                if(csColumns!=null){
                     component.set('v.parentallergyColumns', csColumns);
                     console.log('csColumns!null Allergy: '+csColumns);
                 }
                 if(csColumns==null){
                     csColumns = component.get('v.parentallergyColumns');
                     console.log('csColumnsisNull Allergy----'+csColumns);
                 }
             
                 /*let mapOfApiAndLabel =  {
                                             "AllergyName":"Allergy Name",
                                             "Substance" :"Substance",
                                             "Reaction" :"Reaction",
                                              "Severity":"Severity",
                                             
                                            };   */
                
                    
               /* console.log('csColumns----'+JSON.stringify(csColumns));
                if(!$A.util.isUndefinedOrNull(csColumns)){
                       console.log('Jothi----');
                       const allTextColumns = ["Substance","Reaction","AllergyName","Severity"];
                        if(csColumns){
                            console.log('Jothi1----');
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                     console.log('Jothi11----');
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: 'text'});  
                                }   
                            }
                        }   
                    }*/
                
                console.log('toAddCol----'+JSON.stringify(toAddCol));
                var labelToApiList = component.get('v.allergyColumnsLst');
                console.log('labelToApiList Data***',JSON.stringify(labelToApiList));
                var apiToTypeList = component.get('v.allergydataTypeToApi');
                console.log('apiToTypeList Data***',JSON.stringify(apiToTypeList));
                 
                 if (csColumns && csColumns.length > 0 ) {
                        for (let i = 0; i < csColumns.length; i++) {
                            let fieldName = csColumns[i];
                    		
                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField problem:', reqField);
                            let reqType = apiToTypeList.find(field => field.label == fieldName);
                            console.log('reqType Allergy in the allergy');
                            
                            if (reqField) {
                                let label = reqField.label;
                                if(component.get("v.viewMode") == true){
                                    if (reqType.value == 'DATE') {
                                        toAddCol.push({
                                            label: label,
                                            fieldName: fieldName,
                                            type: reqType.value,
                                            sortable: true,
                                            editable: false,
                                            typeAttributes: {
                                                day: 'numeric',  
                                                month: 'short',  
                                                year: 'numeric'
                                            }
                                        });
                                        
                                        
                                    } 
                                    else if (reqType.value == 'REFERENCE') {
                                        toAddCol.push({
                                            label: label,
                                            fieldName: fieldName,
                                            type: reqType.value,
                                            sortable: true,
                                            editable: false
                                        });
                                        
                                        
                                    }
                                        else if (reqType.value == 'DATETIME') {
                                            toAddCol.push({
                                                label: label,
                                                fieldName: fieldName,
                                                type: 'date',
                                                sortable: true,
                                                editable: false,
                                                typeAttributes: {
                                                    day: 'numeric',  
                                                    month: 'short',  
                                                    year: 'numeric',
                                                    hour: 'numeric',
                                                    minute: 'numeric',
                                                    second: 'numeric',
                                                    hour12: true
                                                }
                                            });
                                            
                                        } 
                                    
                                            else if(reqType.value == 'PICKLIST'){
                                                toAddCol.push({
                                                    label: label,
                                                    fieldName: fieldName,
                                                    type: 'PICKLIST',
                                                    sortable:true,
                                                    editable: false
                                                });
                                            }
                                                else if(reqType.value == 'Address'){
                                                    console.log('inside picklist1')
                                                    toAddCol.push({
                                                        label: label,
                                                        fieldName: fieldName,
                                                        type: 'Address',
                                                        sortable:true,
                                                        editable: false
                                                    });
                                                }
                                                    else{
                                                        toAddCol.push({
                                                            label: label,
                                                            fieldName: fieldName,
                                                            type: reqType.value,
                                                            sortable:true,
                                                            editable: false
                                                        });
                                                        
                                                    }
                                }
                                else{
                                    
                                    if (reqType.value == 'DATE') {
                                        toAddCol.push({
                                            label: label,
                                            fieldName: fieldName,
                                            type: reqType.value,
                                            sortable: true,
                                            editable: false,
                                            typeAttributes: {
                                                day: 'numeric',  
                                                month: 'short',  
                                                year: 'numeric'
                                            }
                                        });
                                        
                                    } 
                                    else if (reqType.value == 'REFERENCE') {
                                        toAddCol.push({
                                            label: label,
                                            fieldName: fieldName,
                                            type: reqType.value,
                                            sortable: true,
                                            editable: false
                                        });
                                        
                                    }
                                        else if (reqType.value == 'DATETIME') {
                                            toAddCol.push({
                                                label: label,
                                                fieldName: fieldName,
                                                type: 'date',
                                                sortable: true,
                                                editable: false,
                                                typeAttributes: {
                                                    day: 'numeric',  
                                                    month: 'short',  
                                                    year: 'numeric',
                                                    hour: 'numeric',
                                                    minute: 'numeric',
                                                    second: 'numeric',
                                                    hour12: true
                                                }
                                            });
                                            
                                        } 
                                    
                                    
                                            else if(reqType.value == 'PICKLIST'){
                                                console.log('inside picklist1')
                                                toAddCol.push({
                                                    label: label,
                                                    fieldName: fieldName,
                                                    type: 'PICKLIST',
                                                    sortable:true,
                                                    editable: false
                                                });
                                            }
                                                else if(reqType.value == 'Address'){
                                                    console.log('inside picklist1')
                                                    toAddCol.push({
                                                        label: label,
                                                        fieldName: fieldName,
                                                        type: 'Address',
                                                        sortable:true,
                                                        editable: false
                                                    });
                                                }
                                                    else{
                                                        toAddCol.push({
                                                            label: label,
                                                            fieldName: fieldName,
                                                            type: reqType.value,
                                                            sortable:true,
                                                            editable: true
                                                        });
                                                    }
                                    
                                    
                                    
                                } 
                            }
                            else {
                                console.error(`Field "${fieldName}" not found in labelToApiList.`);
                            }
                        }
                    }
              
                  res.allergyData.forEach(function(column){
                    
                    if (column && column.hasOwnProperty('ElixirSuite__Allergy_Name1__r')) {
                           
                            column['ElixirSuite__Allergy_Name1__c'] = column.ElixirSuite__Allergy_Name1__r.Name;
                             
                        }
                        if (column && column.hasOwnProperty('ElixirSuite__Substance1__r')) {
                            
                            column['ElixirSuite__Substance1__c'] = column.ElixirSuite__Substance1__r.Name;
                            
                        }
                        if (column && column.hasOwnProperty('ElixirSuite__Reaction1__r')) {
                          
                            column['ElixirSuite__Reaction1__c'] = column.ElixirSuite__Reaction1__r.Name;
                             
                        }
                         if (column && column.hasOwnProperty('ElixirSuite__Severity1__r')) {
                            
                            column['ElixirSuite__Severity1__c'] = column.ElixirSuite__Severity1__r.Name;
                             
                        }
                    
                });
                 
                 console.log('toAddCol for Allergy: '+JSON.stringify(toAddCol))
                 
                 component.set('v.alllergyColumns', toAddCol);
               
                 
           
                    //vitals
                    let csVitalColumns  = res.vitalsColumn;
                    res.vital_Signs_Data.forEach(function(vitalColumns){                       
                        
                        vitalColumns['BloodPressureSystolic'] = vitalColumns.ElixirSuite__Blood_Pressure_Systolic__c;
                        vitalColumns['BloodPressureDiasystolic']= vitalColumns.ElixirSuite__Blood_Pressure_Diasystolic__c;
                        vitalColumns['Temperature']= vitalColumns.ElixirSuite__Temperature__c;  
                        vitalColumns['Pulse']= vitalColumns.ElixirSuite__Pulse__c;  
                        vitalColumns['Respiration']= vitalColumns.ElixirSuite__Respiration__c;  
                        vitalColumns['OxygenSaturation']= vitalColumns.ElixirSuite__Oxygen_Saturation__c;  
                        vitalColumns['VitalAdministeredBy']= vitalColumns.CreatedBy.Name;  
                    });
                    
                    let mapOfApiAndLabelofVital =  {
                                                    "BloodPressureDiasystolic" :"Blood Pressure Diasystolic",
                                                    "Temperature" :"Temperature",
                                                    "Pulse" :"Pulse",
                                                    "Respiration" :"Respiration",
                                                    "OxygenSaturation" :"Oxygen Saturation",
                                                    "VitalAdministeredBy" :"Vital Administered By"
                                            };   
                    
                    let toAddColVitals = [];
                    toAddColVitals.push( { label: 'Blood Pressure Systolic ', fieldName: 'BloodPressureSystolic', type: 'text'});
                    if(!$A.util.isUndefinedOrNull(csVitalColumns)){
                        let csColArrVitals = csVitalColumns.split(';');                       
                        const allTextColumnsVitals = ["BloodPressureDiasystolic","Temperature","Pulse","Respiration","OxygenSaturation","VitalAdministeredBy"];
                        if(csVitalColumns){
                            for(let recSObj in csColArrVitals){
                                if(allTextColumnsVitals.includes(csColArrVitals[recSObj])){
                                    toAddColVitals.push({ label: mapOfApiAndLabelofVital[csColArrVitals[recSObj]], 
                                                   fieldName: csColArrVitals[recSObj], type: 'text'});  
                                }   
                            }
                        }   
                    }
                    
                    var externalcmpDataInstance = component.get("v.ExternalcmpData");
                    externalcmpDataInstance.allergyData = res.allergyData;
                    externalcmpDataInstance.vitalSignsData =  res.vital_Signs_Data;
                    externalcmpDataInstance.glucoseData =  res.glucoseData;
                    component.set("v.ExternalcmpData", externalcmpDataInstance);
                    component.set('v.alllergyColumns',toAddCol);
                    component.set('v.vitalsColumns',toAddColVitals);
                     component.set("v.loaded",true);
                
            }
        });
        
        $A.enqueueAction(action);

    },

   
    formAttributeDataUtility: function (component, serverResponse) {

        // A simple utility to arrange the data in a way to set the key as true/false if response has value and data key 
        // to hold the data; otherwise set key as false and set data key as an array.
        if (!$A.util.isEmpty(serverResponse)) {
            var compiledData = {
                'hasValue': true,
                'data': serverResponse,
                'dataFormSpecific': []
            };
            console.log('DataBase ' + typeof (compiledData));
            //component.set("v.medicationData",medicationData);
            console.log('compiled data in helper ' + JSON.stringify(compiledData));

        }
        else {

            let compiledData = {
                'hasValue': false,
                'data': [],
                'dataFormSpecific': []
            };
            //component.set("v.medicationData",medicationData);
            // console.log('medication inside else '+JSON.stringify(component.get("v.allergyData")));
            console.log('else compiled data ' + JSON.stringify(compiledData));


        }

        return compiledData;


    },
    arrangeConditionDataAsParentChildv2: function (component, parentProblem, relatedProblemDaignoses, relatedNotes) {
        var nameSpace = 'ElixirSuite__';
        console.log('parent PROBLEM ' + JSON.stringify(parentProblem));
        console.log('child Diagnoses ' + JSON.stringify(relatedProblemDaignoses))
        console.log('child NOtes ' + JSON.stringify(relatedNotes))
        var mastrJSON = [];
        var idx = 0;
        if (!$A.util.isEmpty(parentProblem)) {
            for (var parent in parentProblem) {
                mastrJSON.push(parentProblem[parent]);
                mastrJSON[idx].problemIsChecked = true;
                mastrJSON[idx].isAddedFromTemplate = true;
                mastrJSON[idx].description = '';
                mastrJSON[idx].relatedDiagnoses = [];
                mastrJSON[idx].relatedNotes = [];
                mastrJSON[idx].alreadyExisting = true;

                if (!($A.util.isUndefinedOrNull(relatedProblemDaignoses[parent]) || $A.util.isEmpty(relatedProblemDaignoses))) {
                    for (var childDiagnoses in relatedProblemDaignoses) {
                        if (relatedProblemDaignoses[childDiagnoses][nameSpace + 'Related_Problem__c'] == parentProblem[parent].Id) {
                            relatedProblemDaignoses[childDiagnoses].diagnosesIsChecked = true;
                            relatedProblemDaignoses[childDiagnoses].alreadyExistingDaignoses = true;
                            mastrJSON[idx].relatedDiagnoses.push(relatedProblemDaignoses[childDiagnoses]);
                        }
                    }
                }
                if (!($A.util.isUndefinedOrNull(relatedProblemDaignoses[parent]) || $A.util.isEmpty(relatedNotes))) {
                    for (var childNotes in relatedNotes) {
                        if (relatedNotes[childNotes][nameSpace + 'Related_Problem__c'] == parentProblem[parent].Id) {
                            relatedNotes[childNotes].alreadyExistingNotes = true;
                            mastrJSON[idx].relatedNotes.push(relatedNotes[childNotes]);
                        }
                    }
                }
                idx++;

            }
        }
        console.log('final 9000 ' + JSON.stringify(mastrJSON));
        return mastrJSON;

    },
    allArrangementForproblemDiagnosis: function (component) {
        var filterProblemDaignoses = component.get("v.problemDiagnosesData").data;
        console.log('filterProblemDaignoses ' + JSON.stringify(filterProblemDaignoses));
        var diagnoseToDel = [];
        var toUpdateNotesOnForm = [];
        var toUpdateRecordsOnForm = [];
        var toUpdateProblemsOnForm = [];
        var toInsertNewNote = [];
        for (var filter in filterProblemDaignoses) {
            if (!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].relatedDiagnoses)) {
                var insideArr = filterProblemDaignoses[filter].relatedDiagnoses;
                for (var diagnoses in insideArr) {
                    if (!$A.util.isUndefinedOrNull(insideArr[diagnoses].isDeleted) && insideArr[diagnoses].isDeleted) {
                        diagnoseToDel.push(insideArr[diagnoses].Id);
                    }
                }
            }
            if (!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isrelatedNotesUpdated) && filterProblemDaignoses[filter].isrelatedNotesUpdated) {
                var relatedNotes = JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedNotes));
                toUpdateNotesOnForm = toUpdateNotesOnForm.concat(relatedNotes);
            }
            if (!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isrelatedDiagnosesUpdated) && filterProblemDaignoses[filter].isrelatedDiagnosesUpdated) {
                var relatedDiagnoses = JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedDiagnoses));
                toUpdateRecordsOnForm = toUpdateRecordsOnForm.concat(relatedDiagnoses);
            }
            if (!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isproblemRecordUpdatedFormCreateNewTab) && filterProblemDaignoses[filter].isproblemRecordUpdatedFormCreateNewTab) {
                toUpdateProblemsOnForm.push(filterProblemDaignoses[filter]);
            }
            if (!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].toInsertNewNote) && filterProblemDaignoses[filter].toInsertNewNote) {
                var relatedNotesNew = JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedNotes));
                toInsertNewNote = toInsertNewNote.concat(relatedNotesNew);
            }
        }




        var s = { "keysToSave": filterProblemDaignoses, 'AccountId': component.get("v.patientID") };
        console.log('keys to save rtoyoy ' + (JSON.stringify(s)));
        console.log('to update problem records on form ' + (JSON.stringify(toUpdateProblemsOnForm)));
        var toUpdateProblemRecordsOnForm = { 'daignosesRecord': toUpdateRecordsOnForm };
        var finalStringToReturn = {
            'diagnoseToDel': diagnoseToDel,
            'toUpdateNotesOnForm': toUpdateNotesOnForm,
            'toUpdateRecordsOnForm': toUpdateRecordsOnForm,
            'toUpdateProblemsOnForm': toUpdateProblemsOnForm,
            'toInsertNewNote': toInsertNewNote,
            'problemDaignosesDataToSave': JSON.stringify(s),
            'toUpdateProblemRecordsOnForm': JSON.stringify(toUpdateProblemRecordsOnForm),
            'problemToDel': component.get("v.CustomProblemToDel")
        };
        return JSON.stringify(finalStringToReturn);

    },
    allArrangementsForMedicationData: function (component) {
        var finalStringFormedication = {
            'selectedUser': component.get("v.selectedUser"),
            'selectedVia': component.get("v.selectedVia"),
            'medicationJSON': JSON.stringify(component.get("v.medicationJSON"))
        };
        return JSON.stringify(finalStringFormedication);
    },
    medicationDataJSON: function (component, serverResponse) {
        var nameSpace = 'ElixirSuite__';
        //Medication data comes from 2 diffrent object;
        //This function arranges them in a single JSON 
        //This concatinates the value of child data into one and put it as new key; and delete that existing key      
        if (!$A.util.isEmpty(serverResponse.data)) {
            var rows = serverResponse.data;
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                console.log('row 1234 ' + JSON.stringify(row));
                if (row[nameSpace + 'Frequency__r'] != undefined && row[nameSpace + 'Frequency__r'].length != 0 &&
                    row[nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'] != undefined) {
                    console.log('inside if');
                    var str = row[nameSpace + 'Frequency__r'][0][nameSpace + 'Repeat__c'];
                    if (!$A.util.isUndefinedOrNull(str)) {
                        if (str.startsWith('\'n\' times')) {
                            var str2 = str;
                            console.log('str2' + JSON.stringify(str2));
                            var str3 = row[nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                            console.log('str3' + JSON.stringify(str3));
                            var str4 = str2.replace("\'n\'", str3);
                            row[nameSpace + 'Frequency__c'] = str4;
                            delete row[nameSpace + 'Frequency__r'];

                        } else if (str.startsWith('After every')) {
                            var str5 = str;
                            var str6 = row[nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                            var str7 = str5.replace("\'n\'", str6);
                            row[nameSpace + 'Frequency__c'] = str7;
                            delete row[nameSpace + 'Frequency__r'];
                        }
                    }
                    else {
                        row[nameSpace + 'Frequency__c'] = '--';
                    }
                }
            }
        }
        console.log('medication ready ' + JSON.stringify(serverResponse));
        return serverResponse;

    },
    handleValueChange: function (component) {
         console.log("kk---" , JSON.stringify(component.get("v.selectedVal")));
    },
    deleteProblemsIfAny: function (component) {
        var action = component.get('c.deleteAllProblemSavedFromForm');
        action.setParams({
            recIds: component.get("v.insertedProblem"),
            procedureId: component.get("v.procedureWrapper").insertedProcedure,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log("state---" , state);
            
        });
        $A.enqueueAction(action);
    },
    setProblemData: function (component) {
        let probArr = component.get("v.toUpdateProblem");
        let arr = [];
        for (let rec in probArr) {
            arr.push({ 'keysToSave': probArr[rec] });
        }
        component.set("v.toUpdateProblem", arr);
    },

    saveStaticImage: function (component) {
        // find all static image wrapper component
        var staticImageWrappers = component.find("staticImageWrapperChild");
        if (staticImageWrappers) {
            // let's find out how many staticImageWrapper are there
            var totalStaticImageWrapper = staticImageWrappers.length;

            if (totalStaticImageWrapper) {
                // there is more than one static image wrapper
                for (var i = 0; i < totalStaticImageWrapper; i++) {
                    staticImageWrappers[i].fetchDataToSend();
                }
            }
            else {
                // there is only one static image wrapper
                staticImageWrappers.fetchDataToSend();
            }

        }
        // else {
        //     console.log("no static image wrappers found");
        // }

    },

    saveDynamicImage: function (component) {
        // find all static image wrapper component
        var dynamicImageWrappers = component.find("dynamicImageWrapperChild");
        if (dynamicImageWrappers) {
            // let's find out how many staticImageWrapper are there
            var totalStaticImageWrapper = dynamicImageWrappers.length;

            if (totalStaticImageWrapper) {
                // there is more than one static image wrapper
                for (var i = 0; i < totalStaticImageWrapper; i++) {
                    dynamicImageWrappers[i].fetchDataToSend();
                }
            }
            else {
                // there is only one static image wrapper
                dynamicImageWrappers.fetchDataToSend();
            }

        }
        // else {
        //     console.log("no dynamic image wrappers found");
        // }

    },
    saveConsentText: function (component) {
        var childComponents = component.find("consent_text");
        if (childComponents) {
            // let's find out how many staticImageWrapper are there
            var childComponentWrapper = childComponents.length;

            if (childComponentWrapper) {
                // there is more than one dynamic image wrapper
                for (var i = 0; i < childComponentWrapper; i++) {
                    childComponents[i].childMessageMethod();
                }
            }
            else {
                // there is only one dynamic image wrapper
                childComponents.childMessageMethod();
            }

        }
    },
    findDependentField: function (component, column, cssRecords, controllerValue) {
        var column = column;
        var isControlling = column.isControlling;
        if (column.value != '' && isControlling) {
            var controllerValue = controllerValue;
            var dependentField = column.dependentField;
            var pickListMap = column.DependentPicklistValues;
            if (controllerValue != '--- None ---') {
                var childValues = pickListMap[controllerValue];
                console.log('childValues ' + childValues);
                var childValueList = [];
                if ($A.util.isUndefinedOrNull(childValues)) {
                    childValues = [];
                }
                //childValueList.push('--- None ---');
                for (var i = 0; i < childValues.length; i++) {
                    childValueList.push(childValues[i]);
                }
                //Code to populate dependent field values
                var radioList = [];
                for (let section in cssRecords) {
                    let rows = cssRecords[section].ElixirSuite__Object_1_css__r;
                    for (let row in rows) {
                        let columns = rows[row].Columns;
                        for (let column in columns) {
                            if (columns[column].ElixirSuite__Field_Name__c === dependentField) {
                                if (columns[column].ElixirSuite__Form_Data_Type__c == 'Radio') {
                                    for (let child in childValueList) {
                                        let obj = { 'value': childValueList[child], 'label': childValueList[child] };
                                        radioList.push(obj);
                                    }
                                    console.log('radioList ' + radioList);
                                    columns[column]['PicklistValues'] = radioList;
                                }
                                else if (columns[column].ElixirSuite__Data_Type__c == 'MULTIPICKLIST') {
                                    let multiList = [];
                                    for (let child in childValueList) {
                                        let obj = { 'value': childValueList[child], 'label': childValueList[child] };
                                        multiList.push(obj);
                                    }
                                    console.log('multipickList ' + multiList);
                                    columns[column]['PicklistValues'] = multiList;
                                }
                                else {
                                    columns[column]['PicklistValues'] = childValueList;
                                }
                                break;
                            }
                        }
                    }
                }


            }
            else {
                component.set("v.getChildList", ['--- None ---']);
                component.set("v.getDisabledChildField", true);
            }
            component.set("v.cssRecords", cssRecords);
        }
    },
    runValidationForms: function (component) {
        var flag = true;
        if (component.get("v.enableTime")) {
            let timeObj = component.get("v.timeWrapper");
            if (!timeObj.endTime) {
                component.set("v.showConfirmDialog", true);
                flag = false;
            }
        }
        return flag;
    },
    showError : function(component, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            type: 'error',
            message: msg,
        });
        toastEvent.fire();
    },
    saveUpdatededForm: function (component, event, helper,formSubmitToProvider) {
        
        console.log('formSubmitToProvider: '+formSubmitToProvider)
        // save images of all staticImageWrappers
        helper.saveStaticImage(component);

        // save images of all dynamicImageWrappers
        helper.saveDynamicImage(component);
        helper.saveConsentText(component);
        component.set("v.loaded", false);
        var timeObj = component.get("v.timeWrapper");
        if (new Date(timeObj.startTime).setSeconds(0, 0) == new Date(timeObj.endTime).setSeconds(0, 0)) {
            console.log('time equal');
            timeObj.paramSame = true;
        }
        helper.setProblemData(component, event, helper);
        var cssRecords = component.get("v.cssRecords");
        var objNameToValue = component.get("v.objNameToValue");
        console.log('recordsToSave' + JSON.stringify(cssRecords));
        var action = component.get("c.saveForm");

        let modularMatrixDataToSend;
        if (JSON.stringify(component.get("v.modularMatrixData")) == "{}") {
            modularMatrixDataToSend = "";
        }
        else {
            modularMatrixDataToSend = JSON.stringify(component.get("v.modularMatrixData"));
        }

        console.log('sending modular matrix data: ', modularMatrixDataToSend);

        action.setParams({
            'accountId': component.get("v.recordId"),
            'formName': component.get("v.formName"),
            'changedFormName': component.get("v.changedFormName"),
            'cssRecords': JSON.stringify({ 'cssRecords': cssRecords }),
            'formUniqueId': component.get("v.formUniqueId"),
            'objNameToValue': JSON.stringify(objNameToValue),
            'problemData': '',//helper.allArrangementForproblemDiagnosis(component, event ,helper),
            'precriptionData': helper.allArrangementsForMedicationData(component, event, helper),
            'deletedProblem': component.get("v.deletedProblem"),
            'toDelProblemFromUpdate': component.get("v.toDelProblemFromUpdate"),
            'toUpdateProblem': JSON.stringify(component.get("v.toUpdateProblem")),
            'isProblemEnabled': component.get("v.isProblemEnabled"),
            'procedureWrapper': JSON.stringify(component.get("v.procedureWrapper")),
            'isProcedureEnabled': component.get("v.isProcedureEnabled"),
            'timeWrapper': JSON.stringify(component.get("v.timeWrapper")),
            'isTimeEnabled': component.get("v.enableTime"),
            'isClone': component.get("v.clone"),
            'isDeceased': component.get("v.isDeceased"),
            'modularMatrixData': modularMatrixDataToSend,
            'formSubmitToProvider' : formSubmitToProvider
        });
        action.setCallback(this, function (response) {
            var result = component.get("v.formUniqueId");
            var state = response.getState();
            var resp = response.getReturnValue();
            console.log(resp + ' mahi');

            if (state === "SUCCESS") {
                //if(resp == false){
                if(!formSubmitToProvider){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Form Updated Successfully"
                    });
                    toastEvent.fire();                    
                }
                //  window.location.reload();
                // }
                /*else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "This patient is deceased. You cannot edit this patient record!"
                });
                toastEvent.fire();
                }*/

                component.set("v.loaded", true);
                /*** PASS THE SAVED FOR  ID TO EXTERNAL COMPONENTS FOR THEIR SAVING****************/
                try {
                    var allergy = component.find('compB');
                    if (allergy) {
                        allergy.allergyMethod(result, component.get("v.recordId"));
                    }
                    var glucose = component.find('glucoseCmp');
                    if (glucose) {
                        glucose.glucoseMethod(result, component.get("v.recordId"));
                    }
                    var vital = component.find('vitalCmp');
                    if (vital) {
                        vital.vitalMethod(result, component.get("v.recordId"));
                    }
                } catch (e) {
                console.log('Vital error!!'+e); 
                }
                console.log('After event ###');
                var appEvent = $A.get("e.c:FormsRefreshEvt");
                appEvent.fire();
                helper.closeTabAndNavigate(component, event, helper);
                component.set("v.isOpen", false);
            }
            else {
                var errors = response.getError();
                if (errors) {
                    console.log("Error occured while updating form: " + JSON.stringify(errors));

                    if (errors[0] && errors[0].message) {
                        helper.showError(component, errors[0].message);
                    }
                    else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0].message) {
                        helper.showError(component, errors[0].pageErrors[0].statusCode + ": " + errors[0].pageErrors[0].message);
                    }
                    else {
                        helper.showError(component, "FORM_FAILED_TO_UPDATE: Check browser console for details");
                    }
                }
                else {
                    helper.showError(component, `UNKNOWN_ERROR: Response State is ${response.getState()}`);
                }
                component.set("v.loaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    toastHelper : function(title,message,type){
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title, 
                        "message": message,
                        "type" : type
                    });
                    toastEvent.fire();
    },
    closeTabAndNavigate: function (component) {
         var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log('Error in workspace'+error);
                    });
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef:"c:Elixir_NewAccountAssociatedForms",
                    componentAttributes: {
                        recordVal : component.get("v.recordId"),
                        //  categorized : "Other",
                        subCategorized: "Assessment",
                        headingTitle: "All Notes"
                    }
                });
                evt.fire();
        
    },
     deleteSelectedRows: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRecordId');
        console.log('selectedRows',selectedRows);
        // Extract the record IDs from the selected rows
        
        
        // Call the Apex method to delete records
        var action = component.get('c.deleteRecords');
        action.setParams({ recordIds: selectedRows });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // Handle success
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record Deleted Successfully."
                });
                toastEvent.fire(); 
                helper.fetchDiagnosisDataOnforms(component , event , helper);
                component.set("v.loaded",false);
                
                console.log(response.getReturnValue());
            } else if (state === 'ERROR') {
                // Handle error
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    deleteSelectedProblemRows: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRecordId');
        console.log('selectedRows',selectedRows);
        // Extract the record IDs from the selected rows
        
        
        // Call the Apex method to delete records
        var action = component.get('c.deleteProblemRecords');
        action.setParams({ recordIds: selectedRows });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // Handle success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record Deleted Successfully."
                });
                toastEvent.fire(); 
                helper.fetchProblemDataOnforms(component , event , helper);
                component.set("v.loaded",false);
                
                console.log(response.getReturnValue());
            } else if (state === 'ERROR') {
                // Handle error
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    sortAllergyData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.ExternalcmpData.allergyData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.ExternalcmpData.allergyData", data);
    },
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.problemListCopy");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.problemListCopy", data);
    },
    sortDiagnosisData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.diagnosisListCopy");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.diagnosisListCopy", data);
    },
    sortMedicationData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.medicationListCopy");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.medicationListCopy", data);
    },
    saveChangesOfAllergy: function(component, event, helper, draftValues) {
        // Call an Apex method to save changes
        var action = component.get("c.saveRecords");
        action.setParams({
            "updates": draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                     'type': 'success',
                    "message": "Record(s) updated successfully."
                });
                toastEvent.fire(); 
                helper.fetchExternalCmpData(component , event , helper);
                component.set("v.loaded",false);// Refresh data after save
            } else {
                // Handle error
                console.error("Error saving records");
            }
        });
        $A.enqueueAction(action);
    },
})