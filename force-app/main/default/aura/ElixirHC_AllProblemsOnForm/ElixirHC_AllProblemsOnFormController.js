({
    doInit: function(component, event, helper) {
        //set this to true when the very first time checkbox is clicked.
        //So that if checkbox is unchecked and checked again then js dosen't have to make a call again to APEX
        
        component.set("v.problemFirstCallBack", true);
        console.log('gthy ' + JSON.stringify(component.get(" v.problemFirstCallBack")));
        
    },
    handleProblemOnChange :  function(component, event, helper) {
        var value = event.getSource().get("v.checked");
        var masterList = component.get("v.problem");
        console.log('master list 6789 ' + JSON.stringify(masterList));
        var toDeleteRecordIDs = component.get("v.CustomProblemToDel");
        if(!$A.util.isUndefinedOrNull(masterList.alreadyExisting)) {
            toDeleteRecordIDs.push(masterList.Id);
            component.set("v.CustomProblemToDel",toDeleteRecordIDs);
            masterList.isDelete = !value;  
            // masterList.problemIsChecked = !value;
        }
        else {     
            masterList.problemIsChecked = value;
            masterList.isProblemToInsert = value;
        }
        component.set("v.problem",masterList);
        
    },
    //This section bring related daignoses corossponding to which the checkbox (parent problem) is clicked
    problemSectionHandler: function(component, event, helper) {
        //  var checkValue = event.getSource().get("v.checked");
        // console.log('ye value ' + checkValue);
        var masterList = component.get("v.problem");
        var existingIds = [];
        var nspc='ElixirSuite__';
        console.log('master list 6789 ' + JSON.stringify(masterList));
        if(!$A.util.isUndefinedOrNull(masterList.relatedDiagnoses)) {
            var relatedDiagnoses  = masterList.relatedDiagnoses;
            for (var relatedDaignosesId in relatedDiagnoses ) {
                existingIds.push(relatedDiagnoses[relatedDaignosesId].ElixirSuite__ICD_Codes__c);            
            }
        }
        else {
            masterList.relatedDiagnoses = [];
        }
        
        console.log('existing ID '+JSON.stringify(existingIds));
        console.log('msater list  '+JSON.stringify(masterList));
        //when checkbox is checked
        
        // console.log('inside if of child parent ' + event.getSource().get("v.checked"));
        var problemIdx = component.get("v.problemIndex");
        var problemId = component.get("v.problemId");
        console.log('id x value ' + problemIdx);
        console.log('problem ' + problemId);
        
        
        var problemFirstCallBack = component.get("v.problemFirstCallBack");
        console.log('fierst callback value ' + problemFirstCallBack);
        if (problemFirstCallBack == true) {
            var action = component.get("c.getRelatedDiagnoses");
            var parentProblemId = '';
            if(!$A.util.isUndefinedOrNull( masterList[nspc+'Dataset1__c'])) {
                parentProblemId =  masterList[nspc+'Dataset1__c'];
            }
            else {
                parentProblemId =  masterList['Id']; 
            }
            action.setParams({
                parentProblemId: parentProblemId,
                existingIds : existingIds
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listOfrelatedDiagnoses = response.getReturnValue();
                    //  console.log('returned size '+listOfrelatedDiagnoses.size());
                    var getExistingDiagnosis =    component.get('v.problem').relatedDiagnoses;
                    if (!$A.util.isEmpty(listOfrelatedDiagnoses)) {
                        component.set("v.hasValueInDiagnoses", true);
                    }
                    else if(!$A.util.isEmpty(getExistingDiagnosis)){
                         component.set("v.hasValueInDiagnoses", true);
                    }
                    //Adding a check key 'diagnosesIsChecked' to every record to keep a track on which record to insert
                    for (var key in listOfrelatedDiagnoses) {
                        listOfrelatedDiagnoses[key].diagnosesIsChecked = false;  
                        masterList.relatedDiagnoses.push(listOfrelatedDiagnoses[key]);
                    }
                    
                    // Adding a sub tree corosponding the parent record (problem) which is being checked
                    // masterList['displayRelatedDaignoses'] = false;                       
                    
                    console.log(event.getSource().get("v.name"));
                    
                    component.set('v.problem', masterList);
                    component.set("v.allOptions",JSON.parse(JSON.stringify(masterList)));
                    console.log('after setr parent ' + JSON.stringify(component.get('v.problem')));
                    component.set("v.problemFirstCallBack", false);
                    
                } else {
                    
                    //Getting errors if APEX callback fails
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        //show/hide section when checkbox is checked
        var acc = component.find("problemSection");
        
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
 
    },
    onChevronHandle :  function(component, event, helper) {
        var getrecord = component.get("v.problem");
        var existingdaignosesIDs = []; // array to store existing IDs.
        var nspc = '';
        
        //collect IDs of existing diagnoses
        for(var rec in getrecord.relatedDiagnoses){
            existingdaignosesIDs.push(getrecord.relatedDiagnoses[rec].Id);
            
        }
        console.log('existing ids '+existingdaignosesIDs);
        //Call apex to get the rest of the daignoses
        var action = component.get("c.getFiltereddiagnosesTemplates");
        
        action.setParams({ alreadyExistingDiagnosesTemplates :existingdaignosesIDs,
                          parentProblemId :getrecord[nspc+'Id'] });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res=   response.getReturnValue();
                //Create new keys for the new records and set them in the existing ones.
                for (var item in res) {
                    res[item]['diagnosesIsChecked']=false;
                    getrecord.relatedDiagnoses.push(res[item]);
                    
                }             
                component.set("v.problem",getrecord);
                
            }
            
        });
        $A.enqueueAction(action);
        
        var acc = component.find("problemSection");
        
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
    },
    
    //note record handling
    handleNotes: function(component, event, helper) {
        var nspc = 'ElixirSuite__';
        var notesValue  = event.getSource().get("v.value");
        var problemRecord = component.get("v.problem");
        if(!$A.util.isUndefinedOrNull(problemRecord.alreadyExisting) && problemRecord.alreadyExisting){       
            if(!$A.util.isUndefinedOrNull(problemRecord.relatedNotes[0].alreadyExistingNotes) && problemRecord.relatedNotes[0].alreadyExistingNotes) { 
                problemRecord['isrelatedNotesUpdated'] = true;
                problemRecord['isNotesEdited'] = true;
                var n = {'ElixirSuite__Notes__c' : notesValue,
                         'Id' : problemRecord.relatedNotes[0].Id,
                         'ElixirSuite__Dataset1__c' : problemRecord.Id,
                         'alreadyExistingNotes' : true};
                problemRecord.relatedNotes=[];
                problemRecord.relatedNotes.push(n);                
                component.set("v.problemRecord",problemRecord);
            } 
            else {
                problemRecord['toInsertNewNote'] = true;
                var n = {'ElixirSuite__Notes__c' : notesValue,
                         'ElixirSuite__Dataset1__c' : problemRecord.Id,
                        };
                problemRecord.relatedNotes=[];
                problemRecord.relatedNotes.push(n);                
                component.set("v.problemRecord",problemRecord);
            }
        }
        else {        
            var masterList = component.get("v.problem").relatedNotes;
            masterList[0].ElixirSuite__Notes__c=event.getSource().get("v.value");
            
        }
        
    },
    //prototype method to handle show/hide when clicked on DIV
    hideSection: function(component, event, helper) {
        //console.log('inside 45678');
        var acc = component.find("problemSection");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        
    },
    Search: function(component, event, helper) {
        
        helper.SearchHelper(component,event);
        
    },
})