({
	myAction : function(component, event, helper) {
        console.log("sync charges recId***",component.get("v.recordId"));
        var toastEvent = $A.get("e.force:showToast");  
        
        toastEvent.setParams({
                        "type": "Success",
                        "title" : "Sync Charges Completed",
                        "message": "Charges updated.",
                        
                    });
                    toastEvent.fire(); 
        
         window.setTimeout($A.getCallback(function() {
               
            }), 5000);
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
        
        helper.syncChargesHelper(component, event, helper);//added by Anmol
	}
})