({  
    init: function (cmp, event, helper) {
        try{
            cmp.set("v.loaded",false); 
            cmp.set("v.loaded",true);
            cmp.set("v.makePaymentButtonDisable",true); //Anusha 1/10/22
            
            var cmpEvent1 = $A.get("e.c:PaymentEvent");
            cmpEvent1.setParams({
                "firstLabel" :  'Total Applied Amount',
                "secondLabel":'Total Unallocated amount',
                "firstValue":0,
                "secondValue":0
            });
            cmpEvent1.fire();
            
            
            helper.setDefaultJSON(cmp, event, helper);
            helper.setColumns(cmp, event, helper); //Anusha LX3-5599
            cmp.set("v.recordId", cmp.get("v.PatientId")); //Anusha LX3-5599
            if(cmp.get("v.recordId") == "")
            {
                cmp.set("v.isModalOpen",true);
                cmp.set("v.modeOfPaymentLst",[{'label':'Cash'},
                                              {'label':'Cheque'},
                                              {'label':'Credit Card'},
                                              {'label':'EFT'}]); //Anusha
            }
            else
            {
                cmp.set("v.isModalOpen",true);  
                cmp.set("v.PatientId", cmp.get("v.recordId")); 
                helper.displayDetails(cmp, event, helper,cmp.get("v.recordId"));
            }
            
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            today = yyyy +'-'+ mm +'-' + dd ;
            cmp.set("v.dateOfPayment",today);
            cmp.set("v.hideOrShowClaims",false);
            cmp.set('v.columns1', [
                {label: 'Card Number', fieldName: 'ElixirSuite__Credit_Card_Number__c', type: 'text'},
                {label: 'Expiration Month', fieldName: 'ElixirSuite__Expiration_Month__c', type: 'text'},
                {label: 'Expiration Year', fieldName: 'ElixirSuite__Expiration_Year__c', type: 'text'},
                {label: 'First Name', fieldName: 'ElixirSuite__First_Name_on_Card__c', type: 'text'},
                {label: 'Last Name', fieldName: 'ElixirSuite__Last_Name_on_Card__c', type: 'text'},
            ]);
                }
                catch(e){
                alert(e)
                }
                
                },
                
                totalAppliedAmountChange : function(cmp, event) {
                
                var cmpEvent1 = $A.get("e.c:PaymentEvent");
                cmpEvent1.setParams({
                "firstLabel" :  'Total Applied Amount',
                "secondLabel":'Total Unallocated amount',
                "firstValue":event.getParam("value"),
                "secondValue":cmp.get("v.totalUnAllocatedAmount")
                });
                cmpEvent1.fire();
                
                },    
                
                totalUnAllocatedAmountChange : function(cmp, event) {
                
                var cmpEvent1 = $A.get("e.c:PaymentEvent");
                cmpEvent1.setParams({
                "firstLabel" :  'Total Applied Amount',
                "secondLabel":'Total Unallocated amount',
                "firstValue":cmp.get("v.totalAppliedAmount"),
                "secondValue":event.getParam("value")
                });
                cmpEvent1.fire();
                
                },  
                
                sampleMethod :  function(cmp, event,helper) {
                var accid = cmp.get("v.PatientId");
                helper.displayDetails(cmp, event, helper,accid);
                },
                parentComponentEvent : function(cmp, event,helper) { 
                
                var accId = cmp.get("v.PatientId");
                helper.displayDetails(cmp, event, helper,accId);
                
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
                }
                if(cmp.find('select1').get('v.value')=='Cash'){
                cmp.set("v.cheque",false);
                cmp.set("v.Credit",false); 
                }
                if(cmp.find('select1').get('v.value')=='Credit Card'){
                cmp.set("v.cheque",false);
                cmp.set("v.Credit",true); 
                }
                if(cmp.find('select1').get('v.value')=='EFT'){
                cmp.set("v.cheque",false);
                cmp.set("v.Credit",false); 
                }
                helper.registerThePaymentButtonHandler(cmp,evt,helper); //Anusha - 06/10/2022
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
                var changeValue = event.getParam("value");
                if(changeValue =='Make a Payment'){
                cmp.set("v.makePay",true);
                if(cmp.get("v.PatientId") != "")
                {
                cmp.set("v.AllocPay",false);
                cmp.set("v.paySched",false);
                cmp.set("v.Allocate",true); 
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
                }
                else if(changeValue =='Payment schedule'){
                cmp.set("v.paySched",true);
                if(cmp.get("v.PatientId") != "")
                {
                cmp.set("v.AllocPay",false);
                cmp.set("v.makePay",true);
                cmp.set("v.Allocate",true); 
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
                }
                
                } ,
                
                handleToggleChange : function(cmp, event)
                {
                cmp.set('v.AmountDue',0);
                cmp.set("v.PayTransId",[]);
            var changeValue = event.getParam("value");
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
                                                   console.log('___ ' + resp.getReturnValue()[i].ClaimName);
                                                   ClaimsList[i]['Selected'] = false;
                                                   ClaimsList[i]['ShowProc'] = false;
                                                   ClaimsList[i]['NoOfSelectedProcs'] = 0;
                                                   ClaimsList[i]['ClaimName'] = resp.getReturnValue()[i].ClaimName;
                                                   ClaimsList[i]['ClaimId'] = resp.getReturnValue()[i].ClaimId;
                                                   ClaimsList[i]['OpenProc'] = resp.getReturnValue()[i].OpenProc;
                                                   ClaimsList[i]['TotalAllowed'] = resp.getReturnValue()[i].TotalAllowed;
                                                   ClaimsList[i]['InsuranceResp'] = resp.getReturnValue()[i].InsuranceResp;
                                                   ClaimsList[i]['PatientResp'] = resp.getReturnValue()[i].PatientResp;
                                                   
                                                   if('ProcWrap' in resp.getReturnValue()[i] && resp.getReturnValue()[i].ProcWrap != null && resp.getReturnValue()[i].ProcWrap != undefined)
                                                   {
                                                       //ClaimsList[i]['ProcWrap'] = resp.getReturnValue()[i].ProcWrap;
                                                       var ProcWrap = resp.getReturnValue()[i].ProcWrap;
                                                       var count = 1;
                                                       for(var j in resp.getReturnValue()[i].ProcWrap)
                                                       {
                                                           ProcWrap[j]['SNo'] = count+'.';
                                                           ProcWrap[j]['Selected'] = false;
                                                           ProcWrap[j]['ProcId'] = resp.getReturnValue()[i].ProcWrap[j].Id;
                                                           
                                                           ProcWrap[j]['ElixirSuite__Procedure_Name__c'] = resp.getReturnValue()[i].ProcWrap[j].ElixirSuite__Procedure_Name__c;
                                                           ProcWrap[j]['ElixirSuite__Date_Of_Service__c'] = resp.getReturnValue()[i].ProcWrap[j].ElixirSuite__Date_Of_Service__c;
                                                           if (isNaN(resp.getReturnValue()[i].ProcWrap[j].ElixirSuite__Patient_Responsibility__c)) 
                                                           {
                                                               ProcWrap[j]['ElixirSuite__Patient_Responsibility__c'] = 0;
                                                           }
                                                           else
                                                           {
                                                               ProcWrap[j]['ElixirSuite__Patient_Responsibility__c'] = resp.getReturnValue()[i].ProcWrap[j].ElixirSuite__Patient_Responsibility__c;
                                                           }
                                                           count = count + 1;
                                                       }
                                                       ClaimsList[i]['ProcWrap'] = ProcWrap;
                                                   }
                                               }
                                               cmp.set('v.ClaimsList',ClaimsList);
                                           }
                                       }
                                   });
                $A.enqueueAction(action);
                cmp.set("v.hideOrShowClaims",true);
            }
            else if(changeValue == 'By Procedure')
            {
                cmp.set("v.hideOrShowClaims",false);
            }
        },
            
            handleOnClaimSelection : function(cmp, event)
        {
            var getClaimId = event.getSource().get("v.name");
            var getSelected = event.getSource().get("v.checked");
            var ClaimsList = cmp.get("v.ClaimsList");
            var totalAmount = cmp.get('v.AmountDue');
            var selectedIds = cmp.get("v.PayTransId");
            var NoOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");
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
                if(getClaimId == ClaimsList[i].ClaimId)
                {
                    if('ProcWrap' in ClaimsList[i])
                    {
                        var ProcWrapList = ClaimsList[i].ProcWrap;
                        for(var j in ProcWrapList)
                        {
                            if(getSelected == true && ProcWrapList[j].Selected != true)
                            {
                                totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                                selectedIds.push(ProcWrapList[j].ProcId); 
                            }
                            if(getSelected == false && ProcWrapList[j].Selected != false)
                            {
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
                        ClaimsList[i].ProcWrap = ProcWrapList;
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
            cmp.get("v.PayTransId",selectedIds);
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
        },
            
            handleOnProcSelection : function(cmp, event)
        {
            var getClaimId = event.getSource().get("v.value");
            var getProcId = event.getSource().get("v.name");
            var getSelected = event.getSource().get("v.checked");
            var ClaimsList = cmp.get("v.ClaimsList");
            var totalAmount = cmp.get('v.AmountDue');
            var selectedIds = cmp.get("v.PayTransId");
            var NoOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");
            if(getSelected == true && cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
            {
                cmp.set("v.makePaymentButtonDisable", false);
            }
            
            for(var i in ClaimsList)
            {
                if(getClaimId == ClaimsList[i].ClaimId)
                {
                    if('ProcWrap' in ClaimsList[i])
                    {
                        var ProcWrapList = ClaimsList[i].ProcWrap;
                        for(var j in ProcWrapList)
                        {
                            if(getProcId == ProcWrapList[j].ProcId)
                            {
                                if(getSelected == true)
                                {
                                    totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
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
            cmp.get("v.PayTransId",selectedIds);
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
            
        },
            
            getSelectAllClaims : function(cmp, event)
        {
            var getSelected = event.getSource().get("v.checked");
            var ClaimsList = cmp.get("v.ClaimsList");
            var totalAmount = 0;
            var selectedIds = [];
            var ProcWrapList;
            if(getSelected == true && cmp.get('v.payReasonVal') == 'Applied Payment' && cmp.get('v.value') == 'Make a Payment')
            {
                cmp.set("v.makePaymentButtonDisable", false);
            }
            if(getSelected == true)
            {
                for(var i in ClaimsList)
                {
                    if('ProcWrap' in ClaimsList[i])
                    {
                        ProcWrapList = ClaimsList[i].ProcWrap;
                        for(var j in ProcWrapList)
                        {
                            totalAmount = totalAmount + ProcWrapList[j].ElixirSuite__PatientOutstanding__c;
                            selectedIds.push(ProcWrapList[j].ProcId); 
                            ProcWrapList[j].Selected = true;
                        }
                        ClaimsList[i].ProcWrap = ProcWrapList;
                        ClaimsList[i].NoOfSelectedProcs = ClaimsList[i].OpenProcs;
                    }
                    ClaimsList[i].Selected = true;
                }
                cmp.set("v.NoOfClaimsSelected",ClaimsList.length);
                
            }
            else if(getSelected == false)
            {
                for(var a in  ClaimsList)
                {
                    if('ProcWrap' in ClaimsList[a])
                    {
                        ProcWrapList = ClaimsList[a].ProcWrap;
                        for(var b in ProcWrapList)
                        {
                            ProcWrapList[b].Selected = false;
                        }
                        ClaimsList[a].ProcWrap = ProcWrapList;
                        ClaimsList[a].NoOfSelectedProcs = 0;
                    }
                    ClaimsList[a].Selected = false;
                }
                cmp.set("v.NoOfClaimsSelected",0);
            }
            cmp.set('v.ClaimsList',ClaimsList);
            cmp.set('v.AmountDue',totalAmount);
            cmp.get("v.PayTransId",selectedIds);
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
            //Added new
        },
            
            closeModel: function(component) {
                // Set isModalOpen attribute to false  
                component.set("v.isModalOpen", false);
            },
                
                setValue: function(component, event) {
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
                            component.set("v.makePaymentButtonDisable", false);
                        }
                    } 
                    else 
                    {
                        component.set("v.makePaymentButtonDisable", true);
                    }
                    
                    if(component.get("v.NetAmount") > 0 && amountPaid > component.get("v.NetAmount")) {
                        component.set("v.isAllocatedAmtExceedPaSh", true);
                        component.set("v.makePaymentButtonDisable", true);
                    }else if(amountPaid > 0 && component.get("v.NetAmount") > 0 && amountPaid  <= component.get("v.NetAmount")) {
                        component.set("v.isAllocatedAmtExceedPaSh", false);
                        component.set("v.makePaymentButtonDisable", false);
                    }
                }, 
                    
                    
                    
                    selectedRows : function(component, event, helper) {
                        let remainingAmount = 0;
                        var selectedRows =  event.getParam('selectedRows');
                        component.set("v.selectedProcedureRecords",event.getParam('selectedRows'));
                        let selectedProcedureRecordsNetInstance = component.get("v.selectedProcedureRecordsNetInstance"); 
                        if($A.util.isEmpty(event.getParam('selectedRows'))){
                            component.set("v.selectedProcedureRecordsNetInstance",[]); 
                        }
                        else {
                            selectedProcedureRecordsNetInstance = selectedProcedureRecordsNetInstance.concat(event.getParam('selectedRows'));
                            component.set("v.selectedProcedureRecordsNetInstance",selectedProcedureRecordsNetInstance); 
                        } 
                        for (var i = 0; i < selectedRows.length; i++) {
                            if(!$A.util.isUndefinedOrNull(selectedRows[i].remainingAmount)){
                                remainingAmount+=parseInt(selectedRows[i].remainingAmount);         
                            }            
                        }
                        let amountPaid =   component.get("v.amountPaid");
                        /*component.set("v.totalAppliedAmount",remainingAmount);
        if(!$A.util.isUndefinedOrNull(amountPaid)){
            if(amountPaid){
                component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount))); 
            }
        }
        */
        if(!$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0){
            
            if(parseFloat(remainingAmount) > parseFloat(component.get('v.amountPaid'))){
                component.set("v.totalAppliedAmount",parseFloat(amountPaid));  
            }else{
                component.set("v.totalAppliedAmount",parseFloat(remainingAmount));  
            }
            component.set("v.totalUnAllocatedAmount",(parseFloat(amountPaid) - parseFloat(component.get("v.totalAppliedAmount")))); 
        }else{
            component.set("v.totalAppliedAmount",0);  
            component.set("v.totalUnAllocatedAmount",0);             
        }
        
        
        
        
        helper.registerThePaymentButtonHandler(component, event, helper); //Anusha - 06/10/2022
        
        
    },
        
        handleRowAction: function(component, event, helper){
        var action = event.getParam('action');
        switch (action.name) {
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
    },
        calculateAllocations : function(component, event, helper) {
            /*let amountPaid =   component.get("v.amountPaid");
        
        
        if(amountPaid){
            let remainingAmount =   component.get("v.totalAppliedAmount");
            if(!$A.util.isUndefinedOrNull(amountPaid)){
                component.set("v.totalUnAllocatedAmount",(parseInt(amountPaid) - parseInt(remainingAmount)));  
            }
        }
        else {
            component.set("v.totalUnAllocatedAmount",0.0);  
        }*/
        
        //AK
        let amountPaid = component.get("v.amountPaid");
        if(!$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0){
            var remainingAmount = 0;
            var selectedRows = component.get("v.selectedProcedureRecords");
            if(selectedRows.length > 0){
                for (var i = 0; i < selectedRows.length; i++) {
                    if(!$A.util.isUndefinedOrNull(selectedRows[i].remainingAmount)){
                        remainingAmount+=parseInt(selectedRows[i].remainingAmount);         
                    }            
                }
                if(!$A.util.isUndefinedOrNull(amountPaid) && parseInt(amountPaid) > 0){
                    
                    if(parseFloat(remainingAmount) > parseFloat(amountPaid)){
                        component.set("v.totalAppliedAmount",parseFloat(amountPaid));  
                    }else{
                        component.set("v.totalAppliedAmount",parseFloat(remainingAmount));  
                    }
                    component.set("v.totalUnAllocatedAmount",(parseFloat(amountPaid) - parseFloat(component.get("v.totalAppliedAmount")))); 
                }
            }else{
                component.set("v.totalAppliedAmount",0);  
                component.set("v.totalUnAllocatedAmount",parseFloat(amountPaid));  
            }
        }else{
            
            component.set("v.totalUnAllocatedAmount",0); 
            
        }
        
        
        
        //Ak
        
        
        helper.registerThePaymentButtonHandler(component, event, helper); //Anusha - 06/10/2022
    },
        makeTranscation :function(cmp) {
            
            var error = false;
            if(cmp.get('v.payReasonVal') == 'Unallocated Payment' && cmp.get('v.value') == 'Make a Payment')
            {
                cmp.set('v.PayTransId',[]);
            }
            if(cmp.get('v.payReasonVal') == 'Applied Payment' && (cmp.get('v.PayTransId') == null || cmp.get('v.PayTransId') == '') && cmp.get('v.value') == 'Make a Payment')
            {
                error = true;
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'Please select the Procedure(s)',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            if((cmp.get('v.PayTransId') == null || cmp.get('v.PayTransId') == '') && cmp.get('v.value') == 'Make a Payment')
            {
                error = true;
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'Please select the Procedure(s)',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            
            if(cmp.get('v.value') == 'Allocate Payments')
            {
                cmp.set("v.myCurrency",0);
                cmp.set("v.payReasonVal",'Unallocated Payment');
                if(cmp.get('v.PayTransId') == null || cmp.get('v.PayTransId') == '')
                {
                    error = true;
                    let toastEvent = $A.get("e.force:showToast");
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
                let toastEvent = $A.get("e.force:showToast");
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
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'no records present..',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            
            if(error == false)
            {
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
                        if(cmp.get('v.generateReceipt') == true){
                            var url;
                            var newWindow;
                            if(cmp.get('v.value') == 'Make a Payment'){
                                url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+response.getReturnValue();
                                newWindow;	
                                newWindow = window.open(url);	
                                newWindow.focus();	
                                //window.open('/apex/GenerateUpfrontPaymentReceipt?amountPaid='+cmp.get('v.myCurrency')+'&patientId='+cmp.get('v.PatientId')+'&paymentDate='+cmp.get('v.Tdate'));
                            }
                            else if(cmp.get('v.value') == 'Allocate Payments'){
                                url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+response.getReturnValue();
                                newWindow;	
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
            validateAmtAllocated : function(component, event) {
                
                var totalUnAllocatedAmount = component.get("v.totalUnAllocatedAmount");
                var amountAllocated = event.getSource().get('v.value');
                //component.set('v.AmountApplied',amountAllocated);
                if(component.get('v.AmountDue') > component.get("v.amountAllocated"))
                {
                    component.set("v.AmountApplied",component.get("v.amountAllocated"));
                }
                else
                {
                    component.set("v.AmountApplied",component.get("v.AmountDue"));
                }
                if(amountAllocated > totalUnAllocatedAmount) {
                    component.set("v.isAllocatedAmtExceed", true);
                    component.set("v.makePaymentButtonDisable", true);
                } else {
                    component.set("v.isAllocatedAmtExceed", false);
                    component.set("v.makePaymentButtonDisable", false);
                }
            },
        calOnReason : function(cmp, event, helper){
            var amt =0;
            if(cmp.find('payReason').get('v.value')=='Unallocated Payment'){
                cmp.set('v.disableCheckbox',true);
                cmp.set('v.selectedProcedureRecords',[]);
                if(cmp.get('v.amountPaid') != null && cmp.get('v.amountPaid') != 0)
                {
                    amt =0;
                    cmp.set("v.makePaymentButtonDisable", false);
                    cmp.set("v.TotalAppliedAmountInsurance", amt);
                    cmp.set("v.TotalUnallocatedAmountInsurance", cmp.get('v.amountPaid') - amt);
                }else{
                    cmp.set("v.TotalAppliedAmountInsurance", 0);
                    cmp.set("v.TotalUnallocatedAmountInsurance", 0);  
                }
            }
            else if(cmp.find('payReason').get('v.value')=='Applied Payment')
            {
                cmp.set('v.disableCheckbox',false);
                amt =0;
                    if(cmp.get('v.amountPaid') != null && cmp.get('v.amountPaid') != 0)
                    {
                        if(parseFloat(amt) > parseFloat(cmp.get('v.amountPaid'))){
                            cmp.set('v.TotalAppliedAmountInsurance',cmp.get('v.amountPaid'));   
                        }else{
                            cmp.set('v.TotalAppliedAmountInsurance',parseFloat(amt));  
                        }
                        cmp.set("v.TotalUnallocatedAmountInsurance", parseFloat(cmp.get('v.amountPaid')) - cmp.get('v.TotalAppliedAmountInsurance'));
                    }else{
                        cmp.set('v.TotalAppliedAmountInsurance',0);  
                        cmp.set("v.TotalUnallocatedAmountInsurance",0);    
                    }
                helper.registerThePaymentButtonHandler(cmp);
            }
                else if(cmp.find('payReason').get('v.value') !='')
                {
                    cmp.set('v.disableCheckbox',false);
                    if(cmp.get('v.amountPaid') != null && cmp.get('v.amountPaid') != 0)
                    {
                        cmp.set("v.TotalAppliedAmountInsurance", cmp.get('v.amountPaid'));
                        cmp.set("v.TotalUnallocatedAmountInsurance", 0);
                    }else{
                        cmp.set("v.TotalAppliedAmountInsurance", 0);
                        cmp.set("v.TotalUnallocatedAmountInsurance", 0);  
                    }
                     helper.registerThePaymentButtonHandler(cmp);
                }
                    else if(cmp.find('payReason').get('v.value') ==''){ 
                        cmp.set('v.disableCheckbox',false); 
                    }
        },
            onDOSFromChange :  function(cmp, event, helper){
                try{
                    let procedureSearchParams = cmp.get("v.procedureSearchParams");
                    if(!$A.util.isUndefinedOrNull(procedureSearchParams.DOSTo)){      
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
                    else {
                        cmp.set("v.isSearchDisabled",false);  
                    }
                }
                catch(e){
                    alert(e); 
                }
            },
                onDOSToChange : function(cmp, event, helper){
                    try{
                        let procedureSearchParams = cmp.get("v.procedureSearchParams");
                        if(!$A.util.isUndefinedOrNull(procedureSearchParams.DOSTo)){          
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
                        else {
                            cmp.set("v.isSearchDisabled",false);  
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
                            cmp.set("v.isSearchClicked",true); //Anusha LX3-5527
                            try{
                                cmp.set("v.loaded",false);
                                var procedureSearchParams = cmp.get("v.procedureSearchParams");
                                if(procedureSearchParams.DOSFrom || procedureSearchParams.DOSTo || procedureSearchParams.procedureName 
                                   || procedureSearchParams.CPTCode){
                                    
                                    var dosFrom =  procedureSearchParams.DOSFrom;
                                    var dosTo =  procedureSearchParams.DOSTo;
                                    if((dosFrom == '' || $A.util.isUndefinedOrNull(dosFrom)) && dosTo!=''){
                                        dosFrom = dosTo;
                                        procedureSearchParams.DOSFrom = dosTo;
                                    }
                                    else if((dosTo=='' || $A.util.isUndefinedOrNull(dosTo)) && dosFrom!=''){
                                        var today = new Date();
                                        if(new Date(dosFrom)>today){
                                            dosTo = dosFrom;
                                            procedureSearchParams.DOSTo = dosFrom;
                                        }
                                        else {
                                            dosTo = today;                      
                                            procedureSearchParams.DOSTo = $A.localizationService.formatDate(today.toString(), "yyyy MM dd");
                                        }            
                                    }
                                    cmp.set("v.procedureSearchParams",procedureSearchParams); 
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
                    cmp.set("v.loaded",true);
                    if (state === "SUCCESS") {   
                        var result = response.getReturnValue();
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
                            helper.setSerialNumber(cmp, event, helper,selectedProcedureRecordsNetInstance);
                            cmp.set("v.Plist",selectedProcedureRecordsNetInstance);
                            
                        }
                        else {
                            cmp.set("v.loaded",true); 
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different filter!','error');
                        }
                        helper.setColumns(cmp, event, helper, cmp.get("v.customSettingData"));
                        
                    }
                    
                });
                $A.enqueueAction(action);  
            }
            else {
                cmp.set("v.loaded",true); 
                helper.globalFlagToast(cmp, event, helper,'NO FILTER APPLIED!', 'Please apply filter to search!','error');
            }
        }
        catch(e){
            alert(e);
        }
        
    },
        clearClaimSearchFilter :  function(cmp,event,helper){ 
            
            //helper.setDefaultJSON(cmp, event, helper); - commented by Anusha -LX3-5792
            cmp.set("v.procedureSearchParams",{'DOSFrom' : '','DOSTo' : '','procedureName' : '',	
                                               'procedureId' : '','CPTCode' : ''}); //Added by Anusha -LX3-5792
            helper.keepSelectedProcedures(cmp, event, helper);
            cmp.set("v.isSearchDisabled",false); // Added by sagili siva :Lx3-5827
        },
            registerPayment :  function(cmp,event,helper){ 
                try{
                    var selectedRows =  cmp.get("v.selectedProcedureRecords");
                    if(helper.checkRequieredValidity(cmp,event,helper)){
                        if(parseInt(cmp.get("v.totalAppliedAmount"))>parseInt(cmp.get("v.amountPaid")) && selectedRows.length > 1){ //sagili siva LX3-5502
                            cmp.set("v.showConfirmDialog",true); 
                        }
                        else {
                            helper.savePayments(cmp,event,helper);  
                        }  
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
                        //Created dateChangeHandler method by Anusha - 06/10/2022
                        dateChangeHandler:function(cmp,event,helper){
                            helper.registerThePaymentButtonHandler(cmp,event,helper); 
                        },
                            handleCreditSelectedRow :function(cmp,event){
                                console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));  
                                cmp.set("v.creditSelectedRows",event.getParam('selectedRows')); 
                                var creditCard =  cmp.get("v.creditSelectedRows");
                                cmp.set("v.creditCardId",creditCard[0].Id);
                            }
        
    })