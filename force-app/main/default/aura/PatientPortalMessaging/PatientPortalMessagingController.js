({
	doInit : function(component, event, helper) {
		// Retrieve custom setting values and set component attributes
        var action = component.get("c.getCustomSetting");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var settings = response.getReturnValue();
                component.set("v.settings",settings);
                var messagingSettings = settings.ElixirSuite__Disable_Messaging_buttons_from_portal__c;
                console.log('messagingSettings '+messagingSettings);
                var disablePortalButtons = {'New':'FALSE', 'Delete':'FALSE', 'Archive':'FALSE', 'Bookmark':'FALSE'};
                if (messagingSettings) {
                    (messagingSettings.split(';')).map(function(item) {
                        disablePortalButtons[item.trim()] = 'TRUE';
                    }); 
                    component.set("v.disablePortalButtons", disablePortalButtons);
                }
              }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    saveCustomSettings : function(component, event, helper) {
        var buttons = '';
        if(component.find("bookmark").get("v.checked")){
            buttons = buttons + ';' + 'Bookmark';
        }
        if(component.find("archive").get("v.checked")){
            buttons = buttons + ';' + 'Archive';
        }
        if(component.find("new").get("v.checked")){
            buttons = buttons + ';' + 'New';
        }
        if(component.find("delete").get("v.checked")){
            buttons = buttons + ';' + 'Delete';
        }
         var settings = component.get("v.settings");
         // Check each checkbox and append the corresponding value to the custom setting field
        settings.ElixirSuite__Disable_Messaging_buttons_from_portal__c = buttons;
       var action = component.get("c.portalMessagingSettings");
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
                console.log("Failed with state: " + JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    }
})