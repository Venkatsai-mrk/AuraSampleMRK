({
    doInit: function(component, event, helper) {
        var options = component.get("v.options");
        if (options.length === 0) {
            var listOfAllNotes = component.get("v.allRelateNote");
            options = [];
            var selectedValues = [];
            var selectedFormNames = [];
            listOfAllNotes.forEach(function(note) {
                var option = {
                    value: note.Id,
                    label: note.ElixirSuite__Form_Name__c
                };
                options.push(option);
                if (note.isSelected) {
                    selectedValues.push(note.Id);
                    selectedFormNames.push(note.ElixirSuite__Form_Name__c);
                }
            });
            component.set("v.options", options);
            component.set("v.selectedValues", selectedValues);
            component.set("v.selectedFormNames", selectedFormNames);
        }
    },

    handleFormSelection: function(component, event, helper) {
         var selectedValues = event.getParam("value");
        var selectedFormNames = [];
        
        // Get the selected form names based on the selected values
        var listOfAllNotes = component.get("v.allRelateNote");
        listOfAllNotes.forEach(function(note) {
            if (selectedValues.includes(note.Id)) {
                selectedFormNames.push(note.ElixirSuite__Form_Name__c);
            }
        });
        
        component.set("v.selectedValues", selectedValues);
        component.set("v.selectedFormNames", selectedFormNames);
    },

    closeAllNotesModal: function(component, event) {
        component.set("v.relateEHRNotes", false);
    },

    save: function(component, event, helper) {
        var selectedFormNames = component.get("v.selectedFormNames");
        
        var appEvent = $A.get("e.c:EHRNotesEvent");
        appEvent.setParams({
            "selectedValues": component.get("v.selectedValues"),
            "selectedFormNames": selectedFormNames
        });
        appEvent.fire();
        component.set("v.relateEHRNotes", false);
    }
})

/* displaying form name
({
    doInit: function(component, event, helper) {
        var listOfAllNotes = component.get("v.allRelateNote");
        var options = [];
        var selectedValues = [];
        var selectedFormNames = [];
        listOfAllNotes.forEach(function(note) {
            var option = {
                value: note.Id,
                label: note.ElixirSuite__Form_Name__c
            };
            options.push(option);
            if (note.isSelected) {
                selectedValues.push(note.Id);
                selectedFormNames.push(note.ElixirSuite__Form_Name__c);
            }
        });
        component.set("v.options", options);
        component.set("v.selectedValues", selectedValues);
        component.set("v.selectedFormNames", selectedFormNames);
    },

    handleFormSelection: function(component, event, helper) {
         var selectedValues = event.getParam("value");
        var selectedFormNames = [];
        
        // Get the selected form names based on the selected values
        var listOfAllNotes = component.get("v.allRelateNote");
        listOfAllNotes.forEach(function(note) {
            if (selectedValues.includes(note.Id)) {
                selectedFormNames.push(note.ElixirSuite__Form_Name__c);
            }
        });
        
        component.set("v.selectedValues", selectedValues);
        component.set("v.selectedFormNames", selectedFormNames);
    },

    closeAllNotesModal: function(component, event) {
        component.set("v.relateEHRNotes", false);
    },

    save: function(component, event, helper) {
        var selectedFormNames = component.get("v.selectedFormNames");
        
        var appEvent = $A.get("e.c:EHRNotesEvent");
        appEvent.setParams({
            "selectedValues": component.get("v.selectedValues"),
            "selectedFormNames": selectedFormNames
        });
        appEvent.fire();
        component.set("v.relateEHRNotes", false);
    }
})

*/