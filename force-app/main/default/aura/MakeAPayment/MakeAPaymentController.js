({  
    init: function (cmp, event, helper) {
        try{
                cmp.set("v.isModalOpen",true);  
                cmp.set("v.PatientId", cmp.get("v.recordId")); 
               
                helper.displayDetails(cmp, event, cmp.get("v.recordId"));
                helper.getPrivatePaymentDetails(cmp, event, helper, cmp.get("v.recordId"));
               
                cmp.set('v.columns4', [
                {label: 'S.No', fieldName: 'SNo', type: 'text', sortable :true}  ,
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}  ,
                {label: 'Procedure Code', fieldName: 'ProcedureCode', type: 'text', sortable :true}  ,
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Billed Amt.', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true},
                {label: 'Current Discount Amount', fieldName: 'ElixirSuite__Discount_Amount__c', type: 'currency',editable: false}  ,	
                {label: 'Additional Discount Amount', fieldName: 'inputDiscount', type: 'currency',editable: false},
                {
                label: 'Add Discount',
                fieldName: 'otherDiscount',
                type: 'button' ,typeAttributes:  {iconName: 'utility:add', target: '_blank' , name: 'recLink',variant:'Base' }
                },
                {label: 'Patient Paid Amt.', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true,
                typeAttributes: { step: '0.00001', minimumFractionDigits: '2', maximumFractionDigits: '2'},
                },
                {label: 'Remaining Amt.', fieldName: 'RemainingAmount', type: 'currency', sortable :true},
            ]);
            
                cmp.set('v.columns1', [
                {label: 'Card Number', fieldName: 'ElixirSuite__Credit_Card_Number__c', type: 'text'},
                {label: 'Expiration Month', fieldName: 'ElixirSuite__Expiration_Month__c', type: 'text'},
                {label: 'Expiration Year', fieldName: 'ElixirSuite__Expiration_Year__c', type: 'text'},
                {label: 'First Name', fieldName: 'ElixirSuite__First_Name_on_Card__c', type: 'text'},
                {label: 'Last Name', fieldName: 'ElixirSuite__Last_Name_on_Card__c', type: 'text'},
            ]);
            
            cmp.set('v.columns2', [
                {label: 'Schedule', fieldName: 'Name', type: 'Auto Number'},
                {label: 'Frequency', fieldName: 'ElixirSuite__Pay_Frequency__c', type: 'Picklist'},
                {label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'Currency'},
                {label: 'Total Amount', fieldName: 'ElixirSuite__Net_Balance__c', type: 'Currency'},
                {label: 'Remaining Amount', fieldName: 'ElixirSuite__Remaining_Amount__c', type: 'Currency'}
            ]);
            
            cmp.set('v.columns3', [
                {label: 'Scheduled Date', fieldName: 'ElixirSuite__Scheduled_Date__c', type: 'Date'},
                {label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'Text'},
                {label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'Currency'},
                {label: 'Amount Paid', fieldName: 'ElixirSuite__Amount_Paid__c', type: 'Currency'},
                {label: 'Remaining Amount', fieldName: 'ElixirSuite__Remaining_Amount__c', type: 'Currency'}
            ]); 
          
            helper.fetchERASettings(cmp);
            var action1 = cmp.get("c.fetchModeofOtherPayments");
            console.log('options'+action1);
            
            action1.setParams({});
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){ 
                    var opts = response.getReturnValue();
                    console.log('otherModeOptions getReturn'+response.getReturnValue());
                    cmp.set("v.otherModeOptions", JSON.parse(opts));
                    console.log('otherModeOptions setting'+JSON.parse(opts));
                }
            })
            $A.enqueueAction(action1);           
        }
        catch(e){
            alert(e)
        }
    },
    parentComponentEvent : function(cmp, event,helper) { 
       
        var accId = event.getParam("SelectedId"); 
        console.log('Params received: ' + accId);
        cmp.set("v.PatientId", accId);
        if(cmp.get("v.valueForPrivatePayment") == 'Register a Payment' && cmp.get("v.typeOfPayment")=="Private Payment"){
            cmp.find("privateRegisterAPayment").reInitialize();
       	}
        
        helper.displayDetails(cmp, event, accId);
    },
    handleChange: function (cmp, event) {
        cmp.set("v.hideOrShowClaims",false);
        var changeValue = event.getParam("value");
        if(changeValue =='Allocate Payments'){
            cmp.set("v.makePay",false);
            cmp.set("v.cheque",false);
            if(cmp.get("v.PatientId") != "")
            {
                cmp.set("v.AllocPay",true);
                cmp.set("v.Credit",false); 
                cmp.set("v.Allocate",true);
                if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
                
            } 
            cmp.set("v.selectedInsurancePaylist", []);
            cmp.set("v.selectedRowsOfProc", []);
            cmp.set("v.payReasonVal", "");
            cmp.set("v.modeOfPayment", "");
            cmp.set('v.myCurrency',0);
            cmp.set("v.TotalAppliedAmountInsurance", 0);
            cmp.set("v.TotalUnallocatedAmountInsurance", 0);
            
        }
        else if(changeValue =='Make a Payment'){
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            today = yyyy +'-'+ mm +'-' + dd ;
            cmp.set("v.Tdate",today);
            cmp.set("v.makePay",true);
            cmp.set("v.amountAllocated",0);
            if(cmp.get("v.PatientId") != "")
            {
                cmp.set("v.AllocPay",false);
                cmp.set("v.Allocate",true); 
                
                if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
            }
            else
            {
                cmp.set("v.AllocPay",false);
                cmp.set("v.Allocate",false);  
                if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
            }
             cmp.set("v.selectedInsurancePaylist", []);
           cmp.set("v.selectedRowsOfProc", []);
            cmp.set("v.payReasonVal", "");
            cmp.set("v.modeOfPayment", "");
            cmp.set('v.myCurrency',0);
            cmp.set("v.TotalAppliedAmountInsurance", 0);
            cmp.set("v.TotalUnallocatedAmountInsurance", 0);
        }
    },
    closeModel: function(component) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    selectedRows : function(component, event) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        var selectedIds = [];
        var selectedAmount = [];
        var selectedProIds = [];
        var PayTransId = component.get('v.PayTransId');
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedInsurancePaylist",selectedRows);
       // component.set("v.maintainState",selectedRows);
        console.log('seleceted rows after click'+ JSON.stringify(selectedRows)); 
        var sumRemainingmt = 0;
        var sumBilledAmt = 0;
        var totalDisc = 0;
        var totalAmountAfterDisc = 0;
        var totalpaid = 0 ;
    if(selectedRows.length >0){
        component.set("v.disableNextButton",false);
        for(var i =0;i< selectedRows.length; i++){
            if(!$A.util.isUndefinedOrNull(selectedRows[i].RemainingAmount)){
                if(selectedRows[i].RemainingAmount > 0){
                    sumRemainingmt+=selectedRows[i].RemainingAmount;
                    
                }  
            }
         if(!$A.util.isUndefinedOrNull(selectedRows[i].ElixirSuite__Actual_Price__c)){
                if(selectedRows[i].ElixirSuite__Actual_Price__c > 0){
                    sumBilledAmt+=selectedRows[i].ElixirSuite__Actual_Price__c;
                }  
            }
            totalDisc += ((selectedRows[i].inputDiscount==null?0: parseFloat(selectedRows[i].inputDiscount)) + (selectedRows[i].ElixirSuite__Discount_Amount__c==null?0: parseFloat(selectedRows[i].ElixirSuite__Discount_Amount__c)));
            console.log('each iter',totalDisc);
            totalpaid += parseFloat(selectedRows[i].ElixirSuite__Total_Actual_Patient_Paid_Amount__c);
            selectedProIds.push(selectedRows[i].Id);
        }
    }else{
        component.set("v.disableNextButton",true);
    }
    component.set("v.selectedRowsOfProc",selectedProIds);
        if(component.get('v.value') == 'Make a Payment')
        {
            if(component.get("v.payReasonVal") == 'Applied Payment'){
                var amt = 0;
                if(selectedRows.length >0){
                    component.set("v.makePaymentButtonDisable", false);
                    component.set("v.TotalAppliedAmountInsurance", amt);
                    component.set("v.TotalUnallocatedAmountInsurance", component.get('v.myCurrency').toFixed(2) - amt.toFixed(2));
                }else{
                    component.set("v.selectedInsurancePaylist",[]);
                    component.set("v.makePaymentButtonDisable", true);
                    component.set("v.TotalAppliedAmountInsurance", amt);
                    console.log(component.get(amt));
                    console.log(component.get('v.myCurrency'));
                    component.set("v.TotalUnallocatedAmountInsurance", component.get('v.myCurrency').toFixed(2) - amt.toFixed(2));
                }
            }
            
        }
        for (var j = 0; j < selectedRows.length; j++) {
            selectedIds.push(selectedRows[j].Id);
            selectedAmount.push(selectedRows[j].ElixirSuite__PatientOutstanding__c);
            if(PayTransId == null || PayTransId == '' || PayTransId.length == 0)
            {
                PayTransId.push(selectedRows[j].Id);
            }
            else if(!PayTransId.includes(selectedRows[j].Id))
            {
                PayTransId.push(selectedRows[j].Id);
            }
        }
        console.log('#### IDs'+PayTransId);
        console.log('#### selected IDs'+selectedIds);
        for(var k=0; k < PayTransId.length; k++)
        {
            if(!selectedIds.includes(PayTransId[k]))
            {
                PayTransId.splice(k, 1); 
                k--;
            }
        }
        console.log('IDs'+PayTransId);
        component.set("v.PayTransId",PayTransId);
        var sum = selectedAmount.reduce(function(a, b){
            return a + b;
        }, 0);
        /*var sum1 = AmountPaid.reduce(function(a, b){
            return a + b;
        }, 0); */
        //var totalAmount =sum-sum1;
        var totalAmount =sum;
        component.set("v.AmountDue",totalAmount);
        if(component.get('v.value') == 'Make a Payment')
        {
            if(component.get('v.AmountDue') > component.get("v.myCurrency"))
            {
                component.set("v.AmountApplied",component.get("v.myCurrency"));
            }
            else
            {
                component.set("v.AmountApplied",component.get("v.AmountDue"));
            }
        }
        console.log('--kk--'+component.get("v.PayTransId"));
        component.set("v.TotalAppliedAmountInsurance", sumBilledAmt.toFixed(2));
        component.set("v.totalBilledAmount", sumBilledAmt);
        
        component.set("v.totalDiscount", totalDisc.toFixed(2));
        totalAmountAfterDisc =  component.get("v.TotalAppliedAmountInsurance") - component.get("v.totalDiscount");
        component.set("v.totalAmountAfterDiscount",totalAmountAfterDisc.toFixed(2));
        //component.set("v.totalAmountPaid", sumRemainingmt);
        console.log('total remaing111 '+component.get("v.TotalAppliedAmountInsurance"));
        var amounToBePaid = parseFloat(totalAmountAfterDisc.toFixed(2)-totalpaid.toFixed(2)).toFixed(2);
        component.set("v.TotalUnallocatedAmountInsurance",amounToBePaid);
       if($A.util.isUndefinedOrNull(amounToBePaid) || amounToBePaid<=0 || isNaN(parseFloat(amounToBePaid))){ //venkat - LX3-6253
             component.set("v.disableNextButton", true);
        }
        else if (!$A.util.isUndefinedOrNull(amounToBePaid) && amounToBePaid>0){
             component.set("v.disableNextButton", false);
        }
        component.set("v.totalAmountPaid",totalpaid.toFixed(2));
        console.log('total Billed amount '+component.get("v.TotalAppliedAmountInsurance"));
        console.log('total totalDiscount '+component.get("v.totalDiscount"));
        console.log('total totalAmountPaid '+component.get("v.totalAmountPaid"));
        console.log('total totalAmount to bePaid '+component.get("v.TotalUnallocatedAmountInsurance"));
    },
    AmountToPayEditable: function(component) {
        var selectedRows = component.get("v.selectedInsurancePaylist");
        var  totalamount = ((component.get("v.totalAmountAfterDiscount") - component.get("v.totalAmountPaid")));
        console.log('totalamount '+totalamount);
        /*if((component.get("v.TotalUnallocatedAmountInsurance")) > ((component.get("v.totalAmountAfterDiscount") - component.get("v.totalAmountPaid")))){
               var  totalamount = ((component.get("v.totalAmountAfterDiscount") - component.get("v.totalAmountPaid")));
            helper.globalFlagToast(component, event, helper,'Amount can\'t be greater than '+ totalamount.toFixed(2), ' ','Error'); 
        }*/
        var amounToBePaid = parseFloat(component.get("v.TotalUnallocatedAmountInsurance"));
          console.log('amounToBePaid '+amounToBePaid);
        if(amounToBePaid > totalamount || $A.util.isUndefinedOrNull(amounToBePaid) || amounToBePaid<=0 || isNaN(parseFloat(amounToBePaid))){//venkat - LX3-6253
             component.set("v.disableNextButton", true);
        }
        else if (!$A.util.isUndefinedOrNull(amounToBePaid) && amounToBePaid>0){
             component.set("v.disableNextButton", false);
        }
        if($A.util.isEmpty(selectedRows)){	
                var toastEvent = $A.get("e.force:showToast");	
                    toastEvent.setParams({	
                        title : 'Error',	
                        message: 'Please select a Procedure to make Payment',	
                        type: 'Error',	
                        mode: 'pester'	
                    });	
                    toastEvent.fire();	
            }	
        else if((component.get("v.TotalUnallocatedAmountInsurance")) > ((component.get("v.totalAmountAfterDiscount") - component.get("v.totalAmountPaid")))){	
            var toastEvent = $A.get("e.force:showToast");	
                    toastEvent.setParams({	
                        title : 'Error',	
                        message: 'Amount can\'t be greater than '+ totalamount.toFixed(2),	
                        type: 'Error',	
                        mode: 'pester'	
                    });	
                    toastEvent.fire();
        }
    },
    makeTranscation :function(cmp) {
        
        var error = false;
        console.log('#### PatientId : ' + cmp.get('v.PatientId'));
        console.log('#### cmp.get("v.myCurrency") : ' + cmp.get('v.myCurrency'));
        console.log('#### amountAllocated : ' + cmp.get('v.amountAllocated'));
        console.log('#### Tdate : ' + cmp.get('v.Tdate'));
        console.log('#### PayTransId : ' + cmp.get('v.PayTransId'));
        console.log('#### payReasonVal : ' + cmp.get('v.payReasonVal'));
        console.log('#### ReceivedFrom : ' + cmp.get('v.ReceivedFrom'));
        console.log('#### AmountDue : ' + cmp.get('v.AmountDue'));
        console.log('#### error inside make payment : ' + error);
        if(error == false)
        {
            console.log('#### error inside make payment 2 : ' + error);
            console.log('#### PatientId : ' + cmp.get('v.PatientId'));
            console.log('#### cmp.get("v.myCurrency") : ' + cmp.get('v.myCurrency'));
            console.log('#### amountAllocated : ' + cmp.get('v.amountAllocated'));
            console.log('#### Tdate : ' + cmp.get('v.Tdate'));
            console.log('#### PayTransId : ' + cmp.get('v.PayTransId'));
            console.log('#### payReasonVal : ' + cmp.get('v.payReasonVal'));
            console.log('#### ReceivedFrom : ' + cmp.get('v.ReceivedFrom'));
            console.log('#### AmountDue : ' + cmp.get('v.AmountDue'));
            
            var action = cmp.get("c.SaveData");
            action.setParams({
                accId:cmp.get("v.PatientId"),
                amountPaid:cmp.get("v.myCurrency"),
                amountAllocated:cmp.get("v.amountAllocated"),
                payDate:cmp.get("v.Tdate"),	
                payTrans:cmp.get("v.PayTransId"),
                payReason : cmp.get('v.payReasonVal'),
                RecvdFrm : cmp.get('v.ReceivedFrom'),
                paymentNote : cmp.get('v.addNote'),
                amountDue : cmp.get('v.AmountDue')
            });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Payment Sucessful!!',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    cmp.set("v.isModalOpen", false);
                }
            });
            $A.enqueueAction(action);     
        }
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },
    registerPayment :  function(cmp,event,helper){ 
        try{
            if(helper.checkRequieredValidity(cmp,event,helper)){
                if(cmp.get("v.payReasonVal") == 'Applied Payment'){
                    if(parseInt(cmp.get("v.TotalAppliedAmountInsurance"))>parseInt(cmp.get("v.myCurrency")) && (cmp.get("v.selectedInsurancePaylist").length>1 || cmp.get('v.PayTransId').length>1)){
                        cmp.set("v.showConfirmDialog",true);   
                    }
                    else {
                        var sizeOfLst = cmp.get("v.selectedInsurancePaylist");
                        console.log('sizeOfLst.length'+sizeOfLst.length);
                        helper.savePayments(cmp,event,helper); 
                    }  
                }else{
                    helper.savePayments(cmp,event,helper);  
                }
            }
        }
        catch(e){
            alert(e);
        }
    },
    openPopUp : function(component){
        component.set("v.makeAPaymentScreen",true);
    },
    handleRowAction: function(component, event) {
        
        try{
            console.log('inside handleRow Action');
            var action = event.getParam('action');
            var  row = event.getParam('row');
            //component.set("v.actionName",action);
            console.log(action.name);
            //var row = event.getParam('row');
            //component.set("v.SelectedRec", row);
            //console.log('row');
            //   var maxAmount = ((row.ElixirSuite__Actual_Price__c==null?0:row.ElixirSuite__Actual_Price__c) - (row.ElixirSuite__Discount_Amount__c==null?0:row.ElixirSuite__Discount_Amount__c));
            
            //var maxAmount =((row.ElixirSuite__Actual_Price__c - (row.ElixirSuite__Discount_Amount__c + row.inputDiscount)) - row.ElixirSuite__Total_Paid_Amount__c).toFixed(2) ;
            //var maxDiscount = (row.ElixirSuite__Actual_Price__c==null || row.ElixirSuite__Actual_Price__c==0) ? 0:((100*maxAmount) / (row.ElixirSuite__Actual_Price__c)).toFixed(2);
            var tempMaxAmt =((row.ElixirSuite__Actual_Price__c - (row.ElixirSuite__Discount_Amount__c+row.ElixirSuite__Other_Discount__c)) - row.ElixirSuite__Total_Actual_Patient_Paid_Amount__c).toFixed(2) ;
            var maxAmount = tempMaxAmt;
            console.log('maxAmount'+maxAmount);
            console.log('discAmount'+row.ElixirSuite__Discount_Amount__c);
            console.log('paidAmount'+row.ElixirSuite__Total_Actual_Patient_Paid_Amount__c);
            console.log('addDiscount'+row.ElixirSuite__Other_Discount__c);
            var tempMaxDisc = (row.ElixirSuite__Actual_Price__c==null || row.ElixirSuite__Actual_Price__c==0) ? 0:((100*maxAmount) / (row.ElixirSuite__Actual_Price__c)).toFixed(2);
            var maxDiscount = tempMaxDisc;
            console.log('maxDiscount'+maxDiscount);



            switch (action.name) {
                case 'recLink':
                    component.set("v.maxAmountforDiscount", maxAmount);
                    component.set("v.maxPercentageforDiscount", maxDiscount);
                    component.set("v.currentActiveID", row.Id);
                    component.set("v.isDiscountModalOpen", true);
                    break;
            }
        }catch(e){
            alert(e.message);
        }
    },
    handleDiscountCmpEvent : function(component, event) {
        var totalDisc = 0;
        totalDisc =  component.get("v.totalDiscount");
        var selectedRows = component.get("v.selectedInsurancePaylist");
        var amounttobepaid = component.get("v.TotalUnallocatedAmountInsurance");
        var totalBilledAmt = component.get("v.totalBilledAmount");
        //component.set("v.TotalAppliedAmountInsurance", sumBilledAmt.toFixed(2));
        // component.set("v.totalAmountAfterDiscount",totalAmountAfterDisc.toFixed(2));
        //component.set("v.TotalUnallocatedAmountInsurance",totalAmountAfterDisc.toFixed(2)-totalpaid.toFixed(2));
       var inputvalueFromChild = 0;
        inputvalueFromChild = event.getParam("inputValue");	
        var typevalueFromChild = event.getParam("type");
        console.log("type",typevalueFromChild);	
        var allDataInsurance =component.get("v.PInsurancePaylist");	
        console.log('allDataInsurance'+allDataInsurance);
        for(var recdata in allDataInsurance){	
            console.log('allDataInsurance[recdata]'+allDataInsurance[recdata]);
            if(allDataInsurance[recdata].Id==component.get("v.currentActiveID")){
                if(typevalueFromChild == 'Percentage'){
                    let percentValue = parseFloat(inputvalueFromChild)/100;
                    console.log('Percent Value'+percentValue);
                    allDataInsurance[recdata].inputDiscount = (allDataInsurance[recdata].ElixirSuite__Actual_Price__c * percentValue) + parseFloat(allDataInsurance[recdata].ElixirSuite__Other_Discount__c);
                    allDataInsurance[recdata].inputDiscountNew = allDataInsurance[recdata].ElixirSuite__Actual_Price__c * percentValue;
                console.log('New Value'+allDataInsurance[recdata].inputDiscountNew);
                console.log('Old Value'+allDataInsurance[recdata].inputDiscount);  
                }else if(typevalueFromChild == 'Amount'){
                    allDataInsurance[recdata].inputDiscount = allDataInsurance[recdata].ElixirSuite__Other_Discount__c + parseFloat(inputvalueFromChild);
                    allDataInsurance[recdata].inputDiscountNew = parseFloat(inputvalueFromChild);
                   
                }
                if(component.get("v.totalBilledAmount") > 0){
                component.set("v.totalDiscount", parseFloat(totalDisc)+parseFloat(inputvalueFromChild));
                component.set("v.TotalUnallocatedAmountInsurance", parseFloat(amounttobepaid-inputvalueFromChild).toFixed(2));
                    if(parseFloat(amounttobepaid-inputvalueFromChild).toFixed(2)<1){
                        component.set("v.disableNextButton", true); 
                    }else{
                         component.set("v.disableNextButton", false);
                    }
                component.set("v.totalAmountAfterDiscount", parseFloat(totalBilledAmt-inputvalueFromChild).toFixed(2)); 
                }
                let remainingAmt =(allDataInsurance[recdata].ElixirSuite__Actual_Price__c - (allDataInsurance[recdata].ElixirSuite__Discount_Amount__c + allDataInsurance[recdata].inputDiscount)) - allDataInsurance[recdata].ElixirSuite__Total_Paid_Amount__c ;
                //  let remainingAmt = 	 allDataInsurance[recdata].RemainingAmount - allDataInsurance[recdata].inputDiscount;
                allDataInsurance[recdata].RemainingAmount = remainingAmt>0?remainingAmt :0;
                console.log(' allDataInsurance[recdata].RemainingAmount'+ allDataInsurance[recdata].RemainingAmount);
            }
        }
        var sumDisc =0 ;
        for(var i =0;i< selectedRows.length; i++){
            sumDisc += ((selectedRows[i].inputDiscount==null?0: parseFloat(selectedRows[i].inputDiscount)) + (selectedRows[i].ElixirSuite__Discount_Amount__c==null?0: parseFloat(selectedRows[i].ElixirSuite__Discount_Amount__c)));
        }
        component.set("v.totalDiscount", sumDisc.toFixed(2));	
        component.set("v.PInsurancePaylist",allDataInsurance);
        //calculating total amount after discount
        var totAmt = component.get("v.TotalAppliedAmountInsurance");
        var totDisc = component.get("v.totalDiscount");
        component.set("v.totalAmountAfterDiscount", parseFloat(totAmt-totDisc).toFixed(2));
        //calculating total amount to be paid
        var totAftrDisc = component.get("v.totalAmountAfterDiscount");
        var totPaidAmt = component.get("v.totalAmountPaid");
        component.set("v.TotalUnallocatedAmountInsurance", parseFloat(totAftrDisc-totPaidAmt).toFixed(2));
        if(parseFloat(totAftrDisc-totPaidAmt).toFixed(2)<1){
             component.set("v.disableNextButton", true);
        }else{
             component.set("v.disableNextButton", false);
        }
    },
    openPaymentOptions:function(component) {
		component.set("v.openPaymentPage", false);
		var amountToPay = (component.get("v.totalAmountAfterDiscount") - component.get("v.totalAmountPaid"));
		var selectedProcedureRecords =   component.get("v.selectedInsurancePaylist");
		var amounToBePaid = parseFloat(component.get("v.TotalUnallocatedAmountInsurance"));
         console.log('selectedProcedureRecords '+JSON.stringify(selectedProcedureRecords));
         var totalRemainingAmount = component.get("v.totalBilledAmount") - component.get("v.totalDiscount")- component.get("v.totalAmountPaid");
        console.log('totalRemainingAmount '+totalRemainingAmount);
		
        selectedProcedureRecords.forEach(function(element) {
            if(element.RemainingAmount){
                var finalAMT = ((parseFloat(element.RemainingAmount))/totalRemainingAmount)*amounToBePaid;
                   console.log('finalAMT '+finalAMT.toFixed(2));
                    element.AmountToBeCharged = finalAMT.toFixed(2);
            }
        });
      component.set("v.selectedInsurancePaylist", selectedProcedureRecords);
      totalRemainingAmount = component.get("v.totalBilledAmount") - component.get("v.totalDiscount")- component.get("v.totalAmountPaid");
        if(amounToBePaid < amountToPay ){
             component.set("v.disableNextButton", false);
        }else if(parseFloat(component.get("v.TotalUnallocatedAmountInsurance"))  >  parseFloat(component.get("v.totalAmountAfterDiscount"))){
           console.log('TotalUnallocatedAmountInsurance '+component.get("v.TotalUnallocatedAmountInsurance"));
             console.log('totalAmountAfterDiscount '+component.get("v.totalAmountAfterDiscount"));
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Total Amount to be Paid cannot be greater than Total Amount after Discount',
                        type: 'Error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
            component.set("v.disableNextButton", true);
        }
        
    },

    
    CollectPayment:function(component, event, helper) {
        helper.saveCollectPayments(component,event,helper);
    },
    RenderBack:function(component) {
      component.set("v.openPaymentPage", true); 
       console.log('check'+component.get("v.maintainState"));
    },
    handlepaymentChange:function(component, event) {
         var changeValue = event.getParam("value");
        component.set("v.PaymentTypeinCollect", changeValue);
        if(changeValue=='Terminal'){
            component.set("v.othersOpen",false);
          component.set("v.openSavedCards", false); 
            component.set("v.disablePayNowButton", false); 
        }
         if(changeValue=='CashPayment'){
         component.set("v.othersOpen",false);
         component.set("v.openSavedCards", false); 
         component.set("v.disablePayNowButton", false); 
             component.set("v.cardValue", '');
        }
        if(changeValue=='creditCard'){
             component.set("v.disablePayNowButton", true);
         component.set("v.openSavedCards", true); 
         component.set("v.othersOpen",false);
          var action = component.get("c.getPaymentInfo");
                            action.setParams({acctId:component.get("v.PatientId")
                                             });
                            action.setCallback(this, function(response){
                                var state = response.getState();
                                if(state == "SUCCESS"){
                                    var cardList=[];
                                    var result = response.getReturnValue();
                                    //component.set("v.cardOptions", result);
                                    console.log('result'+ JSON.stringify(result));
                                    console.log('result leng'+ result.PaymentCardData.length);
                                    console.log('result name'+ result.PaymentCardData[0].ElixirSuite__Credit_Card_Company__c);
                                    for (var i = 0; i < result.PaymentCardData.length; i++){
                                        var val =result.PaymentCardData[i].ElixirSuite__Credit_Card_Number__c;
                                    console.log('result '+ val);
                                     //   cardList.push({label:result.PaymentCardData[i].ElixirSuite__Credit_Card_Company__c+' Card ending with ' +val.replace(regex, substr) ,value:result.PaymentCardData[i].ElixirSuite__Credit_Card_Company__c});  
                                        cardList.push({label:' '+' '+result.PaymentCardData[i].ElixirSuite__Credit_Card_Company__c+' Card ending with ' +val.replace(/.(?=.{4})/g, "*"),value:result.PaymentCardData[i].Id});  
                                    }
                                    console.log('cardList'+ JSON.stringify(cardList));
                                    component.set("v.paymentCardOptions", cardList);
                                }
                            }); 
                            $A.enqueueAction(action);  
        }
                 if(changeValue=='others'){
         component.set("v.openSavedCards", false); 
         component.set("v.disablePayNowButton", false); 
             component.set("v.othersOpen",true);
                 }
    },
     handlecardChange:function(component, event) {
          let paymentSFId = event.getSource().get("v.value");
          component.set("v.paymentSFId",paymentSFId);
         if(paymentSFId){
            component.set("v.disablePayNowButton", false);  
         }else{
             component.set("v.disablePayNowButton", true); 
         }
     },
   addNewCard : function (component) {
        var action = component.get("c.createCheckOutOtherTransaction");
        action.setParams({
        recordId : component.get("v.recordId"),
       procedures : JSON.stringify({'procedures' : component.get("v.selectedInsurancePaylist")}),
        totalAmount : component.get("v.TotalUnallocatedAmountInsurance"),
        discountAmount : component.get("v.totalDiscount")
        //discountPercent : component.get("v.discountPercent"),
        });
        
        var returnOtherTransactionId = '';

        action.setCallback(this, function(response){
        var state1 = response.getState();
        if (state1 === "SUCCESS"){
        
            returnOtherTransactionId = response.getReturnValue();
            component.set("v.otherTransactionId", returnOtherTransactionId);
            var action2 = component.get("c.checkOutApi");
            action2.setParams({
            recordId : component.get("v.recordId"),
            //procedures : JSON.stringify({'procedures' : component.get("v.selectedInsurancePaylist")}),
            totalAmount : component.get("v.TotalUnallocatedAmountInsurance"),
            discountAmount : component.get("v.totalDiscount"),
            returnOtherTransactionId : component.get("v.otherTransactionId"),
            //discountPercent : component.get("v.discountPercent"),
        });
         action2.setCallback(this, function(response2){
                var state2 = response2.getState();
                if (state2 === "SUCCESS"){  
        var navigationUrl = response2.getReturnValue();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": navigationUrl
        });
        urlEvent.fire();
        }
        });
        $A.enqueueAction(action2);
    }
      });
        $A.enqueueAction(action);
    },
    closeTerminal : function (component, event, helper) {
        helper.cancelTerminal(component, helper);
    },
    printValues :function (component) {      
    	console.log('I am Inside Print'+component.get("v.referenceNumber"));
        console.log('I am Inside Print 2'+component.find("OthersMode").get("v.value"));
    }
});