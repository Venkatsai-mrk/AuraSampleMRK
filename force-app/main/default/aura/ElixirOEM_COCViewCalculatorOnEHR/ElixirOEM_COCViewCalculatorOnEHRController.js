({
    doInit : function(component) {       
        var acctId = component.get("v.estmateRecordId");
        var action = component.get("c.fetchIndividualRecordDetailsForView");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ cocRecordId :  acctId}); 
        // alert( 'COCId:'+acctId);//correct
        action.setCallback(this, function (response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success COC view'+JSON.stringify(response.getReturnValue()));
                var acctDetails = response.getReturnValue().patientDetails;
                component.set("v.acctDetails",acctDetails);
                if(!$A.util.isEmpty(response.getReturnValue().relatedProcedures)){
                    component.set("v.isProceduresSelected",true);
                    component.set("v.hasCalculationCompleted",true);                    
                }
                component.set("v.insuranceDetails",response.getReturnValue().singleRecordQueried);
                component.set("v.procedureTotal",response.getReturnValue().singleRecordQueried.ElixirSuite__Procedure_Total__c);
                component.set("v.allProceduresSelectedToOperate",response.getReturnValue().relatedProcedures);
                //alert('Unit is:'+response.getReturnValue().relatedProcedures[0].ElixirSuite__Unit__c);
                component.set("v.PatientResposibilityRoundedOff",response.getReturnValue().singleRecordQueried.ElixirSuite__Patient_responsibility__c);
                component.set("v.InsuranceResposibilityRoundedOff",response.getReturnValue().singleRecordQueried.ElixirSuite__Insurer_Responsibility__c);                  
            }
            else{
                //getting errors if callback fails
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
        
    },
    hideProcedures : function(component) {
        component.set("v.isProceduresAvailable",false);
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
        
        component.set("v.isProceduresAvailable",true);
    },
    handleChangeMultiSelectProcedures :  function(component, event) {        
        component.set("v.selectedValues",event.getParam("value"));        
    },
    handleConfirmDialogAddProcedure : function(component, event, helper) {
        
        var selectedValues  =  component.get("v.selectedValues");
        var mapOfProcedures =  component.get("v.mapOfProcedures");    
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
            for(var key in selectedValues){
                dataarr.push(mapOfProcedures[selectedValues[key]]);
            }
            helper.calculatedTotalContractedPriceForEachProcedure(component, event, helper,dataarr);
            helper.calculateTotal(component, event, helper,dataarr);
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            component.set("v.allProceduresSelectedToOperate",dataarr);
            component.set("v.isProceduresAvailable",false);
            component.set("v.isProceduresSelected",true);
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
            toUpdateRecord.totalContractedPrice = toUpdateRecord.ElixirSuite__Days_Units__c *  toUpdateRecord.ElixirSuite__Contracted_Price__c;
            helper.calculateTotal(component, event, helper,selectedProceduresData);
            component.set("v.allProceduresSelectedToOperate",selectedProceduresData);
        }
    },
    handleRemoveRecords : function(component, event, helper) {
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
        helper.calculationInHelper(component, event, helper);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "CALCULATION COMPLETE!",
            "message": "See below the result!"
        });
        toastEvent.fire();    
        
    },
    closeModel : function(component) {
        component.set("v.isConsoleView",false);
        component.set("v.isOpen",false);
    },
    save : function(component) {   
        var action = component.get("c.updateUseStatusForCOCEstimateSingleRecord");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ estimateID :  component.get("v.estmateRecordId"),
                          receivedValue : component.get("v.inUseStatus")                       
                         });        
        action.setCallback(this, function (response){            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title" : "IN-USE STATUS UPDATED SUCCESSFULLY!",
                    "message": "Estimation updated successfully!",
                    
                });
                toastEvent.fire(); 
                
                
                var cmpEvent = component.getEvent("CocViewRefresh"); 
                cmpEvent.fire(); 
                component.get("v.openCOCViewMode",false);
                
                console.log('inside success');
                component.set("v.isConsoleView",false);
                component.set("v.isOpen",false);
                let createEvent = component.getEvent("RefreshEstimatesListView");
                //createEvent.setParams({ "expense": newExpense });
                createEvent.fire();
                
                
            }
            else{
                //getting errors if callback fails
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
        
    },
    isCOCinUsed :function(component, event) { 
        component.set("v.saveButtonAbility",true);
        component.set("v.inUseStatus",event.getSource().get("v.checked"));
        
    }
})