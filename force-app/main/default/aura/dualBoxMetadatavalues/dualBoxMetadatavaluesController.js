({
    init : function(component, event, helper) {
        var action = component.get("c.getselectOptions");
        
        var opts = [];
        action.setParams({
            Cid : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue().ListOfCodes;
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v.options", opts);
                var res = response.getReturnValue().claimRecord;
                if(res.ElixirSuite__Claim_Status__c=='Underpaid' || res.ElixirSuite__Claim_Status__c=='Overpaid'){
                    component.set("v.visible",true);
                }
                else {
                    component.set("v.visible",false);
                }
            }else{
                //alert('Callback Failed...');
            }
        });
        $A.enqueueAction(action);
    },
    handleChange: function (component, event, helper) {
        
        var selectedOptionsList = event.getParam("value");       
        component.set("v.selectedoptions" , selectedOptionsList);
        
    },
    
    updateRecord: function(component, event, helper) {
        
        component.set("v.isOpen", true);
        
        var action = component.get("c.getValues");
        var claimid = component.get("v.recordId");
        var selectedoptions = component.get("v.selectedoptions") ;
        action.setParams({
            "claimid": claimid,
            "selectedoptions": selectedoptions
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Re-Submission Codes successfully added to the Claims.',
                    type: 'success'
                });
                toastEvent.fire();
                component.set("v.isOpen", false);
                component.set("v.visible",false);
                $A.get('e.force:refreshView').fire();
                
            } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    type: 'error',
                    message : "Re-Submission Codes could not be successfully added to the Claims."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    closeModal: function(component, event, helper) {
        
        component.set("v.isOpen", false);
    },
    
    openModal: function(component, event, helper) {
        
        component.set("v.isOpen", true);
    }
})