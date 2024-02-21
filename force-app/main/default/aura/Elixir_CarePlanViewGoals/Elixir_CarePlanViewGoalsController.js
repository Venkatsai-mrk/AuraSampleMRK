({
    doInit : function(component, event, helper) {
        component.set("v.goalFirstCallBack",true);
        
        helper.heirarchyDescisionTree(component, event, helper);
        
        var mapOfProblemToNotes = component.get("v.note");
        console.log(JSON.stringify(mapOfProblemToNotes));
        if(! $A.util.isUndefinedOrNull(mapOfProblemToNotes)){
           var goalId = component.get("v.goalId");

           var listOfNotes = mapOfProblemToNotes[goalId];
 
           if(! $A.util.isUndefinedOrNull(listOfNotes)){                
               component.set("v.listOfNotes",listOfNotes);      
               console.log('megh') ;
               console.log('litsGoal Present', component.get("v.listOfNotes"));
           }
        }
        component.set("v.addNotesForGoalsModal",true);
    },
    goalSection  : function(component, event, helper) {
        
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        var goalIdx = component.get("v.goalIdx");
        var goalId = component.get("v.goalId");
        var goalFirstCallBack = component.get("v.goalFirstCallBack");
        if(goalFirstCallBack == true){
            var action = component.get("c.getTasks");  // Objective               
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue().listOfObjs;     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    component.set("v.note",response.getReturnValue().mapOfProblemToRec); // objective notes
                    console.log('notes ',response.getReturnValue());
                    component.set("v.taskListModal",true);
                    var goal = component.get("v.goal");
                    goal['listOfTask'] = listOfTasks;
                     goal['listOfIntervention'] = response.getReturnValue().listOfIntervention;
                    component.set('v.tasksList',goal);
                     component.set("v.goalFirstCallBack",false);
                    
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
    dueDate   : function(component, event, helper){
        var endDate = event.getSource().get("v.value");
        var goalIdx = component.get("v.goalIdx");
        var goal =  component.get('v.goalsList');
        var listOfGoals = goal.listOfGoal;   
        listOfGoals[goalIdx]['endDate'] = endDate;
        component.set('v.goalsList',goal);
        console.log('goal' , JSON.stringify(component.get("v.goal")));
    },
    addTasks :	function(component, event, helper){
        var listOfTasks = component.get("v.tasksList");
        var allTasksList = listOfTasks.listOfTask;
        var setOfIds = [];
        for(var taskRec in allTasksList){
            if(! $A.util.isUndefinedOrNull(allTasksList[taskRec].Id)){
                setOfIds.push(allTasksList[taskRec].Id);           
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasks");
        action.setParams({ 
            existingTasks : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allTasksList",listOfTasks);
                console.log('All Tasks '+JSON.stringify(listOfTasks));
                component.set("v.customTask",true);
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
    removeSection :		function(component, event, helper) {
        var acc = component.find("goalId");
        var goalIdx = component.get("v.goalIdx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var goal =  component.get('v.goalsList');
        console.log(JSON.stringify(component.get('v.problemsList')));
        var listOfGoals = goal.listOfGoal;  
        listOfGoals.splice(goalIdx,1);
        component.set('v.goalsList',goal);
        console.log(JSON.stringify(component.get('v.problemsList')));
    }
})