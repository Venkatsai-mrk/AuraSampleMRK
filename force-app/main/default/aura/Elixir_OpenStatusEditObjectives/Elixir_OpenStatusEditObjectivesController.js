({
    doInit : function(component, event, helper) {
        component.set("v.taskFirstCallBack",true);
    },
    taskSection  : function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var acc = component.find("taskSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        var taskIdx = component.get("v.taskIdx");
        var taskId = component.get("v.taskId");
        var task = component.get("v.task");
        var type = 'Careplan';
       /* if($A.util.isUndefined(task[nameSpace+'Care_Plan_Template_Task__c'])){
            type = 'Template';
        }*/
        var taskFirstCallBack = component.get("v.taskFirstCallBack");
        var action;
        if(taskFirstCallBack == true){
            if(type == 'Template'){
                action = component.get("c.getTemplateInterventions");
            }else{
                action = component.get("c.getInterventions");
            }
                            
            action.setParams({ 
                taskId : taskId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue().listOfTasks;     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var task = component.get("v.task");
                    task['listOfIntervention'] = listOfTasks;
                    
                    component.set('v.InterventionsList',task);
                    component.set('v.task',task);
                    console.log('test' , JSON.stringify(component.get('v.InterventionsList')));
                     component.set("v.taskFirstCallBack",false);
                    
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
        var listOfTasks = component.get("v.InterventionsList");
        var allTasksList = listOfTasks.listOfIntervention;
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
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasks2");
        action.setParams({ 
            existingInts : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allIntsList",listOfTasks);
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
        var taskIdx = component.get("v.taskIdx");
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfTask;
        listOfTasks[taskIdx][nameSpace+'End_Date__c'] = dueDate;
        if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace+'Care_Plan_Template_task__c'])){
            //No Action Taken
          }else{
            listOfTasks[taskIdx]['Action'] = 'UPDATE';;
          }
       
        component.set('v.tasksList',task);
       // console.log('All goalsList ',JSON.stringify(component.get('v.goalsList')));
    },
    removeSection :		function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var acc = component.find("taskId");
        var taskIdx = component.get("v.taskIdx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var task =  component.get('v.tasksList');
     //   console.log(JSON.stringify(component.get('v.goalsList')));
        var listOfTasks = task.listOfTask;  
        if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace +'Care_Plan_Template_Task__c'])){
            listOfTasks.splice(taskIdx,1);
      }else{
            listOfTasks[taskIdx]['Action'] = 'DELETE';
      }
       
       var evt=component.getEvent("test");
        evt.setParam("task",task);
        evt.fire();
       // component.set('v.goalsList',goal);
       // console.log(JSON.stringify(component.get('v.goalsList')));
    },
    
    setIntValue : function (component, event, helper) {
        var Int=event.getParam('Intervention');
        var task=component.get("v.InterventionsList");
        task.listOfTask=Int.listOfIntervention;
        component.set('v.InterventionsList',task);
       component.set("v.goal",goal);

    },
    editableBox : function(component,event,helper){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus1 : function(component,event,helper){
        component.set("v.editableBoxVal", false);
        var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        var taskIdx = component.get("v.taskIdx");
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfTask
        if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace+'Care_Plan_Template_task__c'])){
            //No Action Taken
          }else{
              console.log('gbh');
            listOfTasks[taskIdx]['Action'] = 'UPDATE';;
          }
       
        component.set('v.tasksList',task);
        console.log('bc' , JSON.stringify(component.get('v.tasksList')));
    },
})