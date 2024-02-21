({
	myAction : function(component, event, helper) {
        let erasObj = component.get("v.erasObj");
        if(erasObj.isPosted){
             component.set("v.isDisabled",true); 
        }
        helper.getERADetails(component,event);    
	},
    openPop : function(component, event, helper){
        component.set("v.isOpen",true);
    },
    cancelWindow : function(component, event, helper){
        component.set("v.isOpen",false);
    },
    calculateInterestLateFilingCharge_onChange : function(component, event, helper){
        var paidAmt =0;
        var netAmt =0;
        var providerAdAmt = 0;
        var interestlateFiling = 0;
        var billedAmt = 0;
        netAmt  =event.getSource().get('v.value');
        paidAmt = component.get("v.TotalPaid");
        billedAmt = component.get("v.BilledAmount");
        
        interestlateFiling = netAmt - paidAmt;
        providerAdAmt = billedAmt - paidAmt - interestlateFiling;
        component.set("v.interestLateFilingCharges",interestlateFiling);
        component.set("v.TotalProviderAdjustmentAmt",providerAdAmt);
    },
    saveERA : function(component, event, helper){
        component.set("v.childERAtableList", component.get("v.childERAtableList"));
      //  helper.saveEraData(component, event);
         component.set("v.isOpen",false);
    },
    handleComponentEvent :  function(cmp, event,helper) {
        console.log('component event handler');
        var message = event.getParam("message");
        helper.getERADetails(cmp,event);
    },
    handleClaimLineMapEvent : function(component, event,helper) {
        console.log('component event handler');
        var claimlineId = event.getParam("ClaimLineId");
        var index = event.getParam("MapIndex");
        
        var AllRowsList= component.get("v.eraLineLst");
        var matchedAmt= component.get("v.MatchedAmt");
        var paidAmt= component.get("v.TotalPaid");
        var oldClaimLineConnectedEraLine =0;
        for(var i=0;i<AllRowsList.length; i++){
            if(AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c == claimlineId){
                if(i == index){
                    matchedAmt = matchedAmt + AllRowsList[i].eralineItem.ElixirSuite__Paid__c;
                    continue;
                }else{
                    AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c = '';
                    oldClaimLineConnectedEraLine = oldClaimLineConnectedEraLine + AllRowsList[i].eralineItem.ElixirSuite__Paid__c;
                   
                }
            }
        }
        
        matchedAmt = matchedAmt - oldClaimLineConnectedEraLine;
        
        component.set("v.eraLineLst",AllRowsList);
        component.set("v.MatchedAmt",matchedAmt);
        component.set("v.UnmatchedAmt",paidAmt - matchedAmt);
        console.log('component event handler');
    },

})