({
	getAccountInfo : function(component) {
        var action = component.get("c.getAccountName");
        action.setParams({
            'accountId': component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('acc refund state***',state);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();  
                component.set("v.accName", res);
            }
            else{
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
		
	}
})