({
    myAction : function(component, event, helper) {
        
        helper.fetchLineItemPerClaim(component, event, helper);    
            },
    cancelWindow : function(component, event, helper) {
        let erasObj = component.get("v.erasObj");
        erasObj.lineItemLst = component.get("v.lineItemLstCopy");
        component.set("v.isOpen",false);
        component.set("v.childERAtableList", component.get("v.childERAtableList"));
    },
    addRowForAdjCodeTable :function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name");
            var array = index.split('$');
            var upperIndex = array[0];
            var lowerIndex = array[1];
            let arr = component.get("v.lineItemLst");
            if(arr[upperIndex].adjustmentCodeTable.length==8){
                helper.globalFlagToast(component, event, helper,'Cannot add more than 8 rows!', ' ','error');  
            }
            else {
                arr[upperIndex].adjustmentCodeTable.push(helper.createAdjustmentCodeTableObjectData(component, event, helper));
                component.set("v.lineItemLst",arr);  
                console.log('lineItemLstSet######'+JSON.stringify(component.get("v.lineItemLst")));  
            }           
        }
        catch(e){
            alert(e);
        }
    },
    delRowForAdjCodeTable :function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name");
            var array = index.split('$');
            var upperIndex = array[0];
            var lowerIndex = array[1];
            let lineItemlst = component.get("v.lineItemLst");
            let AllRowsList = lineItemlst[upperIndex].adjustmentCodeTable;
            if(AllRowsList.length==1){
                helper.globalFlagToast(component, event, helper,'Cannot delete last row!', ' ','error');
            }
            else{
                AllRowsList.splice(lowerIndex,1);          
                component.set("v.lineItemLst",lineItemlst);  
                //console.log('lineItemLstSet'+JSON.stringify(component.get("v.lineItemLst")));
            }
            helper.calculatePatientResposibilityAfterdelRowForAdjCodeTable(component, event, helper,index); 
        }
        catch(e){
            alert(e);
        }
    },
    onPaidAmtChanged : function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name");  
            var value = event.getSource().get("v.value");
            helper.calculateAdjustmentAmt_OnPaidAmtChanged(component, event, helper,JSON.parse(JSON.stringify(value)),index);  
            helper.calculateOtherInsuranceResposibility_OnPaidAmtChanged(component, event, helper,JSON.parse(JSON.stringify(value)),index); 
        }
        catch(e){
            alert(e);
        }
    },
    onAllowedAmtChanged : function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name");  
            var value = event.getSource().get("v.value");
            helper.calculateProviderAdjustment_OnAllowedAmtChanged(component, event, helper,JSON.parse(JSON.stringify(value)),index);  
            helper.calculateOtherInsuranceResposibility_OnAllowedAmtChanged(component, event, helper,JSON.parse(JSON.stringify(value)),index); 
            
        }
        catch(e){
            alert(e);
        }
    },
    
    
    doneWithLineItems : function(component, event, helper) {
        try{
            if(helper.validateProcCode(component, event, helper)){
                if(helper.validateAdjustmentCodeWithTotalAdjustment(component, event, helper)){
                    if(helper.validatePaidAmount(component, event, helper) == false){
                        if(helper.validateAllowedAmount(component, event, helper) == false){
                            helper.updateValuesForChildERA(component, event, helper);
                            component.set("v.isOpen",false);
                            component.set("v.childERAtableList",component.get("v.childERAtableList")); 
                        }   
                    }
                    
                } 
            }
        }
        catch(e){
            alert(e);
        }
    },
    calculatePatientResposibility :  function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name");
            var array = index.split('$');
            var upperIndex = array[0];
            var lowerIndex = array[1];
            let arr = component.get("v.lineItemLst");                                  
            let adjCodeTablArr = arr[upperIndex].adjustmentCodeTable;
            let patResp = 0;
            adjCodeTablArr.forEach( function(element, index) {
                if(element.adjCdTbl_adjustmentGroupCode == 'PR'){
                    if(element.adjCdTbl_adjustmentAmount){
                        patResp+=parseFloat(element.adjCdTbl_adjustmentAmount);
                    }
                }
            });
            arr[upperIndex].patientResp = parseFloat(patResp).toFixed(2);
            component.set("v.lineItemLst",arr); 
            helper.calculateOtherInsuranceResposibility_OnPatientRespChanged(component, event, helper,parseFloat(patResp).toFixed(2),upperIndex);
        }
        catch(e){
            alert(e);
        }
    },
    
    //Added by Neha 
   /* setInfoRemarksMap : function(component, event, helper) {
        //console.log('===infoRemarkCodeList    ===');
        let infoRemarkCodeList = event.getParam("infoRemarksValues");
        console.log('===infoRemarkCodeList==='+infoRemarkCodeList);
        var selectedOptions = '';
        var lineItemList = component.get("v.lineItemLst");
        console.log('===lineItemList==='+lineItemList);
        console.log(infoRemarkCodeList[0].Id);
        var obj = lineItemList.find(element=>element.Id==infoRemarkCodeList[0].Id);
        
        for(let i=0;i<infoRemarkCodeList.length;i++){
            if(i==infoRemarkCodeList.length-1){
                selectedOptions+=infoRemarkCodeList[i].Value;
            }else{
                selectedOptions+=infoRemarkCodeList[i].Value+';';
            }
        }
        obj.selectedInfoRemarkCodes = selectedOptions; 
        
        component.set("v.infoRemarksMap",event.getParam("infoRemarksValues"));
        console.log('===lineItemLst after set==='+JSON.stringify(component.get("v.lineItemLst")));
        console.log('===infoRemarksMap==='+JSON.stringify(component.get("v.infoRemarksMap")));
    }*/
    //
})