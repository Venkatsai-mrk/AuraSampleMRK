({
	doInit : function(component, event, helper) {
		var action = component.get("c.reverseReconciliation");
        action.setParams({claimLst :component.get("v.recordId")});
        action.setCallback(this, function(response){
      	    var state = response.getState();
            var res = response.getReturnValue();
            console.log(state);
            if(state === "SUCCESS"){ 
             helper.fireToast('SUCCESS','Reverse Reconciliation completed Successfully');
             var dismissActionPanel = $A.get("e.force:closeQuickAction");
             dismissActionPanel.fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.fireToast('ERROR',errors[0].message);
                    }
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);     
    }
})