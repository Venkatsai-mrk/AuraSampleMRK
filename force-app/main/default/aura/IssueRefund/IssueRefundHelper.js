({
    doInitHelper: function(component, event, helper) {
        var action = component.get("c.getData");
        action.setParams({ procId: component.get("v.procedureId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    var result = response.getReturnValue();
                    component.set("v.patientName", result.procData[0].ElixirSuite__Account__r.Name);
                    component.set("v.userName", result.userName);
                    console.log('tans--' + JSON.stringify(result.TransactionData));
                    console.log('refundIssued--' + JSON.stringify(result.refundIssued));
                    var cumulativeAmounts = {};
                    var transIdMap = {};
                    var masterTransaction;
                    var refundCashAmounts;
                    var refundAmounts = {};
                    var dataTableData = [];
                    if(!$A.util.isEmpty(result.TransactionData[0].ElixirSuite__Transactions__r) && !$A.util.isUndefinedOrNull(result.TransactionData[0].ElixirSuite__Transactions__r)){
                        var transactions = result.TransactionData[0].ElixirSuite__Transactions__r;
                        var refundData = result.refundIssued;
                        
                        transactions.forEach(function(element, index) {
                            if(element.hasOwnProperty('ElixirSuite__Mode_of_Payment__c')){
                                var modeOfPayment = element.ElixirSuite__Mode_of_Payment__c;
                                var amountPaid = element.ElixirSuite__Amount_Paid__c;
                                masterTransaction = element.ElixirSuite__Master_Transaction__c;
                                
                                if (modeOfPayment === 'Credit Card' && element.hasOwnProperty('ElixirSuite__Payment_Information__r') && element.ElixirSuite__Payment_Information__r.hasOwnProperty('ElixirSuite__Credit_Card_Number__c')) {
                                    var creditCardNumber = element.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c;
                                    var lastFourDigits = creditCardNumber.slice(-4);
                                    modeOfPayment += ' - ' + lastFourDigits;
                                }
                                if (modeOfPayment === 'Cheque' && element.hasOwnProperty('ElixirSuite__Other_Transactions__r') && element.ElixirSuite__Other_Transactions__r.hasOwnProperty('ElixirSuite__Cheque_Number__c')) {
                                    var creditCardNumber = element.ElixirSuite__Other_Transactions__r.ElixirSuite__Cheque_Number__c;
                                    var lastFourDigits = creditCardNumber.slice(-4);
                                    modeOfPayment += ' - ' + lastFourDigits;
                                }
                                if(element.ElixirSuite__Mode_of_Payment__c != 'Credit Card' && element.ElixirSuite__Mode_of_Payment__c != 'Cheque'){
                                    if (cumulativeAmounts.hasOwnProperty(modeOfPayment)) {
                                        cumulativeAmounts[modeOfPayment] += amountPaid;
                                    } else {
                                        cumulativeAmounts[modeOfPayment] = amountPaid;
                                    }
                                    if (!transIdMap.hasOwnProperty(modeOfPayment)) {
                                        transIdMap[modeOfPayment] =  element.Id;
                                    }
                                }
                                element['Prior_Transaction_Id'] = element.Id;
                                element['Amount_Paid'] = amountPaid;
                                element['Mode_of_Payment'] = modeOfPayment;
                                //element['paymentInfoId'] = paymentInfoId;
                                element['ReasonForRefund'] = 'No Reason';
                                element['accountId'] = result.procData[0].ElixirSuite__Account__r.Id;
                                
                            }
                        });
                        console.log('transIdMap--' + JSON.stringify(transIdMap));
                        transactions.forEach(function(ele, index) {
                            refundCashAmounts = {};
                            refundData.forEach(function(element, index) {
                                if(element.hasOwnProperty('ElixirSuite__Mode_of_Payment__c')){
                                    var modeOfPaymentRef = element.ElixirSuite__Mode_of_Payment__c;
                                    var refundAmount = element.ElixirSuite__Refund_Amount__c;
                                    if(element.hasOwnProperty('ElixirSuite__Prior_Transaction__c') && !$A.util.isUndefinedOrNull(element.ElixirSuite__Prior_Transaction__c)){
                                        if(element.ElixirSuite__Prior_Transaction__c==ele.Id){
                                            if (!refundAmounts[element.ElixirSuite__Prior_Transaction__c]) {
                                                refundAmounts[element.ElixirSuite__Prior_Transaction__c] = 0;
                                            }
                                            refundAmounts[element.ElixirSuite__Prior_Transaction__c] += parseFloat(refundAmount);
                                        }
                                        if((modeOfPaymentRef != 'Credit Card' || modeOfPaymentRef != 'Cheque')){
                                            if (Object.values(transIdMap).includes(element.ElixirSuite__Prior_Transaction__c)) {
                                                const key = Object.keys(transIdMap).find(key => transIdMap[key] === element.ElixirSuite__Prior_Transaction__c);
                                                console.log('key-'+key);
                                                modeOfPaymentRef = key;
                                                if(element.ElixirSuite__Prior_Transaction__c == transIdMap[modeOfPaymentRef]){
                                                    if (!refundCashAmounts[modeOfPaymentRef]) {
                                                        refundCashAmounts[modeOfPaymentRef] = 0;
                                                    }
                                                    refundCashAmounts[modeOfPaymentRef] += parseFloat(refundAmount);
                                                }
                                            }
                                        }
                                    }
                                }
                            });
                        });  
                        console.log('refundCashAmounts--' + JSON.stringify(refundCashAmounts));
                        var cashTotal = 0;
                        // Create separate entries for each transaction, including Cash
                        transactions.forEach(function(element) {
                            var modeOfPayment = element.Mode_of_Payment;
                            var modeOfPaymt = element.ElixirSuite__Mode_of_Payment__c;
                            if(!$A.util.isUndefinedOrNull(modeOfPayment) || !$A.util.isEmpty(modeOfPayment)){
                                if (modeOfPaymt === 'Credit Card' || modeOfPaymt === 'Cheque') {
                                    dataTableData.push({
                                        Prior_Transaction_Id : element.Id,
                                        Mode_of_Payment: modeOfPayment,
                                        Amount_Paid: element.Amount_Paid,
                                        MasterTransaction: masterTransaction,
                                        paymentInfoId: element.ElixirSuite__Payment_Information__c,
                                        RefundIssued: refundAmounts[element.Id] || 0,
                                        RefundAmount: 0.0,
                                        accountId: element.accountId
                                    });
                                }
                            }
                        });
                        // Group Cash transactions
                        var hndlTableData = Object.keys(cumulativeAmounts).map(function(modeOfPayment, index) {
                            return {
                                Prior_Transaction_Id : transIdMap[modeOfPayment],
                                Mode_of_Payment: modeOfPayment,
                                Amount_Paid: cumulativeAmounts[modeOfPayment],
                                MasterTransaction: masterTransaction,
                                paymentInfoId: '', // Use paymentInfoIds array to retrieve unique paymentInfoIds
                                RefundIssued: parseFloat(refundCashAmounts[modeOfPayment]) || 0,
                                RefundAmount: 0.0,
                                accountId:transactions[0].accountId
                            };
                        });
                        dataTableData.push(...hndlTableData);
                        component.set("v.Plist", dataTableData);
                    }
                } catch (e) {
                    alert(e);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast: function(title, message, variant) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            variant: variant
        });
        toastEvent.fire();
    }
})