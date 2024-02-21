({
    doInit : function(component, event, helper) {
        component.set("v.taskFirstCallBack",true);
        var mapOfGoalToNotes = component.get("v.note");
        console.log(JSON.stringify(mapOfGoalToNotes));
        if(! $A.util.isUndefinedOrNull(mapOfGoalToNotes)){
           var taskId = component.get("v.taskId");

           var listOfNotes = mapOfGoalToNotes[taskId];
 
           if(! $A.util.isUndefinedOrNull(listOfNotes)){                
               component.set("v.listOfNotes",listOfNotes);            
              // console.log('litsGoal Present');
           }
        }
        component.set("v.addNotesForTasksModal",true);
    },
    taskSection  : function(component, event, helper) {
        
        var acc = component.find("taskSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        var taskIdx = component.get("v.taskIdx");
        var taskId = component.get("v.taskId");
        var taskFirstCallBack = component.get("v.taskFirstCallBack");
        if(taskFirstCallBack == true){
            var action = component.get("c.getInterventions");                
            action.setParams({ 
                taskId : taskId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue().listOfTasks;     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    component.set("v.note",response.getReturnValue().mapOfProblemToNotes); // task to notes hi hai ye
                  //  console.log('notes ',response.getReturnValue());
                    component.set("v.interventionListModal",true);
                    var task = component.get("v.task");
                    task['listOfIntervention'] = listOfTasks;
                    component.set('v.InterventionsList',task);
                     component.set("v.taskFirstCallBack",false);
                    console.log("me" ,component.get('v.InterventionsList') );
                    
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
        var taskIdx = component.get("v.taskIdx");
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfTask;   
        listOfTasks[taskIdx]['endDate'] = endDate;
        component.set('v.TasksList',task);
        console.log('goal' , JSON.stringify(component.get("v.task")));
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