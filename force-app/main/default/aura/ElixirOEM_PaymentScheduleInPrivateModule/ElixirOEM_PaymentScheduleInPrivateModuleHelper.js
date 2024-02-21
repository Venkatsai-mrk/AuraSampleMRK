({
    initPayloadCall: function (cmp, event, helper) {
        cmp.set("v.loaded", true); //Anusha modified false to true
        if (cmp.get("v.PatientId")) { //Added by anusha 
            cmp.set("v.loaded", false); //Anusha 
            var action = cmp.get("c.initPayloadCallData");
            action.setParams({
                acctId: cmp.get("v.PatientId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try {
                        cmp.set("v.loaded", true);
                        var result = response.getReturnValue();
                         
                    cmp.set("v.Patient",response.getReturnValue().PatientData);
                    cmp.set("v.plugData",response.getReturnValue().plugDataPresent);
                    let today = new Date();
                    let filteredRecords = [];
                    response.getReturnValue().PayInfo.forEach((record) => {
                        let expirationMonth = record.ElixirSuite__Expiration_Month__c;
                        let expirationYear = parseInt(record.ElixirSuite__Expiration_Year__c);
                        let monthMap = {
                        'Jan': 0, 'Feb': 1, 'Mar': 2, 'Apr': 3,
                        'May': 4, 'June': 5, 'July': 6, 'Aug': 7,
                        'Sep': 8, 'Oct': 9, 'Nov': 10, 'Dec': 11
                    };
                      let expirationMonthNumber = monthMap[expirationMonth];
                 let expirationDate = new Date(expirationYear, expirationMonthNumber);
                    if (expirationDate > today) {
                        let cardNumber = record.ElixirSuite__Credit_Card_Number__c;
                        let maskedCardNumber = "****-****-" + cardNumber.slice(-4);
                        record.ElixirSuite__Credit_Card_Number__c = maskedCardNumber;
                        filteredRecords.push(record);
                    }
                });
                
                cmp.set("v.Infolist", filteredRecords);
                
               // cmp.set("v.Infolist",response.getReturnValue().PayInfo);
                        console.log('result in private payment ----- ' + JSON.stringify(result));
                        cmp.set("v.totalUnAllocatedAmount_SumCount", result.amt);
                        helper.initPayload(cmp, event, helper, cmp.get("v.PatientId"));

                    }
                    catch (e) {
                        alert(e);
                    }
                }

            });
            $A.enqueueAction(action);
        } //Anusha if close
    },
    initPayload: function (cmp, event, helper) {
        cmp.set("v.loaded", false);
        var action = cmp.get("c.queryAllProceduresOnMasterTransaction");
        action.setParams({
            acctId: cmp.get("v.PatientId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    cmp.set("v.loaded", true);
                    var result = response.getReturnValue();
                    let allProcedureOnMT = result.allProcedureOnMT;
                    let arr = [];
                    for (let obj in result.mapOfModeOfPayment) {
                        let sObj = { 'label': obj, 'value': result.mapOfModeOfPayment[obj] };
                        arr.push(sObj);
                    }
                    cmp.set("v.modeOfPaymentLst", arr);
                    if (!$A.util.isEmpty(allProcedureOnMT)) {
                        let count = 1;
                        allProcedureOnMT.forEach(function (element) {
                            element['SNo'] = count;
                            if (element.hasOwnProperty('ElixirSuite__Procedure__r')) {
                                element['procedureName'] = element.ElixirSuite__Procedure__r.Name;
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                            }
                            helper.setRemainingAmount(cmp, event, helper, element);
                            count++;
                        });
                        if (cmp.get("v.typeofPayment") == 'Private Payment'){
                            cmp.set("v.Plist", allProcedureOnMT);
                            console.log('Plist---' + JSON.stringify(cmp.get("v.Plist")));
                        }
                    }
                     cmp.set("v.customSettingData",result.customSettingData);
                    helper.setColumns(cmp, event, helper, result.customSettingData);
                    helper.fetchPaymentSchedulePayload(cmp, event, helper);
                }
                catch (e) {
                    alert(e);
                }
            }

        });
        $A.enqueueAction(action);
    },
    calOnReason : function(cmp, event, helper){
        var amt =0;
        var rowList;
        rowList = cmp.get('v.selectedProcedureRecords');
        console.log('rowList----1',rowList);
        for(var c=0; c<rowList.length; c++){
            if(rowList[c].ElixirSuite__PatientOutstanding__c > 0){
                amt+=rowList[c].ElixirSuite__PatientOutstanding__c;
            }
        }
        if(cmp.get('v.amountPaid') != null && cmp.get('v.amountPaid') != 0)
        {
            if(parseFloat(amt) > parseFloat(cmp.get('v.amountPaid'))){
                cmp.set('v.totalAppliedAmount',cmp.get('v.amountPaid'));   
            }else{
                cmp.set('v.totalAppliedAmount',parseFloat(amt));  
            }
            cmp.set("v.totalUnAllocatedAmount", parseFloat(cmp.get('v.amountPaid')) - cmp.get('v.totalAppliedAmount'));
        }else{
            cmp.set('v.totalAppliedAmount',0);  
            cmp.set("v.totalUnAllocatedAmount",0);    
        }
        helper.registerThePaymentButtonHandler(cmp, event, helper); 
    },
    fetchPaymentSchedulePayload: function (cmp, event, helper) {
        cmp.set("v.loaded", false);
        //   alert('patient id '+cmp.get("v.PatientId"));
        var action = cmp.get("c.paymentSchedulePayload");
        action.setParams({
            acctId: cmp.get("v.PatientId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    cmp.set("v.loaded", true);
                    var result = response.getReturnValue();
                    
                    cmp.set("v.PaySchedulist", response.getReturnValue().paymntData.lstPayPlan);
                    let allProcedureOnMT = response.getReturnValue().paymntData.procDataForInsurancePayment;
                    console.log('Procedure--' + JSON.stringify(response.getReturnValue().paymntData.procDataForInsurancePayment));
                    if (!$A.util.isEmpty(allProcedureOnMT)) {
                        let count = 1;
                        allProcedureOnMT.forEach(function (element) {
                            element['SNo'] = count;
                            if (element.hasOwnProperty('ElixirSuite__Procedure__r')) {
                                element['procedureName'] = element.ElixirSuite__Procedure__r.Name;
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                            }
                            helper.setRemainingAmount(cmp, event, helper, element);
                            count++;
                        });
						if (cmp.get("v.typeofPayment") == 'Insurance Payment'){
                            cmp.set("v.Plist", allProcedureOnMT);
                            console.log('Plist Insurance---' + JSON.stringify(cmp.get("v.Plist")));
                        }
                    }
                }
                catch (e) {
                    alert(e);
                }
            }

        });
        $A.enqueueAction(action);
    },
    globalFlagToast: function (cmp, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.Plist");
        //function to return the value stored in the field
        var key = function (a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1 : -1;

        data.sort(function (a, b) {
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c > d) - (d > c));
        });
        component.set("v.Plist", data);
    },
    savePayments: function (cmp, event, helper) {
        var noProcedureSelected = false;
        var sizeOfLst = cmp.get("v.selectedProcedureRecords").length;
        if (sizeOfLst == 0) {
            noProcedureSelected = true;
        }
        cmp.set("v.loaded", false);
        cmp.set("v.showConfirmDialog", false);	
        var action = cmp.get("c.allocatePaymentInSystem");
        console.log('modeOfPayment***',cmp.get("v.modeOfPayment"));
        action.setParams({
            amountPaid: parseFloat(cmp.get("v.amountPaid")),
            amountPaidCopy: parseFloat(cmp.get("v.amountPaid")),
            modeOfPayment: cmp.get("v.modeOfPayment"),
            dateOfPmt: cmp.get("v.dateOfPayment"),
            pmtTransactionNumber: cmp.get("v.paymentTransactionNumber"),
            acctId: cmp.get("v.PatientId"),
            selectedProcedureRecords: JSON.stringify({ 'procedures': cmp.get("v.selectedProcedureRecords") }),
            totalAppliedAmount: parseFloat(cmp.get("v.totalAppliedAmount")),
            totalUnAllocatedAmount: parseFloat(cmp.get("v.totalUnAllocatedAmount")),
            noProcedureSelected: noProcedureSelected,
            selectedParentScheduleId: cmp.get("v.selectedParentScheduleId"),
            paymentInfoId :cmp.get("v.creditCardId"), // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280 
                chequeNo : cmp.get("v.chequeNo"),
            selectedpaymentplanline :  cmp.get("v.selectedPaymentPlanLineRecords")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var wrapRes = response.getReturnValue();
            console.log('wrapRes***',wrapRes);
            if (state === "SUCCESS") {
            if(wrapRes.msgState=='Success'){
                cmp.set("v.loaded", true);
                cmp.set("v.makePaymentButtonDisable",true);
                helper.globalFlagToast(cmp, event, helper, 'Payment registered!', ' ', 'success');
                cmp.set("v.isModalOpen", true);
                helper.resetData(cmp,event,helper);
                helper.initPayloadCall(cmp, event, helper);
                  $A.get('e.force:refreshView').fire(); //added by anusha LX3-5526
                 //$A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire(); //Lokesh added 
            }

        if(wrapRes.msgState=='URL'){
                    if(wrapRes.msgStr!=''){
                        window.open(wrapRes.msgStr,'_top');
                }
                else{
                            helper.globalFlagToast(cmp, event, helper,'URL not configured!', ' ','error');
                          cmp.set("v.loaded",true);
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
                        cmp.set("v.loaded",true);
                        return;
                    }
                
            }
            
            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                            cmp.set("v.loaded",true);
                        }
                    }
            }

        });
        $A.enqueueAction(action);
    },
    //resetData function added by Anusha-LX3-5747
    resetData : function(cmp){
        cmp.set("v.modeOfPayment",'');
        cmp.set("v.amountPaid",0.0);
        cmp.set("v.paymentTransactionNumber",'');
        cmp.set("v.procedureSearchParams",'');
        cmp.set("v.selectedRows",[]);
        cmp.set("v.totalAppliedAmount",0);
        cmp.set("v.totalUnAllocatedAmount",0);
        cmp.set("v.chequeNo",'');
        cmp.set("v.cheque",false);
        cmp.set("v.Credit",false);
        cmp.set("v.hideSchedule",false);
        cmp.set("v.payReasonVal","");
        cmp.set("v.scheduleList",[]);
        cmp.set("v.PaySchedulist",[]);
        cmp.set("v.creditCardId",'');
        cmp.set("v.selectedParentScheduleId",'');
        
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy +'-'+ mm +'-' + dd ;
        cmp.set("v.dateOfPayment",today);
        
    },
    filterDuplicates: function (cmp, event, helper, arr) {
        const uniqueIds = [];
        const unique = arr.filter(element => {
            const isDuplicate = uniqueIds.includes(element.Id);
            if (!isDuplicate) {
                uniqueIds.push(element.Id);
                return true;
            }
            return false;
        });
        return unique;
    },
    keepSelectedProcedures: function (cmp, event, helper) {
        var selectedProcedureRecords = JSON.parse(JSON.stringify(cmp.get("v.selectedProcedureRecords")));
        let selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecordsNetInstance");
        selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(selectedProcedureRecords);
        selectedProcedureRecordsNetInstance = helper.filterDuplicates(cmp, event, helper, selectedProcedureRecordsNetInstance);
        cmp.set("v.selectedProcedureRecordsNetInstance", selectedProcedureRecordsNetInstance);
        var eisitngIdArr = [];
        selectedProcedureRecordsNetInstance.forEach(function (element) {
            eisitngIdArr.push(element.Id);
        });
        var selectedProcedureRecordsNetInstanceCopy = cmp.get("v.selectedProcedureRecordsNetInstance");
        cmp.set("v.loaded", false);
        //var action = cmp.get("c.filterProcedureOnMasterTransaction");
        if (cmp.get("v.typeofPayment") == 'Insurance Payment'){
                    var action = cmp.get("c.filterAllProcedureOnMasterTransaction");
                }
                if (cmp.get("v.typeofPayment") == 'Private Payment'){
                    var action = cmp.get("c.filterProcedureOnMasterTransaction");
                }
        action.setParams({
            acctId: cmp.get("v.PatientId"),
            eisitngIdArr: eisitngIdArr
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {

                    cmp.set("v.loaded", true);
                    var result = response.getReturnValue();
                    let allProcedureOnMT = result.allProcedureOnMT;
                    if (!$A.util.isEmpty(allProcedureOnMT)) {
                        let count = 1;
                        allProcedureOnMT.forEach(function (element) {
                            if (!eisitngIdArr.includes(element.Id)) {
                                element['SNo'] = count;
                                if (element.hasOwnProperty('ElixirSuite__Procedure__r')) {
                                    element['procedureName'] = element.ElixirSuite__Procedure__r.Name;
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                }
                                //helper.setRemainingAmount(cmp, event, helper, element);
                                count++;
                            }
                        });
                        // asc // desc // 
                        cmp.set("v.selectedRows", eisitngIdArr);
                        helper.sortSelectedProcedures(cmp, 'ElixirSuite__Date_Of_Service__c', 'desc', selectedProcedureRecordsNetInstanceCopy);
                        selectedProcedureRecordsNetInstanceCopy = selectedProcedureRecordsNetInstanceCopy.concat(allProcedureOnMT);
                        cmp.set("v.Plist", selectedProcedureRecordsNetInstanceCopy);
                        console.log('after search enable ---' + JSON.stringify(cmp.get("v.Plist")));
                    }
                    helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                }
                catch (e) {
                    alert(e);
                }
            }

        });
        $A.enqueueAction(action);

    },
    sortSelectedProcedures: function (component, fieldName, sortDirection, data) {
        //  var data = component.get("v.Plist");
        //function to return the value stored in the field
        var key = function (a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1 : -1;

        data.sort(function (a, b) {
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c > d) - (d > c));
        });
        return data;
    },
    checkRequieredValidity: function (cmp, event, helper) {
        var isValid = true;
        let modeOfPayment = cmp.get("v.modeOfPayment");
        let amountPaid = cmp.get("v.amountPaid");
        let dateOfPayment = cmp.get("v.dateOfPayment");
        let creditSelectedRow = cmp.get("v.creditSelectedRows");
        let checkNumber = cmp.get("v.chequeNo");
        console.log('checkNumber',checkNumber);
        if (!modeOfPayment) {
            helper.globalFlagToast(cmp, event, helper, 'Mode of payment is mandatory!', ' ', 'error');
            isValid = false;
        }
         else if(!cmp.get("v.plugData")){
         if(modeOfPayment=='Credit Card' && creditSelectedRow.length<=0){
             helper.globalFlagToast(cmp, event, helper,'Select a credit card!', ' ','error');  
            isValid = false;
        }
}
         else if(modeOfPayment=='Cheque' && !checkNumber){
             helper.globalFlagToast(cmp, event, helper,'Cheque number is mandatory!', ' ','error');  
            isValid = false;
        }
        else if (!dateOfPayment) {
            helper.globalFlagToast(cmp, event, helper, 'Date of payment is mandatory!', ' ', 'error');
            isValid = false;
        }
        else if (!amountPaid) {
            helper.globalFlagToast(cmp, event, helper, 'Amount paid is mandatory!', ' ', 'error');
            isValid = false;
        }
        else if (parseInt(amountPaid) == 0) {
            helper.globalFlagToast(cmp, event, helper, 'Amount paid cannot be zero!', ' ', 'error');
            isValid = false;
        }

        return isValid;
    },

    setRemainingAmount: function (cmp, event, helper, element) {
        if (element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && element.hasOwnProperty('ElixirSuite__Other_Discounts__c')
            && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c')) {
            element['remainingAmount'] = (parseInt(element.ElixirSuite__Expected_Receivable_amount__c) - parseInt(element.ElixirSuite__Other_Discounts__c)) - parseInt(element.ElixirSuite__Total_Paid_Amount__c);
        }
        else if (!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && (element.hasOwnProperty('ElixirSuite__Other_Discounts__c')
            && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c'))) {
            element['remainingAmount'] = (parseInt(element.ElixirSuite__Actual_Price__c) - parseInt(element.ElixirSuite__Other_Discounts__c)) - parseInt(element.ElixirSuite__Total_Paid_Amount__c);
        }
        else if ((!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && !element.hasOwnProperty('ElixirSuite__Other_Discounts__c'))) {
            element['remainingAmount'] = parseInt(element.ElixirSuite__Actual_Price__c) - parseInt(element.ElixirSuite__Total_Paid_Amount__c);
        }
        else if (!element.hasOwnProperty('ElixirSuite__Other_Discounts__c')) {
            element['remainingAmount'] = parseInt(element.ElixirSuite__Expected_Receivable_amount__c) - parseInt(element.ElixirSuite__Total_Paid_Amount__c);
        }
    },
    setColumns: function (cmp, event, helper, customSettingData) {
        let otherDsc = false;
        let exptRecAmt = false;
        if (!$A.util.isUndefinedOrNull(customSettingData)) {
            if (customSettingData.length > 0) {
                otherDsc = customSettingData[0].ElixirSuite__Other_Discounts__c;
                exptRecAmt = customSettingData[0].ElixirSuite__Expected_Receivable_Amount__c;
            }

        }
        cmp.set('v.columns', [
            { label: 'S.No', fieldName: 'SNo', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            //{ label: 'Procedure Name', fieldName: 'procedureName', type: 'text', sortable: true },
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            { label: 'CPT Code', fieldName: 'ElixirSuite__Cpt_Codes__c', type: 'text', sortable: true },
            //{ label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable: true },
             {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
             {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            { label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable: true },
            { label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable: true }
            ,

            { label: 'Remaining amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency', sortable: true },

        ]);
        let addCols = cmp.get('v.columns');
        if (otherDsc) {
            addCols.push({ label: 'Other Discounts', fieldName: 'ElixirSuite__Other_Discounts__c', type: 'currency', sortable: true });
        }

        cmp.set('v.columns4', addCols);
            
            cmp.set('v.columns4', [
            { label: 'S.No', fieldName: 'SNo', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            //{ label: 'Procedure Name', fieldName: 'procedureName', type: 'text', sortable: true },
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            { label: 'CPT Code', fieldName: 'ElixirSuite__Cpt_Codes__c', type: 'text', sortable: true },
            //{ label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable: true },
             {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
             {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            { label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable: true },
            { label: 'Primary Insurance Paid', fieldName: 'ElixirSuite__Insurance_Paid__c', type: 'currency', sortable: true },
            { label: 'Secondary Insurance Paid', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type: 'currency', sortable: true },
            { label: 'Total Adjustment Amount', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type: 'currency', sortable: true },
            { label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable: true }
            ,

            { label: 'Remaining amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency', sortable: true },
            { label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type: 'currency', sortable: true },

        ]);
        let addCols1 = cmp.get('v.columns4');
        if (otherDsc) {
            addCols1.push({ label: 'Other Discounts', fieldName: 'ElixirSuite__Other_Discounts__c', type: 'currency', sortable: true });
        }
        cmp.set('v.columns4', addCols1);
    },
    setDefaultJSON: function (cmp) {
        cmp.set("v.procedureSearchParams", {
            'DOSFrom': '', 'DOSTo': '', 'procedureName': '',
            'procedureId': '', 'CPTCode': ''
        });
        cmp.set('v.columns2', [
            { label: 'Payment Plan Name', fieldName: 'Name', type: 'Auto Number' },
            { label: 'Payment Frequency', fieldName: 'ElixirSuite__Payment_Frequency__c', type: 'Picklist' },
            { label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'currency' },
            { label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type: 'currency' },
            { label: 'Total Amount Paid', fieldName: 'ElixirSuite__Total_Amount_Paid__c', type: 'currency' },
            { label: 'Total Balance Due', fieldName: 'ElixirSuite__Total_Balance_Due__c', type: 'currency' },
            
        ]);
        cmp.set('v.columns3', [
            { label: 'Payment Installment', fieldName: 'Name', type: 'Auto Number' },
			{ label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'currency' },
            {label: 'Due Date', fieldName: 'ElixirSuite__Due_Date__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
            
            { label: 'Remaining Amount', fieldName: 'ElixirSuite__Balance_Due__c', type: 'currency' }
        ]);
    },
    validateAmountPaid: function (component, event, helper) {
        var isValid = true;
        let amountPaid = component.get("v.amountPaid");
        let selectedParentSchedule = component.get("v.selectedParentSchedule");
        if (!$A.util.isEmpty(selectedParentSchedule)) {
            if (parseInt(amountPaid) > selectedParentSchedule[0].ElixirSuite__Total_Balance_Due__c) {
                helper.globalFlagToast(component, event, helper, 'Amount Paid is greater than Remaining Amount of Payment Schedule!', ' ', 'error'); //Anusha LX3-5515
                component.set("v.makePaymentButtonDisable", true);
                isValid = false;
            }
            else {
                component.set("v.makePaymentButtonDisable", false);
                isValid = true;
            }
        }
	return isValid; //added by Anusha LX3-5804
    },
    registerThePaymentButtonHandler:function(cmp){
        let isModeOfPaymentEmpty = cmp.get("v.modeOfPayment")!='';
        let isAmountPaidPositive=cmp.get("v.amountPaid")>0;
        let isProcedureOrClaimSelected=cmp.get("v.selectedProcedureRecords").length>0; //commented by Anusha LX3-5799
        let isPaymentPlanSelected=cmp.get("v.selectedParentSchedule").length>0;
        let isPaymentPlanlineLength=cmp.get("v.selectedPaymentPlanLineRecords").length;
        let isDateEmpty=cmp.get("v.dateOfPayment")!='';
        if(isModeOfPaymentEmpty && isAmountPaidPositive && isDateEmpty && isProcedureOrClaimSelected && isPaymentPlanSelected && isPaymentPlanlineLength > 0 && isPaymentPlanlineLength <= 10){ 
            cmp.set("v.makePaymentButtonDisable",false);
        }else if(isModeOfPaymentEmpty && isAmountPaidPositive && isDateEmpty && isPaymentPlanSelected && isPaymentPlanlineLength > 0 && isPaymentPlanlineLength <= 10){
            cmp.set("v.makePaymentButtonDisable",false);
        }
        else{
            cmp.set("v.makePaymentButtonDisable",true);
        }

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