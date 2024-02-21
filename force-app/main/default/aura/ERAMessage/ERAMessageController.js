({
	doInit : function(component, event, helper) {
    //    $A.get("e.force:closeQuickAction").fire();
		var action = component.get("c.updateClaim");
        action.setParams({
            claimId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
      	 var state = response.getState();
            var res = response.getReturnValue();
            if(state === "SUCCESS"){
                var val1 = res.messege ;
                var val2 = res.check ;
                console.log('d' , val2);
               var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                if(val2 == true){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "success!",
                    "type":"SUCCESS",
                    "message": "ERA Request has been Submitted successfully. Please refresh the screen to check if ERA has arrived."
                });
                toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                if(val2 == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "success!",
                    "type":"SUCCESS",
                     "message": "ERA Request has been Submitted successfully. Please refresh the screen to check if ERA has arrived."
                });
                toastEvent.fire();
                }
                
             $A.get('e.force:refreshView').fire();    
            }
        });
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    }
})