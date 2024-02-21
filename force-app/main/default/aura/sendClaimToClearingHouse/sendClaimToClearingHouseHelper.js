({
    fireToast : function(state, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": state,
            "type": state,
            "message": message
        });
        toastEvent.fire();
    }/*,
    duplicateChecker : function(component) {
        var duplicateChecker = component.get("c.isDuplicateError");
        duplicateChecker.setParams({claimLst :component.get("v.recordId")});
        duplicateChecker.setCallback(this, function(response){
            var state = response.getState();
            let parsedResponse = response.getReturnValue();  
            let isDuplicate = parsedResponse.duplicate;
            if(state === "SUCCESS"){
                if(isDuplicate){
                    this.fireToast('ERROR','Claim is already send to clearing house,Change in status is not permitted at this point of time');
                }else{
                    this.fireToast('SUCCESS','The Claim has been sent to the Clearing House successfully');
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                component.set("v.loaded",false);
                $A.get('e.force:refreshView').fire();
            }else{
                component.set("v.loaded",false);
            }
        });  
        $A.enqueueAction(duplicateChecker);
    }*/		
})