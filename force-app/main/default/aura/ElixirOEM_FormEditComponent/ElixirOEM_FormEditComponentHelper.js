({
    helperMethod : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == ''){
            endProcedureTime = null;
        }
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
    formAttributeDataUtility : function(component,serverResponse) {
        
        
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

            console.log('else compiled data '+JSON.stringify(compiledData));
            
            
        }
        
        return compiledData;
        
        
    },
    
    convertDate : function(component,stringdate) {
        var finalRet  = stringdate.split("/");
        var yyyy  = finalRet[2];
        var mm  = finalRet[1];
        var dd = finalRet[0];
        var today = yyyy +'-'+ mm +'-' + dd ;
        return today;
    },
    
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
                if (row['ElixirSuite__Frequency__r'] != undefined && row['ElixirSuite__Frequency__r'].length != 0 &&
                    row['ElixirSuite__Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'] != undefined) {                   
                    console.log('inside if');
                    var str = row['ElixirSuite__Frequency__r'][0][nameSpace + 'Repeat__c'];
                       if(!$A.util.isUndefinedOrNull(str)){
                    if (str.startsWith('\'n\' times')) {                       
                        var str2 = str;
                        console.log('str2'+JSON.stringify(str2));
                        var str3 = row['ElixirSuite__Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                        console.log('str3'+JSON.stringify(str3));
                        var str4 = str2.replace("\'n\'", str3);                                              
                        row[nameSpace + 'ElixirSuite__Frequency__c'] = str4;
                        delete row['ElixirSuite__Frequency__r'];
                        
                    } else if (str.startsWith('After every')) {
                        var str5 = str;
                        var str6 = row['ElixirSuite__Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                        var str7 = str5.replace("\'n\'", str6);
                        row[nameSpace + 'ElixirSuite__Frequency__c'] = str7;
                        delete row['ElixirSuite__Frequency__r'];                       
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
                        if(relatedProblemDaignoses[childDiagnoses][nameSpace + 'Dataset1__c']==parentProblem[parent].Id) {
                            relatedProblemDaignoses[childDiagnoses].diagnosesIsChecked=true;
                            relatedProblemDaignoses[childDiagnoses].alreadyExistingDaignoses=true;
                            // console.log('icd code '+relatedProblemDaignoses[childDiagnoses].ICD_Codes__c);
                            mastrJSON[idx].relatedDiagnoses.push(relatedProblemDaignoses[childDiagnoses]);
                        }
                    }                                      
                }                     
                if(!($A.util.isUndefinedOrNull(relatedNotes[parent]) || $A.util.isEmpty(relatedNotes))){
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
    OnScrollCall : function(component, event, helper) {
        var action3 = component.get("c.getFormData");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var currentData = component.get('v.showDetail');
        var z=[] ;
        currentData.forEach(n => z.push(n.length));
        var sum = z.reduce(function(a, b){
            return a + b;
        }, 0);
       
         console.log('kk'+component.get('v.showDetail').length);
        action3.setParams({ formId :component.get("v.PresId"),
                           acctId : component.get("v.recordVal"),
                           intOffSet : sum 
                          });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var resp = response.getReturnValue();
                component.set("v.dynamicOffset",resp.dynamicOffset);
                console.log(resp.dynamicOffset);
                console.log('resp list of allergy'+ JSON.stringify(resp));
                console.log('allFields list'+ JSON.stringify(resp.allFields));
                var data = resp.allFields;
                data.splice(0,1);
                var filterdata = data.filter(function( element ) {
                    return element !== null;
                });
                var oldData = component.get("v.showDetail");
                var newData = oldData.concat(filterdata);
                component.set("v.showDetail",newData);
                var isProblemDataUpdated  =  component.get("v.problemDiagnosesData");
                var isAllergyDataUpdated =	component.get("v.allergyData");
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
                //	helper.arrangeConditionDataAsParentChild(component,resp.parentProblems,resp.relatedProblemDaignoses,resp.relatedNotesMap);  
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
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action3);
    },
    
    approvalProcessForLevel2 :  function(component,event,helper){
        var level2Approvers  =  component.get("v.ApprovalValue2");       
        var verficationCode  = component.get("v.verifyCode");
        var action = component.get("c.getCurrentlyLoggedInUser");
        console.log('pisv '+JSON.stringify(component.get("v.getCurrentlyLoggedInUser")));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if(!$A.util.isUndefinedOrNull(level2Approvers) ){
                    if(level2Approvers.includes('Patient')){
                        if($A.util.isUndefinedOrNull(component.get("v.verifyCode")) ){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "OTP code is not yet generated for the Patient.",
                                "message":    "Please contact your administrator."
                            });
                            toastEvent.fire();
                            
                            
                        }
                        else if($A.util.isUndefinedOrNull(component.get("v.AccountDetails.ElixirSuite__Signature_Attachment_Id__c")) ){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "Signature is not yet captured",
                                "message":    "Please register your signature first!"
                            });
                            toastEvent.fire();
                            
                        }
                            else {
                                component.set("v.verifyOtp",true);    
                                component.set("v.LevelOfApproval" , 'Level2');
                            }           
                        
                    }
                    else {
                        var roles  = level2Approvers.split(",");
                        // roles.push('Development Team');
                        var res = response.getReturnValue(); 
                           console.log("logged in user role "+JSON.stringify(res));
                        if(roles.includes(res)){
                            console.log("user code " ,component.get("v.userVerifyCode"));
                            if($A.util.isUndefinedOrNull(component.get("v.userVerifyCode")) ){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "OTP code is not yet generated for the User.",
                                    "message":    "Please contact your administrator."
                                });
                                toastEvent.fire();  
                            }
                            else if($A.util.isUndefinedOrNull(component.get("v.userSignatureVerifyCode"))){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "Signature is not yet captured",
                                    "message":    "Please register your signature first!"
                                });
                                toastEvent.fire();
                                
                            }
                                else {
                                    
                                    component.set("v.loggedInUserRole",res);
                                    component.set("v.verifyOtp",true);    
                                    component.set("v.LevelOfApproval" , 'Level2');
                                    component.set("v.verifyCode" ,component.get("v.userVerifyCode")),
                                        component.set("v.sObjectName" , 'User');
                                }
                        }
                        else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "warning",
                                "message": "You do not have the appropriate access, please contact your administrator"
                            });
                            toastEvent.fire();
                        }
                    }
                }   
            }else{
                console.log('failure');
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action);
        
    },
    approvalProcessForLevel3 :  function(component,event,helper){
        console.log("dfghjk" ,component.get("v.verifyCode"));
        var level3Approvers  =  component.get("v.ApprovalValue3");       
        var verficationCode  = component.get("v.verifyCode");
        var action = component.get("c.getCurrentlyLoggedInUser");
        console.log('pisv '+JSON.stringify(component.get("v.getCurrentlyLoggedInUser")));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                //var level3Approvers  =  component.get("v.ApprovalValue3");
                // level3Approvers = level3Approvers
                if(!$A.util.isUndefinedOrNull(level3Approvers) ){
                    if(level3Approvers.includes('Patient')){
                        if($A.util.isUndefinedOrNull(component.get("v.verifyCode")) ){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "OTP code is not yet generated for the Patient.",
                                "message":    "Please contact your administrator."
                            });
                            toastEvent.fire();
                            
                            
                        }
                        else if($A.util.isUndefinedOrNull(component.get("v.AccountDetails.ElixirSuite__Signature_Attachment_Id__c")) ){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "Signature is not yet captured",
                                "message":    "Please register your signature first!"
                            });
                            toastEvent.fire();
                            
                        }
                            else {
                                component.set("v.verifyOtp",true);    
                                component.set("v.LevelOfApproval" , 'Level3');
                            }           
                        
                    }
                    else {
                        var roles  = level3Approvers.split(",");
                        // roles.push('Development Team');
                        var res = response.getReturnValue();        
                        if(roles.includes(res)){
                            console.log("user code " ,component.get("v.userVerifyCode"));
                            if($A.util.isUndefinedOrNull(component.get("v.userVerifyCode")) ){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "OTP code is not yet generated for the User.",
                                    "message":    "Please contact your administrator."
                                });
                                toastEvent.fire();  
                            }
                            else if($A.util.isUndefinedOrNull(component.get("v.userSignatureVerifyCode"))){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "Signature is not yet captured",
                                    "message":    "Please register your signature first!"
                                });
                                toastEvent.fire();
                                
                            }
                                else {
                                    
                                    component.set("v.loggedInUserRole",res);
                                    component.set("v.verifyOtp",true);    
                                    component.set("v.LevelOfApproval" , 'Level3');
                                    component.set("v.verifyCode" ,component.get("v.userVerifyCode")),
                                        component.set("v.sObjectName" , 'User');
                                }
                        }
                        else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "warning",
                                "message": "You do not have the appropriate access, please contact your administrator"
                            });
                            toastEvent.fire();
                        }
                    }
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title": "Approval Roles for LEVEL 3 is not defined for this form",
                        "message":    "Define LEVEL 3 approval roles first!"
                    });
                    toastEvent.fire();
                }   
            }else{
                console.log('failure');
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action);
    },
    
    complieProblemDaignosisDataAsEditForUpdate : function(component, event, helper){
        var arrForProblemDiagnoses  = [];
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
        var toUpdateProblemRecordsOnForm = {'daignosesRecord' : toUpdateRecordsOnForm};
        var finalKey = {'diagnoseToDel' : diagnoseToDel,
                        'toUpdateNotesOnForm' : toUpdateNotesOnForm,
                        'toUpdateRecordsOnForm' : toUpdateRecordsOnForm,
                        'toUpdateProblemsOnForm' : toUpdateProblemsOnForm,
                        'toInsertNewNote' : toInsertNewNote,
                        'toUpdateProblemRecordsOnForm' : toUpdateProblemRecordsOnForm,
                        'problemDaignosesDataToSave' :s};
        return finalKey;
    }
    
    
})