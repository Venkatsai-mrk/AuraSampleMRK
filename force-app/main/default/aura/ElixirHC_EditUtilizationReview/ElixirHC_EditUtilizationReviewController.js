({
    doInit : function(component, event, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');  
        console.log('reocrd  Value   ' + JSON.stringify(component.get("v.recordValue")));
        
        console.log('inside UR REVIEW CREATE');      
        var readWriteOrEditmode = component.get("v.viewflag");
        if(!readWriteOrEditmode){
            component.set("v.OpenAsMode",'EDIT');
        }
        var action = component.get("c.getAllDataForUtilizationReview");
        action.setParams({ accountId : component.get("v.patientID"),
                          currentlyViewedRecord : component.get("v.recordValue")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
             //   console.log('date type set  ' + JSON.stringify(response.getReturnValue().acctRecord.Admit_Date__c));
                console.log('Master UR  data '+JSON.stringify(response.getReturnValue()));                
                component.set("v.masterDataForUR",response.getReturnValue());
                component.set("v.birthDate" , response.getReturnValue().patBirthDate);
                component.set("v.PatientDetails",response.getReturnValue().acctRecord);
                component.set("v.allProgrmsOffered",response.getReturnValue().lstOfProgramsOffered);
                component.set("v.allProblemsForPatient",response.getReturnValue().allProblemsForPatient);
                 component.set("v.purchasePlan",response.getReturnValue().allVOBDetails);
                component.set("v.planBenifit",response.getReturnValue().allVOBDetails);
                component.set("v.carePreAuth",response.getReturnValue().allVOBDetails);
                component.set("v.memberPlan",response.getReturnValue().allVOBDetails);
                component.set("v.VOBDetails",response.getReturnValue().allVOBDetails);
                component.set("v.PatientProblem",response.getReturnValue().allProblemsForPatient);
                component.set("v.ProcedureInfo",response.getReturnValue().allProcedure);
                component.set("v.recordDetail",response.getReturnValue().allDiagonsis);

                  //Added by Anmol for LX3-5960
                  var prob = component.get("v.PatientProblem");
                  var proced = component.get("v.ProcedureInfo");
                  var diag = component.get("v.recordDetail");
  
                  console.log('proced****',proced.length);
                  if(prob.length==0){
                      component.set("v.checkTableSizeOfProblem",true);
                  }
                  if(proced.length==0){
                      component.set("v.checkTableSizeOfProcedure",true);
                  }
                  if(diag.length==0){
                      component.set("v.checkTableSizeOfDiagnosis",true);
                  }
                  //End by Anmol for LX3-5960

               // component.set("v.ProcedureInfo",response.getReturnValue().Procedurevar);
              // component.set("v.NextReviewDate",component.get("v.UtilizationRecordToSave.ElixirSuite__Date_Time_of_Review__c"));
                // component.find("a_opt").set("v.value", accounts[4].Id);
               if(!$A.util.isEmpty(response.getReturnValue().lastCreatedReview)){
                    component.set("v.showLastReviewInfo",true);
                   	component.set("v.lastCreatedReview",response.getReturnValue().lastCreatedReview[0]); 
                } 
                else {
                    component.set("v.showLastReviewInfo",false);
                }
                var finalQNAmapLst = response.getReturnValue().finalQNAmapLst;
                var myQuestionsAnswers = response.getReturnValue().myQuestionsAnswersLst;
                
                var arrQNA = [];
                for(var rec in myQuestionsAnswers){
                    var QNAkeys = {'ques' : '',
                                   'ans' : ''};
                    if(!$A.util.isUndefinedOrNull(finalQNAmapLst[myQuestionsAnswers[rec].Id])){
                        var q = finalQNAmapLst[myQuestionsAnswers[rec].Id];
                        //  var updatedQ = q.substring(q.indexOf(">")+1);
                        // var fUpdated = updatedQ.substring(0, updatedQ.indexOf("<"));
                        QNAkeys.ques = q;
                        QNAkeys.ans = myQuestionsAnswers[rec]['ElixirSuite__Text__c'];
                        arrQNA.push(QNAkeys);
                    }
                }               
                //component.set("v.data", records);preAssesAnswers  
                component.set("v.preAssesAnswers", arrQNA); 
                helper.getUtilizationRecordForEdit(component, event, helper,component.get("v.recordValue"));
                //helper.arrangeVOBData(component,response.getReturnValue().lstOfPlanBenifit,response.getReturnValue().lstOfCarePreAuth,
                // response.getReturnValue().lstOfMemberPlan,response.getReturnValue().lstOfPurchasePlan);
                /* records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });*/
                
                //  component.set("v.data", records);
                // component.set("v.IsSpinner", false);  
                
                // component.set("v.listDetails", records.formData);
                //  component.set("v.data",res);
            }
            else{
                
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
    
    
    toggleSection : function(component, event, helper) {             
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-close'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }
    },
    closeModel : function(component, event, helper) {  
        component.set("v.isOpen",false);
    },
    /* showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },*/
    
    
    saveAfterEdit: function(component, event, helper) {
        //  component.set("v.IsSpinner", true);
        // helper.ifObjectsAreSame(component, event, helper, component.get("v.URRecordCopy", component.get("v.UtilizationRecordToSave")));
        console.log("Record to update "+JSON.stringify(component.get("v.UtilizationRecordToSave"))); 
        var fieldsValid = component.find('URFiledsValid').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        if(fieldsValid) {
            var utilRec = component.get("v.UtilizationRecordToSave");
            var sesAvail = utilRec.ElixirSuite__Sessions_Available__c;

            var revDat = utilRec.ElixirSuite__Date_Time_of_Review__c;

            console.log('timeOfReview****',revDat);

            if(revDat==null){
 
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 title : 'Error Message',
                 message:'Date/Time of Review cannot be blank', 
                 type: 'error',
                 mode: 'pester'
             });
             toastEvent.fire();
             return;
            }

            if(sesAvail<0){

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Approved Number of Sessions should be greater then Sessions Completed', 
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                return;
               }
            var arr = [];
            arr.push(component.get("v.UtilizationRecordToSave"));
            var action = component.get("c.updtRecordAfterEdit");  
               component.find("Id_spinner").set("v.class" , 'slds-show');  
            action.setParams({               
                "recordToUpdate" : arr,
                "recID" : component.get("v.recordValue")
            });
            action.setCallback(this, function(response) {                    
                var state = response.getState(); 
                if (state === "SUCCESS") {  
                       component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    console.log('wfh '+JSON.stringify(response.getReturnValue()));                       
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "RECORD  UPDATED SUCCESSFULLY!",
                        "message": "Updation Successfull!"
                    });
                    toastEvent.fire(); 
                    //  component.set("v.IsSpinner", false);
                    component.set("v.isOpen", false);
                    $A.get('e.force:refreshView').fire();
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
        }
        
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "title": "PLEASE REVIEW ERROR MESSAGE!",
                "message": "Fields not filled!"
            });
            toastEvent.fire();
        }
        
        
        
    },
    calulateNextReviewDate : function(component, event, helper) {  
     
        var getNumberOfDays = component.get("v.UtilizationRecordToSave")['ElixirSuite__Approved_Number_of_Days__c'];
        if(getNumberOfDays.length>8){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "title": "PLEASE ENTER VALID NUMBER OF DAYS!",
                "message": "Days not valid!"
            });
            toastEvent.fire();
            component.set("v.NextReviewDate",'');             
        }
        else if(getNumberOfDays.length==0){
            component.set("v.NextReviewDate",'');
        }
            else if(getNumberOfDays.length>=1){
                var today = component.get("v.UtilizationRecordToSave.ElixirSuite__Date_Time_of_Review__c");
                today =  new Date(today);
                today = helper.addDays(component, event, helper,today,getNumberOfDays);
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = today.getFullYear();        
                today = dd + '/' + mm + '/' + yyyy;
                // console.log('updated today  '+JSON.stringify(helper.addDays(component, event, helper,today,getNumberOfDays)));                         
                component.set("v.NextReviewDate",today);  
            }            
    },
    handleNextReviewDate :  function(component, event, helper) {  
        // var getCheckedStatus  = event.getSource().get("v.checked");
        if(event.getSource().get("v.checked")){
            component.set("v.isLastURForm",true);
        }
        else {
            component.set("v.isLastURForm",false);
        }
        
    },
   //Added by Anmol for LX3-5961
   reviewDate : function(component ,event ,helper){
    var reviewDt = component.find("review-time").get('v.value');
    console.log('reviewDate**',reviewDt);
    var utilRec = component.get("v.UtilizationRecordToSave");
    utilRec.ElixirSuite__Date_Time_of_Review__c = reviewDt;
    component.set("v.UtilizationRecordToSave",utilRec);
    var acId = component.get("v.patientID");
    
    helper.fetchSessionCompleted(component,acId,reviewDt);
    var apsession = component.get('v.approvedSession');
   // helper.fetchSessionAvail(component,apsession);
},
changeApprovedSession : function(component ,event ,helper){
    var apsession = component.find("approved-session").get('v.value');
    console.log('apsession**',apsession);
    var utilRec = component.get("v.UtilizationRecordToSave");
    utilRec.ElixirSuite__Approved_Number_of_Sessions__c = apsession;
    component.set("v.UtilizationRecordToSave",utilRec);
    
    helper.fetchSessionAvail(component,apsession);
},
//End by Anmol for LX3-5961
    openAsEdit : function(component, event, helper) {  
       
        var getStatus = component.get("v.UtilizationRecordToSave")['ElixirSuite__Status__c'];
        if(getStatus=='Closed'){
           var toastEvent = $A.get("e.force:showToast");
                      toastEvent.setParams({
                        "type": "info",
                        "title": "CANNOT EDIT AS STATUS IS CLOSED!",
                        "message": "Status is closed!!"
                    });
                    toastEvent.fire();
            
        }
        else {
            component.set("v.viewflag",false);
            component.set("v.isEnabledEditButton",false);
            component.set("v.showEditButton",false);
             component.set("v.OpenAsMode",'EDIT');
            
        }
    }
    
})