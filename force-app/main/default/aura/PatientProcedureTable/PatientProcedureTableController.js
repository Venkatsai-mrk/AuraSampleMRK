({
	doInit : function(cmp, event, helper) {
        cmp.set("v.procedureSearchParams",{'From' : '','To' : ''});  
        cmp.set("v.isSearchDisabled",false); 
        cmp.set("v.selectedProcedureRows",[]);
        cmp.set("v.claimsList",[]);
        helper.setColumns(cmp);
        helper.displayDetails(cmp, event, helper) ;	
        console.log('patientProcInit6****');
        
	},
    onDOSChange :  function(cmp, event, helper){
        try{
            
            let procedureSearchParams = cmp.get("v.procedureSearchParams");
            if((!$A.util.isUndefinedOrNull(procedureSearchParams.To)) && (!$A.util.isUndefinedOrNull(procedureSearchParams.From))){      
                
                let dosFrom =  new Date(procedureSearchParams.From);
                let dosTo =  new Date(procedureSearchParams.To);
                if(dosTo && dosFrom){
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
    
    handleRowActionP: function(component, event,helper) {
        
        try{
            console.log('inside handleRow Action');
            var action = event.getParam('action');
            var  row = event.getParam('row');
            console.log(action.name);
            
            
            var tempMaxAmt =(row.ElixirSuite__PatientOutstanding__c).toFixed(2) ;
            var maxAmount = tempMaxAmt;
            console.log('maxAmount'+maxAmount);
            var tempMaxDisc = (row.ElixirSuite__Actual_Price__c == null || row.ElixirSuite__Actual_Price__c == 0 || row.ElixirSuite__Actual_Price__c == 0.00 || row.ElixirSuite__Actual_Price__c == '') ? 0:((100*maxAmount) / (row.ElixirSuite__Actual_Price__c)).toFixed(2);
            var maxDiscount = tempMaxDisc;
            console.log('maxDiscount'+maxDiscount);
             
            
            switch (action.name) {
                case 'recLink':
                    component.set("v.maxAmountforDiscount", maxAmount);
                    component.set("v.maxPercentageforDiscount", maxDiscount);
                    component.set("v.currentActiveID", row.Id);
                    component.set("v.isDiscountModalOpen", true);
                    
                    break;
                case 'Link':
                    helper.navigateToRecordDetail(component, event,helper);
                    break;
            }
        }catch(e){
            alert(e.message);
        }
    },
    
    handleDiscountCmpEvent : function(component, event) {
        
        console.log('oooppp ');
        console.log('procedureType1***',component.get("v.procedureType"));
        var procedureTyp = component.get("v.procedureType");
        var inputvalueFromChild = 0;
        inputvalueFromChild = event.getParam("inputValue");	
        var typevalueFromChild = event.getParam("type");
        console.log("type",typevalueFromChild);	
        console.log("val**",inputvalueFromChild);	
        var allDataInsurance;
        var allProc = false;
        var insProc = false;
        var privProc = false;
        if(procedureTyp == 'All Procedures'){
            allDataInsurance =component.get("v.Allprocedures");	
            allProc = true;
        }
        if(procedureTyp == 'Insurance Procedures'){
            allDataInsurance =component.get("v.InsuranceData");	
            insProc = true;
        }
        if(procedureTyp == 'Private Procedures'){
            allDataInsurance =component.get("v.PrivateData");	
            privProc = true;
        }
        
        console.log('allDataInsurance'+allDataInsurance);
        for(var recdata in allDataInsurance){
            console.log("ROw Id ",allDataInsurance[recdata].Id);	
            console.log("currentActiveID",component.get("v.currentActiveID"));	
            if(allDataInsurance[recdata].Id==component.get("v.currentActiveID")){
                if(typevalueFromChild == 'Percentage'){
                    let percentValue = parseFloat(inputvalueFromChild)/100;
                    console.log('Percent Value'+percentValue);
                    allDataInsurance[recdata].otherDiscount = parseFloat(inputvalueFromChild);// + parseFloat(allDataInsurance[recdata].ElixirSuite__Other_Discount__c);
                    allDataInsurance[recdata].discountType = typevalueFromChild;
                    allDataInsurance[recdata].discountStr = parseFloat(inputvalueFromChild).toString() + '%';
                     
                }else if(typevalueFromChild == 'Amount'){
                    console.log("typevalueFromChild ",typevalueFromChild);
                    console.log("inputvalueFromChild ",inputvalueFromChild);
                    console.log("inputvalueFromChild ",inputvalueFromChild);
                    allDataInsurance[recdata].otherDiscount = parseFloat(inputvalueFromChild); // + allDataInsurance[recdata].ElixirSuite__Other_Discount__c;   
                    allDataInsurance[recdata].discountType = typevalueFromChild;
                    allDataInsurance[recdata].discountStr = '$' + parseFloat(inputvalueFromChild).toString() ;
                   
                }
            }
        }
        
        if(allProc){
        component.set("v.Allprocedures",allDataInsurance);
}
        else if(insProc){
            component.set("v.InsuranceData",allDataInsurance);
        }
        else if(privProc){
            component.set("v.PrivateData",allDataInsurance);
        }
        
        console.log('abcc '+JSON.stringify(component.get("v.Allprocedures")));
        
    },
    
    searchprocedure : function(cmp, event, helper) {
        try{
            var procedureSearchParams = cmp.get("v.procedureSearchParams");
            if(procedureSearchParams.From || procedureSearchParams.To){
                var dosFrom =  JSON.parse(JSON.stringify(procedureSearchParams.From));
                var dosTo =  JSON.parse(JSON.stringify(procedureSearchParams.To));
                if(dosFrom == '' && dosTo!=''){
                    dosFrom = dosTo;
                    cmp.set("v.procedureSearchParams.From",dosTo);
                }
                else if(dosTo=='' && dosFrom!=''){
                    // var today = new Date();
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(dosFrom>today){
                        dosTo = dosFrom;
                        cmp.set("v.procedureSearchParams.To",dosFrom);
                    }
                    else {
                        dosTo = today; 
                        cmp.set("v.procedureSearchParams.To",today);
                    }            
                }
                console.log('dosFrom',dosFrom);
                var action = cmp.get("c.filterProcedurebasedOnDOS");
                action.setParams({accountId : cmp.get("v.recordId"),
                                  dosFrom : dosFrom,
                                  dosTo : dosTo});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") { 
                        var result = response.getReturnValue();
                         console.log('result ----- ' + JSON.stringify(result));
                        if(!$A.util.isEmpty(result.procData)){
                            helper.procedureData(cmp,result);
                        }
                        else{
                            helper.globalFlagToast(cmp, event, helper,'NO RESULTS FOUND!', 'Please try a different Dates!','error');
                        }
                                               
                        
                    }
                });
                $A.enqueueAction(action); 
                
            }
            else {
                helper.globalFlagToast(cmp, event, helper,'DATES NOT MENTIONED!', 'Please apply Date to search!','error');
            }
            
        }
        catch(e){
            alert(e);
        }
        
    },
    getProcedureType: function (cmp, event, helper) {
        cmp.set("v.selectedProcedureRows",[]);
        
        if(cmp.find('select1').get('v.value')=='All Procedures'){
            cmp.set("v.procedureType",'All Procedures');
        }
        else if(cmp.find('select1').get('v.value')=='Insurance Procedures'){
            cmp.set("v.procedureType",'Insurance Procedures');
        }
        else if(cmp.find('select1').get('v.value')=='Private Procedures'){
            cmp.set("v.procedureType",'Private Procedures');
        }
        else if(cmp.find('select1').get('v.value')=='By Claims'){
            cmp.set("v.procedureType",'By Claims');
        }
        var cmpEvent = cmp.getEvent("procedurehandlerEvent");
        cmpEvent.setParams( { "procedureList" :  [],
                             "Type" : cmp.get("v.procedureType")} );
        cmpEvent.fire();
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
    handleAllprocedures : function(component,event){
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedProcedureRows",selectedRows);
        
        console.log('selectedRows1122',selectedRows);
        var cmpEvent = component.getEvent("procedurehandlerEvent");
        cmpEvent.setParams( { "procedureList" :  selectedRows,
                             "Type" : component.get("v.procedureType")} );
        cmpEvent.fire();
        
    },
    /*
    handleInsuranceprocedures : function(component,event){
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedProcedureRows",selectedRows);
    },
    
    handleprivateprocedures : function(component,event){
        var selectedRows =  event.getParam('selectedRows');  
        component.set("v.selectedProcedureRows",selectedRows);
    },*/
    
     handleOnClaimSelection : function(cmp, event, helper)
    {
        var getClaimId = event.getSource().get("v.name");
        var getSelected = event.getSource().get("v.checked");
        var claimsList = cmp.get("v.claimsList");
        var noOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");
        var selectedIds = cmp.get("v.PayTransId");
        if(getSelected == true)
        {
            noOfClaimsSelected = noOfClaimsSelected + 1;
        }
        else
        {
            noOfClaimsSelected = noOfClaimsSelected - 1;
        }
        console.log('#### claimsLength -- ' + claimsList.length);
        console.log('#### NoOfClaimsSelected ---- ' + noOfClaimsSelected);
        
        if(claimsList.length == noOfClaimsSelected)
        {
            cmp.set('v.selectAllClaims',true);
        }
        else
        {
            cmp.set('v.selectAllClaims',false);
        }
        cmp.set("v.NoOfClaimsSelected",noOfClaimsSelected);
        for(var i in claimsList)
        {
            if(getClaimId == claimsList[i].ClaimId)
            {
                 console.log('#### Inside ');
                if('procWrap' in claimsList[i])
                {
                    var procWrapList = claimsList[i].procWrap;
                    for(var j in procWrapList)
                    {
                        if(getSelected == true && procWrapList[j].Selected != true)
                        {
                            //totalAmount = totalAmount + procWrapList[j].ElixirSuite__PatientOutstanding__c;
                            selectedIds.push(procWrapList[j].ProcId);
                        }
                        if(getSelected == false && procWrapList[j].Selected != false)
                        {
                            //totalAmount = totalAmount - procWrapList[j].ElixirSuite__PatientOutstanding__c;
                            for( var ind = 0; ind < selectedIds.length; ind++)
                            { 
                                if( selectedIds[ind] == procWrapList[j].ProcId) 
                                { 
                                    selectedIds.splice(ind, 1); 
                                    ind--;
                                }
                            }
                        }
                        procWrapList[j].Selected = getSelected;
                    }
                    claimsList[i].procWrap = procWrapList;
                }
                if(getSelected == true)
                {
                    claimsList[i].NoOfSelectedProcs = claimsList[i].OpenProc;
                }
                else
                {
                    claimsList[i].NoOfSelectedProcs = 0;
                    
                }
            }
        }
        cmp.set('v.claimsList',claimsList);
        
		 helper.getProcedureRec(cmp, event, helper) ;
        console.log('#### selectedIds CLAIMS  - ' + selectedIds);

    },
    
    handleOnProcSelection : function(cmp, event, helper)
    {
        var getClaimId = event.getSource().get("v.value");
        var getProcId = event.getSource().get("v.name");
        var getSelected = event.getSource().get("v.checked");
        var claimsList = cmp.get("v.claimsList");
        var totalAmount = 0;
        var selectedIds = cmp.get("v.PayTransId");
        var noOfClaimsSelected = cmp.get("v.NoOfClaimsSelected");

        for(var i in claimsList)
        {
            console.log('getClaimId',getClaimId,'===',claimsList[i],'---',getSelected,'-+-',getProcId);
            if(getClaimId == claimsList[i].claimId)
            {
                if('procWrap' in claimsList[i])
                {
                    var procWrapList = claimsList[i].procWrap;
                    console.log('procWrapList3',procWrapList);
                    for(var j in procWrapList)
                    {
                        if(getProcId == procWrapList[j].ProcId)
                        {
                            if(getSelected == true)
                            {
                                totalAmount = totalAmount + procWrapList[j].ElixirSuite__PatientOutstanding__c;
                                selectedIds.push(getProcId);
                                if(claimsList[i].OpenProc == 1)
                                {
                                    claimsList[i].Selected = true;
                                    claimsList[i].NoOfSelectedProcs = claimsList[i].OpenProc;
                                }
                                else
                                {
                                    claimsList[i].NoOfSelectedProcs = claimsList[i].NoOfSelectedProcs + 1;
                                }
                            }
                            if(getSelected == false)
                            {
                                totalAmount = totalAmount - procWrapList[j].ElixirSuite__PatientOutstanding__c;
                                claimsList[i].Selected = false;
                                if(claimsList[i].OpenProc == 1)
                                {
                                    claimsList[i].NoOfSelectedProcs = 0;
                                }
                                else
                                {
                                    claimsList[i].NoOfSelectedProcs = claimsList[i].NoOfSelectedProcs - 1;
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
                                noOfClaimsSelected = noOfClaimsSelected - 1;
                            }
                            break;
                        }
                    }
                    if(claimsList[i].NoOfSelectedProcs == claimsList[i].OpenProc)
                    {
                        claimsList[i].Selected = true;
                        noOfClaimsSelected = noOfClaimsSelected + 1;
                        
                    }
                }
                break;
            }
        }
        
        
        if(noOfClaimsSelected == claimsList.length)
        {
            cmp.set("v.selectAllClaims",true);
        }
        else
        {
            cmp.set("v.selectAllClaims",false);
        }
        cmp.set("v.NoOfClaimsSelected",noOfClaimsSelected);
        cmp.set('v.claimsList',claimsList);
        cmp.set("v.PayTransId",selectedIds);
        helper.getProcedureRec(cmp, event, helper) ;	
        //nsole.log('#### claimsList== - ' + JSON.stringify(claimsList));

    },
    
    getSelectAllClaims : function(cmp, event, helper)
    {
        var getSelected = event.getSource().get("v.checked");
        var claimsList = cmp.get("v.claimsList");
        var selectedIds = [];
        var procWrapList = [];

        if(getSelected == true)
        {
            for(var i in claimsList)
            {
                console.log('#### INSIDE2');
                if('procWrap' in claimsList[i])
                {
                    procWrapList = claimsList[i].procWrap;
                    for(var j in procWrapList)
                    {
                        console.log('#### INSIDE  - ' + selectedIds);
                        //totalAmount = totalAmount + procWrapList[j].ElixirSuite__PatientOutstanding__c;
                        //sumOfAmountPaid+=ProcWrapList[j].patientOutstanding>0?ProcWrapList[j].patientOutstanding:0; //Anusha 06/10/22
                        selectedIds.push(procWrapList[j].ProcId); 
                        procWrapList[j].Selected = true;
                    }
                    claimsList[i].procWrap = procWrapList;
                    claimsList[i].NoOfSelectedProcs = claimsList[i].OpenProc;
                }
                claimsList[i].Selected = true;
            }
            cmp.set("v.NoOfClaimsSelected",claimsList.length);
            
        }
        else if(getSelected == false)
        {
            for(var a in claimsList)
            {
                if('procWrap' in claimsList[a])
                {
                    procWrapList = claimsList[a].procWrap;
                    for(var b in procWrapList)
                    {
                        procWrapList[b].Selected = false;
                    }
                    claimsList[a].procWrap = procWrapList;
                    claimsList[a].NoOfSelectedProcs = 0;
                }
                claimsList[a].Selected = false;
            }
            cmp.set("v.NoOfClaimsSelected",0);
        }
        cmp.set('v.claimsList',claimsList);
		 helper.getProcedureRec(cmp, event, helper) ;
        console.log('#### selectedIds All CLAIMS  - ' + selectedIds);
    }
    
    
    
})