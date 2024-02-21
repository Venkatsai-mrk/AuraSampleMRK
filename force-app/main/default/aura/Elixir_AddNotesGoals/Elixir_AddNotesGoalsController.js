({
    doInit : function(component) {
        
        var listOfNotes = component.get("v.listOfNotes");
        console.log('KK ',JSON.stringify(listOfNotes));
        console.log('goal '+JSON.stringify(component.get("v.goal")));
        console.log('case id in add notes',component.get("v.carePlan"));
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
                noteId : noteId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
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
        else{
            var patientId = component.get("v.patientId");
            console.log('patientId '+patientId);
            var goalId = component.get('v.goal').Id;
            console.log('goal '+component.get('v.goal').Id);
            //var caseId = component.get("v.carePlan");
            var action = component.get("c.saveNotes");    
            component.set("v.openModalAddNotes" , false);
            console.log(text+patientId+' g '+goalId);
            action.setParams({ 
                text : text,
                patientId : patientId,
                recordId : goalId,
                recordName : component.get('v.goal').ElixirSuite__Plan_Hierarchy_Name__c
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    console.log('Success and response is',response.getReturnValue());
                    let arr = component.get("v.contentDocumentId");
                    arr.push(response.getReturnValue());
                    component.set('v.contentDocumentId',arr);
                    component.set("v.textWritten",'');
                    //function after save
                    var action1 = component.get("c.fetchNotes");
                    action1.setParams({ 
                        recordId : goalId
                    });
                    action1.setCallback(this, function(response1) {
                        var state1 = response1.getState();
                        if (state1 === "SUCCESS") { 
                            console.log('Success2');
                            var listofNotesGoals = response1.getReturnValue();
                            console.log('listofNotesGoals '+listofNotesGoals);
                            if(!$A.util.isUndefinedOrNull(listofNotesGoals)){
                                //var listOfNotes = component.get("v.listOfNotes");
                                component.set("v.listOfNotes",listofNotesGoals);
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