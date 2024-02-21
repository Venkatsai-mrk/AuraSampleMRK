({
    computeDates : function(component, event, helper) {
        component.set("v.errorType",'');
        let startDate = component.get("v.Fdate");
        let endDate = component.get("v.Tdate");
        if($A.util.isUndefinedOrNull(startDate)){
            component.set("v.errorType",'Fdate');
            component.set("v.errorMsg",'From Date cannot be empty');
            return 1;
        }
        if($A.util.isUndefinedOrNull(endDate)){
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot be empty');
            return 1;
        }
        if(startDate>=endDate){  
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot less than From Date');
            return 1;
        }
    },
    disableNewButton : function(component){ //Ansuha - start -29/10/22
        var action = component.get("c.getCustomSettings");
        console.log("helper method been called");
        action.setCallback(this, function(response) {
            console.log('response',response.getReturnValue());
            if(response.getReturnValue()=='disableButton'){
                component.set("v.disableNewButton",true);
            }  
        });
        $A.enqueueAction(action);
    }, //Ansuha - End -29/10/22
})