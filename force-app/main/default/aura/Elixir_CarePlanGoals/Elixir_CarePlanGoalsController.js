({
    doInit : function(component, event, helper) {
        helper.heirarchyDescisionTree(component, event, helper);
   		helper.goalSectionReplica(component, event, helper);
        component.set("v.goalFirstCallBack",true);
        
    },
    goalSection1  : function(component) {
        //var goalIdx = component.get("v.goalIdx");
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
                        for(let goalRec in goal['listOfIntervention']){
                            goal['listOfIntervention'][goalRec]['endDate'] = goal['endDate'];
                        } 
                        component.set('v.tasksList',goal);
                        component.set('v.goal',goal);
                        console.log('listOfTasks-- '+JSON.stringify(goal));
                        component.set("v.goalFirstCallBack",false);
                        var event = component.getEvent("GoalHierarchyEvent"); 
                        event.setParams({
                            "goalhierarchy" :  component.get('v.goal')
                        }); 
                        event.fire();     
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
    dueDate   : function(component, event){   
        var endDate = event.getSource().get("v.value");
        var goal =  component.get('v.goal');
        goal['endDate'] = endDate;
        component.set('v.goal',goal);
        console.log('goal' , JSON.stringify(component.get("v.goal").endDate));
    },
    addTasks :	function(component){
        var listOfTask = component.get("v.goal");
        var allTasksList = listOfTask.listOfTask;
        var setOfIds = [];
        for(var taskRec in allTasksList){
            if(! $A.util.isUndefinedOrNull(allTasksList[taskRec].Id)){
                setOfIds.push(allTasksList[taskRec].Id);           
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getTasksFromGoal");
        action.setParams({ 
            existingTasks : setOfIds,
            goalId : component.get("v.goalId")
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
    addTask2 :	function(component){
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
            existingTasks : setOfIds,
            goalId : component.get("v.goalId")
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
    removeSection :	function(component) {
        var header = component.find("goalHeaderId");
        $A.util.removeClass(header, 'slds-show');
        $A.util.addClass(header, 'slds-hide');
        var acc = component.find("goalId");
        var goalIdx = component.get("v.goalIdx");
        console.log('goalIdx '+ goalIdx);
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        $A.util.removeClass(acc, 'third-accordian_bl');
        var goal =  component.get('v.goalsList');
        console.log('goal '+ goal);
        if(! $A.util.isUndefinedOrNull(goal.listOfGoal) && !component.get("v.carePlan")){
            var listOfGoals = goal.listOfGoal;
            for(var g in listOfGoals){
                if(listOfGoals[g].ElixirSuite__Description__c == goalIdx){
                    listOfGoals.splice(listOfGoals.indexOf(listOfGoals[g]),1);
                }
            }
        }
        else{
            var evt=component.getEvent("goalRec");
            evt.setParam("goal",goal);
            evt.setParam("index",goalIdx);
            evt.fire();
        }
        // component.set('v.goalsList',goal);
    },
    editableBox : function(component){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component){
        component.set("v.editableBoxVal", false);
    },
    
    setTaskValue : function (component, event) {
        var task=event.getParam('task');
        var goal=component.get("v.goal");
        goal.listOfTask=task.listOfTask;
        component.set('v.tasksList',task);
        component.set("v.goal",goal);
    },
    AddNotes : function(component) {
        console.log('abcd');
        component.set("v.openModalAddNotes" , true);
        component.set("v.openNotes" , true);
    }/*,
    AccountEventGoals : function(component, event, helper) {
        var message = event.getParam("Id"); 
        component.set("v.recordVal", message); 
    }*/
})