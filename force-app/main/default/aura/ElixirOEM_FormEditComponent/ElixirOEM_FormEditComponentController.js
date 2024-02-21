({
    
    init: function(component, event, helper) {
        component.set('v.todayString', new Date().toISOString());
        component.set("v.endString",'');
        var dt = {'date1' : '', 'date2': '', 'date3':''};
        component.set("v.AllDates",dt);
        var nameSpace = 'ElixirSuite__';
      
        var action3 = component.get("c.getFormData");
        
        component.find("Id_spinner").set("v.class", 'slds-show');
        action3.setParams({
            formId: component.get("v.PresId"),
            acctId: component.get("v.recordVal"),
            intOffSet: 0
        });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class", 'slds-hide');
                var resp = response.getReturnValue();
                console.log('show  sign val', JSON.stringify(component.get("v.showSign")));
                console.log('resp list of allergy' + JSON.stringify(resp));
                console.log('allFields list' + JSON.stringify(resp.allFields));
                component.set("v.showDetail", resp.allFields);
                console.log('show detail value Edit'+JSON.stringify( component.get("v.showDetail"))+component.get("v.showDetail").length);
               component.set("v.userVerifyCode", resp.userVerifyCode); 
                component.set("v.formData", resp.formData[0]);
                console.log('form Data ' + JSON.stringify(resp.formData[0]));
                component.set("v.verifyCode", resp.VerficationCode);
                component.set("v.allCreateNotes", resp.relatedNotesNew);  
               component.set("v.userSignatureVerifyCode", resp.userSignatureVerifyCode);  
                component.set("v.multiPicklistValues", resp.multiPicklistValues);
                component.set("v.physicalTherapist", resp.listOfUsers);
                component.set("v.currentUser", resp.currentUser);
                component.set("v.AccountDetails", resp.acctDetails[0]);
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Approval_Values1__c'])) {
                    component.set("v.ApprovalValue1", resp.formData[0][nameSpace + 'Approval_Values1__c']);
                    component.set("v.level1ApprovalValid", true);
                } else {
                    component.set("v.ApprovalValue1", '');
                    component.set("v.level1ApprovalValid", false);
                }
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Approval_Values_2__c'])) {
                    component.set("v.ApprovalValue2", resp.formData[0][nameSpace + 'Approval_Values_2__c']);
                    component.set("v.level2ApprovalValid", true);
                } else {
                    component.set("v.ApprovalValue2", '');
                    component.set("v.level2ApprovalValid", false);
                }
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Approval_Values_3__c'])) {
                    component.set("v.ApprovalValue3", resp.formData[0][nameSpace + 'Approval_Values_3__c']);
                    component.set("v.level3ApprovalValid", true);
                } else {
                    component.set("v.ApprovalValue3", '');
                    component.set("v.level3ApprovalValid", false);
                }
                component.set("v.signatureValue", resp.signatureValues);
                component.set("v.allergyData", helper.formAttributeDataUtility(component, resp.listOfAllergy));
                var compltedArrangedData = helper.arrangeConditionDataAsParentChildv2(component, resp.listOfconditionData, resp.listOfRelatedDaignoses, resp.listOfrelatedNotes);
                component.set("v.problemDiagnosesData", helper.formAttributeDataUtility(component, compltedArrangedData));
                var medicationBuffer = helper.formAttributeDataUtility(component, resp.listOfMedication);
                component.set("v.vitalSignsData",helper.formAttributeDataUtility(component,resp.mapOfObservation.vitalData));
                component.set("v.glucoseData",helper.formAttributeDataUtility(component,resp.mapOfObservation.glucoseData));
                component.set("v.medicationData", helper.medicationDataJSON(component, medicationBuffer));
                console.log('medication in parent ' + JSON.stringify(component.get("v.medicationData")));
                console.log('kk' + JSON.stringify(resp));
                  console.log('kk related diagnosis '+JSON.stringify(resp.listOfRelatedDaignoses));
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Signature_value_1__c'])) {
                    component.set("v.attachId", resp.formData[0][nameSpace + 'Signature_value_1__c']);
                    component.set("v.signComment1", resp.formData[0][nameSpace + 'Comment_1__c']);
                    component.set("v.signee1", resp.formData[0][nameSpace + 'Signed_By_Level_1__c']);
                    component.set("v.dateTodayForForm1", resp.formData[0][nameSpace + 'Signed_Date_1__c']);
                    component.set("v.newSign", true);
                }
                else {
                    component.set("v.newSign", false);
                    component.set("v.showSign" , true);
                }
                
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Signature_value_2__c'])) {
                    component.set("v.attachId2", resp.formData[0][nameSpace + 'Signature_value_2__c']);
                    component.set("v.signComment2", resp.formData[0][nameSpace + 'Comment_2__c']);
                    component.set("v.signee2", resp.formData[0][nameSpace + 'Signed_By_Level_2__c']);
                    component.set("v.dateTodayForForm2", resp.formData[0][nameSpace + 'Signed_Date_2__c'])
                    component.set("v.newSign2", true);
                    component.set("v.showSignLevel2", false);
                    component.set("v.showSignLevel3", true);
                }
                else {
                    component.set("v.newSign2", false);
                    component.set("v.showSignLevel2", true);
                }
                
                if (!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Signature_value_3__c'])) {
                    component.set("v.attachId3", resp.formData[0][nameSpace + 'Signature_value_3__c']);
                    component.set("v.signComment3", resp.formData[0][nameSpace + 'Comment_3__c']);
                    component.set("v.signee3", resp.formData[0][nameSpace + 'Signed_By_Level_3__c']);
                    component.set("v.dateTodayForForm3", resp.formData[0][nameSpace + 'Signed_Date_3__c'])
                    component.set("v.newSign3", true);
                    
                }
                else if(!$A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Signature_value_2__c'])){
                    component.set("v.newSign3", false);
                    component.set("v.showSignLevel3", true);
                }
                    else if($A.util.isUndefinedOrNull(resp.formData[0][nameSpace + 'Signature_value_2__c'])){
                        component.set("v.newSign3", false);
                        component.set("v.showSignLevel3", false);
                    }
                
                console.log('the new values are', component.get("v.attachId"));     
            } else {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action3);
        
        
        
        
    },
    
    handleMedicationDataEventForSaving :  function(component, event, helper){
        component.set("v.medicationJSON",event.getParam("jsonList"));
        component.set("v.selectedUser",event.getParam("selectedUser")) ;
        component.set("v.selectedVia",event.getParam("selectedVia")) ;
        
    },
    closeModel: function(component, event, helper) {
        component.set("v.editScreen", false);
        component.set("v.showDetail", '');
        
    },
    
    procedureValidity: function(component, event, helper) {
        var valid = true;
        valid = helper.helperMethod(component, valid);
    },
    showVerifyOtp: function(component, event, helper) {
        if ($A.util.isUndefinedOrNull(component.get("v.accName.passCode"))) {
            component.set("v.ErrorMessage", true);
        } else {
            component.set("v.verifyOtp", true);
            component.set("v.showSign", false);
        }
        
    },
    
    CloseSave: function(component, event, helper) {
        
       var valid = true;
       valid = helper.helperMethod(component, valid);
        if(valid){
        var getCompiledDataForProblemDiagnosis = helper.complieProblemDaignosisDataAsEditForUpdate(component, event, helper);
        var vitalSignsDataToSave = component.get("v.vitalSignsData");
        var glucoseDataToSave = component.get("v.glucoseData");
        var filterAllergydata =  component.get("v.allergyData");
        var objetDate = component.get("v.AllDates");
        component.set("v.dateTodayForForm1",objetDate.date1);
        component.set("v.dateTodayForForm2",objetDate.date2);
        component.set("v.dateTodayForForm3",objetDate.date3);
        if(!$A.util.isEmpty(filterAllergydata.data)) {
            component.set("v.allergyDataToSave",filterAllergydata.data);
        }
        console.log('prob data '+JSON.stringify(getCompiledDataForProblemDiagnosis));
        var data = component.get("v.parentSelectedValues");
        var wrapper = {'allergy':component.get("v.allergyDataToSave"),'vital':vitalSignsDataToSave.data,
                       'toInsertNewNote': getCompiledDataForProblemDiagnosis.toInsertNewNote,
                       'prescriptionData' :  JSON.stringify(component.get("v.medicationJSON"))};
        
          var wrapperToDebug = {'allergy':component.get("v.allergyDataToSave"),'vital':vitalSignsDataToSave.data,
                       'toInsertNewNote': getCompiledDataForProblemDiagnosis.toInsertNewNote,
                       'prescriptionData' :  component.get("v.medicationJSON")};
        
        
        
        var finalwrapperToSend  = {'collectiveKey':wrapper};
        console.log('my wrapper 567 '+JSON.stringify(wrapperToDebug));
        var action = component.get("c.saveEditForm");
         console.log('to update problem records on form '+(JSON.stringify(getCompiledDataForProblemDiagnosis.toUpdateProblemsOnForm)));
        console.log('pisv ' + JSON.stringify(component.get("v.parentSelectedValues")));
        //  alert(JSON.stringify(component.get('v.allCreateNotes')));
       // if (valid == true) {
            component.find("Id_spinner").set("v.class", 'slds-show');
            action.setParams({
                formId: component.get("v.PresId"),
                dataSelected: JSON.stringify(component.get("v.parentSelectedValues")),
                inputDataSelected: JSON.stringify(component.get("v.inputSelectedValues")),
                inputTextAreaSelected: JSON.stringify(component.get("v.inputTextAreaSelectedValues")),
                inputDateSelectedValues: JSON.stringify(component.get("v.inputDateselectedValues")),
                inputDateTimeselectedValues: JSON.stringify(component.get("v.inputDateTimeselectedValues")),
                starttimeProcedure: component.get('v.todayString'),
                endtimeProcedure: component.get('v.endString'),
                accountId: component.get("v.recordVal"),
                toUpdateProblemRecordsOnForm : JSON.stringify(getCompiledDataForProblemDiagnosis.toUpdateProblemRecordsOnForm),
                toDeleteRecordsOnForm : component.get('v.toDeleteRecordsOnForm'),
                toUpdateNotes : getCompiledDataForProblemDiagnosis.toUpdateNotesOnForm,
                diagnoseToDel : getCompiledDataForProblemDiagnosis.diagnoseToDel,
                 
                problemToDel : component.get("v.CustomProblemToDel"),
                toUpdateProblemsOnForm :getCompiledDataForProblemDiagnosis.toUpdateProblemsOnForm,
                toInsertNewNote : getCompiledDataForProblemDiagnosis.toInsertNewNote,
                problemDaignosesDataToSave:JSON.stringify(getCompiledDataForProblemDiagnosis.problemDaignosesDataToSave),
                vitalSignsDataToSave : vitalSignsDataToSave.data, 
                wrapper : JSON.stringify(wrapper),
                glucoseDataToSave : glucoseDataToSave.data,
                allergyDataToInsert : component.get("v.allergyDataToSave"),
                "signatureComment1": component.get("v.signComment1"), //signaturecomment
                "signeeName1": component.get("v.signee1"),
                "signatureDate1": component.get("v.dateTodayForForm1"),
                "signatureImage1": component.get("v.attachId"),
                
                "signatureComment2": component.get("v.signComment2"), //signaturecomment
                "signeeName2": component.get("v.signee2"),
                "signatureDate2": component.get("v.dateTodayForForm2"),
                "signatureImage2": component.get("v.attachId2"),
                
                "signatureComment3": component.get("v.signComment3"), //signaturecomment
                "signeeName3": component.get("v.signee3"),
                "signatureDate3": component.get("v.dateTodayForForm3"),
                "signatureImage3": component.get("v.attachId3"),
                
                "approvalLevel": component.get("v.LevelOfApproval"),
                "allNotes" : JSON.stringify(component.get('v.allCreateNotes'))
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class", 'slds-show');
                    //$A.get('e.force:refreshView').fire();
                    console.log('success');
                       var refreshevt = component.getEvent("RefreshUAListView"); 
                    refreshevt.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success",
                        "title": "FORM UPDATED SUCCESSFULLY!",
                        "message": "The form has been updated successfully."
                    });
                    toastEvent.fire();
                    
                    component.set("v.editScreen",false);
                      component.set("v.RefreshList",'Refresh');
                    
                    
                } else {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    console.log('failure');
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        
        }
        
    },
    callMethod: function(component, event, helper) {
        
        if (component.get('v.runScroll') == true) {
            component.set('v.runScroll') == false;
            helper.OnScrollCall(component, event, helper);
        }
        
    },
    closeModel1: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isOpen1", false);
        
    },
    patientSignProcess: function(component, event, helper) {
        //component.set("v.AccountDetails.Signature_Attachment_Id__c", 'IDFRFR');
        console.log("dfghjk", component.get("v.verifyCode"));
        var level1Approvers = component.get("v.ApprovalValue1");
        var verficationCode = component.get("v.verifyCode");
        var action = component.get("c.getCurrentlyLoggedInUser");
        console.log('pisv ' + JSON.stringify(component.get("v.getCurrentlyLoggedInUser")));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var level1Approvers  =  component.get("v.ApprovalValue1");
                // level1Approvers = level1Approvers
                if (!$A.util.isUndefinedOrNull(level1Approvers)) {
                    if (level1Approvers.includes('Patient')) {
                        if ($A.util.isUndefinedOrNull(component.get("v.verifyCode"))) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "OTP code is not yet generated for the Patient.",
                                "message": "Please contact your administrator."
                            });
                            toastEvent.fire();
                            
                            
                        } else if ($A.util.isUndefinedOrNull(component.get("v.AccountDetails.ElixirSuite__Signature_Attachment_Id__c"))) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "warning",
                                "title": "Signature is not yet captured",
                                "message": "Please register your signature first!"
                            });
                            toastEvent.fire();
                            
                        } else {
                            component.set("v.verifyOtp", true);
                            component.set("v.LevelOfApproval", 'Level1');
                        }
                        
                    } else {
                        var roles = level1Approvers.split(",");
                        //roles.push('Development Team');
                        var res = response.getReturnValue();
                        if (roles.includes(res)) {
                            console.log("user code ", component.get("v.userVerifyCode"));
                            if ($A.util.isUndefinedOrNull(component.get("v.userVerifyCode"))) {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "OTP code is not yet generated for the User.",
                                    "message": "Please contact your administrator."
                                });
                                toastEvent.fire();
                            } else if ($A.util.isUndefinedOrNull(component.get("v.userSignatureVerifyCode"))) {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "warning",
                                    "title": "Signature is not yet captured",
                                    "message": "Please register your signature first!"
                                });
                                toastEvent.fire();
                                
                            } else {
                                
                                component.set("v.loggedInUserRole", res);
                                component.set("v.verifyOtp", true);
                                component.set("v.LevelOfApproval", 'Level1');
                                component.set("v.verifyCode", component.get("v.userVerifyCode")),
                                    component.set("v.sObjectName", 'User');
                            }
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "warning",
                                "message": "You do not have the appropriate access, please contact your administrator"
                            });
                            toastEvent.fire();
                        }
                    }
                }
            } else {
                console.log('failure');
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    parentComponentEvent: function(component, event, helper) {
        if(event.getParam("cancelKey") != 'isCancelled')
        {
        console.log('att id', event.getParam("signeeName"));
        var attId = event.getParam("attachementId");
        var commentSign = event.getParam("signComment");
        var checkUndefined = event.getParam("dateToday");
        var dateToday = '';
        if(!$A.util.isUndefinedOrNull(checkUndefined)){
            var toPassDate = JSON.parse(JSON.stringify(event.getParam("dateToday")));
            dateToday = helper.convertDate(component,toPassDate);
        }
        else {
            dateToday = '';
        }
        
        // var dateToday = event.getParam("dateToday");
        var button = event.getParam("showButton");
        var signName = event.getParam("signeeName");
        var val = '-';
        var button1 = event.getParam("showButton1");
        var levelOfApproval = event.getParam("approvalLevel");
        var getParentDateVariable= component.get("v.AllDates");
        if (levelOfApproval == 'Level1') {
            if ($A.util.isUndefinedOrNull(commentSign)) {
                component.set("v.signComment1", val);
            } else {
                component.set("v.signComment1", commentSign);
            }
            component.set("v.attachId", '/servlet/servlet.FileDownload?file=' + attId);
            getParentDateVariable['date1'] = event.getParam("dateToday");
            component.set("v.dateTodayForForm1", dateToday);
            var getsObjectName = component.get("v.sObjectName");
            if (getsObjectName == 'User') {
                component.set("v.signee1", signName + ' (' + component.get("v.loggedInUserRole") + ')');
            } else {
                component.set("v.signee1", signName + '(Patient)');
            }
            console.log('the val is', component.get("v.signComment"));
            component.set("v.showSign", button);
            component.set("v.newSign", button1);
            component.set("v.sObjectName" , 'Account');
            //  component.set("v.showSignLevel2", true);
        }
        
        if (levelOfApproval == 'Level2') {
            if ($A.util.isUndefinedOrNull(commentSign)) {
                component.set("v.signComment2", val);
            } else {
                component.set("v.signComment2", commentSign);
            }
            component.set("v.attachId2", '/servlet/servlet.FileDownload?file=' + attId);
            
            getParentDateVariable['date2'] = event.getParam("dateToday");
            component.set("v.dateTodayForForm2", dateToday);
            var getsObjectName = component.get("v.sObjectName");
            if (getsObjectName == 'User') {
                component.set("v.signee2", signName + ' (' + component.get("v.loggedInUserRole") + ')');
            } else {
                component.set("v.signee2", signName + '(Patient)');
            }
            console.log('the val is', component.get("v.signComment"));
            console.log('hu2hei', button + ' ' + button1);
            component.set("v.showSignLevel2", false);
            component.set("v.newSign2", button1);
            component.set("v.sObjectName" , 'Account');
            // component.set("v.showSignLevel3", true);
        }
        if (levelOfApproval == 'Level3') {
            if ($A.util.isUndefinedOrNull(commentSign)) {
                component.set("v.signComment3", val);
            } else {
                component.set("v.signComment3", commentSign);
            }
            component.set("v.attachId3", '/servlet/servlet.FileDownload?file=' + attId);
            getParentDateVariable['date3'] = event.getParam("dateToday");
            component.set("v.dateTodayForForm3", dateToday);
            var getsObjectName = component.get("v.sObjectName");
            if (getsObjectName == 'User') {
                component.set("v.signee3", signName + ' (' + component.get("v.loggedInUserRole") + ')');
            } else {
                component.set("v.signee3", signName + '(Patient)');
            }
            console.log('the val is', component.get("v.signComment"));
            console.log('hu3hei', button + ' ' + button1);
            component.set("v.showSignLevel3", false);
            component.set("v.newSign3", button1);
            component.set("v.sObjectName" , 'Account');
        }
    }
        else {
            component.set("v.LevelOfApproval", '');
        }
        
    },
    primaryTherapistProcess: function(component, event, helper) {
        helper.approvalProcessForLevel2(component, event, helper);
    },
    clinicalSupervisorSignProcess: function(component, event, helper) {
        helper.approvalProcessForLevel3(component, event, helper);
    },
    
    
})