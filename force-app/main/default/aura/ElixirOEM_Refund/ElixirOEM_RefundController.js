({
    myAction : function(cmp, event, helper) {
        helper.setColumns(cmp);
        helper.displayDetails(cmp, event, cmp.get("v.recordId"));
        helper.getPicklistOptions(cmp, event, helper);
        cmp.set("v.data",'');
        cmp.set("v.isSearchDisabled",false);
        cmp.set("v.isProcessButtonDisabled",true);
        cmp.set("v.dateSearchParams",{'From' : '','To' : ''});
        cmp.set("v.refundDateSearchParams",{'From' : '','To' : ''});
        console.log('RefundList',JSON.stringify(cmp.get("v.RefundList"))); 
    },
    handleRefresh: function(cmp, event, helper) {
        helper.displayDetails(cmp, event, cmp.get("v.recordId"));
    },
    onDOSChange :  function(cmp, event, helper){
        try{
            
            let dateSearchParams = cmp.get("v.dateSearchParams");
            console.log('dateSearchParams--'+dateSearchParams);
            if((!$A.util.isUndefinedOrNull(dateSearchParams.To)) && (!$A.util.isUndefinedOrNull(dateSearchParams.From))){      
                
                let dosFrom =  new Date(dateSearchParams.From);
                let dosTo =  new Date(dateSearchParams.To);
                console.log(dosFrom , dosTo );
                if(dosTo && dosFrom){
                    if(dosFrom>dosTo){
                        console.log('inside');
                        helper.globalFlagToast(cmp, event, helper,'DOS From cannot be higher than DOS To!', ' ','error');
                        cmp.set("v.isSearchDisabled",true);
                    }
                    else {
                        cmp.set("v.isSearchDisabled",false); 
                    }   
                }
            }
            else {
                cmp.set("v.isSearchDisabled",false);  
            }
        }
        catch(e){
            alert(e); 
        }
    },
    
    processRefundReq: function(cmp) {
        //Call Child aura method
        var childComponent = cmp.find("issueRefund");
        childComponent.issueRefundRequest();
    },
    
    handleRowAction: function(cmp, event,helper) {
        var data = cmp.get("v.data");
        console.log('data--'+ JSON.stringify(data));
        var action = event.getParam('action');
        var row = event.getParam('row');
        var selectedRows = [];
        selectedRows.push(row);
        cmp.set("v.selectedRefundRows",selectedRows);
        console.log('row-'+JSON.stringify(row));
        if (action.name === 'buttonAction') {
            cmp.set("v.openIssueRefund",true);
            // cmp.set("v.selectedData",JSON.stringify(row));
        }
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(cmp, event,helper);
                    break;
            }
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
    searchApply : function(cmp, event, helper) {
        try{
            var dateSearchParams = cmp.get("v.dateSearchParams");
            if(dateSearchParams.From || dateSearchParams.To){
                var dosFrom =  JSON.parse(JSON.stringify(dateSearchParams.From));
                var dosTo =  JSON.parse(JSON.stringify(dateSearchParams.To));
                if(dosFrom == '' && dosTo!=''){
                    dosFrom = dosTo;
                    cmp.set("v.dateSearchParams.From",dosTo);
                }
                else if(dosTo=='' && dosFrom!=''){
                    // var today = new Date();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(dosFrom>today){
                        dosTo = dosFrom;
                        cmp.set("v.dateSearchParams.To",dosFrom);
                    }
                    else {
                        dosTo = today; 
                        cmp.set("v.dateSearchParams.To",today);
                    }            
                }
                var action = cmp.get("c.filterProcedurebasedOnDOS");
                action.setParams({accid : cmp.get("v.PatientId"),
                                  dosFrom : dosFrom,
                                  dosTo : dosTo});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") { 
                        var result = response.getReturnValue();                        
                        console.log('result ----- ' + JSON.stringify(result));
                        var recordtype = response.getReturnValue().PrivateRecordtypeId;
                        var allDataInsurance =response.getReturnValue().ProcDataForPayment;
                        if(!$A.util.isEmpty(allDataInsurance)){
                            console.log('Insdide');
                            var count2 = 1;
                            for(var recdata in response.getReturnValue().ProcDataForPayment){
                                allDataInsurance[recdata]['SNo'] = count2+'.';
                                allDataInsurance[recdata]['ProcedureCode'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.Name;
                                allDataInsurance[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Status__c;                                if(allDataInsurance[recdata].RecordTypeId == recordtype){
                                    allDataInsurance[recdata]['ElixirSuite__Patient_Responsibility__c'] = allDataInsurance[recdata].ElixirSuite__Expected_Receivable_amount__c;
                                }
                                
                                
                                
                                count2 = count2 + 1;
                            }
                            let allProcedureOnMT = response.getReturnValue().ProcDataForPayment;
                            if(!$A.util.isEmpty(allProcedureOnMT)){
                                allProcedureOnMT.forEach(function(element) {
                                    if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                        console.log('element@@@---'+JSON.stringify(element));
                                        element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                    }
                                });                         
                            }
                            console.log('allProcedureOnMT@@@---'+JSON.stringify(allProcedureOnMT));
                            cmp.set("v.data",allProcedureOnMT);
                        }
                        else{
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different Dates!','error');
                        }
                    }
                });
                $A.enqueueAction(action); 
                
            }
            else {
                helper.globalFlagToast(cmp, event, helper,'DATES NOT MENTIONED!', 'Please apply Date to search!','error');
            }
            
        }
        catch(e){
            alert(e);
        }
        
    },
    
    handleSelect : function(component, event, helper) {
        let checkedValue = event.getSource().get("v.checked");
        let rowIndex = event.getSource().get("v.name");
        var refundItems = component.get("v.refundItems");
        refundItems[rowIndex].selected = checkedValue;
        let selectedRows = [];
        for (let i = 0; i < refundItems.length; i++) {
            
            if(i != rowIndex && checkedValue == true){
                refundItems[i].checkbox = true;
            }
            if( checkedValue == false){
                refundItems[i].checkbox = false;
            }
            if (refundItems[i].selected) {
                selectedRows.push(refundItems[i]);
            }
        }
        refundItems.selected = checkedValue;
        component.set("v.refundItems",refundItems);
        component.set("v.selectedRows", selectedRows);
        console.log('selectedRows--'+ JSON.stringify(selectedRows));
        component.set("v.isProcessButtonDisabled", selectedRows.length === 0);
        helper.getModeOfpay(component, event, helper);
    },
    onDateChange :  function(cmp, event, helper){
        try{
            
            let dateSearchParams = cmp.get("v.refundDateSearchParams");
            console.log('dateSearchParams--'+dateSearchParams);
            if((!$A.util.isUndefinedOrNull(dateSearchParams.To)) && (!$A.util.isUndefinedOrNull(dateSearchParams.From))){      
                
                let dosFrom =  new Date(dateSearchParams.From);
                let dosTo =  new Date(dateSearchParams.To);
                console.log(dosFrom , dosTo );
                if(dosTo && dosFrom){
                    if(dosFrom>dosTo){
                        console.log('inside');
                        helper.globalFlagToast(cmp, event, helper,'From date cannot be higher than To date!', ' ','error');
                        cmp.set("v.isSearchDisabled",true);
                    }
                    else {
                        cmp.set("v.isSearchDisabled",false); 
                    }   
                }
            }
            else {
                cmp.set("v.isSearchDisabled",false);  
            }
        }
        catch(e){
            alert(e); 
        }
    },
    refundSearchApply : function(cmp, event, helper) {
        try{
            var modeOfPaymentOptions =  cmp.get("v.modeOfPaymentOptions");
            var payCardsInfo = cmp.get("v.payInfoList") ;
            console.log('payCardsInfo ----- ' + JSON.stringify(payCardsInfo));
            var dateSearchParams = cmp.get("v.refundDateSearchParams");
            var selectedStatus = cmp.get("v.selectedStatusValue");
            if(dateSearchParams.From || dateSearchParams.To || selectedStatus){
                var dosFrom =  JSON.parse(JSON.stringify(dateSearchParams.From));
                var dosTo =  JSON.parse(JSON.stringify(dateSearchParams.To));
                if(dosFrom == '' && dosTo!=''){
                    dosFrom = dosTo;
                    cmp.set("v.refundDateSearchParams.From",dosTo);
                }
                else if(dosTo=='' && dosFrom!=''){
                    // var today = new Date();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(dosFrom>today){
                        dosTo = dosFrom;
                        cmp.set("v.refundDateSearchParams.To",dosFrom);
                    }
                    else {
                        dosTo = today; 
                        cmp.set("v.refundDateSearchParams.To",today);
                    }            
                }
                var action;
                if(dosFrom != '' && dosTo!=''){
                    action = cmp.get("c.filterRefundDates");
                    action.setParams({accid : cmp.get("v.PatientId"),
                                      dosFrom : dosFrom,
                                      dosTo : dosTo,
                                      seletedStatus: selectedStatus});
                }else{
                    action = cmp.get("c.filterRefundStatus");
                    action.setParams({accid : cmp.get("v.PatientId"),
                                      seletedStatus: selectedStatus});  
                }
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {                       
                        var allData =response.getReturnValue().refundLst;
                        console.log('allData ----- ' + JSON.stringify(allData));
                        if(!$A.util.isEmpty(allData)){
                            allData.forEach(function(element) {
                                var modeOfPayment = element.ElixirSuite__Mode_of_Payment__c;
                                if (modeOfPayment === 'Credit Card' && element.hasOwnProperty('ElixirSuite__Payment_Information__r') 
                                    && element.ElixirSuite__Payment_Information__r.hasOwnProperty('ElixirSuite__Credit_Card_Number__c')) {
                                    var creditCardNumber = element.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c;
                                    var lastFourDigits = creditCardNumber.slice(-4);
                                    modeOfPayment += ' - ' + lastFourDigits;
                                    element.ElixirSuite__Mode_of_Payment__c = modeOfPayment;
                                    
                                }
                                element['Modeofpayment'] = [{label:modeOfPayment,value:modeOfPayment},{label:'Patient Credit',value:'Patient Credit'}];
                            });
                            console.log('allRefundList***',JSON.stringify(allData));
                            cmp.set("v.modeOfPaymentOptions",modeOfPaymentOptions);
                            cmp.set("v.refundItems",allData);
                        }
                        else{
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different Dates!','error');
                        }
                    }
                });
                $A.enqueueAction(action); 
                
            }
            else {
                helper.globalFlagToast(cmp, event, helper,'DATES NOT MENTIONED!', 'Please apply Date to search!','error');
            }
            
        }
        catch(e){
            alert(e);
        }
        
    },
    /*itemsChange : function(component, event) {
        var recsObj = event.getParam("recordList");
        console.log('chking-'+ JSON.stringify(recsObj));
        var uniqueModesOfPayment = [...new Set(recsObj.map(refund => refund.Mode_of_Payment))];
        console.log('uniqueModesOfPayment-'+ JSON.stringify(uniqueModesOfPayment));
        var modeOfPaymentOptions = uniqueModesOfPayment.map(function(modeOfPayment) {
            return { label: modeOfPayment, value: modeOfPayment };
        });
        console.log('modeOfPaymentOptions-'+ JSON.stringify(modeOfPaymentOptions));
        modeOfPaymentOptions.push({ label: "Patient Credit", value: "Patient Credit" });
        // Filter the refund list based on RefundAmount > 0
        var filteredRefunds = recsObj.filter(function(refund) {
            console.log('RefundAmount-'+refund.RefundAmount);
            console.log('parseInt-RefundAmount-'+parseInt(refund.RefundAmount));
            return parseInt(refund.RefundAmount) > 0;
        });
        console.log('filteredRefunds-'+filteredRefunds);
        
        var refundItems = [];
        
        filteredRefunds.forEach(function(refund, index) {
            var refundId = 'RF-' + (index + 1).toString().padStart(3, '0');
            var modeOfPayment = refund.Mode_of_Payment;
            var refundAmount = refund.RefundAmount;
            
            var refundItem = {
                selected: false,
                RefundID: refundId,
                DateCreated: new Date().toLocaleDateString(),
                RefundAmount: refundAmount,
                RefundIssuedDate: '',
                Status: 'Requested',
                ModeOfPayment: modeOfPayment,
                CreditCheckReferenceNumber: ''
            };
            
            refundItems.push(refundItem);
        });
        
        component.set('v.refundItems', refundItems);
        component.set("v.modeOfPaymentOptions", modeOfPaymentOptions);
    },*/
    
    processRefunds :function(cmp, event, helper) {
        try{
            cmp.set("v.loaded",true);
            var action = cmp.get("c.savemethod");
            console.log('selectedRows ----- '+JSON.stringify(cmp.get("v.selectedRows"))); 
            action.setParams({accid : cmp.get("v.PatientId"),
                              refundIds : cmp.get("v.selectedRows")});
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                var wrapRes = response.getReturnValue();
                console.log('wrapRes : '+ JSON.stringify(wrapRes));
                console.log('state',state);
                if (state === "SUCCESS") {
                    if(wrapRes.msgState=='Success'){
                        cmp.set("v.isProcessButtonDisabled", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Info",
                            "message": wrapRes.msgStr,
                            "type" : "success",
                            "mode" : "dismissible"
                        });
                        toastEvent.fire();
                        // cmp.set("v.selectedRows",'');
                        if(cmp.get("v.sendPatientStatements")){
                            var selectedRows = cmp.get("v.selectedRows");
                            var url = '/apex/ElixirSuite__GenerateRefundStatement?tranId=';
                            
                            for (var i = 0; i < selectedRows.length; i++) {
                                if (i > 0) {
                                    url += ',';
                                }
                                url += selectedRows[i].Id;
                            }
                            var newWindow = window.open(url);
                            newWindow.focus();
                            cmp.set("v.selTabId", 'tab1');
                            cmp.set("v.sendPatientStatements", false);
                            helper.handleSuccess(cmp, event, helper);
                            
                        }else{
                            cmp.set("v.selTabId", 'tab1'); 
                            helper.handleSuccess(cmp, event, helper);
                            
                        }
                    }
                    
                    if(wrapRes.msgState=='Error'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": wrapRes.msgStr,
                            "type" : "error",
                            "mode" : "dismissible"
                        });
                        toastEvent.fire();
                        cmp.set("v.loaded",false);
                        return;
                    }
                    
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                        }
                    }
                    cmp.set("v.loaded",false);
                }
                
            });
            $A.enqueueAction(action); 
        }
        catch(e){
            alert(e); 
        }
        
    },
    handleModeOfPayment :function(cmp, event, helper) {
        helper.getModeOfpay(cmp, event, helper);
    }
    
})