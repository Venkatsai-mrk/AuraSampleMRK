({
    setDefaultJSON : function(component) {
        component.set("v.attachClaimParam",{"patientId" : '' , "patientName" : '' ,"claimHash" : '','openResultTable' : false});
    },
    fetchAllClaims : function(component, event, helper,existingClaimIds) {
        if(component.get("v.EOBRecToSave").ElixirSuite__Payer__c){
            if(component.get("v.attachClaimParam").patientId || component.get("v.attachClaimParam").claimHash){
                let attachClaimParam = component.get("v.attachClaimParam");
                attachClaimParam.openResultTable = false;
                component.set("v.attachClaimParam",attachClaimParam);
                var action = component.get("c.queryAllClaims");
                component.set("v.loaded",false);
                action.setParams({
                    patientId :  component.get("v.attachClaimParam").patientId,
                    claimName :  component.get("v.attachClaimParam").claimHash,
                    payorId : component.get("v.EOBRecToSave").ElixirSuite__Payer__c,
                    existingClaimIds : existingClaimIds
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true); 
                        var result = response.getReturnValue();
                        console.log('allClaims'+JSON.stringify(result));
                        if(!$A.util.isEmpty(result)){
                            helper.populateClaimListTable(component, event, helper,result);   
                        }
                        else {
                            helper.flagNoResult();   
                        }
                        
                    }
                    else{ 
                        component.set("v.loaded",true);
                        var errors = response.getError();
                         var online = response.getError();
                        if (errors) {
                            if (errors[0] && online[0].message) {
                                console.log("Error message: " +
                                            errors[0].message);
                            }        }
                    }            
                });
                
                $A.enqueueAction(action); 
            }
            else {
                helper.flagEmptySearch();
            }
        }
        else {
            helper.flagPayorMissing();
        }
        
    },
    populateClaimListTable :  function(component, event, helper,result) {        
        try{
            let redArr = [];
            let whiteArr = [];
            result.forEach( function(element) {
                let patientName = 'N/A';
                if(element.hasOwnProperty('ElixirSuite__Account__r')){
                    patientName = element.ElixirSuite__Account__r.Name;
                }
                element['patientId'] = element.ElixirSuite__Account__c;
                element['patientName'] = patientName;
                element['ClaimNumber'] = element.Name;
                element['claimId'] = element.Id;
                element['isClaimPosted'] = element.ElixirSuite__Posted__c;
                element['attachAbility'] = false; 
                if(element.hasOwnProperty('ElixirSuite__Master_ERA__c')){
                    element['cssClass'] = 'elemtRed'; 
                    redArr.push(element);
                }
                else {
                    element['cssClass'] = ''; 
                    whiteArr.push(element);
                }
            });
            whiteArr = whiteArr.concat(redArr);
            component.set("v.allClaimResultTable",whiteArr);
            let attachClaimParam = component.get("v.attachClaimParam");
            attachClaimParam.openResultTable = true;
            component.set("v.attachClaimParam",attachClaimParam);
        }
        catch(e){
            alert(e);
        }
    },
    fetchClaimPicklist : function(component, event, helper,obj) {  
        var action = component.get("c.fetchPicklistValuesForClaimFields");
        component.set("v.loaded",false);
        action.setParams({
            lstOfFields : ['ElixirSuite__ERA_Status_Code__c','ElixirSuite__Action_to_be_Taken__c'],
            claimId : obj.claimId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    
        			console.log('Payor:::',result.payorOrder);
                    var arr = helper.formaulateeraStatusCodeToBeArrFromMap(component, event, helper,result.mapOfEraStatusCode,result.SecInsACC,obj.ElixirSuite__Account__c,result.payorOrder);
                    var actionsArr = helper.formaulatePicklistArrFromMap(component, event, helper,result.mapOfActionsToBeTaken);
                    helper.setJSONKeys(component, event, helper,obj,arr,result.claimLineItemData,actionsArr, result.defaultValueForActionTBTField,result);
                    
                }
                catch(e){
                    alert(e);
                }
                
            }
            else{ 
                component.set("v.loaded",true);
                var errors = response.getError();
                var online = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }            
        });
        
        $A.enqueueAction(action); 
    }, 
    setJSONKeys :  function(component, event, helper,obj,arr,claimLineItemData,actionToBeTakenArr,defaultValueForActionTBTField,result) {
        var cntAmt = 0;
      //  let paymentStatus =  helper.getPaymentStatus(component, event, helper,obj);  
        if(obj.ElixirSuite__Total_Contracted_Amount__c != undefined && obj.ElixirSuite__Total_Contracted_Amount__c != null){
                 cntAmt = obj.ElixirSuite__Total_Contracted_Amount__c;
                }
        let sObj = {'claimId' : obj.Id,'patientName' : obj.patientName, 'ClaimNumber' : obj.ClaimNumber, 'payerClaimHash' : '','eraStatusCodePickLstVal' : arr,
                    'openEraHash' : false,
                    'eraHash' : '','actionToBeTakenPickLstVal' : helper.formaulateActionToBeArrFromMap(component, event, helper,result.mapOfActionsToBeTaken,result.SecInsACC,obj.ElixirSuite__Account__c,result.payorOrder) , 'actionToBeTakenVal' : defaultValueForActionTBTField,
                    'patientId' : obj.patientId, 'claimId' : obj.claimId, 'eraStatusCode' : '',
                    'totalBilledAmount' : obj.ElixirSuite__Total_Charge__c, 
                    'totalContractedAmt' : cntAmt,
                    'totalAllowedAmt' : obj.ElixirSuite__Total_Charge__c,
                    'totalAdjustmentAmt' : 0,
                    'ver_1_toalPatientResp' : 0 , 
                    'ver_1_totalOtherInsResp' : 0 ,
                    'paidAmt' : obj.ElixirSuite__Total_Charge__c,
                    'netPaidAmount': obj.ElixirSuite__Total_Charge__c,
                    'paymentStatus' : 'N/A',
                    'isSelectedForPosting' : false,
                    'isPosted' : false,
                    'openLineItemWindow' : false,
                    'lineItemLst' : helper.setLineItemForEachChildERA(component, event, helper,claimLineItemData)};
        let eraTableLst = component.get("v.childERAtableList");
        eraTableLst.push(JSON.parse(JSON.stringify(sObj)));
        component.set("v.childERAtableList",eraTableLst);
    },
    setLineItemForEachChildERA :  function(component, event, helper,result) {
        helper.arrangeRasonMDTValues(component, event, helper,result.mapOfCodeToDesciption);
        console.log('result line item '+JSON.stringify(result));
        let lineItemLst = result.allRelatedClaimLineItem;
        console.log('lineItemLst'+JSON.stringify(lineItemLst));
        let lstArr = [];
        lineItemLst.forEach(function(element) {
            lstArr.push(helper.setJSONKeysForLineItem(component, event, helper,element));
        });  
        return lstArr; 
    },
    setLineItemForEachChildERAOnInit :  function(component, event, helper,result,allRelatedClaimLineItem) {
        helper.arrangeRasonMDTValues(component, event, helper,result.mapOfCodeToDesciption);
        console.log('result line item '+JSON.stringify(result));
        let lineItemLst = allRelatedClaimLineItem;
        var lstArr = [];
        if(!$A.util.isUndefinedOrNull(lineItemLst)){
            console.log('lineItemLst'+JSON.stringify(lineItemLst));
            
            lineItemLst.forEach(function(element) {
                lstArr.push(helper.setJSONKeysForLineItemOnInit(component, event, helper,element));
            });
            console.log('====lstArr====='+JSON.stringify(lstArr));
        }
        
        return lstArr;
    },
    setJSONKeysForLineItem : function(component, event, helper,obj) {
        var procName = '';
        var procCode = 'N/A';
        var procCodeNameAndDescription = '';
        if(obj.hasOwnProperty('ElixirSuite__Procedure__r')){
            if(obj.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c != undefined && obj.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c != null){
             procCode = obj.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c;   
            }
            procCodeNameAndDescription = obj.ElixirSuite__Procedure__r.Name;
            procName = obj.ElixirSuite__Procedure__r.Name;
            if(obj.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c != undefined && obj.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c != null){
                 procCodeNameAndDescription =procCodeNameAndDescription +' - '+obj.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c;   
                }
            
        }
        let lineItemTotalCharge = 0;
        if(obj.ElixirSuite__Days_Units__c != undefined && obj.ElixirSuite__Days_Units__c != null && obj.ElixirSuite__Days_Units__c  != 0){
         lineItemTotalCharge = obj.ElixirSuite__Days_Units__c * obj.ElixirSuite__Procedure_Charge__c; 
        }else{
         lineItemTotalCharge = obj.ElixirSuite__Procedure_Charge__c;  
        }
        
        return {'claimLineItemId':obj.Id,
                'procCode' : procName,
                'procCodeERAprocLineItem' : procName,
                'procCodeNameAndDescription':procCodeNameAndDescription,
                'billedAmt' : lineItemTotalCharge , 
                'conctAmt' : obj.ElixirSuite__Contracted_Amount__c,
                'paidAmt' : lineItemTotalCharge,
                'allowedAmt' : lineItemTotalCharge,
                'adjustMentAmt' : 0,
                'providerAdj' : 0,
                'patientResp' : 0,
                'otherInsuranceResposibility' : 0,               
                'paymentStatus' :'N/A' , 
                'adjustmentCodeTable' : helper.adjustmentCodeTableArray(component)};
    },
    setJSONKeysForLineItemOnInit : function(component, event, helper,obj) {
        var hasClaimLineItem = true;
        if(!obj.hasOwnProperty('ElixirSuite__Claim_Line_Items__c')){
            hasClaimLineItem = false;
        }
     //   var procCode = 'N/A';
        var procName = '';
         var procCodeNameAndDescription = '';
        if(obj.hasOwnProperty('ElixirSuite__Claim_Line_Items__r')){
            if(obj.ElixirSuite__Claim_Line_Items__r.hasOwnProperty('ElixirSuite__Procedure__r')){
                if(obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c != undefined && obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c != null)
                { procCode = obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c;}
                procCodeNameAndDescription = obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.Name;
                procName = obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.Name;
                if(obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c != undefined && obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c != null){
                 procCodeNameAndDescription =procCodeNameAndDescription +' - '+obj.ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__Code_Description__c;   
                }
                
            }
        }
        //Added By Neha
        let suppRemarkCode = obj.ElixirSuite__Adjustment_Remark_Codes__c;
        console.log('====suppRemarkCode====',suppRemarkCode);
        if(String(suppRemarkCode)!='undefined'){
            var suppRemarkCodes = String(suppRemarkCode).split(";");
            var suppRemarkCodeList = [];
            for(let i in suppRemarkCodes){
                //var suppRemark = {};
                //  suppRemark = JSON.parse(suppRemarkCodes[i]);
                var codeobj = {Id:suppRemarkCodes[i],Name:suppRemarkCodes[i]};
                suppRemarkCodeList.push(codeobj);
            }
            //  component.set("v.selectedInfoRemarkCodes",suppRemarkCodeList);
            
            console.log('meghna',component.get("v.selectedInfoRemarkCodes"));
        }
        //
        //
        //Ak
        var patResp = 0;
        if(obj.hasOwnProperty('ElixirSuite__Patient_Responsibility__c')){
            patResp =obj.ElixirSuite__Patient_Responsibility__c;
        }
        var otherResp = 0;
        if(obj.hasOwnProperty('ElixirSuite__Other_Insurance_Responsibility__c')){
            otherResp =obj.ElixirSuite__Other_Insurance_Responsibility__c;
        }
        var adAmt = 0;
        if(obj.hasOwnProperty('ElixirSuite__Total_Adjustment_Amount__c')){
            adAmt =obj.ElixirSuite__Total_Adjustment_Amount__c;
        }
        var pdAmt = 0;
        if(obj.hasOwnProperty('ElixirSuite__Provider_Adjustment__c')){
            pdAmt =obj.ElixirSuite__Provider_Adjustment__c;
        }
        
        console.log('===obj ===='+JSON.stringify(obj));
        console.log('===infoRemarkCodes==='+JSON.stringify(obj.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c));
        console.log('===suppRemarkCodes==='+JSON.stringify(component.get("v.suppRemarkCodesPicklistVal")));
       // var tempList ;
        return {'Id':obj.Id,
                'claimLineItemId':obj.ElixirSuite__Claim_Line_Items__c,
                'procCodeERAprocLineItem' : obj.ElixirSuite__Proc_code__c,
                'procCode' : procName,
                'procCodeNameAndDescription': procCodeNameAndDescription, //Added by Anusha - LX3-5744 -14/10/22
                'billedAmt' : obj.ElixirSuite__Charge__c,
                'allowedAmt' : obj.ElixirSuite__Total_Allowed_Amount__c,
                'adjustMentAmt' : adAmt,
                'providerAdj' : pdAmt, 
                'paidAmt' : obj.ElixirSuite__Paid__c,
                'patientResp' : patResp,
                'hasClaimLineItem' : hasClaimLineItem,
                'otherInsuranceResposibility' : otherResp,
                'adjustmentCodeTable' : helper.adjustmentCodeTableArrayOnInit(component, event, helper,obj),
                'selectedInfoRemarkCodes':suppRemarkCodeList, //Added by Neha 
                'infoRemarkCodes' : component.get("v.infoRemarkCodesPicklistVal") ,//Added by Neha 
                //'selectedInfoRemarksVal' : '', //Added by Neha 
                //'suppRemarkCodes':  component.get("v.suppRemarkCodesPicklistVal")   //Added by Neha 
               };
    },
    arrangeRasonMDTValues : function(component, event, helper,reasonCodeMap) {       
        let reasonLst = [];
        for (var key in reasonCodeMap) {            
            reasonLst.push({value:key, label:reasonCodeMap[key]});
        }
        component.set("v.reasonList",reasonLst);
        console.log('reasonList'+JSON.stringify(component.get("v.reasonList")));
    },
    adjustmentCodeTableArray :     function(component) {
        return [{'adjCdTbl_adjustmentAmount' : 0, 
                 'adjCdTbl_adjustmentCodeReason' : 'X45' , 
                 'adjCdTbl_adjustmentGroupCode' : 'CO',
                 'reasonList' : JSON.parse(JSON.stringify(component.get("v.reasonList"))) , 
                 'adjustmentGrpCodeLst' : JSON.parse(JSON.stringify(component.get("v.arrGrpCode"))),
                 'suppRemarkCode':'',   //Added by Neha 
                 'suppRemarkCodeList':component.get("v.suppRemarkCodesPicklistVal")  //Added by Neha 
                }];
    },
    adjustmentCodeTableArrayOnInit : function(component, event, helper,obj) {
        var adjTableArr = [];
        let totalMaxUsedPointer = obj.ElixirSuite__Count_of_total_adjustments_used__c;
        console.log('====reasonList===='+component.get("v.reasonList"));
        console.log('line322**1');
        
        if(totalMaxUsedPointer != 0 && totalMaxUsedPointer != null && totalMaxUsedPointer != ''){
            
             for(let i=1;i<=totalMaxUsedPointer;i++){
                var reasLst = component.get("v.reasonList");
                reasLst.push({value:obj['ElixirSuite__Code_'+i+'__c'], label:obj['ElixirSuite__Code_'+i+'__c']});
                component.set("v.reasonList",reasLst);
            }   
            
        }
        if(totalMaxUsedPointer == 0){
            adjTableArr =  [{'adjCdTbl_adjustmentAmount' : 0, 
                             'adjCdTbl_adjustmentCodeReason' : 'X45' , 
                             'adjCdTbl_adjustmentGroupCode' : 'CO',
                             'reasonList' : JSON.parse(JSON.stringify(component.get("v.reasonList"))) , 
                             'adjustmentGrpCodeLst' :JSON.parse(JSON.stringify(component.get("v.arrGrpCode"))),
                             'suppRemarkCode':'',  //Added by Neha 
                             'suppRemarkCodeList':component.get("v.suppRemarkCodesPicklistVal") //Added by Neha 
                            }];  
        }
        else {
            for(let i=1;i<=totalMaxUsedPointer;i++){
                adjTableArr.push({'adjCdTbl_adjustmentAmount' : obj['ElixirSuite__Adjustment_Amount_'+i+'__c'], 
                                  'adjCdTbl_adjustmentCodeReason' : obj['ElixirSuite__Code_'+i+'__c'] , 
                                  'adjCdTbl_adjustmentGroupCode' : obj['ElixirSuite__Group_'+i+'__c'],
                                  'reasonList' : JSON.parse(JSON.stringify(component.get("v.reasonList"))) , 
                                  'adjustmentGrpCodeLst' : JSON.parse(JSON.stringify(component.get("v.arrGrpCode"))),
                                  'suppRemarkCode':obj['ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c'], //Added by Neha 
                                  'suppRemarkCodeList':component.get("v.suppRemarkCodesPicklistVal") //Added by Neha 
                                 });
            }   
        }
        return adjTableArr;
    },
    arrangeAdjustmentGrpCodeValues :   function() {       
        return [
            { value: "CO", label: "CO - Contractual Obligations" },
            { value: "OA", label: "OA - Other Adjustments" },
            { value: "PI", label: "PI - Payer Initiated Reductions" },
            { value: "PR", label: "PR - Patient Responsibility" }
        ];
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
    validateNoteRecords: function(component, event, index) {
        console.log('val- index-- '+index);
        var eraNoteList = component.get("v.noteList");
        var toastEvent = $A.get("e.force:showToast");
        console.log('val- eraNoteList-- '+JSON.stringify(eraNoteList));
        var noteList = eraNoteList[index];
        console.log('noteList-- '+JSON.stringify(noteList));
        if(noteList !=null){
            var todayDate = $A.localizationService.formatDateUTC(new Date(), "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'");
            if(noteList.length == 1){
                if (noteList[0].ElixirSuite__Follow_Up_Notes__c == '' && noteList[0].ElixirSuite__Elixir_Assigned_To__c == '' && (noteList[0].ElixirSuite__Elixir_Follow_up_Date__c == '' || noteList[0].ElixirSuite__Elixir_Follow_up_Date__c == null)) {
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
        }
        else{
            return true
        }
    },
    validateRecommendations: function(component, event, index) {
        console.log('val- index-- '+index);
        var toastEvent = $A.get("e.force:showToast");
        var eraRecommendationList = component.get("v.recommendationList");
        console.log('val- eraRecommendationList-- '+JSON.stringify(eraRecommendationList));
        var rList = eraRecommendationList[index];
        console.log('rList-- '+JSON.stringify(rList)); 
        if(rList !=null){
            if(rList.length == 1){
                if((rList[0].ElixirSuite__Elixir_Recommendation__c == '' && rList[0].ElixirSuite__Elixir_Assign_To__c =='') || rList[0].ElixirSuite__Elixir_Recommendation__c != ''){
                    return true; 
                }else{
                   // var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please fill in the recommendation for Assign To user for "+rList[0].ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name,
                        "type" : "error"
                    });
                    toastEvent.fire(); 
                    return false;
                }
                
            }else{
                for (var i = 0; i < rList.length; i++) {
                    if (rList[i].ElixirSuite__Elixir_Recommendation__c == '') {
                        if(rList[i].ElixirSuite__Elixir_Assign_To__c == ''){
                            //var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please fill the recommendation for all the rows in the recommendation table for " +rList[i].ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name,
                                "type" : "error"
                            });
                            toastEvent.fire(); 
                            return false;   
                        }
                        //var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please fill in the recommendation for all Assigned to users for the "+rList[i].ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name,
                            "type" : "error"
                        });
                        toastEvent.fire(); 
                        return false;
                    }
                }
                return true;
            }
        }else{
            return true;
        }
    },
    initPayloadGenericCallBack :  function(component, event, helper) { 
        var action = component.get("c.fetchInitPayload");
        component.set("v.loaded",false);
        action.setParams({
            lstOfFields : ['ElixirSuite__Payment_Method__c','ElixirSuite__Adjustment_Remark_Codes__c'],
            parentERARecord : component.get("v.parentERARecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getError());
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true); 
                    //Added by Neha 
                    const infoCodeList = response.getReturnValue().infoCodePicklistValues;
                    console.log('======infoCodeList======'+JSON.stringify(infoCodeList));
                    var infoCodeListOfObj = [];
                    for(let i in infoCodeList){
                        const codeobj = {Id:infoCodeList[i],Name:infoCodeList[i]};
                        infoCodeListOfObj.push(codeobj);
                    }
                    console.log('====infoRemarkCodesPicklistVal==='+JSON.stringify(infoCodeListOfObj));
                    component.set("v.infoRemarkCodesPicklistVal",infoCodeListOfObj);
                    component.set("v.suppRemarkCodesPicklistVal",response.getReturnValue().SuppCodePicklistValues);
                    //
                    var result = response.getReturnValue().fieldsDataGeneric;
                    var arr = [];
                    for(let obj in result.mapOfClaimPaymentMethod){
                        let sObj = {'label' : obj, 'value' : result.mapOfClaimPaymentMethod[obj]};
                        arr.push(sObj);
                    }               
                    component.set("v.paymentMethodLst",arr);
                    
                    let arrGrpCode = [];
                    for(let obj in result.mapOfAdjustmentgroupCode){
                        let instanceVar = {'label' : result.mapOfAdjustmentgroupCode[obj], 'value' : obj};
                        arrGrpCode.push(instanceVar);
                    }               
                    component.set("v.arrGrpCode",arrGrpCode);
                    
                    
                    helper.arrangeEOBLineItemMap(component, event, helper,response.getReturnValue().childEOBLst,response.getReturnValue().allRelatedClaimLineItem);
                    helper.arrangeParentEOBRecord(component, event, helper,response.getReturnValue().parentEOBRecord[0]);
                    helper.arrangechildEOBData(component, event, helper,response.getReturnValue());
                }
                catch(e){
                    alert(e);
                   
                }
                
            }
            else{ 
                component.set("v.loaded",true);
                var errors = response.getError();
                var online = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }            
        });
        
        $A.enqueueAction(action); 
    },
    arrangeEOBLineItemMap :  function(component, event, helper,childEOBLst,allRelatedClaimLineItem) {
        let EOBLineItemMap = {};
        childEOBLst.forEach( function(obj) {
            allRelatedClaimLineItem.forEach( function(objRelatedClaim, index_RelatedClaim) {
                if(objRelatedClaim.ElixirSuite__EOB__c == obj.Id){
                    if(EOBLineItemMap.hasOwnProperty(obj.Id)){
                        EOBLineItemMap[obj.Id].push(objRelatedClaim); 
                    }
                    else {
                        EOBLineItemMap[obj.Id] = [];
                        EOBLineItemMap[obj.Id].push(objRelatedClaim);
                    }                    
                }
            });
        });
        component.set("v.EOBLineItemMap",EOBLineItemMap);
    },
    arrangeParentEOBRecord :  function(component, event, helper,record) {
        component.set("v.payerName",helper.checkGlobalRelationNull(component, event, helper,record,'ElixirSuite__Payer__r'));
        component.set("v.ERAName",record.Name);
        component.set("v.EOBRecToSave",{ 
            'sobjectType': 'ElixirSuite__EOB__c',  
            'Name' : record.Name,
            'Id' : record.Id,
            'ElixirSuite__Check_EFT_Date__c': record.ElixirSuite__Check_EFT_Date__c ,
            'ElixirSuite__EOB_Id__c': record.ElixirSuite__EOB_Id__c,
            'ElixirSuite__Payer__c': record.ElixirSuite__Payer__c,
            'ElixirSuite__Payment_Method__c': record.ElixirSuite__Payment_Method__c,
            'ElixirSuite__Total_Paid__c' : record.ElixirSuite__Total_Paid__c,
            'ElixirSuite__Payment_Trace__c' : record.ElixirSuite__Payment_Trace__c});         
    },
    arrangechildEOBData :  function(component, event, helper,response) {
        let EOBLineItemMap = component.get("v.EOBLineItemMap");
        console.log('===EOBLineItemMap==='+JSON.stringify(EOBLineItemMap));
        let childEOBLst = response.childEOBLst;
        let mapOferaToLineItem = response.mapOferaToLineItem;
        var arr = [];
        childEOBLst.forEach( function(obj) {
            let isMatched = true;
            let cssClass = '';
            let isAllowedForPosting = false;
            if(!mapOferaToLineItem.hasOwnProperty(obj.Id)){
                isMatched = false;
                cssClass = 'elemtRed';
                isAllowedForPosting = true;
            }
            else if(obj.ElixirSuite__Primary_Posted__c){
                isAllowedForPosting = true; 
            }
            let isClaimPosted = false; 
            if(obj.hasOwnProperty('ElixirSuite__Claim__r')){
                isClaimPosted =  obj.ElixirSuite__Claim__r.ElixirSuite__Posted__c
            }
            var patResp = 0;
            if(obj.hasOwnProperty('ElixirSuite__Total_Patient_Responsibility__c')){
                patResp =obj.ElixirSuite__Total_Patient_Responsibility__c;
            }
            var otherResp = 0;
            if(obj.hasOwnProperty('ElixirSuite__Total_OI_Responsibility__c')){
                otherResp =obj.ElixirSuite__Total_OI_Responsibility__c;
            }
            var payerorder;
            if(obj.ElixirSuite__Claim__c != undefined && obj.ElixirSuite__Claim__c != null && obj.hasOwnProperty('ElixirSuite__Claim__r')){
                if(obj.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c != undefined && obj.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c != null)  {
                 payerorder = obj.ElixirSuite__Claim__r.ElixirSuite__Payer_Order__c;   
                } 
            }
            arr.push({'Id' : obj.Id,'patientName' : helper.checkGlobalRelationNull(component, event, helper,obj,'ElixirSuite__Account__r') , 'ClaimNumber' :  helper.checkGlobalRelationNull(component, event, helper,obj,'ElixirSuite__Claim__r'),
                      'eraHash' : obj.Name, 'openEraHash' : false,
                      'payerClaimHash' : obj.ElixirSuite__Payer_Claim__c,'eraStatusCodePickLstVal' : helper.formaulateeraStatusCodeToBeArrFromMap(component, event, helper,response.mapOfEraStatusCode,response.SecInsACC,obj.ElixirSuite__Account__c,payerorder),
                      'patientId' : obj.ElixirSuite__Account__c, 'claimId' : obj.ElixirSuite__Claim__c, 'eraStatusCode' : obj.ElixirSuite__ERA_Status_Code__c,
                      'totalBilledAmount' : obj.ElixirSuite__Total_Charge__c, 
                      'totalAllowedAmt' : obj.ElixirSuite__Total_Allowed__c,
                      'paidAmt' : obj.ElixirSuite__Total_Paid__c, // total PaidAmt
                      'netPaidAmount': obj.ElixirSuite__Net_Paid_Amt__c,
                      'matchedERA' : isMatched,
                      'totalAdjustmentAmt' : obj.ElixirSuite__Total_Adjustment_Amount__c,
                      'ver_1_toalPatientResp' : patResp, 
                      'ver_1_totalOtherInsResp' : otherResp,
                      'cssClass' : cssClass,
                      'isPosted' : obj.ElixirSuite__Primary_Posted__c,
                      'isClaimPosted' : isClaimPosted,
                      'isAllowedForPosting' : isAllowedForPosting,
                      'isSelectedForPosting' : false,
                      'actionToBeTakenPickLstVal' : helper.formaulateActionToBeArrFromMap(component, event, helper,response.mapOfEraActionsToBeTaken,response.SecInsACC,obj.ElixirSuite__Account__c,payerorder) , 
                      'actionToBeTakenVal' : obj.ElixirSuite__Action_to_be_Taken__c,
                      'openLineItemWindow' : false,
                      'lineItemLst' : helper.setLineItemForEachChildERAOnInit(component, event, helper,response,EOBLineItemMap[obj.Id])});            
        });
        /*  arr.forEach(function(element, index) {
            let lineItemLst = element.lineItemLst;
            lineItemLst.forEach(function(element_child, index_child) {
                if(element_child.hasClaimLineItem == false){
                    element['cssClass'] = 'elemtRed';
                }
            }); 
        }); */
        component.set("v.childERAtableList",arr);
        console.log("***%%%%%%",JSON.stringify(arr));
        component.set("v.childERAtableListCopy",JSON.parse(JSON.stringify(arr)));  
    },
    checkGlobalRelationNull :  function(component, event, helper,obj,propertyName) {
        var objToRet = '';
        if(obj.hasOwnProperty(propertyName)){
            objToRet = obj[propertyName].Name;
        }
        return objToRet;
    },
    formaulatePicklistArrFromMap :  function(component, event, helper,picklistValMap) {
        
        var arr = [];
        for(let obj in picklistValMap){
            let sObj = {'label' : obj, 'value' : picklistValMap[obj]};
            arr.push(sObj);
        }  
        return arr;
    },
    formaulateeraStatusCodeToBeArrFromMap :  function(component, event, helper,picklistValMap,secInsAcc,accId,payorOrder) {
        var arr = [];
        
        for(let obj in picklistValMap){
            if(accId != undefined && accId != null && ((secInsAcc.includes(accId) && payorOrder =='Secondary') || (payorOrder =='Secondary' && obj == 'Process as Primary')) && obj == 'Process as Primary'){
             delete picklistValMap[obj];
            }
           
        }  
        console.log('picklistValMap eraStatusCode '+JSON.stringify(picklistValMap));
        return helper.formaulatePicklistArrFromMap(component, event, helper,picklistValMap);
    },
    
    formaulateActionToBeArrFromMap :  function(component, event, helper,picklistValMap,secInsAcc,accId,payorOrder) {
        var arr = [];
        
        for(let obj in picklistValMap){
            if(accId != undefined && accId != null && (!(secInsAcc.includes(accId)) || (payorOrder =='Secondary' && obj == 'Transfer to Secondary')) && obj == 'Transfer to Secondary'){
             delete picklistValMap[obj];
            }
           
        }  
        console.log('picklistValMap bb'+arr);
        console.log('picklistValMap bb'+JSON.stringify(arr));
        return helper.formaulatePicklistArrFromMap(component, event, helper,picklistValMap);
    },
    flagNoResult :  function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "No result found!",
            "message":  "Please try another filter or clear filter!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    flagEmptySearch :  function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Please select Patient or Claim to search!",
            "message":  "Please try filter!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    flagPayorMissing : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Please select PAYOR to search!",
            "message":  "Please search payor!",
            "type" : "error"
        });
        toastEvent.fire(); 
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    calculateTotalAdjustment_OnAllowedAmtChanged : function(component, event, helper,allowedAmt,index) { 
        let childERAtableList = component.get("v.childERAtableList");
        if(!$A.util.isUndefinedOrNull(childERAtableList[index].totalBilledAmount)){
            childERAtableList[index].totalAdjustmentAmt = (childERAtableList[index].totalBilledAmount -allowedAmt);
            component.set("v.childERAtableList",childERAtableList); 
        }        
    },
    saveERAData : function(component, event, helper,isSaveAndNew) { 
        try{
            if(helper.checkValidity_eraStatCode(component, event, helper) == false){
                if(helper.checkValidity_netPaidAmt(component, event, helper)  == false){
                    console.log("childERAtableList  " +JSON.stringify({'childERAtableList' : component.get("v.childERAtableList")}));
                    console.log('===EOBRecToSave===',component.get("v.EOBRecToSave"));
                    console.log('===childERAToDel===',component.get("v.childERAToDel"));
                    var action = component.get("c.updateERAEOB");
                    component.set("v.loaded",false);
                    action.setParams({
                        eobParentRecord :  component.get("v.EOBRecToSave"),
                        stringifiedTablLst :  JSON.stringify({'childERAtableList' : component.get("v.childERAtableList")}),
                        childERAToDel :  component.get("v.childERAToDel"),
                        notes : JSON.stringify(component.get("v.noteList")),
                        delNotes : JSON.stringify(component.get("v.delNoteList")),
                        recommendation : JSON.stringify(component.get("v.recommendationList")),
                        delRecommendation : JSON.stringify(component.get("v.delRecommendationList"))
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            try{
                                component.set("v.loaded",true); 
                                helper.globalFlagToast(component, event, helper,'RECORD UPDATED!', ' ','success');
                                var cmpEvent = component.getEvent("ElixirOEM_BillingERARefresh");
                                cmpEvent.fire(); 
                                component.set("v.isOpen",false);
                                console.log(isSaveAndNew);
                                if(isSaveAndNew){
                                    component.set("v.openAddERAModal",true);  
                                }
                            }
                            catch(e){
                                alert(e);
                            }
                            
                        }
                        else{ 
                            component.set("v.loaded",true);
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && online[0].message) {
                                    console.log("Error message: " +
                                                errors[0].message);
                                }        }
                        }            
                    });
                    
                    $A.enqueueAction(action);  
                }
            }
        }
        catch(e){
            alert(e);
        }
    },
    checkValidity_eraStatCode: function(component, event, helper) { 
        var wasExecuted = false;
        let allClaimResultTable = component.get("v.childERAtableList");
        let index = 1;
        for(let rec in allClaimResultTable){
            if(!allClaimResultTable[rec].eraStatusCode){
                wasExecuted = true;
                helper.globalFlagToast(component, event, helper,'ERA Status code is mandatory on row '+index,' ','error');
                break;
            }
            index++;
        }
        return wasExecuted;
    },
    checkValidity_netPaidAmt: function(component, event, helper) { 
        var wasExecuted = false;
        let allClaimResultTable = component.get("v.childERAtableList");
        let index = 1;
        for(let rec in allClaimResultTable){
            if(!allClaimResultTable[rec].netPaidAmount){
                wasExecuted = true;
                helper.globalFlagToast(component, event, helper,'Net Paid Amount is mandatory on row '+index,' ','error');
                break;
            }
            index++;
        }
        return wasExecuted;
    },
    fetchLineItemPerClaim : function(component, event, helper,claimId,indexArr) {    
        var action = component.get("c.getClaimLineItemsInParent");
        component.set("v.loaded",false);
        action.setParams({
            claimId : claimId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true); 
                try{
                    component.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    if($A.util.isEmpty(result.allRelatedClaimLineItem)){
                        helper.globalFlagToast(component, event, helper,'No Line Items present for this Claim!', ' ','error');
                        
                    }
                    else {
                        let allClaimResultTable = component.get("v.childERAtableList");
                        allClaimResultTable.forEach( function(element, index) {
                            element.openLineItemWindow = false;
                        });
                        allClaimResultTable[indexArr].openLineItemWindow = true;
                        component.set("v.childERAtableList",allClaimResultTable); 
                    }
                    
                }
                catch(e){
                    alert(e);
                }
                
            }
            else{ 
                component.set("v.loaded",true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }            
        });
        
        $A.enqueueAction(action); 
    },
    removePostedChildERAs:function(component, event, helper) {
        let childERAtableList = component.get("v.childERAtableList");
        let eraTableCopy = JSON.parse(JSON.stringify(component.get("v.childERAtableList")));        
        for(let rec in childERAtableList){
            if(childERAtableList[rec].isPosted){
                let arrIndex = eraTableCopy.findIndex(obj_clRes => obj_clRes.Id == childERAtableList[rec].Id);
                if(arrIndex>=0){
                    eraTableCopy.splice(arrIndex, 1);
                }  
            }
        }
        component.set("v.childERAtableList",eraTableCopy);  
    },
    restoreChildERAs : function(component, event, helper) {
        component.set("v.childERAtableList",JSON.parse(JSON.stringify(component.get("v.childERAtableListCopy"))));  
    },
    filterERAsForPosting :  function(component, event, helper) {
        let childERAtableList = component.get("v.childERAtableList");
        let arr = [];
        for(let rec in childERAtableList){
            if(childERAtableList[rec].isSelectedForPosting){
                arr.push(JSON.parse(JSON.stringify(childERAtableList[rec])));
            }          
        } 
        return arr;
    },
    validatePostedClaims: function(component) {
        var flag = false;
        let lst = component.get("v.childERAtableList");
        var arrLst = [];
        lst.forEach(function(element, index) {
            if(element.isSelectedForPosting){
                if(element.isClaimPosted){
                    flag = true;
                    arrLst.push(element.ClaimNumber);  
                }
            }
        });
        component.set("v.postedClaimFlagLst",arrLst);
        return flag;
    },
    postPaymentCallout: function(component, event, helper) {
        var action = component.get("c.postERAPayments");
        component.set("v.loaded",false);
        component.set("v.flagPostedClaimLst",false);
        action.setParams({
            eobParentRecord :  component.get("v.EOBRecToSave"),
            stringifiedTablLst :  JSON.stringify({'childERAtableList' : helper.filterERAsForPosting(component, event, helper)}),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true);  
                    helper.globalFlagToast(component, event, helper,'PAYMENT POSTED!', ' ','success');
                    var cmpEvent = component.getEvent("ElixirOEM_BillingERARefresh");
                    cmpEvent.fire(); 
                    component.set("v.isOpen",false);
                }
                catch(e){
                    alert(e);
                }
                
            }
            else{ 
                component.set("v.loaded",true);
                var errors = response.getError();
                var online = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }            
        });
        
        $A.enqueueAction(action);  
    }
})