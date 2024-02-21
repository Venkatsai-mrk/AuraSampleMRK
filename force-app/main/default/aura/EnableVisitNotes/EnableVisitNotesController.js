({
	doInit : function(component, event, helper) {
        // Retrieve custom setting values and set component attributes
        var action = component.get("c.getVisitNotes");
        action.setCallback(this, function(response) {
            var state = response.getState();
		if (state === "SUCCESS") {
            component.set("v.visitNotesValue",response.getReturnValue());
            console.log("visitNotesValue" +component.get("v.visitNotesValue"));
              }
        else {
            console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
		
	},
    handleCheckbox : function(component, event, helper) {
      var isChecked = component.get("v.visitNotesValue");
        console.log("isChecked: " + isChecked);
       
        var action = component.get("c.updateMasterRecord");
        action.setParams({ "enableVisitNotesValue": isChecked });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Success");
            } else {
                console.error("Error: " + state);
            }
        });
        
        $A.enqueueAction(action);
    }
})