({
    doInit: function(component) {
        // Retrieve custom setting values and set component attributes
        var helpTextValue = $A.get("$Label.c.AppointmentIntervalHelptext");
        console.log('helpTextValue'+helpTextValue);
        component.set("v.helpText",helpTextValue);
        console.log('helpTextValue'+component.get("v.helpText"));
        var action = component.get("c.getCustomSetting");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            var settings={};
            console.log("settings: " + JSON.stringify(settings));
            console.log("settings: " + settings.ElixirSuite__Enable_portal_in_Elixir__c);
            if (state === "SUCCESS") {
                 settings = response.getReturnValue();
                 component.set("v.settings",settings);
                 console.log("settings: " + JSON.stringify(settings));
                 console.log("settings: " + settings.ElixirSuite__Enable_portal_in_Elixir__c);
              }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    saveCustomSettings : function(component) {
       var settings = component.get("v.settings");
       console.log("settings: " + JSON.stringify(settings));
       console.log("settings: " + settings.ElixirSuite__Enable_portal_in_Elixir__c);
       var action = component.get("c.saveApprovalCareSettings");
       action.setParams({
            customSetting: [settings]
                    });
        console.log("settings: " + JSON.stringify(settings));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Custom setting saved successfully.");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message":  "Setting saved successfully.",
                    "type" :'success'
                });
                toastEvent.fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    }
    
})