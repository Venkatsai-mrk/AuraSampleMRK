({
    doInit : function(component, event, helper) {
        console.log('Child component initialized');
        helper.createObjectData(component, event);
        helper.getUser(component, event, helper);
        helper.fetchPicklistValues(component, event);
    },
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    removeDeletedRow: function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;  
        var AllRowsList = component.get("v.medicationList");
        AllRowsList.splice(index, 1);
        component.set("v.medicationList", AllRowsList);
    },
    cancelMedication : function(component, event, helper) {
        component.set("v.addMedicationList",false);
    },
    addMedication: function(component, event, helper) {
        try{
            console.log('clicked')
            var medicationsToSave = component.get("v.medicationList");
            console.log('medicationsToSave: '+JSON.stringify(medicationsToSave));
            var accountId = component.get("v.patientID");
            
            var action = component.get("c.saveMedications");
            action.setParams({
                "medicationsToSave": medicationsToSave,
                "accountId": accountId,
                "formUniqueId": component.get("v.formUniqueId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var newMedication = response.getReturnValue(); //now we are getting medication Ids
                    if(!$A.util.isUndefinedOrNull(component.get("v.notesSpecificData"))){
                        let notesSpecificDataObj = component.get("v.notesSpecificData");
                        notesSpecificDataObj.medicationData = notesSpecificDataObj.medicationData.concat(newMedication);
                        component.set("v.notesSpecificData", notesSpecificDataObj);
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Medication saved",
                        "type" : "success"
                    });
                    toastEvent.fire();
                    
                    var cmpEvent = component.getEvent("AddMedicationEventOnNotes");
                    cmpEvent.setParams({ "medicationList" : medicationsToSave });
                    cmpEvent.fire();
                    console.log('Added medication event to the create form')
                    component.set("v.addMedicationList",false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            });
            
            $A.enqueueAction(action);
        }
        catch(e){
            console.log('Error in Add Medication: '+e);
        }
    }
    
})