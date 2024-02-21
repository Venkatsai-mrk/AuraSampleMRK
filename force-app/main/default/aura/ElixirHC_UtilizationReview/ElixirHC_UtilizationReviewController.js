({
    doInit : function(component, event, helper) {        
        console.log('isOpen Value   ' + JSON.stringify(component.get("v.isOpen")));
        console.log('inside UR REVIEW CREATE'); 
        var today = new Date();
        component.set('v.todayString', today.toISOString());
       
       //added by Anmol for LX3-5961
       component.set('v.timeOfReview', today.toISOString());
       var tod = today.toISOString();
        var acId = component.get("v.patientID");
       helper.fetchSessionCompleted(component,acId,tod);
       //end by Anmol for LX3-5961

        var namespace ='ElixirSuite__';
        var action = component.get("c.getAllDataForUtilizationReview");
        action.setParams({ accountId : component.get("v.patientID")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.find("Id_spinner").set("v.class" , 'slds-hide');  
             //   console.log('date type set  ' + JSON.stringify(response.getReturnValue().acctRecord.Admit_Date__c));
                console.log('Master UR  data '+JSON.stringify(response.getReturnValue()));                
                component.set("v.masterDataForUR",response.getReturnValue());
                component.set("v.birthDate" , response.getReturnValue().patBirthDate);
                component.set("v.PatientDetails",response.getReturnValue().acctRecord);
                component.set("v.allProgrmsOffered",response.getReturnValue().lstOfProgramsOffered);
                component.set("v.allProblemsForPatient",response.getReturnValue().allProblemsForPatient);
                //component.set("v.purchasePlan",response.getReturnValue().allVOBDetails);
                //component.set("v.planBenifit",response.getReturnValue().allVOBDetails);
               // component.set("v.carePreAuth",response.getReturnValue().allVOBDetails);
               // console.log('JSON RETURN '+response.getReturnValue().allVOBDetails);
               // component.set("v.memberPlan",response.getReturnValue().allVOBDetails); 
                 //component.set("v.VOBDetails",response.getReturnValue().allVOBDetails); 
                 component.set("v.PatientProblem",response.getReturnValue().allProblemsForPatient);
                 component.set("v.ProcedureInfo",response.getReturnValue().allProcedure);
                 component.set("v.recordDetail",response.getReturnValue().allDiagonsis);

                console.log('member plan' , component.get("v.memberPlan"));
                console.log('member plan' , component.get("v.carePreAuth"));

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

                if(!$A.util.isEmpty(response.getReturnValue().lastCreatedReviewForNewUR)){
                component.set("v.lastCreatedReview",response.getReturnValue().lastCreatedReviewForNewUR[0]);
                    component.set("v.showLastReviewInfo",true);
                }
                else {
                    component.set("v.showLastReviewInfo",false);
                }
                
                
                if(!$A.util.isUndefinedOrNull(response.getReturnValue().finalQNAmapLst) || !$A.util.isEmpty(response.getReturnValue().finalQNAmapLst)){
                var formAnswers = response.getReturnValue().finalQNAmapLst;
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
                    QNAkeys.ans = myQuestionsAnswers[rec][namespace + 'Text__c'];
                    arrQNA.push(QNAkeys);
                    }
                }               
                //component.set("v.data", records);preAssesAnswers  
                component.set("v.preAssesAnswers", arrQNA);                       
            }
            else{                
                var errors = response.getError();
                if (errors) {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
    },
    
    handleConfirmDialogYes :  function(component, event, helper) 
    {
        var allValid;
        var fieldsValid = component.find('URFiledsValid').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            var today = new Date();
            endProcedureTime = today;
        }
        if(!($A.util.isUndefinedOrNull(endProcedureTime) || $A.util.isUndefinedOrNull(strtProcedureTime))){
            var today = new Date();
            if(strtProcedureTime>endProcedureTime){         
                procedureEndCmp.setCustomValidity("End date cannot be less than start date");
                procedureEndCmp.reportValidity();
                dateValid = false;
            }
            var dte = new Date(strtProcedureTime);
            if((dte.setDate(dte.getDate()+1) <today)){
                procedureStartCmp.setCustomValidity("Start date cannot be less than today");
                procedureStartCmp.reportValidity();
                dateValid = false;
                console.log('ss');
            }    
        }else{
            allValid = false;
        }
        if(fieldsValid){
            var arr =  [];
           //added by Anmol for LX3-5961
           var utilRec = component.get("v.UtilizationRecordToSave");
           var revDt = component.get("v.timeOfReview");
           var aprovedSes = component.get("v.approvedSession");
           var sesComp = component.get("v.sessionCompleted");
           var sesAvail = component.get("v.sessionAvail");

           console.log('timeOfReview****',revDt);

           if(revDt==null){

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
           
           
           utilRec.ElixirSuite__Date_Time_of_Review__c = revDt;
           utilRec.ElixirSuite__Approved_Number_of_Sessions__c = aprovedSes;
           utilRec.ElixirSuite__Sessions_Completed__c = sesComp;
           utilRec.ElixirSuite__Sessions_Available__c = sesAvail;
           component.set("v.UtilizationRecordToSave",utilRec);
           console.log('after ur review handleConfirmDialogYes**',JSON.stringify(component.get("v.UtilizationRecordToSave")));
           //end by Anmol for LX3-5961
            arr.push(component.get("v.UtilizationRecordToSave"));
            console.log('ur review '+JSON.stringify(component.get("v.UtilizationRecordToSave")));
            var action = component.get("c.saveDataForUtilizationReview"); 
             component.find("Id_spinner").set("v.class" , 'slds-show'); 
            action.setParams({               
                "recordToSave": arr,
                "accountId" : component.get("v.patientID"),
                "starttimeProcedure" :component.get('v.todayString'),
                "endtimeProcedure" : endProcedureTime
                
            });
            action.setCallback(this, function(response) {                    
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    console.log('wfh '+JSON.stringify(response.getReturnValue()));                       
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "UTILIZATION RECORD CREATED SUCCESSFULLY!",
                        "message": "Creation Successfull!"
                    });
                  
                   component.set("v.closeSaveYes", true);
                   //component.set("v.isOpen", false);
              
                    var workspaceAPI = component.find("workspace");
                    if(component.get("v.backPage")){
                        component.set("v.isOpen",false);    
                    }else{
                        window.history.go(-2);
                    }
                    workspaceAPI.getFocusedTabInfo().then(function(response){
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error){
                        console.log(error);
                    });
                  
                   toastEvent.fire();
                   $A.get('e.force:refreshView').fire();  
                } else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "INSERTION  FAILED!",
                        "message": "Failed!"
                    });
                    toastEvent.fire();
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
    
    save: function(component, event, helper) {
        
        //  component.set("v.IsSpinner", true);     
        var allValid;   
        var fieldsValid = component.find('URFiledsValid').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
         if(endProcedureTime == null )
        {
            component.set("v.showConfirmDialog",true); 
        }
      
        if(! ($A.util.isUndefinedOrNull(endProcedureTime) || $A.util.isUndefinedOrNull(strtProcedureTime))){
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                dateValid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
          
            if((dte.setDate(dte.getDate()) >today)){
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                dateValid = false;
                console.log('ss');
            }
            
            else{
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        else{
            allValid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
        
        if(fieldsValid) {
            console.log('ur review '+JSON.stringify(component.get("v.UtilizationRecordToSave")));
              var arr =  [];

                //added by Anmol for LX3-5961
              var utilRec = component.get("v.UtilizationRecordToSave");
              var revDt = component.get("v.timeOfReview");
              var aprovedSes = component.get("v.approvedSession");
              var sesComp = component.get("v.sessionCompleted");
              var sesAvail = component.get("v.sessionAvail");

              console.log('timeOfReview****',revDt);

           if(revDt==null){

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
              
              
              utilRec.ElixirSuite__Date_Time_of_Review__c = revDt;
              utilRec.ElixirSuite__Approved_Number_of_Sessions__c = aprovedSes;
              utilRec.ElixirSuite__Sessions_Completed__c = sesComp;
              utilRec.ElixirSuite__Sessions_Available__c = sesAvail;
              component.set("v.UtilizationRecordToSave",utilRec);
              console.log('after ur review**',JSON.stringify(component.get("v.UtilizationRecordToSave")));
              //end by Anmol for LX3-5961

            arr.push(component.get("v.UtilizationRecordToSave"));
            var action = component.get("c.saveDataForUtilizationReview"); 
             component.find("Id_spinner").set("v.class" , 'slds-show'); 
            action.setParams({               
                "recordToSave": arr,
                "accountId" : component.get("v.patientID"),
                "starttimeProcedure" :component.get('v.todayString'),
                "endtimeProcedure" : component.get('v.endString')
                
            });
            action.setCallback(this, function(response) {                    
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    console.log('wfh '+JSON.stringify(response.getReturnValue()));                       
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "UTILIZATION RECORD CREATED SUCCESSFULLY!",
                        "message": "Creation Successfull!"
                    });
                    toastEvent.fire(); 
                    //  component.set("v.IsSpinner", false);
                  
                    var workspaceAPI = component.find("workspace");
                    if(component.get("v.backPage")){
                        component.set("v.isOpen", false);    
                    }else{
                        window.history.go(-2);
                    }
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                } else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "INSERTION  FAILED!",
                        "message": "Failed!"
                    });
                    toastEvent.fire();
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
        
        //Nikhil Kumar
        
         var workspaceAPI = component.find("workspace");
        if(component.get("v.backPage")){
         component.set("v.isOpen",false);    
        }else{
            window.history.go(-2);
        }
        workspaceAPI.getFocusedTabInfo().then(function(response){
                           var focusedTabId = response.tabId;
                           workspaceAPI.closeTab({tabId: focusedTabId});
                         })
        .catch(function(error){
                            console.log(error);
                         });
    },
    /*  showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    */
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
    },

    //Added by Anmol for LX3-5961
    reviewDate : function(component ,event ,helper){
        var reviewDt = component.find("review-time").get('v.value');
        console.log('reviewDate**',reviewDt);
        component.set('v.timeOfReview', reviewDt);
        var acId = component.get("v.patientID");
        
        helper.fetchSessionCompleted(component,acId,reviewDt);
        var apsession = component.get('v.approvedSession');
       // helper.fetchSessionAvail(component,apsession);
    },

    changeApprovedSession : function(component ,event ,helper){
        var apsession = component.find("approved-session").get('v.value');
        console.log('apsession**',apsession);
        component.set('v.approvedSession', apsession);
        helper.fetchSessionAvail(component,apsession);
    },

    calulateNextReviewDate : function(component, event, helper) {  
        var nspc =  'ElixirSuite__';
        var parentrecord = component.get("v.UtilizationRecordToSave");
        var getNumberOfDays =  parentrecord[nspc+'Approved_Number_of_Days__c'];
      
        /*if(getNumberOfDays.length>8){
             var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "info",
                        "title": "PLEASE ENTER VALID NUMBER OF DAYS!",
                        "message": "Days not valid!"
                    });
                    toastEvent.fire();
				 component.set("v.NextReviewDate",'');             
        }
        else {
        var today = new Date();
       	today = helper.addDays(component, event, helper,today,getNumberOfDays);
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();        
        today = dd + '/' + mm + '/' + yyyy;
       // console.log('updated today  '+JSON.stringify(helper.addDays(component, event, helper,today,getNumberOfDays)));                         
        component.set("v.NextReviewDate",today); 
        }*/
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
                var timeRev = component.get('v.timeOfReview');
                var today = new Date(timeRev);
               // var today = component.get('v.timeOfReview');
                today = helper.addDays(component, event, helper,today,getNumberOfDays);
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = today.getFullYear();        
                today = dd + '/' + mm + '/' + yyyy;
                // console.log('updated today  '+JSON.stringify(helper.addDays(component, event, helper,today,getNumberOfDays)));                         
                component.set("v.NextReviewDate",today); 
            }            
    },
    //End by Anmol for LX3-5961
    handleNextReviewDate :  function(component, event, helper) {  
        // var getCheckedStatus  = event.getSource().get("v.checked");
        if(event.getSource().get("v.checked")){
            component.set("v.isLastURForm",false);
        }
        else {
            component.set("v.isLastURForm",true);
        }
    }
    
    
    
})