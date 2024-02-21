({
    doInit : function(component, event, helper) {
        console.log('patient id '+JSON.stringify(component.get("v.patientID")));
        var dataMap = {};
     
        component.set("v.parentSelectedValues",dataMap);
        var inputDataMap = {};
        component.set("v.parentinputSelectedValues",inputDataMap);
        var inputTextAreadataMap = {};
        component.set("v.inputTextAreaSelectedValues",inputTextAreadataMap);
        var inputDateTimedataMap = {};
        component.set("v.inputDateTimeselectedValues",inputDateTimedataMap);
        var today = new Date();
        component.set('v.todayString', today.toISOString());
        var action = component.get("c.getFormFields");
        var formId = component.get("v.formId");
        var accountId = component.get("v.patientID");
        action.setParams({ formId : component.get("v.formId"),
                          acctId : component.get("v.patientID"),
                          intOffSet : 0
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
                //alert(data);
                //console.log('parent problem  '+JSON.stringify(resp.listOfconditionData));
                //console.log('rel diagnoses  '+JSON.stringify(resp.listOfRelatedDaignoses));
                //console.log('rel notes '+ JSON.stringify(resp.listOfrelatedNotes));
                // console.log('resp list of vital data'+ JSON.stringify(resp.mapOfObservationData.vitalData));
                component.set("v.showDetail",resp.allFields);
                component.set("v.nameSpace",resp.nameSpace);
                //component.set("v.showDetail1",resp.allFields);
                if(!$A.util.isUndefinedOrNull(resp.allFields[0][0].ElixirSuite__Form__r.Name)) {
                    component.set("v.formName",resp.allFields[0][0].ElixirSuite__Form__r.Name);
                }
                console.log('show detail value New'+JSON.stringify( component.get("v.showDetail"))+component.get("v.showDetail").length);
                //component.set("v.multiPicklistValues",resp.multiPicklistValues);
                //component.set("v.physicalTherapist",resp.listOfUsers);
                //component.set("v.currentUser",resp.currentUser); 
                //var compiledData = 
               // helper.arrangeConditionDataAsParentChild(component,resp.parentProblems,resp.relatedProblemDaignoses,resp.relatedNotesMap);  
               var compltedArrangedData  = 
                    helper.arrangeConditionDataAsParentChildv2(component,resp.listOfconditionData,resp.listOfRelatedDaignoses,resp.listOfrelatedNotes); 
                component.set("v.problemDiagnosesData", helper.formAttributeDataUtility(component,compltedArrangedData));
               // console.log('problem diagnoses data filtered '+JSON.stringify(component.get("v.problemDiagnosesData")));
                component.set("v.allergyData",helper.formAttributeDataUtility(component,resp.listOfAllergy));
               component.set("v.glucoseData",helper.formAttributeDataUtility(component,resp.mapOfObservation.glucoseData));
                
                var medicationBuffer  = helper.formAttributeDataUtility(component,resp.listOfMedication);
                component.set("v.medicationData",helper.medicationDataJSON(component,medicationBuffer));
                //console.log('after medicatiuoin data');
                component.set("v.vitalSignsData",helper.formAttributeDataUtility(component,resp.mapOfObservation.vitalData));
                //console.log('vital data '+JSON.stringify( component.get("v.vitalSignsData")));
                console.log('kk related diagnosis '+JSON.stringify(resp.listOfRelatedDaignoses));
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
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    closeModel : function(component, event, helper) {
        console.log('attach IDs '+JSON.stringify(component.get("v.currentlyUploadedDocumetIDs")));
        if(!$A.util.isUndefinedOrNull(component.get("v.currentlyUploadedDocumetIDs"))){
            var action = component.get("c.deleteFiles");
            action.setParams({ sdocumentId : component.get("v.currentlyUploadedDocumetIDs") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {        
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }
        component.set("v.isOpen1",false);
    },
    Save	: function(component, event, helper) {
        
       var valid = true;
       valid = helper.helperMethod(component, valid);
         if(valid){
        console.log('type of medication '+typeof(component.get("v.medicationJSON")));
        console.log('type of user '+typeof(component.get("v.selectedUser")));
        console.log('type of via '+typeof(component.get("v.selectedVia")));
        console.log('save cmp');
        var data = component.get("v.parentSelectedValues");
        var glucoseDataToSave = component.get("v.glucoseData");
        var vitalSignsDataToSave = component.get("v.vitalSignsData");
        console.log('FORM ID '+JSON.stringify(component.get("v.formId")));
        var prob  = component.get("v.problemDiagnosesData");
        
        var filterAllergydata =  component.get("v.allergyData");
        if(!$A.util.isEmpty(filterAllergydata.data)) {
            component.set("v.allergyDataToSave",filterAllergydata.data);
        }
        console.log('glucose to save'+JSON.stringify(component.get("v.glucoseData")));
        console.log("the attachment id" , JSON.stringify(component.get("v.medicationJSON")));
        console.log('all data after set'+JSON.stringify(component.get("v.allergyDataToSave")));
        console.log('save cmp' +JSON.stringify(data));
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
        console.log('to update problem records on form '+(JSON.stringify(toUpdateProblemsOnForm)));
        var toUpdateProblemRecordsOnForm = {'daignosesRecord' : toUpdateRecordsOnForm};
        var action = component.get("c.saveForm");
       
        console.log(component.get('v.todayString'));
        console.log(component.get('v.endString'));
        console.log('to update notes'+JSON.stringify(toUpdateNotesOnForm));
           console.log('to insert notes'+JSON.stringify(toInsertNewNote));
        console.log('to delete records '+component.get('v.toDeleteRecordsOnForm'));
        //var jsProblem = {'keysToSave' :component.get("v.problemDiagnosesData") };
        //  jsProblem['keysToSave'] = component.get("v.problemDiagnosesData");
        
       // if(valid == true){
             component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setParams({ formId : component.get("v.formId"),
                              dataSelected : JSON.stringify(component.get("v.parentSelectedValues")),
                              inputDataSelected	:	JSON.stringify(component.get("v.parentinputSelectedValues")),
                              inputTextAreaSelected : JSON.stringify(component.get("v.inputTextAreaSelectedValues")),
                              inputDateSelectedValues :  JSON.stringify(component.get("v.inputDateselectedValues")),
                              inputDateTimeselectedValues :  JSON.stringify(component.get("v.inputDateTimeselectedValues")),
                              allergyDataToInsert : component.get("v.allergyDataToSave"),
                              accountId : component.get("v.patientID"),
                              jsonList : JSON.stringify(component.get("v.medicationJSON")),
                              selectedUser : component.get("v.selectedUser"),
                              selectedVia: component.get("v.selectedVia"),
                              glucoseDataToSave : glucoseDataToSave.data,
                              vitalSignsDataToSave : vitalSignsDataToSave.data,
                              problemDaignosesDataToSave :  JSON.stringify(s),
                              attachId : component.get("v.attachId"),
                              commentSign : component.get("v.signComment"),
                              starttimeProcedure :component.get('v.todayString'),
                              endtimeProcedure : component.get('v.endString'),
                              sendEmailRequest : component.get('v.formName'),
                              toUpdateProblemRecordsOnForm :  JSON.stringify(toUpdateProblemRecordsOnForm),
                              toDeleteRecordsOnForm : component.get('v.toDeleteRecordsOnForm'),
                              toUpdateNotes : toUpdateNotesOnForm,
                              diagnoseToDel : diagnoseToDel,
                              problemToDel : component.get("v.CustomProblemToDel"),
                              toUpdateProblemsOnForm : toUpdateProblemsOnForm,
                              toInsertNewNote : toInsertNewNote,
                              allNotes : JSON.stringify(component.get('v.allCreateNotes'))
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    console.log('success');
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "success",
                            "title": "FORM CREATED SUCCESSFULLY!",
                            "message": "The form has been created successfully."
                        });
                        toastEvent.fire();
                   	var cmpEvent = component.getEvent("changehandlerEvent"); 
                    //Set event attribute value
                    cmpEvent.fire();
                   
                    var createEvent = component.getEvent("RefreshViewEvent");
                   // createEvent.setParams({ "message": '' });
                    createEvent.fire();
                    
                    component.set("v.isOpen1",false);
                }else{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        
    }
        
        
    },
    handleConfirmDialogNo :  function(component, event, helper){
        component.set("v.showConfirmDialog",false);
    },
    handleConfirmDialogYes :  function(component, event, helper){
        helper.saveInHelper (component,true);
    },
    showVerifyOtp :  function(component, event, helper){
        console.log("dfghjk" ,component.get("v.accName.passCode"));
        if( $A.util.isUndefinedOrNull(component.get("v.accName.passCode")) ){
            alert('You do not have the appropriate access, please contact your administrator');
        }
        else{
            component.set("v.verifyOtp",true);    
            component.set("v.showSign",false);
        }
        
    },
    deleteSelectedRows: function(component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id' + JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        helper.deleteSelectedHelper(component, event, helper ,selectedIds);
    },
    handleMedicationDataEventForSaving :  function(component, event, helper){
        component.set("v.medicationJSON",event.getParam("jsonList"));
        component.set("v.selectedUser",event.getParam("selectedUser")) ;
        component.set("v.selectedVia",event.getParam("selectedVia")) ;
        
    },
    onCheck: function(component, event, helper) {
        if(component.get("v.isRestrict") ==true){
            component.set("v.isRestricted", true);
        }
        else{
            component.set("v.isRestricted", true);
            
        }
    },
    onCancel: function(component, event, helper) {
        component.set("v.isRestricted", false);
        component.set("v.isRestrict", false);
    },
    onSubmit: function(component, event, helper) {
        var action = component.get( 'c.Uinfo' );
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(component.get("v.isRestrict") ==true){
                    var isValidate ;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                        if(userNameVal == res.ElixirSuite__Verification_Code__c){
                            userName.set("v.errors",null);
                            isValidate = true;
                        }else{
                            userName.set("v.errors",[{message:'Invalid Key!!'}]);
                        }
                    }
                    
                    if(isValidate){
                        component.set("v.isRestricted", false);
                        component.set("v.RestrictButtons", true);
                        
                        component.set("v.SecurityKeys", "");
                    }
                }
                else{
                    var isValidate ;
                    var userName = component.find('userName');
                    var userNameVal = component.find('userName').get('v.value');        
                    if($A.util.isUndefinedOrNull(userNameVal) || $A.util.isUndefined(userNameVal) || $A.util.isEmpty(userNameVal)){
                        userName.set("v.errors",[{message:'Please Enter the Key!!'}]);
                        isValidate = false;
                    }else{
                        if(userNameVal == res.ElixirSuite__Verification_Code__c){
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
    parentComponentEvent : function(component , event , helper){
        console.log('att id' , event.getParam("attachementId"));
        var attId = event.getParam("attachementId"); 
        var commentSign = event.getParam("signComment");
        var dateToday = event.getParam("dateToday");
        component.set("v.signComment" , 'Notes : ' + ' ' + commentSign);
        component.set("v.attachId" , '/servlet/servlet.FileDownload?file='+attId);
        component.set("v.dateTodayForForm" , 'Signed on : ' + ' ' + dateToday );
        console.log('the val is' , component.get("v.attachId"));
    },
    
    
    callMethod :  function(component, event, helper){
      //  alert('hi');
        if(component.get('v.runScroll') == true){
            component.set('v.runScroll') == false;
            helper.OnScrollCall(component, event,helper);
        }
        
    }
    /* patientOTP	:  function(component, event, helper){
        var action = component.get("c.getPassCode");
        action.setParams({ formId : component.get("v.formId"),
                          accountId : component.get("v.patientID")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var resp = response.getReturnValue();
               // console.log('success '+JSON.stringify(resp.imgId));              
               // component.set("v.passCode",resp.passCode);
               // component.set("v.imgId",resp.imgId);                
                component.set("v.verifyOtp",true);    
                component.set("v.showSign",false);
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
        
    }*/
})