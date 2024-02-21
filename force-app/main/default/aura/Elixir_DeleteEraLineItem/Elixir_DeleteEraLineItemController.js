({
	myAction : function(component, event, helper) {
		
	},
    deleteCriteria : function(component, event, helper){
        
        component.set("v.isOpenForDeleteERALine",false);
        var cmpEvent = component.getEvent("deleteEralineEvent");
        cmpEvent.setParams({"lineIndex" : component.get("v.selectedIndex"),
                            "deletedLineId" : component.get("v.selectedERALineId")
                           });
        cmpEvent.fire();
        
        
        /*
         console.log('res',component.get("v.selectedERALineId"));
        var action = component.get("c.deleteEraLineItem");
        action.setParams({
                "recordId": component.get("v.selectedERALineId")
            });
         console.log('res',component.get("v.selectedERALineId"));
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                var res = response.getReturnValue();
                console.log('res',res);
                var cmpEvent = component.getEvent("eralineEvent");
                cmpEvent.setParam("message", "the message to send" );
                cmpEvent.fire();
                component.set("v.isOpenForDeleteERALine",false);
            }
        });
        $A.enqueueAction(action);
        */
       
    },
    cancelWindow : function(component, event, helper){
        component.set("v.isOpenForDeleteERALine",false);
    },
})