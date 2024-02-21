({
    doInit : function(component, event, helper) {
        component.set("v.picklistOptions", [
            { label: 'No Reason', value: 'No Reason' },
            { label: 'Price Adjustment', value: 'Price Adjustment' },
            { label: 'Post-Discount', value: 'Post-Discount' }
        ]);
        
        var selLost = component.get("v.selectedRow");
        component.set("v.procedureId", selLost[0].ElixirSuite__Procedure__r.Id);
        helper.doInitHelper(component, event, helper);
        
    },
    closeModel : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    handleBlur : function(component, event, helper) {
        var plist = component.get("v.Plist");
        plist.forEach(function(element, index) {
            if(element.hasOwnProperty('RefundAmount')){
                if($A.util.isUndefinedOrNull(element.RefundAmount) || $A.util.isEmpty(element.RefundAmount)){
                    element.RefundAmount = 0.0;
                }
            }
        });
        component.set("v.Plist", plist);
    },
    handleRefundAmount : function(component, event, helper) {
        // var rowIndex = event.target.dataset.index;
        var rowIndex = event.getSource().get("v.data-rowIndex");
        console.log('rowIndex-'+JSON.stringify(rowIndex));
        var plist = component.get("v.Plist");
        var row = plist[rowIndex];
        console.log('row-'+JSON.stringify(row));
        var allRefundAmountsZero = true;
        if(!$A.util.isEmpty(plist)){
            plist.forEach(function(element, index) {
                console.log('element--'+JSON.stringify(element));
                console.log('index--'+JSON.stringify(index));
                console.log('element[index]--'+JSON.stringify(element[index]));
                if(element.hasOwnProperty('RefundAmount')){
                    if(element.RefundAmount > 0){
                        component.set("v.DisableCreateRefund", false);
                        allRefundAmountsZero = false;
                    }
                    if(element.RefundAmount> (parseFloat(element.Amount_Paid) - parseFloat(element.RefundIssued))){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR",
                            "message": "Refund Amount exceeds the available amount for refund",
                            "type" : "error"
                        });
                        toastEvent.fire();  
                    }
                }
                
            }); 
        }
        if (allRefundAmountsZero) {
            component.set("v.DisableCreateRefund", true);
        }
    },
    save: function(component, event, helper) {
        var plist = component.get("v.Plist");
        console.log('plist--'+JSON.stringify(plist));
        var isValid = true;
        var refundItems = [];
        for (var i = 0; i < plist.length; i++) {
            var refundAmount = parseFloat(plist[i].RefundAmount);
            var amountPaid = parseFloat(plist[i].Amount_Paid);
            var refundsIssued = parseFloat(plist[i].RefundIssued);
            var remainingAmount = amountPaid - refundsIssued;
            if (refundAmount > remainingAmount) {
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR",
                    "message": "Refund Amount exceeds the available amount for refund (Row - " + (plist[i].Mode_of_Payment) + ")",
                    "type" : "error"
                });
                toastEvent.fire(); 
            }
            if(refundAmount < 0 ){
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR",
                    "message": "Please input a refund amount for the refund request",
                    "type" : "error"
                });
                toastEvent.fire();
                break;
            }
            if (refundAmount > 0) {
                var modeOfPayment;
                if(plist[i].Mode_of_Payment.includes('-')){
                    modeOfPayment = plist[i].Mode_of_Payment.replace(/ - \d+$/, '');
                }else{
                    modeOfPayment = plist[i].Mode_of_Payment;  
                }
                var refundItem = {
                    MasterTransaction: plist[i].MasterTransaction,
                    Mode_of_Payment: modeOfPayment,
                    ReasonForRefund: plist[i].ReasonForRefund,
                    RefundAmount: plist[i].RefundAmount,
                    paymentInfoId:plist[i].paymentInfoId,
                    accountId:plist[i].accountId,
                    Prior_Transaction_Id : plist[i].Prior_Transaction_Id
                    
                };
                refundItems.push(refundItem);
            }
        }
        
        if (isValid) {
            console.log("Saving data..."+ JSON.stringify(plist));
            console.log("refundItems.."+ JSON.stringify(refundItems));
            component.set("v.FinalPlist", component.get("v.Plist"));
            
            
            var action = component.get("c.createRefunds");
            action.setParams({ itemListJson: JSON.stringify(refundItems) });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Refunds created successfully.");
                    component.set("v.isModalOpen", false);
                    component.set("v.tabId", 'tab2');
                    var cmpEvent = component.getEvent("changehandlerEvent"); 
                    cmpEvent.fire();
                } else {
                    console.log("Error creating refunds: " + response.getError());
                }
            });
            $A.enqueueAction(action);
        } else {
            console.log("Invalid values found. Please correct the errors.");
        }
        
    }
})