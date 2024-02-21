({
    
    
    // Dynamic creation of div for dropdown list
    dynamicCreation : function(component, recordsList, fieldName) {
        var recordId = 'record-'+component.get('v.uniqueId');
        var recordDiv = document.getElementById(recordId);
        while (recordDiv.firstChild) recordDiv.removeChild(recordDiv.firstChild);
        var li;
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
     
    },
    
    displayDetails : function(cmp, event, helper,accId)
    {
        if(accId == null || accId == "")
        {
            cmp.set("v.PatientId", ""); 
            cmp.set("v.Allocate",false);  
            cmp.set("v.AllocPay",false);
            cmp.set("v.Patient","");
            cmp.set("v.Infolist","");
            cmp.set("v.PaySchedulist","");
            // cmp.set("v.Plist","");
            cmp.find('select1').set('v.value','');
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false);
        }
        else if(accId != null && accId != "")
        {
            
            cmp.set("v.Allocate",true);    
            var action = cmp.get("c.getData");
            action.setParams({accid:cmp.get("v.PatientId")
                             });     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.calculateTotalUnAllocated(cmp, event, response.getReturnValue().patientData);
                    cmp.set("v.Patient",response.getReturnValue().patientData);
                    
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
                }
                cmp.set("v.PaySchedulist",response.getReturnValue().lstPaySchedule);
                
                var allData =response.getReturnValue().procData;
                var count = 1;
                for(var recdata in response.getReturnValue().procData){
                    allData[recdata]['SNo'] = count+'.';
                    allData[recdata]['InsuranceOutstanding'] = allData[recdata].ElixirSuite__Insurance_Responsibility__c - (allData[recdata].ElixirSuite__Insurance_Payments__c);
                    //allData[recdata]['RemaningAmount']= allData[recdata].Actual_Price__c - allData[recdata].Received_Amount__c;
                    if('ElixirSuite__Claim__c' in allData[recdata].ElixirSuite__Procedure__r)
                    {
                        allData[recdata]['Claim'] = '/'+allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__c;
                        allData[recdata]['ClaimName']  = allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                    }
                    
                    count = count + 1;
                }
                helper.initPayload(cmp, event, helper,accId);
            }
                               
                               });
            $A.enqueueAction(action);
        }
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
    initPayload : function(cmp, event, helper){
        cmp.set("v.loaded",false); 
        
        var action = cmp.get("c.queryAllProceduresOnMasterTransaction");
        action.setParams({acctId:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{
                    
                    cmp.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    let allProcedureOnMT = result.allProcedureOnMT;
                    let arr = [];
                    for(let obj in result.mapOfModeOfPayment){
                        let sObj = {'label' : obj, 'value' : result.mapOfModeOfPayment[obj]};
                        arr.push(sObj);
                    }               
                    
                    cmp.set("v.modeOfPaymentLst",arr);
                    if(!$A.util.isEmpty(allProcedureOnMT)){
                        let count = 1;
                        allProcedureOnMT.forEach(function(element) {
                            element['SNo'] = count;
                            if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                element['procedureName'] = element.ElixirSuite__Procedure__r.Name; 
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                            }
                            //helper.setRemainingAmount(cmp, event, helper,element);
                            count++;
                        }); 
                        
                        cmp.set("v.Plist",allProcedureOnMT);
                        cmp.set("v.selectedRows",[]); //Anusha - LX3-5800
                        cmp.set("v.selectedProcedureRecords",[]);
                        console.log('Plist---'+JSON.stringify(cmp.get("v.Plist")));
                    }else{
                        cmp.set("v.Plist",[]);  
                    }
                    
                    
                    cmp.set("v.customSettingData",result.customSettingData);
                    helper.setColumns(cmp, event, helper,result.customSettingData);
                    
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    setRemainingAmount : function(cmp, event, helper,element){
        if(element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && element.hasOwnProperty('ElixirSuite__Other_Discount__c')
           && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c')){
            element['remainingAmount'] = ( parseInt(element.ElixirSuite__Expected_Receivable_amount__c) - parseInt(element.ElixirSuite__Other_Discount__c) ) - parseInt(element.ElixirSuite__Total_Paid_Amount__c); 
        }
        else if(!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && (element.hasOwnProperty('ElixirSuite__Other_Discount__c')
                                                                                          && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c'))){
            element['remainingAmount'] = ( parseInt(element.ElixirSuite__Actual_Price__c) - parseInt(element.ElixirSuite__Other_Discount__c) ) - parseInt(element.ElixirSuite__Total_Paid_Amount__c); 
        }
            else if((!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && !element.hasOwnProperty('ElixirSuite__Other_Discount__c'))){
                element['remainingAmount'] =  parseInt(element.ElixirSuite__Actual_Price__c) - parseInt(element.ElixirSuite__Total_Paid_Amount__c) ; 
            }
                else if(!element.hasOwnProperty('ElixirSuite__Other_Discount__c')){
                    element['remainingAmount'] =  parseInt(element.ElixirSuite__Expected_Receivable_amount__c) - parseInt(element.ElixirSuite__Total_Paid_Amount__c) ;
                }
    },
    setColumns : function(cmp, event, helper,customSettingData){
        let otherDsc = false;
        let exptRecAmt = false;
        if(!$A.util.isUndefinedOrNull(customSettingData)){
            if(customSettingData.length>0){
                otherDsc =  customSettingData[0].ElixirSuite__Other_Discounts__c;
                exptRecAmt =  customSettingData[0].ElixirSuite__Expected_Receivable_Amount__c;
            }
            
        }
        cmp.set('v.columns',[
            {label: 'S.No', fieldName: 'SNo', cellAttributes: { alignment: 'left' },sortable :true, type: 'number'} ,
            //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}  ,
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            {label: 'CPT Code', fieldName: 'procedureName', type: 'text', sortable :true}  ,           
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true}  ,
            {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true}  ,
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true} 
            , {label: 'Remaining amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true}  ,   
            
        ]);
            let addCols =   cmp.get('v.columns');
            if(otherDsc){
            addCols.push({label: 'Other Discounts', fieldName: 'ElixirSuite__Other_Discount__c', type: 'currency',sortable :true});
            }
            if(exptRecAmt){
            addCols.push( {label: 'Expected Receivable Amount', fieldName: 'ElixirSuite__Expected_Receivable_amount__c', type: 'currency',sortable :true}  );
            } 
            
            cmp.set('v.columns',addCols);
            },
            setDefaultJSON : function(cmp){
            cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',
            'procedureId' : '','CPTCode' : ''});
            cmp.set("v.dateOfPayment",''); //Anusha LX3-5599
            cmp.set("v.amountPaid",0.0); //Anusha LX3-5599
            cmp.set("v.paymentTransactionNumber",''); //Anusha LX3-5599
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
            
            sortData : function(component,fieldName,sortDirection){
            var data = component.get("v.Plist");
            //function to return the value stored in the field
            var key = function(a) { return a[fieldName]; }
                var reverse = sortDirection == 'asc' ? 1: -1;
                
                data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        let count = 1;
        data.forEach(function(element) {
            element['SNo'] = count;
            count++;
        }); 
        component.set("v.Plist",data);
    },
    savePayments : function(cmp, event, helper){
        var noProcedureSelected = false;
        var sizeOfLst = cmp.get("v.selectedProcedureRecords").length;
        if(sizeOfLst==0){
            noProcedureSelected = true; 
        }
        cmp.set("v.loaded",false); 
        cmp.set("v.showConfirmDialog",false); 
        var action = cmp.get("c.makePrivatePayment");
        action.setParams({amountPaid : parseFloat(cmp.get("v.amountPaid")),
                          modeOfPayment : cmp.get("v.modeOfPayment"),
                          dateOfPmt : cmp.get("v.dateOfPayment"),
                          pmtTransactionNumber : cmp.get("v.paymentTransactionNumber"),
                          acctId : cmp.get("v.PatientId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedureRecords")}),
                          totalAppliedAmount : parseFloat(cmp.get("v.totalAppliedAmount")),
                          totalUnAllocatedAmount : parseFloat(cmp.get("v.totalUnAllocatedAmount")),
                          noProcedureSelected : noProcedureSelected,
                          paymentInfoId : cmp.get("v.creditCardId"), // Added ElixirSuite__Payment_Information__c by jami, required for Manage Refunds - LX3-9280 
                          chequeNo : cmp.get("v.chequeNo"),
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            var wrapRes = response.getReturnValue();
            //  var recordId = cmp.get("v.recordId");
            if (state === "SUCCESS") {   
                if(wrapRes.msgState=='Success'){
                    cmp.set("v.loaded",true); 
                    helper.globalFlagToast(cmp, event, helper,'PAYMENT REGISTERED!', ' ','success'); 
                    if(!cmp.get("v.isPaymentTab")){ //Anusha LX3-5667 start
                        cmp.set("v.isModalOpen", true); //Modified false to true by Anusha LX3-5747
                        helper.resetData(cmp, event, helper); //Anusha added LX3-5747
                        helper.displayDetails(cmp,event,helper,cmp.get("v.recordId")); //Anusha added LX3-5747
                    } //Anusha LX3-5667 end
                    $A.get('e.force:refreshView').fire(); //added by anusha LX3-5526
                }
                if(wrapRes.msgState=='URL'){
                    if(wrapRes.msgStr!=''){
                        console.log('urlupdated***upd4');
                        window.open(wrapRes.msgStr,'_top');
                    }
                    else{
                        helper.globalFlagToast(cmp, event, helper,'URL not configured!', ' ','error');
                        cmp.set("v.loaded",true);
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
                    cmp.set("v.loaded",true);
                    return;
                }
                
            }
            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                        cmp.set("v.loaded",true);
                    }
                }
            }
            
        });
        $A.enqueueAction(action);  
    },
    filterDuplicates :  function(cmp, event, helper,arr){
        const uniqueIds = [];
        const unique = arr.filter(element => {
            const isDuplicate = uniqueIds.includes(element.Id);
            if (!isDuplicate) {
            uniqueIds.push(element.Id);
            return true;
        }
                                  return false;
                                  });
        return unique;
    },
    keepSelectedProcedures : function(cmp, event, helper)
    {
        var selectedProcedureRecords = JSON.parse(JSON.stringify(cmp.get("v.selectedProcedureRecords")));
        let selectedProcedureRecordsNetInstance = cmp.get("v.selectedProcedureRecordsNetInstance");
        selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(selectedProcedureRecords);
        selectedProcedureRecordsNetInstance =  helper.filterDuplicates(cmp, event, helper,selectedProcedureRecordsNetInstance);
        cmp.set("v.selectedProcedureRecordsNetInstance",selectedProcedureRecordsNetInstance);
        var eisitngIdArr = [];
        selectedProcedureRecordsNetInstance.forEach(function(element) {
            eisitngIdArr.push(element.Id);
        }); 
        var selectedProcedureRecordsNetInstanceCopy =  cmp.get("v.selectedProcedureRecordsNetInstance");
        cmp.set("v.loaded",false);       
        var action = cmp.get("c.filterProcedureOnMasterTransaction");
        action.setParams({acctId:cmp.get("v.PatientId"),
                          eisitngIdArr : eisitngIdArr 
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{
                    
                    cmp.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    let allProcedureOnMT = result.allProcedureOnMT;
                    if(!$A.util.isEmpty(allProcedureOnMT)){
                        let count = 1;                        
                        allProcedureOnMT.forEach(function(element) {
                            if(!eisitngIdArr.includes(element.Id)){
                                element['SNo'] = count;
                                if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                    element['procedureName'] = element.ElixirSuite__Procedure__r.Name;
                                    element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                }
                                helper.setRemainingAmount(cmp, event, helper,element);
                                count++;
                            }
                        }); 
                        // asc // desc // 
                        cmp.set("v.selectedRows", eisitngIdArr);
                        helper.sortSelectedProcedures(cmp,'ElixirSuite__Date_Of_Service__c','desc',selectedProcedureRecordsNetInstanceCopy);
                        selectedProcedureRecordsNetInstanceCopy = selectedProcedureRecordsNetInstanceCopy.concat(allProcedureOnMT);
                        helper.setSerialNumber(cmp, event, helper,selectedProcedureRecordsNetInstanceCopy);
                        cmp.set("v.Plist",selectedProcedureRecordsNetInstanceCopy);
                    }
                    helper.setColumns(cmp, event, helper,cmp.get("v.customSettingData"));
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        $A.enqueueAction(action); 
        
    },
    sortSelectedProcedures : function(component,fieldName,sortDirection,data){
        //  var data = component.get("v.Plist");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        return data;
    },
    checkRequieredValidity :  function(cmp,event,helper){
        var isValid = true;
        let modeOfPayment = cmp.get("v.modeOfPayment");
        let amountPaid = cmp.get("v.amountPaid");
        let dateOfPayment = cmp.get("v.dateOfPayment");
        let creditSelectedRow = cmp.get("v.creditSelectedRows");
        let checkNumber = cmp.get("v.chequeNo");
        if(!modeOfPayment){
            helper.globalFlagToast(cmp, event, helper,'Mode of payment is mandatory!', ' ','error');  
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
                else if(!dateOfPayment){
                    helper.globalFlagToast(cmp, event, helper,'Date of payment is mandatory!', ' ','error');  
                    isValid = false;
                }
                    else if(!amountPaid){
                        helper.globalFlagToast(cmp, event, helper,'Amount paid is mandatory!', ' ','error');  
                        isValid = false;
                    }
                        else if(parseInt(amountPaid)==0){
                            helper.globalFlagToast(cmp, event, helper,'Amount paid cannot be zero!', ' ','error'); 
                            isValid = false;
                        }
        
        return isValid;
    },
    setSerialNumber :  function(cmp,event,helper,selectedProcedureRecordsNetInstance){
        cmp.set("v.loaded",true);
        let count = 1;
        selectedProcedureRecordsNetInstance.forEach(function(element) {
            element['SNo'] = count;
            count++;
        }); 
    },
    //registerThePaymentButtonHandler function added by Anusha - 30/09/2022
    registerThePaymentButtonHandler:function(cmp){
        let isModeOfPaymentEmpty = cmp.get("v.modeOfPayment")!='';
        let isAmountPaidPositive=cmp.get("v.amountPaid")>0;
        //let isProcedureOrClaimSelected=cmp.get("v.selectedProcedureRecords").length>0; //commented by Anusha LX3-5799
        let isDateEmpty=cmp.get("v.dateOfPayment")!='';
        console.log('cmp.get("v.selectedProcedureRecords") '+JSON.stringify(cmp.get("v.selectedProcedureRecords")));
        if(isModeOfPaymentEmpty && isAmountPaidPositive && isDateEmpty && cmp.get("v.dateOfPayment") != null && cmp.get("v.selectedProcedureRecords").length > 0){ //removed '&& isProcedureOrClaimSelected' from condition by Anusha LX3-5799
            cmp.set("v.makePaymentButtonDisable",false);
        }else{
            cmp.set("v.makePaymentButtonDisable",true);
        }
        if(isModeOfPaymentEmpty && isAmountPaidPositive && isDateEmpty && cmp.get("v.dateOfPayment") != null &&cmp.find('payReason').get('v.value')=='Unallocated Payment'){ 
            cmp.set("v.makePaymentButtonDisable",false);
        }
    },
    //resetData function added by Anusha-LX3-5747
    resetData : function(cmp){
        cmp.set("v.modeOfPayment",'');
        cmp.set("v.amountPaid",0.0);
        cmp.set("v.paymentTransactionNumber",'');
        cmp.set("v.procedureSearchParams",'');
        cmp.set("v.selectedRows",[]);
        cmp.set("v.selectedProcedureRecords",[]);
        cmp.set("v.totalAppliedAmount",0);
        cmp.set("v.totalUnAllocatedAmount",0);
        cmp.set("v.makePaymentButtonDisable",true);
        cmp.set("v.chequeNo",'');
        cmp.set("v.cheque",false);
        cmp.set("v.Credit",false);
        cmp.set("v.payReasonVal","");
    }
})