({
    init : function(cmp, event, helper) {
        cmp.set("v.makePaymentButtonDisable",true);
        helper.doInitHelper(cmp, event, helper);
        helper.setDefaultJSON(cmp, event, helper);
        helper.initPayloadCall(cmp, event, helper);
        cmp.set('v.discountType','');
        cmp.set("v.loaded",false); 
        cmp.set("v.loaded",true);
        cmp.set('v.DiscountTableColumns',[
            {label: 'Discount Number', fieldName: 'Name', type: 'Auto Number',sortable :true}
        ]); 
        
         var cmpEvent1 = $A.get("e.c:PaymentEvent");
            cmpEvent1.setParams({
            "firstLabel" :  'Total applied discount',
            "secondLabel":'Total unallocated discount',
                "firstValue":0,
                "secondValue":cmp.get("v.totalUnAllocatedDiscount")
            });
            cmpEvent1.fire();
        
    },
    
                 totalAppliedAmountChange : function(cmp, event) {
        console.log("totalAppliedAmountChange has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
                
                var cmpEvent1 = $A.get("e.c:PaymentEvent");
            cmpEvent1.setParams({
            "firstLabel" :  'Total applied discount',
            "secondLabel":'Total unallocated discount',
                "firstValue":event.getParam("value"),
                "secondValue":cmp.get("v.totalUnAllocatedDiscount")
                });
            cmpEvent1.fire();
                
    },    
                
                        totalUnAllocatedAmountChange : function(cmp, event) {
        console.log("totalUnAllocatedAmountChange has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
                
                var cmpEvent1 = $A.get("e.c:PaymentEvent");
            cmpEvent1.setParams({
            "firstLabel" :  'Total applied discount',
            "secondLabel":'Total unallocated discount',
                "firstValue":cmp.get("v.totalAppliedDiscount"),
                "secondValue":event.getParam("value")
                });
            cmpEvent1.fire();
                
    },
    
    handleTablerowChange: function(cmp, event, helper) {
        console.log('Hiiii')
        if(!cmp.get('v.tempVar')){
            console.log('Hiiii 1')
            cmp.set("v.selectedRows",[]);
            console.log('Hiiii 2')
            let columns =   cmp.get("v.columns");
            console.log('Hiiii 3')
            let discountType = event.getParam('selectedRows')[0].ReasonOfPayment;
            console.log('Hiiii 444')
             cmp.set("v.DiscountTableId",event.getParam('selectedRows')[0].Id);
            console.log('discountType'+discountType);
            cmp.set('v.masterTransactionObj.ElixirSuite__Complete_discount_to_be_utilized__c',false);
            cmp.set('v.discountType',discountType);
            cmp.set('v.renderCheckbox',true);
            if(discountType == 'Discount Amount'){
                 cmp.set("v.loaded",true); 
                cmp.set('v.hideCheckbox',true);
                helper.loadProceduresOnDiscTypeChange(cmp, event, helper);
                columns.forEach(function(element) {  
                    if(element.fieldName == 'currentDiscAmt'){
                        element.editable = true;
                    }
                }); 
            }
            else{
                cmp.set("v.hideCheckbox",false);
                cmp.set("v.loaded",true); 
                cmp.set('v.renderCheckbox',false);
                helper.loadProceduresOnDiscTypeChange(cmp, event, helper);
                columns.forEach(function(element) {  
                    if(element.fieldName == 'currentDiscAmt'){
                        element.editable = false;
                    }
                }); 
            }
            cmp.set("v.columns",columns);
            
            console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows'))); 
            console.log('seleceted rows id'+ event.getParam('selectedRows')[0].Id);
            console.log('unallocated amount rows'+event.getParam('selectedRows')[0].ElixirSuite__Total_Unallocated_Amount__c);
            
           
            let discountTableDiscountPercentage = event.getParam('selectedRows')[0].ElixirSuite__Discount_Amount__c;
            
            cmp.set("v.discountTableDiscountPercentage",parseFloat(discountTableDiscountPercentage));
            let discountTableUnAllocatedAmount = event.getParam('selectedRows')[0].ElixirSuite__Total_Unallocated_Amount__c;
            
            cmp.set("v.discountTableUnAllocatedAmount",parseFloat(discountTableUnAllocatedAmount));
            cmp.set("v.totalUnAllocatedDiscount",parseFloat(discountTableUnAllocatedAmount));
            cmp.set("v.totalAppliedDiscount",0);
            cmp.set("v.selectedProcedureRecords",[]);
            cmp.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
            
            if(discountType=='Discount Percentage' && $A.util.isUndefinedOrNull(discountTableUnAllocatedAmount)){
                cmp.set("v.showUnallocateField",false);
            }else{
                // cmp.set("v.maxRowSelectionProcedures",'');
                cmp.set("v.showUnallocateField",true);
            }
        }
        else{
            console.log('Hiiii 777')
            cmp.set('v.tempVar', false);
        }
        console.log('Hiiii 8888')
        helper.addButtonEnableHandler(cmp, event, helper);
    
    },
    
    onTypeOfDiscountChange : function(cmp, event, helper) {
        cmp.set("v.selectedRows",[]); 
        helper.initPayloadCall(cmp, event, helper);
    },
    validateAmtAllocated :function(cmp, event, helper) {
        let val =  event.getSource().get("v.value");
        if(val){
            let amountPaid = val;
            let totalAppliedDiscount =   cmp.get("v.totalAppliedDiscount"); 
            if(!$A.util.isUndefinedOrNull(amountPaid)){
                cmp.set("v.totalUnAllocatedDiscount",(parseFloat(amountPaid) - parseFloat(totalAppliedDiscount)));   
            }
            if(val>cmp.get("v.totalUnAllocatedDiscount_SumCount")){
                helper.globalFlagToast(cmp, event, helper,'INVALID AMOUNT ALLOCATED!', 'Amount Allocated cannot be greater than Total Unallocated Amount!','error');  
                cmp.set("v.makePaymentButtonDisable",true); 
            }
            else {
                cmp.set("v.makePaymentButtonDisable",false);  
            } 
        }
        else {
            // cmp.set("v.totalUnAllocatedDiscount",0.0);  
        }
        
    },
    selectedRowsOnClick : function(component, event, helper) {
        try{
              let discountCheckbox =component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c");    
            let remainingAmount = 0;
            var selectedRows =  event.getParam('selectedRows');
            console.log('selectedRows'+selectedRows);  
         
      //  let maxDiscAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
            //alert('selectedRows'+selectedRows);
            component.set("v.selectedProcedureRecords",event.getParam('selectedRows'));
            let selectedProcedureRecordsNetInstance = component.get("v.selectedProcedureRecordsNetInstance"); 
            console.log('SHIVAselectedProcedureRecordsNetInstance'+selectedProcedureRecordsNetInstance);
            if($A.util.isEmpty(event.getParam('selectedRows'))){
                component.set("v.selectedProcedureRecordsNetInstance",[]); 
                 
            }
            else {
                selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(event.getParam('selectedRows'));
                component.set("v.selectedProcedureRecordsNetInstance",selectedProcedureRecordsNetInstance); 
            }       
            for (var i = 0; i < selectedRows.length; i++) {
               
                if(!$A.util.isUndefinedOrNull(selectedRows[i].currentDiscAmt)){
                    remainingAmount+=parseFloat(selectedRows[i].currentDiscAmt); 
                }           
            }
            let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
            component.set("v.totalAppliedDiscount",remainingAmount);
           component.set("v.totalUnAllocatedDiscount",discAmt-  JSON.parse(JSON.stringify(remainingAmount)));
            if(component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c")){
               
                helper.reEvaluateLogicOnDeselctingProcedure(component, event, helper,selectedRows);  
            }
            if(component.get("v.discountType") == 'Discount Amount'){
               
                helper.checkSanity(component, event, helper,selectedRows);
            }
            if(component.get("v.discountType") == 'Discount Amount' && discountCheckbox == true){
                console.log('shivasai');
                helper.reCalDisAmtOnSelectedRowChange(component, event, helper);         
            }
            if(component.get("v.discountType") == 'Discount Percentage'){
                
                  if($A.util.isUndefinedOrNull(discAmt)){
                helper.organizePercentageLogic(component, event, helper,selectedRows);
                      
                  }else{
                     
               helper.organizePercentageLogicWithUnallocateAmount(component, event, helper,selectedRows); 
             }
            }
            else {
              
               // helper.handleEnableInlineEditing(component, event, helper,false);
            }
           helper.addButtonEnableHandler(component,event, helper);
            
        }
        catch(e){
           // alert(e);
        }
    },
    runMaxDiscountValidation : function(component, event, helper) {
         try{
             component.set("v.selectedRows",[]); 
            // alert(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"));
             helper.deAllocateDiscounts(component, event, helper,component.get("v.selectedProcedureRecords"));
         }
         catch(e){
            alert(e);
        }
    },
    calculateAllocations : function(component, event, helper) {
        
        try{
            // if(helper.validateDiscountPaid(component, event, helper)){
                if(component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c")){
                    component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false); 
                    helper.globalFlagToast(component, event, helper,'DIVIDE CHECBOX RESET! PLEASE CHECK AGAIN TO DIVIDE THE AMOUNT EQUALLY.', ' ','info'); 
                }  
                
              //  <!--V--> let amountPaid =   component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c");
              let amountPaid =   component.get("v.discountTableUnAllocatedAmount");
                if(amountPaid){
                    let remainingAmount =   component.get("v.totalAppliedDiscount");
                    if(!$A.util.isUndefinedOrNull(amountPaid)){
                        component.set("v.totalUnAllocatedDiscount",(parseFloat(amountPaid) - parseFloat(remainingAmount)));  
                    }
                }
                else {
                    component.set("v.totalUnAllocatedDiscount",0.0);  
                }  
                component.set("v.remainingDiscount",component.get("v.discountTableUnAllocatedAmount")); 
        }
        catch(e){
            alert(e);
        }
    },
    blurLogic  :  function(component, event, helper){ 
        if(component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c")){
            component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false); 
            helper.globalFlagToast(component, event, helper,'DIVIDE CHECBOX RESET! PLEASE CHECK AGAIN TO DIVIDE THE AMOUNT EQUALLY.', ' ','info'); 
        }        
    },
    
    onDOSFromChange :  function(cmp, event, helper){
        try{
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            let dosFrom =  new Date(procedureSearchParams.DOSFrom);
            let dosTo =  new Date(procedureSearchParams.DOSTo);
            if(dosTo){
                if(dosFrom>dosTo){
                    helper.globalFlagToast(cmp, event, helper,'DOS From cannot be higher than DOS To!', ' ','error');
                    cmp.set("v.isSearchDisabled",true);
                }
                else {
                    cmp.set("v.isSearchDisabled",false); 
                }   
            }
        }
        catch(e){
            alert(e); 
        }
    },
    onDOSToChange : function(cmp, event, helper){
        try{
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            let dosFrom =  new Date(procedureSearchParams.DOSFrom);
            let dosTo =  new Date(procedureSearchParams.DOSTo);
            if(dosFrom){
                if(dosFrom>dosTo){
                    helper.globalFlagToast(cmp, event, helper,'DOS From cannot be higher than DOS To!', ' ','error');
                    cmp.set("v.isSearchDisabled",true);
                }
                else {
                    cmp.set("v.isSearchDisabled",false);
                }   
            }   
        }
        catch(e){
            alert(e); 
        }
        
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
    searchClaim :  function(cmp,event,helper){ 
        try{
                    cmp.set("v.loaded",true); 

            var procedureSearchParams = cmp.get("v.procedureSearchParams");
            if(procedureSearchParams.DOSFrom || procedureSearchParams.DOSTo || procedureSearchParams.procedureName 
               || procedureSearchParams.CPTCode){
                
                var dosFrom =  JSON.parse(JSON.stringify(procedureSearchParams.DOSFrom));
                var dosTo =  JSON.parse(JSON.stringify(procedureSearchParams.DOSTo));
                if(dosFrom == '' && dosTo!=''){
                    dosFrom = dosTo;
                    cmp.set("v.procedureSearchParams.DOSFrom",dosTo);
                }
                else if(dosTo=='' && dosFrom!=''){
                   // var today = new Date();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(dosFrom>today){
                        dosTo = dosFrom;
                         cmp.set("v.procedureSearchParams.DOSTo",dosFrom);
                    }
                    else {
                        dosTo = today; 
                        cmp.set("v.procedureSearchParams.DOSTo",today);
                    }            
                }
                
                //commented by sagili siva not to iterate over the same procedure multiple items as mentioned in LX3-5838
              
                /*var selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecordsNetInstance");
                var eisitngIdArr = [];
                selectedProcedureRecordsNetInstance.forEach(function(element, index) {
                    eisitngIdArr.push(element.Id);
                });*/
                
                //Added by sagili siva as per the requirement in LX3-5838
                
                var selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecords");
                console.log('selectedProcedureRecordsNetInstance'+selectedProcedureRecordsNetInstance);
               var selectedProcedureRecordsNetInstance1 =  helper.filterDuplicates(cmp, event, helper,selectedProcedureRecordsNetInstance);
               // cmp.set("v.selectedProcedureRecords",selectedProcedureRecordsNetInstance1);
                console.log('selectedProcedureRecordsNetInstance'+selectedProcedureRecordsNetInstance1);
                var eisitngIdArr = [];
                selectedProcedureRecordsNetInstance1.forEach(function(element) {
                    eisitngIdArr.push(element.Id);
                    console.log('eisitngIdArr'+eisitngIdArr);
                });
                
                var action = cmp.get("c.filterProcedureOnMasterTransaction");
                cmp.set("v.loaded",true); 
                if(dosTo && dosTo){
                    action.setParams({dosFrom : dosFrom,
                                      dosTo : dosTo,
                                      procedureName : procedureSearchParams.procedureName,
                                      CPTCode : procedureSearchParams.CPTCode,
                                      acctId : cmp.get("v.PatientId"),
                                      eisitngIdArr : eisitngIdArr 
                                     });     
                }
                else{
                    action.setParams({
                        procedureName : procedureSearchParams.procedureName,
                        CPTCode : procedureSearchParams.CPTCode,
                        acctId : cmp.get("v.PatientId"),
                        eisitngIdArr : eisitngIdArr 
                    }); 
                }
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        cmp.set("v.loaded",false);
                        
                        var result = response.getReturnValue();
                        console.log('search result ' + JSON.stringify(result));
                        let allProcedureOnMT = result.allProcedureOnMT;
                        if(!$A.util.isEmpty(allProcedureOnMT)){
                            let count = 1;
                            allProcedureOnMT.forEach(function(element) {
                                element['SNo'] = count;
                                if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                    element['procedureName'] = element.ElixirSuite__Procedure__r.Name; 
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                     element['currentDiscAmt'] = 0.0;
                                }
                                helper.setRemainingAmount(cmp, event, helper,element);
                                count++;
                            }); 
                            helper.sortSelectedProcedures(cmp,'ElixirSuite__Date_Of_Service__c','desc',selectedProcedureRecordsNetInstance);
                            selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(allProcedureOnMT);
                            cmp.set("v.Plist",selectedProcedureRecordsNetInstance);
                        }
                        else {
                              cmp.set("v.loaded",false); 
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different filter!','error');
                        }
                      helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                        
                    }
                    
                });
                $A.enqueueAction(action);  
            }
            else {
                cmp.set("v.loaded",false); 
                helper.globalFlagToast(cmp, event, helper,'NO FILTER APPLIED!', 'Please apply filter to search!','error');
            }
        }
        catch(e){
            alert(e);
        }
        
    },
    clearClaimSearchFilter :  function(cmp,event,helper){ 
        var procedureSearchParams = cmp.get("v.procedureSearchParams");     
        //helper.setDefaultJSON(cmp, event, helper);
        cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',
            'procedureId' : '','CPTCode' : ''});
        // helper.initPayloadCall(cmp, event, helper);
        helper.keepSelectedProcedures(cmp, event, helper);
        cmp.set("v.isSearchDisabled",false); // Added by sagili siva :Lx3-5827
         
    },
    allocateDiscountFromUI :  function(cmp,event,helper){ 
        try{
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords")
            if($A.util.isEmpty(selectedProcedureRecords)){
                helper.globalFlagToast(cmp, event, helper,'Please select procedures!', ' ','error');  
                cmp.set("v.loaded",false);
            }else{
                if(helper.checkRequieredValidity(cmp,event,helper)){
                 cmp.set("v.loaded",true);
                helper.savePayments(cmp,event,helper);
                cmp.set('v.tempVar', true);
                /*    
                var act = cmp.get("c.customDiscountTable");
                act.setParams({acctId:cmp.get("v.PatientId")
                              });
                act.setCallback(this, function(response){
                    var state = response.getState();
                    if(state == "SUCCESS"){
                        var result = response.getReturnValue();
                        for(var i=0; i<result.customSettingDiscountTable.length; i++){
                            console.log("==result.totalUnAllocatedDiscount==="+result.customSettingDiscountTable[i]);
                        }
                        cmp.set('v.DiscountTableData', result.customSettingDiscountTable);
                    }
                });
                $A.enqueueAction(act);
                 */   
               //helper.doInitHelper(cmp, event, helper);
               //helper.setDefaultJSON(cmp, event, helper);
               //helper.initPayloadCall(cmp, event, helper);
               //cmp.set('v.discountType','');
               //cmp.set("v.loaded",false); 
           // cmp.set("v.loaded",true);
           /* cmp.set('v.DiscountTableColumns',[
                {label: 'Discount Number', fieldName: 'Name', type: 'Auto Number',sortable :true}
            ]); */
            }
          /* helper.doInitHelper(cmp, event, helper);
            helper.setDefaultJSON(cmp, event, helper);
            helper.initPayloadCall(cmp, event, helper);
            cmp.set('v.discountType','');
            cmp.set("v.loaded",false); 
           // cmp.set("v.loaded",true);
            cmp.set('v.DiscountTableColumns',[
                {label: 'Discount Number', fieldName: 'Name', type: 'Auto Number',sortable :true}
            ]); */
            } 
        }
        catch(e){
            alert(e);
        }
        
    },
    handleConfirmDialogYes :  function(cmp,event,helper){ 
        helper.savePayments(cmp,event,helper);
    },
    handleConfirmDialogNo :  function(cmp){ 
        cmp.set("v.showConfirmDialog",false);    
    },
    divideAmountEqually :  function(component, event, helper) {
        try{
            let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
            console.log(discAmt);
            let Plist =  component.get("v.Plist");
            var checked = event.getSource().get("v.checked"); 
            if(checked){
                if(discAmt){
                    let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
                    let dscToAllocate = discAmt / selectedProcedureRecords.length;
                    if($A.util.isEmpty(selectedProcedureRecords)){
                        helper.globalFlagToast(component, event, helper,'PLEASE SELECT PROCEDURE(S)!', ' ','error');   
                        component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
                    }
                    else {
                        helper.handleEnableInlineEditing(component, event, helper,checked);  
                        selectedProcedureRecords.forEach(function(element) {  
                            if(dscToAllocate > element.remainingAmount){ // 300> 200
                                element.currentDiscAmt = element.remainingAmount;         
                            }
                            else {
                                element.currentDiscAmt = dscToAllocate;      // 200 300
                            }
                            let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                            if(arrIndex>=0){
                                if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                                    Plist[arrIndex].currentDiscAmt = Plist[arrIndex].remainingAmount;
                                }
                                else {
                                    Plist[arrIndex].currentDiscAmt = dscToAllocate
                                }
                            }
                            
                        });                         
                        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
                        component.set("v.Plist",Plist);
                        helper.caculateDiscountVariations(component, event, helper);
                        helper.checkSanity(component, event, helper,selectedProcedureRecords);
                    }                
                }
                else {
                    helper.globalFlagToast(component, event, helper,'PLEASE FILL DISCOUNT AMOUNT!', ' ','error');  
                    component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
                }  
            }
            else {
                helper.handleEnableInlineEditing(component, event, helper,checked);  
                helper.resetCurrentDscAmt(component, event, helper); 
            }
            
        }
        catch(e){
            alert(e);
          //  alert(e.line);
  //alert(e.stack);
        }
        
    },
    handleSaveDataTable :  function(component, event, helper) {
        // component.set("v.masterTransactionObj.ElixirSuite__Complete_discount_to_be_utilized__c",false);
        let Plist =  component.get("v.Plist");
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        let draftValues = event.getParam('draftValues');
        let checkNegative = false;
        let checkRemAmount = false;//AK
        let totalCurrentDiscAmt = 0;
        let unselectedPro = '';
        let idArr = [];
        selectedProcedureRecords.forEach(function(element) {  
            idArr.push(element.Id);
        });
        
      
        draftValues.forEach(function(element) { 
            let arrIndex_PList = Plist.findIndex(obj_pLst => obj_pLst.Id == element.Id);
            if(element.currentDiscAmt != null){
                if(parseFloat(element.currentDiscAmt) < 0){
                    checkNegative = true;
                }
                if(element.currentDiscAmt == ''){
                 element.currentDiscAmt = 0.0;   
                }
                if(parseFloat(element.currentDiscAmt)>parseFloat(Plist[arrIndex_PList].remainingAmount)){
                   checkRemAmount = true; 
                }
                if(arrIndex_PList>=0){
                    if(!idArr.includes( Plist[arrIndex_PList].Id)){
                        if(parseInt(element.currentDiscAmt) != 0){ 
                            console.log('element.currentDiscAmt '+element.currentDiscAmt)
                         unselectedPro = Plist[arrIndex_PList].procedureName;
                        }
                    }
                }
            }
            
        });
        
        Plist.forEach(function(element) {
            let arrIndex_dList = draftValues.findIndex(obj_dLst => obj_dLst.Id == element.Id);
           
                
                if(arrIndex_dList>=0){
                    if(idArr.includes( draftValues[arrIndex_dList].Id)){
                    totalCurrentDiscAmt+=parseFloat(draftValues[arrIndex_dList].currentDiscAmt);    
                    }
                }else if(element.currentDiscAmt != null){
                       totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt); 
                }
                
                
                       
        }); 
        
         console.log('totalCurrentDiscAmtSavedatatable'+totalCurrentDiscAmt);
        if(checkRemAmount){
            helper.globalFlagToast(component, event, helper,'Current discount Amount is greater than Remaining Amount', ' ','error'); 
            component.set("v.makePaymentButtonDisable",true); //17-03-2023 
            component.set("v.cancelSave",true); 
            return;
        }
        if(unselectedPro != ''){
            helper.globalFlagToast(component, event, helper,'Cannot update current discount of unselected '+ unselectedPro +' procedure', ' ','error');
            component.set("v.makePaymentButtonDisable",true); //17-03-2023
            component.set("v.cancelSave",true);  
            return;
        }
        if(checkNegative){
            helper.globalFlagToast(component, event, helper,'Cannot have a negative value ', ' ','error'); 
            component.set("v.makePaymentButtonDisable",true); //17-03-2023 
            component.set("v.cancelSave",true);  
            return;
        }
        
        if(totalCurrentDiscAmt > discAmt){
          helper.globalFlagToast(component, event, helper,'Cannot allocate more than Unallocated Discount Amount!', ' ','error');   
          component.set("v.makePaymentButtonDisable",true); //17-03-2023 
          component.set("v.cancelSave",true);  
          return;  
        }
        
        console.log('draftValues SAVE '+JSON.stringify(draftValues));
        draftValues.forEach(function(element) {  
            let arrIndex_PList = Plist.findIndex(obj_pLst => obj_pLst.Id == element.Id);
            if(arrIndex_PList>=0){
                Plist[arrIndex_PList].currentDiscAmt = element.currentDiscAmt;
                 Plist[arrIndex_PList].ElixirSuite__Other_Discounts__c = element.currentDiscAmt;
            }
            let arrIndex_SelectedProc = selectedProcedureRecords.findIndex(obj_selectProc => obj_selectProc.Id == element.Id);
            if(arrIndex_SelectedProc>=0){ 
                selectedProcedureRecords[arrIndex_SelectedProc].currentDiscAmt = element.currentDiscAmt;  
             selectedProcedureRecords[arrIndex_SelectedProc].ElixirSuite__Other_Discounts__c = element.currentDiscAmt;  

            }           
        }); 
        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
        component.set("v.Plist",Plist);
        component.set("v.draftValues",[]); 
        helper.caculateDiscountVariations(component, event, helper);
        component.set("v.cancelSave",false);
        helper.addButtonEnableHandler(component, event, helper);
        
        //   component.set("v.hideCBCols",false);
    },
    handleCancelDataTable :  function(component, event, helper) {
     console.log("eeeeeeeeeeeeeeeeeeeeeeeeeeee");  
        component.set("v.cancelSave",false);  
        helper.addButtonEnableHandler(component, event, helper); //17-02-2023
    },
    handleCellBlur :  function(component, event, helper) {
         console.log('sachin');
        try{
            let Plist =  component.get("v.Plist");
            let draftValues = event.getParam('draftValues');
            console.log('draftValues '+JSON.stringify(draftValues));
            draftValues.forEach(function(element) {  
                if(element.currentDiscAmt){
                    if(parseFloat(element.currentDiscAmt)<0){
                        helper.globalFlagToast(component, event, helper,'Cannot have a negative value ', ' ','error'); 
                        component.set("v.makePaymentButtonDisable",true);
                    }  
                    else{
                        //component.set("v.makePaymentButtonDisable",false);
                        let arrIndex_PList = Plist.findIndex(obj_pLst => obj_pLst.Id == element.Id);
                        if(arrIndex_PList>=0){
                            if(parseFloat(element.currentDiscAmt)>parseFloat(Plist[arrIndex_PList].remainingAmount)){
                                helper.globalFlagToast(component, event, helper,'Current discount Amount is greater than Remaining Amount for '+Plist[arrIndex_PList].procedureName, ' ','error'); 
                                component.set("v.makePaymentButtonDisable",true);
                            }
                            else {
                                //component.set("v.makePaymentButtonDisable",false);
                            }
                        }  
                    }
                    
                }
               
                

            }); 
            
            helper.addButtonEnableHandler(component, event, helper);
        }
        catch(e){
            alert(e);
            alert(e.getLineNumber());
        }
        
    },
    utilizeCompleteDiscount : function(component, event, helper) {
        var checked = event.getSource().get("v.checked");                        
       let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
        if(checked){
            if($A.util.isEmpty(selectedProcedureRecords)){
                        helper.globalFlagToast(component, event, helper,'PLEASE SELECT PROCEDURE(S)!', ' ','error');   
                        component.set("v.masterTransactionObj.ElixirSuite__Complete_discount_to_be_utilized__c",false);
            }else{
            component.set("v.totalUnAllocatedDiscount" , 0.0);
            }
        }else{
            helper.caculateDiscountVariations(component, event, helper);   
        }
    },
    validatePercentage : function(cmp, event, helper) {
        let val =  event.getSource().get("v.value");
        if(val>100){
            helper.globalFlagToast(cmp, event, helper,'DISCOUNT PERCENTAGE CANNOT BE GREATER THAN 100!', 'Paease enter percentage less than 100.','error');  
            cmp.set("v.makePaymentButtonDisable",true); 
        }
        else {
            cmp.set("v.makePaymentButtonDisable",false);  
        } 
    },
    handleRowAction: function(component, event, helper){
        var action = event.getParam('action');
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
    }
})