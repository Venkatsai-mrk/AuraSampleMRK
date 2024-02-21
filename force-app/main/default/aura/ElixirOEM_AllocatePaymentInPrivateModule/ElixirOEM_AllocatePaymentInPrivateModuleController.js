({
    init : function(cmp, event, helper) {
        cmp.set("v.loaded",false); 
        cmp.set("v.loaded",true);
        cmp.set("v.amountAllocated",0); //Anusha
        cmp.set("v.makePaymentButtonDisable",true);//AK
        
        var cmpEvent1 = $A.get("e.c:PaymentEvent");
        cmpEvent1.setParams({
            "firstLabel" :  'Total Applied Amount',
            "secondLabel":'Total Unallocated amount',
            "firstValue":0,
            "secondValue":0
        });
        cmpEvent1.fire();
        
        helper.setDefaultJSON(cmp, event, helper);
        helper.initPayloadCall(cmp, event, helper);
    },
    
    totalAppliedAmountChange : function(cmp, event) {
        console.log("totalAppliedAmountChange has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
        
        var cmpEvent1 = $A.get("e.c:PaymentEvent");
        cmpEvent1.setParams({
            "firstLabel" :  'Total Applied Amount',
            "secondLabel":'Total Unallocated amount',
            "firstValue":event.getParam("value"),
            "secondValue":cmp.get("v.totalUnAllocatedAmount")
        });
        cmpEvent1.fire();
        
    },    
    
    totalUnAllocatedAmountChange : function(cmp, event) {
        console.log("totalUnAllocatedAmountChange has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
        
        var cmpEvent1 = $A.get("e.c:PaymentEvent");
        cmpEvent1.setParams({
            "firstLabel" :  'Total Applied Amount',
            "secondLabel":'Total Unallocated amount',
            "firstValue":cmp.get("v.totalAppliedAmount"),
            "secondValue":event.getParam("value")
        });
        cmpEvent1.fire();
        
    },
    
    validateAmtAllocated :function(cmp, event, helper) {
        let val =  event.getSource().get("v.value");
        /*
        if(val>0){
            let amountPaid = val;
            let totalAppliedAmount =   cmp.get("v.totalAppliedAmount"); 
            if(!$A.util.isUndefinedOrNull(amountPaid)){
              cmp.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(totalAppliedAmount))); //uncommented by Anusha - LX3-5803
              // Venkat sai
              // cmp.set("v.totalUnAllocatedAmount",(parseInt(totalAppliedAmount)-parseInt(amountPaid))); //commmented by Anusha - LX3-5803
            }
           else {
             cmp.set("v.totalUnAllocatedAmount",0.0);  
            }
            if(val>cmp.get("v.totalUnAllocatedAmount_SumCount")){
                helper.globalFlagToast(cmp, event, helper,'INVALID AMOUNT ALLOCATED!', 'Amount Allocated cannot be greater than Total Unallocated Amount!','error');  
                cmp.set("v.makePaymentButtonDisable",true); 
            }
            else {
                cmp.set("v.makePaymentButtonDisable",false);  
            } 
        }
        else {
             cmp.set("v.totalUnAllocatedAmount",0.0);  
        }*/
        let amountPaid = cmp.get("v.amountAllocated");
        if(!$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0){
            if(val > cmp.get("v.totalUnAllocatedAmount_SumCount")){
                helper.globalFlagToast(cmp, event, helper,'INVALID AMOUNT ALLOCATED!', 'Amount Allocated cannot be greater than Total Unallocated Amount!','error');  
                cmp.set("v.makePaymentButtonDisable",true); 
            }
            var selectedRows = cmp.get("v.selectedProcedureRecords");
            let remainingAmount = 0;
            if(selectedRows.length > 0){
                
                for (var i = 0; i < selectedRows.length; i++) {
                    if(!$A.util.isUndefinedOrNull(selectedRows[i].remainingAmount)){
                        remainingAmount+=parseInt(selectedRows[i].remainingAmount);         
                    }            
                }
                if(parseFloat(remainingAmount) > parseFloat(cmp.get('v.amountAllocated'))){
                    cmp.set("v.totalAppliedAmount",parseFloat(amountPaid));  
                }else{
                    cmp.set("v.totalAppliedAmount",parseFloat(remainingAmount));  
                }
                cmp.set("v.totalUnAllocatedAmount",(parseFloat(amountPaid) - parseFloat(cmp.get("v.totalAppliedAmount"))));
                
            }else{
                cmp.set("v.totalAppliedAmount",0);
                cmp.set("v.totalUnAllocatedAmount",(parseFloat(amountPaid)));
            }
        }else{
            cmp.set("v.totalUnAllocatedAmount",0);
        }
        
        if(cmp.get("v.selectedProcedureRecords").length > 0 && !$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0 && !$A.util.isUndefinedOrNull(cmp.get("v.totalUnAllocatedAmount_SumCount")) && parseInt(cmp.get("v.totalUnAllocatedAmount_SumCount")) >0){
            cmp.set("v.makePaymentButtonDisable",false); 
        }else{
            cmp.set("v.makePaymentButtonDisable",true);  
        }
        
        
        
    },
    selectedRows : function(component, event) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        let remainingAmount = 0;
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedProcedureRecords",event.getParam('selectedRows'));
        let selectedProcedureRecordsNetInstance = component.get("v.selectedProcedureRecordsNetInstance"); 
        if($A.util.isEmpty(event.getParam('selectedRows'))){
            component.set("v.selectedProcedureRecordsNetInstance",[]); 
        }
        else {
            selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(event.getParam('selectedRows'));
            component.set("v.selectedProcedureRecordsNetInstance",selectedProcedureRecordsNetInstance); 
        }       
        for (var i = 0; i < selectedRows.length; i++) {
            if(!$A.util.isUndefinedOrNull(selectedRows[i].remainingAmount)){
                remainingAmount+=parseInt(selectedRows[i].remainingAmount);         
            }            
        }
        let amountPaid =   component.get("v.amountAllocated");
        
        /*
        component.set("v.totalAppliedAmount",remainingAmount);
        if(!$A.util.isUndefinedOrNull(amountPaid)){
            if(amountPaid){
                // Venkat sai
                //component.set("v.totalUnAllocatedAmount",(parseInt(remainingAmount)-parseInt(amountPaid))); //commmented by Anusha - LX3-5803
                component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount))); //uncommmented by Anusha - LX3-5803
            } else {
                component.set("v.totalUnAllocatedAmount",0.0);
            }
            
        } 
        else {
            component.set("v.totalUnAllocatedAmount",0.0);  
        } 
        */
        if(!$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0){
            
            if(parseFloat(remainingAmount) > parseFloat(component.get('v.amountAllocated'))){
                component.set("v.totalAppliedAmount",parseFloat(amountPaid));  
            }else{
                component.set("v.totalAppliedAmount",parseFloat(remainingAmount));  
            }
            component.set("v.totalUnAllocatedAmount",(parseFloat(amountPaid) - parseFloat(component.get("v.totalAppliedAmount"))));
        }else{
            component.set("v.totalAppliedAmount",0);  
            component.set("v.totalUnAllocatedAmount",0);             
        }
        
        if(component.get("v.selectedProcedureRecords").length > 0 && !$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0 && !$A.util.isUndefinedOrNull(component.get("v.totalUnAllocatedAmount_SumCount")) && parseInt(component.get("v.totalUnAllocatedAmount_SumCount")) >0 && parseFloat(amountPaid) <= parseFloat(component.get("v.totalUnAllocatedAmount_SumCount")) ){
            component.set("v.makePaymentButtonDisable",false); 
        }else{
            component.set("v.makePaymentButtonDisable",true);  
        }
        
        
        
        
    },
    calculateAllocations : function(component) {
        let amountPaid =   component.get("v.amountPaid");
        if(amountPaid){
            let remainingAmount =   component.get("v.totalAppliedAmount");
            if(!$A.util.isUndefinedOrNull(amountPaid)){
                // Venkat sai
                //component.set("v.totalUnAllocatedAmount",(parseInt(remainingAmount)-parseInt(amountPaid))); //commmented by Anusha - LX3-5803
                component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount))); //uncommmented by Anusha - LX3-5803
            }
        }
        else {
            component.set("v.totalUnAllocatedAmount",0.0);  
        }
        
    },
    onDOSFromChange :  function(cmp, event, helper){
        try{
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            let dosFrom =  new Date(procedureSearchParams.DOSFrom);
            let dosTo =  new Date(procedureSearchParams.DOSTo);
            if(dosTo.toString() == (new Date(null)).toString()){ //Anusha -Start LX3-5803
                return
            } //Anusha -end - LX3-5803
            if(dosTo){
                if(dosFrom>dosTo){
                    helper.globalFlagToast(cmp, event, helper,'DOS From cannot be higher than DOS To!', ' ','error');
                    cmp.set("v.isSearchDisabled",true);
                }
                else {
                    cmp.set("v.isSearchDisabled",false); 
                }   
            }
        }
        catch(e){
            alert(e); 
        }
    },
    onDOSToChange : function(cmp, event, helper){
        try{
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            let dosFrom =  new Date(procedureSearchParams.DOSFrom);
            let dosTo =  new Date(procedureSearchParams.DOSTo);
            if(dosFrom){
                if(dosTo.toString() == (new Date(null)).toString()){ //Anusha -Start LX3-5803
                    cmp.set("v.isSearchDisabled",false); //Anusha -27/10/22 -LX3-5803
                    return
                } //Anusha -end - LX3-5803
                if(dosFrom>dosTo){
                    helper.globalFlagToast(cmp, event, helper,'DOS From cannot be higher than DOS To!', ' ','error');
                    cmp.set("v.isSearchDisabled",true);
                }
                else {
                    cmp.set("v.isSearchDisabled",false); 
                }   
            }   
        }
        catch(e){
            alert(e); 
        }
        
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
    searchClaim :  function(cmp,event,helper){ 
        try{
            
            var procedureSearchParams = cmp.get("v.procedureSearchParams");
            if(procedureSearchParams.DOSFrom || procedureSearchParams.DOSTo || procedureSearchParams.procedureName 
               || procedureSearchParams.CPTCode){
                
                var dosFrom =  JSON.parse(JSON.stringify(procedureSearchParams.DOSFrom));
                var dosTo =  JSON.parse(JSON.stringify(procedureSearchParams.DOSTo));
                if((dosFrom == '' || $A.util.isUndefinedOrNull(dosFrom)) && dosTo!=''){ //added '|| $A.util.isUndefinedOrNull(dosFrom)' by Anusha - LX3-5803
                    dosFrom = dosTo;
                    cmp.set("v.procedureSearchParams.DOSFrom",dosTo);
                }
                else if((dosTo=='' || $A.util.isUndefinedOrNull(dosTo)) && dosFrom!=''){ //added '|| $A.util.isUndefinedOrNull(dosTo)' by Anusha - LX3-5803
                    // var today = new Date();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(dosFrom>today){
                        dosTo = dosFrom;
                        cmp.set("v.procedureSearchParams.DOSTo",dosFrom);
                    }
                    else {
                        dosTo = today;
                        cmp.set("v.procedureSearchParams.DOSTo",today);
                    }            
                }
                //commented by sagili siva not to iterate over the same procedure multiple items as mentioned in LX3-5838
                
                /*var selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecordsNetInstance");
                var eisitngIdArr = [];
                selectedProcedureRecordsNetInstance.forEach(function(element, index) {
                    eisitngIdArr.push(element.Id);
                });*/
                
                //Added by sagili siva as per the requirement in LX3-5838
                
                var selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecords");
                console.log('selectedProcedureRecordsNetInstance'+selectedProcedureRecordsNetInstance);
                var selectedProcedureRecordsNetInstance1 =  helper.filterDuplicates(cmp, event, helper,selectedProcedureRecordsNetInstance);
                // cmp.set("v.selectedProcedureRecords",selectedProcedureRecordsNetInstance1);
                console.log('selectedProcedureRecordsNetInstance'+selectedProcedureRecordsNetInstance1);
                var eisitngIdArr = [];
                selectedProcedureRecordsNetInstance1.forEach(function(element) {
                    eisitngIdArr.push(element.Id);
                    console.log('eisitngIdArr'+eisitngIdArr);
                });
                
                var action = cmp.get("c.filterProcedureOnMasterTransaction");
                cmp.set("v.loaded",false); 
                if(dosTo && dosTo){
                    action.setParams({dosFrom : dosFrom,
                                      dosTo : dosTo,
                                      procedureName : procedureSearchParams.procedureName,
                                      CPTCode : procedureSearchParams.CPTCode,
                                      acctId : cmp.get("v.PatientId"),
                                      eisitngIdArr : eisitngIdArr 
                                     });     
                }
                else{
                    action.setParams({
                        procedureName : procedureSearchParams.procedureName,
                        CPTCode : procedureSearchParams.CPTCode,
                        acctId : cmp.get("v.PatientId"),
                        eisitngIdArr : eisitngIdArr 
                    }); 
                }
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        cmp.set("v.loaded",true);
                        
                        var result = response.getReturnValue();
                        console.log('search result ' + JSON.stringify(result));
                        let allProcedureOnMT = result.allProcedureOnMT;
                        if(!$A.util.isEmpty(allProcedureOnMT)){
                            let count = 1;
                            allProcedureOnMT.forEach(function(element) {
                                element['SNo'] = count;
                                if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                    element['procedureName'] = element.ElixirSuite__Procedure__r.Name;
                                    element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                }
                                helper.setRemainingAmount(cmp, event, helper,element);
                                count++;
                            }); 
                            helper.sortSelectedProcedures(cmp,'ElixirSuite__Date_Of_Service__c','desc',selectedProcedureRecordsNetInstance);
                            selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(allProcedureOnMT);
                            cmp.set("v.Plist",selectedProcedureRecordsNetInstance);
                        }
                        else {
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different filter!','error');
                        }
                        helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                        
                    }
                    
                });
                $A.enqueueAction(action);  
            }
            else {
                helper.globalFlagToast(cmp, event, helper,'NO FILTER APPLIED!', 'Please apply filter to search!','error');
            }
        }
        catch(e){
            alert(e);
        }
        
    },
    clearClaimSearchFilter :  function(cmp,event,helper){  
        helper.setDefaultJSON(cmp, event, helper);
        helper.keepSelectedProcedures(cmp, event, helper);
        cmp.set("v.isSearchDisabled",false); // Added by sagili siva :Lx3-5827        
    },
    allocatePaymentFromUI :  function(cmp,event,helper){ 
        try{
            var selectedRows =  cmp.get("v.selectedProcedureRecords");
            console.log(selectedRows.length);
            if(helper.checkRequieredValidity(cmp,event,helper)){
                if(!cmp.get("v.amountAllocated") || parseInt(cmp.get("v.amountAllocated"))==0){
                    if(parseInt(cmp.get("v.totalAppliedAmount"))>parseInt(cmp.get("v.totalUnAllocatedAmount_SumCount")) && selectedRows.length > 1){
                        cmp.set("v.showConfirmDialogIfNoAllocation",true);    
                    }
                    else {
                        helper.savePayments(cmp,event,helper,true);  
                    }
                }
                else {
                    if(parseInt(cmp.get("v.totalAppliedAmount"))>parseInt(cmp.get("v.amountAllocated")) && selectedRows.length > 1){
                        cmp.set("v.showConfirmDialog",true);    
                    }
                    else {
                        helper.savePayments(cmp,event,helper,false);  
                    }  
                }
            }
            
        }
        catch(e){
            alert(e);
        }
        
    },
    handleConfirmDialogYes :  function(cmp,event,helper){ 
        helper.savePayments(cmp,event,helper,false);
    },
    handleConfirmDialogNo :  function(cmp){ 
        cmp.set("v.showConfirmDialog",false);    
    },
    handleConfirmDialogYes_NoAllocation :  function(cmp,event,helper){ 
        helper.savePayments(cmp,event,helper,true);
    }, 
    handleConfirmDialogNo_NoAllocation :  function(cmp){ 
        cmp.set("v.showConfirmDialogIfNoAllocation",false);    
    },
    handleRowAction: function(component, event, helper){
        var action = event.getParam('action');
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
    },
})