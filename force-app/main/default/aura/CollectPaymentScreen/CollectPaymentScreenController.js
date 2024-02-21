({
	doInit : function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
          
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Payments"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Payments"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:moneybag",
                iconAlt: "Payments"
            });
        })
        console.log('initupd7***');
        helper.setColumns(component);
        helper.displayDetails(component, event, helper) ;	
        console.log('Record',component.get("v.recordId"));
	},
    
    navToListView: function(component, event, helper) {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },
    navToAccRecord: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    getField: function (cmp, evt, helper) {
        if(cmp.find('select1').get('v.value')==''){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.chequeNo",'');
            cmp.set("v.creditCardId",'');
        }
        if(cmp.find('select1').get('v.value')=='Cheque'){
            cmp.set("v.cheque",true);
            cmp.set("v.Credit",false);  
            cmp.set("v.creditCardId",'');
        }
        if(cmp.find('select1').get('v.value')=='Cash'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false);
            cmp.set("v.chequeNo",'');
            cmp.set("v.creditCardId",'');
        }
        if(cmp.find('select1').get('v.value')=='Credit Card'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",true); 
             cmp.set("v.chequeNo",'');
        }
        if(cmp.find('select1').get('v.value')=='EFT'){
            cmp.set("v.cheque",false);
            cmp.set("v.Credit",false); 
            cmp.set("v.chequeNo",'');
            cmp.set("v.creditCardId",'');
        }
        helper.registerThePaymentButtonHandler(cmp,evt,helper); //Anusha - 30/09/2022
    },
    setValue: function(component, event, helper){
        helper.bottomSection(component, event, helper);
        //helper.registerThePaymentButtonHandler(cmp, event, helper);
        
    },
    getPaymentReason: function(component, event, helper){
        helper.bottomSection(component, event, helper);
        //helper.registerThePaymentButtonHandler(cmp, event, helper);
        
    },
    handleCreditSelectedRow :function(cmp,event){
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));  
        cmp.set("v.creditSelectedRows",event.getParam('selectedRows')); 
        var creditCard =  cmp.get("v.creditSelectedRows");
        cmp.set("v.creditCardId",creditCard[0].Id);
    },
    calculateCreditAmount:function(cmp,event,helper){
        var recsObj =event.getParam('recordList');
        console.log('recsObj',recsObj);
        var sumOfAmount = 0;
        for(var b in recsObj)
        {
            sumOfAmount +=  recsObj[b].ElixirSuite__Total_Remaining_Unallocated_Amount__c;
        }
        console.log('sumOfAmount1',sumOfAmount);
        
        cmp.set("v.creditMemoSelectedRows",recsObj);
        cmp.set("v.TotalCreditAmount",sumOfAmount);
        helper.bottomSection(cmp, event, helper);
    },
    handleProcedureSelected:function(cmp,event,helper){
        var procRec =event.getParam('procedureList');
        var type =event.getParam('Type');
        console.log('procedureList',procRec);
        cmp.set("v.toggleValue",type);
        cmp.set("v.selectedProcedures",procRec);
        helper.addDiscountButtonHandler(cmp);
        helper.bottomSection(cmp, event, helper);
    },
 
    addDiscountCtrl:function(cmp,event,helper){
        
        helper.addDiscountHelper(cmp,event,helper);
        console.log('addDiscount129***');
    },
 
    registerPayment:function(cmp,event,helper){
        console.log('RecordProc',cmp.get("v.selectedProcedures"));
        try{
            if(helper.checkRequieredValidity(cmp,event,helper)){
				helper.savePayments(cmp,event,helper);
                    
            }
        }
        catch(e){
            alert(e);
        }
    }
})