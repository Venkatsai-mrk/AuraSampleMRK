({
    init : function(cmp, event, helper) {
        cmp.set("v.loaded",false); 
        cmp.set("v.loaded",true);
        cmp.set("v.makePaymentButtonDisable",true);
        
        var cmpEvent1 = $A.get("e.c:PaymentEvent");
            cmpEvent1.setParams({
            "firstLabel" :  'Total applied discount',
            "secondLabel":'Total unallocated discount',
                "firstValue":0,
                "secondValue":0
            });
            cmpEvent1.fire();
        
        helper.setDefaultJSON(cmp, event, helper);
        helper.initPayloadCall(cmp, event, helper);
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
    
    onTypeOfDiscountChange : function(cmp, event, helper) {
        cmp.set("v.selectedRows",[]);
        cmp.set("v.totalUnAllocatedDiscount",0.0);//Ak
        cmp.set("v.totalAppliedDiscount",0.0);//AK
        cmp.set("v.selectedList",[]);//AK
        cmp.set("v.selectedProcedureRecords",[]);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Discount_Amount__c",0);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c",0);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c",0);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Discount_Code__c",'');//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Complete_discount_to_be_utilized__c",false);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);//AK
        cmp.set("v.masterTransactionObj.ElixirSuite__Notes__c",'');//AK
        cmp.set("v.procedureSearchParams",'');//AK
        helper.initPayloadCall(cmp, event, helper);
    },
    /*
    validateAmtAllocated :function(cmp, event, helper) {
        let val =  event.getSource().get("v.value");
        if(val){
            let amountPaid = val;
            let totalAppliedDiscount =   cmp.get("v.totalAppliedDiscount"); 
            if(!$A.util.isUndefinedOrNull(amountPaid)){
                cmp.set("v.totalUnAllocatedDiscount",(parseFloat(amountPaid) - parseFloat(totalAppliedDiscount)));   
            }
            if(val>cmp.get("v.totalUnAllocatedDiscount_SumCount")){
                helper.globalFlagToast(cmp, event, helper,'Invalid amount allocated!', 'Amount Allocated cannot be greater than Total Unallocated Amount!','error');  
                cmp.set("v.makePaymentButtonDisable",true); 
            }
            else {
                cmp.set("v.makePaymentButtonDisable",false);  
            } 
        }
        else {
            //cmp.set("v.totalUnAllocatedDiscount",0.0);  
        }
        
    },*/
    selectedRowsOnClick : function(component, event, helper) {
        try{
             console.log('seleceted rows--AKki'+ JSON.stringify(event.getParam('selectedRows'))); 
             //console.log('meg' , component.find('ak').getSelectedRows());
             console.log('--------End--------');
            
           
            var selectedList = component.get("v.selectedList");
            console.log('selectedList--AKki'+ JSON.stringify(event.getParam('selectedList'))); 
            let remainingAmount = 0;
            var selectedRows =  event.getParam('selectedRows');
            
            console.log('-SL Size-'+selectedList.length+'-SR Size-'+selectedRows.length);
            if($A.util.isEmpty(selectedList)){
                component.set("v.selectedList",selectedRows);
            }else if(!$A.util.isEmpty(selectedList) && selectedList.length < selectedRows.length){
                selectedRows.forEach(function(element) {
                    var flag = 0;
                    selectedList.forEach(function(element_SList) { 
                        if(element.Id==element_SList.Id){
                           flag++; 
                        }
                    })
                    if(flag == 0){
                        selectedList.push(element);
                    }
                    
                }); 
                
                }
            if(!$A.util.isEmpty(selectedList) && selectedList.length > selectedRows.length){
             selectedList.forEach(function(element, index) {
                    var flag = 0;
                    selectedRows.forEach(function(element_SList) { 
                        if(element.Id==element_SList.Id){
                           flag++; 
                        }
                    })
                    if(flag == 0){
                        selectedList.splice(index,1);
                        
                    }
                    
                }); 
                
            }
            console.log("SelectedList"+JSON.stringify(component.get("v.selectedList")));
            
            let discountCheckbox=component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c");
            let discountAmount=component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c");
            
            if($A.util.isEmpty(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))){
               component.set("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c",0);//AK
               }
            
            // venkat start
            for (var i = 0; i < selectedRows.length; i++) {
               
                if(!$A.util.isUndefinedOrNull(selectedRows[i].currentDiscAmt)){
                    remainingAmount+=parseFloat(selectedRows[i].currentDiscAmt); 
                }           
            }
           component.set("v.totalAppliedDiscount",remainingAmount);
           component.set("v.totalUnAllocatedDiscount",discountAmount-  JSON.parse(JSON.stringify(remainingAmount)));
            //end
            
            let maxDiscAmt = parseFloat(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))));
            console.log('maxDiscAmt***'+maxDiscAmt);
            
            
            component.set("v.selectedProcedureRecords",event.getParam('selectedRows'));
            let selectedProcedureRecordsNetInstance = component.get("v.selectedProcedureRecordsNetInstance"); 
            if($A.util.isEmpty(event.getParam('selectedRows'))){
                component.set("v.selectedProcedureRecordsNetInstance",[]); 
                component.set("v.selectedList",[]);
                component.set("v.selectedProcedureRecords",[]);
                
            }
            else{
                selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(event.getParam('selectedRows'));
                component.set("v.selectedProcedureRecordsNetInstance",selectedProcedureRecordsNetInstance); 
            }       
            if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment'){
            helper.deAllocateDiscounts(component, event, helper,component.get("v.selectedProcedureRecords"));
            }
            if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Percentage'){
                if(maxDiscAmt == 0 || maxDiscAmt == 0.0){
                    console.log("percentage logic without max discount");
                    helper.organizePercentageLogicWithNoMaxDis(component, event, helper, component.get("v.selectedList"));
                } else{
                    console.log("percentage logic with max discount");
                    helper.organizePercentageLogic(component, event, helper, component.get("v.selectedList"));
                }
            }
            
            if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment' && discountCheckbox==true && discountAmount!=null){
                helper.reCalDisAmtOnSelectedRowChange(component, event, helper); 
                 console.log('Akki2');
            } 
           helper.addButtonEnableHandler(component,event, helper);
        }
        catch(e){
            alert(e);
        }
    },
    runMaxDiscountValidation : function(component, event, helper) {
         try{
             component.set("v.selectedRows",[]); 
             component.set("v.selectedList",[]); 
             component.set("v.selectedProcedureRecords",[]); 
             helper.resetCurrentDscAmt(component, event, helper); 
             if($A.util.isEmpty(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))){
                  component.set("v.totalUnAllocatedDiscount",0.0);//AK
             }else{
                 component.set("v.totalUnAllocatedDiscount",component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"));//AK
             }
             
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
                    helper.globalFlagToast(component, event, helper,'Divide checbox reset! please check again to divide the amount equally.', ' ','info'); 
                }       
                let amountPaid =   component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c");
                if(amountPaid){
                    let remainingAmount =   component.get("v.totalAppliedDiscount");
                    if(!$A.util.isUndefinedOrNull(amountPaid)){
                        component.set("v.totalUnAllocatedDiscount",(parseFloat(amountPaid) - parseFloat(remainingAmount)));  
                    }
                }
                else {
                    component.set("v.makePaymentButtonDisable",true); 
                    component.set("v.totalUnAllocatedDiscount",0.0);  
                }  
                component.set("v.remainingDiscount",component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c"));
                
             component.set("v.selectedRows",[]); 
             component.set("v.selectedList",[]);
            component.set("v.selectedProcedureRecords",[]);
            helper.resetCurrentDscAmt(component, event, helper); 
            helper.addButtonEnableHandler(component,event, helper);
        }
        catch(e){
            alert(e);
        }
    },
    blurLogic  :  function(component, event, helper){ 
        if(component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c")){
            component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false); 
            helper.globalFlagToast(component, event, helper,'Divide checkbox reset! Please check again to divide the amount equally.', ' ','info'); 
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
                cmp.set("v.loaded",false); 
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
                        cmp.set("v.loaded",true);
                        
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
                                }
                                helper.setRemainingAmount(cmp, event, helper,element);
                                count++;
                            }); 
                            helper.sortSelectedProcedures(cmp,'ElixirSuite__Date_Of_Service__c','desc',selectedProcedureRecordsNetInstance);
                            selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(allProcedureOnMT);
                            cmp.set("v.Plist",selectedProcedureRecordsNetInstance);
                        }
                        else {
                            helper.globalFlagToast(cmp, event, helper,'No results found!', 'Please try a different filter!','error');
                        }
                        helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                        
                    }
                    
                });
                $A.enqueueAction(action);  
            }
            else {
                helper.globalFlagToast(cmp, event, helper,'No filter applied!', 'Please apply filter to search!','error');
            }
        }
        catch(e){
            alert(e);
        }
        
    },
    clearClaimSearchFilter :  function(cmp,event,helper){ 
        //helper.setDefaultJSON(cmp, event, helper); //commented by Anusha-LX3-5792
        cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',
        'procedureId' : '','CPTCode' : ''}); //Added by Anusha -LX3-5792
        helper.keepSelectedProcedures(cmp, event, helper);
		cmp.set("v.isSearchDisabled",false); // Added by sagili siva :Lx3-5827        
    },
    addDiscountFromUI :  function(cmp,event,helper){ 
        try{
            console.log('hiii')
            var selectedRows =  cmp.get("v.selectedProcedureRecords");
             console.log(selectedRows.length);
             if($A.util.isEmpty(selectedRows)){
                helper.globalFlagToast(cmp, event, helper,'Please select procedures!', ' ','error');  
            }else if(helper.checkRequieredValidity(cmp,event,helper)){
                console.log('hiii 2222')
                /*if( selectedRows.length > 1){ // sagili siva
                 cmp.set("v.showConfirmDialog",true); 
                  }*/
               // else {
                    console.log('hiii 3333')
                    helper.savePayments(cmp,event,helper);  
               // }  
            }
            
          /* if(helper.checkRequieredValidity(cmp,event,helper)){
                helper.savePayments(cmp,event,helper);  
            }*/
            
        }
        catch(e){
            alert(e);
        }
        
    },
    handleConfirmDialogYes :  function(cmp,helper){ 
        helper.savePayments(cmp,event,helper);
    },
    handleConfirmDialogNo :  function(cmp){ 
        cmp.set("v.showConfirmDialog",false);    
    },
    selectedRowsOne : function(component, event, helper) {
        try{
            var amountPaid = component.get("v.amountPaid");
            console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows'))); 
            component.set("v.selectedParentSchedule",event.getParam('selectedRows'));   
            component.set("v.selectedParentScheduleId",event.getParam('selectedRows')[0].Id);  
            helper.validateAmountPaid(component, event, helper);
            var selectedRows =  event.getParam('selectedRows'); 
            var selectedIds = [];
            var netAmount = []; 
            
            for (var i = 0; i < selectedRows.length; i++) 
            {
                selectedIds.push(selectedRows[i].Id);
                netAmount.push(selectedRows[i].remainingAmount);
            }
            component.set("v.NetAmount",Number(netAmount));
            component.set("v.selectedSchedules",selectedIds);
            
            if(amountPaid > 0 && component.get("v.NetAmount") > 0 && amountPaid > component.get("v.NetAmount")) {
                component.set("v.isAllocatedAmtExceedPaSh", true);
                //  component.set("v.makePaymentButtonDisable", true);
            }else {
                component.set("v.isAllocatedAmtExceedPaSh", false);
                //   component.set("v.makePaymentButtonDisable", false);
            }   
            
            var action = component.get("c.getSchedules");
            component.set("v.loaded",false);       
            action.setParams({lst_masterId:selectedIds
                             });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded",true);         
                    component.set("v.scheduleList",response.getReturnValue());
                    component.set("v.hideSchedule",true);
                }
                
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e);
        }
        
    }, 
    divideAmountEqually :  function(component, event, helper) {
        try{
            let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
            
            let Plist =  component.get("v.Plist");
            var checked = event.getSource().get("v.checked"); 
            console.log(checked);
            if(checked){
                if(discAmt){
                    let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
                    console.log('selectedProcedureRecords '+(component.get("v.selectedProcedureRecords")).length)
                    console.log('selectedProcedureRecords '+JSON.stringify(component.get("v.selectedProcedureRecords")))
                    let dscToAllocate = discAmt / selectedProcedureRecords.length;
                    if($A.util.isEmpty(selectedProcedureRecords)){
                        helper.globalFlagToast(component, event, helper,'PLEASE SELECT PROCEDURE(S)!', ' ','error');   
                        component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
                    }
                    else {
                        helper.handleEnableInlineEditing(component, event, helper,checked);  
                        selectedProcedureRecords.forEach(function(element) {  
                            if(element.ElixirSuite__Actual_Price__c != null){
                            if(dscToAllocate > element.remainingAmount){ // 300> 200
                                element.currentDiscAmt = (element.remainingAmount).toFixed(2);         
                            }
                            else {
                                element.currentDiscAmt = dscToAllocate.toFixed(2);      // 200 300
                            }
                            let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                            if(arrIndex>=0){
                                if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                                    Plist[arrIndex].currentDiscAmt = (Plist[arrIndex].remainingAmount).toFixed(2);
                                }
                                else {
                                    Plist[arrIndex].currentDiscAmt = dscToAllocate.toFixed(2);
                                }
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
                    helper.globalFlagToast(component, event, helper,'Please fill discount amount!', ' ','error');  
                    component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
                }  
            }
            else {
                helper.handleEnableInlineEditing(component, event, helper,checked);  
                helper.resetCurrentDscAmt(component, event, helper); 
            }
            helper.addButtonEnableHandler(component,event, helper);
            
        }
        catch(e){
            alert(e);
        }
        
    },
    handleSaveDataTable :  function(component, event, helper) {
        console.log('Savedatatable');
        //component.set("v.masterTransactionObj.ElixirSuite__Complete_discount_to_be_utilized__c",false);
        let Plist =  component.get("v.Plist");
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
        let draftValues = event.getParam('draftValues');
        
        let checkNegative = false;//AK
        let checkRemAmount = false;//AK
        let totalCurrentDiscAmt = 0;
        let unselectedPro = '';
        let idArr = [];
        selectedProcedureRecords.forEach(function(element) {  
            idArr.push(element.Id);
        });
        
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        console.log('discAmtSavedatatable'+discAmt);
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
            component.set("v.makePaymentButtonDisable",true);
            component.set("v.cancelSave",true);  
            return;
        }
        if(checkNegative){
            helper.globalFlagToast(component, event, helper,'Cannot have a negative value ', ' ','error'); 
            component.set("v.makePaymentButtonDisable",true); 
            component.set("v.cancelSave",true);  
            return;
        }
        if(totalCurrentDiscAmt > discAmt){
            helper.globalFlagToast(component, event, helper,'Cannot allocate more than Discount Amount!', ' ','error');
            component.set("v.makePaymentButtonDisable",true); 
            component.set("v.cancelSave",true);  
            return;  
        }
        
        //Ak
        
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
        component.set("v.cancelSave",false);  
        component.set("v.draftValues",[]); 
        helper.caculateDiscountVariations(component, event, helper);
        helper.addButtonEnableHandler(component, event, helper); //17-02-2023
        //   component.set("v.hideCBCols",false);
    },
    handleCancelDataTable :  function(component, event, helper) {
     console.log("eeeeeeeeeeeeeeeeeeeeeeeeeeee");  
        component.set("v.cancelSave",false);  
        helper.addButtonEnableHandler(component, event, helper); //17-02-2023
    },
    handleCellBlur :  function(component, event, helper) {
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
                                component.set("v.makePaymentButtonDisable",true); //17-03-2023
                            }
                        
                        }  
                    }
                    
                }
            }); 
            /*  if(draftValues[0].currentDiscAmt){
                component.set("v.hideCBCols",true);
            }
            else {
                component.set("v.hideCBCols",false);
            }*/
            helper.addButtonEnableHandler(component, event, helper); //17-02-2023
        }
        catch(e){
            alert(e);
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
        }
        else {
            helper.caculateDiscountVariations(component, event, helper);   
        }
    },
    validatePercentage : function(cmp, event, helper) {
        let val =  event.getSource().get("v.value");
        if(val>100){
            helper.globalFlagToast(cmp, event, helper,'Discount percentage cannot be greater than 100!', 'Please enter percentage less than 100.','error');  
            cmp.set("v.makePaymentButtonDisable",true); 
           
            
            cmp.set("v.selectedRows",[]); 
            cmp.set("v.selectedList",[]);
            helper.resetCurrentDscAmt(cmp, event, helper); 
        }
        else {
            if(parseInt(val) == 0 ){
                cmp.set("v.makePaymentButtonDisable",true);   
            }else{
             cmp.set("v.makePaymentButtonDisable",false);    
            }
            helper.handleEnableInlineEditing(cmp, event, helper,true);
            cmp.set("v.selectedRows",[]);
            cmp.set("v.selectedList",[]);
            cmp.set("v.selectedProcedureRecords",[]);
            helper.resetCurrentDscAmt(cmp, event, helper); 
         }
          helper.addButtonEnableHandler(cmp,event, helper);
        
        
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