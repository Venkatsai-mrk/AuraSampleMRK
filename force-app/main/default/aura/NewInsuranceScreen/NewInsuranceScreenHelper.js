({
	navToListView: function (component, event, helper) {
        var accRec = component.get("v.accountRecord");
        if(accRec){
            
            var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accRec.Id
        });
        navEvt.fire();
        }
        else{
        
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewName": null,
                "scope": "ElixirSuite__VOB__c"
            });
            navEvent.fire();
    }
		
	}
})