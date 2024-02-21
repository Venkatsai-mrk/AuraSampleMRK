({
    doInit : function(component,event, helper) {
        component.set("v.isPopUp",true); 
    },
    submitDetails: function(component,event, helper) {
        component.set("v.isPopUp",false); 
        component.set("v.loaded",true);
        var action = component.get("c.updateClaims");
        action.setParams({claimLst :component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var res = response.getReturnValue();
            if(state === "SUCCESS"){
                //window.setTimeout($A.getCallback(function() {
                    helper.fireToast('SUCCESS',res);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    component.set("v.loaded",false);
                    $A.get('e.force:refreshView').fire();
                    //helper.duplicateChecker(component); 
                // }), 5000);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.fireToast('ERROR',errors[0].message);
                    }
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                component.set("v.loaded",false);
            }
        });
        $A.enqueueAction(action);     
    },
    closePopUp : function(component,event){
        var duplicateChecker = component.get("c.viewIdAll");
        duplicateChecker.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){   
                let viewId = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(viewId)){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/r/ElixirSuite__Claim__c/"+component.get("v.recordId")+"/view",
                        "isredirect": true
                    });
                    urlEvent.fire(); 
                    
                }  
            }
        });  
        $A.enqueueAction(duplicateChecker);
    },
})