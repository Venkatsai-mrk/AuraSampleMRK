({
    closeModel : function(component, event, helper) {
        component.set("v.isOpen",false);
    },
    submitDetails: function(component, event, helper) {
        component.find("v.recordFormForRefEdit").submit();
    },
    showToast : function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type": "Success",
        "title": "Success!", 
        "message": "The record has been updated successfully."
    });
    toastEvent.fire();
    }
})