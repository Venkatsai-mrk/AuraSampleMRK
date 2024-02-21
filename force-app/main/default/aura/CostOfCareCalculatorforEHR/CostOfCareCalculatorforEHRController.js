({
    doInit : function(component) {
        component.set("v.selectedPayerRecord", { label: "Private Pay", value: "Private Pay" });
        var acctId = component.get("v.recordId");
        var action = component.get("c.parentInitFetchDataForCOC");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                var acctDetails = res.acctDetailsFromVOB[0];
                var ContractedPrice = 0.0;
                component.set("v.AllFlag",true);
                component.set("v.acctDetails",acctDetails);
                component.set("v.selectRecordName", acctDetails.ElixirSuite__Account__r.Name);
                if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Contracted Price'){
                    ContractedPrice = res.contractPrice;
                }else if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Actual Price'){
                    ContractedPrice = res.actualPrice;
                }
                component.set("v.ConPrice",ContractedPrice);
                
                //component.set("v.insuranceDetails",res.vobResult);
            }
            else{
                //getting errors if callback fails
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
    handleComponentEvent : function(component, event,helper) {
        var recsObj = event.getParam("SelectedId");
        if($A.util.isUndefinedOrNull(recsObj)){
            helper.resetData(component);
            return;
        }
        var acctId = component.get("v.recordId");
        if(!$A.util.isUndefinedOrNull(acctId)){
            component.set("v.onPatient",true);
            component.set("v.reset",false);
        }
        else{
            component.set("v.onPatient",false);
            component.set("v.reset",true);
        }
        var action = component.get("c.parentInitFetchDataForCOC");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId,
                          vobRecId: recsObj
                         });        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                console.log('dd' , JSON.stringify(res));
                var benDesc = res.benefitDescOptions;
                var benLevel = res.benefitLevelOptions ;
                //benefit description
                var fieldMap = [];
                for(var key in benDesc){
                    fieldMap.push({key: key, value: benDesc[key]});
                }
                component.set("v.benefitDescription", fieldMap);
                
                //benefit level
                var fieldMapLevel = [];
                for(var key1 in benLevel){
                    fieldMapLevel.push({key: key1, value: benLevel[key1]});
                }
                component.set("v.benefitlevel", fieldMapLevel);
                component.set("v.selectRecordId", acctId);
                
                var b = [];
                var mapOfProcedures = {};
                var ContractedPrice = 0;
                var acctDetails = res.acctDetailsFromVOB[0];
                
                component.set("v.AllFlag",true);
                component.set("v.acctDetails",acctDetails);
                component.set("v.selectRecordName", acctDetails.ElixirSuite__Account__r.Name);
                console.log('acctDetails',acctDetails.ElixirSuite__Generate_Claim_on__c);
                if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Contracted Price'){
                    ContractedPrice = res.contractPrice;
                }else if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Actual Price'){
                    ContractedPrice = res.actualPrice;
                }
                
                component.set("v.ConPrice",ContractedPrice);
                component.set("v.insuranceDetails",res.vobResult);
                console.log('THE VOB RESULT IS:'+ JSON.stringify(component.get("v.insuranceDetails")));
                var allProcedures = res.allProcedures;
                for (var i = 0; i < allProcedures.length; i++) {
                    // childRecords.push();
                    b.push({
                        'label': allProcedures[i]['Name'],
                        'value': allProcedures[i]['Id']                                              
                    });  
                    allProcedures[i].totalContractedPrice = 0.0;
                    mapOfProcedures[allProcedures[i].Id] = allProcedures[i];
                }
                component.set("v.mapOfProcedures",mapOfProcedures);
                component.set("v.options",b);
            }
            else{
                //getting errors if callback fails
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
    hideProcedures : function(component) {
        component.set("v.isProceduresAvailable",false);
        component.set("v.isOpen",true);
    },
    openProcedures : function(component) {
        var lstOfProcedures = component.get("v.allProceduresSelectedToOperate");
        var arr = [];
        for (var existingId in lstOfProcedures) {
            if(!$A.util.isUndefinedOrNull(lstOfProcedures[existingId].Id)) {
                arr.push(lstOfProcedures[existingId].Id);
            }
        }
        var action = component.get("c.getProceduresTemplates");  
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ alreadyExistingProcedures :  arr});
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success');
                var b = [];
                var mapOfProcedures = {};
                //add key to all records to keep an eye on which one is selected.    
                var allProcedures = response.getReturnValue();
                
                //  component.set("v.insuranceDetails",response.getReturnValue().insuranceDetails[0]);
                for (var i = 0; i < allProcedures.length; i++) {
                    // childRecords.push();
                    b.push({
                        'label': allProcedures[i]['Name'],
                        'value': allProcedures[i]['Id']                                              
                    });  
                    allProcedures[i].totalContractedPrice = 0.0;
                    mapOfProcedures[allProcedures[i].Id] = allProcedures[i];
                }
                component.set("v.mapOfProcedures",mapOfProcedures);
                component.set("v.options",b);
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
        
        component.set("v.isProceduresAvailable",true);
    },
    handleChangeMultiSelectProcedures :  function(component, event) {
        
        component.set("v.selectedValues",event.getParam("value"));        
    },
    handleConfirmDialogAddProcedure : function(component, event, helper) {
        component.set("v.selectedValues",event.currentTarget.id);
        var selectedValues  =  component.get("v.selectedValues");
        //alert(selectedValues);
        var mapOfProcedures =  component.get("v.mapOfProcedures");  
        var acctDetails = component.get("v.acctDetails");
        var Contprice = component.get("v.ConPrice"); 
        
        if($A.util.isUndefinedOrNull(selectedValues) || $A.util.isEmpty(selectedValues)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "title" : "Please select something!",
                "message": "Nothing selected!",
                
            });
            toastEvent.fire();
        }
        else {
            component.find("Id_spinner").set("v.class" , 'slds-show');
            var dataarr = component.get("v.allProceduresSelectedToOperate");
            console.log('dataarr',JSON.stringify(dataarr));
            for(var key in selectedValues){
                dataarr.push(mapOfProcedures[selectedValues[key]]);
            }
            for (var i in dataarr){
                for(var j in Contprice){
                    if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Contracted Price'){
                        if(dataarr[i].Id == Contprice[j].ElixirSuite__Procedure__c){
                            dataarr[i]['cPrice']=Contprice[j].ElixirSuite__Contracted_Amount__c;
                            dataarr[i]['Unit']=Contprice[j].ElixirSuite__Units__c;
                        }  
                    }
                    else if(acctDetails.ElixirSuite__Generate_Claim_on__c == 'Actual Price'){
                        if(dataarr[i].Id == Contprice[j].ElixirSuite__Procedure__c){
                            dataarr[i]['cPrice']=Contprice[j].ElixirSuite__List_Price__c;
                            dataarr[i]['Unit']=Contprice[j].ElixirSuite__Units__c;
                        }
                        
                    }
                }
            }
            helper.calculatedTotalContractedPriceForEachProcedure(component, event, helper,dataarr);
            helper.calculateTotal(component, event, helper,dataarr);
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            console.log('C'+JSON.stringify(dataarr));
            component.set("v.allProceduresSelectedToOperate",dataarr);
            component.set("v.isProceduresAvailable",false);
            component.set("v.isProceduresSelected",true);
            component.set("v.isOpen",true);
            var newList=[];
            component.set("v.selectedValues", newList);
            component.set("v.selectvalueName",'');
            component.set("v.EmptyList",false);
        }
    },
    updateTotalContractedPrice : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        if(value.length>8){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "title": "PLEASE ENTER VALID NUMBER OF UNITS!",
                "message": "Units not valid!"
            });
            toastEvent.fire();            
        }
        else {
            var selectedProceduresData = component.get("v.allProceduresSelectedToOperate");
            var toUpdateRecord =  selectedProceduresData[index];
            toUpdateRecord.Unit = parseInt(toUpdateRecord.Unit);
            toUpdateRecord.totalContractedPrice = (toUpdateRecord.Unit *  toUpdateRecord.cPrice).toString();
            helper.calculateTotal(component, event, helper,selectedProceduresData);
            component.set("v.allProceduresSelectedToOperate",selectedProceduresData);
        }
    },
    handleRemoveRecords : function(component, event, helper) {
        component.set("v.checkAttribute",true);
        var index = event.getSource().get("v.name");
        var selectedProceduresData = component.get("v.allProceduresSelectedToOperate");
        selectedProceduresData.splice(index,1);
        helper.calculateTotal(component, event, helper,selectedProceduresData);
        component.set("v.allProceduresSelectedToOperate",selectedProceduresData);
        helper.calculationInHelper(component, event, helper);
        var checkLength = component.get("v.allProceduresSelectedToOperate");
        if(checkLength.length == 0){
            component.set("v.isProceduresSelected",false);
            component.set("v.hasCalculationCompleted",false);
        }
    },
    calculateResponsibility :function(component, event, helper) {
        var procTotal  =  JSON.parse(JSON.stringify(component.get("v.procedureTotal")));
        console.log('procTotal----' + procTotal);
        var selectedPayerRecord  = component.get("v.selectedPayerRecord");
        console.log('selectedPayerRecord----' + JSON.stringify(selectedPayerRecord));
        if(selectedPayerRecord.value == 'Private Pay'){
            component.set("v.hasCalculationCompleted",true);
            component.set("v.PatientResposibilityRoundedOff",procTotal.toFixed(2));
            component.set("v.InsuranceResposibilityRoundedOff",0);
        }else{
            helper.calculationInHelper(component, event, helper);  
        }
    },
    closeModel : function(component) {
        component.set("v.isConsoleView",false);
        component.set("v.isOpen",false);
    },
    save : function(component) {  
        var acctId = component.get("v.recordId");
        var selectedPayerRecord  = component.get("v.selectedPayerRecord").label;
        var Changedcopay = 0;
        if(component.get("v.value1") == 'Use Co-pay for Calculations'){
            if(!$A.util.isUndefinedOrNull(component.find('copay'))){
                Changedcopay = component.find('copay').get('v.value');
            }
        }
        var patientResponisibility = component.get("v.PatientResposibilityRoundedOff");
        var InsuranceResposibilityRoundedOff = component.get("v.InsuranceResposibilityRoundedOff");
        var action = component.get("c.saveCOC");
        var insuranceDetailsToSave = {'keysToSave' : component.get("v.insuranceDetails")};
        var proceduresToSave = {'keysToSaveForPrcedures' : component.get("v.allProceduresSelectedToOperate")};
        component.find("Id_spinner").set("v.class" , 'slds-show');
        /*  console.log('10');
        console.log('acctId:----' + acctId);
        console.log('patientResponisibility:----' + patientResponisibility);
        console.log('InsuranceResposibilityRoundedOff:----' + InsuranceResposibilityRoundedOff);
        console.log(component.get("v.procedureTotal"));
        console.log('insurance to save:'+insuranceDetailsToSave);
        console.log('proceduresToSave'+JSON.stringify(proceduresToSave));
        console.log(component.get("v.inUseStatus"));
        console.log('Changedcopay:----' + Changedcopay);*/
        
        action.setParams({ 
            accountId :  acctId,
            patientResponsibility : patientResponisibility,
            insuranceResposibility : InsuranceResposibilityRoundedOff,
            procedureTotal : component.get("v.procedureTotal"),
            insuranceDetails :  JSON.stringify(insuranceDetailsToSave),
            proceduresToSave :  JSON.stringify(proceduresToSave),
            receivedValue : component.get("v.inUseStatus"),
            copay:Changedcopay,
            coIns: component.get("v.coIns"),
            dedct: component.get("v.deduc"),
            oopMaximn: component.get("v.oopMax"),
            benDescription: component.get("v.benefitDescriptionValue"),
            benLevel: component.get("v.benefitLevelValue"),
            insValue: component.get("v.insuranceTypeValue"),
            selectedPayer : selectedPayerRecord
        });        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title" : "COST OF CARE CALCULATION SAVED SUCCESSFULLY!",
                    "message": "Estimations saved successfully!",
                    
                });
                toastEvent.fire(); 
                console.log('inside success');
                component.set("v.isConsoleView",false);
                component.set("v.isOpen",false);
                var appEvent = $A.get("e.c:RefreshEstimatesListView");
                appEvent.fire();
                
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        console.error("Stack trace: " + errors[0].stack);
                    }        }
            }
        });
        $A.enqueueAction(action);        
        
    },
    searchField : function(component, event) {
        var currentText = event.getSource().get("v.value");   
        component.set("v.LoadingText", true);
        if(currentText.length > 0) {
            component.set('v.EmpList',true);
        }
        else {
            component.set('v.EmpList',false);
        }
        
        var action = component.get("c.employerList");
        action.setParams({
            "searchKeyWord" : currentText
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
            }
            
            component.set("v.LoadingText", false);
        });
        $A.enqueueAction(action);
        
    },
    setSelectedRecord : function(component, event) {
        component.set('v.EmpList',false);
        var currentText = event.currentTarget.id;
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        if(event.currentTarget.dataset.name=='Other | N/A'){
            component.set("v.EmpOther",true);
        }
        else{ component.set("v.EmpOther",false);
            }
        component.set("v.selectRecordId", currentText);
        var action = component.get("c.parentInitFetchDataForCOC");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  currentText});        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success');
                var b = [];
                var mapOfProcedures = {};
                //add key to all records to keep an eye on which one is selected.
                var acctDetails = response.getReturnValue().acctDetailsFromVOB[0];
                component.set("v.acctDetails",acctDetails);
                var allProcedures = response.getReturnValue().allProcedures;
                component.set("v.insuranceDetails",response.getReturnValue().vobResult[0]);
                for (var i = 0; i < allProcedures.length; i++) {
                    // childRecords.push();
                    b.push({
                        'label': allProcedures[i]['Name'],
                        'value': allProcedures[i]['Id']                                              
                    });  
                    allProcedures[i].totalContractedPrice = 0.0;
                    mapOfProcedures[allProcedures[i].Id] = allProcedures[i];
                }
                component.set("v.mapOfProcedures",mapOfProcedures);
                component.set("v.options",b);
                
                
                
            }
            else{
                //getting errors if callback fails
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
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.set("v.insuranceDetails","");
        helper.redoInit(component, event, helper);
    },
    handleChange: function (component, event) {
        // alert(event.getParam('value'));
        
        console.log('1');
        if(event.getParam('value')=='Use Co-pay for Calculations'){
            console.log('2');
            component.set("v.useCopay", false);
            console.log('3');
        }
        else{
            console.log('4');
            component.set("v.useCopay", true);
            console.log('5');
            component.set("v.coPayAmt", '');
            console.log('6');
        }
    },
    isCOCinUsed :function(component,event) { 
        
        component.set("v.inUseStatus",event.getSource().get("v.checked"));
        
    },
    handleOnChange : function(component) {
        var benDescription = component.get("v.benefitDescriptionValue");
        var benLevel = component.get("v.benefitLevelValue");
        var insValue = component.get("v.insuranceTypeValue");
        
        var insList = component.get("v.insuranceDetails");
        
        console.log('sbhj' , JSON.stringify(insList));
        for(var i in insList){
            if(!$A.util.isEmpty(benDescription) && !$A.util.isEmpty(benLevel) && !$A.util.isEmpty(insValue)){
                if(benDescription == '30 = Health Benefit Plan Coverage' && benLevel=='Self' && insValue=='In Network'){
                    component.set("v.deduc",insList[i].ElixirSuite__Deductible_Rem_Ind_In_Network__c) ;
                    component.set("v.oopMax",insList[i].ElixirSuite__OOP_Rem_Ind_In_Network__c) ;
                    component.set("v.coIns",insList[i].ElixirSuite__Co_Insurance_Ind_In_Network__c); 
                    component.set("v.coPayAmt",0);
                }
                else if(benDescription == '30 = Health Benefit Plan Coverage' && benLevel=='Self' && insValue=='Out Of Network'){
                    component.set("v.deduc",insList[i].ElixirSuite__Deductible_Rem_Ind_Out_Network__c) ;
                    component.set("v.oopMax",insList[i].ElixirSuite__OOP_Rem_Ind_Out_Network__c) ;
                    component.set("v.coIns",insList[i].ElixirSuite__Co_Insurance_Ind_Out_Of_Network__c);
                    component.set("v.coPayAmt",0);
                }
                    else if(benDescription == '30 = Health Benefit Plan Coverage' && benLevel!='Self' && insValue=='In Network'){
                        component.set("v.deduc",insList[i].ElixirSuite__Deductible_Rem_Fam_In_Network__c) ;
                        component.set("v.oopMax",insList[i].ElixirSuite__OOP_Rem_Fam_In_Network__c) ;
                        component.set("v.coIns",insList[i].ElixirSuite__Co_Insurance_Fam_In_Network__c);
                        component.set("v.coPayAmt",0);
                    }
                        else if(benDescription == '30 = Health Benefit Plan Coverage' && benLevel!='Self' && insValue=='Out Of Network'){
                            component.set("v.deduc",insList[i].ElixirSuite__Deductible_Rem_Fam_Out_Network__c) ;
                            component.set("v.oopMax",insList[i].ElixirSuite__OOP_Rem_Fam_Out_Network__c) ;
                            component.set("v.coIns",insList[i].ElixirSuite__Co_Insurance_Fam_Out_Of_Network__c);
                            component.set("v.coPayAmt",0);
                        }
                            else if(benDescription == 'AI = Substance Abuse' && insValue=='In Network'){
                                component.set("v.deduc",0) ;
                                component.set("v.oopMax",0) ;
                                component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_In_Net__c);
                                component.set("v.coPayAmt",0);
                            }
                                else if(benDescription == 'AI = Substance Abuse' && insValue=='Out Of Network'){
                                    component.set("v.deduc",0) ;
                                    component.set("v.oopMax",0) ;
                                    component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_Out_Net__c);
                                    component.set("v.coPayAmt",0);
                                }
                                    else if(benDescription == 'CI = Substance Abuse Facility - Inpatient' && insValue=='In Network'){
                                        component.set("v.deduc",0) ;
                                        component.set("v.oopMax",0) ;
                                        component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_In_Net__c);
                                        component.set("v.coPayAmt",0);
                                    }
                                        else if(benDescription == 'CI = Substance Abuse Facility - Inpatient' && insValue=='Out Of Network'){
                                            component.set("v.deduc",0) ;
                                            component.set("v.oopMax",0) ;
                                            component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_Out_Net__c);
                                            component.set("v.coPayAmt",0);
                                        }
                                            else if(benDescription == 'CJ = Substance Abuse Facility - Outpatient' && insValue=='In Network'){
                                                component.set("v.deduc",0) ;
                                                component.set("v.oopMax",0) ;
                                                component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_In_Net__c);
                                                component.set("v.coPayAmt",0);
                                            }
                                                else if(benDescription == 'CJ = Substance Abuse Facility - Outpatient' && insValue=='Out Of Network'){
                                                    component.set("v.deduc",0) ;
                                                    component.set("v.oopMax",0) ;
                                                    component.set("v.coIns",insList[i].ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_Ou_Net__c);
                                                    component.set("v.coPayAmt",0);
                                                }    
            }            
        }   
    },
    
    getProcedure : function(component){
        if(component.find('select1').get('v.value') != ''){      
            component.set("v.AllFlag",false);
            component.set("v.codeCategory",component.find('select1').get('v.value'));
            component.set("v.selectvalueName",'');
            component.set("v.searchRecord",'');
            
            component.set("v.EmptyList",false);
        }else{
            component.set("v.AllFlag",true);
            component.set("v.selectvalueName",'');
            component.set("v.searchRecord",'');
            component.set("v.EmptyList",false);
        }
    },
    searchValue : function(component, event) {
        var currentText = event.getSource().get("v.value");   
        component.set("v.Loading", true);
        if(currentText.length > 0) {
            component.set('v.EmptyList',true);
            
        }
        else {
            component.set('v.EmptyList',false);
        }
        var lstOfProcedures = component.get("v.allProceduresSelectedToOperate");
        console.log('lstOfProcedures--'+lstOfProcedures);
        var arr = [];
        for (var existingId in lstOfProcedures) {
            if(!$A.util.isUndefinedOrNull(lstOfProcedures[existingId].Id)) {
                arr.push(lstOfProcedures[existingId].Id);
            }
        }
        console.log('arr--'+JSON.stringify(arr));
        var action = component.get("c.procedureList");
        action.setParams({
            "searchKeyWord" : currentText,
            "codeCategory" : component.get("v.codeCategory"),
            "alreadyExistingProcedures" :  arr
            
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {              
                component.set("v.searchRecord", response.getReturnValue()); 
                var mapOfProcedures = {};   
                var allProcedures = response.getReturnValue();
                for (var i = 0; i < allProcedures.length; i++) {
                    allProcedures[i].totalContractedPrice = 0.0;
                    mapOfProcedures[allProcedures[i].Id] = allProcedures[i];
                }
                component.set("v.mapOfProcedures",mapOfProcedures);
            }
            else if (STATE === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                } 
            }
            component.set("v.Loading", false);
        });
        $A.enqueueAction(action);
    },
    clearField : function(component){
        component.set("v.selectvalueName",'');
        component.set("v.searchRecord",'');
        component.set("v.EmptyList",false);
    }
    
})