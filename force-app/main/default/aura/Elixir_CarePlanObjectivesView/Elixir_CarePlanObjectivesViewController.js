({
    doInit : function(component, event, helper) {
        component.set("v.taskFirstCallBack",true);
        console.log('userlist inside objective',component.get("v.usersList"));
        helper.observationSectionReplica(component, event, helper);
        console.log('at init '+JSON.stringify(component.get("v.taskId"))); // values coming
        if(!$A.util.isUndefinedOrNull(component.get("v.task").ElixirSuite__Template_Problem__r)){
            var action = component.get("c.fetchNotes");
            action.setParams({ 
                recordId : component.get("v.taskId")
            });
            action.setCallback(this, function(response) {
                var state1 = response.getState();
                if (state1 === "SUCCESS") { 
                    console.log('Success2 in objective');
                    var listofNotesGoals = response.getReturnValue();
                    console.log('listofNotesGoals '+listofNotesGoals);
                    if(!$A.util.isUndefinedOrNull(listofNotesGoals)){
                        //var listOfNotes = component.get("v.listOfNotes");
                        component.set("v.listOfNotes",listofNotesGoals);
                        component.set("v.openNotes" , true);
                    }    
                }else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message in goal notes: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        }
    },   
    observationSection  : function(component) {
        //  console.log('for observation  '+JSON.stringify(component.get("v.copyDummy")));
        //  var getReplicatedData = getDummy ;
        var acc = component.find("taskSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        var taskIdx = component.get("v.taskIdx");
        var taskId = component.get("v.taskId"); // undefined
        console.log("fvehf" , taskId + 'dsbdj' + taskIdx);
        var taskFirstCallBack = component.get("v.taskFirstCallBack");
        console.log("taskFirstCallBack" , taskFirstCallBack);
        if(taskFirstCallBack == true){
            
            //if(!$A.util.isUndefinedOrNull(taskId) || !$A.util.isEmpty(taskId)){
                var action = component.get("c.getInterventions");                
                action.setParams({ 
                    taskId : taskId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        var listOfInterventions = response.getReturnValue();     
                        console.log('listOfTasks3 '+JSON.stringify(listOfTasks));
                        var task = component.get("v.task");
                        console.log('hsb',JSON.stringify(component.get("v.task")));
                        task['listOfIntervention'] = listOfInterventions;
                        
                        for(var objRec in task['listOfIntervention']){
                            task['listOfIntervention'][objRec]['endDate'] = task['endDate'];
                        } 
                        console.log('listOfTasks ii'+JSON.stringify(task));
                        component.set('v.InterventionsList',task);
                        component.set('v.task',task);
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
            //}
        }
        
    },
    
    dueDate   : function(component, event){
        var endDate = event.getSource().get("v.value");
        var task =  component.get('v.task');
        task['endDate'] = endDate;
        component.set('v.task',task);
        console.log('task' , JSON.stringify(component.get("v.task")));
    },
    addTasks :	function(component){
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
    addInterventions :	function(component){
         console.log('listOfInt ', component.get("v.taskId"));
        var listOfInt = component.get("v.task");
        console.log('listOfInt '+JSON.stringify(listOfInt));
        var allIntsList = listOfInt.listOfIntervention;
        var setOfIds = [];
        for(var taskRec in allIntsList){
            if(! $A.util.isUndefinedOrNull(allIntsList[taskRec])){
                if(! $A.util.isUndefinedOrNull(allIntsList[taskRec].ElixirSuite__Template_Problem__c)){
                    setOfIds.push(allIntsList[taskRec].ElixirSuite__Template_Problem__c);   
                }
                else{
                    setOfIds.push(allIntsList[taskRec].Id);
                }
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getInterventionFromObjective");
        action.setParams({ 
            existingInts : setOfIds,
            objectiveId : component.get("v.taskId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allIntsList",listOfTasks);
                console.log('All Tasksss '+JSON.stringify(listOfTasks));
                component.set("v.customInt",true);
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
    
    
    editableBox : function(component){
        component.set("v.editableBoxVal", true);
    },
    removeSection :	function(component) {
        var acc = component.find("taskIds");
        var taskIdx = component.get("v.taskIdx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        $A.util.removeClass(acc, 'third-accordian_bl'); 
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfTask; 
        listOfTasks.splice(taskIdx,1);
        console.log('dhbwdh--' , JSON.stringify(task));        
        var evt=component.getEvent("test");
        evt.setParam("task",task);
        evt.fire();
    },
    outsideFocus : function(component){
        component.set("v.editableBoxVal", false);
    },
    setIntValue : function (component, event) {
        var task=event.getParam('Intervention');
        var int=component.get("v.task");
        int.listOfIntervention=task.listOfIntervention;
        component.set('v.InterventionsList',task);
        component.set("v.task",int);
        console.log('hjk', JSON.stringify(component.get("v.InterventionsList")));
        
    },
    AddNotes : function(component) {
        console.log('abd');
        component.set("v.openModalAddNotes" , true);
        component.set("v.openNotes" , true);
    }/*, 
    AccountEventObj : function(component, event, helper) {
        var message = event.getParam("Id"); 
        component.set("v.recordVal", message);  
    }*/
})