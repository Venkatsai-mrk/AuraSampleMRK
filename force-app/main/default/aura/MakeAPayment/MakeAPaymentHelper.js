({
    displayDetails: function(cmp, event, accId) {
        console.log("#### accId : " + accId);
        if (accId == null || accId == "") {
            cmp.set("v.PatientId", "");
            cmp.set("v.Patient", "");
            cmp.set("v.Infolist", "");
            cmp.set("v.Plist", "");
            cmp.find("select1").set("v.value", "");
            cmp.set("v.Credit", false);
            cmp.set("v.payReasonVal", "");
            cmp.set("v.myCurrency", 0.0);
            
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, "0");
            var mm = String(today.getMonth() + 1).padStart(2, "0");
            var yyyy = today.getFullYear();
            today = yyyy + "-" + mm + "-" + dd;
            cmp.set("v.Tdate", today);
        } else if (accId != null && accId != "") {
            console.log("in else block odf display details");
            cmp.set("v.Allocate", true);
            var action = cmp.get("c.getData");
            action.setParams({ accid: cmp.get("v.PatientId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("result ----- " + JSON.stringify(result));
                    // this.calculateTotalUnAllocated(cmp, event, response.getReturnValue().PatientData);
                    console.log(
                        "PatientData ----- " +
                        JSON.stringify(response.getReturnValue().PatientData)
                    );
                    //console.log(response.getReturnValue().PatientData);
                    
                    cmp.set("v.Patient", response.getReturnValue().PatientData);
                    cmp.set("v.Infolist", response.getReturnValue().PayInfo);
                    cmp.set("v.PaySchedulist", response.getReturnValue().lstPaySchedule);
                    console.log(
                        "trans---" + JSON.stringify(response.getReturnValue().ProcData)
                    );
                    cmp.set("v.Plist", response.getReturnValue().ProcData);
                    
                    cmp.set(
                        "v.totalUnAllocatedAmount",
                        response.getReturnValue().totalRemainingUnallocatedAmount
                    );
                    var allDataInsurance = response.getReturnValue()
                    .ProcDataForInsurancePayment;
                    var count2 = 1;
                    for (var recdata in response.getReturnValue()
                         .ProcDataForInsurancePayment) {
                        allDataInsurance[recdata]["SNo"] = count2 + ".";
                        allDataInsurance[recdata]["inputDiscountNew"] = 0;
                        allDataInsurance[recdata]["AmountToBeCharged"] = 0;
                        allDataInsurance[recdata]["ProcedureCode"] =
                            allDataInsurance[recdata].ElixirSuite__Procedure__r.Name;
                        if (
                            allDataInsurance[recdata].ElixirSuite__Procedure__r
                            .ElixirSuite__Claim__r != null
                        ) {
                            allDataInsurance[recdata]["ProcedureClaim"] =
                                allDataInsurance[
                                recdata
                            ].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                        }
                        
                        count2 = count2 + 1;
                    }
                    console.log(
                        "trans---" +
                        JSON.stringify(
                            response.getReturnValue().ProcDataForInsurancePayment
                        )
                    );
                    //cmp.set("v.PInsurancePaylist",response.getReturnValue().ProcDataForInsurancePayment);
                    // console.log("before calling");
                    // helper.getPrivatePaymentDetails(cmp, event, accId);
                    // console.log("after calling");
                }
            });
            $A.enqueueAction(action);
        }
    },
    getPrivatePaymentDetails: function(cmp) {
        console.log("In getPrivatePaymentDetails");
        var action = cmp.get("c.getPrivateProc");
        action.setParams({ acctId: cmp.get("v.PatientId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    var allDataInsurance = response.getReturnValue();
                    console.log("allDataInsurance" + allDataInsurance);
                    let count2 = 1;
                    var proceduresWithRemAmtZero = [];
                    for (var recdata in allDataInsurance) {
                        console.log(
                            "allDataInsurance[recdata]" + allDataInsurance[recdata]
                        );
                        console.log(
                            "allDataInsurance[recdata].id" + allDataInsurance[recdata].Id
                        );
                        
                        allDataInsurance[recdata]["SNo"] = count2 + ".";
                        allDataInsurance[recdata]["inputDiscountNew"] = 0;
                        allDataInsurance[recdata]["AmountToBeCharged"] = 0;
                        allDataInsurance[recdata]["ProcedureCode"] =
                            allDataInsurance[recdata].ElixirSuite__Procedure__r.Name;
                        if (
                            allDataInsurance[recdata].ElixirSuite__Procedure__r
                            .ElixirSuite__Claim__r != null
                        ) {
                            allDataInsurance[recdata]["ProcedureClaim"] =
                                allDataInsurance[
                                recdata
                            ].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                        }
                        if (
                            allDataInsurance[recdata].ElixirSuite__Other_Discount__c != null
                        ) {
                            allDataInsurance[recdata]["inputDiscount"] =
                                allDataInsurance[recdata].ElixirSuite__Other_Discount__c;
                        }
                        if (
                            allDataInsurance[recdata].ElixirSuite__Procedure__r
                            .ElixirSuite__Claim_Generation__c == true
                        ) {
                            allDataInsurance[recdata][
                                "ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c"
                            ] = "Yes";
                           
                        }
                        if (
                            allDataInsurance[recdata].ElixirSuite__Procedure__r
                            .ElixirSuite__Claim_Generation__c == false
                        ) {
                            allDataInsurance[recdata][
                                "ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c"
                            ] = "No";
                        } 
                        //  let remainingamt =allDataInsurance[recdata].ElixirSuite__Actual_Price__c - (allDataInsurance[recdata].ElixirSuite__Total_Paid_Amount__c) - (allDataInsurance[recdata].ElixirSuite__Discount_Amount__c)
                        let remainingamt =
                            allDataInsurance[recdata].ElixirSuite__Actual_Price__c -
                            (allDataInsurance[recdata].ElixirSuite__Discount_Amount__c +
                             allDataInsurance[recdata].ElixirSuite__Other_Discount__c) -
                            allDataInsurance[recdata].ElixirSuite__Total_Paid_Amount__c;
                        console.log("remainingamt" + remainingamt);
                        allDataInsurance[recdata]["RemainingAmount"] = remainingamt;
                        console.log(allDataInsurance[recdata]["RemainingAmount"]);
                        
                        if (
                            allDataInsurance[recdata]["RemainingAmount"] != 0 &&
                            allDataInsurance[recdata]["RemainingAmount"] > 0
                        ) {
                            proceduresWithRemAmtZero.push(allDataInsurance[recdata]);
                            proceduresWithRemAmtZero.SNo = count2 + ".";
                            count2 = count2 + 1;
                        }
                    }
                    if (count2 == 1) {
                        cmp.set("v.showErrormsg", true);
                    }
                    cmp.set("v.PInsurancePaylist", proceduresWithRemAmtZero);
                    console.log(
                        "dataInsurance=>",
                        JSON.stringify(cmp.get("v.PInsurancePaylist"))
                    );
                } catch (e) {
                    alert(e);
                }
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function(component, fieldName, sortDirection) {
        var data = component.get("v.PInsurancePaylist");
        //function to return the value stored in the field
        var key = function(a) {
            return a[fieldName];
        };
        var reverse = sortDirection == "asc" ? 1 : -1;
        
        data.sort(function(a, b) {
            var c = key(a) ? key(a) : "";
            var d = key(b) ? key(b) : "";
            return reverse * ((c > d) - (d > c));
        });
        component.set("v.PInsurancePaylist", data);
    },
    checkRequieredValidity: function(cmp) {
        var isValid = true;
        
        return isValid;
    },
    globalFlagToast: function(cmp, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    fetchERASettings: function(cmp) {
        var action = cmp.get("c.getERASetting");
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            var optionsForPrivatePayment = [];
             var forclose;
            optionsForPrivatePayment.push({
                label: "Register a Payment",
                value: "Register a Payment"
            });
            optionsForPrivatePayment.push({
                label: "Allocate Payments",
                value: "Allocate Payments"
            });
            if (
                resp.ElixirSuite__Private_Payments__c == true &&
                resp.ElixirSuite__Insurance_Payments__c == true
            ) {
                var arr = [];
                
                arr.push({ label: "Insurance Payment", value: "Insurance Payment" });
                // arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
                
                cmp.set("v.typeOfPayment", "Insurance Payment");
                 forclose = cmp.find("paymentTypeAura");
                $A.util.removeClass(forclose, "slds-hide");
                $A.util.addClass(forclose, "slds-show");
                cmp.set("v.paymentTypeList", arr);
            }
            if (
                resp.ElixirSuite__Private_Payments__c == false &&
                resp.ElixirSuite__Insurance_Payments__c == true
            ) {
                cmp.set("v.typeOfPayment", "Insurance Payment");
                 forclose = cmp.find("paymentTypeAura");
                $A.util.addClass(forclose, "slds-hide");
                $A.util.removeClass(forclose, "slds-show");
            }
            if (
                resp.ElixirSuite__Private_Payments__c == true &&
                resp.ElixirSuite__Insurance_Payments__c == false
            ) {
                cmp.set("v.typeOfPayment", "Private Payment");
                 forclose = cmp.find("paymentTypeAura");
                $A.util.addClass(forclose, "slds-hide");
                $A.util.removeClass(forclose, "slds-show");
            }
            cmp.set("v.optionsForPrivatePayment", optionsForPrivatePayment);
        });
        $A.enqueueAction(action);
    },
    saveCollectPayments: function(cmp, event, helper) {
        var acctId = cmp.get("v.recordId");
        var payType = cmp.get("v.PaymentTypeinCollect");
        var totalRemainingAmount =
            cmp.get("v.totalBilledAmount") -
            cmp.get("v.totalDiscount") -
            cmp.get("v.totalAmountPaid");
        console.log("payTyp " + payType);
        var action;
        if (payType == "CashPayment") {
             action = cmp.get("c.makeCollectPayment");
            action.setParams({
                amountToBePaid: parseFloat( cmp.get("v.TotalUnallocatedAmountInsurance") ),
                acctId: acctId,
                selectedProcedureRecords: JSON.stringify({ procedures: cmp.get("v.selectedInsurancePaylist")}),
                discountAmount: cmp.get("v.totalDiscount"),
                totalRemainingAmount: totalRemainingAmount,
                strModeOfPayment:"Cash",
                referenceNumber: ""
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state " + state);
                if (state == "SUCCESS") {
                    cmp.set("v.isModalOpen", false);
                    var otherTransaction = response.getReturnValue();
                    console.log(otherTransaction + " other transaction id");
                    console.log(otherTransaction.Id + " other transaction id");
                    var otherTransactionId = otherTransaction.Id;
                    var finalParametre = acctId + "$" + otherTransactionId;
                    var orderId = finalParametre;
                    var url =
                        "/apex/ElixirSuite__SqaurePaymentsBill?orderId=" + finalParametre;
                    //   alert(url);
                    var newWindow;
                    newWindow = window.open(url);
                    newWindow.focus();
                    helper.globalFlagToast(
                        cmp,
                        event,
                        helper,
                        "COLLECT PAYMENT REGISTERED!",
                        " ",
                        "success"
                    );
                }
            });
            $A.enqueueAction(action);
        } else if (payType == "creditCard") {
            var action2 = cmp.get("c.createOtherTransaction");
            action2.setParams({
                acctId: cmp.get("v.recordId"),
                paymentSFId: cmp.get("v.paymentSFId"),
                procedures: JSON.stringify({
                    procedures: cmp.get("v.selectedInsurancePaylist")
                }),
                totalAmount: parseFloat(cmp.get("v.TotalUnallocatedAmountInsurance")),
                discountAmount: cmp.get("v.totalDiscount"),
                strModeOfPayment:"Card",
                referenceNumber: ""
            });
            var otherTransactionId = "";
            action2.setCallback(this, function(response2) {
                var state2 = response2.getState();
                if (state2 === "SUCCESS") {
                    otherTransactionId = response2.getReturnValue();
                    cmp.set("v.otherTransactionId", otherTransactionId);
                    var action3 = cmp.get("c.createTransaction");
                    action3.setParams({
                        acctId: cmp.get("v.recordId"),
                        otherTransactionId: cmp.get("v.otherTransactionId"),
                        procedures: JSON.stringify({
                            procedures: cmp.get("v.selectedInsurancePaylist")
                        }),
                        totalAmount: parseFloat(
                            cmp.get("v.TotalUnallocatedAmountInsurance")
                        )
                    });
                    var transactionIds = "";
                    action3.setCallback(this, function(response3) {
                        var state3 = response3.getState();
                        if (state3 === "SUCCESS") {
                            transactionIds = response3.getReturnValue();
                            cmp.set("v.transactionIds", transactionIds);
                            var action4 = cmp.get("c.createPaymentsFromSquareUp");
                            action4.setParams({
                                acctId: cmp.get("v.recordId"),
                                totalAmount: parseFloat(
                                    cmp.get("v.TotalUnallocatedAmountInsurance")
                                ),
                                transactionIds: cmp.get("v.transactionIds"),
                                paymentSFId: cmp.get("v.paymentSFId")
                                //procedures : JSON.stringify({'procedures' : cmp.get("v.selectedInsurancePaylist")}),
                            });
                            action4.setCallback(this, function(response4) {
                                var state4 = response4.getState();
                                console.log("######### " + response4.getReturnValue());
                                if (
                                    state4 === "SUCCESS" &&
                                    response4.getReturnValue() === "Success"
                                ) {
                                    helper.globalFlagToast(
                                        cmp,
                                        event,
                                        helper,
                                        "PAYMENT SUCCESSFUL",
                                        " ",
                                        "Success"
                                    );
                                    
                                    var finalParametre = acctId + "$" + otherTransactionId;
                                    var orderId = finalParametre;
                                    
                                    var url =
                                        "/apex/ElixirSuite__SqaurePaymentsBill?orderId=" +
                                        finalParametre;
                                    var newWindow;
                                    newWindow = window.open(url, "_self");
                                    cmp.set("v.isModalOpen", false);
                                } else {
                                    helper.globalFlagToast(
                                        cmp,
                                        event,
                                        helper,
                                        "PAYMENT FAILED",
                                        " ",
                                        "Failed"
                                    );
                                }
                            });
                            $A.enqueueAction(action4);
                        }
                    });
                    $A.enqueueAction(action3);
                }
            });
            $A.enqueueAction(action2);
        } else if (payType == "Terminal") {
             action = cmp.get("c.activateTerminal");
            action.setParams({
                recordId: acctId,
                totalAmount: parseFloat(cmp.get("v.TotalUnallocatedAmountInsurance")),
                strModeOfPayment:"Terminal",
                referenceNumber: ""
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state " + state);
                if (state == "SUCCESS") {
                    var returnedResponse = response.getReturnValue();
                    if (returnedResponse.checkoutId == "##") {
                        helper.globalFlagToast(
                            cmp,
                            event,
                            helper,
                            "No device is active for this user",
                            " ",
                            "Failed"
                        );
                        cmp.set("v.isModalOpen", false);
                        cmp.set("v.teminalSpinner", false);
                        return;
                    }
                    cmp.set("v.teminalSpinner", true);
                    cmp.set("v.deviceId", returnedResponse.checkoutId);
                    helper.intervalSettings(
                        cmp,
                        helper,
                        returnedResponse.checkoutId,
                        returnedResponse.timeOut,
                        returnedResponse.interval
                    );
                    helper.pollingBooth(
                        cmp,
                        helper,
                        returnedResponse.checkoutId,
                        returnedResponse.timeOut,
                        returnedResponse.interval
                    );
                } else {
                    cmp.set("v.isModalOpen", false);
                    cmp.set("v.teminalSpinner", false);
                    helper.globalFlagToast(
                        cmp,
                        event,
                        helper,
                        "Terminal is not activated",
                        " ",
                        "Failed"
                    );
                }
            });
            $A.enqueueAction(action);
        } else if (payType == "others") {
             option = cmp.get("v.body");
            console.log('get body'+cmp.get("v.body"))
            var action = cmp.get("c.makeCollectPayment");
            var otherModeType = cmp.find("OthersMode").get("v.value");
            console.log('otherModeType'+otherModeType);
            console.log('referenceNumber'+cmp.get("v.referenceNumber"));
            action.setParams({
                referenceNumber: cmp.get("v.referenceNumber"),
                amountToBePaid: parseFloat(
                    cmp.get("v.TotalUnallocatedAmountInsurance")
                ),
                acctId: acctId,
                selectedProcedureRecords: JSON.stringify({
                    procedures: cmp.get("v.selectedInsurancePaylist")
                }),
                discountAmount: cmp.get("v.totalDiscount"),
                totalRemainingAmount: totalRemainingAmount,
                strModeOfPayment: otherModeType
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state " + state);
                if (state == "SUCCESS") {
                    cmp.set("v.isModalOpen", false);
                    cmp.set("v.teminalSpinner", true);
                    var otherTransaction = response.getReturnValue();
                    console.log(otherTransaction + " other transaction id");
                    console.log(otherTransaction.Id + " other transaction id");
                    var otherTransactionId = otherTransaction.Id;
                    var finalParametre = acctId + "$" + otherTransactionId;
                    var orderId = finalParametre;
                    var url =
                        "/apex/ElixirSuite__SqaurePaymentsBill?orderId=" + finalParametre;
                    //   alert(url);
                    var newWindow;
                    newWindow = window.open(url);
                    newWindow.focus();
                }
            });
            $A.enqueueAction(action);
        }
    },
    pollingBooth: function(component, helper, deviceId, timeOut, interval) {
        var x = setInterval(function() {
            var action = component.get("c.checkTerminalPayment");
            action.setParams({
                recordId: component.get("v.recordId"),
                procedures: JSON.stringify({
                    procedures: component.get("v.selectedInsurancePaylist")
                }),
                totalAmount: component.get("v.TotalUnallocatedAmountInsurance"),
                discountAmount: component.get("v.totalDiscount"),
                deviceId: deviceId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Polling booth worked");
                    var pollingResult = response.getReturnValue();
                    console.log("polling Result ############ " + pollingResult);
                    if (pollingResult == "COMPLETED") {
                        component.set("v.paySuccess", "SUCCESS");
                        helper.cancelTerminal(component, helper);
                        clearInterval(x);
                    } else if (
                        pollingResult == "CANCELED" ||
                        pollingResult == "CANCEL_REQUESTED"
                    ) {
                        component.set("v.paySuccess", "TIMEOUT");
                        helper.cancelTerminal(component, helper);
                        clearInterval(x);
                    }
                }
            });
            $A.enqueueAction(action);
        }, interval * 1000);
        //setTimeout(function( ) { clearInterval( x ); }, timeOut * 1000);
    },
    intervalSettings: function(
        component,
        helper,
        deviceId,
        thresholdTime
    ) {
        var countDownDate = new Date();
        countDownDate.setMinutes(countDownDate.getMinutes() + thresholdTime);
        // Update the count down every 1 second
        var x = setInterval(function() {
            // Get today's date and time
            var now = new Date().getTime();
            
            // Find the distance between now and the count down date
            var distance = countDownDate.getTime() - now;
            
            // Time calculations for days, hours, minutes and seconds
            var hours = Math.floor(
                (distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
            );
            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            // Output the result in an element with id="demo"
            component.set(
                "v.remainingTime",
                hours + "h " + minutes + "m " + seconds + "s "
            );
            
            // If the count down is over, write some text
            if (distance < 0) {
                component.set("v.paySuccess", "TIMEOUT");
                helper.cancelTerminal(component, helper);
                //clearInterval(x);
            }
        }, 1000);
    },
     cancelTerminal: function(component) {
        console.log("Cancelling the Terminal action");
        console.log("paysuccess " + component.get("v.paySuccess"));
        component.set("v.isSpinner", true);
        var action = component.get("c.closeTerminalPayment");
        action.setParams({
            deviceId: component.get("v.deviceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state " + state);
            if (state === "SUCCESS") {
                component.set("v.isSpinner", false);
                console.log("Cancelling the Terminal action state " + state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Canceled",
                    message: "Payment canceled.",
                    duration: " 5000",
                    key: "info_alt",
                    type: "Failed",
                    mode: "dismissible"
                });
                toastEvent.fire();
                var result = response.getReturnValue();
                if (result == "CANCELED" || result == "CANCEL_REQUESTED") {
                    component.set("v.paySuccess", "TIMEOUT");
                }
                component.set("v.isSpinner", false);
                component.set("v.isModalOpen", false);
            }
        });
        $A.enqueueAction(action);
        const interval_id = window.setInterval(function() {},
                                               Number.MAX_SAFE_INTEGER);
        // Clear any timeout/interval up to that id
        for (let i = 1; i < interval_id; i++) {
            window.clearInterval(i);
        }
    },
    savePayments: function(cmp, event, helper) {
        var noProcedureSelected = false;
        var sizeOfLst = cmp.get("v.selectedInsurancePaylist").length;
        if (sizeOfLst == 0 && cmp.get("v.toggleValue") != "By Claims") {
            noProcedureSelected = true;
        }
        var procsFromClaimList = [];
        
        // cmp.set("v.loaded",false);
        cmp.set("v.showConfirmDialog", false);
        var action = cmp.get("c.makeInsurancePayment");
        action.setParams({
            amountPaid: parseFloat(cmp.get("v.myCurrency")),
            modeOfPayment: cmp.get("v.modeOfPayment"),
            dateOfPmt: cmp.get("v.Tdate"),
            reasonForPayment: cmp.get("v.payReasonVal"),
            pmtTransactionNumber: cmp.get("v.TNumber"),
            acctId: cmp.get("v.PatientId"),
            selectedProcedureRecords:
            cmp.get("v.toggleValue") != "By Claims"
            ? JSON.stringify({
                procedures: cmp.get("v.selectedInsurancePaylist")
            })
            : JSON.stringify({ procedures: procsFromClaimList }),
            //selectedProcedureRecords : JSON.stringify({'procedures' : procsFromClaimList}),
            totalAppliedAmount: parseFloat(cmp.get("v.TotalAppliedAmountInsurance")),
            totalUnAllocatedAmount: parseFloat(
                cmp.get("v.TotalUnallocatedAmountInsurance")
            ),
            noProcedureSelected: noProcedureSelected
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.loaded", true);
                if (cmp.get("v.generateReceipt") == true) {
                    if (
                        cmp.get("v.payReasonVal") == "Applied Payment"
                    ) {
                        var url =
                            "/apex/ElixirSuite__PrintReceiptPdf?tranId=" +
                            response.getReturnValue();
                        var newWindow;
                        newWindow = window.open(url);
                        newWindow.focus();
                        //window.open('/apex/GenerateUpfrontPaymentReceipt?amountPaid='+cmp.get('v.myCurrency')+'&patientId='+cmp.get('v.PatientId')+'&paymentDate='+cmp.get('v.Tdate'));
                    }
                } else {
                    helper.globalFlagToast(
                        cmp,
                        event,
                        helper,
                        "PAYMENT REGISTERED!",
                        " ",
                        "success"
                    );
                }
                if (!cmp.get("v.isPaymentTab")) {
                    cmp.set("v.isModalOpen", true);
                    helper.resetData(cmp, event, helper);
                    helper.displayDetails(cmp, event, helper);
                }
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
    },
    resetData: function(cmp) {
        cmp.set("v.modeOfPayment", "");
        cmp.set("v.payReasonVal", "");
        cmp.set("v.myCurrency", 0.0);
        cmp.set("v.toggleValue", "By Procedure");
        cmp.set("v.hideOrShowClaims", false);
        cmp.set("v.makePaymentButtonDisable", true);
        cmp.set("v.TotalAppliedAmountInsurance", 0);
        cmp.set("v.TotalUnallocatedAmountInsurance", 0);
        cmp.set("v.selectedRowsOfProc", []);
        cmp.set("v.TotalAppliedForAllocatePayment", 0);
        cmp.set("v.TotalUnallocatedForAllocatePayment", 0);
    },
    
});