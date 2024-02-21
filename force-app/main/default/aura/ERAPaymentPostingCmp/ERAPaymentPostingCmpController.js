({
    doInit : function(cmp, event, helper) {
        
        cmp.set('v.columns', [
            {label: 'ERA No.' ,fieldName: 'EraName', type:'button' ,typeAttributes:  {label: { fieldName: 'EraName' }, target: '_blank',name:'recLink',variant:'Base' } },
            {label: 'ERA ID', fieldName: 'EraId', type: 'text'}  ,
            {label: 'Payer Name', fieldName: 'PayerName', type : 'text'},
            {label: 'Payment Trace', fieldName: 'PaymentTrace', type: 'text', cellAttributes: {
                class: {
                    fieldName: 'testCSSClass'
                }
            }}  ,
            {label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
             typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}},
            //{label: 'Check Number', fieldName: 'CheckNumber', type : 'text'}
        ]);
            
            cmp.set('v.childColumns', [
            {label: 'ERA No.' ,fieldName: 'childEraName', type:'button' ,typeAttributes:  {label: { fieldName: 'childEraName' }, target: '_blank',name:'recLink',variant:'Base' } },
            {label: 'Claim No.', fieldName: 'ClaimNo', type: 'text'}  ,
            {label: 'Patient Name', fieldName: 'PatientName', type : 'text'},
            {label: 'Status Code', fieldName: 'StatusCode', type : 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
            typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}},
            {label: 'Matched ERA', fieldName: 'Matched', type : 'boolean'},
            //{label: 'Check Number', fieldName: 'CheckNumber', type : 'text'}
        ]);
        //LX3-5217(Akanksha)
         var parentEraPage = cmp.get("v.parentEraPage") || 1; 
         console.log('parentEraPage '+parentEraPage);
         var childEraPage = cmp.get("v.childEraPage") || 1;
         console.log('childEraPage' +childEraPage);
         var recordToDisplay = 20;
         helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);
         
    },
    //LX3-5217(Akanksha)
    navigate: function(cmp, event, helper){ 	
        var parentEraPage = cmp.get("v.parentEraPage") || 1; 
        var recordToDisplay = 20;
        var direction = event.getSource().get("v.label"); 
        console.log('direction '+direction);
        var childEraPage=cmp.get("v.childEraPage") || 1;     
        
        if(cmp.get("v.parentERA")==true){
        parentEraPage = direction === "Previous" ? (parentEraPage - 1) : (parentEraPage + 1); 
        }
        if(cmp.get("v.childERA")==true){
        childEraPage = direction === "Previous" ? (childEraPage - 1) : (childEraPage + 1);
        }
        
        if(cmp.get("v.parentSearch") == true){
           helper.fetchMasterEraData(cmp, event, parentEraPage,recordToDisplay);   
        }else if(cmp.get("v.childSearch") == true){
            helper.fetchClaimEraData(cmp, event,childEraPage,recordToDisplay); 
        }else{
          helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);    
        }
      
               
    }, 
    clearFilter : function(cmp, event, helper){
       // var check_date = null;
         helper.parentEraDefaultValues(cmp, event);
        /*cmp.set("v.paymentTrace" , '');
        cmp.set("v.ERA_Id" , '');
        cmp.set("v.FromDate" , check_date);
        cmp.set("v.ToDate" , check_date);
        cmp.set("v.recList" , {});
        cmp.set("v.selectedEraRecParent" , {});
        cmp.set("v.selRec" , '');
        cmp.set("v.searchString",'');
        cmp.set("v.selRecERAParent" , '');
        cmp.set("v.searchStringEraParent",'');*/
        //LX3-5217(Akanksha)
        var parentEraPage = 1; 
         console.log('parentEraPage '+parentEraPage);
         var childEraPage = cmp.get("v.childEraPage") || 1;
         console.log('childEraPage' +childEraPage);
         var recordToDisplay = 20;
         helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);
    },
    clearFilterChild : function(cmp, event, helper){
        //var check_date = null;
        
       helper.claimEraDefaultValues(cmp, event);
        /*cmp.set("v.selectedClaimRec" , {});
        cmp.set("v.FromDateChild" , check_date);
        cmp.set("v.ToDateChild" , check_date);
        cmp.set("v.selectedPatientRec" , {});
        cmp.set("v.selectedEraRec" , {});
        cmp.set("v.selRecERA" , '');
        cmp.set("v.searchStringEra",'');
        cmp.set("v.selRecClaim" , '');
        cmp.set("v.searchStringClaim",'');
        cmp.set("v.selRecPatient" , '');
        cmp.set("v.searchStringPatient",'');
         cmp.set("v.statusCode" , '');
        cmp.set("v.matched" , false);*/
        //LX3-5217(Akanksha)
         var parentEraPage = cmp.get("v.parentEraPage") || 1; 
         console.log('parentEraPage '+parentEraPage);
         var childEraPage = cmp.get("v.childEraPage") || 1;
         console.log('childEraPage' +childEraPage);
         var recordToDisplay = 20;
         helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);
    },
    
    search : function(cmp, event, helper) {
        
        //var checkLookupValue = cmp.get("v.checkValue");
        var error = false;
        //sagili siva
        if(cmp.get('v.FromDate') != null && cmp.get('v.FromDate') != '' || cmp.get('v.ToDate') != null && cmp.get('v.ToDate') != ''|| cmp.get('v.paymentTrace') != null && cmp.get('v.paymentTrace') != '' 
               || cmp.get('v.ERA_Id') != null && cmp.get('v.ERA_Id') != '' || cmp.get('v.recList') != null && cmp.get('v.recList') != '' || cmp.get('v.selectedEraRecParent') != null && cmp.get('v.selectedEraRecParent') != ''){
        if(cmp.get('v.FromDate') != '' && cmp.get('v.FromDate') != null && (cmp.get('v.ToDate') == '' || cmp.get('v.ToDate') == null))
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message: 'Please select To Date.',
                type: 'Error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else if((cmp.get('v.FromDate') == '' || cmp.get('v.FromDate') == null) && ( cmp.get('v.ToDate') != '' && cmp.get('v.ToDate') != null))
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message: 'Please select From Date.',
                type: 'Error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
            else if(cmp.get("v.FromDate") > cmp.get("v.ToDate")){
                error = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : '',
                    message: 'From Date should be less than To Date.',
                    type: 'Error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
                /*else if(checkLookupValue === true){
                    error = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : '',
                        message: 'Please enter any filter criteria.',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }*/
            }
            // sagili siva
            else {
                error = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : '',
                        message: 'Please enter any filter criteria.',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            }
        if(error == false){
            console.log('sai');
            //LX3-5217(Akanksha)
            var parentEraPage = 1; 
            var recordToDisplay = 20;
            helper.fetchMasterEraData(cmp, event, parentEraPage,recordToDisplay);
            cmp.set("v.parentSearch",true);
        }
    },
    
    searchChild : function(cmp, event, helper) {
        //sagili siva
        //var checkLookupValue = cmp.get("v.checkValue");
        var error = false;
        // sagili siva
        if(cmp.get('v.FromDateChild') != null && cmp.get('v.FromDateChild') != '' || cmp.get('v.ToDateChild') != null && cmp.get('v.ToDateChild') != ''|| cmp.get('v.selectedEraRec') != null && cmp.get('v.selectedEraRec') != '' 
           || cmp.get('v.selectedPatientRec') != null && cmp.get('v.selectedPatientRec') != '' || cmp.get('v.selectedClaimRec') != null && cmp.get('v.selectedClaimRec') != ''){
            if(cmp.get('v.FromDateChild') != '' && cmp.get('v.FromDateChild') != null && (cmp.get('v.ToDateChild') == '' || cmp.get('v.ToDateChild') == null))
            {
                error = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : '',
                    message: 'Please select To Date.',
                    type: 'Error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            //sagili siva
            else if(cmp.get("v.FromDateChild") > cmp.get("v.ToDateChild")){
                error = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : '',
                    message: 'From Date should be less than To Date.',
                    type: 'Error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
             }
             else if((cmp.get('v.FromDateChild') == '' || cmp.get('v.FromDateChild') == null) && ( cmp.get('v.ToDateChild') != '' && cmp.get('v.ToDateChild') != null) && (cmp.get('v.ToDateChild') == '' || cmp.get('v.ToDateChild') == null)){
                    error = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : '',
                        message: 'Please select From Date.',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            /* else if(checkLookupValue === true ){
                error = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : '',
                    message: 'Please enter any filter criteria.',
                    type: 'Error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }*/
        }
        // sagili siva
        else {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message: 'Please enter any filter criteria.',
                type: 'Error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        } 
        if(error == false){
            console.log('siva');
            //LX3-5217(Akanksha)
            var childEraPage = 1; 
            var recordToDisplay = 20;
            helper.fetchClaimEraData(cmp, event,childEraPage,recordToDisplay);
            cmp.set("v.childSearch",true);
        } 
    },
    
    handleChangeERA : function (cmp, event, helper) {
        var changeValue = event.getParam("value");
        //alert(changeValue);
        if(changeValue =='Parent ERA'){
            
            cmp.set("v.parentERA",true);
            cmp.set("v.childERA",false);
         var parentEraPage = cmp.get("v.parentEraPage") || 1; 
         console.log('parentEraPage '+parentEraPage);
         var childEraPage = cmp.get("v.childEraPage") || 1;
         console.log('childEraPage' +childEraPage);
         var recordToDisplay = 20;
         helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);
           helper.claimEraDefaultValues(cmp, event);
            }
        else if(changeValue =='Claim ERA'){
            //sagili siva
            cmp.set("v.childERA",true);
            cmp.set("v.parentERA",false);
            var parentEraPage = cmp.get("v.parentEraPage") || 1; 
         console.log('parentEraPage '+parentEraPage);
         var childEraPage = cmp.get("v.childEraPage") || 1;
         console.log('childEraPage' +childEraPage);
         var recordToDisplay = 20;
         helper.fetchParentEOBData(cmp, event,parentEraPage,recordToDisplay,childEraPage);
            helper.parentEraDefaultValues(cmp, event);
        }
       
    },
        
    searchChildERA : function(cmp, event, helper)
    {
        var error = false;
        if(cmp.get('v.ChildFromDate') != '' && cmp.get('v.ChildFromDate') != null && (cmp.get('v.ChildToDate') == '' || cmp.get('v.ChildToDate') == null))
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message: 'Please select To Date.',
                type: 'Error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else if((cmp.get('v.ChildFromDate') == '' || cmp.get('v.ChildFromDate') == null) && ( cmp.get('v.ChildToDate') != '' && cmp.get('v.ChildToDate') != null))
        {
            error = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message: 'Please select From Date.',
                type: 'Error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        if(error == false)
            helper.fetchChildEraData(cmp,event, cmp.get('v.selMasterERAID'));
    },
    
    sortColumn : function (component, event, helper) {
        try{
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    sortColumnChild : function (component, event, helper) {
        try{
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedByChild", fieldName);
            component.set("v.sortedDirectionChild", sortDirection);
            helper.sortDataChild(component, fieldName, sortDirection);
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    
    selectedChildEraRows : function(cmp, event, helper)
    {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));
        var selectedRows =  event.getParam('selectedRows');  
        if(selectedRows != null && selectedRows.length > 0)
        {
            var selectedERAId = selectedRows[0].Id;
            console.log('### selectedERAId : ' + selectedERAId);
            cmp.set('v.showEraItemsTable',true);
            
            var ChildEra = selectedRows[0];
            cmp.set('v.ClaimId',ChildEra.ClaimId);
            cmp.set('v.Paid',ChildEra.totalInsPaid);
            cmp.set('v.TotalAllowed',ChildEra.totalAllowed);
            cmp.set('v.PatientName',ChildEra.Patient);
            cmp.set('v.Provider',ChildEra.Provider);
            
            cmp.set("v.selectedChildEraRec",selectedERAId);
            
            var action = cmp.get('c.getERALineItems');
            action.setParams({
                selERAId : selectedERAId
            });
            action.setCallback(this,function(resp){
                
                var result = resp.getReturnValue();
                console.log(result);
                if(resp.getState() == 'SUCCESS')
                {
                    if(resp.getReturnValue() != null && resp.getReturnValue().length > 0)
                    {
                        var EraItemsList = resp.getReturnValue();
                        for(var i in resp.getReturnValue())
                        {
                            //Claim_Line_Items__r.Procedure__r.From_Date_of_Service__c
                            EraItemsList[i]['Id'] = resp.getReturnValue()[i].Id;
                            EraItemsList[i]['ProcCode'] = resp.getReturnValue()[i].ElixirSuite__Proc_code__c;
                            EraItemsList[i]['StartDate'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__From_Date_of_Service__c;
                            EraItemsList[i]['EndDate'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Procedure__r.ElixirSuite__To_Date_of_Service__c;
                            EraItemsList[i]['Mod1'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_1__c == null ? '' : resp.getReturnValue()[i].Claim_Line_Items__r.Modifier_1__c;
                            EraItemsList[i]['Mod2'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_2__c == null ? '' : resp.getReturnValue()[i].Claim_Line_Items__r.Modifier_2__c;
                            EraItemsList[i]['Mod3'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_3__c == null ? '' : resp.getReturnValue()[i].Claim_Line_Items__r.Modifier_3__c;
                            EraItemsList[i]['Mod4'] = resp.getReturnValue()[i].ElixirSuite__Claim_Line_Items__r.ElixirSuite__Modifier_4__c == null ? '' : resp.getReturnValue()[i].Claim_Line_Items__r.Modifier_4__c;
                            EraItemsList[i]['Charge'] = resp.getReturnValue()[i].ElixirSuite__Charge__c == null ? 0 : resp.getReturnValue()[i].ElixirSuite__Charge__c;
                            EraItemsList[i]['AllowedAmount'] = resp.getReturnValue()[i].ElixirSuite__Total_Allowed_Amount__c == null ? 0 : resp.getReturnValue()[i].ElixirSuite__Total_Allowed_Amount__c;
                            EraItemsList[i]['Deductible'] = resp.getReturnValue()[i].ElixirSuite__Deductible__c == null ? 0 : resp.getReturnValue()[i].ElixirSuite__Deductible__c;
                            EraItemsList[i]['CoPay'] = resp.getReturnValue()[i].ElixirSuite__Copay__c == null ? 0 : resp.getReturnValue()[i].ElixirSuite__Copay__c;
                            //EraItemsList[i]['totalAdjustment'] = resp.getReturnValue()[i].Total_Adjustment_Amount__c == null ? 0 : resp.getReturnValue()[i].Total_Adjustment_Amount__c;
                            EraItemsList[i]['ProviderPaid'] = resp.getReturnValue()[i].Paid__c == null ? 0 : resp.getReturnValue()[i].Paid__c;
                            EraItemsList[i]['PatientResp'] = resp.getReturnValue()[i].Claim_Line_Items__r.Patient_Responsibility__c == null ? 0 : resp.getReturnValue()[i].Claim_Line_Items__r.Patient_Responsibility__c;
                            var adjCodeLst = [];
                            for(var adj=1; adj<=6; adj++)
                            {
                                var codefield = 'ElixirSuite__Adjustment_Code_'+adj+'__c';
                                var amtfield = 'ElixirSuite__Adjustment_Amount_'+adj+'__c';
                                var dummyField = 'Adjustment_Amount_'+adj;
                                console.log('$$$$ resp.getReturnValue()[i][codefield] ' + resp.getReturnValue()[i][codefield]);
                                console.log('$$$$ resp.getReturnValue()[i][amtfield] ' + resp.getReturnValue()[i][amtfield]);
                                if(resp.getReturnValue()[i][codefield] != null && resp.getReturnValue()[i][codefield] != '-' && resp.getReturnValue()[i][codefield] != '' && resp.getReturnValue()[i][amtfield] != null)
                                {
                                    adjCodeLst.push({label:resp.getReturnValue()[i][codefield], value:resp.getReturnValue()[i][amtfield]+'#'+amtfield+'#'+resp.getReturnValue()[i].Id+'#'+dummyField});
                                    EraItemsList[i][amtfield] = resp.getReturnValue()[i][amtfield];
                                    EraItemsList[i][dummyField] = resp.getReturnValue()[i][amtfield];
                                }
                            }
                            if(adjCodeLst.length>0){
                                var val = adjCodeLst[0].value.split('#');
                                EraItemsList[i]['totalAdjustment'] = val[0]; 
                                EraItemsList[i]['AdjustmentField'] = val[1]; 
                                EraItemsList[i]['AdjustmentDummyField'] = val[3]; 
                                cmp.set("v.selectedAdjCode",adjCodeLst[0].label);
                                EraItemsList[i]['AdjustmentCode'] = adjCodeLst;
                            }
                            
                        }
                        cmp.set('v.EraItemsList',EraItemsList);
                        console.log('$$$$ EraItemsList : ' + JSON.stringify(EraItemsList));
                    }
                    else
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : '',
                            message: 'No Data Found.',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    onCodeChange : function(cmp,event,helper)
    {
        var selVal = event.getSource().get("v.value");
        console.log(selVal); 
        var selValLst = selVal.split('#');
        var amount = selValLst[0];
        var field = selValLst[1];
        var eliId = selValLst[2];
        var dummyfield = selValLst[3];
        var EraItemsList = cmp.get("v.EraItemsList");
        for(var i in EraItemsList)
        {
            if(EraItemsList[i]['Id'] == eliId )
            {
                EraItemsList[i]['totalAdjustment'] = EraItemsList[i][field];
                EraItemsList[i]['AdjustmentField'] = field; 
                EraItemsList[i]['AdjustmentDummyField'] = dummyfield; 
                break;
            }
        }
        cmp.set("v.EraItemsList",EraItemsList);
        
        //console.log(event.currentTarget.getAttribute("value"));
        
    },
    onAdjAmountChange : function(cmp,event,helper)
    {
        var inputVal = event.getSource().get("v.value");
        var eliId = event.getSource().get("v.name");
        console.log(eliId);
        var EraItemsList = cmp.get("v.EraItemsList");
        for(var i in EraItemsList)
        {
            if(EraItemsList[i]['Id'] == eliId )
            {
                //EraItemsList[i]['totalAdjustment'] = EraItemsList[i][field];
                var field = EraItemsList[i]['AdjustmentField'];
                var dummyfield = EraItemsList[i]['AdjustmentDummyField'];
                EraItemsList[i][field] = inputVal;
                EraItemsList[i][dummyfield] = inputVal;
                console.log('**** ' + JSON.stringify(EraItemsList[i]));
                break;
            }
        }
        cmp.set("v.EraItemsList",EraItemsList);
        //console.log('**** ' + JSON.stringify(EraItemsList));
    },
    
    postPayments : function(component, event, helper) {
        var eraItemList = component.get("v.EraItemsList");
        console.log(eraItemList);
        helper.doPostERAPayments(component, event, helper);
    },
    
    cancel : function(cmp, event, helper)
    {
        $A.get('e.force:refreshView').fire();
    },
    
    save : function(cmp, event, helperhandleRowAction)
    {
        var eraItemList = cmp.get("v.EraItemsList");
        console.log(eraItemList);
        helper.saveManualERA(cmp, event, helper);
    },
    AddEra : function(cmp, event, helper){
        cmp.set("v.openAddERAModal",true);
    },
    viewERA :  function(cmp, event, helper){
        cmp.set("v.viewAddERAModal",true);
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.RowId",row.Id);
        component.set("v.SelectedRec",row);
        
        switch (action.name) {   
            case 'recLink':
                component.set("v.isEnabledEditButton",true);
                component.set("v.editScreenDisabled",true);
                component.set("v.editScreen",true);               
                break;
                
                
            case 'DELETE':
                component.set("v.showConfirmDialog",true);                
                break;
        }
    },
    
    handleRowActionChild : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.childRowId",row.Id);
        
        switch (action.name) {   
            case 'recLink':
                component.set("v.isOpenChild",true);              
                break;
        }
    }
})