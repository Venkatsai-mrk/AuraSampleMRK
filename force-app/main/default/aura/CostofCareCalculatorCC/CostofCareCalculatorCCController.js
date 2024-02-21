({
    doInit : function(component, event, helper) {
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        
        $A.enqueueAction(action3);
        if(component.get("v.ContactCentr") == true)
        {
        
        var acctId = component.get("v.recordId");
        console.log("AcctId:"+acctId);
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
        action.setParams({ recordId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                console.log('RES'+res);
                if($A.util.isEmpty(res.insuranceDetails))
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "Please verify your Insurance Details!",
                        "message": "Select your Payor and Type!",
                
            });
            toastEvent.fire();
            component.set("v.disable",true);
                }
                else{
                    if(
                    $A.util.isUndefinedOrNull(res.insuranceDetails[0].ElixirSuite__Type__c) || 
                    $A.util.isEmpty(res.insuranceDetails[0].ElixirSuite__Type__c)
                    ){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title" : "Please verify your Insurance Details!",
                            "message": "Select your Type!",
                            
                        });
                        toastEvent.fire();
                        component.set("v.disable",true);
                    }
 			         
  					else if(
                    $A.util.isUndefinedOrNull(res.insuranceDetails[0].ElixirSuite__Payer__r) || 
                    $A.util.isEmpty(res.insuranceDetails[0].ElixirSuite__Payer__r)
                    ){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title" : "Please verify your Insurance Details!",
                            "message": "Select your Payor Name!",
                            
                        });
                        toastEvent.fire();
                        component.set("v.disable",true);
                    }
        }
                
                 if((
                    $A.util.isUndefinedOrNull(res.vobResult[0].ElixirSuite__Deductible_Individual_Out_Plan_Network__c)|| 
                    $A.util.isEmpty(res.vobResult[0].ElixirSuite__Deductible_Individual_Out_Plan_Network__c)
                	) ||
                    (
                    $A.util.isUndefinedOrNull(res.vobResult[0].ElixirSuite__Deduc_inNtwk_Clientperc__c)|| 
                    $A.util.isEmpty(res.vobResult[0].ElixirSuite__Deduc_inNtwk_Clientperc__c)
                	) ||
 			(
            $A.util.isUndefinedOrNull(res.vobResult[0].ElixirSuite__out_of_network_outOfPocket_total__c) || 
  			$A.util.isEmpty(res.vobResult[0].ElixirSuite__out_of_network_outOfPocket_total__c)
            )){
            	 var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                "type": "warning",
                "title" : "Result Details not filled!",
                "message": "Fill the required fields!",
                
            });
            toastEvent.fire();
            component.set("v.disable",true);
        }
                
     
                
                component.set("v.selectRecordId", acctId);
                
                var b = [];
                var mapOfProcedures = {};
                
                var acctDetails = res.acctDetailsFromVOB[0];
                component.set("v.acctDetails",acctDetails);
                component.set("v.selectRecordName", acctDetails.ElixirSuite__Opportunity__r.Name);
                
                var ContractedPrice = res.ContractPrice;
                component.set("v.ConPrice",ContractedPrice);
                
                component.set("v.coPayValue", res.vobResult[0].ElixirSuite__In_Net_Co_Payment__c);
                var allProcedures = res.allProcedures;
                var insdet=[];
                insdet=res.insuranceDetails;
                var vobres=[];
                vobres=res.vobResult;
                vobres[0].ElixirSuite__Payer_Name__c=insdet[0].ElixirSuite__Payer__r.Name; 
                console.log('Payer name:'+vobres[0].ElixirSuite__Payer_Name__c);
                vobres[0].ElixirSuite__Insurance_Type__c=insdet[0].ElixirSuite__Type__c;
                component.set("v.insuranceDetails",vobres);
            for (var i = 0; i < allProcedures.length; i++) {
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
    hideProcedures : function(component, event, helper) {
        component.set("v.isProceduresAvailable",false);
    },
    openProcedures : function(component, event, helper) {
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
                var res = response.getReturnValue();              
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
    handleChangeMultiSelectProcedures :  function(component, event, helper) {        
        component.set("v.selectedValues",event.getParam("value"));        
    },
    handleConfirmDialogAddProcedure : function(component, event, helper) {
        
        var selectedValues  =  component.get("v.selectedValues");
        //alert(selectedValues);
        var mapOfProcedures =  component.get("v.mapOfProcedures");    
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
            for(var key in selectedValues){
                dataarr.push(mapOfProcedures[selectedValues[key]]);
            }
            for (var i in dataarr){
                for(var j in Contprice){
                    if(dataarr[i].Id == Contprice[j].ElixirSuite__Procedure__c){
                        dataarr[i]['cPrice']=Contprice[j].ElixirSuite__Contracted_Amount__c;
                        dataarr[i]['Unit']=Contprice[j].ElixirSuite__Units__c;
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
            toUpdateRecord.totalContractedPrice = toUpdateRecord.Unit *  toUpdateRecord.cPrice;
            helper.calculateTotal(component, event, helper,selectedProceduresData);
            component.set("v.allProceduresSelectedToOperate",selectedProceduresData);
        }
    },
    handleRemoveRecords : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
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
    closeModel : function(component, event, helper) {
        component.set("v.isOpen",false);
        $A.get("e.force:closeQuickAction").fire(); //added by Avani Jain 
    },
    save : function(component, event, helper) {  
        //console.log('1');
        var acctId = component.get("v.recordId");
        //console.log('2');
        var Changedcopay = 0;
        console.log('The value is:'+component.get("v.value"));
        //console.log('3');
        if(component.get("v.value") == 'Use Co-pay for Calculations'){
            console.log('31');
            Changedcopay = component.find('copay').get('v.value');
            console.log('32');
        }
        
        //console.log('4');
        var patientResponisibility = component.get("v.PatientResposibilityRoundedOff");
        //console.log('5');
        var InsuranceResposibilityRoundedOff = component.get("v.InsuranceResposibilityRoundedOff");
       // console.log('6');
        var action = component.get("c.saveCOC");
        //console.log('7');
        var insuranceDetailsToSave = {'keysToSave' : component.get("v.insuranceDetails")};
        //console.log('8');
        var proceduresToSave = {'keysToSaveForPrcedures' : component.get("v.allProceduresSelectedToOperate")};
        //console.log('9');
        component.find("Id_spinner").set("v.class" , 'slds-show');
        console.log('10');
        console.log('acctId:----' + acctId);
        console.log('patientResponisibility:----' + patientResponisibility);
        console.log('InsuranceResposibilityRoundedOff:----' + InsuranceResposibilityRoundedOff);
        console.log(component.get("v.procedureTotal"));
        console.log(insuranceDetailsToSave);
        console.log(proceduresToSave);
        console.log(component.get("v.inUseStatus"));
        console.log('Changedcopay:----' + Changedcopay);
        
        action.setParams({ 
            recordId :  acctId,
            patientResponsibility : patientResponisibility,
            insuranceResposibility : InsuranceResposibilityRoundedOff,
            procedureTotal : component.get("v.procedureTotal"),
            insuranceDetails :  JSON.stringify(insuranceDetailsToSave),
            proceduresToSave :  JSON.stringify(proceduresToSave),
            receivedValue : component.get("v.inUseStatus"),
            copay:Changedcopay
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
                component.set("v.isOpen",false);
                $A.get("e.force:closeQuickAction").fire(); //added by Avani Jain
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
    searchField : function(component, event, helper) {
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
            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {  
                    
                }
            }
            component.set("v.LoadingText", false);
        });
        $A.enqueueAction(action);
        
    },
    setSelectedRecord : function(component, event, helper) {
        component.set('v.EmpList',false);
        var currentText = event.currentTarget.id;
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        if(event.currentTarget.dataset.name=='Other | N/A'){
            component.set("v.EmpOther",true);
        }
        else{ component.set("v.EmpOther",false);
            }
        component.set("v.selectRecordId", currentText);
        var action = component.get("c.parentInit_FetchDataForCOC");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ recordId :  currentText});        
        action.setCallback(this, function (response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success');
                var b = [];
                var mapOfProcedures = {};
                //add key to all records to keep an eye on which one is selected.
                var res = response.getReturnValue();
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
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.set("v.insuranceDetails","");
        helper.redoInit(component, event, helper);
    },
    handleChange: function (component, event) {
        //alert(component.find("mygroup").get("v.value"));
        
        console.log('1');
        if(component.find("mygroup").get("v.value")=='Use Co-pay for Calculations'){
            console.log('2');
            component.set("v.useCopay", false);
            console.log('3');
        }
        else{
            console.log('4');
            component.set("v.useCopay", true);
            console.log('5');
            component.set("v.value", '');
            console.log('6');
        }
    },
    isCOCinUsed :function(component, event, helper) { 
        
        component.set("v.inUseStatus",event.getSource().get("v.checked"));
        
    }
})