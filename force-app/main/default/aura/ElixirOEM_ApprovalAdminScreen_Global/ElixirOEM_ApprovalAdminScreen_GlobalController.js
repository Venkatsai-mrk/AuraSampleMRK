({
    doInit : function(component, event, helper) {
        helper.buildWrapper(component, event, helper);
    },
    handleApprovalSelection :  function(component, event, helper) {
        if(event.getSource().get("v.value")=='CarePlan'){
            component.set("v.afterApprovalUnitSelection",true);
        }
        else {
            component.set("v.afterApprovalUnitSelection",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "UNDER DEVELOPMENT",
                "message": "Selected unit is still under development!",
                "type" : "info"
            });
            toastEvent.fire();
        }
        
    },
    completeTransaction :  function(component, event, helper) {
        component.set("v.afterApprovalUnitSelection",false);
        helper.buildWrapper(component, event, helper);
        
    }
})