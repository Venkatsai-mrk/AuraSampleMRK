({
	createTableData : function(component) {
        var action = component.get("c.getClaimLines");
        
        action.setParams({
                "recordId": component.get("v.claimId")
                
            });
        component.set("v.loaded",false);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    component.set("v.loaded",true);
                    var res = response.getReturnValue();
                    console.log('res',res);
                    
                    
                    component.set("v.intialClaimlineList",res);
                    component.set("v.claimlineList",res);
                }catch(e){
                    alert(e);
                }
            }
        });
        $A.enqueueAction(action);
    }
})