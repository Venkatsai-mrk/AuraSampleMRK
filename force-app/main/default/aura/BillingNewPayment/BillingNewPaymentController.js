({  
    init: function (cmp, event, helper) {
        try{
            
            if(cmp.get("v.recordId") == "")
            {

            }
            else
            {
                cmp.set("v.isModalOpen",true);  
                cmp.set("v.PatientId", cmp.get("v.recordId")); 
                
                cmp.set("v.AllocPay",false);
                cmp.set("v.Allocate",false);
                helper.displayDetails(cmp, event, cmp.get("v.recordId"));
            }
            
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            today = yyyy +'-'+ mm +'-' + dd ;
            cmp.set("v.Tdate",today);
            console.log('#### Tdate:  ' + cmp.get('v.Tdate'));
            cmp.set("v.hideOrShowClaims",false);
            cmp.set('v.columns', [
                {label: 'S.No', fieldName: 'SNo', type: 'text'}  ,
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text'}  ,
                {label: 'CPT Code', fieldName: 'ElixirSuite__Cpt_Codes__c', type: 'text'}  ,
                {label: 'Procedure Date', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', typeAttributes: {  
                    day: 'numeric',  
                    month: 'short',  
                    year: 'numeric'  
                }},
                {label: 'Claim/Non-Claim', fieldName: 'Claim', type:'url',
                 typeAttributes: {
                     label: { 
                         fieldName: 'ClaimName' 
                     },
                     target : '_blank'
                 }
                },
                {label: 'Insurance Outstanding', fieldName: 'InsuranceOutstanding', type : 'currency'},
                {label: 'Adjustments', fieldName: 'ElixirSuite__Payment_Adjustments__c', type : 'currency'},
                //{label: 'Patient Outstanding', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency'},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency'},
                {label: 'Patient Payment', fieldName: 'ElixirSuite__Patient_Payments__c', type : 'currency'},
                {label: 'Original Price', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency'},
                //{label: 'Amount Paid', fieldName: 'Received_Amount__c', type: 'currency'},
                //{label: 'Remaining Amount', fieldName: 'RemaningAmount', type: 'currency'},
                {label: 'Credit', fieldName: 'ElixirSuite__Credit_Amount__c', type: 'currency'},
                {label: 'Remaining Amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency'},
                
            ]);
                
                
                cmp.set('v.columns4', [
                //{label: 'S.No', fieldName: 'SNo', type: 'text', sortable :true}  ,
                //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}  ,
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
                //{label: 'Procedure Code', fieldName: 'ProcedureCode', type: 'text', sortable :true}  , //commented this line by Anusha LX3-5519
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
                {label: 'Claim Generated', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c', type: 'text', sortable :true},
                {label: 'Claim No', fieldName: 'ProcedureClaim', type : 'text', sortable :true},
                {label: 'Billed Amt.', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true},
                {label: 'Primary Insurance Paid Amt.', fieldName: 'ElixirSuite__Insurance_Paid__c', type : 'currency', sortable :true},
                {label: 'Secondary Insurance Paid Amt.', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type : 'currency', sortable :true},
                {label: 'Adjustment Amt.', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type : 'currency', sortable :true},
                {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true},
                {label: 'Patient Paid Amt.', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true},
                
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
            helper.getFormSetting(cmp); //Anusha LX3-5820
        }
        catch(e){
            alert(e)
        }
    },
    
    registerPrivatePayment : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("privateRegisterAPayment");
        childComponent.registerThePayment();
        
    },
    
    allocatePrivatePayment : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("privateAllocatePayment");
        childComponent.allocateThePayment();
        
    },
    
    registerPaymentSchedule : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("privatePaymentSchedule");
        childComponent.allocateThePaymentSchedule();
        
    },
    
    addPrivateDiscount : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("privatePaymentAddDiscount");
        childComponent.addDiscountInPrivate();
        
    },
    
    allocatePrivateDiscount : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("privatePaymentAllocateDiscount");
        childComponent.allocateDiscountInPrivate();
        
    },
     processRefunds : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("processRefund");
        childComponent.processRefunds();
        
    },
    
    createRefundReq : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("processRefund");
        childComponent.processRefundRequest();
        
    },
      generateRefundStatement : function(cmp, event) {
        var changeValue = event.getParam("checked");
          console.log('changeValue--'+changeValue);
         //Call Child aura method
       /* var childComponent = cmp.find("processRefund");
        var message = childComponent.processRefunds();*/
    
    },
    fromChild : function(cmp, event){
        
        var firstLb = event.getParam("firstLabel");
        var secondLb = event.getParam("secondLabel");
        
        var firstVl = event.getParam("firstValue");
        var secondVl = event.getParam("secondValue");
        
        cmp.set("v.PrivateAmountLabel",firstLb);
        cmp.set("v.TotalPrivateUnallocatedAmountLabel",secondLb);
        
        cmp.set("v.PrivateAppliedAmountInsurance",firstVl);
        cmp.set("v.TotalPrivateUnallocatedAmountInsurance",secondVl);
        
        
        
    },
    
    
    parentComponentEvent : function(cmp, event,helper) { 
        
        var accId = event.getParam("SelectedId"); 
        console.log('Params received: ' + accId);
        cmp.set("v.PatientId", accId);
        if(cmp.get("v.valueForPrivatePayment") == 'Register a Payment' && cmp.get("v.typeOfPayment")=="Private Payment"){ //Anusha-start LX3-5599
            cmp.find("privateRegisterAPayment").reInitialize();
        }
        if(cmp.get("v.valueForPrivatePayment") == 'Allocate Payments' && cmp.get("v.typeOfPayment")=="Private Payment"){ 
            cmp.find("privateAllocatePayment").reInitialize();  //Anusha LX3-5525
        }
        if(cmp.get("v.valueForPrivatePayment") == 'Payment schedule' && cmp.get("v.typeOfPayment")=="Private Payment"){
            cmp.find("privatePaymentSchedule").reInitialize(); //Anusha LX3-5527
        } 
        if(cmp.get("v.valueForPrivatePayment") == 'Add Discount' && cmp.get("v.typeOfPayment")=="Private Payment"){ 
            cmp.find("privatePaymentAddDiscount").reInitialize();  
        } //Anusha -end LX3-5599
        if(cmp.get("v.valueForPrivatePayment") == 'Allocate Discount' && cmp.get("v.typeOfPayment")=="Private Payment"){ 
            cmp.find("privatePaymentAllocateDiscount").reInitialize();  
        } 
        
        
        helper.displayDetails(cmp, event, accId);
        
        
        
    },
    
    getField: function (cmp, evt, helper) {
        if(cmp.find('select1').get('v.value')==''){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='Cheque'){
            cmp.set("v.cheque",true);
            cmp.set("v.Credit",false);  
            cmp.set("v.creditCardId",''); 
        }
        if(cmp.find('select1').get('v.value')=='Cash'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false);
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='Credit Card'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",true); 
             cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='EFT'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.creditCardId",'');
            cmp.set("v.chequeNo",'');
        }
        helper.registerThePaymentButtonHandler(cmp,evt,helper); //Anusha - 30/09/2022
    },
    getField2: function (cmp) {
        
        if(cmp.find('select2').get('v.value')=='Cheque'){
            cmp.set("v.cheque",true);
            cmp.set("v.Credit",false);  
        }
        if(cmp.find('select2').get('v.value')=='Cash'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
        }
        if(cmp.find('select2').get('v.value')=='Credit Card'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",true); 
        }
        if(cmp.find('select2').get('v.value')==''){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
        }
    },
    handleChange: function (cmp, event) {
        cmp.set("v.toggleValue",'By Procedure'); //Anusha
        cmp.set("v.hideOrShowClaims",false); //Anusha
        cmp.set("v.patOutStndAmount",false);
        cmp.set("v.patOutStndAmountRegister",false);
        var changeValue = event.getParam("value");
        if(changeValue =='Allocate Payments'){
            cmp.set("v.makePay",false);
            cmp.set("v.cheque",false); //Anusha
            cmp.set("v.isAllocatedAmtExceed",false);
            if(cmp.get("v.PatientId") != "")
            {
                cmp.set("v.AllocPay",true);
                cmp.set("v.Credit",false); 
                cmp.set("v.Allocate",true);
                cmp.set("v.paySched",false);
                
                //cmp.set("v.PaymentType",'Allocated')
                //cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
                if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
                
            } 
            else
            {
                cmp.set("v.AllocPay",true); //Anusha - changed false to true LX3-5541
                cmp.set("v.Credit",false); 
                cmp.set("v.Allocate",false); 
                //cmp.set("v.PaymentType",'Allocated')
                //cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
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
            cmp.set("v.TNumber", "");
            cmp.set('v.myCurrency',0);
            cmp.set("v.addNote", "");
            
            cmp.set("v.allocatePaymentButtonDisable", true);
            cmp.set("v.TotalAppliedAmountInsurance", 0);
            cmp.set("v.TotalUnallocatedAmountInsurance", 0);
            cmp.set("v.TotalAppliedForAllocatePayment", 0);
            cmp.set("v.TotalUnallocatedForAllocatePayment",0 )
            cmp.set('v.disableCheckbox',false);//17-02-2023
           
                        
        }
        else if(changeValue =='Make a Payment'){
            //Anusha
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            today = yyyy +'-'+ mm +'-' + dd ;
            cmp.set("v.Tdate",today); //end
            cmp.set("v.makePay",true);
            cmp.set("v.amountAllocated",0);//Anusha
            if(cmp.get("v.PatientId") != "")
            {
                cmp.set("v.AllocPay",false);
                cmp.set("v.paySched",false);
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
                //cmp.set("v.PaymentType",'Unallocated');
                //cmp.set("v.AmountDue",0);
                //cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));   
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
            cmp.set("v.TNumber", "");
            cmp.set('v.myCurrency',0);
            cmp.set("v.addNote", "");
            
            cmp.set("v.makePaymentButtonDisable", true);
            cmp.set("v.TotalAppliedAmountInsurance", 0);
            cmp.set("v.TotalUnallocatedAmountInsurance", 0);
            
            
        }
        else if(changeValue =='Payment Plan'){
                cmp.set("v.paySched",true);
                cmp.set("v.makePay",false); //Anusha 01/10/2022
            	cmp.set("v.AllocPay",false);
                cmp.set("v.Allocate",false);
            cmp.set("v.TotalAppliedAmountInsurance", 0);
            cmp.set("v.TotalUnallocatedAmountInsurance", 0);
            /*cmp.set("v.TotalAppliedForAllocatePayment", 0);
            cmp.set("v.TotalUnallocatedForAllocatePayment",0 )*/
               /* if(cmp.get("v.PatientId") != "")
                {
                    cmp.set("v.AllocPay",false);
                    cmp.set("v.makePay",true);
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
                    //cmp.set("v.PaymentType",'Unallocated');
                    //cmp.set("v.AmountDue",0);
                    //cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));   
                    if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
                    {
                        cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
                    }
                    else
                    {
                        cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                    }
                }*/
            }
        
    } ,
    
    handleToggleChange : function(cmp, event, helper)
    {
        cmp.set("v.makePaymentButtonDisable", true);
        cmp.set('v.AmountDue',0);
        cmp.set("v.PayTransId",[]);
        cmp.set("v.TotalAppliedForAllocatePayment", 0);
        cmp.set("v.TotalUnallocatedForAllocatePayment",0 )
        var changeValue = event.getParam("value");
        console.log('#### Toggle Value : ' + changeValue);
        if(changeValue == 'By Claims')
        {
            cmp.set('v.selectAllClaims',false);
            cmp.set("v.NoOfClaimsSelected",0);
            var action = cmp.get("c.getClaimsData");
            action.setParams({
                accId : cmp.get("v.PatientId")
            });
            action.setCallback(this, function(resp)
                               {
                                   if(resp.getState() == 'SUCCESS')
                                   {
                                       if(resp.getReturnValue() != null)
                                       {
                                           console.log('#### Claims Wrapper List : ' + JSON.stringify(resp.getReturnValue()));
                                           var ClaimsList = resp.getReturnValue();
                                           for(var i in resp.getReturnValue())
                                           {
                                               console.log('inside ' + i);
                                               console.log('___ ' + resp.getReturnValue()[i].claimName);
                                               ClaimsList[i]['Selected'] = false;
                                               ClaimsList[i]['ShowProc'] = false;
                                               ClaimsList[i]['NoOfSelectedProcs'] = 0;
                                               ClaimsList[i]['ClaimName'] = resp.getReturnValue()[i].claimName;
                                               ClaimsList[i]['ClaimId'] = resp.getReturnValue()[i].claimId;
                                               ClaimsList[i]['OpenProc'] = resp.getReturnValue()[i].openProc;
                                               ClaimsList[i]['TotalAllowed'] = resp.getReturnValue()[i].totalAllowed;
                                               ClaimsList[i]['InsuranceResp'] = resp.getReturnValue()[i].insuranceResp;
                                               ClaimsList[i]['PatientResp'] = resp.getReturnValue()[i].patientResp;
                                               
                                               if('procWrap' in resp.getReturnValue()[i] && resp.getReturnValue()[i].procWrap != null && resp.getReturnValue()[i].procWrap != undefined)
                                               {
                                                   
                                                   var procWrap = resp.getReturnValue()[i].procWrap;
                                                   var count = 1;
                                                   for(var j in resp.getReturnValue()[i].procWrap)
                                                   {
                                                       procWrap[j]['SNo'] = count+'.';
                                                       procWrap[j]['Selected'] = false;
                                                       procWrap[j]['ProcId'] = resp.getReturnValue()[i].procWrap[j].Id;
                                                       //Anusha Start 30/09/2022
                                                       let patientOutstanding=resp.getReturnValue()[i].procWrap[j].ElixirSuite__Patient_Responsibility__c-resp.getReturnValue()[i].procWrap[j].ElixirSuite__Total_Paid_Amount__c; 
                                                       procWrap[j]['patientOutstanding']=patientOutstanding; //resp.getReturnValue()[i].procWrap[j].ElixirSuite__Claim_Generation__c?patientOutstanding:'0'; - commented by anusha 03/10/222
                                                       //Anusha END 30/09/2022
                                                       procWrap[j]['ElixirSuite__PatientOutstanding__c'] = procWrap[j].ElixirSuite__Patient_Responsibility__c - (procWrap[j].ElixirSuite__Total_Paid_Amount__c); //Added by Anusha - 06/10/22
                                                       procWrap[j]['ElixirSuite__Procedure_Name__c'] = resp.getReturnValue()[i].procWrap[j].ElixirSuite__Procedure_Name__c;
                                                       procWrap[j]['ElixirSuite__Date_Of_Service__c'] = resp.getReturnValue()[i].procWrap[j].ElixirSuite__Date_Of_Service__c;
                                                       procWrap[j]['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = resp.getReturnValue()[i].procWrap[j].ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                                                       if (isNaN(resp.getReturnValue()[i].procWrap[j].ElixirSuite__Patient_Responsibility__c)) 
                                                       {
                                                           procWrap[j]['ElixirSuite__Patient_Responsibility__c'] = 0;
                                                       }
                                                       else
                                                       {
                                                           procWrap[j]['ElixirSuite__Patient_Responsibility__c'] = resp.getReturnValue()[i].procWrap[j].ElixirSuite__Patient_Responsibility__c;
                                                       }
                                                       count = count + 1;
                                                   }
                                                   console.log('procWrap@@'+JSON.stringify(procWrap));
                                                   ClaimsList[i]['procWrap'] = procWrap;
                                                   cmp.set("v.claimProcedurePaylist",procWrap);
                                               }
                                           }
                                           cmp.set('v.ClaimsList',ClaimsList);
                                           console.log(JSON.parse(JSON.stringify(cmp.get('v.ClaimsList'))));
                                           console.log('#### ClaimsList : ' + JSON.stringify(cmp.get('v.ClaimsList')));
                                       }
                                   }
                                   if((cmp.get('v.value') == 'Make a Payment' )){
                                       helper.calOnReason(cmp, event, helper);  
                                   }
                               });
            $A.enqueueAction(action);
            cmp.set("v.hideOrShowClaims",true);
            
            
        }
        else if(changeValue == 'By Procedure')
        {
            cmp.set('v.selectedInsurancePaylist',[]);
            cmp.set("v.hideOrShowClaims",false);
            if((cmp.get('v.value') == 'Make a Payment' )){
                helper.calOnReason(cmp, event, helper);  
            }
        }
    },
    
    handleOnClaimSelection : function(cmp, event, helper)
    {
        var getClaimId = event.getSource().get("v.name");
        var getSelected = event.getSource().get("v.checked");
        var ClaimsList = cmp.get("v.ClaimsList");
        var totalAmount = cmp.get('v.AmountDue');
        var selectedIds = cmp.get("v.PayTransId");
        var NoOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");
        
        //var sumOfAmountPaid = parseFloat(cmp.get("v.TotalAppliedAmountInsurance")); //Anusha 04/10/22;
        //var sumOfAppliedAllocatePaid = parseFloat(cmp.get("v.TotalAppliedForAllocatePayment"));
        if(getSelected == true && cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
        {
            cmp.set("v.makePaymentButtonDisable", false);
        }
        if(getSelected == true)
        {
            NoOfClaimsSelected = NoOfClaimsSelected + 1;
        }
        else
        {
            NoOfClaimsSelected = NoOfClaimsSelected - 1;
        }
        console.log('#### claimsLength -- ' + ClaimsList.length);
        console.log('#### NoOfClaimsSelected ---- ' + NoOfClaimsSelected);
        if(ClaimsList.length == NoOfClaimsSelected)
        {
            cmp.set('v.selectAllClaims',true);
        }
        else
        {
            cmp.set('v.selectAllClaims',false);
        }
        cmp.set("v.NoOfClaimsSelected",NoOfClaimsSelected);
        for(var i in ClaimsList)
        {
            if(getClaimId == ClaimsList[i].claimId)
            {
                if('procWrap' in ClaimsList[i])
                {
                    var ProcWrapList = ClaimsList[i].procWrap;
                    for(var j in ProcWrapList)
                    {
                        if(getSelected == true && ProcWrapList[j].Selected != true)
                        {
                            totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                            selectedIds.push(ProcWrapList[j].ProcId);
                            //sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                            //sumOfAppliedAllocatePaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                            
                        }
                        if(getSelected == false && ProcWrapList[j].Selected != false)
                        {
                            //sumOfAmountPaid-=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 04/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                            //sumOfAppliedAllocatePaid-=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                            totalAmount = totalAmount - ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                            for( var ind = 0; ind < selectedIds.length; ind++)
                            { 
                                if( selectedIds[ind] == ProcWrapList[j].ProcId) 
                                { 
                                    selectedIds.splice(ind, 1); 
                                    ind--;
                                }
                            }
                        }
                        ProcWrapList[j].Selected = getSelected;
                    }
                    ClaimsList[i].procWrap = ProcWrapList;
                }
                if(getSelected == true)
                {
                    ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].OpenProcs;
                }
                else
                {
                    ClaimsList[i].NoOfSelectedProcs = 0;
                    
                }
            }
        }
        
        

        
       
        
        cmp.set('v.ClaimsList',ClaimsList);
        cmp.set('v.AmountDue',totalAmount);
        cmp.set("v.PayTransId",selectedIds);
        
        if(cmp.get('v.value') == 'Make a Payment')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        else if(cmp.get('v.value') == 'Allocate Payments')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        //added
            else if(cmp.get('v.value') == 'Payment schedule')
            {
                if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
            }
        console.log('#### selectedIds CLAIMS  - ' + selectedIds);
       
        
        //
        if((cmp.get('v.value') == 'Make a Payment' )) 
        {
            helper.calOnReason(cmp, event, helper);
        }
        if(cmp.get('v.value') == 'Allocate Payments'){
            
           helper.calOnReasonForAllocate(cmp, event, helper); 
        }
        //
        //helper.registerThePaymentButtonHandler(cmp, event, helper); //Anusha - 30/09/2022
    },
    
    handleOnProcSelection : function(cmp, event, helper)
    {
        var getClaimId = event.getSource().get("v.value");
        var getProcId = event.getSource().get("v.name");
        var getSelected = event.getSource().get("v.checked");
        var ClaimsList = cmp.get("v.ClaimsList");
        var totalAmount = cmp.get('v.AmountDue');
        var selectedIds = cmp.get("v.PayTransId");
        var NoOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");
        //var sumOfAmountPaid = parseFloat(cmp.get("v.TotalAppliedAmountInsurance")); //Anusha 04/10/22
        //var sumOfAppliedAllocatePaid = parseFloat(cmp.get("v.TotalAppliedForAllocatePayment"));
        if(getSelected == true && cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
        {
            cmp.set("v.makePaymentButtonDisable", false);
        }
        if(getSelected == true && cmp.get('v.amountAllocated')>0) //LX3-6100
        {
            cmp.set("v.allocatePaymentButtonDisable", false);
        }else{
            cmp.set("v.allocatePaymentButtonDisable", true); 
        }
        
        for(var i in ClaimsList)
        {
            if(getClaimId == ClaimsList[i].ClaimId)
            {
                if('procWrap' in ClaimsList[i])
                {
                    var ProcWrapList = ClaimsList[i].procWrap;
                    for(var j in ProcWrapList)
                    {
                        if(getProcId == ProcWrapList[j].ProcId)
                        {
                            if(getSelected == true)
                            {
                                totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                                //sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                //sumOfAppliedAllocatePaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                selectedIds.push(getProcId);
                                if(ClaimsList[i].OpenProc == 1)
                                {
                                    ClaimsList[i].Selected = true;
                                    ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].OpenProc;
                                }
                                else
                                {
                                    ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].NoOfSelectedProcs + 1;
                                }
                            }
                            if(getSelected == false)
                            {
                                //sumOfAmountPaid-=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 04/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                //sumOfAppliedAllocatePaid-=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 03/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                totalAmount = totalAmount - ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                                ClaimsList[i].Selected = false;
                                if(ClaimsList[i].OpenProc == 1)
                                {
                                    ClaimsList[i].NoOfSelectedProcs = 0;
                                }
                                else
                                {
                                    ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].NoOfSelectedProcs - 1;
                                }
                                for( var ind = 0; ind < selectedIds.length; ind++)
                                { 
                                    if( selectedIds[ind] == getProcId) 
                                    { 
                                        selectedIds.splice(ind, 1); 
                                        ind--;
                                        break;
                                    }
                                }
                                NoOfClaimsSelected = NoOfClaimsSelected - 1;
                            }
                            break;
                        }
                    }
                    if(ClaimsList[i].NoOfSelectedProcs == ClaimsList[i].OpenProc)
                    {
                        ClaimsList[i].Selected = true;
                        NoOfClaimsSelected = NoOfClaimsSelected + 1;
                        
                    }
                    console.log('ClaimsList[i].NoOfSelectedProcs --- ' + ClaimsList[i].NoOfSelectedProcs);
                    console.log('ClaimsList[i].OpenProc --- ' + ClaimsList[i].OpenProc);
                }
                break;
            }
        }
        
        
        if(NoOfClaimsSelected == ClaimsList.length)
        {
            cmp.set("v.selectAllClaims",true);
        }
        else
        {
            cmp.set("v.selectAllClaims",false);
        }
        cmp.set("v.NoOfClaimsSelected",NoOfClaimsSelected);
        cmp.set('v.ClaimsList',ClaimsList);
        cmp.set('v.AmountDue',totalAmount);
        cmp.set("v.PayTransId",selectedIds);
        
        
        
        if(cmp.get('v.value') == 'Make a Payment')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        else if(cmp.get('v.value') == 'Allocate Payments')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        //Added new
            else if(cmp.get('v.value') == 'Payment schedule')
            {
                if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
            }
        //added new
        console.log('#### selectedIds - ' + selectedIds);
        
        //
        if((cmp.get('v.value') == 'Make a Payment' )) 
        {
            helper.calOnReason(cmp, event, helper);
        }
        if(cmp.get('v.value') == 'Allocate Payments'){
            
           helper.calOnReasonForAllocate(cmp, event, helper); 
        }
        //
        //helper.registerThePaymentButtonHandler(cmp, event, helper); //Anusha - 30/09/2022
        
    },
    
    getSelectAllClaims : function(cmp, event, helper)
    {
        var getSelected = event.getSource().get("v.checked");
        var ClaimsList = cmp.get("v.ClaimsList");
        var totalAmount = 0;
        var selectedIds = [];
        var ProcWrapList = [];
        //var sumOfAmountPaid = parseFloat(cmp.get("v.TotalAppliedAmountInsurance")); //Anusha 06/10/22
        if(getSelected == true && cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
        {
            cmp.set("v.makePaymentButtonDisable", false);
        }
        
        if(getSelected == true)
        {
            for(var i in ClaimsList)
            {
                if('procWrap' in ClaimsList[i])
                {
                    ProcWrapList = ClaimsList[i].procWrap;
                    for(var j in ProcWrapList)
                    {
                        totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                        //sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 06/10/22
                        selectedIds.push(ProcWrapList[j].ProcId); 
                        ProcWrapList[j].Selected = true;
                    }
                    ClaimsList[i].procWrap = ProcWrapList;
                    ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].OpenProcs;
                }
                ClaimsList[i].Selected = true;
            }
            cmp.set("v.NoOfClaimsSelected",ClaimsList.length);
            
        }
        else if(getSelected == false)
        {
            for(var a in ClaimsList)
            {
                if('procWrap' in ClaimsList[a])
                {
                    ProcWrapList = ClaimsList[a].procWrap;
                    for(var b in ProcWrapList)
                    {
                        ProcWrapList[b].Selected = false;
                    }
                    ClaimsList[a].procWrap = ProcWrapList;
                    ClaimsList[a].NoOfSelectedProcs = 0;
                }
                ClaimsList[a].Selected = false;
            }
            cmp.set("v.NoOfClaimsSelected",0);
            //sumOfAmountPaid=0; //Anusha 06/10/22
        }
        cmp.set('v.ClaimsList',ClaimsList);
        cmp.set('v.AmountDue',totalAmount);
        cmp.set("v.PayTransId",selectedIds);
        //Added if Anusha - start- 6/10/22
       /* if(cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment') 
        {
            cmp.set('v.TotalAppliedAmountInsurance',sumOfAmountPaid); 
        } 
        cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.myCurrency') - cmp.get('v.TotalAppliedAmountInsurance')); 
        */
        //Anusha - end- 6/10/22
        if(cmp.get('v.value') == 'Make a Payment')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        else if(cmp.get('v.value') == 'Allocate Payments')
        {
            if(cmp.get('v.AmountDue') > cmp.get("v.amountAllocated"))
            {
                cmp.set("v.AmountApplied",cmp.get("v.amountAllocated"));
            }
            else
            {
                cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
            }
        }
        //Added new
            else if(cmp.get('v.value') == 'Payment schedule')
            {
                if(cmp.get('v.AmountDue') > cmp.get("v.myCurrency"))
                {
                    cmp.set("v.AmountApplied",cmp.get("v.myCurrency"));
                }
                else
                {
                    cmp.set("v.AmountApplied",cmp.get("v.AmountDue"));
                }
            }
        if((cmp.get('v.value') == 'Make a Payment' )) 
        {
            helper.calOnReason(cmp, event, helper);
        }
        if(cmp.get('v.value') == 'Allocate Payments'){
            
           helper.calOnReasonForAllocate(cmp, event, helper); 
        }
        //Added new
        console.log('#### selectedIds CLAIMS  - ' + selectedIds);
    },
    
    closeModel: function(component) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    setValue: function(component, event, helper) {
        
        // Set isModalOpen attribute to false  
        //component.set("v.AmountApplied",component.get("v.myCurrency"));
        if(component.get('v.AmountDue') > component.get("v.myCurrency"))
        {
            component.set("v.AmountApplied",component.get("v.myCurrency"));
        }
        else
        {
            component.set("v.AmountApplied",component.get("v.AmountDue"));
        }
        
        var amountPaid = event.getSource().get('v.value');
        var schList = [];
        var length =0;
        schList = component.get("v.selectedSchedules");
        if(schList != null)
        {
            length = schList.length;
        }
        
        if(amountPaid > 0  ) 
        {
            if(component.get('v.value') == 'Payment schedule')
            {
                if(length > 0)
                {
                    component.set("v.makePaymentButtonDisable", false);
                }
                else
                {
                    component.set("v.makePaymentButtonDisable", true);
                }
            }
            else
            {
                // component.set("v.makePaymentButtonDisable", false);
            }
        } 
        else 
        {
            component.set("v.makePaymentButtonDisable", true);
        }
        if((component.get('v.value') == 'Make a Payment' )){
            helper.calOnReason(component, event, helper);  
        }
        
        if(component.get("v.NetAmount") > 0 && amountPaid > component.get("v.NetAmount")) {
            component.set("v.isAllocatedAmtExceedPaSh", true);
            component.set("v.makePaymentButtonDisable", true);
        }else if(amountPaid > 0 && component.get("v.NetAmount") > 0 && amountPaid  <= component.get("v.NetAmount")) {
            component.set("v.isAllocatedAmtExceedPaSh", false);
            component.set("v.makePaymentButtonDisable", false);
        }
        helper.registerThePaymentButtonHandler(component,event,helper); //Anusha - 30/09/2022
    }, 
    
    selectedRowsOne : function(component, event) {
        var amountPaid = component.get("v.myCurrency");
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        var selectedRows =  event.getParam('selectedRows'); 
        var selectedIds = [];
        var netAmount = [];
        
        for (var i = 0; i < selectedRows.length; i++) 
        {
            selectedIds.push(selectedRows[i].Id);
            netAmount.push(selectedRows[i].ElixirSuite__Remaining_Amount__c);
        }
        component.set("v.NetAmount",Number(netAmount));
        component.set("v.selectedSchedules",selectedIds);
        
        if(amountPaid > 0 && component.get("v.NetAmount") > 0 && amountPaid > component.get("v.NetAmount")) {
            component.set("v.isAllocatedAmtExceedPaSh", true);
            component.set("v.makePaymentButtonDisable", true);
        }else {
            component.set("v.isAllocatedAmtExceedPaSh", false);
            component.set("v.makePaymentButtonDisable", false);
        }   
        
        var action = component.get("c.getSchedules");
        action.setParams({lstmasterId:selectedIds
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.scheduleList",response.getReturnValue());
            }
            component.set("v.hideSchedule",true);
        });
        $A.enqueueAction(action);
    }, 
    
    selectedRows : function(component, event, helper) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        var selectedIds = [];
        var selectedAmount = [];
        
        var PayTransId = component.get('v.PayTransId');
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedInsurancePaylist",selectedRows);
        
        
        
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
            selectedAmount.push(selectedRows[i].ElixirSuite__PatientOutstanding__c);
            if(PayTransId == null || PayTransId == '' || PayTransId.length == 0)
            {
                PayTransId.push(selectedRows[i].Id);
            }
            else if(!PayTransId.includes(selectedRows[i].Id))
            {
                PayTransId.push(selectedRows[i].Id);
            }
        }
        console.log('#### IDs'+PayTransId);
        console.log('#### selected IDs'+selectedIds);
        for(var j=0; j < PayTransId.length; j++)
        {
            if(!selectedIds.includes(PayTransId[j]))
            {
                PayTransId.splice(j, 1); 
                j--;
            }
        }
        console.log('IDs'+PayTransId);
        
          
        //
        if((component.get('v.value') == 'Make a Payment' )) 
        {
            helper.calOnReason(component, event, helper);
        }
        if(component.get('v.value') == 'Allocate Payments'){
            
           helper.calOnReasonForAllocate(component, event, helper); 
        }
        //
        
        
        
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
        else if(component.get('v.value') == 'Allocate Payments')
        {
            if(component.get('v.AmountDue') > component.get("v.amountAllocated"))
            {
                component.set("v.AmountApplied",component.get("v.amountAllocated"));
            }
            else
            {
                component.set("v.AmountApplied",component.get("v.AmountDue"));
            }
        }
            else if(component.get('v.value') == 'Payment schedule')
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
         
        
    },
    handleRowAction: function(component, event, helper){
        var action = event.getParam('action');
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
    },
    makeTranscation :function(cmp) {
        
        var error = false;
        
        if(cmp.get('v.payReasonVal') == 'Unallocated Payment' && cmp.get('v.value') == 'Make a Payment')
        {
            console.log('Inside Unallocated Payment');
            cmp.set('v.PayTransId',[]);
            console.log('PayTransId : ' + cmp.get('v.PayTransId'));
        }
        if(cmp.get('v.payReasonVal') == 'Applied Payment' && (cmp.get('v.PayTransId') == null || cmp.get('v.PayTransId') == '') && cmp.get('v.value') == 'Make a Payment')
        {
            console.log('Inside Applied Payment');
            /* error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'Please select the Procedure(s)',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEvent.fire();*/
            cmp.get('v.makePaymentButtonDisable', true);
        }
        
        if(cmp.get('v.value') == 'Allocate Payments')
        {
            cmp.set("v.myCurrency",0);
            cmp.set("v.payReasonVal",'Unallocated Payment');
            console.log('inside allocate payments : ' + error);
            if(cmp.get('v.PayTransId') == null || cmp.get('v.PayTransId') == '')
            {
                error = true;
                console.log('inside allocate payments 2 : ' + error);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'Please select the Procedure(s)',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }
        if(cmp.get('v.payReasonVal') == '' && cmp.get('v.value') == 'Make a Payment')
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'Please select the Payment Reason',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        
        if(cmp.get('v.PaySchedulist') == null && cmp.get('v.value') == 'Payment schedule')
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'no records present..',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        
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
            
            console.log('@@ selected schedules : ' + cmp.get('v.selectedSchedules'));
            console.log('@@ amount paid for schedule : ' + cmp.get('v.myCurrency2'));
            
            var action = cmp.get("c.SaveData");
            action.setParams({
                accId:cmp.get("v.PatientId"),
                amountPaid:cmp.get("v.myCurrency"),
                amountAllocated:cmp.get("v.amountAllocated"),
                payDate:cmp.get("v.Tdate"),	
                payTrans:cmp.get("v.PayTransId"),
                payReason : cmp.get('v.payReasonVal'),
                lst_seledSheduls : cmp.get('v.selectedSchedules'),
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
                    var url = '';
                     var newWindow;	
                    if(cmp.get('v.generateReceipt') == true && (cmp.get('v.payReasonVal') == 'Applied Payment')){
                        if(cmp.get('v.value') == 'Make a Payment'){
                            url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+response.getReturnValue();
                            newWindow = window.open(url);	
                            newWindow.focus();	
                            //window.open('/apex/GenerateUpfrontPaymentReceipt?amountPaid='+cmp.get('v.myCurrency')+'&patientId='+cmp.get('v.PatientId')+'&paymentDate='+cmp.get('v.Tdate'));
                        }
                        else if(cmp.get('v.value') == 'Allocate Payments'){
                            url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+response.getReturnValue();
                            newWindow = window.open(url);	
                            newWindow.focus();	
                            //window.open('/apex/GenerateUpfrontPaymentReceipt?amountPaid='+cmp.get('v.amountAllocated')+'&patientId='+cmp.get('v.PatientId')+'&paymentDate='+cmp.get('v.Tdate'));
                        }
                    }
                    cmp.set("v.isModalOpen", false);
                }
            });
            $A.enqueueAction(action);     
        }
    },
    validateAmtAllocated : function(component, event, helper) {
        
        var totalUnAllocatedAmount = component.get("v.totalUnAllocatedAmount");
        var amountAllocated = event.getSource().get('v.value');
        
        
        if(parseFloat(amountAllocated) > parseFloat(totalUnAllocatedAmount)) {
            component.set("v.isAllocatedAmtExceed", true);
            component.set("v.allocatePaymentButtonDisable", true);
        } else {
            component.set("v.isAllocatedAmtExceed", false);
            component.set("v.allocatePaymentButtonDisable", false);
        }
        
        
        
        helper.calOnReasonForAllocate(component, event, helper);
        
        //component.set('v.AmountApplied',amountAllocated);
        if(component.get('v.AmountDue') > component.get("v.amountAllocated"))
        {
            component.set("v.AmountApplied",component.get("v.amountAllocated"));
        }
        else
        {
            component.set("v.AmountApplied",component.get("v.AmountDue"));
        }
        
    },
    
    getPaymentReason : function(cmp, event, helper)
    {
        /*
        if(cmp.find('payReason').get('v.value')=='Unallocated Payment'){
            cmp.set('v.generateReceipt',false);
            cmp.set('v.disableCheckbox',true);
            var ClaimsList = cmp.get("v.ClaimsList");
            var totalAmount = cmp.get('v.AmountDue');
            var selectedIds = [];
            
            for(var i in ClaimsList)
            {
                if('ProcWrap' in ClaimsList[i])
                {
                    var ProcWrapList = ClaimsList[i].ProcWrap;
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
                var amt =0;
                cmp.set("v.makePaymentButtonDisable", false);
                cmp.set("v.TotalAppliedAmountInsurance", amt);
                cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.myCurrency') - amt);
            }
        }
        else if(cmp.find('payReason').get('v.value')=='Applied Payment')
        {
            cmp.set('v.generateReceipt',false);
            cmp.set('v.disableCheckbox',false);
            if(cmp.get('v.myCurrency') != null && cmp.get('v.myCurrency') != 0)
            {
                var amt =0;
                var rowList = cmp.get('v.selectedInsurancePaylist');
                if(cmp.get('v.toggleValue')!='By Claims'){ 
                    if(rowList.length > 0){
                        
                        cmp.set("v.makePaymentButtonDisable", false);
                        
                        
                        for(var i=0; i<rowList.length; i++){
                        }
                    }else{
                        cmp.set("v.makePaymentButtonDisable", true);
                    }
                    if(parseFloat(amt) > parseFloat(cmp.get('v.myCurrency'))){
                        cmp.set('v.TotalAppliedAmountInsurance',cmp.get('v.myCurrency'));   
                    }else{
                        cmp.set('v.TotalAppliedAmountInsurance',parseFloat(amt));  
                    }
                    
                    //cmp.set("v.TotalAppliedAmountInsurance", amt);
                    cmp.set("v.TotalUnallocatedAmountInsurance", parseFloat(cmp.get('v.myCurrency')) - cmp.get('v.TotalAppliedAmountInsurance'));
                    //cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.myCurrency') - amt);
                    cmp.set("v.NoOfClaimsSelected",0);
                }
                
                else if(cmp.get('v.toggleValue')=='By Claims'){
                    
                    var ClaimsList = cmp.get("v.ClaimsList");
                    
                    var sumOfAmountPaid = 0;
                    if(cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
                    {
                        cmp.set("v.makePaymentButtonDisable", false);
                    }
                    for(var i in ClaimsList)
                    {
                        if('ProcWrap' in ClaimsList[i])
                        {
                            var ProcWrapList = ClaimsList[i].ProcWrap;
                            for(var j in ProcWrapList)
                            {
                                if(ProcWrapList[j].Selected)
                                {
                                    sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 04/10/22 //Anusha - Added patientOutstanding greater than 0 check - 06/10/22
                                }
                            }
                        }
                    }
                    if((cmp.get('v.payReasonVal') == 'Applied Payment' ) && (cmp.get('v.value') == 'Make a Payment' )) //Added if Anusha - start- 4/10/22
                    {
                        if(parseFloat(sumOfAmountPaid) > parseFloat(cmp.get('v.myCurrency'))){
                            cmp.set('v.TotalAppliedAmountInsurance',cmp.get('v.myCurrency'));   
                        }else{
                            cmp.set('v.TotalAppliedAmountInsurance',parseFloat(sumOfAmountPaid)); //Anusha - 3/10/22 
                        } 
                    }
                    cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.myCurrency') - cmp.get('v.TotalAppliedAmountInsurance')); //Anusha - end- 4/10/22
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
                }
            }
                else if(cmp.find('payReason').get('v.value') ==''){ //Anusha-03/10/22
                    cmp.set('v.disableCheckbox',false); //Anusha-03/10/22
                } //Anusha-03/10/22
        helper.registerThePaymentButtonHandler(cmp, event, helper); //Anusha - 30/09/2022
        */
        helper.calOnReason(cmp, event, helper);
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
                /*
                if(cmp.get("v.payReasonVal") == 'Applied Payment'){
                    if(parseInt(cmp.get("v.TotalAppliedAmountInsurance"))>parseInt(cmp.get("v.myCurrency")) && (cmp.get("v.selectedInsurancePaylist").length>0 || cmp.get('v.PayTransId').length>0)){ //Anusha - added && condition and length check LX3-5342 //Added '|| cmp.get('v.PayTransId').length>1)' by Anusha -03/10/22
                        cmp.set("v.showConfirmDialog",true);   
                    }
                    else {
                        var sizeOfLst = cmp.get("v.selectedInsurancePaylist");
                        console.log('sizeOfLst.length'+sizeOfLst.length);
                        helper.savePayments(cmp,event,helper); 
                    }  
                }else{
                    helper.savePayments(cmp,event,helper);  
                }*/
                
                if(cmp.get("v.myCurrency") && parseInt(cmp.get("v.myCurrency")) > 0){
                    if(cmp.get("v.patOutStndAmountRegister")){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Error",
                            "title": "Procedure has no outstanding Amount!",
                            "message": "Selected Procedure has no outstanding Amount!"
                        });
                        toastEvent.fire();
                        
                    }else{
                       helper.savePayments(cmp,event,helper);   
                    }
                    
                }
                
            }
            
        }
        catch(e){
            alert(e);
        }
        
        
    },
    registerAllocatePayment :  function(cmp,event,helper){ 
        try{
            if(cmp.get("v.amountAllocated")){
                if(cmp.get("v.amountAllocated")!=0 && parseInt(cmp.get("v.amountAllocated")) > 0){
                    /*
                    if(parseInt(cmp.get("v.TotalAppliedForAllocatePayment"))>parseInt(cmp.get("v.amountAllocated")) && cmp.get("v.selectedInsurancePaylist").length>0 || cmp.get('v.PayTransId').length>0){ //Anusha - added && condition and length check LX3-5342 //change > 1 to 0
                        cmp.set("v.showConfirmDialogForAllocatePayment",true); 
                        
                        cmp.set("v.showConfirmDialogMessage",'Do you want to apply the Amount to Allocate on the basis of oldest to newest DOS?');
                    }else {
                        var sizeOfLst = cmp.get("v.selectedInsurancePaylist");
                        console.log(sizeOfLst.length);
                        helper.saveAllocatedPayments(cmp,event,helper);  
                    } */
                    
                    //if(parseFloat(cmp.get("v.amountAllocated")) > parseFloat(cmp.get("v.TotalAppliedForAllocatePayment"))){ 
                    if(cmp.get("v.patOutStndAmount")){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Error",
                            "title": "Procedure has no outstanding Amount!",
                            "message": "Selected Procedure has no outstanding Amount!"
                        });
                        toastEvent.fire();
                        
                        
                    }else{
                      helper.saveAllocatedPayments(cmp,event,helper);   
                    }
                    
                }
                /*
                if(cmp.get("v.amountAllocated") == 0.00 || cmp.get("v.amountAllocated") ==''){
                    if(parseInt(cmp.get("v.TotalAppliedForAllocatePayment"))>parseInt(cmp.get("v.totalUnAllocatedAmount"))){
                        cmp.set("v.showConfirmDialogForAllocatePayment",true);
                        cmp.set("v.showConfirmDialogMessage",'Do you want to apply the Unallocated Amount on the basis of oldest to newest DOS?');
                        
                    }else {
                        var sizeOfLst = cmp.get("v.selectedInsurancePaylist");
                        console.log(sizeOfLst.length);
                        helper.saveAllocatedPayments(cmp,event,helper);  
                    } 
                }*/
            }
            /*else{
                
                if(parseInt(cmp.get("v.TotalAppliedForAllocatePayment"))>parseInt(cmp.get("v.totalUnAllocatedAmount"))){
                    cmp.set("v.showConfirmDialogForAllocatePayment",true);
                    cmp.set("v.showConfirmDialogMessage",'Do you want to apply the Unallocated Amount on the basis of oldest to newest DOS?');
                    
                }else {
                    var sizeOfLst = cmp.get("v.selectedInsurancePaylist");
                    console.log(sizeOfLst.length);
                    helper.saveAllocatedPayments(cmp,event,helper);  
                } 
                
            }
            */
            
            
        }
        catch(e){
            alert(e);
        }
        
    },
    handleConfirmDialogYesForAllocate : function(cmp,event,helper){ 
        helper.saveAllocatedPayments(cmp,event,helper);
    },
    handleConfirmDialogYes :  function(cmp,event,helper){ 
        helper.savePayments(cmp,event,helper);
    },
    handleConfirmDialogNo :  function(cmp){ 
        cmp.set("v.showConfirmDialog",false);   
        cmp.set("v.showConfirmDialogForAllocatePayment",false); 
    },
    //Added changePaymentType by Anusha LX3-5599
    changePaymentType : function(cmp,event,helper){
        cmp.set("v.makePay",true);
        cmp.set("v.AllocPay",false);
        cmp.set("v.paySched",false);
        cmp.set("v.value","Make a Payment");
        cmp.set("v.valueForPrivatePayment","Register a Payment");
        
        if(cmp.get("v.isPaymentTab")){
            cmp.set("v.recordId","");
            cmp.set("v.PatientId","");
            cmp.set("v.Allocate","");
            cmp.set("v.totalUnAllocatedAmount",0.0);
        }
        helper.resetData(cmp, event, helper);
        if(cmp.get("v.PatientId") != null && cmp.get("v.PatientId") != ''){
         helper.displayDetails(cmp, event, cmp.get("v.PatientId"));   
        }
      
    },
    //Created dateChangeHandler method by Anusha  
    dateChangeHandler:function(cmp,event,helper){
        helper.registerThePaymentButtonHandler(cmp,event,helper); 
    }
    ,
        handleCreditSelectedRow :function(cmp,event){
            console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));  
             cmp.set("v.creditSelectedRows",event.getParam('selectedRows')); 
           var creditCard =  cmp.get("v.creditSelectedRows");
            cmp.set("v.creditCardId",creditCard[0].Id);
        }
    
    
    
})