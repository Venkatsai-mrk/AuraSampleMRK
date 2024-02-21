({
    doInit : function(component, event, helper) {
        helper.createObjectData(component, event,'');
        var action = component.get("c.fetchICDVersion");
        //component.set("v.loaded",false);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                //component.set("v.loaded",true);
                let res = response.getReturnValue().mapPickListValues;  
                let defaultValuePicklist = response.getReturnValue().defValue;  
                let arr = [];
                for(let obj in res){
                    let sObj = {'label' : obj, 'value' : res[obj]};
                    arr.push(sObj);
                }
                console.log('list val of ICD version'+JSON.stringify(arr));
                component.set("v.ICDPickList",arr);
                if(!$A.util.isUndefinedOrNull(defaultValuePicklist)){
                    let diagnosisList =  component.get("v.diagnosisList");
                    let recordDiagnosis = diagnosisList[0];
                    recordDiagnosis.ICDVersion = defaultValuePicklist;
                    component.set("v.ICDVersion",defaultValuePicklist);
                }
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    // function for create new object Row in Allergy List 
    addNewRow: function(component, event, helper) {
//component.set("v.selectedRecord",""); //clear selected record if having any
        // call the common "createObjectData" helper method for add new Object Row to List  
        helper.createObjectDataOnNewRow(component, event,component.get("v.ICDVersion"));
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        // get the all List (problemList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.diagnosisList");
        AllRowsList.splice(index, 1);
        // set the problemList after remove selected row element  
        component.set("v.diagnosisList", AllRowsList);
    },
    Cancel : function(component, event, helper) {
        component.set("v.showAddOnlyDiagnosis",false);
        component.set("v.diagnosisList",[]);
        component.set("v.selectedRecord","");
    },
    diagnosisComponentEvent : function(component, event, helper) {
        try{
            var recsObj = JSON.parse(JSON.parse(JSON.stringify(event.getParam("recordAsObject"))));
            var mapOfIdAndSObj = {};
            for(var sObj in recsObj){
                mapOfIdAndSObj  = recsObj[sObj];
            }
            console.log('delect name '+event.getParam("index"));
            console.log('diagnosisComponentEvent '+JSON.stringify(recsObj));
            console.log('diagnosisPoppup '+JSON.stringify(mapOfIdAndSObj));
            console.log('mapOfIdAndSObj.length '+ recsObj.length);
            if (!$A.util.isEmpty(mapOfIdAndSObj) && recsObj.length==1){ 
                console.log('if ');
                let diagnosisList =  component.get("v.diagnosisList");
                let recordDiagnosis = diagnosisList[event.getParam("index")];
                recordDiagnosis.ICDCode = mapOfIdAndSObj.diagnosisCodeName;
                recordDiagnosis.ICDVersion = mapOfIdAndSObj.icdVersion;
                recordDiagnosis.ICDDescription = mapOfIdAndSObj.description;
                recordDiagnosis.ICDId = mapOfIdAndSObj.diagnosisId;  
                component.set("v.diagnosisList",diagnosisList);
            }
            else{
                console.log('else ');
                let diagnosisList =  component.get("v.diagnosisList");
                let recordDiagnosis = diagnosisList[event.getParam("index")];
                recordDiagnosis.ICDCode = mapOfIdAndSObj.diagnosisCodeName;
                recordDiagnosis.ICDDescription = mapOfIdAndSObj.description;
                recordDiagnosis.ICDVersion = mapOfIdAndSObj.icdVersion;
                component.set("v.diagnosisList",diagnosisList);
            }
        }
        catch(e){
            alert('error 22 '+e.stack);
        }
    },
    handleModalSave: function(component, event, helper){       
        console.log('this is the data', event.getParam('selectedRecords'));
        var recsObj = event.getParam('selectedRecords');
        if(!$A.util.isEmpty(recsObj)){
            let diagnosisList =  component.get("v.diagnosisList");
            console.log('inside',diagnosisList.length,'++', JSON.stringify(diagnosisList));
            if(diagnosisList.length == 1 && diagnosisList[0].ICDId == '' && diagnosisList[0].ICDCode == ''){               
                diagnosisList = [];
                /*let recordDiagnosis = diagnosisList[0];
                recordDiagnosis.ICDId = recsObj[0].value;
                recordDiagnosis.ICDCode = recsObj[0].label;
                recordDiagnosis.ICDDescription = recsObj[0].description;
                recordDiagnosis.ICDVersion = recsObj[0].version;
                recordDiagnosis.DiagnosisType = recsObj[0].diagnosisType;
                recordDiagnosis.Notes = recsObj[0].notes;
                recordDiagnosis.DateDiagnoses = recsObj[0].dateOnDiagnoses;
                recordDiagnosis.SelectedRecord = recsObj[0];*/
                recsObj.forEach(function (rec) {
                    let recordDiagnosis = {
                        ICDId: rec.value,
                        ICDCode: rec.label,
                        ICDDescription: rec.description,
                        ICDVersion: rec.version,
                        DiagnosisType: rec.diagnosisType,
                        Notes: rec.notes,
                        DateDiagnoses: rec.dateOnDiagnoses,
                        SelectedRecord: rec,
                        IsPatientDiagnosis: true
                    }; 
                                   
                    diagnosisList.push(recordDiagnosis);
                });
                component.set("v.diagnosisList",diagnosisList);
                console.log('v.diagnosisList', component.get("v.diagnosisList"));
                let showAddOnlyDiagnosis = component.get("v.showAddOnlyDiagnosis");
                if(showAddOnlyDiagnosis == false){
                    showAddOnlyDiagnosis = true;
                    component.set("v.showAddOnlyDiagnosis",showAddOnlyDiagnosis);
                }
            }
            else{
                console.log('inside else');
                /*let recordDiagnosis = {};
                recordDiagnosis.ICDId = recsObj[0].value;
                recordDiagnosis.ICDCode = recsObj[0].label;
                recordDiagnosis.ICDDescription = recsObj[0].description;
                recordDiagnosis.ICDVersion = recsObj[0].version;
                recordDiagnosis.DiagnosisType = recsObj[0].diagnosisType;
                recordDiagnosis.Notes = recsObj[0].notes;
                recordDiagnosis.DateDiagnoses = recsObj[0].dateOnDiagnoses;
                recordDiagnosis.SelectedRecord = recsObj[0];
                diagnosisList.push(recordDiagnosis);*/
                recsObj.forEach(function (rec) {
                    let recordDiagnosis = {
                        ICDId: rec.value,
                        ICDCode: rec.label,
                        ICDDescription: rec.description,
                        ICDVersion: rec.version,
                        DiagnosisType: rec.diagnosisType,
                        Notes: rec.notes,
                        DateDiagnoses: rec.dateOnDiagnoses,
                        SelectedRecord: rec,
                        IsPatientDiagnosis: true
                    }; 
                                   
                    diagnosisList.push(recordDiagnosis);
                });
                component.set("v.diagnosisList",diagnosisList); 
                console.log('v.diagnosisList', component.get("v.diagnosisList"));
            }
            component.set("v.showAddExistingDiagnosis", false);
        }
        else{
            console.log('inside else');
            component.set("v.showAddExistingDiagnosis", false);
        }
    },
    addOnlyDiagnosis: function(component, event, helper) {
        try {
            let payloadToSave = {'keysToSave' : component.get("v.diagnosisList"),
                                 'formUniqueId': component.get("v.formUniqueId")};      
            console.log('data to save ' + JSON.stringify(payloadToSave));
            
            var action = component.get("c.saveOnlyDiagnosisRec");
            action.setParams({
                'payload' : JSON.stringify(payloadToSave),
                'accountId' : component.get("v.patientID")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var newDiagnosis = response.getReturnValue();
                    if(!$A.util.isUndefinedOrNull(component.get("v.notesSpecificData"))){
                        let notesSpecificDataObj = component.get("v.notesSpecificData");
                        notesSpecificDataObj.diagnosisData = notesSpecificDataObj.diagnosisData.concat(newDiagnosis);
                        component.set("v.notesSpecificData", notesSpecificDataObj);
                    }
                    // Get the current list of diagnosis from the parent
                    let parentDiagnosisList = component.get("v.diagnosisList");
                    
                    // Add the new diagnosis to the list
                    //parentDiagnosisList.push(newDiagnosis);
                    
                    component.set("v.diagnosisList", parentDiagnosisList);
                    
                    // Fire the event with the updated problemList
                    var cmpEvent = component.getEvent("AddOnlyDiagnosisEvent");
                    cmpEvent.setParams({ "diagnosisList" : parentDiagnosisList });
                    cmpEvent.fire();
                    
                    /*
                 * write logic to pull newly added diagnosis to show on list view
                // Update the parent's diagnosisList attribute with the new list
                component.set("v.diagnosisList", parentDiagnosisList);
                // Fire the event with the updated problemList
                var cmpEvent = component.getEvent("AddOnlyProblemEvent");
                cmpEvent.setParams({ "problemList" : parentProblemList });
                cmpEvent.fire();
                */
                
                // Hide the component or do other necessary actions
                component.set("v.showAddOnlyDiagnosis", false);
                
                // Display a success toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "DIAGNOSIS SAVED!",
                    "message": " ",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set("v.diagnosisList", []);
                console.log("Child Component: " + JSON.stringify(parentDiagnosisList));
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
    handleICDVersionChange:  function(component, event, helper) {
        var selectedOption = event.getSource();
        var index = selectedOption.get("v.name");
        var AllRowsList = component.get("v.diagnosisList");
        let rec = AllRowsList[index];      
        rec.ICDId= '',
        rec.ICDCode='',
        rec.ICDDescription='',
        rec.ICDVersion= event.getSource().get("v.value"),
        rec.DiagnosisType= '',
        rec.DateDiagnoses=new Date(),
        rec.Notes='',
        rec.ElixirSuite__Account__c= component.get("v.patientID"),
        rec.SelectedRecord= ''
        AllRowsList[index] = rec;
        component.set("v.diagnosisList", AllRowsList);    
    }
})