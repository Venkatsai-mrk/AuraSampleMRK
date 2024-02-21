({
    openSubtab: function() {
        /* var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "custom__component",
                "attributes": {
                    "componentName": "c__AdmissionForms"
                },
                "state": {
                    "uid": "1",
                    "c__name": component.get("v.myName")
                }
            }
        }).then(function(tabId) {
            console.log("The new subtab ID is:" + tabId);
        }).catch(function(error) {
            console.log("error");
        });*/
    },
    
    
    /* checkLicenseKey: function(component,event,helper){
      var licenseAction = component.get("c.checkEMRLicense");
        var is_license_available = false;
        licenseAction.setCallback(component,function(response){
            if(response.getState() === "SUCCESS"){
                is_license_available = response.getReturnValue();
                component.set("v.licenseAvailable",is_license_available);
            }
        });
        $A.enqueueAction(licenseAction);
    },*/ 
    /*Added by Avani Jain*/
    OpenElixirBillingSummary :function(component){
        /*   debugger;
      var evt = $A.get("e.force:navigateToComponent");
      evt.setParams({
          componentDef:"c:BillingSummaryforEHR",
          componentAttributes: {
              recordId1 : component.get("v.recordId"),
          }
      });
      evt.fire();*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:BillingSummaryforEHR",
            componentAttributes: {
                recordId1 : component.get("v.recordId"),
                ehrLicense : component.get("v.Ehr"),
                billingLicense :   component.get("v.Billing"),
                contactcenterLicense : component.get("v.ContactCentr")
            }
        });
        evt.fire();
    },
    /*end*/
    
  
    
   
    
    OpenClaims :function(component){
        
        
        component.set("v.OpPatientStatement",false);
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ClaimListView_for_Ehr",
            componentAttributes: {
                patId : component.get("v.recordId")
            }
        });
        evt.fire();
        
        
        
        
    },
    
    OpenPayment :function(component){
        
        /*component.set("v.Payment",true);
        component.set("v.Claims",false);
           component.set("v.CostOfCare",false);
         component.set("v.PaymentSchedule",false);
         component.set("v.PatientStatement",false);*/
        
        component.set("v.OpPatientStatement",false);
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:PaymentHistory_for_ehr",
            componentAttributes: {
                patId : component.get("v.recordId")
            }
        });
        evt.fire();
        
        
        
        
    },
    
    OpenPatientStatement :function(component){
        
        component.set("v.OpPatientStatement",true);
       
        
        
    },
    
    
    OpenElixirTimeline :function(component){
        //debugger;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:TimeLineParent",
            componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
            }
        });
        evt.fire();
    },
    handleRedirectNotesSubSection_1 : function(component) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:FirstVisitNotes",
            componentAttributes: {
                accountId : component.get("v.recordId"),
                noteType: 'First Visit Notes'
            }
        });
        evt.fire();
    },
    progressNote : function(component) {
        /*  var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirHC:progressNote_Jumpstartmd",
            componentAttributes: {
                accountId : component.get("v.recordId")
            }
        });
        evt.fire();
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ProgressNotesFinal",
            componentAttributes: {
                accountId : component.get("v.recordId")
            }
        });
        evt.fire();*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:FirstVisitNotes",
            componentAttributes: {
                accountId : component.get("v.recordId"),
                noteType: 'Progress Notes'
            }
        });
        evt.fire();
    },
    checkLicenseKey: function(component){
        component.set("v.licenseAvailable",true);
    },
    displaymessege: function(){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Cannot allocate bed",
            "message": "Bed is already allocated!"
        });
        toastEvent.fire();
    },
    
    notAccessible:function(){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Insufficient Permissions",
            "type":"error",
            "message": "Your profile permissions does not allow you to access this tab!"
        });
        toastEvent.fire();
    },
    getaccessibility: function(component,event,helper){
        component.set("v.loaded",false);
        var width = window.screen.availWidth;
        var height = window.screen.availHeight;
        console.log(width+' x '+height + 'haanji');
        var action =  component.get("c.getAccess");
        action.setParams({
            
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
            console.log(response.getReturnValue());
            //  component.set("v.accessibilityMap",response.getReturnValue());
            component.set("v.accessibilityMap",true);
            component.set("v.orgNamespace" , response.getReturnValue());
            console.log('org nspc '+ component.get("v.orgNamespace" ));
                
            component.set("v.accessibilityMap",true);
            component.set("v.orgNamespace" , response.getReturnValue());
            console.log('org nspc '+ component.get("v.orgNamespace" ));
            }
            var action2 = component.get('c.tabPermission');
        action2.setParams({
        });
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                console.log('TabPermission '+JSON.stringify(response.getReturnValue()));
                var wrapList = response.getReturnValue();
                component.set("v.TabPermission",response.getReturnValue().cs);
                component.set("v.Transportation",wrapList.isTransportation);
                component.set("v.Procedure",wrapList.isProcedure);
                component.set("v.ProgressNotes",wrapList.isProgressNotes);
                component.set("v.NotesForms",wrapList.isNotesForms);
                component.set("v.CareEpisode",wrapList.isCareEpisode);
                component.set("v.DischargeForm",wrapList.isDischargeForm);
                component.set("v.Timeline",wrapList.isTimeline);
                component.set("v.GenerateVerificationCode",wrapList.isGenerateVerificationCode);
                component.set("v.AdmissionForms",wrapList.isAdmissionForms);
                component.set("v.CarePlan",wrapList.isCarePlan);
                component.set("v.NursingForms",wrapList.isNursingForms);
                component.set("v.MorMar",wrapList.isMorMar);
                component.set("v.FirstVisitNotes",wrapList.isFirstVisitNotes);
                component.set("v.ClinicalForms",wrapList.isClinicalForms);
                component.set("v.ReviewForms",wrapList.isReviewForms);
                component.set("v.SendDataForClaims",wrapList.isSendDataForClaims);
                component.set("v.MedicalExamination",wrapList.isMedicalExamination);
                component.set("v.LabOrders",wrapList.isLabOrders);
                component.set("v.Prescriptions",wrapList.isPrescriptions);
                component.set("v.Proc",true);
                component.set("v.CaptureSignature",wrapList.isCaptureSignature);
                component.set("v.MasterProblemList",wrapList.isMasterProblemList);
                component.set("v.BillingSummary",wrapList.isBillingSummary);
                component.set("v.CostOfCare",wrapList.costOfCare);
                component.set("v.PaymentSchedule",wrapList.paymentSchedule);
                component.set("v.Claims",wrapList.claims);
                component.set("v.Payment",wrapList.payment);
                component.set("v.PatientStatement",wrapList.patientStatement);
                component.set("v.MedicalCoding",wrapList.medicalCoding);
                component.set("v.CHCPrescription",wrapList.isCHCPrescription);
                component.set("v.NewCropPrescription",wrapList.isNewCropPrescription);
                component.set("v.IntegratedLabOrder",wrapList.isIntegratedLabOrder);
                console.log('TabPermission set '+JSON.stringify( component.get("v.TabPermission")));
               
               
                component.set("v.la",wrapList.isIntegratedLabOrder);
                if(wrapList.isBillingSummary==false && wrapList.isProcedure==false && wrapList.isProgressNotes == false && wrapList.isNotesForms == false && wrapList.isCareEpisode == false && wrapList.isDischargeForm == false && wrapList.isTimeline == false && wrapList.isGenerateVerificationCode == false && wrapList.isAdmissionForms == false && wrapList.isCarePlan == false && wrapList.isNursingForms == false && wrapList.isMorMar == false && wrapList.isFirstVisitNotes == false && wrapList.isClinicalForms == false && wrapList.isReviewForms == false && wrapList.isSendDataForClaims == false && wrapList.isMedicalExamination == false && wrapList.isLabOrders == false && wrapList.isPrescriptions == false && wrapList.isCaptureSignature == false && wrapList.isMasterProblemList == false )
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Insufficient Permissions",
                        "type":"error",
                        "message": "Your profile permissions does not allow you to access the tabs. Please contact your system administator for sufficient permissions!"
                    });
                    toastEvent.fire();
                }	 
                var action3 = component.get('c.licensBasdPermission');
                action3.setParams({
                });
                
                action3.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        component.set("v.loaded",true);
                        var wrapList = response.getReturnValue();
                        component.set("v.Ehr",wrapList.isEhr);
                        component.set("v.Billing",wrapList.isRcm);
                        component.set("v.ContactCentr",wrapList.isContactCenter);
                        component.set("v.subTabPicklistValueMap",wrapList.subTabPicklistValue);
                        let res = wrapList.subTabPicklistValue;
                       let mapOfLabelAndApi = {};
                         for(let rec in res){
                             mapOfLabelAndApi[res[rec]] = rec;
                         }
                         component.set("v.subTabPicklistValueMap",mapOfLabelAndApi);
                         console.log('subTabPicklistValue '+JSON.stringify( component.get("v.subTabPicklistValueMap")));
                        try{
                           helper.createDynamicJSON(component,event,helper);
                        }
                        catch(e){
                            alert('error' + e );
                        }
                    }
                });
                $A.enqueueAction(action3);
            }
        });
        $A.enqueueAction(action2);
        });
        $A.enqueueAction(action);
     
        
    },
    newCarePlan:function() {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirFDC:Elixir_CarePlan",
            componentAttributes: {
                recordVal : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    
    abcde : function(){
        //var aa = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/EMROccupancyAllocationforHC?Id=",
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    
    patientBills : function() {
        
    },
    UrNotes : function(component, event, helper) {
        //component.sectionOne();
        var a = component.get('c.sectionOne');
        var nameSpace = component.get('v.orgNamespace');
        $A.enqueueAction(a);
        helper.renderRelatedList(component,event,nameSpace+'Notes__c','UR Notes',nameSpace+'Notes__c','articleOne');
        helper.redirectToSobject(component, event, helper);
    },
    sectionOne: function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
    },
    sectionTwo : function(component, event, helper) {
        helper.helperFun(component,event,'articleTwo');
    },
    sectionThree : function(component, event, helper) {
        helper.helperFun(component,event,'articleThree');
    },
    sectionFour : function(component, event, helper) {
        helper.helperFun(component,event,'articleFour');
    },
    sectionFive : function(component, event, helper) {
        helper.helperFun(component,event,'articleFive');
    },
    sectionSix : function(component, event, helper) {
        helper.helperFun(component,event,'articleSix');
    },
    sectionSeven : function(component, event, helper) {
        helper.helperFun(component,event,'articleSeven');
    },
    /*sectionEight : function(component, event, helper) {
        helper.helperFun(component,event,'articleEight');
    },*/
    sectionNine : function(component, event, helper) {
        helper.helperFun(component,event,'articleNine');
    },
    sectionBed : function(component, event, helper) {
        helper.helperFun(component,event,'allocateBed');
    },
    sectionTen : function(component, event, helper) {
        helper.helperFun(component,event,'articleTen');
    },
    sectionEleven: function(component, event, helper) {
        helper.helperFun(component,event,'articleEleven');
    },
    sectionSubTab1 :function(component, event, helper){
        helper.helperFun(component,event,'articleSubTab1');
        
    },
    
    /*sectionSubTab2:function(component, event, helper){
         helper.helperFun(component,event,'articleSubTab2');
        
    },*/
    
    nursingNotes: function(component,event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Notes__c','Nursing Notes',nameSpace+'Notes__c','articleThree');
        helper.redirectToSobject(component, event, helper);
    },
    /* ehrconditions :function (component,event,helper){
        helper.renderRelatedList(component,event,'HealthCloudGA__EhrCondition__c','EHR Condition','HealthCloudGA__EhrCondition__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    ehrprocedures :function (component,event,helper){
        helper.renderRelatedList(component,event,'HealthCloudGA__EHRProcedure__c','EHR Procedure','HealthCloudGA__EHRProcedure__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },*/
    clinicalNotes :function (component,event,helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Notes__c','Clinical Notes',nameSpace+'Note__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    bioAssessments: function(component,event,helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Assessments__c','Bio Psych Social',nameSpace+'Description__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    caseMgmtNotes : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Notes__c','Case Management Notes',nameSpace+'Notes__c','articleSeven');
        helper.redirectToSobject(component, event, helper);
    },
    nursingAssessment :function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Assessments__c','Nursing Assessment',nameSpace+'Description__c','articleThree');
        helper.redirectToSobject(component, event, helper);
    },
    specialAssessments : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Assessments__c','Special Assessments',nameSpace+'Description__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    treatmentPlan : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Plan__c','Initial Treatment Plan',nameSpace+'Treatment_Plan_Type__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    treatmentPlanReview : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Plan__c','Treatment Plan Reviews',nameSpace+'Treatment_Plan_Type__c','articleSix');
        helper.redirectToSobject(component, event, helper);
    },
    nursingTXPlan : function(component, event, helper){
        helper.renderRelatedList(component,event,'Case','CarePlan','Subject','articleThree');
        helper.redirectToSobject(component, event, helper);
    },
    caseMgmtPlan : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Plan__c','Case Management Plan',nameSpace+'Treatment_Plan_Type__c','articleSeven');
        helper.redirectToSobject(component, event, helper);
    },
    HPassessments : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Assessments__c','H&P',nameSpace+'Description__c','articleTwo');
        helper.redirectToSobject(component, event, helper);
    },
    caseMgmtAssmnt : function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Assessments__c','Case Management Assessment',nameSpace+'Description__c','articleSeven');
        helper.redirectToSobject(component, event, helper);
    },
    labResults: function(component, event, helper){
        helper.getLabResults(component,event,'articleNine','Lab Result');
        helper.redirectToSobject(component, event, helper);
    },
    otherTestResults: function(component, event, helper){
        helper.getLabResults(component,event,'articleNine','Test Result');
        helper.redirectToSobject(component, event, helper);
    },
    allocatebed: function(component, event, helper){
        helper.getbed(component,event,'allocateBed','allocatebed');
        helper.redirectToSobject(component, event, helper);
        
    },
    heatmap: function(component, event, helper){
        helper.helperfun(component,event,'allocateBed'); 
        helper.redirectToSobject(component, event, helper);
        // helper.getmap(component,event,'allocateBed','heatmap');
        //helper.redirectToSobject(component, event, helper);
        
    },
    
    
    
    DCTransferNote: function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Notes__c','DC/Transfer Notes',nameSpace+'Note__c','articleTen');
        helper.redirectToSobject(component, event, helper);
    },
    
    DCPatient: function(component, event, helper){
        var a = component.get('c.hideSubTab');
        $A.enqueueAction(a);
        helper.renderSubtabsOfSubtabs(component,'articleTen','DcPatient');
        helper.redirectToSobject(component, event, helper);
    },
    uploadForms:function(component, event, helper){
        helper.renderSubtabsOfSubtabs(component,'articleFour','uploadForms');
        helper.redirectToSobject(component, event, helper);
    },
    
    transferPatient: function(component, event, helper){
        var a = component.get('c.hideSubTab');
        $A.enqueueAction(a);
        helper.renderSubtabsOfSubtabs(component,'articleTen','transferPatient');
        helper.redirectToSobject(component, event, helper);
    },
    
    hideSubTab : function(component, event, helper){
        helper.renderSubtabsOfSubtabs(component,'articleSubTab1');
        helper.redirectToSobject(component, event, helper);
    },
    
    /*RxOrder:function(component, event, helper){
        helper.renderRelatedList(component,event,'Labs_and_RX_forms__c','Prescription','Medication_A__c','articleTwo');
        helper.redirectToSobject(component, event, helper);
    },*/
    labTest:function(component, event, helper){
        var nameSpace = component.get('v.orgNamespace');
        helper.renderRelatedList(component,event,nameSpace+'Labs_and_RX_forms__c','Lab Testing',nameSpace+'Test_Description__c','articleTwo');
        helper.redirectToSobject(component, event, helper);
    },
    toggleView:function(component){
        var cmps = component.find("articleTwo");
        for(var cm in cmps){
            if($A.util.hasClass(cmps[cm],'slds-tabs_scoped__content')){
                $A.util.removeClass(cmps[cm], 'slds-show');
                $A.util.removeClass(cmps[cm], 'slds-is-active');
                $A.util.addClass(cmps[cm], 'slds-hide');
            }
        }
    },
    AdmissionFormHandler: function(){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:AdmissionForms",
            componentAttributes: {
                //  patientID : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    VerifyFormHandler: function(component){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:VerifyAdmissionForms",
            componentAttributes: {
                patientID : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    MORMARHandler1 : function(component){
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"C:MAR",
            componentAttributes: {
                patientID : component.get("v.recordId")
            }
        });
        evt.fire();
        
    },
    /*admissionFormsHandler : function(component,event,helper){
     var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:AdmissionForms",
            componentAttributes: {
               // patientID : component.get("v.recordId")
            }
        });
		evt.fire();
    },*/
    
    /*
    URInitialReview : function(component, event, helper){
        helper.renderRelatedList(component,event,'Assessments__c','UR Initial Review','Description__c','articleEight');
    },
    URConcurrentReview : function(component, event, helper){
        helper.renderRelatedList(component,event,'Assessments__c','UR Concurrent Review','Description__c','articleEight');
    }*/
    
    doctorOrder : function(component  ){
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openModal",true);  
    },
    labOrdersHandler : function(component  ){
        
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ElixirHC_LabOrderListView",
            componentAttributes: {
                patientID : component.get("v.recordId"),
                nameSpace : 'ElixirSuite__'
            }
        });
        evt.fire();
        
    },
    labOrdersCHCHandler : function(component  ){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__labOrdersCHCSuTab"
                },
                "state": {
                    c__crecordId: component.get("v.recordId")
                }
            },
            focus: true
        }).then(function(subtabId){
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Lab Tests"
            });
            /** workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "action:new_case",
                iconAlt: "Clone Case"
            });**/
        }).catch(function(error) {
            console.log(error);
        });
        
        /** var evt = $A.get("e.force:navigateToComponent");
      evt.setParams({
          componentDef:"c:tableForLabOrder",
          componentAttributes: {
              patientID : component.get("v.recordId"),
              nameSpace : ''
          }
      });
      evt.fire();**/
        
    },
    
    // EprescriptionCHCHandler: function(component,event,helper){
    //     var id=component.get("v.recordId");
    //      var urlEvent = $A.get("e.force:navigateToURL");
    //     urlEvent.setParams({
    //         "url":"/apex/CreatePrescription?Id="+id,
    //     });
    //     urlEvent.fire(); 
    // },
    // EprescriptionCHCHandler: function(component,event,helper){
    //     var compDefinition = {
    //         type: 'standard__component',
    //         componentDef: "c:ePriscriptionListView",
    //         attributes: {
    //         },
    //         // state: {
    //         //     nooverride: 1,
    //         //     navigationLocation: 'LIST_VIEW',
    //         //     backgroundContext: '/lightning/o/Opportunity/list?filterName=Recent'
    //         //     //backgroundContext: back_url
    //         // }
    //     };
    //     let encodedCompDef = btoa(JSON.stringify(compDefinition));
    //     var urlEvent = $A.get("e.force:navigateToURL");
    //     urlEvent.setParams({
    //         "url": "/one/one.app#" + encodedCompDef
    //     });
    //     urlEvent.fire();
    // },
    
    EprescriptionCHCHandler: function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__getPrescriptionCompo"
                },
                "state": {
                    c__crecordId: component.get("v.recordId")
                }
            },
            focus: true
        }).then(function(subtabId){
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Prescriptions"
            });
            /** workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "action:new_case",
                iconAlt: "Clone Case"
            });**/
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    
    
    prescriptionNewCrop:function(component  ){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:newCropPrescriptions",
            componentAttributes: {
                recordVal : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    
    
    vitalRec : function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/HealthCloudGA__Observations__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
        
    },
    
    
    /*CreatelabOrdersHandler : function(component , event , helper){
      console.log('create rec order'+component.get("v.recordId"));
       component.set("v.recordVal" ,component.get("v.recordId"));
       console.log('reverse '+component.get("v.recordVal"));
      component.set("v.openCreateLabOrder",true);
      
  },*/
    
    ASAMForms : function(component  ){
        
        /*  component.set("v.recordVal" ,component.get("v.recordId"));
      console.log('reverse '+component.get("v.recordVal"));
      component.set("v.openASAMForms",true);*/
        //alert('id for rec '+JSON.stringify( component.get("v.recordId")));         
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:ASAMListView",
            componentAttributes: {
                patientID : component.get("v.recordId")
            }
        });
        evt.fire();
        
    },
    prescriptionsView	:	function(component  ){
        // var nspc = ''+':';
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:MedicationListView",
            componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
            }
        });
        evt.fire();
        //system.debug('hbdh');
    },
    
    procView	:	function(component  ){
        // var nspc = ''+':';
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:MedicalCodingListView",
            componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
            }
        });
        evt.fire();
        //system.debug('hbdh');
    },
    
    accountAssociatedForms: function(component  ){
        component.set("v.OpenNewNursing",true);  
        
    },
    
    medication : function(component  ){
        component.set("v.recordValForMedication" ,component.get("v.recordId"));
        component.set("v.openMedicationModal",true); 
        //console.log('record id for tab'+component.get("v.recordId"));
        //console.log('record id for tab after'+component.get("v.recordValForMedication"));
        // alert('value of true '+component.get("v.openMedicationModal"));
        
    },
    
    MORMARHandler : function(component){
        
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openModalMorMar",true);   
        
    },
    /* labOrdersHandler : function(component,event,helper){
      component.set("v.openModalLabOrder",true);
      var v = component.get("v.recordId");
      var url ="/lightning/r/"+ v +"/related/HealthCloudGA__EHRProcedureRequest__c/view";
      console.log('url-------'+url);
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url" : "https://elixir-development-dev-ed.lightning.force.com/lightning/o/HealthCloudGA__EHRProcedureRequest__c/list?filterName=Recent"
     // "url": "/lightning/o/HealthCloudGA__EHRProcedureRequest__c/home"
    });
    urlEvent.fire();
    // window.open('https://elixir-development-dev-ed.lightning.force.com','_top');
 	},*/
    
    handleComponentEvent : function(component,event){
        var message = event.getParam("ShowComponent");
        component.set("v.openReviewOrder",message)
    },
    
    heatmapcontrol: function(){
        var heatevt = $A.get("e.force:navigateToComponent");
        heatevt.setParams({
            componentDef:"ElixirCS:HeatMap",
            componentAttributes: {
                
            }});
        heatevt.fire();
        
    },
    generateClaim : function(){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success !",
            "type":"success",
            "message": "Data has been successfully sent for Claim Generation!"
        });
        toastEvent.fire(); 
        
        /*  var action = component.get("c.generateClaimMethod");
      action.setParams({
          "patientId" : component.get("v.recordId")
      });
      action.setCallback(this, function(response){
          if(response.getState() === 'SUCCESS'){
              if(response.getReturnValue()==true){
          var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
        			"title": "Successful",
                    "type":"success",
        			"message": "Data has been successfully sent for Claim Generation!"
        		});
    			toastEvent.fire();
          console.log('response-----'+response.getReturnValue());
      }
            
          else{
               var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
        			"title": "Error",
                    "type":"Error",
        			"message": "There are no new conditions for this patient!"
        		});
    			toastEvent.fire(); 
          }
          }
              
      });
      $A.enqueueAction(action);*/
    },
    
    // works on generate OTP button
    
    
    
    
   
    
    NotesForm : function(component  ){
        component.set("v.recordVal" ,component.get("v.recordId"));
        // component.set("v.OpenNotes",true);
        component.set("v.OpenNewNotes" , true);
    },
    
    admissionForms: function(component  ){
        component.set("v.recordVal" ,component.get("v.recordId"));
        //  component.set("v.OpenAdmsn",true);  
        component.set("v.OpenNewAdmsn",true);
        /*  var evt = $A.get("e.force:navigateToComponent");
      console.log('asadsf');
     
      //var name = event.getSource().get("v.name");
      //console.log('asadsf' +name);
      //var array = name.split('$');
     // console.log('dfda'+JSON.stringify(component.get(recordId)));
      var category = 'Nursing';//array[0];
      var subCategory = 'Assessments';//array[1];
        evt.setParams({
            componentDef:"ElixirFDC:Elixir_AccountAssociatedForms",
            componentAttributes: {
               recordVal : component.get("v.recordId"),
               categorized  : category,
               subCategorized : subCategory,
                headingTitle : 'All Forms'
            }
        });*/
        
    },
    
    clinicalForms	:	function(component  ){
        component.set("v.recordVal" ,component.get("v.recordId"));
        // component.set("v.OpenClinical",true); 
        component.set("v.OpenNewClinical",true);
        /*  var evt = $A.get("e.force:navigateToComponent");
      console.log('asadsf');
     
      //var name = event.getSource().get("v.name");
      //console.log('asadsf' +name);
      //var array = name.split('$');
     // console.log('dfda'+JSON.stringify(component.get(recordId)));
      var category = 'Clinical';//array[0];
      var subCategory = 'Assessment';//array[1];
        evt.setParams({
            componentDef:"ElixirFDC:Elixir_AccountAssociatedForms",
            componentAttributes: {
               recordVal : component.get("v.recordId"),
               categorized  : category,
               subCategorized : subCategory,
                headingTitle : 'All Assessment Forms'
            }
        });
		evt.fire();
        console.log('asdf');*/
    },
    navHome : function () {
        //var nameSpace = component.get('v.orgNamespace');
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "ElixirSuite__Encounter__c"
        });
        homeEvent.fire();
        
    },
    navAllergy : function (component) {
        /* var homeEvent = $A.get("e.force:navigateToObjectHome");
      homeEvent.setParams({
          "scope": "ElixirSuite__AllergyIntolerance__c"
      });
      homeEvent.fire();
       */
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "AllergyIntolerances",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
        
    },
    navHome1 : function (component) {
        /*  var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirFDC:CarePlan_ListView",
            componentAttributes: {
                recordVal : component.get("v.recordId"),
                openCareplan : true
            }
        });
		evt.fire();  */
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openCareplan", true);
    },
    encounterListview : function (component) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:EncounterListView",
            componentAttributes: {
                recordVal : component.get("v.recordId")
            }
        });
        evt.fire();  
    },
    
    URListview : function (component) {
        
        // var nspc = ''+':';
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ElixirHC_URListView",
            componentAttributes: {
                patientID : component.get("v.recordId"),
                OrgWideNameSpace : 'ElixirSuite__'
            }
        });
        evt.fire();
        //system.debug('hbdh');
        
        
        
        
        
    },
    
    claimsListview : function (component) {
        console.log('ur account '+JSON.stringify(component.get("v.recordId")));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:Elixir_ClaimsListView",
            componentAttributes: {
                patientID : component.get("v.recordId")
            }
        });
        evt.fire();  
    },
    handleClickForUA : function (component) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ElixirHC_UAListView",
            componentAttributes: {
                patientID : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    handleClickForCMForms :  function (component) {
        // component.set("v.categorized",'CaseManagement');
        // component.set("v.headingTitle",'Case Management Forms')
        component.set("v.openCMForms",true);
    },
    
    inventoryRec : function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Inventory__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
    },
    
    encounterRecord : function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Encounters__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
    },
    
    allergyRec: function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Medical_Examinations__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
    },
    ImmunizationRec: function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Vaccines__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
    },
    
    referralRec: function(component){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:ElixirOEM_ReferralListView",
            componentAttributes: {
                recordVal : component.get("v.recordId")
            }
        });
        evt.fire();  
    },
    
    procedureRec: function(component){
        var p  = component.get("v.recordId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Procedures__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
    },
    
    masterProblemListview : function (component) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:masterProblemlist",
            componentAttributes: {
                recordVal : component.get("v.recordId")
            }
        });
        evt.fire();  
    },
    
    //Master Note Workspace APi
    
    masterNoteViewMedical : function (component) {
        //   component.set("v.OpenNewAdmsn" , true);
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
    genericParentTabCall :  function (component, event, helper) {
        const launchTypes = {'component' : 'genericComponentLaunch','event' : 'genericEventLaunch',
                             'workspace' : 'genericWorkspaceLaunch'};
        var ctarget = event.currentTarget;
        var dataSet = ctarget.dataset.value;
        let arrJSON = component.get("v.dynamicTabLst");
        let isDirectTabLaunch = arrJSON[dataSet].isDirectTabLaunch;
        if(isDirectTabLaunch){
            let typeOfLaunch = arrJSON[dataSet].typeOfLaunch;
            console.log('typeOfLaunch: ' + typeOfLaunch);
            
            var helperName = launchTypes[typeOfLaunch];
            console.log('helperName in genericParentTabCall: ' + helperName);
            
            if (helperName) {
                helper[helperName](component, event, helper, arrJSON[dataSet]);
            } else {
                console.error('Helper function not found for typeOfLaunch: ' + typeOfLaunch);
            }
 
        }  
    },
    genericSubTabCall :  function (component, event, helper) {
        const launchTypes = {'component' : 'genericComponentLaunch','event' : 'genericEventLaunch',
                             'workspace' : 'genericWorkspaceLaunch'};
        var ctarget = event.currentTarget;
        var dataSet = ctarget.dataset.value;
        let arrIndex = dataSet.split('$');
        let parentIndex = arrIndex[0];
        let childIndex = arrIndex[1];
        let arrJSON = component.get("v.dynamicTabLst");
        //let isDirectTabLaunch = arrJSON[parentIndex].isDirectTabLaunch;
        let helperName = arrJSON[parentIndex].subTabs[childIndex].methodName;
        if(helperName){
            helper[helperName](component, event, helper);  // helper logic calling if there is any
        }
        let  typeOfLaunch  = arrJSON[parentIndex].subTabs[childIndex].typeOfLaunch;
        var launchHelperName = launchTypes[typeOfLaunch];
        if(launchHelperName){
            if( arrJSON[parentIndex].subTabs[childIndex].elementChild.hasOwnProperty('ElixirSuite__Pre_Launch_Validation__c')){ // if validation helper given then runn helper method
            var preLaunchHelperValidationName = arrJSON[parentIndex].subTabs[childIndex].elementChild.ElixirSuite__Pre_Launch_Validation__c;
            console.log('preLaunchHelperValidationName',preLaunchHelperValidationName);
            helper[preLaunchHelperValidationName](component,event,helper,arrJSON,parentIndex,childIndex,launchHelperName);
        }
        else { // if no validation then launch simply
              helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]); // dynamic launch calling    
        }
        }
        
     /*   var flag = true;
        if(flag){
            
        }
        if( arrJSON[parentIndex].subTabs[childIndex].elementChild.hasOwnProperty('ElixirSuite__TAB_Component_Definition__c')){
            if( arrJSON[parentIndex].subTabs[childIndex].elementChild.ElixirSuite__TAB_Component_Definition__c == 'ElixirSuite__labOrdersCHCSuTab'){
                flag = false;
            helper.runValiDationAndOpenLabOrder(component, event, helper);
                console.log('INSIDE IF FOR LAUNCHING COMPONENT');
        }
            else if( arrJSON[parentIndex].subTabs[childIndex].elementChild.ElixirSuite__TAB_Component_Definition__c == 'c:newCropSubComp'){
                flag = false;
            helper.runValidationAndOpenNewCrop(component, event, helper);
                //console.log('INSIDE IF FOR LAUNCHING COMPONENT');
        }
        }
        if(flag) {
        helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]); // dynamic launch calling               
    }*/
    }
    
})