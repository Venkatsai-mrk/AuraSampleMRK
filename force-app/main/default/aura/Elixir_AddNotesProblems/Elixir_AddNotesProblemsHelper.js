({
    notesRefresh : function(component , event , noteId ,idx) {
       var listOfNotes = component.get("v.listOfNotes");
       listOfNotes.splice(idx , 1); 
       component.set("v.listOfNotes" , listOfNotes);
    }
})
/*var problemId = component.get("v.problem").Id;
if(! $A.util.isUndefinedOrNull(problemId)){              
        var action = component.get("c.getGoals");        
        action.setParams({ 
            problemId : problemId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var listOfGoals = response.getReturnValue().listOfGoal;     
                component.set("v.note",response.getReturnValue().mapOfProblemToNotes);
                component.set('v.carePlanViewGoals',true);
                console.log('listOfGoals '+JSON.stringify(listOfGoals));
                var masterList = component.get("v.problem");
                masterList['listOfGoal'] = listOfGoals;
                component.set('v.goalsList',masterList);
                component.set("v.problemFirstCallBack",false);
                
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
    }*/