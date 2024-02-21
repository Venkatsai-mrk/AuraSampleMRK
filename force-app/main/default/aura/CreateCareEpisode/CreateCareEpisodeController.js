({
    doInit : function(component, event, helper) {
       var stopRec = component.get("v.stopRec");
        var toastEvent = $A.get("e.force:showToast");
        var pageRef = component.get("v.pageReference");
        console.log('pageRef--'+JSON.stringify(pageRef));
        var eventId = pageRef.state.ElixirSuite__recordId;
        var appStatus = pageRef.state.ElixirSuite__status;
        component.set("v.eventId", eventId);
        component.set("v.eventStatus", appStatus);
        var pageState = pageRef.state; 
        if(pageState.hasOwnProperty('ws')){
            var base64Context = pageState.ws;
            console.log('base64Context--'+JSON.stringify(base64Context));
        }
        if(!$A.util.isUndefinedOrNull(base64Context)){
            var parts = base64Context.split('/'); 
            var accountId = parts[4];
            component.set("v.accountId", accountId);
        }else{
            component.set("v.accountId", ''); 
        }
        console.log('accountId--'+JSON.stringify(component.get("v.accountId")));
        console.log('status****',component.get("v.eventStatus"));
        if(stopRec){
            return;
        }
        var action = component.get("c.createCareEpisode");
        action.setParams({ accountID: component.get("v.accountId"),
                          eventId : component.get("v.eventId"),
                          eventStatus : component.get("v.eventStatus")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state*****",state)
            if (state === "SUCCESS") {
                var r = response.getReturnValue();
                console.log("create care episode*****",r);
                console.log("Url*****",r.Url);
                var result = r.Url;
               var workspaceAPI = component.find("workspace");
                workspaceAPI.isConsoleNavigation().then(function(response) {
                    console.log('response@@',response);
                    component.set("v.isConsole", response);
                })
                .catch(function(error) {
                    console.log(error);
                });
                var redirectUrl = result;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": redirectUrl,
                    "isredirect": true
                });
                urlEvent.fire();
                 component.set("v.stopRec", true);
if(component.get("v.isConsole")){
                $A.get("e.force:refreshView").fire();
}else{
                    window.setTimeout($A.getCallback(function() {
                        window.location.reload();
                        console.log('Timeout completed');
                    }), 50);
                    
                }
            } 
            else {
                console.log("Error creating refunds: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})