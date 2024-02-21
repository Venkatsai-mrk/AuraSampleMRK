({
	navToListView: function (component, event, helper) {

        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "ElixirSuite__Message_Subject__c"
                });
                navEvent.fire();
                
            }
            
        });
        $A.enqueueAction(action);
          },
    navigateToListView: function(component, event, helper) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ElixirSuite__Message_Subject__c',
                actionName: 'list'
            }
        };
        navService.generateUrl(pageReference).then(function(url) {
            window.location.href = url;
        });
    }

})