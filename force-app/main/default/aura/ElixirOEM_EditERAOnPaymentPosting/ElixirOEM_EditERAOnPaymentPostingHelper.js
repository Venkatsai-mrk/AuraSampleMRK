({
    getERADetails : function(component,event) {
        var action = component.get("c.getERARecord");
        
        action.setParams({
            "recordId": component.get("v.eraId")
            
        });
        component.set("v.loaded",false);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    
                    var res = response.getReturnValue();
                    console.log('res',res);
                    
                    
                    
                    var billedAmount = 0;
                    var paidAmt =0;
                    var netAmt =0;
                    var ptResponse = 0;
                    var interestlateFiling = 0;
                    var providerAdAmt = 0;
                    var otherInResponse = 0;
                    var allowedAmt = 0;
                    
                    paidAmt = res.totalPaidSum;
                    netAmt = res.eob.ElixirSuite__Net_Paid_Amt__c;
                    ptResponse = res.totalPatientResponsibilitySum;
                    allowedAmt = res.totalAllowedSum;
                    
                    paidAmt = paidAmt ? paidAmt : 0 ;
                    netAmt = netAmt ? netAmt : 0 ;
                    ptResponse = ptResponse ? ptResponse : 0 ;
                    allowedAmt = allowedAmt ? allowedAmt : 0 ;
                    
                    interestlateFiling = netAmt- paidAmt;
                    
                    //providerAdAmt = billedAmount - paidAmt - interestlateFiling;
                    
                    //otherInResponse = allowedAmt - ptResponse - paidAmt;
                    
                    var patientName ='';
                    var claimName='';
                    if( res.eob.ElixirSuite__Claim__c){
                        if(res.eob.ElixirSuite__Claim__r.ElixirSuite__Total_Charge__c){
                            billedAmount = res.eob.ElixirSuite__Claim__r.ElixirSuite__Total_Charge__c;
                        }
                        if(res.eob.ElixirSuite__Claim__r.ElixirSuite__Patient_Name__c){
                            patientName = res.eob.ElixirSuite__Claim__r.ElixirSuite__Patient_Name__c;
                        }
                        if(res.eob.ElixirSuite__Claim__r.Name){
                            claimName = res.eob.ElixirSuite__Claim__r.Name;
                        }
                        
                    }
                    billedAmount = billedAmount ? billedAmount : 0 ;
                    var matched = res.totalMatchedPaidSum;
                   // var totaProvider =res.eob.ElixirSuite__Total_Provider_Adjustment_Amt__c;
                    var otherResponse = res.eob.ElixirSuite__Total_Other_Insurance_Responsibility__c;
                    
                    matched = matched ? matched : 0 ;
                    var totaProvider = 0;
                    
                    otherResponse = allowedAmt - (ptResponse + paidAmt);
                    var unmatched = paidAmt - matched;
                    
                    totaProvider = billedAmount - (paidAmt +interestlateFiling);
                      var actionArr = [];
                     for(let obj1 in res.mapOfActionToBeTaken){
                        let sObj1 = {'label' : obj1, 'value' : res.mapOfActionToBeTaken[obj1]};
                        actionArr.push(sObj1);
                    }  
                    component.set("v.actionToBeTakenList",actionArr);
                    component.set("v.era",res.eob);
                    component.set("v.patientName",patientName);
                    component.set("v.InternalClaim",claimName);
                    component.set("v.TotalPaid",paidAmt);
                    component.set("v.TotalAllowedAmount",allowedAmt);
                    component.set("v.MatchedAmt",matched);
                    
                    component.set("v.BilledAmount",billedAmount);
                    component.set("v.TotalAdjustmentAmt",(billedAmount - paidAmt));
                    component.set("v.UnmatchedAmt",unmatched);
                    component.set("v.payerClaim",res.eob.ElixirSuite__Payer_Claim__c);
                    component.set("v.eraStatusCodeSelected",res.eob.ElixirSuite__ERA_Status_Code__c);
                    component.set("v.actionToBeTakenSelected",res.eob.ElixirSuite__Action_to_be_Taken__c);
                    
                    console.log('actionToBeTakenSelected',component.get("v.actionToBeTakenSelected"));
                    
                    component.set("v.netPaid",netAmt);
                    
                    component.set("v.PatientResponsibility",ptResponse);
                    //component.set("v.interestLateFilingCharges",res.eob.ElixirSuite__Interest_Late_Filling_Charges__c);
                    component.set("v.interestLateFilingCharges",netAmt- paidAmt);
                    component.set("v.TotalProviderAdjustmentAmt",totaProvider);
                    
                    component.set("v.OtherInsuranceResponsibility",otherResponse);                     
                    
                    var arr = [];
                  
                    for(let obj in res.mapOfERAStatusCode){
                        let sObj = {'label' : obj, 'value' : res.mapOfERAStatusCode[obj]};
                        arr.push(sObj);
                    }  
                   
                    component.set("v.eraStatusCodeList",arr);
                    
                    this.createTable(component,event);
                   
                }
                catch(e){
                    alert(e);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    createTable : function(component,event) {
        
        var action = component.get("c.getERALineItems");
        
        action.setParams({
            "recordId": component.get("v.eraId")
            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    component.set("v.loaded",true);
                    var res = response.getReturnValue();
                    console.log('res',res);
                    if(res.length >0){
                        var eralines = [];
                        res.forEach(function(record){
                            
                            eralines.push({
                                'eralineItem' :record, 'isOpen': false, 'isOpenforMap': false, 'isOpenforDelete': false
                            });
                        });
                        component.set("v.eraLineLst",eralines);
                    }
                     
                    // component.set("v.eraLineList",res);
                }catch(e){
                    alert(e);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    
})