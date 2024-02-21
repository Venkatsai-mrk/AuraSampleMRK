({
	  problemSectionReplica : function(component) {
        
        //var problemIdx = component.get("v.problemIndex");
        var problemId = component.get("v.problemId");
        var acc = component.find("problemSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        if(! $A.util.isUndefinedOrNull(problemId)){              
            var problemFirstCallBack = component.get("v.problemFirstCallBack");
            if(problemFirstCallBack == true){
                var action = component.get("c.getGoalsAndEvidences");        
                action.setParams({ 
                    problemId : problemId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        var listOfGoals = response.getReturnValue();     
                        console.log('listOfGoals '+JSON.stringify(listOfGoals));
                        var masterList = component.get("v.problem");
                       
                        console.log('new--', masterList['endDate']);
                        masterList['listOfGoal'] = listOfGoals.listOfGoalForProblem;
                        masterList['listOfDef'] = listOfGoals.listOfEvidenceForProblem;
                        component.set("v.listEvidence" , listOfGoals.listOfEvidenceForProblem);
                        
                        for(var problemRec in masterList['listOfGoal']){
                         masterList['listOfGoal'][problemRec]['endDate'] = masterList['endDate'];
                        }
                        for(let problemRec in masterList['listOfDef']){
                            masterList['listOfDef'][problemRec]['endDate'] = masterList['endDate'];
                        }
                        console.log('new', JSON.stringify(masterList));
                        
                        component.set("v.problem",masterList);
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
            }
        }
       
    },
      goalSectionReplica  : function(component, event, helper) {
        //var goalIdx = component.get("v.goalIdx");
        var goalId = component.get("v.problemId");
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
         if(! $A.util.isUndefinedOrNull(goalId)){  
        //var goalFirstCallBack = component.get("v.goalFirstCallBack");

            var action = component.get("c.getTasks");                
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue();     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var goal = {'listOfTask' : listOfTasks};
                     component.set("v.goal",goal);
                    //goal['listOfTask'] = listOfTasks;
                  
                    for(var goalRec in goal['listOfTask']){
                         goal['listOfTask'][goalRec]['endDate'] = goal['endDate'];
                        } 
                    component.set('v.tasksList',goal);
                    component.set('v.goal',goal);
                    component.set("v.goalFirstCallBack",false);
                    helper.observationSectionReplica(component, event, helper);
                    
                    
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
    
     observationSectionReplica  : function(component) {
       //  console.log('for observation  '+JSON.stringify(component.get("v.copyDummy")));
       //  var getReplicatedData = getDummy ;
        //var acc = component.find("taskSection");
        /*for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }*/
        var taskIdx = component.get("v.taskIdx");
        var taskId = component.get("v.problemId"); // undefined
        console.log("fvehf" , taskId + 'dsbdj' + taskIdx);
        //var taskFirstCallBack = component.get("v.taskFirstCallBack");
        
            var action = component.get("c.getInterventions");                
            action.setParams({ 
                taskId : taskId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfInterventions = response.getReturnValue();     
                   // console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var task = {'listOfIntervention' : listOfInterventions};
                     component.set("v.task",task);
                  //  var task = component.get("v.task");
                   // console.log('hsb',JSON.stringify(component.get("v.task")));
                    //task['listOfIntervention'] = listOfInterventions;
                  
                    for(var objRec in task['listOfIntervention']){
                         task['listOfIntervention'][objRec]['endDate'] = task['endDate'];
                     } 
                    console.log('listOfTasks '+JSON.stringify(task));
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
        
        
    },
      
})