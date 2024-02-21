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
                        dataTypeToApiList.push({ Type: key, values: reqMapDataTypeToApi[key] });
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
    fetchColumnsForProblemsFromCustomSetting: function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getProblemsColumns");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('res========= ' + JSON.stringify(res));
                
                if (!$A.util.isUndefinedOrNull(res)) {
                    let csColArr = res.split(';');
                    console.log('csColArr ' + JSON.stringify(csColArr));
                    
                    // Set the split array to the component attribute
                    component.set("v.parentProblemColumns", csColArr);
                }
                
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
        component.set("v.showProblemData",true);
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns problem***',csColumns);
        console.log('finColumnsApi problem***',finColumnsApi);
        console.log('finColumnsLabel problem***',finColumnsLabel);
        
        var columnsFromCustomSetting = component.get('v.parentProblemColumns');
        console.log('columnsFromCustomSetting for problems***',columnsFromCustomSetting);
        var labelToApiList = component.get('v.problemColumnsLst');
       
         var action = component.get("c.fetchAccountProblems");
         action.setParams({
             acctId: component.get("v.patientID"),
             problemIds: component.get("v.notesSpecificData").problemData
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
                 
                 toAddCol.push( { label: 'Problem Name ', fieldName: 'Name', type: 'text',sortable:true,editable:false});
                 toAddCol.push( { label: 'SNOMED CT Code ', fieldName: 'ElixirSuite__SNOMED_CT_Code__c', type: 'text',sortable:true,editable:true});
                 toAddCol.push( { label: 'Problem Type', fieldName: 'ElixirSuite__Problem_Type__c', type: 'text',sortable:true,editable:false});
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
                    		//console.log('csColumns[i] problem:', csColumns[i]);
							//console.log('field.value:', field.value);

                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField problem:', reqField);
                            let reqType = dataTypeToApiLst.find(field => field.Type == fieldName);
                            // Find the corresponding entry in dataTypeToApiLst
                            //let dataTypeToApi = dataTypeToApiLst.find(field => field.value == fieldName);
                    		//console.log('dataTypeToApi:', dataTypeToApi);
                            if (reqField) {
                                let label = reqField.label;
                                //let dataType = dataTypeToApi.DataType;
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
                sortable: true,
                editable: false

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
                sortable: true,
                editable: false
            });}
            else if(reqType.values === 'PICKLIST'){
                    
                toAddCol.push({
                    label: label,
                    fieldName: fieldName,
                    type: "picklist",
                    editable: false, 
                    sortable:true// You can customize this based on your requirements
                });
                }
                                else{
                    
                                toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: true, 
                                    sortable:true// You can customize this based on your requirements
                                });
                                } } else {
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
                                    class: 'delbtn'
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
    fetchProblemDataOnformsinit : function(component, event ,helper){
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
       
         var action = component.get("c.fetchAccountProblems");
         action.setParams({
             acctId: component.get("v.patientID"),
             problemIds: component.get("v.notesSpecificData").problemData
         });
         
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 component.set("v.loaded",true);
                 var masterProblemList = response.getReturnValue();
                 console.log('masterProblemList 1: '+JSON.stringify(masterProblemList))
                 //component.set("v.problemListCopy", masterProblemList); on init do not set data as per request LX3-12304
                 
                 var nameSpace = 'ElixirSuite__';                 
                 
                 let toAddCol = [];
                 
             //    toAddCol.push( { label: 'Problem Name ', fieldName: 'Name', type: 'text'});
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
                    		//console.log('csColumns[i] problem:', csColumns[i]);
							//console.log('field.value:', field.value);

                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField problem:', reqField);
                            // Find the corresponding entry in dataTypeToApiLst
                            //let dataTypeToApi = dataTypeToApiLst.find(field => field.value == fieldName);
                    		//console.log('dataTypeToApi:', dataTypeToApi);
                            if (reqField) {
                                let label = reqField.label;
                                //let dataType = dataTypeToApi.DataType;
                    
                                toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: true, 
                                    sortable:true// You can customize this based on your requirements
                                });
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
                                    class: 'delbtn'
                                }
                            });
                 
                 console.log('toAddCol for problems: '+toAddCol)
                 
                 component.set('v.problemColumnsOnForms', toAddCol);
                 //component.set("v.problemListCopy", masterProblemList); on init do not set data as per request LX3-12304
                 
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
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
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
    
    sortAllergyData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.ExternalcmpData.allergyData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.ExternalcmpData.allergyData", data);
    },
     
   fetchColumnsFromCustomSetting: function(component, event, helper) {
    component.set("v.loaded", false);
    var action = component.get("c.getDiagnosisColumns");
    
    action.setCallback(this, function(response) {
        var state = response.getState();
        
        if (state === "SUCCESS") {
            console.log("res " + JSON.stringify(response.getReturnValue()));
            var res = response.getReturnValue();
            console.log('res========= ' + JSON.stringify(res));
            
            if (!$A.util.isUndefinedOrNull(res)) {
                let csColArr = res.split(';');
                console.log('csColArr ' + JSON.stringify(csColArr));
                
                // Set the split array to the component attribute
                component.set("v.parentColumns", csColArr);
            }

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
                        dataTypeToApiList.push({ value: key, type: reqMapDataTypeToApi[key] });
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
        component.set("v.showDiagnosisData",true);
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
            diagnosisIds: component.get("v.notesSpecificData").diagnosisData
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
                
                toAddCol.push( { label: 'Code Label', fieldName: 'Name', type: 'text',sortable:true,editable: true});
                toAddCol.push( { label: 'Code Description', fieldName: 'ElixirSuite__Code_Description1__c', type: 'text',sortable:true,editable: true});
                toAddCol.push( { label: 'ICD Version', fieldName: 'ElixirSuite__Version__c', type: 'text',sortable:true,editable: false});
                
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

				if (csColumns && csColumns.length > 0 ) {
                        for (let i = 0; i < csColumns.length; i++) {
                            let fieldName = csColumns[i];
                    		console.log('csColumns[i]:', csColumns[i]);
							//console.log('field.value:', field.value);

                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField:', reqField);
                            let reqType = dataTypeToApiLst.find(field => field.value == fieldName);
                           
                            if (reqField) {
                                let label = reqField.label;
                                //let dataType = dataTypeToApi.DataType;
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
                editable: false

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
                editable: false
            });}
            else if(reqType.type === 'PICKLIST'){
                toAddCol.push({
                    label: label,
                    fieldName: fieldName,
                    type: "picklist",
                    editable: false, 
                    sortable:true// You can customize this based on your requirements
                });
            }
                                else{
                    
                                toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: true, sortable:true// You can customize this based on your requirements
                                });
                                } } else {
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
                        variant: 'Base'
                    }
                });
                
                toAddCol.push({
                    label: 'Action',
                    type: 'button',
                    typeAttributes: {
                        label: '',
                        name: 'deleteRow',
                        title: 'Delete',
                        iconName: 'utility:delete',class: 'delbtn'
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
    fetchDiagnosisDataOnformsinit : function(component, event ,helper){
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
            diagnosisIds: component.get("v.notesSpecificData").diagnosisData
        });
         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var diagnosisList = response.getReturnValue();
                console.log('diagnosisList: '+diagnosisList);
                console.log('diagnosisList Data==: '+JSON.stringify(diagnosisList))
                //component.set("v.diagnosisListCopy", diagnosisList); on init do not set data as per request LX3-12304
                var nameSpace = 'ElixirSuite__';
				
                let toAddCol = [];
                 

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

				if (csColumns && csColumns.length > 0 ) {
                        for (let i = 0; i < csColumns.length; i++) {
                            let fieldName = csColumns[i];
                    		console.log('csColumns[i]:', csColumns[i]);
							//console.log('field.value:', field.value);

                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField:', reqField);
                           
                            if (reqField) {
                                let label = reqField.label;
                                //let dataType = dataTypeToApi.DataType;
                    
                                toAddCol.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: "text",
                                    editable: true, sortable:true// You can customize this based on your requirements
                                });
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
                        variant: 'Base'
                    }
                });
                
                toAddCol.push({
                    label: 'Action',
                    type: 'button',
                    typeAttributes: {
                        label: '',
                        name: 'deleteRow',
                        title: 'Delete',
                        iconName: 'utility:delete',class: 'delbtn'
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
                //component.set('v.diagnosisListCopy', allData); on init do not set data as per request LX3-12304
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
                var reqTypeList = [];
                for (var key in mapMedicationApiAndType) {
                    if (mapMedicationApiAndType.hasOwnProperty(key)) {
                        reqTypeList.push({ labels: key, values: mapMedicationApiAndType[key] });
                    }
                }
                console.log('Parent Component reqFieldsList ====', JSON.stringify(reqTypeList));
                
                component.set("v.medicationColumnsLst", reqFieldsList);
                component.set("v.medicationTypeLst", reqTypeList);
                
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
        component.set("v.showMedicationsData",true);
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
        var fieldApiAndType = component.get("v.medicationApiAndType");
        
        var action = component.get("c.fetchAccountMedication");
        action.setParams({
            acctId: component.get("v.patientID"),
            medicationIds: component.get("v.notesSpecificData").medicationData
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
                
                let toAddCol = [];
                toAddCol.push( { label: 'Medication Name',sortable:true, fieldName: 'ElixirSuite__Medication__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Medication__c') ? fieldApiAndType.ElixirSuite__Medication__c : 'text', editable: (fieldApiAndType.hasOwnProperty('ElixirSuite__Medication__c') && (fieldApiAndType.ElixirSuite__Medication__c == 'REFERENCE' || fieldApiAndType.ElixirSuite__Medication__c == 'DATETIME' || fieldApiAndType.ElixirSuite__Medication__c == 'DATE')) ? false : true});
                toAddCol.push( { label: 'Strength',sortable:true, fieldName: 'strength', type: fieldApiAndType.hasOwnProperty('strength') ? fieldApiAndType.strength : 'text', editable: (fieldApiAndType.hasOwnProperty('strength') && (fieldApiAndType.strength == 'REFERENCE' || fieldApiAndType.strength == 'DATETIME' || fieldApiAndType.strength == 'DATE')) ? false : false});
                toAddCol.push( { label: 'Directions',sortable:true, fieldName: 'ElixirSuite__Direction__c', type: fieldApiAndType.hasOwnProperty('ElixirSuite__Direction__c') ? fieldApiAndType.ElixirSuite__Direction__c : 'text', editable: (fieldApiAndType.hasOwnProperty('ElixirSuite__Direction__c') && (fieldApiAndType.ElixirSuite__Direction__c == 'REFERENCE' || fieldApiAndType.ElixirSuite__Direction__c == 'DATETIME' || fieldApiAndType.ElixirSuite__Direction__c == 'DATE')) ? false : true});
                
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
                var apiToTypeList = component.get('v.medicationTypeLst');
                
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
                        let reqType = apiToTypeList.find(field => field.labels == fieldName);
                        
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
                sortable: true,
                editable:false,

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
                sortable: true,
                editable:false,
            });}
            else if(reqType.values === 'PICKLIST'){
                            
                         toAddCol.push({
                        label: label,
                        fieldName: fieldName,
                        type: 'picklist', 
                        editable:false,
                        sortable: true
                    });}
                            
                            else{
                                toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: fieldApiAndType.hasOwnProperty(fieldName) ? fieldApiAndType[fieldName] : "text",
                                editable: (fieldApiAndType.hasOwnProperty(fieldName) && (fieldApiAndType[fieldName] == 'REFERENCE' || fieldApiAndType[fieldName] == 'DATETIME' || fieldApiAndType[fieldName] == 'DATE' || fieldApiAndType[fieldName] == 'ID')) ? false : true,
                                sortable:true // You can customize this based on your requirements
                            });
                                
                            }
            
                        }else if(csColumns){
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: fieldApiAndType.hasOwnProperty(csColumns[recSObj]) ? fieldApiAndType[csColumns[recSObj]] : 'text',sortable:true,editable:(fieldApiAndType.hasOwnProperty(csColumns[recSObj]) && (fieldApiAndType[csColumns[recSObj]] == 'REFERENCE' || fieldApiAndType[csColumns[recSObj]] == 'DATETIME' || fieldApiAndType[csColumns[recSObj]] == 'DATE' || fieldApiAndType[csColumns[recSObj]] == 'ID')) ? false : true});  
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
    fetchMedicationsDataOnformsinit : function(component, event ,helper){
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
            medicationIds: component.get("v.notesSpecificData").medicationData
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var medicationList = response.getReturnValue();
                console.log('medicationList: '+medicationList);
                console.log('medicationList Data==: '+JSON.stringify(medicationList))
                //component.set("v.medicationListCopy", medicationList); on init do not set data as per request LX3-12304
                var nameSpace = 'ElixirSuite__';
                
                let toAddCol = [];
                
                
                if(csColumns!=null){
                    console.log('csColumns'+csColumns);
                    component.set('v.medicationColumns', csColumns);
                }
                if(csColumns==null){
                    csColumns = component.get('v.medicationColumns');
                    console.log('csColumns----'+csColumns);
                }
                var labelToApiList = component.get('v.medicationColumnsLst');
                console.log('labelToApiList***', labelToApiList);
                console.log('csColumns length :', csColumns.length);
                console.log('labelToApiList length:', labelToApiList.length);
                
                let mapOfApiAndLabel =  {
                                             "strength":"Strength"                                             
                                            };  
                
                console.log('csColumns----'+JSON.stringify(csColumns));
               
                
                if (csColumns && csColumns.length > 0 ) {
                    const allTextColumns = ["strength"];
                    for (let i = 0; i < csColumns.length; i++) {
                        let fieldName = csColumns[i];
                        let reqField = labelToApiList.find(field => field.value == fieldName);
                        console.log('reqField:', reqField);
                        
                        if (reqField) {
                           
                            let label;
                            if(reqField.label ==='Direction'){
                                label='Directions';
                            }else{
                              label=reqField.label;
                            }
                            toAddCol.push({
                                label: label,
                                fieldName: fieldName,
                                type: "text",
                                editable: true,
                                sortable:true // You can customize this based on your requirements
                            });
                        }else if(csColumns){
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: 'text',sortable:true});  
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
                //component.set('v.medicationListCopy', allData); on init do not set data as per request LX3-12304
               
                
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
    helperInit : function(component, event ,helper){
        var action = component.get("c.buildForm");
        action.setParams({ formName : component.get("v.formName") , accountId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('css result '+JSON.stringify(result));
            if(state === 'SUCCESS'){
            if(!$A.util.isUndefinedOrNull(result)){
                const colMap = {1 : 'slds-size_12-of-12',
                                2 : 'slds-size_6-of-12',
                                3 : 'slds-size_4-of-12',
                                4 : 'slds-size_3-of-12',
                                6 : 'slds-size_2-of-12'};
                var cssRecords = result.cssRecords;
                var allFields = result.allFields;
                component.set("v.timeWrapper",{'startTime' : result.currentDateTime,'endTime' : '','paramSame' : false,'setEndTimeAsCurrent' : false});  
                var formDefaultValues = result.formDefaultValues;
                console.log('formDefaultValues'+JSON.stringify(formDefaultValues));
                var objToData = result.objToData;
                var consentData = result.consentData;
                var formCssToFxValue = result.formCssToFxValue;
                var accountName = result.accountName;
                component.set("v.accName", accountName);
                component.set("v.consentData",consentData);
                
                component.set("v.FormData", result.tempData);
                console.log('meg' + JSON.stringify(cssRecords));
                
                component.set("v.patientModeCheckboxVisible", result.isPatientModeEnabled);
                
                    if(!$A.util.isUndefinedOrNull(cssRecords)){
                        for(let record in cssRecords){
                            if(cssRecords[record].ElixirSuite__Section_Number__c == 1){
                                component.set("v.enableTime", cssRecords[record].ElixirSuite__Is_Time_Enabled__c);
                            }
                            cssRecords[record]['addProblem'] = false;
                            var isAutoTextEnabled = cssRecords[record]['ElixirSuite__Enable_Auto_text__c'];
                            if(!$A.util.isUndefinedOrNull(cssRecords[record].ElixirSuite__Indentation__c)){
                                let indent = cssRecords[record].ElixirSuite__Indentation__c;
                                if(indent.toLowerCase() == 'heading'){
                                    cssRecords[record].ElixirSuite__Css__c += ';margin-left:25px'; 
                                }else if(indent.toLowerCase() == 'subheading'){
                                    cssRecords[record].ElixirSuite__Css__c += ';margin-left:50px'; 
                                }
                            }
                            if(cssRecords[record].ElixirSuite__Add_Problem__c){
                                component.set("v.isProblemEnabled",true);
                            }
                            if(cssRecords[record].ElixirSuite__Add_Procedure__c){
                                component.set("v.isProcedureEnabled",true);
                            }
                            if(!$A.util.isUndefinedOrNull(cssRecords[record].ElixirSuite__Form_Category__c)){
                                component.set("v.category", cssRecords[record].ElixirSuite__Form_Category__c);
                            }
                            //TEXT GENERATION - START
                            var apiNameToValues = {};
                            try{
                                if(isAutoTextEnabled){
                                    let autoText = cssRecords[record].ElixirSuite__Auto_text__c;
                                    cssRecords[record].ElixirSuite__Auto_text__c = autoText.replaceAll('$','');
                                    let defaultAutoText = cssRecords[record].ElixirSuite__Auto_text__c;
                                    cssRecords[record]['DefaultAutoText'] = defaultAutoText;
                                    helper.getBrackets(JSON.parse(JSON.stringify(defaultAutoText)), cssRecords[record], helper);
                                    console.log('****'+JSON.stringify(cssRecords[record]));
                                }
                            }
                            catch(exe){
                                //alert(exe);
                            }
                            //TEXT GENERATION - END
                            //MATRIX-HEAD START
                            let sectionInfo = cssRecords[record];
                            let isMatrix = sectionInfo.ElixirSuite__Is_matrix__c;
                            let headings = sectionInfo.ElixirSuite__Headings__c;
                            try{
                                if(!$A.util.isUndefinedOrNull(headings)){
                                    let separatedHeads = headings.split(';');
                                    sectionInfo['ElixirSuite__Headings__c'] = separatedHeads;
                                    let columnsInSection = cssRecords[record].ElixirSuite__Columns_In_Section__c;
                                    sectionInfo['colsize'] = helper.fetchColSize(parseInt(columnsInSection), colMap);
                                }                       
                            }catch(e){}
                            //MATRIX-HEAD END
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
                            let section = cssRecords[record].ElixirSuite__Object_1_css__r;
                            let columnsInSection = cssRecords[record].ElixirSuite__Columns_In_Section__c;
                            let oldRowNumber = -1;
                            let oldRow = 0;
                            if(!$A.util.isUndefinedOrNull(section)){          
                                for(let rowParent=0 ;rowParent<section.length; rowParent++){
                                    let escapeFToFpass = false;
                                    //Object - Form values - START
                                    console.log('Map_object_console '+section[rowParent]['ElixirSuite__Map_object__c']);
                                    if(!$A.util.isUndefinedOrNull(section[rowParent]['ElixirSuite__Map_object__c'])){
                                        let objName = section[rowParent]['ElixirSuite__Map_object__c'];
                                        let fldName = section[rowParent]['ElixirSuite__Map_field__c'];
                                        let dataType = section[rowParent]['ElixirSuite__Data_Type__c'];
                                        if(!$A.util.isUndefinedOrNull(objToData[objName])){
                                            console.log('jj'+objToData[objName]);
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
                                                    var val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                    let myBool = (val === 'true');
                                                    section[rowParent]['value'] = myBool;
                                                }
                                                    else{
                                                        var val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                        section[rowParent]['value'] = val;
                                                    }
                                            }
                                        }
                                    }
                                    console.log('2');
                                    //Default values - END
                                    var row = rowParent;
                                    let rowAdd = 0;
                                    for(let i=0;i<parseInt(columnsInSection);i++){
                                        if($A.util.isUndefinedOrNull(section[rowParent+i])){
                                            continue;//Saviour
                                        }
                                        let escapeFToFpass = false;
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
                                            console.log('**'+JSON.stringify(objToData));
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
                                                            section[rowParent+i]['value'] = objToData[objName][fldName].substring(0,limitLength);
                                                        }else{
                                                        section[rowParent+i]['value'] = objToData[objName][fldName];
                                                        }
                                                        escapeFToFpass = true;
                                                    }
                                                }
                                            }
                                        }
                                        if(!$A.util.isUndefinedOrNull(section[rowParent+i]['ElixirSuite__Map_object__c'])){
                                            let objName = section[rowParent+i]['ElixirSuite__Map_object__c'];
                                            let fldName = section[rowParent+i]['ElixirSuite__Map_field__c'];
                                            let dataType = section[rowParent+i]['ElixirSuite__Data_Type__c'];
                                            console.log('**'+JSON.stringify(formCssToFxValue));
                                            let index = allFields.findIndex( field => field.apiName.toLowerCase() == section[rowParent+i].ElixirSuite__Field_Name__c.toLowerCase() );
                                            var limitLength = allFields[index].lengthOfField;
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
                                                                section[rowParent+i]['value'] = sObjData[fldName].substring(0,limitLength);
                                                            }else{
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
                                                        var val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                        let myBool = (val === 'true');
                                                        section[rowParent+i]['value'] = myBool;
                                                    }
                                                        else{
                                                            var val = formDefaultValues[index]['ElixirSuite__Default1__c'];
                                                            section[rowParent+i]['value'] = val;
                                                        }
                                                }
                                            }
                                        }
                                        //Default values - END
                                        
                                        // Auto text Generation FOR AUTOPOPULATION - START
                                        
                                        if(!$A.util.isUndefinedOrNull(section[rowParent+i]['value']) && isAutoTextEnabled){
                                            let fieldName = section[rowParent+i]['ElixirSuite__Field_Name__c'];
                                            apiNameToValues[fieldName] = section[rowParent+i]['value'];
                                        }
                                        // Auto text Generation FOR AUTOPOPULATION - END
                                        let rowNumber = section[rowParent+i].ElixirSuite__Row__c;
                                        if($A.util.isUndefinedOrNull(rowNumber) || rowNumber==0){
                                            rowAdd++;
                                            continue;
                                        }
                                        if($A.util.isUndefinedOrNull(section[row]['Columns'])){
                                            section[row]['Columns'] = []; 
                                        }
                                        let index = -1;
                                        console.log('b4');
                                        if(section[rowParent+i]['ElixirSuite__Field_Label_Long__c'] != 'nbsp' && !$A.util.isUndefinedOrNull(section[rowParent+i].ElixirSuite__Field_Name__c)){
                                            index = allFields.findIndex( field => field.apiName.toLowerCase() == section[rowParent+i].ElixirSuite__Field_Name__c.toLowerCase() );
                                        }
                                        console.log('#'+index);
                                        if(index != -1){                                         
                                            var dataTypeValue = allFields[index].dataType.toUpperCase();
                                            var lengthOfField = allFields[index].lengthOfField;
                                                        var formDataType = section[rowParent+i]['ElixirSuite__Form_Data_Type__c'];
                                                        console.log('5'+JSON.stringify(section[rowParent+i]['PicklistValues']));
                                                        if(dataTypeValue == 'PICKLIST' && formDataType != 'Radio'){
                                                            section[rowParent+i]['PicklistValues'] = [];
                                                            if(allFields[index].isDependent && allFields[index].isControlling){
                                                                section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                section[rowParent+i]['dependentField'] = allFields[index].dependentField;
                                                                section[rowParent+i]['isControlling'] = allFields[index].isControlling;
                                                                section[rowParent+i]['isDependent'] = allFields[index].isDependent;
                                                                //section[rowParent+i]['controllingField'] = allFields[index].controllingField;                                                 
                                                            }
                                                            else if(allFields[index].isDependent){
                                                                section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                section[rowParent+i]['isDependent'] = allFields[index].isDependent;
                                                                //section[rowParent+i]['controllingField'] = allFields[index].controllingField;                                                 
                                                            }
                                                                else if(allFields[index].isControlling){
                                                                    section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                    section[rowParent+i]['dependentField'] = allFields[index].dependentField;
                                                                    section[rowParent+i]['isControlling'] = allFields[index].isControlling;
                                                                    section[rowParent+i]['PicklistValues'] = allFields[index].picklistValues;    
                                                                }
                                                                    else{
                                                                        section[rowParent+i]['PicklistValues'] = allFields[index].picklistValues;    
                                                                    }
                                                        }
                                                        else if(formDataType == 'Radio'){
                                                            section[rowParent+i]['PicklistValues'] = [];                          
                                                            if(allFields[index].isDependent && allFields[index].isControlling){
                                                                section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                section[rowParent+i]['dependentField'] = allFields[index].dependentField;
                                                                section[rowParent+i]['isControlling'] = allFields[index].isControlling;
                                                                section[rowParent+i]['isDependent'] = allFields[index].isDependent;
                                                                //section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                //section[rowParent+i]['controllingField'] = allFields[index].controllingField;      
                                                            }
                                                            else if(allFields[index].isControlling){
                                                                section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;  
                                                                section[rowParent+i]['dependentField'] = allFields[index].dependentField;
                                                                section[rowParent+i]['isControlling'] = allFields[index].isControlling;                                         
                                                                let radioPicklistValues = allFields[index].picklistValues;
                                                                for(let pickValue in radioPicklistValues){
                                                                    section[rowParent+i]['PicklistValues'].push({'value' :radioPicklistValues[pickValue], 'label' :radioPicklistValues[pickValue]});
                                                                }
                                                            }
                                                                else if(allFields[index].isDependent){
                                                                    
                                                                    //section[rowParent+i]['controllingField'] = allFields[index].controllingField;                                                 
                                                                }
                                                                    else{
                                                                        section[rowParent+i]['PicklistValues'] = [];
                                                                        let picklistValues = allFields[index].picklistValues;
                                                                        for(let pickValue in picklistValues){
                                                                            section[rowParent+i]['PicklistValues'].push({'value' :picklistValues[pickValue], 'label' :picklistValues[pickValue]});
                                                                        }
                                                                    }
                                                        }
                                                            else if(dataTypeValue == 'BOOLEAN'){
                                                                if($A.util.isUndefinedOrNull(section[rowParent+i]['value'])){
                                                                    section[rowParent+i]['value'] = false;
                                                                }
                                                            }
                                                            else if(dataTypeValue == 'TEXTAREA' || dataTypeValue == 'STRING'){
                                                                console.log(dataTypeValue+' mahendra test data type');
                                                                if($A.util.isUndefinedOrNull(section[rowParent+i]['lengthOfField'])){
                                                                    section[rowParent+i]['lengthOfField'] = lengthOfField;
                                                                }
                                                            }
                                                            else if(dataTypeValue == 'REFERENCE'){ //Added by Vidish
                                                                //alert('Inside AutoPopulate Reference'+component.get("v.recordId"));
                                                                    if($A.util.isUndefinedOrNull(section[rowParent+i]['value'])){
                                                                        if(section[rowParent+i]['ElixirSuite__Auto_Populate__c']){
                                                                  //         alert('inside AutoPopulate User' +section[rowParent+i]['ElixirSuite__Reference_to_object__c'])
                                                                            if(section[rowParent+i]['ElixirSuite__Reference_to_object__c'] == 'User'){
                                                                        section[rowParent+i]['value'] = $A.get("$SObjectType.CurrentUser.Id");
                                                                            }
                                                                            if(section[rowParent+i]['ElixirSuite__Reference_to_object__c'] == 'Account'){
                                                                          //alert('inside AutoPopulate Account' +component.get("v.recordId"));                                                                           
                                                                        section[rowParent+i]['value'] = component.get("v.recordId");
                                                                            }
                                                                           }
                                                                           }
                                                                
                                                                           
                                                                    
                                                                }
                                                            
                                                                else if(dataTypeValue == 'MULTIPICKLIST'){
                                                                    if($A.util.isUndefinedOrNull(section[rowParent+i]['value'])){
                                                                        section[rowParent+i]['value'] = [];
                                                                    }
                                                                    section[rowParent+i]['PicklistValues'] = [];
                                                                    if(allFields[index].isDependent){
                                                                        //let picklistValues = allFields[index].picklistValues;
                                                                        //section[rowParent+i]['DependentPicklistValues'] = allFields[index].controllingValueToDependentValues;                                                 
                                                                        //section[rowParent+i]['controllingField'] = allFields[index].controllingField;                              
                                                                    }
                                                                    else if(allFields[index].isControlling){
                                                                        let picklistValues = allFields[index].picklistValues;
                                                                        for(let pickValue in picklistValues){
                                                                            section[rowParent+i]['PicklistValues'].push({'value' :picklistValues[pickValue], 'label' :picklistValues[pickValue]});
                                                                        }
                                                                        section[rowParent+i]['isControlling'] = allFields[index].isControlling;   
                                                                        section[rowParent+i]['dependentField'] = allFields[index].dependentField;
                                                                    }else{
                                                                        let picklistValues = allFields[index].picklistValues;
                                                                        for(let pickValue in picklistValues){
                                                                            section[rowParent+i]['PicklistValues'].push({'value' :picklistValues[pickValue], 'label' :picklistValues[pickValue]});
                                                                        }
                                                                    }
                                                                    /** section[rowParent+i]['PicklistValues'] = [];
                                                let picklistValues = allFields[index].picklistValues;
                                                for(let pickValue in picklistValues){
                                                    section[rowParent+i]['PicklistValues'].push({'value' :picklistValues[pickValue], 'label' :picklistValues[pickValue]});
                                                }
                                                if($A.util.isUndefinedOrNull(section[rowParent+i]['value'])){
                                                    section[rowParent+i]['value'] = [];  
                                                } **/
                                                                    //section[row]['PicklistValues'] = allFields[index].picklistValues;
                                                                    
                                                                }
                                                        console.log('Picklist'+section[row]['PicklistValues']);
                                                        /*if(!$A.util.isUndefinedOrNull(section[parseInt(row)+parseInt(i)])
                                               && (currentRow == -1 || lcurrentRow == section[parseInt(row)+parseInt(i)].Row__c)){
                                                currentRow = section[parseInt(row)+parseInt(i)].Row__c;
                                                section[parseInt(row)+parseInt(i)]['colsize'] = helper.fetchColSize(parseInt(columnsInSection), colMap);
                                                section[row]['Columns'].push(JSON.parse(JSON.stringify(section[parseInt(row)+parseInt(i)])));
                                                console.log('section '+JSON.stringify(section[row]));
                                                rowAdd++;
                                            }*/
                                                        /*  if(rowAdd != columnsInSection){
                                            for(let i=0;i<columnsInSection-parseInt(rowAdd);i++){
                                                section[row]['Columns'].push({'Data_Type__c':'nbsp'});
                                            }
                                        }*/
                                                       }    
                                        var currentRow = -1;
                                        var sectionToPush = section[parseInt(row)+parseInt(i)];
                                        if(!$A.util.isUndefinedOrNull(sectionToPush)
                                           && (currentRow == -1 || currentRow == sectionToPush.ElixirSuite__Row__c)){
                                            currentRow = sectionToPush.ElixirSuite__Row__c;
                                            //Handling NO Label - START
                                            if(sectionToPush.ElixirSuite__No_Label__c){
                                                sectionToPush.ElixirSuite__Field_Label_Long__c = '';
                                            }
                                            //Handling NO Label - END
                                            sectionToPush['colsize'] = helper.fetchColSize(parseInt(columnsInSection), colMap);
                                            section[row]['Columns'].push(JSON.parse(JSON.stringify(sectionToPush)));
                                            console.log('section '+JSON.stringify(section[row]));
                                            rowAdd++;
                                        }
                                    }
                                    rowParent = parseInt(rowParent)+parseInt(rowAdd)-1;
                                }
                                //AUTO TEXT GENERATION - FINAL STRING MAKING - START
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
                                    else if(isAutoTextEnabled && $A.util.isUndefinedOrNull(cssRecords[record]['bluePrint'])){
                                        cssRecords[record].AutoText = cssRecords[record]['DefaultAutoText'];
                                    }
                                }catch(exe){
                                    alert(exe);
                                }
                                //AUTO TEXT GENERATION - FINAL STRING MAKING - END
                            }          
                        }
                        if (parseInt(component.get("v.numberOfImagesToLoad")) === 0) {
                            component.set("v.loaded",true);
                            }  
                     component.set("v.cssRecords", cssRecords);
                        
                }
            }else{
                    helper.showError(component, 'Css records are not retrieved');
                    component.set("v.loaded",true);
                    component.set("v.isOpen",false);
                }
            }else{
            var errorMsg = action.getError()[0].message;
            console.log('Error message ',errorMsg);
            helper.showError(component, 'Callback failed! Check console for error details');
            component.set("v.loaded",true);
            component.set("v.isOpen",false);
            }
        });
        $A.enqueueAction(action);   
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
    fetchColSize : function(columns, colMap){
        if(!$A.util.isUndefinedOrNull(colMap[columns])){
            return colMap[columns];
        }else{
            return 'slds-size_2-of-12';
        }
    },
    //TEXT Generator
    getBrackets : function(defaultText,section, helper){
        var bluePrints = helper.bracketsBuilder(defaultText);
        section['bluePrint'] = bluePrints;    
    },
    bracketsBuilder : function(defaultText){
        var bluePrints = [];
        while(defaultText.lastIndexOf("[") != -1){
            var extractedTextWithinBrackets = defaultText.substring(
                defaultText.lastIndexOf("[") + 1,
                defaultText.lastIndexOf("]")
            );
            let firstPart = defaultText.substr(0, defaultText.lastIndexOf("["));
            let lastPart = defaultText.substr(defaultText.lastIndexOf("]")+1);
            let textAfterExtraction = firstPart + lastPart;
            defaultText = textAfterExtraction;
            bluePrints.push(extractedTextWithinBrackets.replace( /(<([^>]+)>)/ig, ''));  
            
            // Create Blue Print Values
            
        }
        if(bluePrints.length>0){
            return bluePrints;
            //return bluePrints.reverse();
        }
    },
    createListForAutoText : function(separator,allFieldsInText,allValues){
        console.log('createListForAutoText START');
        let apiNames = allFieldsInText.split(separator);
        
        var finalValues = [];
        var count = 0;
        for(let idx in apiNames){
            console.log(apiNames[idx]);
            console.log('reached here',JSON.stringify(allValues));
            if(allValues.hasOwnProperty(apiNames[idx])){
                var dataToInsert = allValues[apiNames[idx]];
                if(separator == '+'){
                    count+= parseInt((dataToInsert == undefined||dataToInsert=="")?0:dataToInsert);
                }else if(separator == '*'){
                    count*= parseInt((dataToInsert == undefined||dataToInsert=="")?0:dataToInsert);
                }else if(separator == '@'){
                    console.log('@',dataToInsert);
                    finalValues.push(dataToInsert);
                }else{
                    dataToInsert = this.addSpacesWithinMultiSelect(dataToInsert);
                    finalValues.push(dataToInsert);
                }      
                console.log('$$$$'+dataToInsert);
            }
        }
        console.log('finalValues '+finalValues);      
        let finalString = '{';
        if(finalValues.length>0){
            finalString += finalValues.join(',\r');
        }else if(separator=='+' || separator =='*'){
            finalString += count;
        }
        finalString += '}';   
        console.log('createListForAutoText END');
        return finalString;
    },
    addSpacesWithinMultiSelect :function(dataToInsert){
        try{
            if(dataToInsert.length>0){
                var eachRec = [];
                dataToInsert.forEach(function(record){ 
                    if(eachRec.length != 0){
                        record = '\r'+record;
                    }
                    eachRec.push(record);
                });
            }        
            return eachRec.join(',');
        }catch(e){
            return dataToInsert;
        }
    },
    //TEXT Generator
    setBrackets : function(finalSetOfValues, section, helper){
        console.log('setBrackets START');
        let defaultAutoText = section['DefaultAutoText'];
        var receivedText = helper.autoTextBracketsBuilder(defaultAutoText, finalSetOfValues);
        console.log('setBrackets END');
        return receivedText; 
    },
    autoTextBracketsBuilder : function(finalText, finalSetOfValues){
        var bluePrints = [];
        let count = 0;
        while(finalText.lastIndexOf("[") != -1){
            var extractedTextWithinBrackets = finalText.substring(
                finalText.lastIndexOf("[") + 1,
                finalText.lastIndexOf("]")
            );
            let firstPart = finalText.substr(0, finalText.lastIndexOf("["));
            let lastPart = finalText.substr(finalText.lastIndexOf("]")+1);
            let textAfterExtraction = firstPart + ' ' + finalSetOfValues[count] + ' ' + lastPart;
            finalText = textAfterExtraction;
            count++;       
        }
        return finalText;
    },
    buildParentWrapperForExternalComponents : function (component , event , helper) {
        var wrapperExternalObjet = {'allergyData' : [],
                                    'allergyDataFormSpecific' : [],
                                    'glucoseData' : [],
                                    'glucoseDataFormSpecific' : [],
                                    'vitalSignsData': [],
                                    'vitalSignsDataFormSpecific' : []};
        component.set("v.ExternalcmpData",wrapperExternalObjet);
        var wrapperExternalAuraIf = {'allergyData' : false,
                                     'glucoseData' : false,
                                     'vitalSignsData': false};
        component.set("v.ExternalcmpParentAuraIf",wrapperExternalAuraIf);
        let sObjWrapper = {'insertedProcedure' : [],'updatedProcedure' : [],'toDelProcRecords' : []};
        component.set("v.procedureWrapper",sObjWrapper);
        console.log('ext comp data '+JSON.stringify(component.get("v.ExternalcmpData")));
        
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
        
       
        var action = component.get("c.allergyDataAcctSpeific");
        action.setParams({
            acctId: component.get("v.patientID"),
            notesSpecificData: JSON.stringify(component.get("v.notesSpecificData"))
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
                    toAddCol.push( { label: 'Substance Code', fieldName: 'ElixirSuite__Substance_Code__c', type: 'text',editable: false,sortable:true,});
                 
                 if(csColumns!=null){
                     component.set('v.parentallergyColumns', csColumns);
                     console.log('csColumns!null Allergy: '+csColumns);
                 }
                 if(csColumns==null){
                     csColumns = component.get('v.parentallergyColumns');
                     console.log('csColumnsisNull Allergy----'+csColumns);
                 }
             
                 let mapOfApiAndLabel =  {
                                             "Substance" :"Substance",
                                             "Reaction" :"Reaction",
                                              "Severity":"Severity",
                                             
                                            };   
                
                    
               /* console.log('csColumns----'+JSON.stringify(csColumns));
                if(!$A.util.isUndefinedOrNull(csColumns)){
                       const allTextColumns = ["Substance","Reaction","Severity"];
                        if(csColumns){
                            for(let recSObj in csColumns){
                                if(allTextColumns.includes(csColumns[recSObj])){
                                    toAddCol.push({ label: mapOfApiAndLabel[csColumns[recSObj]], 
                                                   fieldName: csColumns[recSObj], type: 'lookup',
                                                   editable: true,});  
                                }   
                            }
                        }   
                    })*/
                
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
                                        else if(reqType.value == 'REFERENCE'){
                                            toAddCol.push({
                                                label: label,
                                                fieldName: fieldName,
                                                type: 'REFERENCE',
                                                sortable:true,
                                                editable: false
                                            });
                                        }
                                            else {
                                                toAddCol.push({
                                                    label: label,
                                                    fieldName: fieldName,
                                                    type: reqType.value,
                                                    sortable: true,
                                                    editable: true
                                                });
                                            }
                                
                                
                                
                            } else {
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
                 
                 console.log('toAddCol for Allergy: '+toAddCol)
                 
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
    
    formAttributeDataUtility : function(component,serverResponse) {
        
        // A simple utility to arrange the data in a way to set the key as true/false if response has value and data key 
        // to hold the data; otherwise set key as false and set data key as an array.
        if(!$A.util.isEmpty(serverResponse)) {
            var compiledData  = {
                'hasValue'  : true,
                'data' : serverResponse,
                'dataFormSpecific' : []
            };
            console.log('DataBase '+typeof(compiledData));
            //component.set("v.medicationData",medicationData);
            console.log('compiled data in helper '+JSON.stringify(compiledData));
            
        }
        else {
            
            var compiledData  = {
                'hasValue'  : false,
                'data' : [],
                'dataFormSpecific' : []
            };
            //component.set("v.medicationData",medicationData);
            // console.log('medication inside else '+JSON.stringify(component.get("v.allergyData")));
            console.log('else compiled data '+JSON.stringify(compiledData));
            
            
        }
        
        return compiledData;
        
        
    },
    arrangeConditionDataAsParentChildv2 :  function(component,parentProblem,relatedProblemDaignoses,relatedNotes) {
        var nameSpace = 'ElixirSuite__';
        console.log('parent PROBLEM '+JSON.stringify(parentProblem));
        console.log('child Diagnoses '+JSON.stringify(relatedProblemDaignoses))
        console.log('child NOtes '+JSON.stringify(relatedNotes))
        var mastrJSON = [];
        var idx = 0;        
        if(!$A.util.isEmpty(parentProblem)) {           
            for (var parent in parentProblem) {                
                mastrJSON.push(parentProblem[parent]);
                mastrJSON[idx].problemIsChecked = true;
                mastrJSON[idx].isAddedFromTemplate = true; 
                mastrJSON[idx].description = '';         
                mastrJSON[idx].relatedDiagnoses = [];
                mastrJSON[idx].relatedNotes = [];
                mastrJSON[idx].alreadyExisting = true;
                
                if(!($A.util.isUndefinedOrNull(relatedProblemDaignoses[parent]) || $A.util.isEmpty(relatedProblemDaignoses))){
                    for(var childDiagnoses in relatedProblemDaignoses) {
                        if(relatedProblemDaignoses[childDiagnoses][nameSpace + 'Related_Problem__c']==parentProblem[parent].Id) {
                            relatedProblemDaignoses[childDiagnoses].diagnosesIsChecked=true;
                            relatedProblemDaignoses[childDiagnoses].alreadyExistingDaignoses=true;
                            mastrJSON[idx].relatedDiagnoses.push(relatedProblemDaignoses[childDiagnoses]);
                        }
                    }                                      
                }                     
                if(!($A.util.isUndefinedOrNull(relatedProblemDaignoses[parent]) || $A.util.isEmpty(relatedNotes))){
                    for(var childNotes in relatedNotes) {
                        if(relatedNotes[childNotes][nameSpace + 'Related_Problem__c']==parentProblem[parent].Id) {                              
                            relatedNotes[childNotes].alreadyExistingNotes=true;
                            mastrJSON[idx].relatedNotes.push(relatedNotes[childNotes]);
                        }
                    }                   
                }                   
                idx++;
                
            }
        }
        console.log('final 9000 '+JSON.stringify(mastrJSON));
        return mastrJSON;
        
    },
    allArrangementForproblemDiagnosis : function(component, event ,helper){
        var filterProblemDaignoses  = component.get("v.problemDiagnosesData").data;
        console.log('filterProblemDaignoses ' +JSON.stringify(filterProblemDaignoses));
        var diagnoseToDel = []; 
        var toUpdateNotesOnForm = [];
        var toUpdateRecordsOnForm = [];
        var toUpdateProblemsOnForm = [];
        var toInsertNewNote  = [];
        for (var filter in filterProblemDaignoses) {
            if(!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].relatedDiagnoses)){
                var insideArr = filterProblemDaignoses[filter].relatedDiagnoses;
                for(var diagnoses in insideArr){
                    if(!$A.util.isUndefinedOrNull(insideArr[diagnoses].isDeleted) && insideArr[diagnoses].isDeleted){
                        diagnoseToDel.push(insideArr[diagnoses].Id);
                    }
                }
            }
            if(!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isrelatedNotesUpdated) && filterProblemDaignoses[filter].isrelatedNotesUpdated){
                var relatedNotes  =  JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedNotes));                    
                toUpdateNotesOnForm=toUpdateNotesOnForm.concat(relatedNotes);  
            }
            if(!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isrelatedDiagnosesUpdated)  && filterProblemDaignoses[filter].isrelatedDiagnosesUpdated) {
                var relatedDiagnoses  =  JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedDiagnoses));                    
                toUpdateRecordsOnForm=toUpdateRecordsOnForm.concat(relatedDiagnoses);
            }
            if(!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].isproblemRecordUpdatedFormCreateNewTab)  && filterProblemDaignoses[filter].isproblemRecordUpdatedFormCreateNewTab) {                     
                toUpdateProblemsOnForm.push(filterProblemDaignoses[filter]);
            }
            if(!$A.util.isUndefinedOrNull(filterProblemDaignoses[filter].toInsertNewNote)  && filterProblemDaignoses[filter].toInsertNewNote) {
                var relatedNotesNew  =  JSON.parse(JSON.stringify(filterProblemDaignoses[filter].relatedNotes));  
                toInsertNewNote=toInsertNewNote.concat(relatedNotesNew);
            }
        }
        
        
        
        
        var  s =  {"keysToSave":filterProblemDaignoses,'AccountId' : component.get("v.patientID")  };
        console.log('keys to save rtoyoy '+(JSON.stringify(s)));
        console.log('to update problem records on form '+(JSON.stringify(toUpdateProblemsOnForm)));
        var toUpdateProblemRecordsOnForm = {'daignosesRecord' : toUpdateRecordsOnForm};
        var finalStringToReturn = {'diagnoseToDel' : diagnoseToDel,
                                   'toUpdateNotesOnForm' : toUpdateNotesOnForm,
                                   'toUpdateRecordsOnForm': toUpdateRecordsOnForm,
                                   'toUpdateProblemsOnForm':toUpdateProblemsOnForm,
                                   'toInsertNewNote' : toInsertNewNote,
                                   'problemDaignosesDataToSave' : JSON.stringify(s),
                                   'toUpdateProblemRecordsOnForm' : JSON.stringify(toUpdateProblemRecordsOnForm),
                                   'problemToDel' : component.get("v.CustomProblemToDel")
                                  };
        console.log('problem return sucess '+JSON.stringify(finalStringToReturn));
        return JSON.stringify(finalStringToReturn);
        
    },
    allArrangementsForMedicationData : function(component, event ,helper) {   
        var finalStringFormedication = {'selectedUser' : component.get("v.selectedUser"),
                                        'selectedVia' :component.get("v.selectedVia"),                            
                                        'medicationJSON':JSON.stringify(component.get("v.medicationJSON"))
                                       };
        console.log('medication return sucess '+finalStringFormedication);
        return JSON.stringify(finalStringFormedication);
    },
    //added by Anmol for LX3-5770
    fetchNspc: function (component, event, helper) {
        var action = component.get("c.fetchNameSpace");
          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                 component.set("v.orgWideValidNamespace",response.getReturnValue());
              }
              else {
                      console.log("failure for namespace");
              }
                });
          },
          //end by Anmol for LX3-5770

                  //added by Anmol for LX3-6263
    fetchCustomSett: function (component, event, helper) {
        var action = component.get("c.fetchCustomSettingsPrescription");
          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for fetchCustomSettingsPrescription",result);
                if(result == 'Dummy Prescription'){

                    component.set("v.prescButton" , true);

                }
                 
              }
              else {
                      console.log("failure for namespace");
              }
                });
                $A.enqueueAction(action);
          },
          //end by Anmol for LX3-6263

    medicationDataJSON : function(component,serverResponse) {
        var nameSpace = 'ElixirSuite__';
        //Medication data comes from 2 diffrent object;
        //This function arranges them in a single JSON 
        //This concatinates the value of child data into one and put it as new key; and delete that existing key      
        if(!$A.util.isEmpty(serverResponse.data)) {            
            var rows  = serverResponse.data;
            for (var i = 0; i < rows.length; i++) {                
                var row = rows[i];
                console.log('row 1234 ' + JSON.stringify(row));
                if (row[nameSpace+'Frequency__r'] != undefined && row[nameSpace+'Frequency__r'].length != 0 &&
                    row[nameSpace+'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'] != undefined) {                   
                    console.log('inside if');
                    var str = row[nameSpace+'Frequency__r'][0][nameSpace + 'Repeat__c'];
                    if(!$A.util.isUndefinedOrNull(str)){
                        if (str.startsWith('\'n\' times')) {                       
                            var str2 = str;
                            console.log('str2'+JSON.stringify(str2));
                            var str3 = row[nameSpace+'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                            console.log('str3'+JSON.stringify(str3));
                            var str4 = str2.replace("\'n\'", str3);                                              
                            row[nameSpace + 'Frequency__c'] = str4;
                            delete row[nameSpace+'Frequency__r'];
                            
                        } else if (str.startsWith('After every')) {
                            var str5 = str;
                            var str6 = row[nameSpace+'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                            var str7 = str5.replace("\'n\'", str6);
                            row[nameSpace + 'Frequency__c'] = str7;
                            delete row[nameSpace+'Frequency__r'];                       
                        }
                    }
                    else {
                        row[nameSpace + 'Frequency__c'] = '--';
                    }
                }
            }
        }
        console.log('medication ready '+JSON.stringify(serverResponse));
        return serverResponse;
        
    },
    deleteProblemsIfAny : function(component, event ,helper) {   
        console.log('medication ready '+JSON.stringify( component.get("v.procedureWrapper").insertedProcedure));
        var action = component.get('c.deleteAllProblemSavedFromForm');
        action.setParams({recIds : component.get("v.insertedProblem"),
                          procedureId : component.get("v.procedureWrapper").insertedProcedure,
                         });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
            }
        });
        $A.enqueueAction(action);    
    },
    setProblemData : function(component, event ,helper) {   
        let probArr = component.get("v.toUpdateProblem");
        let arr = [];
        for(let rec in probArr){
            arr.push({'keysToSave' : probArr[rec]});
        }
        component.set("v.toUpdateProblem",arr);
    },
    
    saveStaticImage : function(component) {
        // find all static image wrapper component
        var staticImageWrappers = component.find("staticImageWrapperChild");
        if (staticImageWrappers) {
            // let's find out how many staticImageWrapper are there
            var totalStaticImageWrapper = staticImageWrappers.length;
            
            if (totalStaticImageWrapper) {
                // there is more than one static image wrapper
                for (var i=0; i<totalStaticImageWrapper; i++) {
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
    saveConsentText : function(component) {
        var childComponents = component.find("consent_text");
        if (childComponents) {
            // let's find out how many staticImageWrapper are there
            var childComponentWrapper = childComponents.length;
            
            if (childComponentWrapper) {
                // there is more than one dynamic image wrapper
                for (var i=0; i<childComponentWrapper; i++) {
                    childComponents[i].childMessageMethod();
                }
            }
            else {
                // there is only one dynamic image wrapper
                childComponents.childMessageMethod();
            }
            
        }
    },
    saveDynamicImage : function(component) {
        console.log("inside saveDynamicImage");
        // find all static image wrapper component
        var dynamicImageWrappers = component.find("dynamicImageWrapperChild");
        if (dynamicImageWrappers) {
            // let's find out how many staticImageWrapper are there
            var totalDynamicImageWrapper = dynamicImageWrappers.length;
            
            if (totalDynamicImageWrapper) {
                // there is more than one dynamic image wrapper
                for (var i=0; i<totalDynamicImageWrapper; i++) {
                    dynamicImageWrappers[i].fetchDataToSend();
                }
            }
            else {
                // there is only one dynamic image wrapper
                dynamicImageWrappers.fetchDataToSend();
            }
            
        }
        // else {
        //     console.log("no dynamic image wrappers found");
        // }
        
    },
    findDependentField : function(component ,column,cssRecords,controllerValue) {
        var column = column;
        var isControlling = column.isControlling;
        if(column.value != '' && isControlling){        
            var controllerValue = controllerValue;
            var dependentField = column.dependentField;
            var pickListMap = column.DependentPicklistValues;           
            if (controllerValue != '--- None ---') {        
                var childValues = pickListMap[controllerValue];  
                console.log('childValues '+childValues);
                if($A.util.isUndefinedOrNull(childValues)){
                    childValues = [];
                }
                var childValueList = [];
                //childValueList.push('--- None ---');
                for (var i = 0; i < childValues.length; i++) {
                    childValueList.push(childValues[i]);
                }
                //Code to populate dependent field values
                var radioList = [];
                for(let section in cssRecords){
                    let rows = cssRecords[section].ElixirSuite__Object_1_css__r;
                    for(let row in rows){
                        let columns = rows[row].Columns;
                        for(let column in columns){
                            if(columns[column].ElixirSuite__Field_Name__c === dependentField){
                                if(columns[column].ElixirSuite__Form_Data_Type__c == 'Radio'){
                                    for(let child in childValueList){
                                        let obj = {'value' : childValueList[child], 'label' : childValueList[child]};  
                                        radioList.push(obj);                                        
                                    }
                                    console.log('radioList '+radioList);
                                    columns[column]['PicklistValues'] = radioList;    
                                }
                                else if(columns[column].ElixirSuite__Data_Type__c == 'MULTIPICKLIST'){
                                    let multiList = [];
                                    for(let child in childValueList){
                                        let obj = {'value' : childValueList[child], 'label' : childValueList[child]};  
                                        multiList.push(obj);                                        
                                    }
                                    console.log('multipickList '+multiList);
                                    columns[column]['PicklistValues'] = multiList;    
                                }           
                                    else{
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
                component.set("v.getDisabledChildField" , true);
            }
            component.set("v.cssRecords",cssRecords);
        }
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    runValidationForms : function(component, event, helper) {
        var flag = true;
        if(component.get("v.enableTime")){
           let timeObj = component.get("v.timeWrapper");
        if(!timeObj.endTime){
            component.set("v.showConfirmDialog",true);
            flag = false;
        }  
        }
        
       
        return flag;
    },
    savecreatedForm :  function(component, event, helper) {
        try{
            // save images of all staticImageWrappers
            helper.saveStaticImage(component);
            
            // save images of all dynamicImageWrappers
            helper.saveDynamicImage(component);
            helper.saveConsentText(component);
            console.log('to delt update ids '+component.get("v.toDelProblemFromUpdate"));          
            helper.setProblemData(component, event, helper);
            console.log('to  update ids '+JSON.stringify(component.get("v.toUpdateProblem")));        
            
            var cssRecords = component.get("v.cssRecords");
            console.log('recordsToSave'+JSON.stringify(cssRecords));
            console.log('procedureWrapper'+JSON.stringify(component.get("v.procedureWrapper")));
            var action = component.get("c.saveForm");
            component.set("v.loaded",false);
            var timeObj = component.get("v.timeWrapper");
            if(new Date(timeObj.startTime).setSeconds(0, 0) == new Date(timeObj.endTime).setSeconds(0, 0)){
                console.log('time equal');
                timeObj.paramSame = true;
            }
            
            component.set("v.timeWrapper",timeObj);
            // alert(component.get("v.isProblemEnabled"));

            let modularMatrixDataToSend;
            if (JSON.stringify(component.get("v.modularMatrixData")) == "{}") {
                modularMatrixDataToSend = "";
            }
            else {
                modularMatrixDataToSend = JSON.stringify(component.get("v.modularMatrixData"));
            }

            console.log('sending modular matrix data: ', modularMatrixDataToSend);

            action.setParams({ 'accountId' : component.get("v.recordId"),
                              'changedFormName' : component.get("v.changedFormName"),
                              'category' :component.get("v.category"),
                              'formName' : component.get("v.formName"),
                              'cssRecords' : JSON.stringify({'cssRecords' :cssRecords}),
                              'problemData' :  '',//helper.allArrangementForproblemDiagnosis(component, event ,helper),
                              'precriptionData' : helper.allArrangementsForMedicationData(component, event ,helper),
                              'deletedProblem' : component.get("v.deletedProblem"),
                              'toDelProblemFromUpdate' :  component.get("v.toDelProblemFromUpdate"),
                              'toUpdateProblem' :  JSON.stringify(component.get("v.toUpdateProblem")),
                              'isProblemEnabled' : component.get("v.isProblemEnabled"),
                              'procedureWrapper' : JSON.stringify(component.get("v.procedureWrapper")),
                              'isProcedureEnabled' : component.get("v.isProcedureEnabled"),
                              'timeWrapper' : JSON.stringify(component.get("v.timeWrapper")),
                              'isTimeEnabled' :   component.get("v.enableTime"),
                              'modularMatrixData' : modularMatrixDataToSend,
                              'toUpdateNotesSpecific' :  JSON.stringify(component.get("v.notesSpecificData"))
                             });
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                console.log('result form unique id '+result);
                var state = response.getState();
                console.log('STATE ',state);
                if (state === "SUCCESS") {  
                    const formApp = component.find('formApprovalId'); 
                    //console.log('Inside Success Save '+formApp +'  ' +result);
                    formApp.saveSign(result);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Form Saved Successfully"
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire();
                  //  window.location.reload();
                    component.set("v.loaded",true);
                    try{
                        /*** PASS THE SAVED FOR  ID TO EXTERNAL COMPONENTS FOR THEIR SAVING****************/
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

                        if(component.get("v.isActualNotes")){
                            component.set("v.customCategory",[]);
                        }
                    }catch(e){
                        console.log('Vital error!!'+e);   
                    }
                    console.log('After event ###');
                    var appEvent = $A.get("e.c:FormsRefreshEvt");
                    appEvent.setParams({"route" : "forRefresh",
                                        "formUniqueId" : result}); 
                    appEvent.fire();
                    
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
                    evt.fire(); /*
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log('Error in closing the tab: '+error);
                    });*/
                    var appEvent = $A.get("e.c:CloseAllNotesTab"); 
                    console.log('Close Event Fired!!!')
                    appEvent.fire();
                    component.set("v.isOpen",false);
                    
                    /**********************************************************************************/
                    
                    
                    
                } 
                else {
                    var errors = response.getError();
                    if (errors) {
                        console.log("Error occured while saving form: " + JSON.stringify(errors));

                        if (errors[0] && errors[0].message) {
                            helper.showError(component, errors[0].message);
                        }
                        else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0].message) {
                            helper.showError(component, errors[0].pageErrors[0].statusCode + ": " + errors[0].pageErrors[0].message);
                        }
                        else {
                            helper.showError(component, "FORM_FAILED_TO_SAVE: Check browser console for details");
                        }
                    }
                    else {
                        helper.showError(component, `UNKNOWN_ERROR: Response State is ${response.getState()}`);
                    }
                    component.set("v.loaded",true);
                }
            });
            $A.enqueueAction(action);   
        }
        catch(e){
            alert(e);
        } 
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