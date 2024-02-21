({
	getERADetails : function(component,event) {
		
        var action = component.get("c.getERALineItemRecord");
        
        action.setParams({
                "recordId": component.get("v.eraLineItemId")
                
            });
         component.set("v.loaded",false);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                     component.set("v.loaded",true);
                    var res = response.getReturnValue();
                   
                    var reasonLst =[];
                    var adjustmentGroupLst =[];
                    var supplementalList = [];
                    
                    var supplementalCodeMap = res.SupplementalCode;
                    var reasonCodeMap = res.mapOfCodeToDesciption;
                    var adjustmentGroupMap = res.AdjustmentCode;
                    
                    console.log('reasonCodeMap',JSON.stringify(reasonCodeMap));
                    for ( var key in reasonCodeMap ) {
                        
                        reasonLst.push({value:key, label:reasonCodeMap[key]});
                    }
                    for ( var key1 in supplementalCodeMap ) {
                        
                        supplementalList.push({value:key1, label:supplementalCodeMap[key1]});
                    }
                    
                    for ( var key2 in adjustmentGroupMap ) {
                        
                        adjustmentGroupLst.push({value:key2, label:adjustmentGroupMap[key2]});
                    }

                    var adTable = component.get("v.adjustmentCodesList");
                    
                    for(var i=0;i<adTable.length;i++){
                        reasonLst.push({value:adTable[i].SelectedAdjustmentReason, label:adTable[i].SelectedAdjustmentReason});
                    }
                    
                    console.log('line47***');

                    component.set("v.headerLabel",res.headerLabel);
                    component.set("v.reasonList",reasonLst);
                    component.set("v.suppRemarkCodeList",supplementalList);
                    component.set("v.options", adjustmentGroupLst);
                    
                     }catch(e){
                         alert(e);
                     }
                }
        });
        $A.enqueueAction(action);
	},
    setAdjustmentTable :function(component,event,res,adjustmentAmount) {
        var cdList = [];
                     cdList = component.get("v.adjustmentCodesList");
                    if(res.eraLineItem.ElixirSuite__Code_1__c || res.eraLineItem.ElixirSuite__Group_1__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_1__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_1__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_1__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_2__c || res.eraLineItem.ElixirSuite__Group_2__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_2__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_2__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_2__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_3__c || res.eraLineItem.ElixirSuite__Group_3__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_3__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_3__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_3__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_4__c || res.eraLineItem.ElixirSuite__Group_4__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_4__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_4__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_4__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_5__c || res.eraLineItem.ElixirSuite__Group_5__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_5__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_5__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_5__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_6__c || res.eraLineItem.ElixirSuite__Group_6__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_6__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_6__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_6__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_7__c || res.eraLineItem.ElixirSuite__Group_7__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_7__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_7__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_7__c
                            
                        });
                    }
                    if(res.eraLineItem.ElixirSuite__Code_8__c || res.eraLineItem.ElixirSuite__Group_8__c){
                        cdList.push({
                            
                            'AdjustmentAmount': res.eraLineItem.ElixirSuite__Adjustment_Amount_8__c,
                            'SelectedAdjustmentGroupCode':res.eraLineItem.ElixirSuite__Group_8__c,
                            'SelectedAdjustmentReason' : res.eraLineItem.ElixirSuite__Code_8__c
                            
                        });
                    }
        
        if(cdList.length ==0){
            cdList.push({
                            
                            'AdjustmentAmount': 0,
                            'SelectedAdjustmentGroupCode':'',
                            'SelectedAdjustmentReason' : ''
                            
                        });
        }
        component.set("v.adjustmentCodesList", cdList);
    },
    
    saveERALineHelper :function(component,event) {
        var allValidPaidamount = component.get("v.PaidAmt");
        var allValidAllowedamount = component.get("v.AllowedAmt");
         var indx = component.get("v.editedLineIndex");
                         
        component.set("v.isOpenERALine",false);
        var cmpEvent = component.getEvent("eralineEvent");
        cmpEvent.setParams({"lineIndex" : indx});
        
        cmpEvent.fire();
                        
        
       
        /*
        if(allValidPaidamount && allValidAllowedamount){
            try{
                console.log('patRes',patRes);
                var patRes =  component.get("v.PatientResponsibility");
                patRes = patRes || 0;
                console.log('patRes',patRes);
                var temp = component.get("v.adjustmentCodesList");
                
                var adjustmentArr = [];
                if(temp.length >0){
                    adjustmentArr =component.get("v.adjustmentCodesList");
                }
               console.log('adjustmentArr',adjustmentArr);
                console.log('adjustmentArr',JSON.stringify(adjustmentArr));
                var action = component.get("c.saveERALineItemRecord");
                action.setParams({
                    "recordId": component.get("v.eraLineItemId"),
                    "procedureCode": component.get("v.ProcedureCode"),
                    "BilledAmount": component.get("v.BilledAmount"),
                    "PaidAmt": component.get("v.PaidAmt"),
                    "AllowedAmt": component.get("v.AllowedAmt"),
                    "patientResponsibility": patRes,
                    "AdjustmentSummary": JSON.stringify(adjustmentArr)
                    
                });
                console.log('adjustmentArr',JSON.stringify(adjustmentArr));
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state ==='SUCCESS'){
                        var res = response.getReturnValue();
                        console.log('res',res);
                        var indx = component.get("v.editedLineIndex");
                         
                        var cmpEvent = component.getEvent("eralineEvent");
                        cmpEvent.setParams({"lineIndex" : indx,
                                           "adList": temp});
                        
                        cmpEvent.fire();
                        component.set("v.isOpenERALine",false);
                        console.log('res',res);
                    }
                });
                $A.enqueueAction(action); 
            }catch(e){
                alert(e);
            }
        }else{
            //alert('Please provide Paid Amount and Allowed Amount');
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please provide Paid Amount and Allowed Amount",
                    "type" : "error"
                });
                toastEvent.fire();
        }*/
        
    },
    calculateOtherInsuranceResposibility_OnPatientRespChanged : function(component,event,helper,patResp) {
        
        let allowedAmt = component.get("v.AllowedAmt");
        let paidAmt = component.get("v.PaidAmt");
        allowedAmt = allowedAmt || 0;
        paidAmt = paidAmt || 0;
        var otherInsuranceResposibility =0;
        otherInsuranceResposibility =allowedAmt - paidAmt -patResp;
        component.set("v.insuranceResponsibility",parseFloat(otherInsuranceResposibility).toFixed(2));  
    },
    calculateOtherInsuranceResposibility_OnPaidAmtChanged : function(component,event,helper,paidAmt) {
        
        let allowedAmt = component.get("v.AllowedAmt");
        let patientResp = component.get("v.PatientResponsibility");
        patientResp = patientResp || 0;
        allowedAmt = allowedAmt || 0;
        var otherInsuranceResposibility =0;
        otherInsuranceResposibility = allowedAmt - paidAmt-patientResp;
        
        component.set("v.insuranceResponsibility",otherInsuranceResposibility);  
    },
    calculateOtherInsuranceResposibility_OnAllowedAmtChanged : function(component,event,helper,allowedAmt) {
        
        let patientResp = component.get("v.PatientResponsibility");
        let paidAmt = component.get("v.PaidAmt");
        patientResp = patientResp || 0;
        paidAmt = paidAmt || 0;
        var otherInsuranceResposibility =0;
        otherInsuranceResposibility =allowedAmt - paidAmt -patientResp;
        component.set("v.insuranceResponsibility",otherInsuranceResposibility);  
    }
})