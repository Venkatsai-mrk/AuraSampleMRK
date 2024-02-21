({
    doInit : function(component, event, helper) {
        //get all problem templates.
        
        console.log('t/f value  '+JSON.stringify(component.get("v.isOpen")));
        console.log('existing prb   '+JSON.stringify(component.get("v.existingProblems")));
        var nspc = 'ElixirSuite__';
        var arr= [];
        var arrOnlyNewlyCreatedProblems = [];
        var arrOnlyTemplateProblems = [];
        var  parent = component.get("v.existingProblems");
        var existingProblemsList = parent.data; 
        console.log('existing problem reocrds   '+JSON.stringify(existingProblemsList));
        for (var existingId in existingProblemsList) {
            if(!$A.util.isUndefinedOrNull(existingProblemsList[existingId]['ElixirSuite__Dataset1__c'])) {
                arr.push(existingProblemsList[existingId]['ElixirSuite__Dataset1__c']);
                arrOnlyTemplateProblems.push(existingProblemsList[existingId]); // getting IDs of already existing problem.
            }
            else {
                arrOnlyNewlyCreatedProblems.push(existingProblemsList[existingId]);
            }
            
        }
        
        component.set("v.templateProblems",arrOnlyTemplateProblems);
        component.set("v.NewProblemRecordsList",arrOnlyNewlyCreatedProblems);
        console.log('new problem reocrds   '+JSON.stringify(component.get("v.NewProblemRecordsList")));
        var templateProblems = component.get("v.templateProblems");
        console.log('existing prb IDs  '+JSON.stringify(arr));
        var action = component.get("c.getAllProblemTemplates");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ existingproblemsList :  arr});        
        action.setCallback(this, function (response){
            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success');
                //add key to all records to keep an eye on which one is selected.
                var res = response.getReturnValue();
                for (var key in res) {
                    res[key].problemIsChecked= false;
                    res[key].isAddedFromTemplate = true; // to keep track if the problem is added from template or user created a new one.
                    res[key][nspc+'Dataset1__c'] = res[key].Id; // Put problem template id as 'Id' key, because existing ones have this name. 
                    res[key].isProblemToInsert = false;// To flag the newly selected problem from existing one.
                    res[key].isProblemEditable=true; // to keep flag on which problems will be editable.
                    res[key].relatedNotes=[{'ElixirSuite__Notes__c': '',
                                            'isEditableNotes' : true}];
                    //res[key].displayRelatedDaignoses= false;
                    templateProblems.push(res[key]);    
                    
                }  
                
                 component.set("v.nameSpace" , res.nameSpace);
                component.set("v.templateProblems",templateProblems);
                component.set("v.allOptions",JSON.parse(JSON.stringify(templateProblems)));
                templateProblems = templateProblems.concat(component.get("v.NewProblemRecordsList"));
                component.set("v.existingProblems.data",templateProblems);
                console.log('existing problem 78 '+JSON.stringify( component.get("v.existingProblems")));               
                console.log('90876 '+JSON.stringify( component.get("v.existingProblems")));
                component.set("v.allOptions",JSON.parse(JSON.stringify(templateProblems)));              
                console.log('options response '+JSON.stringify( component.get("v.templateProblems")));
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);        
        helper.hideSpinner(component);
    },
    handleConfirmDialogCancel : function(component, event, helper) {
        console.log('cancel value'+  component.get("v.isOpen"));
        component.set("v.isOpen",false);
    },
    handleConfirmDialogNext : function(component, event, helper) {
        //get the parent JSON and pass it to form component
        var title = "Review Error Messages on ADD NEW PROBLEM tab!";
        var message = "Please fill mandatory fields." ; 
        var fieldsValid = helper.checkFiledsValidity(component,event,helper);
        var templatePass  = helper.checkTemplateValidation(component, event);
        var nonTemplatePass  =  helper.checkNonTemplateValidation(component, event);
        if(templatePass == false && nonTemplatePass==false){
            fieldsValid = false ; 
            title = "PLEASE SELECT SOMETHING!" ; 
            message = "Nothing selected." ; 
        }
        else if(nonTemplatePass==false){
            
        }
        console.log('confirmationdoalog '+JSON.stringify( component.get("v.options")));
        var newProblems = component.get("v.NewProblemRecordsList");
        console.log('new problem '+JSON.stringify( component.get("v.NewProblemRecordsList")));               
        var templateProblems =  component.get("v.templateProblems");      
        var finalJsonToSave   = templateProblems.concat(newProblems);
        console.log('fj ts  '+JSON.stringify(finalJsonToSave));
        // var helper.isValidationRequiered(component,templateProblems);
        if(fieldsValid || $A.util.isUndefinedOrNull(fieldsValid)){
            var cmpEvent = component.getEvent("problemDiagnosesData");
            // Get the value from Component and set in Event
            cmpEvent.setParams( { "problemDiagnosesDataToSave" : finalJsonToSave} );
            cmpEvent.fire();            
            // component.set("v.isOpen",false);
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "info",
                "title": title,
                "message":  message
                
            });
            toastEvent.fire();
        }     
    },
    handleProblemNameChange :  function(component, event, helper) {
        var nspc = component.get("v.nameSpace");
        var isEmpty  = event.getSource().get("v.value");
        console.log('has vlaue '+isEmpty);
        var parent = component.get("v.NewProblemRecordsList");
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        if(!$A.util.isUndefinedOrNull(parent[index].alreadyExisting) && parent[index].alreadyExisting){
            parent[index]['isproblemRecordUpdatedFormCreateNewTab'] = true; 
            //parent[index][nspc+'Problem_Name__c'] = value;
             parent[index][nspc+'Name'] = value;
            component.set("v.NewProblemRecordsList",parent); 
        }
        else {
            
            if(!isEmpty==''){
                parent[index].isProblemToInsert=true;
                parent[index].problemIsChecked=true;
                parent[index].Name=value;
                
            } 
            else {
                parent[index].isProblemToInsert=false;
                parent[index].problemIsChecked=false;
                parent[index].Name=value;
            }
        }
    },
    handleDescriptionUpdate :  function(component, event, helper) {
        var nspc = component.get("v.nameSpace");
        var parent = component.get("v.NewProblemRecordsList");
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        if(!$A.util.isUndefinedOrNull(parent[index].alreadyExisting) && parent[index].alreadyExisting){
            parent[index]['isproblemRecordUpdatedFormCreateNewTab'] = true; 
            parent[index][nspc+'Description__c'] = value;
            component.set("v.NewProblemRecordsList",parent); 
        }
        
    },
    handleChangeForSelectCheckBox :  function(component, event, helper) {
        component.set("v.showRelatedDiagnoses",true);
        var value= event.getSource().get("v.name");
        console.log('name for checked '+JSON.stringify(value));
        var action = component.get("c.getRelatedDiagnoses");
        
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('inside success');
                
                var res = response.getReturnValue();
                console.log('options response '+JSON.stringify(res));                
                var b = [];                
                for (var i = 0; i < res.length; i++) {                   
                    b.push({
                        'label': res[i]['Name'],
                        'value':  res[i]['Id']
                    });
                    
                    
                }
                component.set("v.options",b);
                // component.set("v.openListOfProblems",true);
                //component.set("v.allOptions",JSON.parse(JSON.stringify(b)));
                
                console.log("options set---"+JSON.stringify(component.get("v.options")));
                console.log("allOptions set---"+JSON.stringify(component.get("v.allOptions")));
                
                
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
    /*   
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        * The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        
            var sectionState = sectionDiv.getAttribute('class').search('slds-is-open');
            
            // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
            if(sectionState == -1){
                sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
            }else{
                sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
            }
        },*/
    
    handleConfirmDialogCancel : function(component, event, helper) {
        component.set("v.isOpen",false);
    },
    handleSectionToggle : function(component, event, helper) {
        var openSections = event.getParam('openSections');
        var anm  =  component.find("accordion").get('v.activeSectionName') ; 
        console.log('event toggle section '+openSections);
        console.log('event toggle anm '+anm);
    },
    handleAddProblemsAndDiagnoses :  function(component, event, helper) {
    },
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    
    Search: function(component, event, helper) {
        var key = event.getSource().get("v.value")
        helper.SearchHelper(component, key);
        
    },
    onAddNewProblemTabActive : function(component, event, helper) {
        // create a Default RowItem [problem Instance] on first time tab switches;
        // by calling this helper function  
        component.set("v.isSearchbarVisible",false);
        var existingData=component.get("v.NewProblemRecordsList"); 
        console.log('data 678 '+JSON.stringify(existingData));
        if(!existingData.length>=1) {
            helper.createObjectData(component, event);            
        }
        
    },
    onAddProblemFromTemplteTabActive : function(component, event, helper) {
        component.set("v.isSearchbarVisible",true);
    },
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var deletedProblems = component.get("v.CustomProblemToDel");
        if($A.util.isUndefinedOrNull(deletedProblems)){
            deletedProblems = [];
        }
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        // get the all List (problem attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.NewProblemRecordsList");
        var copy = JSON.parse(JSON.stringify(AllRowsList));
        deletedProblems.push(copy[index].Id);
        AllRowsList.splice(index, 1);
        // set the problem after remove selected row element  
        component.set("v.NewProblemRecordsList", AllRowsList);
        AllRowsList = AllRowsList.concat(component.get("v.templateProblems"));
        component.set("v.existingProblems.data",AllRowsList);
        component.set("v.CustomProblemToDel", deletedProblems);       
        console.log('del added    '+JSON.stringify(component.get("v.CustomProblemToDel")));
    },
    handleAddDaignoses :  function(component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var lstOfProblems =  component.get("v.NewProblemRecordsList");
        
        var lstOfDaignoses = lstOfProblems[currentIndex].relatedDiagnoses;
        var arr = [];
        for (var existingId in lstOfDaignoses) {
            if(!$A.util.isUndefinedOrNull(lstOfDaignoses[existingId].Id)) {
                arr.push(lstOfDaignoses[existingId].Id);
            }
        }
        var action = component.get("c.getAllDaignosesTemplates");   
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ existingDiagnosesList :  arr}); 
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('inside success');                             
                var res = response.getReturnValue();
                var b = [];
                var mapOfDiagnoses = {};
                for (var i = 0; i < res.length; i++) { 
                    // childRecords.push();
                    b.push({
                        'label': res[i]['ElixirSuite__Diagnosis_Code_and_Name__c'],
                        'value': res[i]['Id']                                               
                    });   
                    mapOfDiagnoses[res[i].Id] = res[i]; 
                }
                component.set("v.optionsForDaignoses",b); 
                component.set("v.mapOfDiagnoses",mapOfDiagnoses); 
                console.log('map of diagnoses '+JSON.stringify(component.get("v.mapOfDiagnoses")));
                component.set("v.allDataDaignoses",JSON.parse(JSON.stringify(b)));
                console.log('options set JSON'+JSON.stringify(component.get("v.optionsForDaignoses")));
                component.set("v.iterationIndex",event.getSource().get("v.name"));
                component.set("v.openAddDaignoses",true);
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);
        
        
        
    },
    onDiagnosesBlur : function(component, event, helper) {
        console.log('blur daignoses selected values '+JSON.stringify(component.get("v.optionsForDaignoses")));
    },
    handleChangeMultiSelectDiagnoses :  function(component, event, helper) {  
        component.set("v.selectedValues",event.getParam("value"));        
    },
    handleConfirmDialogAdd :  function(component, event, helper) {
        var selectedValues  =  component.get("v.selectedValues");
        if($A.util.isUndefinedOrNull(selectedValues) || $A.util.isEmpty(selectedValues)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "title" : "Please select something!",
                "message": "Nothing selected!",
                
            });
            toastEvent.fire(); 
        }
        else {
            var newProblemRecordlist =   component.get("v.NewProblemRecordsList");
            var mapOfDiagnoses =  component.get("v.mapOfDiagnoses");     
            var index  = component.get("v.iterationIndex");
            if($A.util.isUndefinedOrNull(newProblemRecordlist[index].relatedDiagnoses)){
                newProblemRecordlist[index].relatedDiagnoses = [];
            }
            var cuurentRecordDiagnosesArray = 	newProblemRecordlist[index].relatedDiagnoses;                  
            if(!$A.util.isUndefinedOrNull(newProblemRecordlist[index].alreadyExisting) && newProblemRecordlist[index].alreadyExisting){
                newProblemRecordlist[index]['isrelatedDiagnosesUpdated'] = true;                 
                for(var rec in selectedValues){ 
                    if(!$A.util.isUndefinedOrNull(mapOfDiagnoses[selectedValues[rec]]) && mapOfDiagnoses[selectedValues[rec]].alreadyExistingDaignoses) {
                        
                    }
                    else {
                        mapOfDiagnoses[selectedValues[rec]]['isAdded'] =true;
                        mapOfDiagnoses[selectedValues[rec]]['Dataset1__c'] = newProblemRecordlist[index].Id;
                        var insideRecord = mapOfDiagnoses[selectedValues[rec]];
                        insideRecord['diagnosesIsChecked'] =true;  
                        cuurentRecordDiagnosesArray.push(insideRecord);
                        newProblemRecordlist[index].relatedDiagnoses = cuurentRecordDiagnosesArray ;
                    }
                }
                component.set("v.NewProblemRecordsList",newProblemRecordlist);
                component.set("v.openAddDaignoses",false);
            }
            
            else {
                for(var rec in selectedValues){  
                    var insideRecord = mapOfDiagnoses[selectedValues[rec]];
                    insideRecord['diagnosesIsChecked'] =true;                               
                    cuurentRecordDiagnosesArray.push(insideRecord);
                }
                newProblemRecordlist[index].relatedDiagnoses = cuurentRecordDiagnosesArray ;
                component.set("v.NewProblemRecordsList",newProblemRecordlist);
                console.log('after set  '+JSON.stringify(component.get("v.NewProblemRecordsList")));
                component.set("v.openAddDaignoses",false);
            }
            
            
        }
         component.set("v.selectedValues",[]);
    },
    handleConfirmDialogCancelForAddDiagnosesPopup : function(component, event, helper) {
        component.set("v.openAddDaignoses",false); 
    },
    handleNotes: function(component, event, helper) {
        var nspc = component.get("v.nameSpace");
        var index  = event.getSource().get("v.name");
        var getArray  = component.get("v.NewProblemRecordsList");
        var notesValue  = event.getSource().get("v.value");
        var problemRecord = getArray[index];
        if(!$A.util.isUndefinedOrNull(problemRecord.alreadyExisting) && problemRecord.alreadyExisting){
            //  if(!$A.util.isEmpty(problemRecord.relatedNotes)){
            if(!$A.util.isUndefinedOrNull(problemRecord.relatedNotes[0].alreadyExistingNotes) && problemRecord.relatedNotes[0].alreadyExistingNotes) {              
                problemRecord['isrelatedNotesUpdated'] = true;
                problemRecord['isNotesEdited'] = true;
                var n = {'Notes__c' : notesValue,
                         'Id' : problemRecord.relatedNotes[0].Id,
                         'Dataset1__c' : problemRecord.Id};
                problemRecord.relatedNotes=[];
                problemRecord.relatedNotes.push(n);                
                component.set("v.NewProblemRecordsList",getArray);
            }
            //   }
            else {
                problemRecord['toInsertNewNote'] = true;
                var n = {'Notes__c' : notesValue,
                         'Dataset1__c' : problemRecord.Id};
                problemRecord.relatedNotes=[];
                problemRecord.relatedNotes.push(n);                
                component.set("v.problemRecord",problemRecord);
            }
        }
        else { 
            
            var masterList = problemRecord.relatedNotes;
            masterList[0].Notes__c=event.getSource().get("v.value");
            
            
        }
        
        
    },
    
    
})