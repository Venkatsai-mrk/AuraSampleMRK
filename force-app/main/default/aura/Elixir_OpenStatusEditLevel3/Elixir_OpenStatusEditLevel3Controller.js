({
    doInit : function(component, event, helper) {
           helper.heirarchyDescisionTree(component, event, helper);
        component.set("v.goalFirstCallBack",true);
    },
    goalSection  : function(component, event, helper) {
         var nameSpace = 'ElixirSuite__';
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        var goalIdx = component.get("v.goalIdx");
        var goalId = component.get("v.goalId");
        var goal = component.get("v.goal");
        var type = 'Careplan';
      /*  if($A.util.isUndefined(goal[nameSpace+'Dataset2__c'])){
            type = 'Template';
        }*/
        var goalFirstCallBack = component.get("v.goalFirstCallBack");
        var action;
        if(goalFirstCallBack == true){
            if(type == 'Template'){
                action = component.get("c.getTemplateTasks");
            }else{
                action = component.get("c.getTasks");
            }
                            
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue().listOfObjs;     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var goal = component.get("v.goal");
                    goal['listOfTask'] = listOfTasks;
                    goal['listOfIntervention'] = response.getReturnValue().listOfIntervention;
                    component.set('v.tasksList',goal);
                     component.set("v.goalFirstCallBack",false);
                     /************ AFTER CODE REFACTOR ***********************/
                    component.set("v.goal",goal);
                    /********************************************************/
                    console.log("b", component.get('v.tasksList'));
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
    addTasks :	function(component, event, helper){
         var nameSpace = 'ElixirSuite__';
        var listOfTasks = component.get("v.tasksList");
        var allTasksList = listOfTasks.listOfTask;
        var setOfIds = [];
        for(var taskRec in allTasksList){
            if(allTasksList[taskRec].Action != 'DELETE'){
                if( $A.util.isUndefinedOrNull(allTasksList[taskRec][nameSpace+'Dataset2__c'])){
                    setOfIds.push(allTasksList[taskRec].Id);           
                }else{
                    setOfIds.push(allTasksList[taskRec][nameSpace+'Dataset2__c']);
                }
            }
        }
     //   console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasksTemplate");
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
    dueDate  :		function(component, event, helper) {
          var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        var goalIdx = component.get("v.goalIdx");
        var goal =  component.get('v.goalsList');
        var listOfDefs = goal.listOfDef;
        listOfDefs[goalIdx][nameSpace+'Due_Date__c'] = dueDate;
        if($A.util.isUndefinedOrNull(listOfDefs[goalIdx][nameSpace+'Dataset2__c'])){
            //No Action Taken
          }else{
            listOfDefs[goalIdx]['Action'] = 'UPDATE';;
          }
       
        component.set('v.goalsList',goal);
        console.log('All goalsList ',JSON.stringify(component.get('v.goalsList')));
    },
    removeSection :		function(component, event, helper) {
         var nameSpace = 'ElixirSuite__';
        var acc = component.find("goalId");
        var goalIdx = component.get("v.goalIdx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var goal =  component.get('v.goalsList');
    //    console.log(JSON.stringify(component.get('v.goalsList')));
        var listOfDefs = goal.listOfDef;  
        if($A.util.isUndefinedOrNull(listOfDefs[goalIdx][nameSpace+'Dataset2__c'])){
            console.log('abc');
            listOfDefs.splice(goalIdx,1);
      }else{
           console.log('def');
            listOfDefs[goalIdx]['Action'] = 'DELETE';
      }
       
         var evt=component.getEvent("goalTest");
        evt.setParam("goal",goal);
        evt.fire();
       
       // component.set('v.goalsList',goal);
     //   console.log(JSON.stringify(component.get('v.goalsList')));
    },
    setTaskValue : function (component, event, helper) {
        var task=event.getParam('task');
        var goal=component.get("v.goal");
        goal.listOfTask=task.listOfTask;
        component.set('v.tasksList',task);
      component.set("v.goal",goal);

    },
     editableBox : function(component,event,helper){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component,event,helper){
        component.set("v.editableBoxVal", false);
           var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        var goalIdx = component.get("v.goalIdx");
        var goal =  component.get('v.goalsList');
        var listOfDefs = goal.listOfDef;
        if($A.util.isUndefinedOrNull(listOfDefs[goalIdx][nameSpace+'Dataset2__c'])){
            //No Action Taken
          }else{
            listOfDefs[goalIdx]['Action'] = 'UPDATE';;
          }
       
        component.set('v.goalsList',goal);
    },
})