({
    
    // function call on component Load
    doInit: function(component, event, helper) {
      //  component.set("v.patientID",'0016F00003j9OCoQAM');
        console.log('inside allergy data'+JSON.stringify(component.get("v.patientID")));
        // create a Default RowItem [Allergy Instance] on first time Component Load
        // by call this helper function  
        helper.createObjectData(component, event);
        //  helper.dataFetchDecision(component, event, helper);
        
    },
    
    // function for save the Records 
  /*  save: function(component, event, helper) {
        try{
             if(component.get("v.windowNotCancelled")){
           if (helper.emptyCheck(component, event)) {
                var formID; var patientID;
                var params = event.getParam('arguments');
                if (params) {
                    formID = params.formID;
                    patientID = params.patientID;
                }
                console.log('form '+formID + 'acct '+patientID);
               var savedAllergy = component.get("v.allergyListCopyToSave");
               const finalAllergyData = savedAllergy.map(obj => ({
                   'ElixirSuite__Medical_Examination__c': obj.sobjectType,
                   'ElixirSuite__Allergy_Name1__c':obj.AllergyName,
                   'ElixirSuite__Substance1__c': obj.Substance,
                   'ElixirSuite__Substance_Code__c': obj.SubstanceCode,
                   'ElixirSuite__Reaction1__c': obj.Reaction,
                   'ElixirSuite__Severity1__c':obj.Severity,
                   'ElixirSuite__Account__c': obj.ElixirSuite__Account__c
               }));
               
               console.log('finalAllergyData: '+JSON.stringify(finalAllergyData));
               
                var action = component.get("c.saveAllergies");
                action.setParams({
                    formID : formID,
                    accountId: patientID,
                    allergieTosave : finalAllergyData
                });
              	console.log('allergyListCopyToSave in addAllergy: '+JSON.stringify(component.get("v.allergyListCopyToSave")))
                // component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setCallback(this, function(response) {
                    alert('inside callback')
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Allergies have been saved successfully.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                         //$A.get('e.force:refreshView').fire();
                    }
                     
                    
                    appEvent.fire();
                    
                });
                
                $A.enqueueAction(action);
            } 
        }
        }
        catch(e){
            alert('save error in add allergy cmp: '+e)
        }
    },*/
    addAllergyToMainCompoennt :  function(component, event, helper) {
        try{
            if (helper.validateRequired(component, event)) {
                var wrapperExternalObjet = component.get("v.ExternalcmpData");
                var allergyAccountSpecific = wrapperExternalObjet.allergyData;
                var newlyAddedAllergy = JSON.parse(JSON.stringify(component.get("v.allergyList")));
                component.set("v.allergyListCopyToSave", JSON.parse(JSON.stringify(component.get("v.allergyList"))));

               // const fAllergy = allergyAccountSpecific.concat(newlyAddedAllergy);
               // wrapperExternalObjet.allergyData = fAllergy;
               // component.set("v.ExternalcmpData", wrapperExternalObjet);
                console.log('allergyListCopyToSave: '+JSON.stringify(component.get("v.allergyListCopyToSave")))
                
                const finalAllergyData = component.get("v.allergyListCopyToSave").map(obj => ({
                    'sobjectType': 'ElixirSuite__Medical_Examination__c',
                    'ElixirSuite__Allergy_Name1__c': obj.AllergyName,
                    'ElixirSuite__Substance1__c': obj.Substance,
                    'ElixirSuite__Substance_Code__c': obj.SubstanceCode,
                    'ElixirSuite__Reaction1__c': obj.Reaction,
                    'ElixirSuite__Severity1__c': obj.Severity,
                    'ElixirSuite__Note__c' : obj.Notes,
                    'ElixirSuite__Account__c': obj.ElixirSuite__Account__c
                }));

                console.log('allergyListCopyToSave : '+JSON.stringify(finalAllergyData))
                component.set("v.allergyListCopyToSave", JSON.stringify(finalAllergyData));
                var action = component.get("c.saveAllergies");
                action.setParams({
                    accountId: component.get("v.patientID"),
                    allergieTosave: finalAllergyData,
                    formUniqueId: component.get("v.formUniqueId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var newAllergy = response.getReturnValue(); //now we are getting allergy Ids
                        if(!$A.util.isUndefinedOrNull(component.get("v.notesSpecificData"))){
                            let notesSpecificDataObj = component.get("v.notesSpecificData");
                            notesSpecificDataObj.allergyData = notesSpecificDataObj.allergyData.concat(newAllergy);
                            component.set("v.notesSpecificData", notesSpecificDataObj);
                        }  
                        console.log('Before Event ');
                     var cmpEvent = $A.get("e.c:AddAllergyToCreateForm");
                     cmpEvent.setParams({ "allergyList" : finalAllergyData });
                     cmpEvent.fire();
                        console.log('After Event fired');
                        component.set("v.showNewAllergy",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Allergy saved",
                            "type": "success"
                        });
                        toastEvent.fire();
                      
                    }
                    else if (state === "ERROR") {
                    var errors = response.getError();
                        console.error('Error while adding allergy: '+errors);
                }
                    
                });

                $A.enqueueAction(action);

            /*    var cmpEvent = component.getEvent("hideAllergysection");
                cmpEvent.setParams({
                    "path": "allergy"
                });
                cmpEvent.fire();*/
                
                var RowItemList = [];
                RowItemList.push({
                    'sobjectType': 'ElixirSuite__Medical_Examination__c',
                    'AllergyName': '',
                    'Substance': '',
                    'SubstanceCode': '',
                    'Reaction': '',
                    'Severity': '',
                    'Notes' : '',
                    'ElixirSuite__Account__c': component.get("v.patientID")
                });

                component.set("v.allergyList", RowItemList);
            
        }}
        catch(e){
            alert('Error addAllergyToMainCompoennt'+e)
        }
    },
    // function for create new object Row in Allergy List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        // get the all List (allergyList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.allergyList");
        AllRowsList.splice(index, 1);
        // set the allergyList after remove selected row element  
        component.set("v.allergyList", AllRowsList);
    },
    Cancel : function(component, event, helper) {
        /*  var wrapperParentAuraIf = component.get("v.ExternalcmpParentAuraIf");
        wrapperParentAuraIf.allergyData = false;
        component.set("v.ExternalcmpParentAuraIf",wrapperParentAuraIf);*/
        component.set("v.showNewAllergy",false);  
        component.set("v.windowNotCancelled",false);
        /*var cmpEvent = component.getEvent("hideAllergysection");
        cmpEvent.setParams({
            "path" : "allergy" });
        cmpEvent.fire();*/
    },
    
})