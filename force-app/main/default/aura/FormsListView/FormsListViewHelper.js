({
    formAttributeDataUtility : function(component,serverResponse) {
        
        // A simple utility to arrange the data in a way to set the key as true/false if response has value and data key 
        // to hold the data; otherwise set key as false and set data key as an array.
        if(!$A.util.isEmpty(serverResponse)) {
            var compiledData  = {
                'hasValue'  : true,
                'data' : serverResponse
            };
            console.log('DataBase '+typeof(compiledData));
            //component.set("v.medicationData",medicationData);
            console.log('compiled data in helper '+JSON.stringify(compiledData));
            
        }
        else {
            
            var compiledData  = {
                'hasValue'  : false,
                'data' : []
            };
            //component.set("v.medicationData",medicationData);
            // console.log('medication inside else '+JSON.stringify(component.get("v.allergyData")));
            console.log('else compiled data '+JSON.stringify(compiledData));
            
            
        }
        
        return compiledData;
        
        
    },
    
    medicationDataJSON : function(component,serverResponse) {
        var nameSpace = component.get("v.nameSpace") ;
        //Medication data comes from 2 diffrent object;
        //This function arranges them in a single JSON 
        //This concatinates the value of child data into one and put it as new key; and delete that existing key      
        if(!$A.util.isEmpty(serverResponse.data)) {            
            var rows  = serverResponse.data;
            for (var i = 0; i < rows.length; i++) {                
                var row = rows[i];
                console.log('row 1234 ' + JSON.stringify(row));
                if (row['Frequency__r'] != undefined && row['Frequency__r'].length != 0 &&
                    row['Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'] != undefined) {                   
                    console.log('inside if');
                    var str = row['Frequency__r'][0][nameSpace + 'Repeat__c'];
                       if(!$A.util.isUndefinedOrNull(str)){
                    if (str.startsWith('\'n\' times')) {                       
                        var str2 = str;
                        console.log('str2'+JSON.stringify(str2));
                        var str3 = row['Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                        console.log('str3'+JSON.stringify(str3));
                        var str4 = str2.replace("\'n\'", str3);                                              
                        row[nameSpace + 'Frequency__c'] = str4;
                        delete row['Frequency__r'];
                        
                    } else if (str.startsWith('After every')) {
                        var str5 = str;
                        var str6 = row['Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                        var str7 = str5.replace("\'n\'", str6);
                        row[nameSpace + 'Frequency__c'] = str7;
                        delete row['Frequency__r'];                       
                    }
                       }
                    else {
                         row[nameSpace + 'Frequency__c'] = '--';
                    }
                }
            }
        }
        return serverResponse;
  
    },
      deleteSelectedHelper: function(component, event, helper, selectedIds) {
        
        var action = component.get( 'c.deleteAllForms' );
        action.setParams({
            "lstRecordId": selectedIds,
        });
        console.log("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                  helper.initFunctionMovedToHelper(component, event, helper);              
            } else if (state === "ERROR") {
                
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
    
    arrangeConditionDataAsParentChildv2 :  function(component,parentProblem,relatedProblemDaignoses,relatedNotes) {
         var nameSpace = 'ElixirSuite__' ;
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
                        if(relatedProblemDaignoses[childDiagnoses][nameSpace + 'Dataset1__c']==parentProblem[parent].Id) {
                            relatedProblemDaignoses[childDiagnoses].diagnosesIsChecked=true;
                            relatedProblemDaignoses[childDiagnoses].alreadyExistingDaignoses=true;
                            mastrJSON[idx].relatedDiagnoses.push(relatedProblemDaignoses[childDiagnoses]);
                        }
                    }                                      
                }                     
                if(!($A.util.isUndefinedOrNull(relatedProblemDaignoses[parent]) || $A.util.isEmpty(relatedNotes))){
                    for(var childNotes in relatedNotes) {
                        if(relatedNotes[childNotes][nameSpace + 'Dataset1__c']==parentProblem[parent].Id) {                              
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
    saveInHelper :  function(component) {
        
    },
        helperMethod : function(component , valid) {
            var procedureStartCmp = component.find("procedure-start_time");
            var strtProcedureTime = procedureStartCmp.get('v.value');
            var procedureEndCmp = component.find("procedure-end_time");
            var endProcedureTime = procedureEndCmp.get('v.value');
            if(! ($A.util.isUndefinedOrNull(endProcedureTime) || $A.util.isUndefinedOrNull(strtProcedureTime))){
                var today = new Date();
                if(strtProcedureTime>endProcedureTime){         
                    procedureEndCmp.setCustomValidity("End date cannot be less than start date");
                    procedureEndCmp.reportValidity();
                    valid = false;
                }
                else{
                    procedureEndCmp.setCustomValidity("");
                    procedureEndCmp.reportValidity()
                }
                var dte = new Date(strtProcedureTime);
                if((dte.setDate(dte.getDate()+1) <today)){
                    procedureStartCmp.setCustomValidity("Start date cannot be less than today");
                    procedureStartCmp.reportValidity();
                    valid = false;
                    console.log('ss');
                }    
            }else{
                valid = false;
                procedureEndCmp.setCustomValidity("Complete this field");
                procedureEndCmp.reportValidity();
            }
            return valid;
        },
  OnScrollCall : function(component, event, helper) {
        console.log('scroll');
        /*var dataMap = {};
        debugger;
        component.set("v.parentSelectedValues",dataMap);
        var inputDataMap = {};
        component.set("v.parentinputSelectedValues",inputDataMap);
        var inputTextAreadataMap = {};
        component.set("v.inputTextAreaSelectedValues",inputTextAreadataMap);
        var inputDateTimedataMap = {};
        component.set("v.inputDateTimeselectedValues",inputDateTimedataMap);
        */
        var today = new Date();
        component.set('v.todayString', today.toISOString());
        var action = component.get("c.getFormFields");
        var formId = component.get("v.formId");
        console.log('kk'+component.get('v.showDetail').length);
        var currentData = component.get('v.showDetail');
        var z=[] ;
        currentData.forEach(n => z.push(n.length));
        var sum = z.reduce(function(a, b){
            return a + b;
        }, 0);
      
        var accountId = component.get("v.patientID");
        action.setParams({ formId : component.get("v.formId"),
                          acctId : component.get("v.patientID"),
                          intOffSet : sum
                         });
        action.setStorable({
            ignoreExisting: true
        });
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {  
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var resp = response.getReturnValue();
                //component.set('v.runScroll',resp.runScroll);
                component.set("v.dynamicOffset",resp.dynamicOffset);
                console.log(resp.dynamicOffset);
                console.log('parent problem  '+JSON.stringify(resp.listOfconditionData));
                console.log('rel diagnoses  '+JSON.stringify(resp.listOfRelatedDaignoses));
                console.log('rel notes '+ JSON.stringify(resp.listOfrelatedNotes));
                // console.log('resp list of vital data'+ JSON.stringify(resp.mapOfObservationData.vitalData));
                //var currentData = component.get('v.showDetail1');                
                //component.set("v.showDetail", currentData.concat(resp.allFields));
                /*var data1 =resp.allFields;
                delete data1[0];
                var filterdata = data1.filter(function( element ) {
                    return element !== null;
                });
                currentData.push(filterdata);
                console.log('delete data  '+JSON.stringify(data1));*/
                var data = resp.allFields;
                data.splice(0,1);
                var filterdata = data.filter(function( element ) {
                    return element !== null;
                });
                var oldData = component.get("v.showDetail");
                var newData = oldData.concat(filterdata);
                component.set("v.showDetail",newData);
                var isProblemDataUpdated  =  component.get("v.problemDiagnosesData");
                var isAllergyDataUpdated = component.get("v.allergyData");
                var isGlucoseDataUpdated = component.get("v.glucoseData");
                var isMedicationDataUpdated = component.get("v.medicationData");
                var isVitalDataUpdated = component.get("v.vitalSignsData");
                /* if(!$A.util.isUndefinedOrNull(resp.allFields[0][0].Form__r.Name)) {
                 component.set("v.formName",resp.allFields[0][0].Form__r.Name);
                }*/
                console.log('show detail value '+JSON.stringify( component.get("v.showDetail")));
                component.set("v.multiPicklistValues",resp.multiPicklistValues);
                component.set("v.physicalTherapist",resp.listOfUsers);
                component.set("v.currentUser",resp.currentUser);
                //var compiledData =
                // helper.arrangeConditionDataAsParentChild(component,resp.parentProblems,resp.relatedProblemDaignoses,resp.relatedNotesMap);  
                var compltedArrangedData  =
                    helper.arrangeConditionDataAsParentChildv2(component,resp.listOfconditionData,resp.listOfRelatedDaignoses,resp.listOfrelatedNotes);
                if($A.util.isUndefinedOrNull(isProblemDataUpdated)) {
                    component.set("v.problemDiagnosesData", helper.formAttributeDataUtility(component,compltedArrangedData));
                }
                console.log('problem diagnoses data filtered '+JSON.stringify(component.get("v.problemDiagnosesData")));
                if($A.util.isUndefinedOrNull(isAllergyDataUpdated)) {
                    component.set("v.allergyData",helper.formAttributeDataUtility(component,resp.listOfAllergy));
                }
                if($A.util.isUndefinedOrNull(isGlucoseDataUpdated)) {
                    component.set("v.glucoseData",helper.formAttributeDataUtility(component,resp.mapOfObservation.glucoseData));
                }
                var medicationBuffer  = helper.formAttributeDataUtility(component,resp.listOfMedication);
                if($A.util.isUndefinedOrNull(isMedicationDataUpdated)) {
                    component.set("v.medicationData",helper.medicationDataJSON(component,medicationBuffer));
                }
                console.log('after medicatiuoin data');
                  if($A.util.isUndefinedOrNull(isVitalDataUpdated)) {
                component.set("v.vitalSignsData",helper.formAttributeDataUtility(component,resp.mapOfObservation.vitalData));
                  }
                console.log('vital data '+JSON.stringify( component.get("v.vitalSignsData")));
                console.log('kk'+JSON.stringify(resp));
            }else{
               
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
           
        });
        $A.enqueueAction(action);
    },
    
    
})