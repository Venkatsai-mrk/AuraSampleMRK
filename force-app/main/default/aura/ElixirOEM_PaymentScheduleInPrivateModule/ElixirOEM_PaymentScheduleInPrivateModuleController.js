({
    init : function(cmp, event, helper) {
        cmp.set("v.loaded",false); 
        cmp.set("v.loaded",true); 
        cmp.set("v.makePaymentButtonDisable",true);
        cmp.set("v.modeOfPayment",""); //Anusha 1/10/22
        cmp.set("v.amountPaid",0.0); //Anusha 1/10/22
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy +'-'+ mm +'-' + dd ;
        cmp.set("v.dateOfPayment",today);
        cmp.set("v.paymentTransactionNumber",""); //Anusha 1/10/22                            
        cmp.set("v.modeOfPaymentLst",[{'label':'Cash'},
                                              {'label':'Cheque'},
                                              {'label':'Credit Card'},
                                              {'label':'EFT'}]); //Anusha -18/10/22
         cmp.set('v.columns1', [
                {label: 'Card Number', fieldName: 'ElixirSuite__Credit_Card_Number__c', type: 'text'},
                {label: 'Expiration Month', fieldName: 'ElixirSuite__Expiration_Month__c', type: 'text'},
                {label: 'Expiration Year', fieldName: 'ElixirSuite__Expiration_Year__c', type: 'text'},
                {label: 'First Name', fieldName: 'ElixirSuite__First_Name_on_Card__c', type: 'text'},
                {label: 'Last Name', fieldName: 'ElixirSuite__Last_Name_on_Card__c', type: 'text'},
            ]);
             
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
        if(val){
            let amountPaid = val;
            let totalAppliedAmount =   cmp.get("v.totalAppliedAmount"); 
            if(!$A.util.isUndefinedOrNull(amountPaid)){
                cmp.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(totalAppliedAmount)));   
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
            // cmp.set("v.totalUnAllocatedAmount",0.0);  
        }
        
    },
    selectedPaymentLineRows : function(component, event, helper) {
             var amt = 0;
             var selectedRows =  event.getParam('selectedRows');  
             component.set("v.selectedPaymentPlanLineRecords",event.getParam('selectedRows'));
             console.log('selectedPaymentPlanLineRecords@@--'+JSON.stringify(component.get("v.selectedPaymentPlanLineRecords")));
             if(selectedRows.length > 10){
                 helper.globalFlagToast(component, event, helper,'You can select upto 10 records!', ' ','error');
                 component.set("v.makePaymentButtonDisable",true); 
             }else{ 
                 var rowList = component.get('v.selectedPaymentPlanLineRecords');
                 console.log('rowList--4',rowList);
                 for(var c=0; c<rowList.length; c++){
                     if(rowList[c].ElixirSuite__Balance_Due__c > 0){
                     amt+=rowList[c].ElixirSuite__Balance_Due__c;
                 }
            }
    		component.set("v.amountPaid",amt);
    		helper.calOnReason(component, event, helper); 
             }
     },
    selectedRows : function(component, event, helper) {
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
        } /*      
        for (var i = 0; i < selectedRows.length; i++) {
            if(!$A.util.isUndefinedOrNull(selectedRows[i].remainingAmount)){
                remainingAmount+=parseInt(selectedRows[i].remainingAmount);         
            }            
        }
        component.set("v.totalAppliedAmount",remainingAmount);
        let amountPaid =   component.get("v.amountPaid"); //replaced 'amountAllocated' with 'amountPaid' by Anusha LX3-5804
        if(!$A.util.isUndefinedOrNull(amountPaid)){
            if(amountPaid){
                component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount)));  
            }
        }*/
        
		helper.calOnReason(component, event, helper); 
        
    },
    calculateAllocations : function(component, event, helper) {
        try{
            /*if(helper.validateAmountPaid(component, event, helper)){
                let amountPaid =   component.get("v.amountPaid");
                if(amountPaid){
                    let remainingAmount =   component.get("v.totalAppliedAmount");
                    if(!$A.util.isUndefinedOrNull(amountPaid)){
                        component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount)));  
                    }
                }
                else {
                    component.set("v.totalUnAllocatedAmount",0.0);  
                }  
            }
            }*/
            helper.validateAmountPaid(component, event, helper);
            helper.calOnReason(component, event, helper); 
        }
        catch(e){
            alert(e);
        }
        
        
        
    },
    onDOSFromChange :  function(cmp, event, helper){
        try{
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            let dosFrom =  new Date(procedureSearchParams.DOSFrom);
            let dosTo =  new Date(procedureSearchParams.DOSTo);
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
                if(dosFrom == '' && dosTo!=''){
                    dosFrom = dosTo;
                     cmp.set("v.procedureSearchParams.DOSFrom",dosTo);
                }
                else if(dosTo=='' && dosFrom!=''){
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
                
                
                if (cmp.get("v.typeofPayment") == 'Insurance Payment'){
                    var action = cmp.get("c.filterAllProcedureOnMasterTransaction");
                }
                if (cmp.get("v.typeofPayment") == 'Private Payment'){
                    var action = cmp.get("c.filterProcedureOnMasterTransaction");
                }
                cmp.set("v.loaded",false); 
                if(dosTo && dosFrom){
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
                if(parseInt(cmp.get("v.totalAppliedAmount"))>parseInt(cmp.get("v.amountAllocated")) && selectedRows.length > 1){ // sagili siva 
                    cmp.set("v.showConfirmDialog",true);    
                }
                else {
                    helper.savePayments(cmp,event,helper);  
                }  
            }
            
        }
        catch(e){
            alert(e);
        }
        
    },
    handleConfirmDialogYes :  function(cmp,event,helper){ 
        helper.savePayments(cmp,event,helper);
    },
    handleConfirmDialogNo :  function(cmp){ 
        cmp.set("v.showConfirmDialog",false);    
    },
    selectedRowsOne : function(component,event,helper) {
        try{
            var selectedLineItems = component.get("v.selectedPaymentPlanLineRecords");
            if (selectedLineItems) {
                var scheduleList = component.get("v.scheduleList");
                for (var i = 0; i < scheduleList.length; i++) {
                    scheduleList[i].isSelected = false;
                }
                component.set("v.scheduleList", scheduleList);
            }
            var amountPaid = component.get("v.amountPaid");
            console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows'))); 
            component.set("v.selectedParentSchedule",event.getParam('selectedRows'));   
            component.set("v.selectedParentScheduleId",event.getParam('selectedRows')[0].Id);  
            //helper.validateAmountPaid(component, event, helper);
            var selectedRows =  event.getParam('selectedRows'); 
            var selectedIds = [];
            var netAmount = []; 
            
            for (var i = 0; i < selectedRows.length; i++) 
            {
                selectedIds.push(selectedRows[i].Id);
                netAmount.push(selectedRows[i].remainingAmount);
            }
            component.set("v.NetAmount",Number(netAmount));
            component.set("v.selectedSchedules",selectedIds);
            
            if(amountPaid > 0 && component.get("v.NetAmount") > 0 && amountPaid > component.get("v.NetAmount")) {
                component.set("v.isAllocatedAmtExceedPaSh", true);
            }else {
                component.set("v.isAllocatedAmtExceedPaSh", false);
            }   
            
            var action = component.get("c.getPaymentLines");
            component.set("v.loaded",false);       
            action.setParams({lst_masterId:selectedIds
                             });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded",true);      
                    component.set("v.scheduleList",response.getReturnValue());
                    component.set("v.hideSchedule",true);
                }
                
            });
            $A.enqueueAction(action);
            //component.set("v.selectedPaymentPlanLineRecords",[]);
        }
        catch(e){
            alert(e);
        }
        
    },
        handleCreditSelectedRow :function(cmp,event){
            console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));  
             cmp.set("v.creditSelectedRows",event.getParam('selectedRows')); 
           var creditCard =  cmp.get("v.creditSelectedRows");
            cmp.set("v.creditCardId",creditCard[0].Id);
        } ,
    
    getField: function (cmp, event, helper) {
        if(cmp.find('select1').get('v.value')==''){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='Cheque'){
            cmp.set("v.cheque",true);
            cmp.set("v.Credit",false);  
            cmp.set("v.creditCardId",''); 
        }
        if(cmp.find('select1').get('v.value')=='Cash'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false);
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='Credit Card'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",true); 
             cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='EFT'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        helper.calOnReason(cmp, event, helper); 
    },handleRowAction: function(component, event, helper){
        var action = event.getParam('action');
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
    }
    
})