({
    helperMethod : function(component,event,helper) {
        alert('here after promise');
        var action = component.get("c.countExistingRecords");    
        action.setParams({
            acctId:  component.get("v.recId")
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('true');
            }
        });           
        $A.enqueueAction(action);
    }
})