({
    doInit : function(component, event, helper) {
            helper.heirarchyDescisionTree(component, event, helper);
     console.log('task new coming '+JSON.stringify(component.get("v.dueDateGoal")));
     //   helper.goalSectionReplica(component, event, helper);
        component.set("v.goalFirstCallBack",true);
        
    },
    goalSection  : function(component, event, helper) {
        var goalIdx = component.get("v.goalIdx");
        var goalId = component.get("v.goalId");
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
         if(! $A.util.isUndefinedOrNull(goalId)){  
        var goalFirstCallBack = component.get("v.goalFirstCallBack");
        if(goalFirstCallBack == true){
            var action = component.get("c.getTasks");                
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue();     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var goal = component.get("v.goal");
                    goal['listOfTask'] = listOfTasks.listOfObj;
                    goal['listOfIntervention'] = listOfTasks.listOfInterv;
                  
                    for(var goalRec in goal['listOfTask']){
                         goal['listOfTask'][goalRec]['endDate'] = goal['endDate'];
                        } 
                     for(var goalRec in goal['listOfIntervention']){
                         goal['listOfIntervention'][goalRec]['endDate'] = goal['endDate'];
                        } 
                    component.set('v.tasksList',goal);
                    component.set('v.goal',goal);
					 console.log('listOfTasks-- '+JSON.stringify(goal));
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
         }
    },
    dueDate   : function(component, event, helper){   
        var endDate = event.getSource().get("v.value");
        var goal =  component.get('v.goal');
        goal['endDate'] = endDate;
        component.set('v.goal',goal);
        console.log('goal' , JSON.stringify(component.get("v.goal").endDate));
    },
    addTasks :	function(component, event, helper){
        var listOfTask = component.get("v.goal");
        var allTasksList = listOfTask.listOfTask;
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
     addTask2 :	function(component, event, helper){
        var listOfTask = component.get("v.goal");
        var allTasksList = listOfTask.listOfIntervention;
        var setOfIds = [];
        for(var taskRec in allTasksList){
            if(! $A.util.isUndefinedOrNull(allTasksList[taskRec].Id)){
                setOfIds.push(allTasksList[taskRec].Id);           
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasks2");
        action.setParams({ 
            existingTasks : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allTasksList",listOfTasks);
                console.log('All Tasks '+JSON.stringify(listOfTasks));
                component.set("v.customTask2",true);
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
        $A.util.removeClass(acc, 'third-accordian_bl');
        var goal =  component.get('v.goalsList');
        var listOfGoals = goal.listOfGoal;  
        listOfGoals.splice(goalIdx,1);
        
        var evt=component.getEvent("goalTest");
        evt.setParam("goal",goal);
        evt.fire();
       // component.set('v.goalsList',goal);
    },
     editableBox : function(component,event,helper){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component,event,helper){
        component.set("v.editableBoxVal", false);
    },
    
    setTaskValue : function (component, event, helper) {
        var task=event.getParam('task');
        var goal=component.get("v.goal");
        goal.listOfTask=task.listOfTask;
        component.set('v.tasksList',task);
        component.set("v.goal",goal);
        
        
    }
})