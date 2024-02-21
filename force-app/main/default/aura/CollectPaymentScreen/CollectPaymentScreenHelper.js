({
	setColumns: function(component) {
        component.set('v.columns1', [
            {label: 'Card Number', fieldName: 'ElixirSuite__Credit_Card_Number__c', type: 'text'},
            {label: 'Expiration Month', fieldName: 'ElixirSuite__Expiration_Month__c', type: 'text'},
            {label: 'Expiration Year', fieldName: 'ElixirSuite__Expiration_Year__c', type: 'text'},
            {label: 'First Name', fieldName: 'ElixirSuite__First_Name_on_Card__c', type: 'text'},
            {label: 'Last Name', fieldName: 'ElixirSuite__Last_Name_on_Card__c', type: 'text'},
        ]);

    }, 
    displayDetails:function(component, event, helper){
         var today = new Date();
         var dd = String(today.getDate()).padStart(2, '0');
         var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
         var yyyy = today.getFullYear();
         
         today = yyyy +'-'+ mm +'-' + dd ;
         component.set("v.Tdate",today);
        var action = component.get("c.fetchdetails");
           action.setParams({ accountId : component.get("v.recordId") });
           action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state',state ,'+++',response.getReturnValue());
               if (state === "SUCCESS") {     
           		   var result = response.getReturnValue();
                   component.set("v.accName", result.patientData.Name);
            		let arr = [];
                    for(let obj in result.mapOfModeOfPayment){
                        let sObj = {'label' : obj, 'value' : result.mapOfModeOfPayment[obj]};
                        arr.push(sObj);
                    }               
                    component.set("v.modeOfPaymentLst",arr);
        			let today = new Date();
        			let filteredRecords = [];
                    if(result.payInfo != undefined){
                        result.payInfo.forEach((record) => {
                            let expirationMonth = record.ElixirSuite__Expiration_Month__c;
                            let expirationYear = parseInt(record.ElixirSuite__Expiration_Year__c);
                            let monthMap = {
                            'Jan': 0, 'Feb': 1, 'Mar': 2, 'Apr': 3,
                            'May': 4, 'June': 5, 'July': 6, 'Aug': 7,
                            'Sep': 8, 'Oct': 9, 'Nov': 10, 'Dec': 11
                        };
                        let expirationMonthNumber = monthMap[expirationMonth];
                        let expirationDate = new Date(expirationYear, expirationMonthNumber);
                        if (expirationDate > today) {
                            let cardNumber = record.ElixirSuite__Credit_Card_Number__c;
                            let maskedCardNumber = "****-****-" + cardNumber.slice(-4);
                            record.ElixirSuite__Credit_Card_Number__c = maskedCardNumber;
                            filteredRecords.push(record);
                        }
                    });
                    
                    component.set("v.Infolist", filteredRecords);
                    console.log('Infolist--'+ JSON.stringify(filteredRecords))
                }
               }
           
            });
           
           $A.enqueueAction(action);
       },
           
    bottomSection : function(cmp, event, helper){

        var amt =0;
        var discButtAct=cmp.get("v.makeDiscountButtonDisable");
        if(cmp.find('payReason').get('v.value')=='Unallocated Payment'){
            cmp.set('v.disableCheckbox',true);
            cmp.set("v.selectedProcedures",[]);
            cmp.set("v.creditMemoSelectedRows",[]);            
             cmp.set("v.TotalCreditAmount", 0);
            if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
            {
                amt =0;
                if(discButtAct){
                cmp.set("v.makePaymentButtonDisable", false);
                }
                cmp.set("v.TotalAppliedAmount", amt);
                cmp.set("v.TotalUnallocatedAmount", cmp.get('v.myCurrency') - amt);
            }else{
                cmp.set("v.TotalAppliedAmount", 0);
                cmp.set("v.TotalUnallocatedAmount", 0);  
                cmp.set("v.makePaymentButtonDisable",true);
               
            }
        }
        else if(cmp.find('payReason').get('v.value')=='Applied Payment')
        {
            cmp.set('v.disableCheckbox',false);
            amt =0;
            var rowList;
            rowList = cmp.get('v.selectedProcedures');
            console.log('rowListlength',rowList.length);
            if(rowList.length > 0){
                
                if(discButtAct){
                cmp.set("v.makePaymentButtonDisable", false);
                }
                
                
                for(var c=0; c<rowList.length; c++){
                    console.log('rowList---',rowList);
                    console.log('row',rowList[c].ElixirSuite__PatientOutstanding__c);
                    if(rowList[c].ElixirSuite__PatientOutstanding__c > 0){
                        amt+=rowList[c].ElixirSuite__PatientOutstanding__c;
                    }
                }
            }else{
                cmp.set("v.makePaymentButtonDisable", true);
            }
            if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
            {
                if(parseFloat(amt) <= parseFloat(cmp.get('v.TotalCreditAmount'))) {

                        cmp.set('v.TotalAppliedAmount',0);  
                        cmp.set("v.TotalUnallocatedAmount", parseFloat(cmp.get('v.myCurrency')));
                    
                }
                else if((parseFloat(amt) >= parseFloat(cmp.get('v.myCurrency'))) && parseFloat(cmp.get('v.TotalCreditAmount')) == 0) {

                        cmp.set('v.TotalAppliedAmount',cmp.get('v.myCurrency'));  
                        cmp.set("v.TotalUnallocatedAmount", parseFloat(cmp.get('v.myCurrency'))- cmp.get('v.TotalAppliedAmount'));
                    
                }else if(parseFloat(amt) >= (parseFloat(cmp.get('v.myCurrency')) + parseFloat(cmp.get('v.TotalCreditAmount')))) {

                        cmp.set('v.TotalAppliedAmount',cmp.get('v.myCurrency'));  
                        cmp.set("v.TotalUnallocatedAmount", parseFloat(cmp.get('v.myCurrency'))- cmp.get('v.TotalAppliedAmount'));
                    
                }else{
                    cmp.set('v.TotalAppliedAmount',parseFloat(amt) - parseFloat(cmp.get('v.TotalCreditAmount')));
                    cmp.set("v.TotalUnallocatedAmount", parseFloat(cmp.get('v.myCurrency')) - cmp.get('v.TotalAppliedAmount'));
                }
            }else{
                cmp.set('v.TotalAppliedAmount',0);  
                cmp.set("v.TotalUnallocatedAmount",0);    
            }
           
        }   
            else if(cmp.find('payReason').get('v.value') ==''){ 
                cmp.set('v.disableCheckbox',false); 
            } 
        
        helper.registerThePaymentButtonHandler(cmp);
    },
        addDiscountButtonHandler:function(cmp){
            
            var procSelected = cmp.get("v.selectedProcedures");
            console.log('procSelected***',procSelected);
            if(procSelected.length > 0){
            for(var i=0;i<procSelected.length;i++){
                console.log('inside loop4***',procSelected[i].otherDiscount);
                if(procSelected[i].otherDiscount > 0){
                    cmp.set("v.makeDiscountButtonDisable",false);
                }
            }
        }
            else{
                cmp.set("v.makeDiscountButtonDisable",true);
            }
        },
        registerThePaymentButtonHandler:function(cmp){
            let isModeOfPaymentEmpty = cmp.get("v.modeOfPayment")!='';
            let isReasonEmpty=cmp.get("v.payReasonVal")!='';
            let isAmountPaidPositive=cmp.get("v.myCurrency")>0;
            let isProcedureOrClaimSelected=cmp.get("v.payReasonVal")=='Unallocated Payment'?true:cmp.get("v.selectedProcedures").length>0;
            let isDateEmpty=cmp.get("v.Tdate")!='';
            let creditMemo=cmp.get("v.creditMemoSelectedRows").length;
            let discButtAct=cmp.get("v.makeDiscountButtonDisable");
            if(creditMemo>0 && isProcedureOrClaimSelected && discButtAct){
                cmp.set("v.makePaymentButtonDisable",false);
            }else{
                 if(isModeOfPaymentEmpty && isReasonEmpty && isAmountPaidPositive && isProcedureOrClaimSelected && isDateEmpty && discButtAct){
                cmp.set("v.makePaymentButtonDisable",false);
                }
                else if(isModeOfPaymentEmpty && isAmountPaidPositive && isProcedureOrClaimSelected && discButtAct){
                    cmp.set("v.makePaymentButtonDisable",false);
                }
                else{
                        cmp.set("v.makePaymentButtonDisable",true);
                    }
            }
           
        },
        
    checkRequieredValidity :  function(cmp,event,helper){
        var isValid = true;
        let modeOfPayment = cmp.get("v.modeOfPayment");
        let creditSelectedRow = cmp.get("v.creditSelectedRows");
        let payReason = cmp.get("v.payReasonVal");
        let checkNumber = cmp.get("v.chequeNo");
         if(modeOfPayment=='Credit Card' && creditSelectedRow.length<=0){
                helper.globalFlagToast(cmp, event, helper,'Select a Credit card!', ' ','error');  
                isValid = false;
            }
        else if(modeOfPayment=='Cheque' && !checkNumber){
                helper.globalFlagToast(cmp, event, helper,'Cheque number is mandatory!', ' ','error');  
                isValid = false;
            }
        else if(payReason && !modeOfPayment){
                helper.globalFlagToast(cmp, event, helper,'Mode of Payment is mandatory!', ' ','error');  
                isValid = false;
            }

        
        return isValid;
    },
        
    globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
        
    addDiscountHelper : function(cmp, event, helper){
            
            
        var action = cmp.get("c.addDiscount");
        action.setParams({
                          acctId : cmp.get("v.recordId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedures")}),
 			});     
            action.setCallback(this, function(response) {
                var state = response.getState();
                var wrapRes = response.getReturnValue();
                if (state === "SUCCESS") {
                    if(wrapRes == 'completed'){
                    helper.globalFlagToast(cmp, event, helper,'Discount Added!', ' ','success');
                }
                    $A.get('e.force:refreshView').fire();
                    console.log('addDiscount227***');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                        }
                    }
                }
                });
        $A.enqueueAction(action);  
        },
        
    savePayments : function(cmp, event, helper){
        
        console.log('modeOfPayment***',cmp.get("v.modeOfPayment"));
        var noProcedureSelected = false;
        //console.log("noProcedureSelected:", noProcedureSelected);
        var sizeOfLst = cmp.get("v.selectedProcedures").length;
        console.log("sizeOfLst:", sizeOfLst);
        if(sizeOfLst==0){ 
            noProcedureSelected = true; 
       }

        console.log('creditMemoSelectedRows',cmp.get("v.creditMemoSelectedRows"));
        var action = cmp.get("c.makePayment");
        action.setParams({amountPaid : parseFloat(cmp.get("v.myCurrency")),
                          modeOfPayment : cmp.get("v.modeOfPayment"),
                          dateOfPmt : cmp.get("v.Tdate"),
                          reasonForPayment : cmp.get("v.payReasonVal"),
                          note :  cmp.get("v.addNote"),
                          pmtTransactionNumber : cmp.get("v.TNumber"),
                          acctId : cmp.get("v.recordId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedures")}),
                          totalAppliedAmount : parseFloat(cmp.get("v.TotalAppliedAmount")),
                          totalUnAllocatedAmount : parseFloat(cmp.get("v.TotalUnallocatedAmount")),
                          totalCreditAmount : parseFloat(cmp.get("v.TotalCreditAmount")),
                          noProcedureSelected : noProcedureSelected,
                          paymentInfoId : cmp.get("v.creditCardId"), 
                          chequeNo : cmp.get("v.chequeNo"),
                          creditMemo :  cmp.get("v.creditMemoSelectedRows"),
 			});     
            action.setCallback(this, function(response) {
                var state = response.getState();
                var wrapRes = response.getReturnValue();
                console.log('wrapRes***',wrapRes);
                if (state === "SUCCESS") {   
                if(wrapRes.msgState=='Success'){
                    if(cmp.get('v.generateReceipt') == true){
                        if( cmp.get('v.payReasonVal') == 'Applied Payment'){
                            
                            var url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+wrapRes.msgStr;
                            var newWindow;	
                            newWindow = window.open(url);	
                            newWindow.focus();	
                            //window.open('/apex/GenerateUpfrontPaymentReceipt?amountPaid='+cmp.get('v.myCurrency')+'&patientId='+cmp.get('v.PatientId')+'&paymentDate='+cmp.get('v.Tdate'));
                        }
                    }
                    else {
                        helper.globalFlagToast(cmp, event, helper,'PAYMENT REGISTERED!', ' ','success');
                    }
                    $A.get('e.force:refreshView').fire();
                    //helper.resetData(cmp, event, helper);
                }
                
			if(wrapRes.msgState=='URL'){
                if(wrapRes.msgStr!=''){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": wrapRes.msgStr,
                        "isredirect": true
                    });
                    urlEvent.fire();
                }
                else{
                    helper.globalFlagToast(cmp, event, helper,'URL not configured!', ' ','error');
                }
            }
                    
                    if(wrapRes.msgState=='Error'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": wrapRes.msgStr,
                            "type" : "error",
                            "mode" : "dismissible"
                        });
                        toastEvent.fire();
                        cmp.set("v.loaded",false);
                        return;
                    }
                    
                }
                
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                        }
                    }
                }
                
            });
        $A.enqueueAction(action);  
        },
})