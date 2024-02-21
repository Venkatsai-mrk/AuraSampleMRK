({
    initPayloadCall : function(cmp, event, helper) {
        cmp.set("v.loaded",false);       
        var action = cmp.get("c.initPayloadCall");
        action.setParams({acctId:cmp.get("v.PatientId")
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try{                      
                    cmp.set("v.loaded",true); 
                    var result = response.getReturnValue();
                    console.log('result in private payment ----- ' + JSON.stringify(result));
                    cmp.set("v.totalUnAllocatedAmount_SumCount",result.amt); 
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
                            helper.setRemainingAmount(cmp, event, helper,element);
                            count++;
                        }); 
                        
                        cmp.set("v.Plist",allProcedureOnMT);
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
        component.set("v.Plist",data);
    },
    savePayments : function(cmp, event, helper,noAllocation){
        var noProcedureSelected = false;
        var sizeOfLst = cmp.get("v.selectedProcedureRecords").length;
        if(sizeOfLst==0){
            noProcedureSelected = true; 
        }
        cmp.set("v.loaded",false); 
        cmp.set("v.showConfirmDialog",false); 
        cmp.set("v.showConfirmDialogIfNoAllocation",false); 
        var amtAllocated = 0;
        if(noAllocation){
            amtAllocated = parseFloat(cmp.get("v.totalUnAllocatedAmount_SumCount"));
        }
        else {
            amtAllocated = parseFloat(cmp.get("v.amountAllocated")); 
        }
        var action = cmp.get("c.allocatePaymentInSystem");
        action.setParams({amountAllocated : amtAllocated,
                          acctId : cmp.get("v.PatientId"),
                          selectedProcedureRecords : JSON.stringify({'procedures' : cmp.get("v.selectedProcedureRecords")}),
                          totalAppliedAmount : parseFloat(cmp.get("v.totalAppliedAmount")),
                          totalUnAllocatedAmount : parseFloat(cmp.get("v.totalUnAllocatedAmount")),
                          noProcedureSelected : noProcedureSelected,
                          totalUnallocatedAmt : parseFloat(cmp.get("v.totalUnAllocatedAmount_SumCount"))
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                cmp.set("v.loaded",true); 
                helper.globalFlagToast(cmp, event, helper,'PAYMENT REGISTERED!', ' ','success');  
                if(!cmp.get("v.isPaymentTab")){ //Anusha LX3-5667 start
                    cmp.set("v.isModalOpen", true);//Modified false to true by Anusha -LX3-5747
                    helper.resetData(cmp, event, helper); //added by Anusha LX3-5747
                    helper.initPayloadCall(cmp, event, helper); //added by Anusha LX3-5747
                } //Anusha LX3-5667 end
                //$A.get('e.force:refreshView').fire(); //added by anusha LX3-5526
                $A.get("e.force:navigateToSObject").setParams({"recordId": recordId, "slideDevName": "related"}).fire();//Lokesh Added
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
    //resetData function added by Anusha -LX3-5747
    resetData : function(cmp){
        cmp.set("v.amountAllocated",0.0);
        cmp.set("v.procedureSearchParams","");
        cmp.set("v.selectedRows",[]);
        cmp.set("v.selectedProcedureRecords",[])
        cmp.set("v.makePaymentButtonDisable",true);
        cmp.set("v.totalAppliedAmount",0);
        cmp.set("v.totalUnAllocatedAmount",0);
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
        /* if(!amountPaid){
            helper.globalFlagToast(cmp, event, helper,'Amount to allocate is mandatory!', ' ','error');  
            isValid = false;
        }
        else if(parseInt(amountPaid)==0){
            helper.globalFlagToast(cmp, event, helper,'Amount to allocate cannot be zero!', ' ','error'); 
            isValid = false;
        }*/
        if(cmp.get("v.selectedProcedureRecords").length == 0){
            helper.globalFlagToast(cmp, event, helper,'Please select procedures!', ' ','error');
            isValid = false;   
        }
        return isValid;
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
            {label: 'S.No', fieldName: 'SNo', type: 'number', cellAttributes: { alignment: 'left' }, sortable :true} ,
            //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}  ,
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            {label: 'CPT Code', fieldName: 'procedureName', type: 'text', sortable :true}  ,
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true} ,
            {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amount (Charge Amount)', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true}  ,
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true} 
            ,            
            
            {label: 'Remaining amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true}  ,
            
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