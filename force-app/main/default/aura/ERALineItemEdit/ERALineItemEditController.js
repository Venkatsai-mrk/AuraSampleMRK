({
    
	myAction : function(component, event, helper) {
       
        console.log('eraline',component.get("v.eraLineItemId"));
        var opts = [
            { value: "CO", label: "CO - Contractual Obligations" },
            { value: "OA", label: "OA - Other Adjustments" },
            { value: "PI", label: "PI - Payer Initiated Reductions" },
            { value: "PR", label: "PR - Patient Responsibility" }
        ];
       
        var rs =component.get("v.reasonList"); 
        helper.getERADetails(component,event);
       
	},
    openPop : function(component, event, helper){
        component.set("v.isOpenERALine",true);
    },
    addRecord : function(component, event, helper) {
        var rs =component.get("v.reasonList"); 
        var codesLst = component.get("v.adjustmentCodesList");
        codesLst.push({
            
            'AdjustmentAmount': '0',
            'SelectedAdjustmentGroupCode':'',
            'SelectedAdjustmentReason' : '',
            'SelectedSupplementalCode' : ''
            //'AdjustmentGroupCode':opts,
           // 'AdjustmentReason': rs
            
        });
        component.set("v.adjustmentCodesList", codesLst);
	},
    removeRecord : function(component, event, helper) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;
            var finalindex = event.currentTarget.dataset.id;
            var AllRowsList = component.get("v.adjustmentCodesList");
            if(AllRowsList.length!=1){
                AllRowsList.splice(finalindex, 1);
                component.set("v.adjustmentCodesList", AllRowsList);
                let arr = component.get("v.adjustmentCodesList"); 
                let patResp = 0;
                arr.forEach( function(element) {
                    if(element.SelectedAdjustmentGroupCode == 'PR'){
                        patResp+=parseFloat(element.AdjustmentAmount);
                    }
                });
                
                component.set("v.PatientResponsibility",parseFloat(patResp).toFixed(2)); 
                
                helper.calculateOtherInsuranceResposibility_OnPatientRespChanged(component, event, helper,parseFloat(patResp).toFixed(2));
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Can not delete last row",
                    "message": " ",
                    "type" : "error"
                });
                toastEvent.fire();
            }
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    allowedAmountChangesHandler :function(component, event, helper) {
        var allowedAmount =0;
        allowedAmount =event.getSource().get('v.value');
        var billedAmount = 0;
        billedAmount =component.get("v.BilledAmount");
        billedAmount = billedAmount || 0;
        var providerAdjustment = billedAmount - allowedAmount;
        
        console.log('allowedAmount',allowedAmount);
        console.log('billedAmount',billedAmount);
        console.log('providerAdjustment',providerAdjustment);
        
        //component.set("v.AllowedAmt",parseFloat(allowedAmount).toFixed(2));
        component.set("v.ProviderAdjustment",parseFloat(providerAdjustment).toFixed(2));
        
        helper.calculateOtherInsuranceResposibility_OnAllowedAmtChanged(component, event, helper,parseFloat(allowedAmount).toFixed(2));
    },
    paidAmountChangesHandler :function(component, event, helper) {
        var paidAmount =0;
            paidAmount= event.getSource().get('v.value');
        var billedAmount = 0;
            billedAmount =component.get("v.BilledAmount");
        billedAmount = billedAmount || 0;
       
        var adjustmentAmount = 0;
            adjustmentAmount =billedAmount - paidAmount;
        
        //component.set("v.PaidAmt",parseFloat(paidAmount).toFixed(2));
        component.set("v.AdjustmentAmt",parseFloat(adjustmentAmount).toFixed(2));
        
        helper.calculateOtherInsuranceResposibility_OnPaidAmtChanged(component, event, helper,parseFloat(paidAmount).toFixed(2));
    },
    cancelWindow :function(component, event, helper) {
        component.set("v.isOpenERALine",false);
    },
    saveERALineItem :function(component, event, helper) {
        var totalAmt= 0;
        
        var AllRowsList = component.get("v.adjustmentCodesList");
            if(AllRowsList.length >0){
                for(var i=0; i<AllRowsList.length; i++){
                    console.log('amount...',AllRowsList[i].AdjustmentAmount);
                    if(AllRowsList[i].AdjustmentAmount!='' || AllRowsList[i].AdjustmentAmount!= undefined){
                        totalAmt = parseFloat(totalAmt)+parseFloat( AllRowsList[i].AdjustmentAmount);
                    }                    
                    console.log('gp...',AllRowsList[i].SelectedAdjustmentGroupCode);
                    console.log('reason...',AllRowsList[i].SelectedAdjustmentReason);
                }
               component.set("v.TotalAmount",parseFloat(totalAmt).toFixed(2));
            }
        
       
        var AdjustmentAmt = component.get("v.AdjustmentAmt");
        
        totalAmt =totalAmt || 0;
        console.log('totalAmt',totalAmt);
        console.log('AdjustmentAmt',AdjustmentAmt);
        
        if(parseFloat(totalAmt).toFixed(2) == parseFloat(AdjustmentAmt).toFixed(2)){
            console.log('AdjustmentAmt',AdjustmentAmt);
            helper.saveERALineHelper(component,event);
        }else{
            
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Adjustment Amt. is not equal to the total Adjustment amounts from the table.",
                    "message": " ",
                    "type" : "error"
                });
                toastEvent.fire();
        }
        
    },
    calculatePatientResposibility : function(component,event,helper){
        try{
            
            let arr = component.get("v.adjustmentCodesList"); 
            let patResp = 0;
            arr.forEach( function(element) {
                if(element.SelectedAdjustmentGroupCode == 'PR'){
                    patResp+=parseFloat(element.AdjustmentAmount);
                }
            });
            
            component.set("v.PatientResponsibility",parseFloat(patResp).toFixed(2)); 
            
            helper.calculateOtherInsuranceResposibility_OnPatientRespChanged(component, event, helper,parseFloat(patResp).toFixed(2));
        }
        catch(e){
            alert(e);
        }
    }
})