({
    setColumns: function(cmp) {
        cmp.set('v.columns', [
            {label: 'S.No', fieldName: 'SNo', type: 'text', sortable :true, initialWidth: 50}  ,
             {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base',initialWidth: 250 }},
            //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true, initialWidth: 250}  ,
            //{label: 'Procedure Code', fieldName: 'ProcedureCode', type: 'text', sortable :true}  , 
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true},
            {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amt.', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true},
            {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true},
            {label: 'Patient Paid Amt.', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true},
            {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true},
            { label: '', type: 'button', initialWidth: 150, typeAttributes: { label: 'Issue Refund', name: 'buttonAction', variant: 'brand', size: 'small' } }
        ]);
        cmp.set("v.picklistOptions", [
            { label: 'Requested', value: 'Requested' },
            { label: 'Issued', value: 'Issued' },
            { label: 'Denied', value: 'Denied' },
            { label: 'All', value: 'All' }
        ]);
        
    },
    setDefaultJSON : function(component) {
        let defaultJSON = 
            {'selected' : false,
             'RefundID' : '',
             'DateCreated' :  new Date(),
             'RefundAmount' : 0,
             'RefundIssuedDate':'',
             'ModeOfPayment' : '',
             'Status' : '',
             'CreditCheckReferenceNumber':0
            };
        component.set("v.refundItems",defaultJSON);
    },
    displayDetails : function(cmp)
    {
        var modeOfPaymentOptions =  cmp.get("v.modeOfPaymentOptions");
        var action = cmp.get("c.getData");
        action.setParams({accid:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                console.log('result ----- ' + JSON.stringify(result));
                
                var recordtype = response.getReturnValue().PrivateRecordtypeId;
                var allDataInsurance =response.getReturnValue().ProcDataForPayment;
                
                var allRefundList = result.patientRefundLst;
                var payCardsInfo = result.paymentInfo;
                cmp.set("v.payInfoList",payCardsInfo);
                allRefundList.forEach(function(element) {
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
                console.log('allRefundList***',JSON.stringify(allRefundList));
                cmp.set("v.modeOfPaymentOptions",modeOfPaymentOptions);
                cmp.set("v.refundItems",allRefundList);
                
                var count2 = 1;
                for(var recdata in response.getReturnValue().ProcDataForPayment){
                    allDataInsurance[recdata]['SNo'] = count2+'.';
                    allDataInsurance[recdata]['ProcedureCode'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.Name;
                    if(allDataInsurance[recdata].RecordTypeId == recordtype){
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
            
        });
        $A.enqueueAction(action);
    },
    globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.data");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        component.set("v.data",data);
    },
    getPicklistOptions: function (component) {
        component.set("v.statusOptions", [
            { label: "Requested", value: "Requested" },
            { label: "Issued", value: "Issued", disabled: true },
            { label: "Denied", value: "Denied" }
        ]);
    },
    getModeOfpay: function (cmp) {
        var modOptions = cmp.get("v.modeOfPaymentOptions");
        var selectedrw = cmp.get("v.selectedRows");
        console.log('modOptions--'+JSON.stringify(modOptions));
        console.log('selectedrw--'+JSON.stringify(selectedrw));
        selectedrw.forEach(function(element) {
            var modeOfPayment = element.ElixirSuite__Mode_of_Payment__c;
            if (modeOfPayment.includes('Credit Card') && element.hasOwnProperty('ElixirSuite__Payment_Information__c')) {
                var isMatching = modOptions.find(function(option) {
                    return option.label === modeOfPayment;
                });
                if (isMatching) {
                    var matchingOption = modOptions.find(function(option) {
                        return option.label === modeOfPayment;
                    });
                    
                    if (matchingOption) {
                        element.ElixirSuite__Payment_Information__c = matchingOption.Id;
                    }
                }
            }
        });
        cmp.set("v.selectedrw",selectedrw);
        console.log('selectedrw 00@2--'+JSON.stringify(selectedrw)); 
    },
    handleSuccess: function(cmp, event, helper) {
        helper.setColumns(cmp);
        helper.displayDetails(cmp, event, cmp.get("v.recordId"));
        helper.getPicklistOptions(cmp, event, helper);
        cmp.set("v.data",'');
        cmp.set("v.isSearchDisabled",false);
        cmp.set("v.isProcessButtonDisabled",true);
        cmp.set("v.dateSearchParams",{'From' : '','To' : ''});
        cmp.set("v.refundDateSearchParams",{'From' : '','To' : ''});
        console.log('RefundList',JSON.stringify(cmp.get("v.RefundList"))); 
        cmp.set("v.loaded",false);
    },
    navigateToRecordDetail: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        var procrecordId = row['ElixirSuite__Procedure__c'];
        
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: procrecordId,
                objectApiName: 'ElixirSuite__Procedure__c',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    }
    
})