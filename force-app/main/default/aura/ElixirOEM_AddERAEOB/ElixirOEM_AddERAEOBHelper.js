({
    setDefaultJSON : function(component) {
        component.set("v.EOBRecToSave",{ 
            'sobjectType': 'ElixirSuite__EOB__c',                                                                         
            'ElixirSuite__Check_EFT_Date__c': '' ,
            'ElixirSuite__EOB_Id__c': '',
            'ElixirSuite__Payer__c': '',
            'ElixirSuite__Payment_Method__c': '',
            'ElixirSuite__Total_Paid__c' : '',
            'ElixirSuite__Payment_Trace__c' : ''});
        component.set("v.attachClaimParam",{"patientId" : '' , "patientName" : '' ,"claimHash" : '','openResultTable' : false});
    },
    
    setPaymentMethod : function(component,event,helper) {
        
        try{
            var action = component.get("c.getPaymentMethod");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var result = response.getReturnValue();
                    console.log('setPaymentMethod result***3',result);
                    component.set("v.defPaymentMethod",result.defPaymentMethodValue);
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0]) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    
    fetchAllClaims : function(component, event, helper,existingClaim) {
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
                    existingClaim : existingClaim
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.loaded",true); 
                        var result = response.getReturnValue();
                        console.log('allClaims'+JSON.stringify(result));
                        
                        var claimIdArr = [];
                        if(!$A.util.isEmpty(result)){
                            result.forEach(function(element) {
                                claimIdArr.push(element.Id);
                            });
                            helper.fetchRelatedChildERAs(component, event, helper,claimIdArr,result);
                            
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
    fetchRelatedChildERAs : function(component, event, helper,claimIdArr,result) {  
        var action = component.get("c.fetchAllRelatedERA");
        component.set("v.loaded",false);
        action.setParams({
            claimIdArr : claimIdArr
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true); 
                    var resp = response.getReturnValue();
                    helper.populateClaimListTable(component, event, helper,result,resp);
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
    populateClaimListTable :  function(component, event, helper,result,resp) {        
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
                if(resp.hasOwnProperty(element.Id)){
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
                    var arr = [];
                    var actionsArr = [];
                    for(let obj in result.mapOfEraStatusCode){
                        let sObj = {'label' : obj, 'value' : result.mapOfEraStatusCode[obj]};
                        arr.push(sObj);
                    }       
                    for(let obj in result.mapOfActionsToBeTaken){
                        let sObj = {'label' : obj, 'value' : result.mapOfActionsToBeTaken[obj]};
                        actionsArr.push(sObj);
                    }
                    helper.setJSONKeys(component, event, helper,obj,arr,result.claimLineItemData,actionsArr,
                                       result.defaultValueForActionTBTField);
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
    setJSONKeys :  function(component, event, helper,obj,arr,claimLineItemData,actionToBeTakenArr,defaultValueForActionTBTField) {
         var cntAmt = 0;
       // let paymentStatus =  helper.getPaymentStatus(component, event, helper,obj);
        if(obj.ElixirSuite__Total_Contracted_Amount__c != undefined && obj.ElixirSuite__Total_Contracted_Amount__c != null){
                 cntAmt = obj.ElixirSuite__Total_Contracted_Amount__c;
                }
        let sObj = {'Id' : obj.Id,'patientName' : obj.patientName, 'ClaimNumber' : obj.ClaimNumber, 'payerClaimHash' : '',
                    'isClaimPosted' : obj.isClaimPosted,
                    'eraStatusCodePickLstVal' : arr,
                    'actionToBeTakenPickLstVal' : actionToBeTakenArr ,
                    'actionToBeTakenVal' : defaultValueForActionTBTField,
                    'patientId' : obj.patientId, 'claimId' : obj.claimId, 'eraStatusCode' : '',
                    'totalBilledAmount' : obj.ElixirSuite__Total_Charge__c, 
                    'totalContractedAmt' : cntAmt,
                    'totalAllowedAmt' : obj.ElixirSuite__Total_Charge__c,
                    'totalAdjustmentAmt' : 0,
                    'paidAmt' : obj.ElixirSuite__Total_Charge__c,
                    'netPaidAmount': obj.ElixirSuite__Total_Charge__c,
                    'paymentStatus' : 'N/A',
                    'ver_1_toalPatientResp' : 0 , 
                    'ver_1_totalOtherInsResp' : 0 , 
                    'openLineItemWindow' : false,
                    'eraId':'',
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
    arrangeRasonMDTValues : function(component, event, helper,reasonCodeMap) {       
        let reasonLst = [];
        for (var key in reasonCodeMap) {            
            reasonLst.push({value:key, label:reasonCodeMap[key]});
        }
        component.set("v.reasonList",reasonLst);
        console.log('reasonList'+JSON.stringify(component.get("v.reasonList")));
    },
    setJSONKeysForLineItem : function(component, event, helper,obj) {
        var procCode = 'N/A';
        var procName = '';
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
        
        //Added By Neha
        let suppRemarkCode = obj.ElixirSuite__Adjustment_Remark_Codes__c;
        console.log('====suppRemarkCode====',suppRemarkCode);
        if(String(suppRemarkCode)!='undefined'){
            var suppRemarkCodes = String(suppRemarkCode).split(";");
            console.log('====suppRemarkCode====',suppRemarkCodeList);
            var suppRemarkCodeList = [];
            for(let i in suppRemarkCodes){
                const codeobj = {Id:suppRemarkCodes[i],Name:suppRemarkCodes[i]};
                suppRemarkCodeList.push(codeobj);
            }
            component.set("v.selectedInfoRemarkCodes",suppRemarkCodeList);
            
            console.log('====suppRemarkCode====',suppRemarkCodeList);
        }
        //
        //
        return {'claimLineItemId':obj.Id,
                'procCode' : procName,
                'procCodeNameAndDescription':procCodeNameAndDescription, //Added by Anusha - LX3-5744
                'procCodeERAprocLineItem' : procName,
                'billedAmt' : lineItemTotalCharge, 
                'conctAmt' : obj.ElixirSuite__Contracted_Amount__c,
                'paidAmt' : lineItemTotalCharge,
                'allowedAmt' : lineItemTotalCharge,
                'adjustMentAmt' : 0,
                'providerAdj' : 0,
                'patientResp' : 0,
                'otherInsuranceResposibility' : 0,
                'paymentStatus' :'N/A' ,
                'selectedInfoRemarkCodes':component.get("v.selectedInfoRemarkCodes"), //Added by Neha 
                'infoRemarkCodes' : component.get("v.infoRemarkCodesPicklistVal") ,//Added by Neha 
                'adjustmentCodeTable' : helper.adjustmentCodeTableArray(component,(lineItemTotalCharge - obj.ElixirSuite__Contracted_Amount__c))};
    },
    adjustmentCodeTableArray :     function(component,adjAmt) {
        return [{'adjCdTbl_adjustmentAmount' : 0 ,
                 'adjCdTbl_adjustmentCodeReason' : 'X45' ,
                 'adjCdTbl_adjustmentGroupCode' : 'CO',
                 'reasonList' : JSON.parse(JSON.stringify(component.get("v.reasonList"))) ,
                 'suppRemarkCode':'',   //Added by Neha 
                 'suppRemarkCodeList':component.get("v.suppRemarkCodesPicklistVal"),  //Added by Neha 
                 'adjustmentGrpCodeLst' : JSON.parse(JSON.stringify(component.get("v.arrGrpCode"))) }];
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
    fetchPicklistValueIfAny :  function(component) { 
        var action = component.get("c.fetchPicklistValuesForObjectMdt");
        component.set("v.loaded",false);
        action.setParams({
            lstOfFields : ['ElixirSuite__Payment_Method__c']
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
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
                    
                    component.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    var arr = [];
                    console.log('add era 374***');
                    let defvalue = component.get("v.defPaymentMethod");
                    if(!$A.util.isEmpty(defvalue)){
                        
                        let sObj = {'label' : defvalue, 'value' : defvalue};
                        arr.push(sObj);
                        
                    }else{
                        var noneVal ={ 'value': "", 'label': "NONE" };
                        arr.push(noneVal); 
                    }
                    
                    for(let obj in result.mapOfClaimPaymentMethod){
                        if(defvalue!=obj){
                        let sObj = {'label' : obj, 'value' : result.mapOfClaimPaymentMethod[obj]};
                        arr.push(sObj);
                        }
                    }               
                    component.set("v.paymentMethodLst",arr);
                    component.set("v.EOBRecToSave.ElixirSuite__Payment_Method__c",component.get("v.defPaymentMethod")); 
                    let arrGrpCode = [];
                    for(let obj in result.mapOfAdjustmentgroupCode){
                        let instanceVar = {'label' : result.mapOfAdjustmentgroupCode[obj], 'value' : obj}; 
                        arrGrpCode.push(instanceVar);
                    }               
                    component.set("v.arrGrpCode",arrGrpCode);
                    
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
            "title": "Please select Insurance Payer to search!",
            "message":  "Please search Insurance Payer!",
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
    saveERAData : function(component, event, helper,isSaveAndNew,isPosted) { 
        if(helper.checkValidity_eraStatCode(component, event, helper) == false){
            if(helper.checkValidity_netPaidAmt(component, event, helper)  == false){
                console.log("childERAtableList  " +JSON.stringify({'childERAtableList' : component.get("v.childERAtableList")}));
                var action = component.get("c.saveERAEOB");
                component.set("v.loaded",false);
                action.setParams({
                    eobParentRecord :  component.get("v.EOBRecToSave"),
                    stringifiedTablLst :  JSON.stringify({'childERAtableList' : component.get("v.childERAtableList")}),
                    isInsert : true,
                    isPosted : isPosted,
                    notes : JSON.stringify(component.get("v.noteList")),
                    
                    recommendation : JSON.stringify(component.get("v.recommendationList"))
                    
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        try{ 
                            
                            component.set("v.ERAid",response.getReturnValue()[0]);
                            console.log(JSON.stringify(component.get("v.childERAtableList")));
                            component.set("v.loaded",true); 
                            helper.globalFlagToast(component, event, helper,'RECORD SAVED!', ' ','success');
                            console.log('11111');
                            
                            //component.find("recommendationComp").saveRecommends();
                            //component.find("notesComp").saveNotes();
                            //console.log('2222');
                            var cmpEvent = component.getEvent("ElixirOEM_BillingERARefresh");
                            cmpEvent.fire();
                            console.log('3333');
                            component.set("v.isOpen",false);
                            console.log('44444');
                            if(isSaveAndNew){
                                component.set("v.isOpen",true);  
                            }
                        }
                        catch(e){
                            console.log(e);
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
        }
        
    },
    fetchLineItemPerClaim : function(component, event, helper,claimId,indexArr) {
        component.set("v.loaded",false);       
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
                        allClaimResultTable.forEach( function(element) {
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
                  //  var toastEvent = $A.get("e.force:showToast");
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
                      //  var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please Complete Follow up Notes on row Number "+(i+1),
                            "type" : "error"
                        });
                        toastEvent.fire(); 
                        return false;
                    }
                    else if(noteList[i].ElixirSuite__Elixir_Follow_up_Date__c <= todayDate){
                      //  var toastEvent = $A.get("e.force:showToast");
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
                           // var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please fill the recommendation for all the rows in the recommendation table for " +rList[i].ElixirSuite__Elixir_ERA__r.ElixirSuite__Claim__r.Name,
                                "type" : "error"
                            });
                            toastEvent.fire(); 
                            return false;   
                        }
                       // var toastEvent = $A.get("e.force:showToast");
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
    validatePostedClaims: function(component) {
        var flag = false;
        let lst = component.get("v.childERAtableList");
        var arrLst = [];
        lst.forEach(function(element) {
                if(element.isClaimPosted){
                    flag = true;
                    arrLst.push(element.ClaimNumber);  
                }
        });
        component.set("v.postedClaimFlagLst",arrLst);
        return flag;
    },
})