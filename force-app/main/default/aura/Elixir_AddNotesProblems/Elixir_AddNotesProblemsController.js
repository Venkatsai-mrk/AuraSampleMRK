({
    doInit : function(component) {
        
        var listOfNotes = component.get("v.listOfNotes");
        console.log('KK ',JSON.stringify(listOfNotes));
    }
    ,
    AddNotes : function(component) {
        component.set("v.textWritten",'');
        component.set("v.openModalAddNotes" , true);
        //var listOfNotes = component.get("v.listOfNotes");
        
    },
    delNote  :  function(component, event, helper) {
        var m = confirm("Are you sure , you want to delete this note?");
        if(m){
            var name = event.getSource().get('v.name').split('$');
            var noteId = name[0];
            var idx = name[1];
            var action = component.get("c.delNotes");   
            action.setParams({ 
                noteId : noteId,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    //call back for refresh notes section
                    helper.notesRefresh(component , event , noteId ,idx);            
                }else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    Save  :  function(component) {
        var text = component.get("v.textWritten");
        if($A.util.isUndefinedOrNull(text) || text == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : 'warning',
                "title": "WRITE SOMETHING!",
                "message": "Please write something!"
            });
            toastEvent.fire();
        }
        else {
            var patientId = component.get("v.patientId");
            var problemId = component.get("v.problem").ElixirSuite__Plan_Hierarchy__r[0].Id;
            //var caseId = component.get("v.carePlan").Id;
            var action = component.get("c.saveNotes");
            component.set("v.openModalAddNotes" , false);
            console.log(patientId+'prob'+problemId);
            action.setParams({ 
                text : text,
                patientId : patientId,
                recordId : problemId,
                recordName : component.get('v.problem').Name
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    console.log('Success and response is for problem notes',response.getReturnValue());
                    let arr = component.get("v.contentDocumentId");
                    arr.push(response.getReturnValue());
                    component.set('v.contentDocumentId',arr);
                    component.set("v.textWritten",'');
                    //function after save
                    var action1 = component.get("c.fetchNotes");
                    action1.setParams({ 
                        recordId : problemId
                    });
                    action1.setCallback(this, function(response1) {
                        var state1 = response1.getState();
                        if (state1 === "SUCCESS") { 
                            var listofNotesProblems = response1.getReturnValue();
                            if(!$A.util.isUndefinedOrNull(listofNotesProblems)){
                                console.log('notess ',listofNotesProblems);
                                //var listOfNotes = component.get("v.listOfNotes");
                                component.set("v.listOfNotes",listofNotesProblems);
                            }  
                            
                            
                        }else{
                            var errors = response1.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " +
                                                errors[0].message);
                                }        }
                        }
                    });
                    $A.enqueueAction(action1);
                }else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeMainModal :  function(component) {
        component.set("v.openModalAddNotes" , false);
    }
})