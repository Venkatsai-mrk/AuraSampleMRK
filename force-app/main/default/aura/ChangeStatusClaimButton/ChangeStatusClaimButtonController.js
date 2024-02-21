({
	doInit : function(component, event, helper) {
        console.log('#### recordId : ' + component.get("v.recordId"));
		var action = component.get("c.checkClaimStatus");
        action.setParams({
            'claimId' : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
      	 var state = response.getState();
            var res = response.getReturnValue();
            if(state === "SUCCESS"){
               console.log(state)
               helper.fireToast(state,'Your request has been submitted');
              // helper.sendCallOut(component);
               helper.refreshViewIn2Sec();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.fireToast(state,errors[0].message);
                    }
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    }
})