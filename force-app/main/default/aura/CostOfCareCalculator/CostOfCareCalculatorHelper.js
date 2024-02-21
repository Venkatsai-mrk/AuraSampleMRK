({
    calculatedTotalContractedPriceForEachProcedure : function(component, event, helper,dataArray) {
        //console.log('Data Array is:'+JSON.stringify(dataArray));
        for(var key in dataArray){
            if(!$A.util.isUndefinedOrNull(dataArray[key].Unit) && !$A.util.isUndefinedOrNull(dataArray[key].cPrice)){
                var i = parseInt(dataArray[key].Unit);
                var k = parseInt(dataArray[key].cPrice);
                dataArray[key].totalContractedPrice = i*k;
            }
            else if(!$A.util.isUndefinedOrNull(dataArray[key].Unit)) {
                dataArray[key].cPrice = 0;  //changed by Avani Jain
                var i = parseInt(dataArray[key].Unit);
                var k = parseInt(dataArray[key].cPrice);
                dataArray[key].totalContractedPrice = i*k;  
            }
                else if(!$A.util.isUndefinedOrNull(dataArray[key].cPrice)) {
                    dataArray[key].Unit = 1;  
                    var i = parseInt(dataArray[key].Unit);
                    var k = parseInt(dataArray[key].cPrice);
                    dataArray[key].totalContractedPrice = i*k;  
                }
                    else if($A.util.isUndefinedOrNull(dataArray[key].cPrice && $A.util.isUndefinedOrNull(dataArray[key].cPrice))) {
                        dataArray[key].Unit = 1;  
                        dataArray[key].cPrice = 0;//changed by Avani Jain
                        var i = parseInt(dataArray[key].Unit);
                        var k = parseInt(dataArray[key].cPrice);
                        dataArray[key].totalContractedPrice = i*k;  
                    }
        }
    },
    calculateTotal : function(component, event, helper,dataArray){
        var getNumbersToAdd = [];
        for(var key in dataArray){
            if(!$A.util.isUndefinedOrNull(dataArray[key].totalContractedPrice)){
                getNumbersToAdd.push(parseInt(dataArray[key].totalContractedPrice));
            }
        }
        var sum = getNumbersToAdd.reduce(function(a, b){
            return a + b;
        }, 0);
        component.set("v.procedureTotal",sum);
    },
    calculationInHelper: function(component, event, helper,dataArray){
        console.log('In helper');
        component.find("Id_spinner").set("v.class" , 'slds-show');

        var procTotal  =  JSON.parse(JSON.stringify(component.get("v.procedureTotal")));
        console.log('procTotal----' + procTotal);
        
        var parentNumber = JSON.parse(JSON.stringify(component.get("v.insuranceDetails")));
        console.log('Parent Number:'+parentNumber);
        
        var coPay = 0;
        
        var patientResponsibility = 0;
        var InsuranceResposibility = 0;
        
        if(parentNumber.length >= 1) {
            
            if(component.get("v.value") == 'Use Co-pay for Calculations'){
                coPay = parseInt(parentNumber[0].ElixirSuite__In_Net_Co_Payment__c);
            }
            console.log('Copay:'+coPay);
            var coInsurance = parseInt(parentNumber[0].ElixirSuite__Deduc_inNtwk_Clientperc__c);
            console.log('coInsurance----' + coInsurance);
            
            var remainigDeductible = parseInt(parentNumber[0].ElixirSuite__in_network_total__c);
            console.log('remainigDeductible----' + remainigDeductible);
            
            var oopMax = parseInt(parentNumber[0].ElixirSuite__out_of_network_outOfPocket_total__c);
            console.log('oopMax----' + oopMax);
            
            if(procTotal < remainigDeductible) {
                console.log('procTotal < remainigDeductible');
                
                patientResponsibility = procTotal + coPay;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = 0;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff", 0);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(procTotal >= remainigDeductible) {
                console.log('procTotal >= remainigDeductible');
                
                var totalApplicableAmount = procTotal - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remainigDeductible + remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                patientResponsibility = patiResponsibility + coPay;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = procTotal - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(remainigDeductible == 0) {
                console.log('remainigDeductible==0');
                
                var totalApplicableAmount = procTotal - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                patientResponsibility = patiResponsibility + coPay;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = procTotal - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(procTotal > oopMax) {
                console.log('procTotal > oopMax');
                
                var patiResponsibility = oopMax;
                console.log('patiResponsibility----' + patiResponsibility);
                
                patientResponsibility = patiResponsibility + coPay;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = procTotal - oopMax;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",InsuranceResposibility);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            }
            
        }
        
        if(parentNumber.length >= 2) {
            
            if(component.get("v.value") == 'Use Co-pay for Calculations'){
                coPay = parseInt(parentNumber[1].ElixirSuite__In_Net_Co_Payment__c);
            }
            
            var coInsurance = parseInt(parentNumber[1].ElixirSuite__Deduc_inNtwk_Clientperc__c);
            console.log('coInsurance----' + coInsurance);
            
            var remainigDeductible = parseInt(parentNumber[1].ElixirSuite__in_network_total__c);
            console.log('remainigDeductible----' + remainigDeductible);
            
            var oopMax = parseInt(parentNumber[1].ElixirSuite__out_of_network_outOfPocket_total__c);
            console.log('oopMax----' + oopMax);
            
            if(patientResponsibility < remainigDeductible) {
                console.log('patientResponsibility < remainigDeductible');
                
                patientResponsibility = patientResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + 0;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff", 0);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
               
                if(parentNumber.length == 2) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(patientResponsibility >= remainigDeductible) {
                console.log('patientResponsibility >= remainigDeductible');
                
                var totalApplicableAmount = patientResponsibility - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remainigDeductible + remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 2) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(remainigDeductible == 0) {
                console.log('remainigDeductible==0');
                
                var totalApplicableAmount = patientResponsibility - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 2) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(patientResponsibility > oopMax) {
                console.log('patientResponsibility > oopMax');
                
                var patiResponsibility = oopMax;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - oopMax;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",InsuranceResposibility);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                
                if(parentNumber.length == 2) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
            }
            
        }
        
        if(parentNumber.length >= 3) {
            
            if(component.get("v.value") == 'Use Co-pay for Calculations'){
                coPay = parseInt(parentNumber[1].ElixirSuite__In_Net_Co_Payment__c);
            }
            
            var coInsurance = parseInt(parentNumber[2].ElixirSuite__Deduc_inNtwk_Clientperc__c);
            console.log('coInsurance----' + coInsurance);
            
            var remainigDeductible = parseInt(parentNumber[2].ElixirSuite__in_network_total__c);
            console.log('remainigDeductible----' + remainigDeductible);
            
            var oopMax = parseInt(parentNumber[2].ElixirSuite__out_of_network_outOfPocket_total__c);
            console.log('oopMax----' + oopMax);
            
            if(patientResponsibility < remainigDeductible) {
                console.log('patientResponsibility < remainigDeductible');
                
                patientResponsibility = patientResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + 0;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff", 0);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                component.set("v.hasCalculationCompleted",true);
                
            } else if(patientResponsibility >= remainigDeductible) {
                console.log('patientResponsibility >= remainigDeductible');
                
                var totalApplicableAmount = patientResponsibility - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remainigDeductible + remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                component.set("v.hasCalculationCompleted",true);
                
            } else if(remainigDeductible == 0) {
                console.log('remainigDeductible==0');
                
                var totalApplicableAmount = patientResponsibility - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                var coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                var remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                var patiResponsibility = remaininSecPart;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - patiResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",Math.round(InsuranceResposibility));
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                component.set("v.hasCalculationCompleted",true);
                
            } else if(patientResponsibility > oopMax) {
                console.log('patientResponsibility > oopMax');
                
                var patiResponsibility = oopMax;
                console.log('patiResponsibility----' + patiResponsibility);
                
                InsuranceResposibility = InsuranceResposibility + patientResponsibility - oopMax;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                patientResponsibility = patiResponsibility;
                console.log('patientResponsibility----' + patientResponsibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",InsuranceResposibility);
                component.set("v.PatientResposibilityRoundedOff",Math.round(patientResponsibility));
                component.set("v.hasCalculationCompleted",true);
            }
        }
        component.find("Id_spinner").set("v.class" , 'slds-hide');      
    },
    redoInit : function(component, event, helper) {
        var acctId = component.get("v.recordId");
        if(!$A.util.isUndefinedOrNull(acctId)){
            component.set("v.onPatient",true);
            component.set("v.reset",false);
        }
        else{
            component.set("v.onPatient",false);
            component.set("v.reset",true);
        }
        var action = component.get("c.parentInit_FetchDataForCOC");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                console.log(res);
                
                component.set("v.selectRecordId", acctId);
                
                var b = [];
                var mapOfProcedures = {};
                
                var acctDetails = res.acctDetailsFromVOB[0];
                component.set("v.acctDetails",acctDetails);
                component.set("v.selectRecordName", acctDetails.ElixirSuite__Account__r.Name);
                
                var ContractedPrice = res.ContractPrice;
                component.set("v.ConPrice",ContractedPrice);
                
                component.set("v.coPayValue", res.vobResult[0].ElixirSuite__In_Net_Co_Payment__c);
                component.set("v.insuranceDetails",res.vobResult);
                
                var allProcedures = res.allProcedures;
                
                for (var i = 0; i < allProcedures.length; i++) {
                    // childRecords.push();
                    b.push({
                        'label': allProcedures[i]['Name'],
                        'value': allProcedures[i]['Id']                                              
                    });  
                    allProcedures[i].totalContractedPrice = 0;
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
   
})