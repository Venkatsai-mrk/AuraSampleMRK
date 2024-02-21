({
    doInit : function(component) {
        var problemId = component.get("v.problemId");
        console.log('problem '+component.get('v.problem'));
        console.log('problemid '+problemId);
        var action = component.get("c.fetchRelatedDiagnosis");
        action.setParams({
            problemId: problemId
        });
        //  component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //   component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                console.log('DIAGNOSIS RESP '+JSON.stringify(res));
                var masterList = component.get("v.problem");
                masterList['listOfRelatedDiagnosis'] = res;
                masterList['listOfGoal'] = [];
                masterList['listOfDef'] = [];
                component.set("v.problem",masterList);
                component.set("v.problemFirstCallBack",true);
            }
            
        });
        
        $A.enqueueAction(action);
        
        if(!$A.util.isUndefinedOrNull(component.get('v.problem').ElixirSuite__Plan_Hierarchy__r)){
            var action1 = component.get("c.fetchNotes");
            action1.setParams({ 
                recordId : component.get("v.problem").ElixirSuite__Plan_Hierarchy__r[0].Id
            });
            action1.setCallback(this, function(response) {
                var state1 = response.getState();
                if (state1 === "SUCCESS") { 
                    console.log('Success2 in problem');
                    var listofNotesProblems = response.getReturnValue();
                    console.log('listofNotesProblems '+listofNotesProblems);
                    if(!$A.util.isUndefinedOrNull(listofNotesProblems)){
                        //var listOfNotes = component.get("v.listOfNotes");
                        component.set("v.listOfNotes",listofNotesProblems);
                        component.set("v.openNotes" , true);
                    }    
                }else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message in problem notes: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action1);
            
            //remove problem id from list if same problem added again
            var removedProblem = component.get("v.removedProblemId");
            for(var i = removedProblem.length - 1; i >= 0; i--){
                if(removedProblem[i] == component.get("v.problem").ElixirSuite__Plan_Hierarchy__r[0].Id){
                    removedProblem.splice(i,1);
                }
            }
            component.set("v.removedProblemId",removedProblem);
        }
        
    }
    ,
    //This section bring goals relation to this problem
    handleRemoveDiagnosis : function(component, event) {
        var nameSpace = 'ElixirSuite__';
        var problem = component.get("v.problem");
        var diagnosis = problem.listOfRelatedDiagnosis;
        var recordIndex = event.getSource().get("v.name");
        /************************************************************/
        if($A.util.isUndefinedOrNull(diagnosis[recordIndex][nameSpace+'Dataset1__c'])){
            diagnosis.splice(recordIndex,1);
        }else{
            diagnosis[recordIndex]['Action'] = 'DELETE';
        }
         /************************************************************/
        
        component.set("v.problem",problem);
        
    },
    problemSection : function(component) {
        console.log('Goals');
        //var nameSpace = 'ElixirSuite__';
        //var problemIdx = component.get("v.problemIndex");
        var problemId = component.get("v.problemId");
        var treatmentPlanId = component.get("v.treatmentPlanId");
        //var problem = component.get("v.problem");
        //var type = 'Careplan';
        /* if( $A.util.isUndefinedOrNull(problem[nameSpace+'Dataset1__c'])){
            type = 'Template';
        }*/
        var acc = component.find("problemSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        console.log('problemId',problemId);
        if(! $A.util.isUndefinedOrNull(problemId)){              
            var problemFirstCallBack = component.get("v.problemFirstCallBack");
            var action;
            if(problemFirstCallBack == true){
                  action = component.get("c.getGoalsAndEvidences");             
                action.setParams({ 
                    problemId : problemId,
                    treatmentPlanId : treatmentPlanId
                });        
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state',state);
                    if (state === "SUCCESS") {   
                        var listOfGoals = response.getReturnValue();     
                        console.log('listOfGoals '+JSON.stringify(listOfGoals));
                        var masterList = component.get("v.problem");
                        if(!$A.util.isUndefinedOrNull(listOfGoals.listOfGoal)){
                            masterList['listOfGoal'] = listOfGoals.listOfGoal;
                        }
                        if(!$A.util.isUndefinedOrNull(listOfGoals.listOfObjs)){
                            masterList['listOfDef'] = listOfGoals.listOfObjs;
                        }
                        masterList['listOfRelatedDiagnosis'] = listOfGoals.listOfDaignosis;
                        component.set("v.listEvidence" , listOfGoals.listOfObjs);
                        
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
                        //helper.goalSectionReplica(component, event, helper);
                        
                        /*component.set("v.listEvidence" , listOfGoals.listOfEvidence);
                        component.set('v.goalsList',masterList);
                       // component.set('v.problem',masterList);
                        component.set("v.problemFirstCallBack",false);
                        console.log('after adding untouched masterlist '+JSON.stringify(component.get("v.problemsList")));*/
                        
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
    handledueDateUpdate : function(component, event, helper) {
      
          var dueDate; 
         var params = event.getParam('arguments');
                if (params) {
                    dueDate = params.dueDate;
                    
                }
	helper.updateViaCommonAttribute(component, event, helper,dueDate);  
    },
    /* addGoals  : function(component, event, helper) {
        var nameSpace = '';
        var listOfGoals = component.get("v.goalsList");
        var allGoalsList = listOfGoals.listOfGoal;
        var setOfIds = [];
        for(var goalRec in allGoalsList){
            if(allGoalsList[goalRec].Action != 'DELETE'){
                if($A.util.isUndefinedOrNull(allGoalsList[goalRec][nameSpace+'Care_Plan_Template_Goal__c'])){
                    setOfIds.push(allGoalsList[goalRec].Id);
                    
                }else{
                    setOfIds.push(allGoalsList[goalRec][nameSpace+'Care_Plan_Template_Goal__c']);
                }
            }
        }
        console.log('df'+JSON.stringify(setOfIds));
        var action = component.get("c.getAllGoalsTemplate");
        action.setParams({ 
            existingGoals : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                var listOfGoals = response.getReturnValue().listOfGoal;     
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
    },*/
    addGoals  : function(component) {
        // component.set("v.openMainModal",true);
        //var listOfGoals = component.get("v.goalsList");
        var listOfGoals = component.get("v.problem");
        var allGoalsList = listOfGoals.listOfGoal;
        var setOfIds = [];
        for(var goalRec in allGoalsList){
            if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec])){
                if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec].ElixirSuite__Template_Problem__c)){
                    setOfIds.push(allGoalsList[goalRec].ElixirSuite__Template_Problem__c);
                }
                else{
                setOfIds.push(allGoalsList[goalRec].Id);
                }
                
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
    AddNotes : function(component) {
        component.set("v.openModalAddNotes" , true);        
        component.set("v.openNotes" , true);
    },
    addDiagnosis  : function(component) {
        component.set("v.openAddDiagnosis",true);
    },
    dueDate  :		function(component, event) {
        var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        var problemIdx = component.get("v.problemIndex");
        var problem =  component.get('v.problemsList');
        var listOfProblems = problem.listOfProblem;
        listOfProblems[problemIdx][nameSpace+'Due_Date__c'] = dueDate;
        if($A.util.isUndefinedOrNull(listOfProblems[problemIdx][nameSpace+'Dataset1__c'])){
            //No Action taken
        }else{
            listOfProblems[problemIdx]['Action'] = 'UPDATE';
        }
        
        component.set('v.problemsList',problem);
        console.log('All probs ',JSON.stringify(component.get('v.problem')));
    },
    removeSection :		function(component) {
        //var header = component.find("problem_header");
        //$A.util.removeClass(header, 'slds-show');
        //$A.util.addClass(header, 'slds-hide');
        
        var acc = component.find("problemId");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        console.log('problem before remove' , component.get('v.problem')); 
        var problem =  component.get('v.problem');
        if(!$A.util.isUndefinedOrNull(problem.ElixirSuite__Plan_Hierarchy__r)){
            let arr = component.get("v.removedProblemId");
            arr.push(problem.ElixirSuite__Plan_Hierarchy__r[0].Id);
            component.set("v.removedProblemId",arr);
        }
        let problemIdx = component.get("v.problemIndex");
        let problemlist =  component.get('v.problemsList');
        let listOfProblems = problemlist.listOfProblem;  
        listOfProblems.splice(problemIdx,1);
        component.set('v.problemsList',problemlist);
        component.set("v.showProblemButton",true);//added to enable problem button.
        
        
        //var nameSpace = 'ElixirSuite__';
        //var acc = component.find("problemId");
        /*$A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var problemIdx = component.get("v.problemIndex");
        var goalIdx = component.get("v.goalIdx");
        var problem =  component.get('v.problemsList');
        var listOfProblems = problem.listOfProblem;
        if($A.util.isUndefinedOrNull(listOfProblems[problemIdx][nameSpace+'Dataset1__c'])){
            listOfProblems.splice(problemIdx,1);
        }else{
            listOfProblems[problemIdx]['Action'] = 'DELETE';
        }
        
        
        console.log('Removed ',JSON.stringify(listOfProblems));
        component.set('v.problemsList',problem);
        console.log('All probs ',JSON.stringify(component.get('v.problem')));*/
    },
    closeAllGoalsModal  :  function(component) {
        component.set("v.customGoalModal",false);
    },
    editableBox : function(component){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component,event){
        
        component.set("v.editableBoxVal", false);
        var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        console.log('bbsb' + dueDate);
        var problemIdx = component.get("v.problemIndex");
        var problem =  component.get('v.problemsList');
        var listOfProblems = problem.listOfProblem;
        listOfProblems[problemIdx][nameSpace+'Due_Date__c'] = dueDate;
        if($A.util.isUndefinedOrNull(listOfProblems[problemIdx][nameSpace+'Dataset1__c'])){
            //No Action taken
        }else{
            listOfProblems[problemIdx]['Action'] = 'UPDATE';
        }
        component.set('v.problemsList',problem);
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
    adddef  : function(component) {
        // component.set("v.openMainModal",true);
        //var listOfGoals = component.get("v.goalsList");
        var listOfGoals = component.get("v.problem");
        var allGoalsList = listOfGoals.listOfDef;
        var setOfIds = [];
        for(var goalRec in allGoalsList){
            if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec].Id)){
                if(! $A.util.isUndefinedOrNull(allGoalsList[goalRec].ElixirSuite__Template_Problem__c)){
                    setOfIds.push(allGoalsList[goalRec].ElixirSuite__Template_Problem__c);
                }
                else{
                    setOfIds.push(allGoalsList[goalRec].Id);
                }
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
})