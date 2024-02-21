({
    fireToast : function(state, message) {
       /* sforce.one.showToast({
            "title": state,
            "type": state,
            "message": message
        });*/
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": state,
                "title": "",
                "message": message
            });
            toastEvent.fire();
        console.log('AAAA');
    },
    viewName: function(component) {
        var duplicateChecker = component.get("c.viewId");
        duplicateChecker.setCallback(this, function(response){
        var state = response.getState();
            if(state === "SUCCESS"){   
                let viewId = response.getReturnValue();
               
                var homeEvent = $A.get("e.force:navigateToList");
                homeEvent.setParams({
                    "listViewId": viewId,
                    "listViewName": null,
                    "scope": "ElixirSuite__Claim__c",
                    "isredirect": "true" 
                });
                homeEvent.fire();
               component.set("v.callClaimSubmit", false);
                 component.set("v.loaded",false);
            }
        });  
        $A.enqueueAction(duplicateChecker);
    }
})