({
    doInit : function(component, event, helper) {
        helper.heirarchyDescisionTree(component, event, helper);
        console.log('goal in edit goal init '+JSON.stringify(component.get("v.goal")));
        //helper.goalSectionReplica(component, event, helper);
        component.set("v.goalFirstCallBack",true);
        if(!$A.util.isUndefinedOrNull(component.get("v.goal").ElixirSuite__Template_Problem__r)){
            var action = component.get("c.fetchNotes");
            action.setParams({ 
                recordId : component.get("v.goalId")
            });
            action.setCallback(this, function(response) {
                var state1 = response.getState();
                if (state1 === "SUCCESS") { 
                    console.log('Success2');
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
                        goal['listOfTask'] = listOfTasks.listOfObjs;
                        goal['listOfIntervention'] = listOfTasks.listOfTasks;
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
            if(! $A.util.isUndefinedOrNull(allTasksList[taskRec])){
                if(! $A.util.isUndefinedOrNull(allTasksList[taskRec].ElixirSuite__Template_Problem__c)){
                   setOfIds.push(allTasksList[taskRec].ElixirSuite__Template_Problem__c);   
            }
            else{
                setOfIds.push(allTasksList[taskRec].Id);  
            }
        }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getTasksFromGoal");
        if($A.util.isEmpty(setOfIds) && ! $A.util.isUndefinedOrNull(listOfTask.ElixirSuite__Template_Problem__c)){
            action.setParams({ 
                existingTasks : setOfIds,
                goalId : listOfTask.ElixirSuite__Template_Problem__c
            });
        }
        else{
            action.setParams({ 
                existingTasks : setOfIds,
                goalId : component.get("v.goalId")
            });
        }
        
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
        console.log('listOfTask inside goal interv',listOfTask);
        var allTasksList = listOfTask.listOfIntervention;
        console.log('allTasksList inside addatsk2',allTasksList);
        var setOfIds = [];
       // var setOfIds2 = [];
        for(var taskRec in allTasksList){
            if(! $A.util.isUndefinedOrNull(allTasksList[taskRec])){
                if(! $A.util.isUndefinedOrNull(allTasksList[taskRec].ElixirSuite__Template_Problem__c)){
                    setOfIds.push(allTasksList[taskRec].ElixirSuite__Template_Problem__c);   
                }
                else{
                    setOfIds.push(allTasksList[taskRec].Id);
                }
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasks2");
        if($A.util.isEmpty(setOfIds) && ! $A.util.isUndefinedOrNull(listOfTask.ElixirSuite__Template_Problem__c)){
            console.log('inside if');
            action.setParams({ 
                existingTasks : setOfIds,
                goalId : listOfTask.ElixirSuite__Template_Problem__c
            });
        }
        else{
            action.setParams({ 
                existingTasks : setOfIds,
                goalId : component.get("v.goalId")
            }); 
        }
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
    removeSection :		function(component) {
        var header = component.find("goalId");
        $A.util.removeClass(header, 'slds-show');
        $A.util.addClass(header, 'slds-hide');
        var acc = component.find("goalId");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var goalIdx = component.get("v.goalIdx");
        console.log('goal before remove' , component.get('v.goal'));
        var goalsList =  component.get('v.goalsList');
        console.log('goalsList' , JSON.stringify(component.get('v.goalsList')));
        if(!$A.util.isUndefinedOrNull(goalsList) && !$A.util.isUndefinedOrNull(goalsList.listOfGoal)){
            for(var g in goalsList.listOfGoal){
                console.log('goalIdx' , goalIdx, 'goalsList.listOfGoal[g].Name', goalsList.listOfGoal[g].Name, 'goalid', component.get("v.goalId"));
                if(!$A.util.isUndefinedOrNull(component.get('v.goal').ElixirSuite__Template_Problem__r)){
                    //added for if goal is not template problem its plan subhierarchy, removed goal will not restore until its deleted from database
                    let goal =  component.get('v.goal');
                    goal['Action'] = 'Delete';
                    component.set('v.goal',goal);
                    console.log('goal after remove under problem' , component.get('v.goal'));
                    break;
                }
                else{
                    if(component.get('v.goal').Name == goalIdx && goalsList.listOfGoal[g].Name == goalIdx){
                        //it means goal under problem is template problem goal and after remove it will be restored under add goal button
                        goalsList.listOfGoal.splice(goalsList.listOfGoal.indexOf(goalsList.listOfGoal[g]),1);
                        console.log('goalsList after under problem' , JSON.stringify(component.get('v.goalsList')));
                        component.set('v.goalsList', goalsList);
                        break;
                    } 
                }
            } 
        }
        else{
            let goal =  component.get('v.goal');
            goal['Action'] = 'Delete';
            component.set('v.goal',goal);
            console.log('goal after remove' , component.get('v.goal'));
        }
        //var goalIdx = component.get("v.goalIdx");
        //console.log('goalIdx '+ goalIdx);
        //$A.util.removeClass(acc, 'third-accordian_bl');
        /*var goal =  component.get('v.goalsList');
        if(! $A.util.isUndefinedOrNull(goal.listOfGoal) && !component.get("v.carePlan")){
            var listOfGoals = goal.listOfGoal;  
            listOfGoals.splice(goalIdx,1);
        }
        else{
            var evt=component.getEvent("goalRec");
            evt.setParam("goal",goal);
            evt.fire();
        }
        // component.set('v.goalsList',goal);
        // */
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
        component.set("v.openModalAddNotes" , true);
        component.set("v.openNotes" , true);
    }/*,
    AccountEventGoals : function(component, event, helper) {
        var message = event.getParam("Id"); 
        component.set("v.recordVal", message); 
    }*/
})