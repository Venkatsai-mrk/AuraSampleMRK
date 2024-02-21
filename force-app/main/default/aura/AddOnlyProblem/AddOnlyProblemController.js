({
    doInit : function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    // function for create new object Row in Allergy List 
    addNewRow: function(component, event, helper) {
        // call the common "createObjectData" helper method for add new Object Row to List  
        helper.createObjectDataOnNewRow(component, event);
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        // get the all List (problemList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.problemList");
        AllRowsList.splice(index, 1);
        // set the problemList after remove selected row element  
        component.set("v.problemList", AllRowsList);
    },
    Cancel : function(component, event, helper) {
        component.set("v.showAddOnlyProblem",false);
        component.set("v.problemList",[]);
    },
    ProblemEvent : function(component, event, helper) {
        try{
            var recsObj = JSON.parse(JSON.stringify(event.getParam("recordAsObject"))); 
            console.log('parentComponentEvent '+JSON.stringify(recsObj));
            console.log('SelectedId '+event.getParam("SelectedId"));
            let problemList =  component.get("v.problemList");
            let recordProblem = problemList[event.getParam("SelectedId")];
            console.log('recordProblem '+JSON.stringify(recordProblem));
            recordProblem.ProblemId = recsObj.Id;
            recordProblem.ProblemName = recsObj.templateProbName;
            recordProblem.ProblemDescription = recsObj.problemDescription;
            recordProblem.SNOMEDCTCode = recsObj.snowmed;
            component.set("v.problemList",problemList); 
            console.log('problemList '+JSON.stringify(problemList));
        }
        catch(e){
            alert('error'+e.stack);
        }
    },
    handleModalSave: function(component, event, helper){       
        console.log('this is the data', event.getParam('selectedRecords'));
        var recsObj = event.getParam('selectedRecords');
        if(!$A.util.isEmpty(recsObj)){
            let problemList =  component.get("v.problemList");
            console.log('inside',problemList.length,'++', JSON.stringify(problemList));
            if(problemList.length == 1 && problemList[0].ProblemId == '' && problemList[0].ProblemName == ''){               
                // Clear existing blank record
                problemList = [];
                /*let recordProblem = problemList[0];
                recordProblem.ProblemId = recsObj[0].tempProbId;
                recordProblem.ProblemName = recsObj[0].label;
                recordProblem.ProblemDescription = recsObj[0].description;
                recordProblem.SNOMEDCTCode = recsObj[0].snowmed;
                recordProblem.ProblemType = recsObj[0].problemType;
                recordProblem.Status = recsObj[0].status;
                recordProblem.Notes = recsObj[0].notes;
                recordProblem.DateOnset = recsObj[0].dateOnset;*/
                recsObj.forEach(function (rec) {
                    let recordProblem = {
                        ProblemId: rec.tempProbId,
                        ProblemName: rec.label,
                        ProblemDescription: rec.description,
                        SNOMEDCTCode: rec.snowmed,
                        ProblemType: rec.problemType,
                        Status: rec.status,
                        Notes: rec.notes,
                        DateOnset: rec.dateOnset,
                        EndDate: rec.endDate,
                        IsPatientProblem: true,
                        ExistingProblemId: rec.value
                    }; 
                                   
                    problemList.push(recordProblem);
                });
                component.set("v.problemList",problemList);
                console.log('v.problemList', component.get("v.problemList"));
                let showAddOnlyProblem = component.get("v.showAddOnlyProblem");
                if(showAddOnlyProblem == false){
                    showAddOnlyProblem = true;
                    component.set("v.showAddOnlyProblem",showAddOnlyProblem);
                }
            }
            else{
                console.log('inside else');
                /*let recordProblem = {};
                recordProblem.ProblemId = recsObj[0].tempProbId;
                recordProblem.ProblemName = recsObj[0].label;
                recordProblem.ProblemDescription = recsObj[0].description;
                recordProblem.SNOMEDCTCode = recsObj[0].snowmed;
                recordProblem.ProblemType = recsObj[0].problemType;
                recordProblem.Status = recsObj[0].status;
                recordProblem.Notes = recsObj[0].notes;
                recordProblem.DateOnset = recsObj[0].dateOnset;
problemList.push(recordProblem);*/
                recsObj.forEach(function (rec) {
                    let recordProblem = {
                        ProblemId: rec.tempProbId,
                        ProblemName: rec.label,
                        ProblemDescription: rec.description,
                        SNOMEDCTCode: rec.snowmed,
                        ProblemType: rec.problemType,
                        Status: rec.status,
                        Notes: rec.notes,
                        DateOnset: rec.dateOnset,
                        EndDate: rec.endDate,
                        IsPatientProblem: true,
                        ExistingProblemId: rec.value
                    };
        
                    // Add the current recordProblem to problemList
                problemList.push(recordProblem);
});
                
                component.set("v.problemList",problemList); 
                console.log('v.problemList', component.get("v.problemList"));
            }
            //component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showAddExistingProblem", false);
        }
        else{
            console.log('inside else');
            //component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showAddExistingProblem", false);
        }
    },
    addOnlyProblem: function(component, event, helper) {
    try {
        let payloadToSave = {'keysToSave' : component.get("v.problemList"),
                             'formUniqueId': component.get("v.formUniqueId")};      
        console.log('data to save ' + JSON.stringify(payloadToSave));
        
        var action = component.get("c.saveOnlyProblemRec");
        action.setParams({
            'payload' : JSON.stringify(payloadToSave),
            'accountId' : component.get("v.patientID")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var newProblem = response.getReturnValue(); //now we are getting problem Ids
                if(!$A.util.isUndefinedOrNull(component.get("v.notesSpecificData"))){
                    let notesSpecificDataObj = component.get("v.notesSpecificData");
                    notesSpecificDataObj.problemData = notesSpecificDataObj.problemData.concat(newProblem);
                    component.set("v.notesSpecificData", notesSpecificDataObj);
                }
                // Get the current list of problems from the parent
                let parentProblemList = component.get("v.problemList");

                // Add the new problem to the list
                //parentProblemList.push(newProblem);

                // Update the parent's problemList attribute with the new list
                component.set("v.problemList", parentProblemList);

                // Fire the event with the updated problemList
                var cmpEvent = component.getEvent("AddOnlyProblemEvent");
                cmpEvent.setParams({ "problemList" : parentProblemList });
                cmpEvent.fire();

                // Hide the component or do other necessary actions
                component.set("v.showAddOnlyProblem", false);

                // Display a success toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "PROBLEM SAVED!",
                    "message": " ",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set("v.problemList", []);

                console.log("Child Component: " + JSON.stringify(parentProblemList));
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });

        $A.enqueueAction(action); 
    } catch (e) {
        console.log(e);
    }
},
})