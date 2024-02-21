({
    calculatedTotalContractedPriceForEachProcedure : function(component, event, helper,dataArray) {
        //console.log('Data Array is:'+JSON.stringify(dataArray));
        for(var key in dataArray){
            if(!$A.util.isUndefinedOrNull(dataArray[key].Unit) && !$A.util.isUndefinedOrNull(dataArray[key].cPrice)){
                var i = parseFloat(dataArray[key].Unit);
                var k = parseFloat(dataArray[key].cPrice);
                dataArray[key].totalContractedPrice = (i*k).toFixed(2);
            }
            else if(!$A.util.isUndefinedOrNull(dataArray[key].Unit)) {
                dataArray[key].cPrice = 0;  //changed by Avani Jain
                var a = parseFloat(dataArray[key].Unit);
                var b = parseFloat(dataArray[key].cPrice);
                dataArray[key].totalContractedPrice = (a*b).toFixed(2);  
            }
                else if(!$A.util.isUndefinedOrNull(dataArray[key].cPrice)) {
                    dataArray[key].Unit = 1;  
                    var c = parseFloat(dataArray[key].Unit);
                    var d = parseFloat(dataArray[key].cPrice);
                    dataArray[key].totalContractedPrice = (c*d).toFixed(2);  
                }
                    else if($A.util.isUndefinedOrNull(dataArray[key].cPrice && $A.util.isUndefinedOrNull(dataArray[key].cPrice))) {
                        dataArray[key].Unit = 1;  
                        dataArray[key].cPrice = 0;//changed by Avani Jain
                        var e = parseFloat(dataArray[key].Unit);
                        var f = parseFloat(dataArray[key].cPrice);
                        dataArray[key].totalContractedPrice = (e*f).toFixed(2);  
                    }
        }
    },
    calculateTotal : function(component, event, helper,dataArray){
        var getNumbersToAdd = [];
        for(var key in dataArray){
            if(!$A.util.isUndefinedOrNull(dataArray[key].totalContractedPrice)){
                getNumbersToAdd.push(parseFloat(dataArray[key].totalContractedPrice));
            }
        }
        var sum = getNumbersToAdd.reduce(function(a, b){
            return a + b;
        }, 0);
        component.set("v.procedureTotal",sum);
    },
    calculationInHelper: function(component){
        console.log('In helper');
        component.find("Id_spinner").set("v.class" , 'slds-show');
        
        var procTotal  =  JSON.parse(JSON.stringify(component.get("v.procedureTotal")));
        console.log('procTotal----' + procTotal);
        
        var parentNumber = JSON.parse(JSON.stringify(component.get("v.insuranceDetails")));
        console.log('Parent Number:'+parentNumber);
        
        var coPay = 0;
        
        var patientResponsibility = 0;
        var InsuranceResposibility = 0;
        var totalApplicableAmount = 0;
        var coinsur = 0;
        var remaininSecPart = 0;
        var coInsurance1 = component.get("v.coIns");
        var deduct1 = component.get("v.deduc");
        var oopMaxm1 = component.get("v.oopMax");
        var coPayAmount1 = component.get("v.coPayAmt");
        if (Number.isNaN(coInsurance1) || coInsurance1 == "" || coInsurance1 === null) {
            coInsurance1=parseFloat(0);
        }
        if (Number.isNaN(deduct1) || deduct1 == "" || deduct1 === null) {
            deduct1=parseFloat(0);
        }
        if (Number.isNaN(oopMaxm1) || oopMaxm1 == "" || oopMaxm1 === null) {
            oopMaxm1=parseFloat(0);
        }
        if (Number.isNaN(coPayAmount1) || coPayAmount1 == "" || coPayAmount1 === null) {
            coPayAmount1=parseFloat(0);
        }
        
        if(parentNumber.length >= 1) {
            
            if(component.get("v.value1") == 'Use Co-pay for Calculations'){
                coPay = parseFloat(coPayAmount1);
            }
            else{
                coPay = parseFloat(0);
            }
            console.log('Copay:'+coPay);
            var coInsurance = parseFloat(coInsurance1);
            console.log('coInsurance----' + coInsurance);
            
            var remainigDeductible = parseFloat(deduct1);
            console.log('remainigDeductible----' + remainigDeductible);
            
            var oopMax = parseFloat(oopMaxm1);
            console.log('oopMax----' + oopMax);
            
            if(procTotal < remainigDeductible) {
                console.log('procTotal < remainigDeductible---// 300 , 500');
                
                patientResponsibility = procTotal ;
                console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = 0;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff", 0);
                component.set("v.PatientResposibilityRoundedOff",patientResponsibility.toFixed(2));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(procTotal >= remainigDeductible) 
            {
                console.log('procTotal >= remainigDeductible');
                
                totalApplicableAmount = procTotal - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                patientResponsibility = coPay + remainigDeductible + remaininSecPart;
                
                if(patientResponsibility > oopMax) {
                    patientResponsibility = oopMax;                  
                }
                
                InsuranceResposibility = procTotal - patientResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",InsuranceResposibility.toFixed(2));
                component.set("v.PatientResposibilityRoundedOff",patientResponsibility.toFixed(2));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            } else if(remainigDeductible == 0) 
            {
                console.log('remainigDeductible==0');
                
                totalApplicableAmount = procTotal - remainigDeductible;
                console.log('totalApplicableAmount----' + totalApplicableAmount);
                
                coinsur = coInsurance/100;
                console.log('coinsur----' + coinsur);
                
                remaininSecPart = totalApplicableAmount * coinsur;
                console.log('remaininSecPart----' + remaininSecPart);
                
                patientResponsibility = coPay + remaininSecPart;
                
                if(patientResponsibility > oopMax) {
                    patientResponsibility = oopMax;                
                }
                // patientResponsibility = patiResponsibility + coPay;
                // console.log('patientResponsibility----' + patientResponsibility);
                
                InsuranceResposibility = procTotal - patientResponsibility;
                console.log('InsuranceResposibility----' + InsuranceResposibility);
                
                component.set("v.InsuranceResposibility",InsuranceResposibility);
                component.set("v.PatientResposibility",patientResponsibility);
                component.set("v.InsuranceResposibilityRoundedOff",InsuranceResposibility.toFixed(2));
                component.set("v.PatientResposibilityRoundedOff",patientResponsibility.toFixed(2));
                
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
                component.set("v.PatientResposibilityRoundedOff",patientResponsibility.toFixed(2));
                
                if(parentNumber.length == 1) {
                    component.set("v.hasCalculationCompleted",true);
                } else {
                    component.set("v.hasCalculationCompleted",false);
                }
                
            }
            var checkVal  = component.get("v.checkAttribute");
            if(checkVal == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "CALCULATION COMPLETE!",
                    "message": "See below the result!"
                });
                toastEvent.fire();  
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Procedure Removed!",
                    "message": "Procedure Removed successfully!"
                });
                toastEvent.fire();  
                component.set("v.checkAttribute",false);
            }
        }
        else{
            if(component.get("v.selectedPayerRecord").value != 'Private Pay'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error",
                "message": "Please add the VOB details to proceed!"
            });
            toastEvent.fire();     
        }
        }
        
        component.find("Id_spinner").set("v.class" , 'slds-hide');      
    },
    redoInit : function(component) {
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
                
                var ContractedPrice = res.contractPrice;
                component.set("v.ConPrice",ContractedPrice);
                
                //  component.set("v.coPayValue", res.vobResult[0].ElixirSuite__In_Net_Co_Payment__c);
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
    resetData : function(component) {
        component.set("v.hasCalculationCompleted",false);
        component.set("v.isProceduresSelected",false);
        component.set("v.benefitDescriptionValue",'');
        component.set("v.benefitLevelValue",'');
        component.set("v.insuranceTypeValue",'');
        component.set("v.selectvalueName",'');
        component.set("v.searchRecord",'');
        component.set("v.codechange",'');
        component.set("v.EmptyList",false);
        component.set("v.allProceduresSelectedToOperate",[]);
    }
})