({
    doInitHelper : function(component) {  
        var discountCouponCode = false;
        var discountType = false;
        var action = component.get("c.customDiscountTable");
        action.setParams({acctId:component.get("v.PatientId")
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set('v.DiscountTableData', result.customSettingDiscountTable);
                console.log('---customSettingDiscountTable---'+ JSON.stringify(result.customSettingDiscountTable));
                component.set('v.discountTableUnAllocatedAmount', result.customSettingDiscountTable.ElixirSuite__Discount_Amount__c);
                console.log(result.customSettingData);
                if(!$A.util.isUndefinedOrNull(result.customSettingData)){
                    if(result.customSettingData.length>0){
                        discountCouponCode = result.customSettingData[0].ElixirSuite__Discount_Coupon_Code__c;
                        discountType = result.customSettingData[0].ElixirSuite__Discount_Type__c;
                    }
                }
                var allProcedure = result.customSettingDiscountTable;
                    if(!$A.util.isEmpty(allProcedure)){
                        allProcedure.forEach(function(element) {
                            if(element.hasOwnProperty('ElixirSuite__Reason_Of_Payment__c')){
                                if(element.ElixirSuite__Reason_Of_Payment__c == 'Discounted Payment'){
                                element['ReasonOfPayment'] = 'Discount Amount';
                                element['DiscountType'] = 'currency';
                                }
                                if(element.ElixirSuite__Reason_Of_Payment__c == 'Discounted Percentage'){
                                element['ReasonOfPayment'] = 'Discount Percentage';
                                element['DiscountType'] = 'percent';
                                }
                            }
                        }); 
                    }
            }
            let addCols =   component.get('v.DiscountTableColumns');
            if(discountType){
                addCols.push( {label: 'Discount Type', fieldName: 'ReasonOfPayment', type: 'text', sortable :true}  );
            } 
            if(discountCouponCode){
                addCols.push({label: 'Discount Coupon Code', fieldName: 'ElixirSuite__Discount_Code__c', type: 'text', sortable :true});
            }
         addCols.push( {label: 'Discount Value', fieldName: 'ElixirSuite__Discount_Amount__c',sortable :true}  );
         addCols.push( {label: 'Applied Discount', fieldName: 'ElixirSuite__Allocated_Amount__c', type: 'currency',sortable :true}  );
         addCols.push( {label: 'Unallocated Discount', fieldName: 'ElixirSuite__Total_Unallocated_Amount__c', type: 'currency',sortable :true} );
            if(!$A.util.isEmpty(allProcedure)){
                allProcedure.forEach(function(element) {
                     if(element.hasOwnProperty('DiscountType')){
                    if(element.DiscountType == 'currency'){
                        element['ElixirSuite__Discount_Amount__c'] = '$' + element['ElixirSuite__Discount_Amount__c'];                                }
                    if(element.DiscountType == 'percent'){
                        element['ElixirSuite__Discount_Amount__c'] = element['ElixirSuite__Discount_Amount__c'] + '%';                                }
                     }
                     }); 
            }
         component.set('v.DiscountTableColumns',addCols);
        });
        $A.enqueueAction(action);
    }, 
    
    initPayloadCall : function(cmp, event, helper) {
        var action = cmp.get("c.initPayloadCallData");
        action.setParams({acctId:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{                      
                    cmp.set("v.loaded",false); 
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
     
        var action = cmp.get("c.queryAllProceduresOnMasterTransaction");
        action.setParams({acctId:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{                    
                 cmp.set("v.loaded",false); 
                    var result = response.getReturnValue();
                    console.log('result.allProcedureOnMT checking'+result.allProcedureOnMT);
                    let allProcedureOnMT = result.allProcedureOnMT;
                     cmp.set("v.proceduresListDiscountChng",result.allProcedureOnMT);
                    
                    if(!$A.util.isEmpty(allProcedureOnMT)){
                         cmp.set("v.customSettingData",result.customSettingData);
                        helper.setColumns(cmp, event, helper,result.customSettingData);
                        helper.calculateTotalRemainingAmount(cmp, event, helper);
                        console.log('Plist---'+JSON.stringify(cmp.get("v.Plist")));
                    }
                        
                }
                catch(e){
                    alert('checking'+e);
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    loadProceduresOnDiscTypeChange : function(cmp, event, helper) { // Venkat 
        cmp.set("v.loaded",false);
     let discountType = cmp.get('v.discountType');
        var DiscountTableId = cmp.get('v.DiscountTableId');
        let allProcedureOnMT = cmp.get('v.proceduresListDiscountChng');
              if(!$A.util.isEmpty(allProcedureOnMT)){
                        if(discountType=='Discount Amount'){
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
                        
                        }else{
                            let count = 1;
                           var percentageRecords = [];
                        allProcedureOnMT.forEach(function(element, index) {
                            console.log('other tracs ids  '+element.ElixirSuite__Master_Transaction__c);
                             console.log('DiscountTableId  '+DiscountTableId);
                            if( element.ElixirSuite__Master_Transaction__c!= DiscountTableId){
                               percentageRecords.push(allProcedureOnMT[index]);
                               console.log('percentageRecords---'+percentageRecords);  
                            }
                            if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                                element['procedureName'] = element.ElixirSuite__Procedure__r.Name; 
                                element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                element['currentDiscAmt'] = 0.0;
                            }
                            helper.setRemainingAmount(cmp, event, helper,element);
                           
                        }); 
                            percentageRecords.forEach(function(element) {
                                  element['SNo'] = count;
                                 count++;
                            });  
                            
                        cmp.set("v.Plist",percentageRecords);  
                        }
                        helper.calculateTotalRemainingAmount(cmp, event, helper);
                        console.log('Plist---'+JSON.stringify(cmp.get("v.Plist")));
                    }
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
       
        cmp.set("v.showConfirmDialog",false); 
        var action = cmp.get("c.allocateDiscountInSystem");
        action.setParams({otherTransaction :cmp.get("v.masterTransactionObj"),  
                          discountType:cmp.get('v.discountType'),
                          acctId : cmp.get("v.PatientId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedureRecords")}),                   
                          totalUnAllocatedDiscount : cmp.get("v.totalUnAllocatedDiscount"),
                          appliedDiscount:cmp.get("v.totalAppliedDiscount"),
                          discountTableId:cmp.get("v.DiscountTableId")
                         });      
        action.setCallback(this, function(response) {
                //helper.doInitHelper(cmp,event,helper);
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.loaded",false); 
                helper.globalFlagToast(cmp, event, helper,'DISCOUNT REGISTERED!', ' ','success'); 
                if(!cmp.get("v.isPaymentTab")){ //Anusha start -LX3-5747
                    cmp.set("v.isModalOpen", true);
                    cmp.set("v.DiscountTableData", []);
                    helper.resetData(cmp,event,helper); 
                    cmp.set('v.DiscountTableColumns',[
                        {label: 'Discount Number', fieldName: 'Name', type: 'Auto Number',sortable :true}
                    ]);
                    helper.doInitHelper(cmp, event, helper);
                    helper.setDefaultJSON(cmp, event, helper);
                    helper.initPayloadCall(cmp, event, helper);
                    cmp.set('v.discountType','');
                    //helper.doInitHelper1(cmp, event, helper);
                    
                }
               // $A.get('e.force:refreshView').fire(); //Anusha end -LX3-5747
               //$A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire();//Lokesh Added
            }            

            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.globalFlagToast(cmp, event, helper,errors[0].message,' ','error');
                            cmp.set("v.loaded",false);
                        }
                    }
                }
			            
        }); 
        $A.enqueueAction(action);
    },
     resetData :function(cmp){
        cmp.set("v.hideCheckbox",false);
        cmp.set("v.discountType",'');
        cmp.set("v.Plist",[]);
        cmp.set("v.cancelSave",false); 
        cmp.set("v.procedureSearchParams",'');
        cmp.get("v.selectedProcedureRecords",[]);
        cmp.set("v.makePaymentButtonDisable",true);
        cmp.set('v.selectedRows',[]);
        cmp.set('v.totalAppliedDiscount',0);
        cmp.set('v.totalUnAllocatedDiscount',0);
        cmp.set('v.renderCheckbox',true);
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
        cmp.set("v.loaded",true);       
        var action = cmp.get("c.filterProcedureOnMasterTransaction");
        action.setParams({acctId:cmp.get("v.PatientId"),
                          eisitngIdArr : eisitngIdArr 
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{
                    
                    cmp.set("v.loaded",false); 
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
                                helper.setRemainingAmount(cmp, event, helper,element);
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
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        return data;
    },
    checkRequieredValidity :  function(cmp,event,helper){
        var isValid = true;
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords")
       /* if(!typeOfdsc){
            helper.globalFlagToast(cmp, event, helper,'Type of discount is mandatory!', ' ','error');  
            isValid = false;
        }
       if(!discountAmt){
            helper.globalFlagToast(cmp, event, helper,'Discount amount is mandatory!', ' ','error');  
            isValid = false;
        } */  
            if($A.util.isEmpty(selectedProcedureRecords)){
                helper.globalFlagToast(cmp, event, helper,'Please select procedures!', ' ','error');  
                isValid = false;
                cmp.set("v.loaded",false);
            }
                else if(!(helper.validateDiscAmtWithzero(cmp,event,helper))){
                    helper.globalFlagToast(cmp, event, helper,'NO DISCOUNT ALLOCATED!', 'Please allocate discount in Current Discount Amount of atleast 1 procedure!','error');  
                    isValid = false;
                    cmp.set("v.loaded",false);
                }
                    else if(helper.compareDiscountAmount(cmp,event,helper)){
                        helper.globalFlagToast(cmp, event, helper,'Total Applied Discount is greater than Remaining Unallocated Discount Amount!', ' ','error');  
                        isValid = false;
                        cmp.set("v.loaded",false);
                        
                    } 
        
        return isValid;
    },
    validateDiscAmtWithzero : function(cmp) {
        var allow = false;
        let selectedProcedureRecords = cmp.get("v.selectedProcedureRecords");
        for(let rec in selectedProcedureRecords){
            if(selectedProcedureRecords[rec].hasOwnProperty('currentDiscAmt')){
                if(parseInt(selectedProcedureRecords[rec].currentDiscAmt) > 0){
                    allow = true;
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
       
       // if(totalCurrentDiscAmt > cmp.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")){
           if(totalCurrentDiscAmt > cmp.get("v.discountTableUnAllocatedAmount")){
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
    validateDiscountPaid:  function(component, event, helper){
        var isValid = true;
      //<--V-->  let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));      
       let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
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
     caculateDiscountVariations :  function(component) { 
         console.log('siva6');
       //<--V-->  let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        let totalCurrentDiscAmt = 0;
        let Plist =  component.get("v.Plist");
        Plist.forEach(function(element) {                            
            totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);                
            
        }); 
        component.set("v.totalAppliedDiscount",totalCurrentDiscAmt);
        component.set("v.totalUnAllocatedDiscount",discAmt-  JSON.parse(JSON.stringify(totalCurrentDiscAmt)));
    },
    
    reEvaluateLogicOnDeselctingProcedure :  function(component, event, helper,selectedProcedureRecords) { 
        console.log('siva5');
      //  let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        let checked =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c")));
        let dscToAllocate = discAmt / selectedProcedureRecords.length;
        let Plist =  component.get("v.Plist");
        if($A.util.isEmpty(selectedProcedureRecords)){
            helper.handleEnableInlineEditing(component, event, helper,false);   
            component.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
        }
        else {
            helper.handleEnableInlineEditing(component, event, helper,checked); 
            selectedProcedureRecords.forEach(function(element) {  
                if(dscToAllocate > element.remainingAmount){
                    element.currentDiscAmt = element.remainingAmount;         
                }
                else {
                    element.currentDiscAmt = dscToAllocate;     
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
            helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
        }
    },

    deAllocateDiscounts :  function(component, event, helper,selectedProcedureRecords) { 
        let idArr = [];
        selectedProcedureRecords.forEach(function(element) {  
            idArr.push(element.Id);
            element.currentDiscAmt = 0.0;
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
    deAllocateDiscountsOnDeselect :  function(component, event, helper,selectedProcedureRecords) { 
        let idArr = [];
        selectedProcedureRecords.forEach(function(element, index) {  
            idArr.push(element.Id);
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
      //  let discAmt =   JSON.parse(JSON.stringify(component.get("v.masterTransactionObj.ElixirSuite__Discount_Amount__c")));
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        selectedProcedureRecords.forEach(function(element) {  
            totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);    
        }); 
        if(totalCurrentDiscAmt>discAmt){
           // helper.globalFlagToast(component, event, helper,'Total discount amount of selected procedure(s) cannot be greater than discount amount!', ' ','error');
            component.set("v.makePaymentButtonDisable",true);
        }
        else {
            component.set("v.makePaymentButtonDisable",false);
        }
          helper.deAllocateDiscountsOnDeselect(component, event, helper,selectedProcedureRecords);
    },
    
    organizePercentageLogicWithUnallocateAmount : function(component, event, helper) { 
       let Plist =  component.get("v.Plist");
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
         let remainingAmount =   component.get("v.totalAppliedDiscount");
        let unallocatedAomunt =  component.get("v.totalUnAllocatedDiscount");
         console.log('unallocatedAomunt '+unallocatedAomunt);
            component.set("v.makePaymentButtonDisable",false); 
        let discPercentage =   JSON.parse(JSON.stringify(component.get("v.discountTableDiscountPercentage")));
        let maxDiscAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        let totalAppliedDiscount=0;
        let totalUnAllocatedDiscount=maxDiscAmt;
         console.log('maxDiscAmt '+maxDiscAmt);
              console.log('discPercentage '+discPercentage);
         console.log('selectedProcedureRecords '+JSON.stringify(selectedProcedureRecords));
        if( parseInt(discPercentage)!=0 && !$A.util.isEmpty(selectedProcedureRecords)){ 
             console.log('chk ');
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,true);
            
            selectedProcedureRecords.forEach(function(element) { 
                if(element.ElixirSuite__Actual_Price__c != null){
                      console.log('ElixirSuite__Actual_Price__c '+element.ElixirSuite__Actual_Price__c );
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
            helper.deAllocateDiscountsOnDeselect(component, event, helper,selectedProcedureRecords);
            helper.checkValidityAgainstMaxDiscount(component, event, helper,maxDiscAmt,selectedProcedureRecords);
            helper.caculateDiscountVariations(component, event, helper);
            
        }
        else if($A.util.isEmpty(selectedProcedureRecords)){
            console.log('Hiii');
            helper.resetCurrentDscAmt(component, event, helper);
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,false);
            helper.deAllocateDiscountsOnDeselect(component, event, helper,selectedProcedureRecords);
        }
            else { 
                helper.globalFlagToast(component, event, helper,'Please enter discount percentage!', ' ','error'); 
                component.set("v.selectedRows",[]);
                component.set("v.selectedProcedureRecords",[]);
                //component.set("v.selectedList",[]);
            }
    },
    organizePercentageLogic : function(component, event, helper) { 
        let Plist =  component.get("v.Plist");
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
         let remainingAmount =   component.get("v.totalAppliedDiscount");
        let unallocatedAomunt =  component.get("v.totalUnAllocatedDiscount");
        let discPercentage =   JSON.parse(JSON.stringify(component.get("v.discountTableDiscountPercentage")));
        let maxDiscAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        if(discPercentage && parseInt(discPercentage)!=0 && !$A.util.isEmpty(selectedProcedureRecords)){          
            component.set("v.makePaymentButtonDisable",false); 
            helper.handleEnableInlineEditing(component, event, helper,true);
            selectedProcedureRecords.forEach(function(element) {  
                let dscToAllocate = ( element.ElixirSuite__Actual_Price__c * discPercentage ) / 100;
                
                if(dscToAllocate > element.remainingAmount){ // 300> 200
                    element.currentDiscAmt = element.remainingAmount; 
                }
                    else{
                     element.currentDiscAmt = dscToAllocate; // 200 300
                }
               /* let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                if(arrIndex>=0){
                  if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                      if($A.util.isEmpty(Plist[arrIndex].remainingAmount)||Plist[arrIndex].remainingAmount==0 ){
                        Plist[arrIndex].currentDiscAmt = Plist[arrIndex].remainingAmount;
                      }
                  }
                    else {
                        Plist[arrIndex].currentDiscAmt = dscToAllocate;
                            console.log('Plist[arrIndex].currentDiscAmt12'+Plist[arrIndex].currentDiscAmt);
                    }
                } */          
            });
            
            component.set("v.selectedProcedureRecords",selectedProcedureRecords);
            component.set("v.Plist",Plist);
             helper.deAllocateDiscountsOnDeselect(component, event, helper,selectedProcedureRecords);
            helper.checkValidityAgainstMaxDiscount(component, event, helper,maxDiscAmt,selectedProcedureRecords)
           helper.caculateDiscountVariations(component, event, helper); 
        }
        else if($A.util.isEmpty(selectedProcedureRecords)){
            helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
            component.set("v.makePaymentButtonDisable",false); 
        }
            else { 
                helper.globalFlagToast(component, event, helper,'Please enter discount percentage!', ' ','error'); 
                component.set("v.selectedRows",[]); 
            }
        
    },
    
     checkValidityAgainstMaxDiscount : function(component, event, helper,maxDiscAmt,selectedProcedureRecords) { 
        var allowMoreSelection = true;
        let totalCurrentDiscAmt = 0;
        if(maxDiscAmt){
            selectedProcedureRecords.forEach(function(element) {  
                totalCurrentDiscAmt+=parseFloat(element.currentDiscAmt);                      
            }); 
           
            if(totalCurrentDiscAmt > parseFloat(maxDiscAmt)){
               // helper.globalFlagToast(component, event, helper,'Cannot allocate more than maximun discount!', ' ','error'); 
               // component.set("v.makePaymentButtonDisable",true); 
               // component.set("v.maxRowSelectionProcedures",selectedProcedureRecords.length);
            }
            else if(totalCurrentDiscAmt <= parseFloat(maxDiscAmt)){
              //  component.set("v.maxRowSelectionProcedures",data.length );
            }
            else{
                component.set("v.makePaymentButtonDisable",false);  
               //  component.set("v.maxRowSelectionProcedures",'');
            }
        }
    },
    setDefaultJSON : function(cmp){
        cmp.set("v.masterTransactionObj",{'ElixirSuite__Discount_Amount__c' : 0.0, 'ElixirSuite__Discount_Percentage__c' : 0,
            'ElixirSuite__Maximum_Discount__c': '','ElixirSuite__Complete_discount_to_be_utilized__c' : false,
            'ElixirSuite__Discount_Code__c' : '','ElixirSuite__Notes__c' : '','ElixirSuite__Reason_Of_Payment__c' : 'Discounted Payment',
            'ElixirSuite__Divide_the_Discount_Amount_equally_among__c' : false});
        	 cmp.set('v.selectedRows',[]);
        cmp.set("v.hideCheckbox",false);
        cmp.set("v.masterTransactionObj.ElixirSuite__Divide_the_Discount_Amount_equally_among__c",false);
            cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',
            'procedureId' : '','CPTCode' : ''});
            },
    reCalDisAmtOnSelectedRowChange:function(component, event, helper){
    try{
        console.log('sivasaiprasad');
            
           let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
            let remainingDscAmt = JSON.parse(JSON.stringify(discAmt));
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
                            if(dscToAllocate > element.remainingAmount){ // 300> 200
                                element.currentDiscAmt = (element.remainingAmount);         
                            }
                            else {
                                element.currentDiscAmt = dscToAllocate;      // 200 300
                            }
                            let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
                            if(arrIndex>=0){
                                if(dscToAllocate > Plist[arrIndex].remainingAmount){  
                                    Plist[arrIndex].currentDiscAmt = (Plist[arrIndex].remainingAmount);
                                }
                                else {
                                    Plist[arrIndex].currentDiscAmt = dscToAllocate;
                                }
                            }
           
                        });                         
                        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
                        component.set("v.Plist",Plist);
                        helper.caculateDiscountVariations(component, event, helper);
                        helper.checkSanity(component, event, helper,selectedProcedureRecords);
                       // helper.deAllocateDiscounts(component, event, helper,selectedProcedureRecords);
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
        let discAmt =   JSON.parse(JSON.stringify(component.get("v.discountTableUnAllocatedAmount")));
        let selectedProcedureRecords = component.get("v.selectedProcedureRecords");
        let Plist =  component.get("v.Plist");
        selectedProcedureRecords.forEach(function(element) {                            
            element.currentDiscAmt = 0.0;                        
            let arrIndex = Plist.findIndex(obj => obj.Id == element.Id);
            if(arrIndex>=0){
                Plist[arrIndex].currentDiscAmt = 0.0;
            }
        }); 
        component.set("v.selectedProcedureRecords",selectedProcedureRecords);
        component.set("v.Plist",Plist);
        component.set("v.totalAppliedDiscount",0);
        component.set("v.totalUnAllocatedDiscount",discAmt);
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
            {label: 'S.No', fieldName: 'SNo', type: 'number', cellAttributes: { alignment: 'left' }},
            //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true},
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            {label: 'CPT Code', fieldName: 'procedureName', type: 'text', sortable :true},
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true},
             {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true},
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true},            
            
            {label: 'Remaining Amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true},
            {label: 'Current Discount Amount', fieldName: 'currentDiscAmt', type: 'currency',editable:false},
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
            
            if(checkDiscount && selectedRows.length > 0 && component.get("v.discountType") == 'Discount Amount' && !(component.get("v.cancelSave"))){
            component.set("v.makePaymentButtonDisable",false);  
            }else if(selectedRows.length > 0 && component.get("v.discountType") == 'Discount Percentage'){
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