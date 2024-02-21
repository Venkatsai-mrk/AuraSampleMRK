({
    doInit : function(component, event, helper) {
        
        var listOfNotes = component.get("v.listOfNotes");
        console.log('level 3 notes  ',JSON.stringify(listOfNotes));
       
    }
    ,
    AddNotes : function(component, event, helGoalper) {
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
    }else{
        
    }
    },
    Save  :  function(component, event, helper) {
        var text = component.get("v.textWritten");
        var patientId = component.get("v.patientId");
        var goalId = component.get("v.goal").Id;
        var caseId = component.get("v.carePlan").Id;
        var action = component.get("c.saveNotesGoals");    
        component.set("v.openModalAddNotes" , false);
		console.log(text+patientId+'d'+goalId+'dcd'+caseId);
        action.setParams({ 
            text : text,
            patientId : patientId,
            goalId : goalId,
            caseId  : caseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                 //function after save
                 var action1 = component.get("c.notesOfGoal");
                 action1.setParams({ 
                     goalId : goalId
                 });
                 action1.setCallback(this, function(response1) {
                     var state1 = response1.getState();
                     if (state1 === "SUCCESS") { 
                         var listofNotesProblems = response1.getReturnValue();
                         if(!$A.util.isUndefinedOrNull(listofNotesProblems)){
                             console.log('notess ',listofNotesProblems);
                             var listOfNotes = component.get("v.listOfNotes");
                               console.log('AFTER LEVEL 3 NOTES  ',JSON.stringify(listOfNotes));
                             component.set("v.listOfNotes",listofNotesProblems);
                         }  
                        
 
                     }else{
 
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
    },
    closeMainModal :  function(component, event, helper) {
        component.set("v.openModalAddNotes" , false);
    }
})