({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        console.log('inside allergy data'+JSON.stringify(component.get("v.patientID")));
        // create a Default RowItem [Glucose Instance] on first time Component Load
        // by call this helper function  
        
        helper.createObjectData(component, event);
        helper.setAllPicklistValues(component);
        
        
        
    },
    addGlucoseToMainCompoennt :  function(component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "Substance code" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the ListView component to pass the Allergy list
             component.set("v.windowNotCancelled",true);
            var wrapperExternalObjet =   component.get("v.ExternalcmpData");
            var glucoseDataFormSpecific = wrapperExternalObjet.glucoseDataFormSpecific;
            var glucoseData = wrapperExternalObjet.glucoseData;
            var newlyAddedGlucose = JSON.parse(JSON.stringify(component.get("v.glucoseList")));
             component.set("v.glucoseListCopyToSave",JSON.parse(JSON.stringify(component.get("v.glucoseList")))); 
            const finalAllergy = glucoseDataFormSpecific.concat(newlyAddedGlucose);
            const fAllergy = glucoseData.concat(newlyAddedGlucose);
            wrapperExternalObjet.glucoseDataFormSpecific = finalAllergy;
            wrapperExternalObjet.glucoseData = fAllergy;
            component.set("v.ExternalcmpData",wrapperExternalObjet);
            var cmpEvent = component.getEvent("hideAllergysection");
            cmpEvent.setParams({
                "path" : "glucose" });
            cmpEvent.fire();
           var RowItemList = [];
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Medical_Examination__c',
            'ElixirSuite__Glucose_Reading__c': '',
            'ElixirSuite__Intervention__c': '',
            'ElixirSuite__Type_of_check__c': '',
            'ElixirSuite__Note__c' : '',
            'ElixirSuite__Account__c' : component.get("v.patientID")
        });

             component.set("v.glucoseList",RowItemList);
        }
    },
    // function to add the records in the event. 
    Save: function(component, event, helper) {
        if(component.get("v.windowNotCancelled")){
             if (helper.emptyCheck(component, event)) {
                var formID; var patientID;
                var params = event.getParam('arguments');
                if (params) {
                    formID = params.formID;
                    patientID = params.patientID;
                }
 			
                var action = component.get("c.saveAllGlucose");
                action.setParams({
                    formID : formID,
                    accountId: patientID,
                    glucoseList : component.get("v.glucoseListCopyToSave")
                });
                // component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                     
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The record has been updated successfully.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }
                    
                });
                
                $A.enqueueAction(action);
            } 
        }
        
        
    },
    
    handleSelect: function(component, event, helper) {
        console.log('inside ');
        component.set("v.MedicalValue", event.getSource().get("v.value"));
        component.set("v.OrderedTests", true);
        
    },
    
    // function for create new object Row in Glucose List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        // get the all List (glucoseList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.glucoseList");
        AllRowsList.splice(index, 1);
        // set the glucoseList after remove selected row element  
        component.set("v.glucoseList", AllRowsList);
    },
    Cancel : function(component, event, helper) {
        component.set("v.windowNotCancelled",false);
        var cmpEvent = component.getEvent("hideAllergysection");
        cmpEvent.setParams({
            "path" : "glucose" });
        cmpEvent.fire();
    },
})