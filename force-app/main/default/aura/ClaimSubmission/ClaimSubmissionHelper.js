({
    fireToast : function(state, message) {
         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": state,
                "title": "",
                "message": message
            });
            toastEvent.fire();
    },
/*
    duplicateChecker : function(component, helper) {
        var duplicateChecker = component.get("c.isDuplicateError");
        duplicateChecker.setParams({claimLst :component.get("v.formedClaimIds")});
        duplicateChecker.setCallback(this, function(response){
        var state = response.getState();
            if(state === "SUCCESS"){    
                let parsedResponse = response.getReturnValue();  
                let isDuplicate = parsedResponse.duplicate;
                let viewId = parsedResponse.viewId;
                if(isDuplicate){
                    this.fireToast('ERROR','Duplicate file detected');
                    if(!$A.util.isUndefinedOrNull(viewId)){
                    var homeEvent = $A.get("e.force:navigateToList");
                    homeEvent.setParams({
                        "listViewId": viewId,
                        "listViewName": null,
                        "scope": "ElixirSuite__Claim__c",
                         "isredirect": "true" 
                    });
                    homeEvent.fire();
                   component.set("v.callClaimSubmit", false);
                  
                } 

                }else{
                   this.fireToast('SUCCESS','The Claim has been sent to the Clearing House successfully');
                    if(!$A.util.isUndefinedOrNull(viewId)){
                    var homeEvent = $A.get("e.force:navigateToList");
                    homeEvent.setParams({
                        "listViewId": viewId,
                        "listViewName": null,
                        "scope": "ElixirSuite__Claim__c",
                         "isredirect": "true" 
                    });
                    homeEvent.fire();
                   component.set("v.callClaimSubmit", false);
                  
                } 
                   
                }
            }
        });  
        $A.enqueueAction(duplicateChecker);
    },*/
    viewName: function(component) {
        var duplicateChecker = component.get("c.viewId");
        duplicateChecker.setCallback(this, function(response){
        var state = response.getState();
            if(state === "SUCCESS"){   
                let viewId = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(viewId)){
                    var homeEvent = $A.get("e.force:navigateToList");
                    homeEvent.setParams({
                        "listViewId": viewId,
                        "listViewName": null,
                        "scope": "ElixirSuite__Claim__c",
                         "isredirect": "true" 
                    });
                    homeEvent.fire();
                    component.set("v.callClaimSubmit", false);
                  
                }  
            }
        });  
        $A.enqueueAction(duplicateChecker);
    }
})