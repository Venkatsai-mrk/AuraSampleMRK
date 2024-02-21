({
    reCalDisAmtOnSelectedRowChange:function(component, event, helper){
        try{
            console.log('Akki2');
            let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
            
            let Plist =  component.get("v.Plist");
            var checked = component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c"); 
            if(checked){
                if(discAmt){
                    let selectedProcedureRecords =event.getParam('selectedRows');// component.get("v.selectedProcedureRecords");
                    let dscToAllocate = discAmt / selectedProcedureRecords.length;
                    if($A.util.isEmpty(selectedProcedureRecords)){
                        helper.globalFlagToast(component, event, helper,'Please select procedure(s)!', ' ','error');   
                        helper.resetCurrentDscAmt(component, event, helper);
                        component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
                        helper.handleEnableInlineEditing(component, event, helper,false); 
                        
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
                        helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
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
            
        }
        catch(e){
            alert(e);
        }
        
    },
    
    initPayloadCall : function(cmp, event, helper) {
        cmp.set("v.loaded",false);       
        var action = cmp.get("c.initPayloadCallData");
        action.setParams({acctId:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{                      
                    cmp.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    let arr = [];
                    for(let obj in result.typeOfDiscount){
                        let sObj = {'label' : obj, 'value' : result.typeOfDiscount[obj]};
                        arr.push(sObj);
                    }               
                    cmp.set("v.typeOfDiscountLst",arr);
                    console.log('result in private payment ----- ' + JSON.stringify(result));
                    //cmp.set("v.totalUnAllocatedDiscount_SumCount",result.amt); 
                    helper.initPayload(cmp, event, helper,cmp.get("v.PatientId"));                    
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        $A.enqueueAction(action);
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
                    console.log('result.allProcedureOnMT checking'+result.allProcedureOnMT);
                    let allProcedureOnMT = result.allProcedureOnMT;
                    
                    if(!$A.util.isEmpty(allProcedureOnMT)){
                        cmp.set("v.customSettingData",result.customSettingData);
                        helper.setColumns(cmp, event, helper,result.customSettingData);
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
                        cmp.set("v.Plist",allProcedureOnMT);
                        helper.calculateTotalRemainingAmount(cmp, event, helper);
                        console.log('Plist---'+JSON.stringify(cmp.get("v.Plist")));
                    }
                    
                    
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        $A.enqueueAction(action);
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
        var recordId = cmp.get("v.recordId");
        var sizeOfLst = cmp.get("v.selectedProcedureRecords").length;
        if(sizeOfLst==0){
            noProcedureSelected = true; 
        }
        
        cmp.set("v.loaded",false); 
        cmp.set("v.showConfirmDialog",false); 
        var action = cmp.get("c.allocateDiscountInSystem");
        action.setParams({otherTransaction :cmp.get("v.masterTransactionObj"),                        
                          acctId : cmp.get("v.PatientId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedureRecords")}),                   
                          selectedParentScheduleId : cmp.get("v.selectedParentScheduleId"),
                          totalUnAllocatedDiscount : cmp.get("v.totalUnAllocatedDiscount"),
                          appliedDiscount:cmp.get("v.totalAppliedDiscount"),
                          DiscountCode:cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Code__c"),
                          Notes:cmp.get("v.masterTransactionObj.ElixirSuite__Notes__c")
                         });      
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                cmp.set("v.loaded",true); 
                helper.globalFlagToast(cmp, event, helper,'Discount registered!', ' ','success');  
                if(!cmp.get("v.isPaymentTab")){ //Anusha start -LX3-5747
                    cmp.set("v.isModalOpen", true);
                    helper.resetData(cmp,event,helper);
                    helper.initPayloadCall(cmp, event, helper);
                    
                }
                $A.get('e.force:refreshView').fire(); //Anusha end -LX3-5747
                //$A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire();// Lokesh Added
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
        /*
           let couponcode = cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Code__c");
           let dicounttype = cmp.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c");
            let dicountAmount = cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c");
            let unallocatedDiscount = cmp.get("v.totalUnAllocatedDiscount");
            let AppliedDiscount = cmp.get("v.totalAppliedDiscount");
            alert(AppliedDiscount);*/
        
        
    },
    //resetData function Added by Anusha - LX3-5747
    resetData :function(cmp){
        cmp.set("v.masterTransactionObj",'ElixirSuite__Master_Transaction__c');
        cmp.set("v.procedureSearchParams",'');
        cmp.set('v.selectedRows',[]);
        cmp.set("v.selectedList",[]);//AK
        cmp.set("v.cancelSave",false);  
        cmp.set("v.makePaymentButtonDisable",true);
        cmp.set("v.selectedProcedureRecords",[]);
        cmp.set('v.totalAppliedDiscount',0);
        cmp.set('v.totalUnAllocatedDiscount',0);
        cmp.set('v.masterTransactionObj', {'ElixirSuite__Reason_Of_Payment__c' : 'Discounted Payment','ElixirSuite__Discount_Amount__c' : 0}); //Anusha -19/11/22 LX3-5747, LX3-6038
        //cmp.set('v.masterTransactionObj', {'ElixirSuite__Discount_Amount__c' : 0});
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
                                    element['currentDiscAmt'] = 0.0;
                                }
                                //helper.setRemainingAmount(cmp, event, helper,element);
                                count++;
                            }
                        }); 
                        // asc // desc // 
                        cmp.set("v.selectedRows", eisitngIdArr);
                        helper.sortSelectedProcedures(cmp,'ElixirSuite__Date_Of_Service__c','desc',selectedProcedureRecordsNetInstanceCopy);
                        selectedProcedureRecordsNetInstanceCopy = selectedProcedureRecordsNetInstanceCopy.concat(allProcedureOnMT);
                        cmp.set("v.Plist",selectedProcedureRecordsNetInstanceCopy);
                        
                        console.log('after search enable ---'+JSON.stringify(cmp.get("v.Plist")));
                    }
                    helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        $A.enqueueAction(action); 
        
    },
    calculateTotalRemainingAmount : function(cmp){
        let Plist =  cmp.get("v.Plist");
        let totalRemAmt = 0;
        Plist.forEach(function(element) {
            if(element.hasOwnProperty('remainingAmount')){
                if(element.remainingAmount){
                    totalRemAmt+=parseFloat(element.remainingAmount);
                }
            }
            
        });     
        cmp.set("v.totalRemAmt",totalRemAmt);  
    },
    sortSelectedProcedures : function(component,fieldName,sortDirection,data){
        //  var data = component.get("v.Plist");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d  = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        return data;
    },
    checkRequieredValidity :  function(cmp,event,helper){
        console.log('checkvalidity');
        var isValid = true;
        if(cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")!=null){
            var discountAmt =  JSON.parse(JSON.stringify(cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        }
        if(cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c")!=null){
            var discountPercent = JSON.parse(JSON.stringify(cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c")));
        }
        /*if(!typeOfdsc){
                helper.globalFlagToast(cmp, event, helper,'Type of Discount is mandatory!', ' ','error');  
                isValid = false;
            }*/
        if(cmp.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Percentage'){
            console.log('jiiiiii');
            if(parseInt(discountPercent) == 0){
                console.log('discountPercent')
                helper.globalFlagToast(cmp, event, helper,'Discount Percentage is mandatory!', ' ','error');  
                isValid = false;
            }
        }else if(cmp.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment'){
            console.log('jiiiiii  22222222222');
            if(parseInt(discountAmt) == 0){
                console.log('discountAmt')
                helper.globalFlagToast(cmp, event, helper,'Discount Amount is mandatory!', ' ','error');  
                isValid = false;
            }
        }else if(helper.validateDiscAmtWithzero(cmp,event,helper)){
            helper.globalFlagToast(cmp, event, helper,'No discount allocated!', 'Please allocate discount in Current Discount Amount of atleast 1 procedure!','error');  
            isValid = false;
        }
            else if(helper.validateNegativeRecords(cmp,event,helper).allow){
                helper.globalFlagToast(cmp, event, helper,'Cannot have negative discount amount for the following :', helper.validateNegativeRecords(cmp,event,helper).arr.join(';'),'error');  
                isValid = false;
            }
                else if(helper.compareDiscountAmount(cmp,event,helper)){
                    helper.globalFlagToast(cmp, event, helper,'Total Applied Discount is greater than Discount Amount!', ' ','error');  
                    isValid = false;
                } 
        
        return isValid;
    },
    validateNegativeRecords : function(cmp) {
        var toRet = {'allow' : false , arr : []};
        var allow = false;
        var arr = [];
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords");
        for(let rec in selectedProcedureRecords){
            if(selectedProcedureRecords[rec].hasOwnProperty('currentDiscAmt')){
                if(parseInt(selectedProcedureRecords[rec].currentDiscAmt)<0){
                    allow = true;
                    arr.push(selectedProcedureRecords[rec].procedureName);
                }              
            }          
        }
        toRet.allow = allow;
        toRet.arr = arr;
        return toRet; 
    },
    validateDiscAmtWithzero : function(cmp) {
        var allow = true;
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords");
        for(let rec in selectedProcedureRecords){
            if(selectedProcedureRecords[rec].hasOwnProperty('currentDiscAmt')){
                if(parseInt(selectedProcedureRecords[rec].currentDiscAmt)!=0){
                    allow = false;
                    break;
                }              
            }          
        }
        return allow; 
    },
    compareDiscountAmount : function(cmp) {
        var allow = false;
        let totalCurrentDiscAmt = 0;
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords");
        selectedProcedureRecords.forEach(function(element) {
            if(element.currentDiscAmt){
                totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);
            }
            else {
                element.currentDiscAmt = 0;
            }
        }); 
        if(totalCurrentDiscAmt > cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")){
            allow = true;
        }
        cmp.set("v.selectedProcedureRecords",selectedProcedureRecords);
        return allow;
    },
    setRemainingAmount : function(cmp, event, helper,element){
        if(element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && element.hasOwnProperty('ElixirSuite__Other_Discount__c')
           && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c')){
            element['remainingAmount'] = ( parseFloat(element.ElixirSuite__Expected_Receivable_amount__c) - parseFloat(element.ElixirSuite__Other_Discount__c) ) - parseFloat(element.ElixirSuite__Total_Paid_Amount__c); 
        }
        else if(!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && (element.hasOwnProperty('ElixirSuite__Other_Discount__c')
                                                                                          && element.hasOwnProperty('ElixirSuite__Total_Paid_Amount__c'))){
            element['remainingAmount'] = ( parseFloat(element.ElixirSuite__Actual_Price__c) - parseFloat(element.ElixirSuite__Other_Discount__c) ) - parseFloat(element.ElixirSuite__Total_Paid_Amount__c); 
        }
            else if((!element.hasOwnProperty('ElixirSuite__Expected_Receivable_amount__c') && !element.hasOwnProperty('ElixirSuite__Other_Discount__c'))){
                element['remainingAmount'] =  parseFloat(element.ElixirSuite__Actual_Price__c) - parseFloat(element.ElixirSuite__Total_Paid_Amount__c) ; 
            }
                else if(!element.hasOwnProperty('ElixirSuite__Other_Discount__c')){
                    element['remainingAmount'] =  parseFloat(element.ElixirSuite__Expected_Receivable_amount__c) - parseFloat(element.ElixirSuite__Total_Paid_Amount__c) ;
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
            { label: 'S.No', fieldName: 'SNo', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true } ,
            //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}  ,
             {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            {label: 'CPT Code', fieldName: 'procedureName', type: 'text', sortable :true}  ,
            
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true}  ,
             {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true}  ,
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true} 
            ,            
            
            {label: 'Remaining amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true}  ,
            {label: 'Current Discount Amount', fieldName: 'currentDiscAmt', type: 'currency',editable: true}  ,
            
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
            cmp.set("v.masterTransactionObj",{'ElixirSuite__Discount_Amount__c' : 0.0, 'ElixirSuite__Discount_Percentage__c' : 0,
            'ElixirSuite__Maximum_Discount__c': '','ElixirSuite__Complete_discount_to_be_utilized__c' : false,
            'ElixirSuite__Discount_Code__c' : '','ElixirSuite__Notes__c' : '','ElixirSuite__Reason_Of_Payment__c' : 'Discounted Payment',
            'ElixirSuite__Divide_the_Discount_Amount_equally_among__c' : false});
            cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',
            'procedureId' : '','CPTCode' : ''});
            cmp.set('v.columns2', [
            {label: 'Schedule', fieldName: 'Name', type: 'Auto Number'},
            {label: 'Frequency', fieldName: 'ElixirSuite__Pay_Frequency__c', type: 'Picklist'},
            {label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'Currency'},
            {label: 'Total Amount', fieldName: 'ElixirSuite__Net_Balance__c', type: 'Currency'},
            {label: 'Remaining Amount', fieldName: 'ElixirSuite__Total_Balance_Due__c', type: 'Currency'}
        ]);
        cmp.set('v.columns3', [
            {label: 'Scheduled Date', fieldName: 'ElixirSuite__Due_Date__c', type: 'Date'},
            {label: 'Status', fieldName: 'ElixirSuite__Payment_Status__c', type: 'Picklist'},
            {label: 'Installment Amount', fieldName: 'ElixirSuite__Installment_Amount__c', type: 'Currency'},
            {label: 'Amount Paid', fieldName: 'ElixirSuite__Total_payment_Made_formula__c', type: 'Currency'},
            {label: 'Remaining Amount', fieldName: 'ElixirSuite__Balance_Due1__c', type: 'Currency'}
        ]); 
    },
    validateDiscountPaid:  function(component, event, helper){
        var isValid = true;
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));      
        if(discAmt > component.get("v.totalRemAmt") ){
            helper.globalFlagToast(component, event, helper,'Discount amount cannot be greater than total remaining value!', ' ','error');
            component.set("v.makePaymentButtonDisable",true);
            component.set("v.hideCBCols",true);
            isValid = false;
        }
        else {
            component.set("v.makePaymentButtonDisable",false);
            component.set("v.hideCBCols",false);
            isValid = true;
        }
        return isValid;
    },
    handleEnableInlineEditing :  function(component, event, helper,checked) { 
        let columns =   component.get("v.columns");
        if(checked){
            columns.forEach(function(element) {  
                if(element.fieldName == 'currentDiscAmt'){
                    element.editable = false;
                }
                
            });  
        }
        else {
            columns.forEach(function(element) {  
                if(element.fieldName == 'currentDiscAmt'){
                    element.editable = true;
                }
            });   
        }
        component.set("v.columns",columns);
    },
    resetCurrentDscAmt :  function(component) { 
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
        if(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")!=null){
            var discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        }
        if(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c")!=null){
            var maxDiscAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c")));
        }
        console.log('reset@@@@@@@ '+selectedProcedureRecords);
        let Plist =  component.get("v.Plist");
        Plist.forEach(function(element) {                            
            element.currentDiscAmt = 0.0;                          
        }); 
        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
        component.set("v.Plist",Plist);
        component.set("v.totalAppliedDiscount",0.0);//AK
        if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Percentage'){
            if(maxDiscAmt == 0 || maxDiscAmt == 0.0){
                console.log("333");
                component.set("v.totalUnAllocatedDiscount",0.0);   
            }else{
                component.set("v.totalUnAllocatedDiscount",maxDiscAmt);
            }
        }
        if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment'){
            component.set("v.totalUnAllocatedDiscount",discAmt);
        }
        
    },
    caculateDiscountVariations :  function(component) { 
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        let maxDiscAmt = parseInt(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))));
        //alert(typeof(maxDiscAmt));
        let totalCurrentDiscAmt = 0;
        let Plist =  component.get("v.Plist");
        Plist.forEach(function(element) { 
            if(element.currentDiscAmt != null){
                totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);  
            }
            
        }); 
        console.log("totalCurrentDiscAmt--- "+totalCurrentDiscAmt);
        component.set("v.totalAppliedDiscount",(totalCurrentDiscAmt).toFixed());//AK
        if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Percentage'){
            if(maxDiscAmt == 0 || maxDiscAmt == 0.0){
                console.log("333");
                component.set("v.totalUnAllocatedDiscount",0.0);   
            }else{
                console.log('maxDiscAmt');
                component.set("v.totalUnAllocatedDiscount",maxDiscAmt-  (totalCurrentDiscAmt.toFixed())); 
            }
        }
        if(component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment'){
            component.set("v.totalUnAllocatedDiscount",discAmt - (totalCurrentDiscAmt.toFixed()));
        }
        
    },
    deAllocateDiscounts :  function(component, event, helper,selectedProcedureRecords) { 
        let idArr = [];
        selectedProcedureRecords.forEach(function(element) {  
            idArr.push(element.Id);
            //element.currentDiscAmt = 0.0;//AK
        }); 
        let Plist =  component.get("v.Plist");
        Plist.forEach(function(element_PList) {  
            if(!idArr.includes(element_PList.Id)){
                element_PList.currentDiscAmt = 0.0;
            }
        }); 
        component.set("v.Plist",Plist);
        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
    },
    checkSanity :  function(component, event, helper,selectedProcedureRecords) { 
        let totalCurrentDiscAmt = 0;
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        selectedProcedureRecords.forEach(function(element) {  
            totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);    
        }); 
        console.log('discAmt '+discAmt)
        console.log('totalCurrentDiscAmt '+totalCurrentDiscAmt)
        if(parseInt(totalCurrentDiscAmt.toFixed()) > parseInt(discAmt)){
            helper.globalFlagToast(component, event, helper,'Total discount amount of selected procedure(s) cannot be greater than discount amount!', ' ','error');
            component.set("v.makePaymentButtonDisable",true);
        }
        else {
            component.set("v.makePaymentButtonDisable",false);
        }
    },
    organizePercentageLogic : function(component, event, helper) { 
        console.log("percentage logic");
        let Plist =  component.get("v.Plist");
        // var pListSize = component.get("v.Plist").length ; 
        //  component.set("v.maxRowSelectionProcedures",parseInt(pListSize));
        let selectedProcedureRecords = component.get("v.selectedList");
        let discPercentage =   parseInt(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c"))));
        let maxDiscAmt =   parseInt(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))));
        let totalAppliedDiscount = 0;//AK
        let totalUnAllocatedDiscount = maxDiscAmt;//AK
        if(discPercentage && parseInt(discPercentage)!=0 && !$A.util.isEmpty(selectedProcedureRecords)){ 
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,true);
            
            selectedProcedureRecords.forEach(function(element) { 
                if(element.ElixirSuite__Actual_Price__c != null){
                    let dscToAllocate = (parseFloat(element.ElixirSuite__Actual_Price__c) * discPercentage ) / 100;
                    let lstAmt = dscToAllocate+ totalAppliedDiscount;
                    console.log('dscToAllocat'+dscToAllocate );
                    if(totalUnAllocatedDiscount > 0 && totalUnAllocatedDiscount > 0.0){
                        if(lstAmt>maxDiscAmt){
                            element.currentDiscAmt = totalUnAllocatedDiscount;
                            totalAppliedDiscount+=totalUnAllocatedDiscount;
                        }else if(dscToAllocate > element.remainingAmount){ // 300> 200
                            element.currentDiscAmt = (element.remainingAmount).toFixed(2); 
                            totalAppliedDiscount+=parseFloat(element.remainingAmount); 
                        }else {
                            element.currentDiscAmt = dscToAllocate.toFixed(2);      // 200 300
                            totalAppliedDiscount+=parseFloat(dscToAllocate);
                        }
                        
                        let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                        if(arrIndex>=0){
                            if(lstAmt>maxDiscAmt){
                                Plist[arrIndex].currentDiscAmt = totalUnAllocatedDiscount;  
                            }else if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                                Plist[arrIndex].currentDiscAmt = (Plist[arrIndex].remainingAmount).toFixed(2);
                            }else {
                                Plist[arrIndex].currentDiscAmt = dscToAllocate.toFixed(2);
                            }
                        }
                        totalUnAllocatedDiscount = maxDiscAmt- totalAppliedDiscount.toFixed();
                    }else{
                        component.set("v.makePaymentButtonDisable",true); 
                    }
                }
            });
            
            component.set("v.selectedProcedureRecords",selectedProcedureRecords);
            component.set("v.Plist",Plist);
            if(component.get("v.makePaymentButtonDisable")){
                helper.globalFlagToast(component, event, helper,'Cannot allocate more than maximum discount!', ' ','error');   
            }
            helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
            //helper.checkValidityAgainstMaxDiscount(component, event, helper,maxDiscAmt,selectedProcedureRecords);
            helper.caculateDiscountVariations(component, event, helper);
            
        }
        else if($A.util.isEmpty(selectedProcedureRecords)){
            console.log('Hiii');
            helper.resetCurrentDscAmt(component, event, helper);
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,false);
        }
            else { 
                helper.globalFlagToast(component, event, helper,'Please enter discount percentage!', ' ','error'); 
                component.set("v.selectedRows",[]);
                component.set("v.selectedProcedureRecords",[]);
                component.set("v.selectedList",[]);
            }
        
    },
    //Akki
    organizePercentageLogicWithNoMaxDis : function(component, event, helper) { 
        console.log("222");
        console.log("percentage logic without amount");
        let Plist =  component.get("v.Plist");
        //  component.set("v.maxRowSelectionProcedures",component.get("v.Plist").length);
        let maxDiscAmt =   parseInt(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Maximum_Discount__c"))));
        let selectedProcedureRecords = component.get("v.selectedList");
        let discPercentage =   parseInt(JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c"))));
        if(discPercentage && parseInt(discPercentage)!=0 && !$A.util.isEmpty(selectedProcedureRecords)){          
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,true);
            selectedProcedureRecords.forEach(function(element) {
                if(element.ElixirSuite__Actual_Price__c != null){
                    let dscToAllocate = (parseFloat(element.ElixirSuite__Actual_Price__c) * discPercentage ) / 100;
                    console.log('dscToAllocat'+dscToAllocate );
                    if(dscToAllocate > element.remainingAmount){ // 300> 200
                        element.currentDiscAmt = (element.remainingAmount).toFixed(2); 
                        
                    }else {
                        element.currentDiscAmt = dscToAllocate.toFixed(2);      // 200 300
                        
                    }
                    
                    let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                    if(arrIndex>=0){
                        if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                            Plist[arrIndex].currentDiscAmt = (Plist[arrIndex].remainingAmount).toFixed(2);
                        }else {
                            Plist[arrIndex].currentDiscAmt = dscToAllocate.toFixed(2);
                        }
                    }
                }
            }); 
            component.set("v.selectedProcedureRecords",selectedProcedureRecords);
            component.set("v.Plist",Plist);
            helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
            helper.checkValidityAgainstMaxDiscount(component, event, helper,maxDiscAmt,selectedProcedureRecords);
            helper.caculateDiscountVariations(component, event, helper);
            
        }
        else if($A.util.isEmpty(selectedProcedureRecords)){
            helper.resetCurrentDscAmt(component, event, helper);
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,false);
        }
            else { 
                helper.globalFlagToast(component, event, helper,'Please enter discount percentage!', ' ','error'); 
                component.set("v.selectedRows",[]);
                component.set("v.selectedProcedureRecords",[]);
                component.set("v.selectedList",[]);
            }
        
    },
    checkValidityAgainstMaxDiscount : function(component, event, helper,maxDiscAmt,selectedProcedureRecords) { 
        let totalCurrentDiscAmt = 0;
        if(maxDiscAmt){
            selectedProcedureRecords.forEach(function(element) {  
                totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);                      
            }); 
            if(totalCurrentDiscAmt > parseFloat(maxDiscAmt)){
                helper.globalFlagToast(component, event, helper,'Cannot allocate more than maximum discount!', ' ','error'); 
                component.set("v.makePaymentButtonDisable",true); 
            } 
            else{
                component.set("v.makePaymentButtonDisable",false);  
            }
        }
    },
    addButtonEnableHandler: function(component)
    {
        var selectedRows = component.get("v.selectedProcedureRecords");
        var checkDiscount = false; 
        for(var row of selectedRows){
            if(row.currentDiscAmt > 0){
                checkDiscount = true;
                break;
            }
        }
        
        if(checkDiscount && selectedRows.length > 0 && component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Payment' && component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c") != null && component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c") != '' && parseInt(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")) > 0 && !(component.get("v.cancelSave"))){
            component.set("v.makePaymentButtonDisable",false);  
        }else if(checkDiscount && selectedRows.length > 0 && component.get("v.masterTransactionObj.ElixirSuite__Reason_Of_Payment__c") == 'Discounted Percentage' && component.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c") != null && component.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c") != '' && parseInt(component.get("v.masterTransactionObj.ElixirSuite__Discount_Percentage__c"))  > 0){
            component.set("v.makePaymentButtonDisable",false);    
        }else{
            component.set("v.makePaymentButtonDisable",true);   
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
    }
    
})