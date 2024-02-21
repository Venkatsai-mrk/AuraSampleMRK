({
    init : function(component, event, helper) {;
        const params = new URLSearchParams(window.location.search);
        let isOrder = true;
        for (const param of params) {
            if(param[0] == 'orderId' && isOrder){
                isOrder = false;
                component.set("v.orderId", param[1]);
            }else if(param[0] == 'customerId'){
                component.set("v.customerId", param[1]);
            }
        };
        var action = component.get("c.updateTransaction");
        action.setParams({
            orderId: component.get("v.orderId"),
            customerId: component.get("v.customerId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
  
            }
        
        });
        $A.enqueueAction(action);
    },
    submitDetails  : function(component, event, helper) {
        var action = component.get("c.fetchPaymentDetails");
        action.setParams({
            orderId: component.get("v.orderId"),
            customerId: component.get("v.customerId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                helper.generateReceipt(component);
                component.set("v.isModalOpen",false);		
            }       
        });
        $A.enqueueAction(action);
    },
    closeModel	: function(component, event, helper) {
        helper.generateReceipt(component);
        component.set("v.isModalOpen",false);		
    }
})