({
    doInit : function(component) {
        component.set("v.problemFirstCallBack",true);
        //  helper.problemSectionReplica(component, event, helper);
        console.log('abc' , component.get("v.dueDateProb"));
    }
    ,
    //This section bring goals relation to this problem
    problemSection : function(component, event, helper) {
        
        //var problemIdx = component.get("v.problemIndex");
        var problemId = component.get("v.problemId");
        var acc = component.find("problemSection");
        console.log('acc '+acc);
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
                        // console.log('listOfGoals '+JSON.stringify(listOfGoals.listOfDaignosis));
                        var masterList = component.get("v.problem");
                        component.set("v.Daignosis",listOfGoals.listOfDaignosis)
                        //  console.log('new--', masterList['endDate']);
                        masterList['listOfGoal'] = [];
                        masterList['listOfDef'] = [];
                        masterList['listOfRelatedDiagnosis'] = listOfGoals.listOfDaignosis;
                        component.set("v.listEvidence" , listOfGoals.listOfEvidenceForProblem);
                        
                        for(var problemRec in masterList['listOfGoal']){
                            masterList['listOfGoal'][problemRec]['endDate'] = masterList['endDate'];
                        }
                        for(let problemRec in masterList['listOfDef']){
                            masterList['listOfDef'][problemRec]['endDate'] = masterList['endDate'];
                        }
                        
                        //  console.log('new', JSON.stringify(masterList));
                        
                        component.set("v.problem",masterList);
                        component.set('v.goalsList',masterList);
                        component.set("v.problemFirstCallBack",false);
                        helper.goalSectionReplica(component, event, helper);
                        
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
        console.log('prob' , JSON.stringify(component.get("v.problem").endDate));
        var endDate = event.getSource().get("v.value");
        var problem =  component.get('v.problem');
        problem['endDate'] = endDate;
        component.set('v.problem',problem);
        console.log('prob' , JSON.stringify(component.get("v.problem").endDate));
    },
    addGoals  : function(component) {
        // component.set("v.openMainModal",true);
        //var listOfGoals = component.get("v.goalsList");
        console.log('problem id inside addgoals ',component.get("v.problemId"));
        var listOfGoals = component.get("v.problem");
        console.log('listOfGoals '+listOfGoals);
        var allGoalsList = listOfGoals.listOfGoal;
        var setOfIds = [];
        for(var goalRec in allGoalsList){
            if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec].Id)){
                setOfIds.push(allGoalsList[goalRec].Id);
                
            }
        }
        console.log('df'+JSON.stringify(setOfIds));
        var action = component.get("c.getAllGoalsAndObjectives");
        action.setParams({ 
            existingGoals : setOfIds,
            problemId : component.get("v.problemId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                var listOfGoals = response.getReturnValue().listOfTemplateProblemGoal;   
                console.log('listOfGoals');
                component.set("v.allGoals",listOfGoals);
                console.log('All Goals '+JSON.stringify(listOfGoals));
                component.set("v.customGoalModal",true);
                
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
    adddefs  : function(component) {
        // component.set("v.openMainModal",true);
        //var listOfGoals = component.get("v.goalsList");
        var listOfGoals = component.get("v.problem");
        var allGoalsList = listOfGoals.listOfDef;
        var setOfIds = [];
        for(var goalRec in allGoalsList){
            if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec].Id)){
                setOfIds.push(allGoalsList[goalRec].Id);
                
            }
        }
        console.log('df'+JSON.stringify(setOfIds));
        var action = component.get("c.getAllGoalsAndObjectives");
        action.setParams({ 
            existingGoals : setOfIds,
            problemId : component.get("v.problemId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                var listOfGoals = response.getReturnValue().listOfTemplateProblemObj;     
                component.set("v.allGoals1",listOfGoals);
                console.log('All Goals '+JSON.stringify(listOfGoals));
                component.set("v.customGoalModal1",true);
                
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
    addDiagnosis  : function(component) {
        component.set("v.openDiag",true);
        
    },
    removeSection :		function(component) {
            var acc = component.find("problemId");
            $A.util.removeClass(acc, 'slds-show');
            $A.util.addClass(acc, 'slds-hide');
            $A.util.removeClass(acc, 'first-inner-dl');
            var problemIdx = component.get("v.problemIndex");
            var problem =  component.get('v.problemsList');
            var listOfProblems = problem.listOfProblem;  
            listOfProblems.splice(problemIdx,1);
            component.set('v.problemsList',problem);
            component.set("v.showProblemButton",true);//added to enable problem button.
    },
    removeDiag :function(component, event) {
        
        //    var selectedId = component.find("diag").get("v.label");
        var selectedId = event.getSource().get("v.label");
        var listOfDiag = component.get("v.problem");
        var allDiag = listOfDiag.listOfRelatedDiagnosis;
        console.log(JSON.stringify(allDiag));
        for(var i in allDiag){
            if(allDiag[i].Name == selectedId){
                allDiag.splice(i, 1); 
            }
        }
        console.log(JSON.stringify(allDiag));
        listOfDiag.listOfRelatedDiagnosis=allDiag;
        component.set("v.problem",listOfDiag);
    },
    /*existingGoalsActive  :		function(component, event, helper) {
    },*/
    closeAllGoalsModal  :  function(component) {
        component.set("v.customGoalModal",false);
    },
    editableBox : function(component){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component){
        component.set("v.editableBoxVal", false);
    },
    handleValueChange : function (component, event) {
        var masterList = component.get("v.problem");
        console.log("kk" , masterList['listOfEvidences']);
        console.log("kk---" , component.get("v.msOptionsList"));
        masterList['listOfEvidences'] = event.getParam("value");
        component.set("v.problem",masterList);
        
    },
    setGoalValue : function (component, event) {
        var goal=event.getParam('goal');
        var problem=component.get("v.problem");
        problem.listOfGoal=goal.listOfGoal;
        component.set('v.goalsList',goal);
        component.set("v.problem",problem);
        
        
    },
    setDefValue : function (component, event) {
        var goal=event.getParam('goal');
        var problem=component.get("v.problem");
        problem.listOfGoal=goal.listDef;
        component.set('v.goalsList1',goal);
        component.set("v.problem",problem);
        
        
    },
    addInterventions :	function(component){
        var listOfInt = component.get("v.task");
        var allIntsList = listOfInt.listOfIntervention;
        var setOfIds = [];
        for(var taskRec in allIntsList){
            if(! $A.util.isUndefinedOrNull(allIntsList[taskRec].Id)){
                setOfIds.push(allIntsList[taskRec].Id);           
            }
        }
        var action = component.get("c.getAllInterventions");
        action.setParams({ 
            existingInts : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allIntsList",listOfTasks);
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
        var action = component.get("c.getAllTasks");
        action.setParams({ 
            existingTasks : setOfIds,
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
    AddNotes : function(component) {
        component.set("v.openModalAddNotes" , true);        
        component.set("v.openNotes" , true);
    },
    objEvent : function(component, event) { 
        var message = event.getParam("message"); 
        component.set("v.eventMessage", message ); 
        console.log('messages '+message);
        var listOfObj = component.get("v.eventMessage");
        event.stopPropagation();
        var prevvalue =  component.get("v.allTasksListShow");
        if(prevvalue != null && prevvalue!= undefined){
            for(var prev in prevvalue){
                listOfObj.push(prevvalue[prev]);
            }
        }
        component.set("v.allTasksListShow",listOfObj);
        component.set("v.customTask",false);
    },
    
    addObjective : function(component) { 
        var setOfIds = [];
        if(! $A.util.isUndefinedOrNull(component.get("v.allTasksListShow"))){
            var listOfTask = component.get("v.allTasksListShow");
            for(var taskRec in listOfTask){
                if(! $A.util.isUndefinedOrNull(listOfTask[taskRec].Id)){
                    setOfIds.push(listOfTask[taskRec].Id);           
                }
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
})