({
    fetchLineItemPerClaim : function(component, event, helper) {
        component.set("v.loaded",false);
        component.set("v.loaded",true);
        var erasObj = component.get("v.erasObj");
        let lineItem = erasObj.lineItemLst;        
        if(erasObj.hasOwnProperty('lineItemLst')){  
            console.log('hasLineItem');            
        }
        component.set("v.erasObj",erasObj);  
        component.set("v.lineItemLst",erasObj.lineItemLst); 
        component.set("v.lineItemLstCopy",JSON.parse(JSON.stringify(component.get("v.lineItemLst"))));
        console.log('==lineItemLst==='+JSON.stringify(erasObj.lineItemLst));
        
    },
    getPaymentStatus :   function(component, event, helper,obj) {
        var result = '';
        if(obj.ElixirSuite__Total_Contracted_Amount__c == obj.ElixirSuite__Total_Allowed_Amount__c){
            result = 'Paid';
        }
        else if(obj.ElixirSuite__Total_Contracted_Amount__c > obj.ElixirSuite__Total_Allowed_Amount__c){
            result = 'Underpaid';
        }
            else if(obj.ElixirSuite__Total_Contracted_Amount__c < obj.ElixirSuite__Total_Allowed_Amount__c){
                result = 'Overpaid';
            }
        return result;
    },
    arrangeRasonMDTValues :   function(component, event, helper,reasonCodeMap) {       
        let reasonLst = [];
        for (var key in reasonCodeMap) {            
            reasonLst.push({value:key, label:reasonCodeMap[key]});
        }
        component.set("v.reasonList",reasonLst);
        console.log('reasonList'+JSON.stringify(component.get("v.reasonList")));
    },
    arrangeAdjustmentGrpCodeValues :   function(component, event, helper) {       
        return [
            { value: "CO", label: "CO - Contractual Obligations" },
            { value: "OA", label: "OA - Other Adjustments" },
            { value: "PI", label: "PI - Payer Initiated Reductions" },
            { value: "PR", label: "PR - Patient Responsibility" }
        ];
    },
    createAdjustmentCodeTableObjectData :  function(component, event, helper) {  
        
        //Added by Neha 
        var suppList = component.get("v.lineItemLst")[0].adjustmentCodeTable[0].suppRemarkCodeList;
        component.set("v.suppRemarkCodesPicklistVal",suppList);
        //console.log("++++suppremarkCodeList+++++",component.get("v.suppremarkCodeList"));
        //
        
        return {'adjCdTbl_adjustmentAmount' : 0 ,
                'adjCdTbl_adjustmentCodeReason' : '' ,
                'adjCdTbl_adjustmentGroupCode' : '',
                'reasonList' : JSON.parse(JSON.stringify(component.get("v.reasonList"))) ,
                'adjustmentGrpCodeLst' : helper.arrangeAdjustmentGrpCodeValues(component, event, helper),
                'suppRemarkCode':'',   //Added by Neha 
                'suppRemarkCodeList':component.get("v.suppRemarkCodesPicklistVal")  //Added by Neha 
               };      
    },
    calculateAdjustmentAmt_OnPaidAmtChanged : function(component, event, helper,paidAmt,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        if(paidAmt){
        lineItemlst[index].adjustMentAmt = (parseFloat(lineItemlst[index].billedAmt).toFixed(2) - parseFloat(paidAmt).toFixed(2)).toFixed(2);
        component.set("v.lineItemLst",lineItemlst);  
        }
    },
    
    calculateProviderAdjustment_OnAllowedAmtChanged : function(component, event, helper,allowedAmt,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        let billedAmt = lineItemlst[index].billedAmt;
        if(allowedAmt){
            lineItemlst[index].providerAdj = (parseFloat(billedAmt).toFixed(2) - parseFloat(allowedAmt).toFixed(2)).toFixed(2);
            component.set("v.lineItemLst",lineItemlst);   
        }
        
    },
   
    calculatePaymentStatus_OnAllowedAmtChanged : function(component, event, helper,allowedAmt,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        let conctAmt = lineItemlst[index].conctAmt;
        lineItemlst[index].paymentStatus = helper.flagDynamicPaymentStatusChange(component, event, helper,allowedAmt,conctAmt);
        component.set("v.lineItemLst",lineItemlst); 
    },
    calculateOtherInsuranceResposibility_OnAllowedAmtChanged : function(component, event, helper,allowedAmt,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        let paidAmt = lineItemlst[index].paidAmt;
        let patientResp = lineItemlst[index].patientResp;
        let otherInsuranceResposibility;
        if(allowedAmt){
            otherInsuranceResposibility = (parseFloat(allowedAmt) - (parseFloat(paidAmt) + parseFloat(patientResp)));
            lineItemlst[index].otherInsuranceResposibility = otherInsuranceResposibility.toFixed(2);
            component.set("v.lineItemLst",lineItemlst);   
        }
        
    },
    calculateOtherInsuranceResposibility_OnPaidAmtChanged :  function(component, event, helper,paidAmt,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        let allowedAmt = lineItemlst[index].allowedAmt;
        let patientResp = lineItemlst[index].patientResp;
        let otherInsuranceResposibility;
        if(paidAmt){
            otherInsuranceResposibility = (parseFloat(allowedAmt) - (parseFloat(paidAmt) + parseFloat(patientResp)));
            lineItemlst[index].otherInsuranceResposibility =  otherInsuranceResposibility.toFixed(2);
            component.set("v.lineItemLst",lineItemlst);   
        }
      
    },
    calculateOtherInsuranceResposibility_OnPatientRespChanged : function(component, event, helper,patientResp,index) { 
        let lineItemlst = component.get("v.lineItemLst");
        let allowedAmt = lineItemlst[index].allowedAmt;
        let paidAmt = lineItemlst[index].paidAmt;
        let otherInsuranceResposibility;
        console.log('abcc '+(parseFloat(allowedAmt) - (parseFloat(paidAmt) + parseFloat(patientResp))));
        if(!$A.util.isUndefinedOrNull(allowedAmt) && !$A.util.isUndefinedOrNull(paidAmt)){
            otherInsuranceResposibility = (parseFloat(allowedAmt) - (parseFloat(paidAmt) + parseFloat(patientResp)));
            lineItemlst[index].otherInsuranceResposibility =  otherInsuranceResposibility.toFixed(2);
            component.set("v.lineItemLst",lineItemlst);   
        }
        
    },
    flagDynamicPaymentStatusChange :  function(component, event, helper,allowedAmt,contractedAmt) { 
        var result = '';
        if(allowedAmt == contractedAmt){
            result = 'Paid';
        }
        else if(allowedAmt < contractedAmt){
            result = 'Underpaid';
        }
            else if(allowedAmt > contractedAmt){
                result = 'Overpaid';
            }
        return result;
    },
    updateValuesForChildERA :function(component, event, helper,title,message,type) {
        let lineItemlst = component.get("v.lineItemLst");
        let erasObj = component.get("v.erasObj");
        let sum = 0;
        let totalConctr = 0;
        let totalAllowed = 0;
        let totalAdjustmentAmt = 0;
        let ver_1_totalOtherInsResp = 0;
        let ver_1_toalPatientResp = 0;
        lineItemlst.forEach( function(element, index) {
            if(!$A.util.isUndefinedOrNull(element.paidAmt)){
                sum+=parseFloat(element.paidAmt).toFixed(2);
                
            }     
            if(!$A.util.isUndefinedOrNull(element.allowedAmt)){
                totalAllowed+=parseFloat(element.allowedAmt).toFixed(2);
            }
            if(!$A.util.isUndefinedOrNull(element.conctAmt)){
                totalConctr+=parseFloat(element.conctAmt).toFixed(2);
            }
            if(!$A.util.isUndefinedOrNull(element.adjustMentAmt)){
                totalAdjustmentAmt+=parseFloat(element.adjustMentAmt).toFixed(2);
            }
            if(!$A.util.isUndefinedOrNull(element.otherInsuranceResposibility)){
                ver_1_totalOtherInsResp+=parseFloat(element.otherInsuranceResposibility).toFixed(2);
            }
            if(!$A.util.isUndefinedOrNull(element.patientResp)){
                ver_1_toalPatientResp+=parseFloat(element.patientResp).toFixed(2);
            }
            
        });
        erasObj.ver_1_totalOtherInsResp = parseFloat(ver_1_totalOtherInsResp).toFixed(2);
        erasObj.ver_1_toalPatientResp = parseFloat(ver_1_toalPatientResp).toFixed(2);
        erasObj.totalAdjustmentAmt = parseFloat(totalAdjustmentAmt).toFixed(2);
        erasObj.totalAllowedAmt = parseFloat(totalAllowed).toFixed(2);
        erasObj.paidAmt = parseFloat(sum).toFixed(2);
        erasObj.paymentStatus = helper.flagDynamicPaymentStatusChange(component, event, helper,totalAllowed,totalConctr);
        component.set("v.erasObj",erasObj);
    },
    validateAdjustmentCodeWithTotalAdjustment : function(component, event, helper) {
        var validPass = true;
        let lineItemLst = component.get("v.lineItemLst"); 
        for(let rec in lineItemLst){
            let element = lineItemLst[rec];
            let adjCodeTabl = element.adjustmentCodeTable;
            let totalAdjAmt = element.adjustMentAmt;
            let childAdjAmtSum = 0;
            adjCodeTabl.forEach( function(element_child, index_child) {
                childAdjAmtSum+=parseFloat(element_child.adjCdTbl_adjustmentAmount);
            });
            console.log('totalAdjAmt '+totalAdjAmt);
            console.log('childAdjAmtSum '+childAdjAmtSum);
            if(parseFloat(totalAdjAmt).toFixed(2) != parseFloat(childAdjAmtSum).toFixed(2) ){
                helper.globalFlagToast(component, event, helper,'Adjustment Amt. is not equal to the total Adjustment amounts from the table for '+element.procCode, ' ','error'); 
                validPass = false;
                break;
            }            
        }
        return validPass;
    },
    validateProcCode : function(component, event, helper) {
        var validPass = true;
        let lineItemLst = component.get("v.lineItemLst"); 
        for(let rec in lineItemLst){
            let element = lineItemLst[rec];            
            if(!element.procCodeERAprocLineItem){
                helper.globalFlagToast(component, event, helper,'Please fill the Procedure code for '+element.procCode, ' ','error'); 
                validPass = false;
                break;
            }            
        }
        return validPass;
    },
    validatePaidAmount : function(component, event, helper) {
        var validPass = false;
        let lineItemLst = component.get("v.lineItemLst"); 
        let index = 1;
        for(let rec in lineItemLst){
            if(!lineItemLst[rec].paidAmt){                
                validPass = true;
                helper.globalFlagToast(component, event, helper,'Paid Amount is mandatory for procedure '+lineItemLst[rec].procCode,' ','error');
                break;
                
                index++;
            }    
        }
        return validPass;
    },
    validateAllowedAmount : function(component, event, helper) {
        var validPass = false;
        let lineItemLst = component.get("v.lineItemLst"); 
        let index = 1;
        for(let rec in lineItemLst){
            if(!lineItemLst[rec].allowedAmt){                
                validPass = true;
                helper.globalFlagToast(component, event, helper,'Allowed Amount is mandatory for procedure '+lineItemLst[rec].procCode,' ','error');
                break;            
                index++;
            }    
            
        }
        return validPass;
    },
    calculatePatientResposibilityAfterdelRowForAdjCodeTable :  function(component, event, helper,index) {
        try{
            
            var array = index.split('$');
            var upperIndex = array[0];
            var lowerIndex = array[1];
            let arr = component.get("v.lineItemLst");                                  
            let adjCodeTablArr = arr[upperIndex].adjustmentCodeTable;
            let patResp = 0;
            adjCodeTablArr.forEach( function(element, index) {
                if(element.adjCdTbl_adjustmentGroupCode == 'PR'){
                    if(element.adjCdTbl_adjustmentAmount){
                        patResp+=element.adjCdTbl_adjustmentAmount;
                    }
                }
            });
            arr[upperIndex].patientResp = parseFloat(patResp).toFixed(2);
            component.set("v.lineItemLst",arr); 
            helper.calculateOtherInsuranceResposibility_OnPatientRespChanged(component, event, helper,patResp,upperIndex);
        }
        catch(e){
            alert(e);
        }
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    }
    
})