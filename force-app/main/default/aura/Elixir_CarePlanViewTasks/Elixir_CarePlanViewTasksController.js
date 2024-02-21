({
	doInit : function(component, event, helper) {
        console.log('aya');
   
        var mapOfTaskToNotes = component.get("v.note");
        console.log(JSON.stringify(mapOfTaskToNotes));
        if(! $A.util.isUndefinedOrNull(mapOfTaskToNotes)){
           var taskId = component.get("v.taskId");

           var listOfNotes = mapOfTaskToNotes[taskId];
 
           if(! $A.util.isUndefinedOrNull(listOfNotes)){                
               component.set("v.listOfNotes",listOfNotes);            
               console.log('litsGoal Present');
           }
        }
        component.set("v.addNotesForTasksModal",true);
	},    
     removeSection :	function(component, event, helper) {
        var acc = component.find("taskId");
        var taskIdx = component.get("v.taskIdx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfTask;  
        listOfTasks.splice(taskIdx,1);
        component.set('v.tasksList',task);
    }
})