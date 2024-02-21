({
    doInit : function(component, event, helper) {
        component.set("v.problemFirstCallBack",true);
        helper.fetchDiagnoses(component, event, helper);
       //	helper.heirarchyDescisionTree(component, event, helper);
        var mapOfProblemToNotes = component.get("v.note");
        console.log(JSON.stringify(mapOfProblemToNotes));
        if(! $A.util.isUndefinedOrNull(mapOfProblemToNotes)){
            var problemId = component.get("v.problemId");
            
            var listOfNotes = mapOfProblemToNotes[problemId];
            
            if(! $A.util.isUndefinedOrNull(listOfNotes)){                
                component.set("v.listOfNotes",listOfNotes);            
                
            }
        }
        if(!component.get("v.carePlanClosedStatus")){
            component.set("v.addNotesForProblemModal",true);
        }
    },
    //This section bring goals relation to this problem
    problemSection : function(component, event, helper) {
        console.log('Goals');
        var problemIdx = component.get("v.problemIndex");
        var problemId = component.get("v.problemId");
        var acc = component.find("problemSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        if(! $A.util.isUndefinedOrNull(problemId)){              
            var problemFirstCallBack = component.get("v.problemFirstCallBack");
            if(problemFirstCallBack == true){
                var action = component.get("c.getGoals");        
                action.setParams({ 
                    problemId : problemId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        var listOfGoals = response.getReturnValue().listOfGoal;     
                        component.set("v.note",response.getReturnValue().mapOfProblemToNotes);
                        component.set("v.note_2",response.getReturnValue().mapOfProblemToNotes_2);
                        component.set('v.carePlanViewGoals',true);
                        console.log('listOfGoals '+JSON.stringify(listOfGoals));
                        var masterList = component.get("v.problem");
                        masterList['listOfGoal'] = listOfGoals;
                        masterList['listOfDef'] =  response.getReturnValue().level2_Goal_bhevDef;
                        component.set("v.listEvidence" , response.getReturnValue().listOfEvidence);
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
        else{
            
        }
        
    },
    closeAllGoalsModal  :  function(component, event, helper) {
        component.set("v.customGoalModal",false);
    }
})