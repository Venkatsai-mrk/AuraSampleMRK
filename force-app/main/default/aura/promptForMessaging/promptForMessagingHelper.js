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
    navToMessageSubjectListView : function (component, event, helper) {
        var accRecId  = component.get("v.patientId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:customListViewMsgSubject",
            componentAttributes: {
                patientID : accRecId,
                navToListView : true
            }
        });
        evt.fire(); 
        
        var appEvent = $A.get("e.c:RefreshMessages"); 
        appEvent.fire(); 

        
        console.log(accRecId+' accRecId');
        

}
})