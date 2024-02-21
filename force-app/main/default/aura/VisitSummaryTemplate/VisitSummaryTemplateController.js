({
    doInit: function(component, event, helper) {
        component.set("v.showSpinner", true);
        
        // Retrieve the picklist values and display in checkbox
        var action = component.get("c.getVisitSummarySection");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                for (var i = 0; i < result.picklistValues.length; i++) {
                    var option = {
                        label: result.picklistValues[i],
                        value: result.picklistValues[i]
                    };
                    options.push(option);
                }
                component.set("v.picklistOptions", options);
                
                // Fetch selected values and "Visit Summary" checkbox value
                var selectedValuesAction = component.get("c.getSelectedValues");
                selectedValuesAction.setParams({
                    emailSettingName: component.get("v.emailSettingName")
                });
                selectedValuesAction.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.selectedValues", result.selectedValues);
                        component.set("v.visitSummaryEnabled", result.visitSummaryEnabled);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                    component.set("v.showSpinner", false);
                });
                $A.enqueueAction(selectedValuesAction);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCheckboxChange: function(component, event, helper) {
        // To handle the selected values
        var selectedValues = event.getParam("value");
        console.log('selectedValues '+selectedValues);
        component.set("v.selectedValues", selectedValues);
    },
    
    handleSave: function(component, event, helper) {
        // To save the data
        component.set("v.showSpinner", true);
        var selectedSection = component.get("v.selectedValues");
        var visitSummaryEnabled = component.get("v.visitSummaryEnabled");
        var action = component.get("c.saveVisitSummary");        
        action.setParams({
            selectedValues :selectedSection.join(';'),
            emailSettingName : component.get("v.emailSettingName"),
            visitSummaryEnabled: visitSummaryEnabled
        }); 
        action.setCallback(this, function(response) { 
            var state = response.getState();                
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                var result = response.getReturnValue();
                component.set("v.visitSummaryEnabled", result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Visit summary settings saved",
                    "type" : "success"
                });
                toastEvent.fire();
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }                                       
            }                
        });
        $A.enqueueAction(action);        
    },
})