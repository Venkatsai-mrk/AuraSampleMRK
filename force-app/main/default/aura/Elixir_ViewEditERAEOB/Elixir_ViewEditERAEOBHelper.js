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
                                        var billedAmount = 0;
                    var paidAmt =0;
                    var netAmt =0;
                    var ptResponse = 0;
                    var interestlateFiling = 0;
                  //  var providerAdAmt = 0;
                   // var otherInResponse = 0;
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
                    var claimId = '';
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
                        claimId = res.eob.ElixirSuite__Claim__c;
                        component.set("v.patientId",res.eob.ElixirSuite__Account__c);
                    }
                    
                  component.set("v.editAbilityIfPosted",res.eob.ElixirSuite__Primary_Posted__c);
                     component.set("v.isDisabled",res.eob.ElixirSuite__Primary_Posted__c); 
                    billedAmount = billedAmount ? billedAmount : 0 ;
                    var matched = res.totalMatchedPaidSum;
                    // var totaProvider =res.eob.ElixirSuite__Total_Provider_Adjustment_Amt__c;
                    var otherResponse = res.eob.ElixirSuite__Total_Other_Insurance_Responsibility__c;
                    
                    matched = matched ? matched : 0 ;
                    var totaProvider = 0;
                    
                    otherResponse = allowedAmt - (ptResponse + paidAmt);
                    var unmatched = paidAmt - matched;
                    
                    totaProvider = billedAmount - (paidAmt +interestlateFiling);
                    component.set("v.era",res.eob);
                    component.set("v.patientName",patientName);
                    component.set("v.InternalClaim",claimName);
                    component.set("v.claimId",claimId);
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
                    var actionArr = [];
                    
                    for(let obj in res.mapOfERAStatusCode){
                        let sObj = {'label' : obj, 'value' : res.mapOfERAStatusCode[obj]};
                        arr.push(sObj);
                    }  
                    
                    for(let obj1 in res.mapOfActionToBeTaken){
                        let sObj1 = {'label' : obj1, 'value' : res.mapOfActionToBeTaken[obj1]};
                        actionArr.push(sObj1);
                    }  
                    component.set("v.actionToBeTakenList",actionArr);
                    component.set("v.eraStatusCodeList",arr);
                    
                    var InfoList = [];
                    var InformationCodeList = [];
                    
                    InfoList =res.listOfInformationCode;
                    
                    for (var i = 0; i < InfoList.length; i++) {
                        InformationCodeList.push({
                            label: InfoList[i]
                        });
                    }
                    
                    
                    this.createTable(component,event,InformationCodeList);
                    
                }
                catch(e){
                 
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    createTable : function(component,event,InformationCodeList) {
        
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
                    const that = this;
                   
                    if(res.length >0){
                        var eralines = [];
                        res.forEach(function(record){
                            var cdList = [];
                            var billedAmount = 0;
                            var claimLineId;
                           
                            billedAmount =record.ElixirSuite__Charge__c;
                                
                            if(record.ElixirSuite__Claim_Line_Items__c){
                                claimLineId = record.ElixirSuite__Claim_Line_Items__c;
                            }
                            var allowedAmount =record.ElixirSuite__Total_Allowed_Amount__c;
                            var paidAmount = record.ElixirSuite__Paid__c;
                            var insuranceResponsibility =record.ElixirSuite__Other_Insurance_Responsibility__c;
                            var patientResponsibility = record.ElixirSuite__Patient_Responsibility__c;
                            var alreadyPresentInfo = record.ElixirSuite__Adjustment_Remark_Codes__c;
                            var selectedInfoArray = [];
                            if(alreadyPresentInfo!='' && alreadyPresentInfo!=undefined){
                                selectedInfoArray =alreadyPresentInfo.split(';');
                            }
                            
                            var showTxt = 'Select an option...';
                            if(selectedInfoArray.length >0){
                                showTxt = selectedInfoArray.length + " options selected";
                            }else{
                               showTxt = 'Select an option...'; 
                            }
                            billedAmount = billedAmount ? billedAmount : 0 ;
                            allowedAmount = allowedAmount ? allowedAmount : 0 ;
                            paidAmount = paidAmount ? paidAmount : 0 ;
                            
                            var adjustmentAmount = parseFloat(billedAmount -paidAmount).toFixed(2);
                            var providerAdjustment = parseFloat(billedAmount - allowedAmount).toFixed(2);
                            
                            //adjustmentAmount = adjustmentAmount ? adjustmentAmount : 0;
                            //providerAdjustment = providerAdjustment ? providerAdjustment : 0;
                            that.setAdTable(component,event,record,adjustmentAmount,cdList);
                            eralines.push({
                                'eralineItem' :record,
                                'lineId':record.Id,
                                'IsEdited':false,
                                'isOpen': false, 
                                'isOpenforMap': false, 
                                'isOpenforDelete': false,
                                'claimLineItemId': claimLineId,
                                'billedAmount': billedAmount,
                                'allowedAmount': allowedAmount,
                                'paidAmount': paidAmount,
                                'adjustmentAmount': adjustmentAmount,
                                'providerAdjustment': providerAdjustment,
                                'insuranceResponsibility': insuranceResponsibility,
                                'patientResponsibility': patientResponsibility,
                                'ProcedureCode': record.ElixirSuite__Proc_code__c,
                                'ajcdList': cdList,
                                'InformList': InformationCodeList,
                                'selectedInfoList': selectedInfoArray,
                                'showText': showTxt,
                            });
                        });
                        component.set("v.eraLineLst",eralines);
                    }
                    else{
                        component.set("v.eraLineLst",[]);
                    }
                    // component.set("v.eraLineList",res);
                }catch(e){
                  // alert(e.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    setAdTable:function(component,event,record,adjustmentAmount,cdList) {
        
        
        if(record.ElixirSuite__Code_1__c || record.ElixirSuite__Group_1__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_1__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_1__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_1__c
            });
        }
        if(record.ElixirSuite__Code_2__c || record.ElixirSuite__Group_2__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_2__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_2__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_2__c
            });
        }
        if(record.ElixirSuite__Code_3__c || record.ElixirSuite__Group_3__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_3__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_3__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_3__c
                
            });
        }
        if(record.ElixirSuite__Code_4__c || record.ElixirSuite__Group_4__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_4__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_4__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_4__c
                
            });
        }
        if(record.ElixirSuite__Code_5__c || record.ElixirSuite__Group_5__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_5__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_5__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_5__c
                
            });
        }
        if(record.ElixirSuite__Code_6__c || record.ElixirSuite__Group_6__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_6__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_6__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_6__c
                
            });
        }
        if(record.ElixirSuite__Code_7__c || record.ElixirSuite__Group_7__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_7__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_7__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_7__c
                
            });
        }
        if(record.ElixirSuite__Code_8__c || record.ElixirSuite__Group_8__c){
            cdList.push({
                
                'AdjustmentAmount': record.ElixirSuite__Adjustment_Amount_8__c,
                'SelectedAdjustmentGroupCode':record.ElixirSuite__Group_8__c,
                'SelectedAdjustmentReason' : record.ElixirSuite__Code_8__c
                
            });
        }
        
        if(cdList.length ==0){
            adjustmentAmount = adjustmentAmount ? adjustmentAmount : 0;
            cdList.push({
                
                'AdjustmentAmount': adjustmentAmount,
                'SelectedAdjustmentGroupCode':'CO',
                'SelectedAdjustmentReason' : '45',
                'SelectedSupplementalCode' : 'M2'
            });
        }
        
       
    },
    
    saveChildEraLines: function(component,event,helper,isPosted) {
        var netpaidValid =component.get("v.netPaid");
        console.log('noteList '+JSON.stringify(component.get("v.noteList")));
        if(netpaidValid){
            var action = component.get("c.saveChildEralineRecords");
            component.set("v.loaded",false);
            var tempList = component.get("v.eraLineLst");
            var eraItemList = [];
            var adjustmentCodeList = [];
            
            for(var i=0; i<tempList.length; i++){
                eraItemList.push({
                    'lineItem' :tempList[i].eralineItem
                });
                adjustmentCodeList.push(tempList[i].ajcdList);
            }
            console.log(',meg' + JSON.stringify(adjustmentCodeList));
            action.setParams({
                "eraLineObjectList": JSON.stringify(eraItemList),
                "adjustmentReasonCode" : JSON.stringify(adjustmentCodeList),
                "recommendationList": JSON.stringify(component.get("v.recommendationList")),
                "delRecList": JSON.stringify(component.get("v.delRecommendationList")),
                "noteList": JSON.stringify(component.get("v.noteList")),
                "delNoteList": JSON.stringify(component.get("v.delNoteList"))
                
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('state '+response.getState());
                if(state ==='SUCCESS'){
                    try{
                        component.set("v.loaded",true);
                        //const addNotesClaim = component.find('addNotesClaim');
                        //var reccc = addNotesClaim.saveNotesRecommendations();
                        //console.log("reccc"+reccc);
                       // var res = response.getReturnValue();
                        //if(reccc)
                        this.saveEraData(component,event,helper,isPosted);
                    }
                    catch(e){
                        alert(e);
                    }  
                    
                }
            });
            $A.enqueueAction(action);
        }else{
            //alert('Please provide Net Paid Amt.');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please provide Net Paid Amt.",
                "type" : "error"
            });
            toastEvent.fire();
        }
    },
    saveEraData: function(component,event,helper,isPosted) {
        // var netpaidValid =component.get("v.netPaid");
       // var ablist =  component.get("v.eraLineLst");
        console.log('formulate JSON '+JSON.stringify(helper.formulatePostingJSON(component,event,helper)));
        // if(netpaidValid){
        var action = component.get("c.saveEraRecord");
        component.set("v.loaded",false);
        action.setParams({
            "recordId": component.get("v.eraId"),
            "payerClaim": component.get("v.payerClaim"),
            "statusCode": component.get("v.eraStatusCodeSelected"),
            "billAmt": component.get("v.BilledAmount"),
            "allowedAmt": component.get("v.TotalAllowedAmount"),
            "paidAmt": component.get("v.TotalPaid"),
            "adjustmentAmt": component.get("v.TotalAdjustmentAmt"),
            "netPaidAmt": component.get("v.netPaid"),
            "OtherInsuranceResponsibility": component.get("v.OtherInsuranceResponsibility"),
            "actionTaken": component.get("v.actionToBeTakenSelected"),
            "matchAmt": component.get("v.MatchedAmt"),
            "ptResponse": component.get("v.PatientResponsibility"),
            "stringifiedEralineitemList" : JSON.stringify({'key' : component.get("v.deletedEralineLst")}),
            "stringifiedupdatedlineitemList" :JSON.stringify({'key' : component.get("v.eraLineLst")}),
            "postingJSON" : JSON.stringify({'childERAtableList' : helper.formulatePostingJSON(component,event,helper)}),
            "isPosted" : isPosted
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    component.set("v.loaded",true);
                    var res = response.getReturnValue();
                    console.log('res',res);
                    component.set("v.isOpen",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Child ERA and ERALineItems updated successfully",
                        "type" : "success"
                    });
                    toastEvent.fire()
                    //this.saveChildEraLines(component,event);
                }
                catch(e){
                    alert(e);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    formulatePostingJSON : function(component,event,helper) {
        let lineItemLst = component.get("v.eraLineLst");
        let totalPatientResp = 0;
        let totalOtherInsResp = 0;
        lineItemLst.forEach(function(element) {
            if(!$A.util.isUndefinedOrNull(element.patientResponsibility)){
                totalPatientResp+=element.patientResponsibility;
            }
            if(!$A.util.isUndefinedOrNull(element.insuranceResponsibility)){
                totalOtherInsResp+=element.insuranceResponsibility;
            }
        }); 
        console.log('totalPatientResp '+totalPatientResp);
        console.log('totalOtherInsResp '+totalOtherInsResp);
        var arrObj = [];
        var sObj = {                 
            'patientId' : component.get("v.patientId"), 'claimId' : component.get("v.claimId"),
            'totalBilledAmount' : component.get("v.BilledAmount"),                  
            'totalAllowedAmt' : component.get("v.TotalAllowedAmount"),
            'totalAdjustmentAmt' : component.get("v.TotalAdjustmentAmt"),
            'paidAmt' : component.get("v.TotalPaid"),
            'actionToBeTakenVal' : component.get("v.actionToBeTakenSelected"),
            'netPaidAmount': component.get("v.netPaid"),
            'ver_1_toalPatientResp' : totalPatientResp , 'ver_1_totalOtherInsResp' : totalOtherInsResp , 
            'openLineItemWindow' : false,'lineItemLst' : helper.setLineItemForEachChildERA(component, event, helper)};
        arrObj.push(sObj);
        return arrObj;
    },
    setLineItemForEachChildERA : function(component,event,helper) {
        var lstArr = [];
        let lineItemLst = component.get("v.eraLineLst");
        lineItemLst.forEach(function(element) {
            lstArr.push(helper.setJSONKeysForLineItem(component, event, helper,element));
        }); 
        return lstArr;
    },
    setJSONKeysForLineItem :  function(component,event,helper,obj) {        
        return {'claimLineItemId':obj.claimLineItemId,
                'billedAmt' : obj.billedAmount ,             
                'paidAmt' : obj.paidAmount,
                'allowedAmt' : obj.allowedAmount,
                'adjustMentAmt' : obj.adjustmentAmount,
                'providerAdj' : obj.providerAdjustment,
                'patientResp' : obj.patientResponsibility,
                'otherInsuranceResposibility' : obj.insuranceResponsibility, 
                 'selectedInfoRemarkCodes':obj.ElixirSuite__Adjustment_Remark_Codes__c, //Added by Neha 
                 'infoRemarkCodes' : component.get("v.infoRemarkCodesPicklistVal") //Added by Neha 
               };                                                
    },
    setERAValuesFromParentScreen :  function(component,event,helper,mode) {
        
        var eraList = component.get("v.eraLineLst");
       // var eraObject = component.get("v.era");
        var billedAmount = 0;
        var paidAmt =0;
        var netAmt =0;
        var ptResponse = 0;
        var interestlateFiling = 0;
        //var providerAdAmt = 0;
       // var otherInResponse = 0;
        var allowedAmt = 0;
        var matched = 0;
        var otherResponse = 0;
        var totaProvider = 0;
        
        if(mode ==='delete'){
            for(var i=0;i <eraList.length; i++){
                paidAmt+=parseFloat(eraList[i].eralineItem.ElixirSuite__Paid__c);
                allowedAmt+=parseFloat(eraList[i].eralineItem.ElixirSuite__Total_Allowed_Amount__c);
                ptResponse+=parseFloat(eraList[i].eralineItem.ElixirSuite__Patient_Responsibility__c);
                if(eraList[i].eralineItem.ElixirSuite__Claim_Line_Items__c!=''){
                    matched+=parseFloat(eraList[i].eralineItem.ElixirSuite__Paid__c);
                }
                
            }
        }else if(mode ==='edit'){
            for(var i=0;i <eraList.length; i++){
                paidAmt+=parseFloat(eraList[i].paidAmount);
                allowedAmt+=parseFloat(eraList[i].allowedAmount);
                ptResponse+=parseFloat(eraList[i].patientResponsibility);
                if(eraList[i].eralineItem.ElixirSuite__Claim_Line_Items__c!=''){
                    matched+=parseFloat(eraList[i].paidAmount);
                }
            }
        }
        
        netAmt = component.get("v.netPaid");
        billedAmount = component.get("v.BilledAmount");
        
        paidAmt = paidAmt ? paidAmt : 0 ;
        ptResponse = ptResponse ? ptResponse : 0 ;
        allowedAmt = allowedAmt ? allowedAmt : 0 ;
        billedAmount = billedAmount ? billedAmount : 0 ;
        netAmt = netAmt ? netAmt : 0 ;
        matched = matched ? matched : 0 ;
        
        var unmatched = paidAmt - matched;
        interestlateFiling = netAmt- paidAmt; 
        otherResponse = allowedAmt - (ptResponse + paidAmt);
        
        interestlateFiling = interestlateFiling ? interestlateFiling : 0 ;
        
        totaProvider = billedAmount - (paidAmt +interestlateFiling);
        
        
        component.set("v.TotalPaid",parseFloat(paidAmt).toFixed(2));
        component.set("v.TotalAllowedAmount",parseFloat(allowedAmt).toFixed(2));
        component.set("v.MatchedAmt",parseFloat(matched).toFixed(2));
        
        component.set("v.BilledAmount",parseFloat(billedAmount).toFixed(2));
        var totalAdj = parseFloat(billedAmount) - parseFloat(paidAmt);
        component.set("v.TotalAdjustmentAmt",parseFloat(totalAdj).toFixed(2));
        component.set("v.UnmatchedAmt",parseFloat(unmatched).toFixed(2));        
        component.set("v.netPaid",parseFloat(netAmt).toFixed(2));
        
        component.set("v.PatientResponsibility",parseFloat(ptResponse).toFixed(2));
        //component.set("v.interestLateFilingCharges",res.eob.ElixirSuite__Interest_Late_Filling_Charges__c);
        var insLateFile = parseFloat(netAmt)- parseFloat(paidAmt);
        component.set("v.interestLateFilingCharges",parseFloat(insLateFile).toFixed(2));
        component.set("v.TotalProviderAdjustmentAmt",parseFloat(totaProvider).toFixed(2));
        
        component.set("v.OtherInsuranceResponsibility",parseFloat(otherResponse).toFixed(2));                        
        
    },
    validateNoteRecords: function(component) {
        var noteList = component.get("v.noteList");
        var toastEvent = $A.get("e.force:showToast");
        if(noteList == null || noteList.length == 0){
            return true;
        }
        var todayDate = $A.localizationService.formatDateUTC(new Date(), "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'");
        if(noteList.length == 1){
            if (noteList[0].ElixirSuite__Follow_Up_Notes__c == '' && noteList[0].ElixirSuite__Elixir_Assigned_To__c == '' && (noteList[0].ElixirSuite__Elixir_Follow_up_Date__c == '' || noteList[0].ElixirSuite__Elixir_Follow_up_Date__c == null) ) {
              return true;  
            }else if(noteList[0].ElixirSuite__Follow_Up_Notes__c != '' && noteList[0].ElixirSuite__Elixir_Assigned_To__c != '' && (noteList[0].ElixirSuite__Elixir_Follow_up_Date__c != '' || noteList[0].ElixirSuite__Elixir_Follow_up_Date__c != null)){
                  if(noteList[0].ElixirSuite__Elixir_Follow_up_Date__c <= todayDate){
                  // var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Follow-up date should be greater than today's date.",
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
                return true;
            }else{
               // var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete Follow up Notes on row Number 1",
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            
        }else{
        for (var i = 0; i < noteList.length; i++) {
            if (noteList[i].ElixirSuite__Follow_Up_Notes__c == '' || noteList[i].ElixirSuite__Elixir_Assigned_To__c == '' || noteList[i].ElixirSuite__Elixir_Follow_up_Date__c == '' || noteList[i].ElixirSuite__Elixir_Follow_up_Date__c == null) {
               // var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Complete Follow up Notes on row Number "+(i+1),
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            else if(noteList[i].ElixirSuite__Elixir_Follow_up_Date__c <= todayDate){
                  // var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Follow-up date should be greater than today's date on row "+(i+1),
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
        }
        
        return true;
        }
    },
    validateRecommendations: function(component, event) {
        var rList = component.get("v.recommendationList");
        var toastEvent = $A.get("e.force:showToast");
        if(rList == null || rList.length == 0){
            return true;
        }
        if(rList.length == 1){
            if((rList[0].ElixirSuite__Elixir_Recommendation__c == '' && rList[0].ElixirSuite__Elixir_Assign_To__c =='') || rList[0].ElixirSuite__Elixir_Recommendation__c != ''){
               return true; 
            }else{
                // var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please fill in the recommendation for Assign To users",
                    "type" : "error"
                });
                toastEvent.fire(); 
                return false;
            }
            
        }else{
        for (var i = 0; i < rList.length; i++) {
                    if (rList[i].ElixirSuite__Elixir_Recommendation__c == '') {
                        if(rList[i].ElixirSuite__Elixir_Assign_To__c == ''){
                         //   var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please fill the recommendation for all the rows in the recommendation table ",
                                "type" : "error"
                            });
                            toastEvent.fire(); 
                            return false;   
                        }
                       // var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please fill in the recommendation for all Assigned to users ",
                            "type" : "error"
                        });
                        toastEvent.fire(); 
                        return false;
                    }
                }
        return true;
        }
    },
    
})