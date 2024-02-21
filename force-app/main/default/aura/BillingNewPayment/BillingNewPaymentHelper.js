({
    
    
    // Dynamic creation of div for dropdown list
    dynamicCreation : function(component, recordsList, fieldName) {
        var recordId = 'record-'+component.get('v.uniqueId');
        var recordDiv = document.getElementById(recordId);
        var li;
        while (recordDiv.firstChild) recordDiv.removeChild(recordDiv.firstChild);
        
        if(Array.isArray(recordsList) && recordsList.length) {
            const len = recordsList.length;
            for(let k = 0; k<len; k++) {
                li = document.createElement("li");
                li.id = recordsList[k].Id;
                li.appendChild(document.createTextNode(recordsList[k][fieldName]));
                recordDiv.appendChild(li);
            }
        } else {
            li = document.createElement("li");
            li.id = '';
            li.appendChild(document.createTextNode(recordsList));
            recordDiv.appendChild(li);
        }
    },
    calculateTotalUnAllocated : function(component, event, dataArray) {
        
        console.log('Patient Data ------');
        console.log(JSON.stringify(dataArray));
        console.log(dataArray.ElixirSuite__Unallocated_Amount__c);
        /*
        var getNumbersToAdd = [];
        for(var key in dataArray){
            if(!$A.util.isUndefinedOrNull(dataArray[key].Total_Unallocated_Amount__c)){
                getNumbersToAdd.push(parseInt(dataArray[key].Total_Unallocated_Amount__c));
            }
        }
        var sum = getNumbersToAdd.reduce(function(a, b){
            return a + b;
        }, 0);
        */
        if(dataArray.ElixirSuite__Unallocated_Amount__c == null || dataArray.ElixirSuite__Unallocated_Amount__c == 0 || dataArray.ElixirSuite__Unallocated_Amount__c == undefined)
        {	
            console.log('Inside if');
            component.set("v.totalUnAllocatedAmount", 0);
        }
        else
        {
            console.log('Inside else');
            component.set("v.totalUnAllocatedAmount", dataArray.ElixirSuite__Unallocated_Amount__c);
        }
    },
    
    displayDetails : function(cmp, event, accId)
    {
        console.log('#### accId : ' + accId);
        cmp.set("v.amountAllocated",0); //Anusha
        if(accId == null || accId == "")
        {
            cmp.set("v.PatientId", ""); 
            cmp.set("v.Allocate",false);
            if(cmp.get("v.value")=='Allocate Payments'){
                cmp.set("v.AllocPay",true); //Modified by Anusha from false to true LX3-5599 
            }
            cmp.set("v.totalUnAllocatedAmount",0.0); //Anusha LX3-5599
            cmp.set("v.Patient","");
            cmp.set("v.Infolist","");
            cmp.set("v.PaySchedulist","");
            cmp.set("v.Plist","");
            cmp.find('select1').set('v.value','');
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false);
            cmp.set("v.payReasonVal",""); //Anusha - Start
            cmp.set("v.myCurrency",0.0);
            cmp.set("v.TNumber","");
            cmp.set("v.addNote","");
            cmp.set("v.creditCardId","");
            cmp.set("v.generateReceipt",false);
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var yyyy = today.getFullYear();
            today = yyyy +'-'+ mm +'-' + dd ;
            cmp.set("v.Tdate",today);//Anusha -End
        }
        else if(accId != null && accId != "")
        {
            console.log('in else block odf display details');
            cmp.set("v.Allocate",true);
            var action = cmp.get("c.getData");
            action.setParams({accid:cmp.get("v.PatientId")
                             });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    console.log('result ----- ' + JSON.stringify(result));
                    //console.log(result);
                    
                    // this.calculateTotalUnAllocated(cmp, event, response.getReturnValue().patientData);
                    console.log('patientData ----- ' +  JSON.stringify(response.getReturnValue().patientData));
                    //console.log(response.getReturnValue().patientData);
                    cmp.set("v.Patient",response.getReturnValue().patientData);
                    cmp.set("v.plugData",response.getReturnValue().plugDataPresent);
                    let today = new Date();
                    let filteredRecords = [];
                    if(response.getReturnValue().payInfo != undefined){
                        response.getReturnValue().payInfo.forEach((record) => {
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
                    
                    cmp.set("v.Infolist", filteredRecords);
                    
                    // cmp.set("v.Infolist",response.getReturnValue().payInfo);
                    console.log('Infolist--'+ JSON.stringify(filteredRecords))
                }
                
                cmp.set("v.PaySchedulist",response.getReturnValue().lstPaySchedule);
                
                var allData =response.getReturnValue().procData;
                var count = 1;
                for(var recdata1 in response.getReturnValue().procData){
                    allData[recdata1]['SNo'] = count+'.';
                    allData[recdata1]['InsuranceOutstanding'] = allData[recdata1].ElixirSuite__Insurance_Responsibility__c - (allData[recdata1].ElixirSuite__Insurance_Payments__c);
                    //allData[recdata]['RemaningAmount']= allData[recdata1].Actual_Price__c - allData[recdata].Received_Amount__c;
                    if('ElixirSuite__Claim__c' in allData[recdata1].ElixirSuite__Procedure__r)
                    {
                        allData[recdata1]['Claim'] = '/'+allData[recdata1].ElixirSuite__Procedure__r.ElixirSuite__Claim__c;
                        allData[recdata1]['ClaimName']  = allData[recdata1].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                    }
                    
                    count = count + 1;
                }
                console.log('trans---'+JSON.stringify(response.getReturnValue().procData));
                cmp.set("v.Plist",response.getReturnValue().procData);
                
                //Mamta Added Code
                //
                //
                
                cmp.set("v.totalUnAllocatedAmount",response.getReturnValue().totalRemainingUnallocatedAmount);
                var allDataInsurance =response.getReturnValue().procDataForInsurancePayment;
                var count2 = 1;
                for(var recdata in response.getReturnValue().procDataForInsurancePayment){
                    allDataInsurance[recdata]['SNo'] = count2+'.';
                    allDataInsurance[recdata]['ProcedureCode'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.Name;
                    if(allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__r!=null){
                        allDataInsurance[recdata]['ProcedureClaim'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                    }
                     if(allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Status__c!=null){
                        allDataInsurance[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                    }
                    if(allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c == true){
                        
                        allDataInsurance[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c'] = 'Yes';
                        
                    }else if(allDataInsurance[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c == false){
                        
                        allDataInsurance[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c'] = 'No';
 
                    }
                    
                    count2 = count2 + 1;
                }
                console.log('trans---'+JSON.stringify(response.getReturnValue().procDataForInsurancePayment));
                cmp.set("v.PInsurancePaylist",response.getReturnValue().procDataForInsurancePayment);
                
            }
                               
                               });
            $A.enqueueAction(action);
        }
        
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.PInsurancePaylist");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        component.set("v.PInsurancePaylist",data);
    },
    checkRequieredValidity :  function(cmp,event,helper){
        var isValid = true;
        let modeOfPayment = cmp.get("v.modeOfPayment");
        let amountPaid = cmp.get("v.myCurrency");
        let dateOfPayment = cmp.get("v.Tdate");
        let payReason = cmp.get("v.payReasonVal");
        let creditSelectedRow = cmp.get("v.creditSelectedRows");
        let checkNumber = cmp.get("v.chequeNo");
        if(!modeOfPayment){
            helper.globalFlagToast(cmp, event, helper,'MODE OF PAYMENT IS MANDATORY!', ' ','error');  
            isValid = false;
        }
        else if(!cmp.get("v.plugData")){
            if(modeOfPayment=='Credit Card' && creditSelectedRow.length<=0){
                helper.globalFlagToast(cmp, event, helper,'Select a credit card!', ' ','error');  
                isValid = false;
            }
        }
            else if(modeOfPayment=='Cheque' && !checkNumber){
                helper.globalFlagToast(cmp, event, helper,'Cheque number is mandatory!', ' ','error');  
                isValid = false;
            }
                else if(!payReason){
                    helper.globalFlagToast(cmp, event, helper,'REASON IS MANDATORY!', ' ','error');  
                    isValid = false;
                }
                    else if(!dateOfPayment){
                        helper.globalFlagToast(cmp, event, helper,'DATE OF PAYMENT IS MANDATORY!', ' ','error');  
                        isValid = false;
                    }
                        else if(!amountPaid){
                            helper.globalFlagToast(cmp, event, helper,'AMOUNT PAID IS MANDATORY!', ' ','error');  
                            isValid = false;
                        }
                            else if(parseInt(amountPaid)==0){
                                helper.globalFlagToast(cmp, event, helper,'AMOUNT PAID CANNOT BE ZERO!', ' ','error'); 
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
    fetchERASettings : function(cmp){
        var action = cmp.get("c.getERASetting");
        action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            var optionsForPrivatePayment=[];
            var arr = [];
            optionsForPrivatePayment.push({'label': 'Register Payment', 'value': 'Register a Payment'});
            optionsForPrivatePayment.push({'label': 'Allocate Payments', 'value': 'Allocate Payments'});
            if(resp.ElixirSuite__Payment_Schedule_for_Private_Payment__c == true){
                optionsForPrivatePayment.push({'label': 'Payment Plan', 'value': 'Payment schedule'});
            }
            if(resp.ElixirSuite__Adding_Discount_Allocating_Discount__c == true){
                optionsForPrivatePayment.push({'label': 'Add Discount', 'value': 'Add Discount'});
                optionsForPrivatePayment.push({'label': 'Allocate Discount', 'value': 'Allocate Discount'});
            }
            if(resp.ElixirSuite__Private_Payments__c == true && resp.ElixirSuite__Insurance_Payments__c ==true){
                arr.push({'label' : 'Insurance Payment', 'value' : 'Insurance Payment'});
                arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
                arr.push({'label' : 'Manage Refunds', 'value' : 'Manage Refunds'});
                
                cmp.set("v.typeOfPayment",'Insurance Payment');
                var forclose = cmp.find("paymentTypeAura");
                $A.util.removeClass(forclose, 'slds-hide');
                $A.util.addClass(forclose, 'slds-show');
                cmp.set("v.paymentTypeList",arr); 
                
            }
            if(resp.ElixirSuite__Private_Payments__c == false && resp.ElixirSuite__Insurance_Payments__c ==true){
                arr.push({'label' : 'Insurance Payment', 'value' : 'Insurance Payment'});
                arr.push({'label' : 'Manage Refunds', 'value' : 'Manage Refunds'});
                
                cmp.set("v.typeOfPayment",'Insurance Payment');
                var forclose1 = cmp.find("paymentTypeAura");
                $A.util.removeClass(forclose1, 'slds-hide');
                $A.util.addClass(forclose1, 'slds-show');
                cmp.set("v.paymentTypeList",arr); 
            }
            if(resp.ElixirSuite__Private_Payments__c == true && resp.ElixirSuite__Insurance_Payments__c ==false){
                arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
                arr.push({'label' : 'Manage Refunds', 'value' : 'Manage Refunds'});
                
                cmp.set("v.typeOfPayment",'Private Payment');
                var forclose2 = cmp.find("paymentTypeAura");
                $A.util.removeClass(forclose2, 'slds-hide');
                $A.util.addClass(forclose2, 'slds-show');
                cmp.set("v.paymentTypeList",arr); 
            }
            cmp.set("v.optionsForPrivatePayment",optionsForPrivatePayment);
        });
        $A.enqueueAction(action);
    },
    navigateToRecordDetail: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        var procrecordId = row['ElixirSuite__Procedure__c'];
        
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: procrecordId,
                objectApiName: 'ElixirSuite__Procedure__c',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    },
    savePayments : function(cmp, event, helper){
        
        console.log('modeOfPayment***',cmp.get("v.modeOfPayment"));
        var noProcedureSelected = false;
        console.log("noProcedureSelected:", noProcedureSelected);
        var sizeOfLst = cmp.get("v.selectedInsurancePaylist").length;
        
        if(sizeOfLst==0 && cmp.get('v.toggleValue')!='By Claims'){  //Added AND condition by Anusha -04/10/22
            noProcedureSelected = true; 
        }
        //Added below lines by Anusha -04/10/22 -Start
        var sizeOfClaimList = cmp.get("v.PayTransId").length;
        console.log('AAAA '+cmp.get("v.PayTransId").length);
        var procsFromClaimList =[];
        if(cmp.get('v.toggleValue')=='By Claims'){
            if(sizeOfClaimList==0){
                noProcedureSelected = true; 
            } 
            cmp.get("v.ClaimsList").forEach((item)=>{
                item.procWrap.forEach((innerItem)=>{
                console.log("innerItem"+JSON.stringify(innerItem));
                if(innerItem.Selected==true){
                procsFromClaimList.push(innerItem);
            }
            })
            })
            } //Anusha -04/10/22 -End
                //cmp.set("v.loaded",false);
                cmp.set("v.showConfirmDialog",false); 
                var action = cmp.get("c.makeInsurancePayment");
                console.log('modeOfPayment***',cmp.get("v.modeOfPayment"));
                action.setParams({amountPaid : parseFloat(cmp.get("v.myCurrency")),
                modeOfPayment : cmp.get("v.modeOfPayment"),
                dateOfPmt : cmp.get("v.Tdate"),
                reasonForPayment : cmp.get("v.payReasonVal"),
                note :  cmp.get("v.addNote"),
                pmtTransactionNumber : cmp.get("v.TNumber"),
                acctId : cmp.get("v.PatientId"),
                //Added condition check by Anusha -04/10/22
                selectedProcedureRecords : cmp.get('v.toggleValue')!='By Claims'?JSON.stringify({'procedures' : cmp.get("v.selectedInsurancePaylist")}):JSON.stringify({'procedures' : procsFromClaimList}),
                //selectedProcedureRecords : JSON.stringify({'procedures' : procsFromClaimList}),
                totalAppliedAmount : parseFloat(cmp.get("v.TotalAppliedAmountInsurance")),
                totalUnAllocatedAmount : parseFloat(cmp.get("v.TotalUnallocatedAmountInsurance")),
                noProcedureSelected : noProcedureSelected,
                paymentInfoId : cmp.get("v.creditCardId"), // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280 
                chequeNo : cmp.get("v.chequeNo"),
 });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                var wrapRes = response.getReturnValue();
                console.log('wrapRes***',wrapRes);
                if (state === "SUCCESS") {   
                if(wrapRes.msgState=='Success'){
                    cmp.set("v.loaded",true); 
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
                    if(!cmp.get("v.isPaymentTab")){ //Anusha LX3-5667 start
                        cmp.set("v.isModalOpen", true); //Anusha modified false to true - LX3-5747
                        helper.resetData(cmp, event, helper); //Anusha LX3-5747
                        helper.displayDetails(cmp, event, helper); //Anusha added - LX3-5747
                    } //Anusha LX3-5667 end
                    $A.get('e.force:refreshView').fire(); //added by anusha LX3-5526
                    // $A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire();//Lokesh Added
                    helper.resetData(cmp, event, helper);
                }
                
if(wrapRes.msgState=='URL'){
                    if(wrapRes.msgStr!=''){
                        window.open(wrapRes.msgStr,'_top');
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
            saveAllocatedPayments : function(cmp, event, helper){
                
                
                var noProcedureSelected = false;
                console.log('noProcedureSelected: ', noProcedureSelected);
                
                var sizeOfLst = cmp.get("v.selectedInsurancePaylist").length;
                console.log('sizeOfLst: ', sizeOfLst);
                
                if(sizeOfLst==0  && cmp.get('v.toggleValue')!='By Claims'){
                    noProcedureSelected = true; 
                }
                
                var sizeOfClaimList = cmp.get("v.PayTransId").length;
                var procsFromClaimList =[];
                if(cmp.get('v.toggleValue')=='By Claims'){
                    if(sizeOfClaimList==0){
                        noProcedureSelected = true; 
                    } 
                    cmp.get("v.ClaimsList").forEach((item)=>{
                        item.procWrap.forEach((innerItem)=>{
                        console.log("innerItem"+JSON.stringify(innerItem));
                        if(innerItem.Selected==true){
                        procsFromClaimList.push(innerItem);
                    }
                    })
                    })
                    }
                        
                        
                        
                        // cmp.set("v.loaded",false); 
                        cmp.set("v.showConfirmDialog",false); 
                        var action = cmp.get("c.makeAllocatePayment");
                        
                        
                        action.setParams({
                        amountPaid : parseFloat(cmp.get("v.amountAllocated")),
                        acctId : cmp.get("v.PatientId"),
                        selectedProcedureRecords : cmp.get('v.toggleValue')!='By Claims'?JSON.stringify({'procedures' : cmp.get("v.selectedInsurancePaylist")}):JSON.stringify({'procedures' : procsFromClaimList}),
                        totalAppliedAmount : parseFloat(cmp.get("v.TotalAppliedForAllocatePayment")),
                        totalRemainingUnAllocatedAmt : parseFloat(cmp.get("v.TotalUnallocatedForAllocatePayment")),
                    });     
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.log('state: ', state);
                        
                        if (state === "SUCCESS") {   
                            
                            cmp.set("v.loaded",true); 
                            
                            helper.globalFlagToast(cmp, event, helper,'PAYMENT REGISTERED!', ' ','success');  
                            if(!cmp.get("v.isPaymentTab")){ //Anusha LX3-5667 start
                                cmp.set("v.isModalOpen", true); //Anusha modified false to true - LX3-5747
                                helper.resetData(cmp, event, helper); //Anusha LX3-5747
                                helper.displayDetails(cmp, event, helper); //Anusha added - LX3-5747
                            } //Anusha LX3-5667 end
                            $A.get('e.force:refreshView').fire(); //added by anusha LX3-5526
                            //$A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire();// Lokesh Added
                        }
                        
                    });
                    $A.enqueueAction(action);  
                },
                    //registerThePaymentButtonHandler function added by Anusha - 30/09/2022
                    registerThePaymentButtonHandler:function(cmp){
                        let isModeOfPaymentEmpty = cmp.get("v.modeOfPayment")!='';
                        let isReasonEmpty=cmp.get("v.payReasonVal")!='';
                        let isAmountPaidPositive=cmp.get("v.myCurrency")>0;
                        let isProcedureOrClaimSelected=cmp.get("v.payReasonVal")=='Unallocated Payment'?true:cmp.get("v.PayTransId").length>0 || cmp.get("v.NoOfClaimsSelected")>0; //Added 'Unalloacted payment'condition check on 03/10/22 -Anusha
                        let isDateEmpty=cmp.get("v.Tdate")!='';
                        if(isModeOfPaymentEmpty && isReasonEmpty && isAmountPaidPositive && isProcedureOrClaimSelected && isDateEmpty){
                            cmp.set("v.makePaymentButtonDisable",false);
                        }
                        else if(isModeOfPaymentEmpty && isAmountPaidPositive && isProcedureOrClaimSelected){
                            cmp.set("v.makePaymentButtonDisable",false);
                        }
                            else{
                                cmp.set("v.makePaymentButtonDisable",true);
                            }
                    },
                        //resetData function Created by Anusha - LX3-5747
                        resetData:function(cmp){
                            cmp.set("v.modeOfPayment",'');
                            cmp.set("v.payReasonVal",'');
                            cmp.set("v.myCurrency",0.0);
                            cmp.set("v.TNumber",'');
                            cmp.set("v.addNote",'');
                            cmp.set("v.toggleValue",'By Procedure');
                            cmp.set("v.hideOrShowClaims",false);
                            cmp.set("v.makePaymentButtonDisable",true);
                            cmp.set("v.allocatePaymentButtonDisable", true);
                            cmp.set("v.TotalAppliedAmountInsurance",0);
                            cmp.set("v.TotalUnallocatedAmountInsurance",0);
                            cmp.set("v.amountAllocated",0);
                            cmp.set("v.selectedRowsOfProc", []);
                            cmp.set("v.TotalAppliedForAllocatePayment",0);
                            cmp.set("v.TotalUnallocatedForAllocatePayment",0);
                            cmp.set("v.disableCheckbox",false);
                            cmp.set('v.selectedInsurancePaylist',[]);
                            cmp.set("v.PayTransId",[]);
                            cmp.set("v.patOutStndAmount",false);
                            cmp.set("v.patOutStndAmountRegister",false);
                            cmp.get("v.ClaimsList",[]);
                            cmp.set("v.showConfirmDialog",false);   
                            cmp.set("v.showConfirmDialogForAllocatePayment",false);
                            cmp.set("v.chequeNo",'');
                            cmp.set("v.cheque",false);
                            cmp.set("v.Credit",false);
                        },
                            //Anusha LX3-5820
                            getFormSetting : function(cmp){
                                var action = cmp.get("c.getDisplaySetting");
                                action.setCallback(this, function(response){
                                    var resp=response.getReturnValue();
                                    console.log("enabledForm"+resp);
                                    if(resp=='disableButton'){
                                        var arr = [];
                                        
                                        arr.push({'label' : 'Private Payment', 'value' : 'Private Payment'});
                                        arr.push({'label' : 'Manage Refunds', 'value' : 'Manage Refunds'});
                                        
                                        cmp.set("v.typeOfPayment",'Private Payment');
                                        var forclose = cmp.find("paymentTypeAura");
                                        $A.util.removeClass(forclose, 'slds-hide');
                                        $A.util.addClass(forclose, 'slds-show');
                                        cmp.set("v.paymentTypeList",arr); 
                                    }
                                });
                                $A.enqueueAction(action);
                            },
                                calOnReason : function(cmp, event, helper)
                {
                     var ClaimsList;
                    var ProcWrapList;
                    var amt =0;
                    if(cmp.find('payReason').get('v.value')=='Unallocated Payment'){
                        cmp.set('v.generateReceipt',false);
                        cmp.set('v.disableCheckbox',true);
                        ClaimsList = cmp.get("v.ClaimsList");
                        //var totalAmount = cmp.get('v.AmountDue');
                        var selectedIds = [];
                        
                        for(var i in ClaimsList)
                        {
                            if('procWrap' in ClaimsList[i])
                            {
                                ProcWrapList = ClaimsList[i].procWrap;
                                for(var j in ProcWrapList)
                                {
                                    ProcWrapList[j].Selected = false;
                                }
                                ClaimsList[i].Selected = false;
                            }
                        }
                        cmp.set('v.selectedInsurancePaylist',[]);
                        cmp.set('v.ClaimsList',ClaimsList);
                        cmp.set('v.AmountDue',0);
                        cmp.set("v.PayTransId",selectedIds);
                        
                        
                        if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
                        {
                            amt =0;
                            cmp.set("v.makePaymentButtonDisable", false);
                            cmp.set("v.TotalAppliedAmountInsurance", amt);
                            cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.myCurrency') - amt);
                        }else{
                            cmp.set("v.TotalAppliedAmountInsurance", 0);
                            cmp.set("v.TotalUnallocatedAmountInsurance", 0);  
                        }
                    }
                    else if(cmp.find('payReason').get('v.value')=='Applied Payment')
                    {
                        //cmp.set('v.generateReceipt',false);
                        cmp.set('v.disableCheckbox',false);
                        cmp.set("v.patOutStndAmountRegister",false);
                        amt =0;
                        var rowList;
                        rowList = cmp.get('v.selectedInsurancePaylist');
                        if(cmp.get('v.toggleValue')!='By Claims'){ 
                            if(rowList.length > 0){
                                
                                cmp.set("v.makePaymentButtonDisable", false);
                                
                                
                                for(var c=0; c<rowList.length; c++){
                                    if(rowList[c].ElixirSuite__PatientOutstanding__c > 0){
                                        amt+=rowList[c].ElixirSuite__PatientOutstanding__c;
                                    }else{
                                        cmp.set("v.patOutStndAmountRegister",true);
                                    }
                                }
                            }else{
                                cmp.set("v.makePaymentButtonDisable", true);
                            }
                            if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
                            {
                                if(parseFloat(amt) > parseFloat(cmp.get('v.myCurrency'))){
                                    cmp.set('v.TotalAppliedAmountInsurance',cmp.get('v.myCurrency'));   
                                }else{
                                    cmp.set('v.TotalAppliedAmountInsurance',parseFloat(amt));  
                                }
                                cmp.set("v.TotalUnallocatedAmountInsurance", parseFloat(cmp.get('v.myCurrency')) - cmp.get('v.TotalAppliedAmountInsurance'));
                            }else{
                                cmp.set('v.TotalAppliedAmountInsurance',0);  
                                cmp.set("v.TotalUnallocatedAmountInsurance",0);    
                            }
                            
                            //cmp.set("v.TotalAppliedAmountInsurance", amt);
                            
                            cmp.set("v.NoOfClaimsSelected",0);
                        }
                        
                        else if(cmp.get('v.toggleValue')=='By Claims'){
                            
                            ClaimsList = cmp.get("v.ClaimsList");
                            cmp.set("v.patOutStndAmountRegister",false);
                            var sumOfAmountPaid = 0;
                            if(cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
                            {
                                cmp.set("v.makePaymentButtonDisable", false);
                            }
                            for(var a in ClaimsList)
                            {
                                if('procWrap' in ClaimsList[a])
                                {
                                    ProcWrapList = ClaimsList[a].procWrap;
                                    for(var b in ProcWrapList)
                                    {
                                        if(ProcWrapList[b].Selected)
                                        {
                                            sumOfAmountPaid+=ProcWrapList[b].patientOutstanding>0?ProcWrapList[b].patientOutstanding:0; //Anusha 04/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                            if(ProcWrapList[b].patientOutstanding <= 0){
                                                cmp.set("v.patOutStndAmountRegister",true);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            if((cmp.get('v.payReasonVal') == 'Applied Payment' ) && (cmp.get('v.value') == 'Make a Payment' )) 
                            {
                                if(cmp.get("v.myCurrency") != null && cmp.get("v.myCurrency") != 0){
                                    if(parseFloat(sumOfAmountPaid) > parseFloat(cmp.get('v.myCurrency'))){
                                        
                                        cmp.set('v.TotalAppliedAmountInsurance',cmp.get('v.myCurrency'));   
                                    }else{
                                        cmp.set('v.TotalAppliedAmountInsurance',parseFloat(sumOfAmountPaid)); 
                                    }
                                    cmp.set("v.TotalUnallocatedAmountInsurance", parseFloat(cmp.get('v.myCurrency')) - parseFloat(cmp.get('v.TotalAppliedAmountInsurance'))); 
                                }else{
                                    cmp.set('v.TotalAppliedAmountInsurance',0);
                                    cmp.set("v.TotalUnallocatedAmountInsurance", 0);   
                                }
                            }
                            
                        }
                        
                    }
                        else if(cmp.find('payReason').get('v.value') !='')
                        {
                            cmp.set('v.disableCheckbox',false);
                            if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
                            {
                                //Mamta Added
                                cmp.set("v.TotalAppliedAmountInsurance", cmp.get('v.myCurrency'));
                                cmp.set("v.TotalUnallocatedAmountInsurance", 0);
                            }else{
                                cmp.set("v.TotalAppliedAmountInsurance", 0);
                                cmp.set("v.TotalUnallocatedAmountInsurance", 0);  
                            }
                            
                            rowList = cmp.get('v.selectedInsurancePaylist');
                            if(cmp.get('v.toggleValue')!='By Claims'){
                                cmp.set("v.patOutStndAmountRegister",false);
                                if(rowList.length > 0){
                                    for(var y=0; y<rowList.length; y++){
                                        cmp.set("v.patOutStndAmountRegister",true);
                                    }
                                }
                            }else if(cmp.get('v.toggleValue')=='By Claims'){
                                
                                
                                ClaimsList = cmp.get("v.ClaimsList");
                                cmp.set("v.patOutStndAmountRegister",false);
                                
                                for(var x in ClaimsList)
                                {
                                    if('procWrap' in ClaimsList[x])
                                    {
                                        	ProcWrapList = ClaimsList[x].procWrap;
                                        for(var z in ProcWrapList)
                                        {
                                            if(ProcWrapList[z].Selected && ProcWrapList[z].patientOutstanding <= 0)
                                            {
                                                cmp.set("v.patOutStndAmountRegister",true);
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            
                            
                        }
                            else if(cmp.find('payReason').get('v.value') ==''){ 
                                cmp.set('v.disableCheckbox',false); 
                            } //Anusha-03/10/22
                    helper.registerThePaymentButtonHandler(cmp, event, helper);
                },
                    
                    calOnReasonForAllocate : function(component, event, helper)
                {
                    
                    if(component.get('v.value') == 'Allocate Payments'){
                        if(component.get('v.toggleValue')!='By Claims'){
                            var rowList = component.get('v.selectedInsurancePaylist');
                            var amt = 0;
                            if(rowList.length >0){
                                component.set("v.patOutStndAmount", false);
                                for(var a =0;a< rowList.length; a++){
                                    if(!$A.util.isUndefinedOrNull(rowList[a].ElixirSuite__PatientOutstanding__c)){
                                        if(rowList[a].ElixirSuite__PatientOutstanding__c > 0){
                                            amt+=rowList[a].ElixirSuite__PatientOutstanding__c;
                                        }else{
                                            component.set("v.patOutStndAmount", true);
                                        }
                                    }
                                    
                                }
                                if(component.get('v.amountAllocated')!=null && component.get('v.amountAllocated')!= 0 && parseInt(component.get('v.amountAllocated')) > 0){
                                    if(parseFloat(amt) > parseFloat(component.get('v.amountAllocated'))){
                                        component.set('v.TotalAppliedForAllocatePayment',component.get('v.amountAllocated'));   
                                    }else{
                                        component.set('v.TotalAppliedForAllocatePayment',parseFloat(amt)); 
                                    }
                                    component.set("v.TotalUnallocatedForAllocatePayment", parseFloat(component.get('v.amountAllocated')) -  parseFloat(component.get('v.TotalAppliedForAllocatePayment')));
                                }else{
                                    component.set('v.TotalAppliedForAllocatePayment',0);
                                    component.set("v.TotalUnallocatedForAllocatePayment", 0);
                                }
                                
                            }else{
                                component.set("v.selectedInsurancePaylist",[]);
                                component.set("v.TotalAppliedForAllocatePayment", amt);
                                component.set("v.TotalUnallocatedForAllocatePayment", component.get('v.amountAllocated') - amt);
                            }
                        }
                        else if(component.get('v.toggleValue')=='By Claims'){
                            
                            var sumOfAmountPaid = 0;
                            var ClaimsList = component.get("v.ClaimsList");
                            
                            component.set("v.patOutStndAmount", false);                   
                            for(var i in ClaimsList)
                            {
                                if('procWrap' in ClaimsList[i])
                                {
                                    var ProcWrapList = ClaimsList[i].procWrap;
                                    for(var j in ProcWrapList)
                                    {
                                        if(ProcWrapList[j].Selected)
                                        {
                                            sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; 
                                            
                                            if(ProcWrapList[j].patientOutstanding <= 0 ){
                                                component.set("v.patOutStndAmount", true);     
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            if(component.get('v.amountAllocated')!=null && component.get('v.amountAllocated')!= 0 && parseInt(component.get('v.amountAllocated')) > 0){
                                if(parseFloat(sumOfAmountPaid) > parseFloat(component.get('v.amountAllocated'))){
                                    component.set('v.TotalAppliedForAllocatePayment',component.get('v.amountAllocated'));   
                                }else{
                                    component.set('v.TotalAppliedForAllocatePayment',parseFloat(sumOfAmountPaid)); 
                                }
                                //component.set("v.TotalAppliedForAllocatePayment", sumOfAmountPaid);
                                component.set("v.TotalUnallocatedForAllocatePayment", parseFloat(component.get('v.amountAllocated')) -  parseFloat(component.get('v.TotalAppliedForAllocatePayment')));
                            }else{
                                component.set('v.TotalAppliedForAllocatePayment',0);
                                component.set("v.TotalUnallocatedForAllocatePayment", 0);
                            }
                        }
                        helper.registerAllocatePaymentButtonHandler(component, event, helper);
                    }
                    
                },
                    registerAllocatePaymentButtonHandler : function(component)
                {
                    //var totalUnAllocatedAmount = component.get("v.totalUnAllocatedAmount");
                    //var amountAllocated = component.get("v.amountAllocated");
                    var rowList = component.get('v.selectedInsurancePaylist');
                    if(parseInt(component.get('v.totalUnAllocatedAmount')) > 0 && parseFloat(component.get('v.amountAllocated')) <= parseFloat(component.get('v.totalUnAllocatedAmount')) && component.get('v.amountAllocated')!=null && component.get('v.amountAllocated')!= 0 && parseInt(component.get('v.amountAllocated')) > 0 && (rowList.length >0 || component.get("v.PayTransId").length>0) ){
                        component.set("v.allocatePaymentButtonDisable", false);   
                    }else{
                        component.set("v.allocatePaymentButtonDisable", true);   
                    }
                    
                    
                    
                }
            })