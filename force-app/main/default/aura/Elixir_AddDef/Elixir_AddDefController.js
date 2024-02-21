({
    doInit : function(component) {
        var listOfAllGoals = component.get("v.allGoals");
        console.log(JSON.stringify(listOfAllGoals));
        var goalList = [];
        var mapOfGoals = {};
        for(var goalrec in listOfAllGoals){
            goalList.push({value:listOfAllGoals[goalrec].Id,
                           label:listOfAllGoals[goalrec].ElixirSuite__Description__c}); //For options map
            mapOfGoals[listOfAllGoals[goalrec].Id] = listOfAllGoals[goalrec]; //all goals map
        }
        console.log(JSON.stringify(goalList));
        component.set("v.options",goalList);
        component.set("v.allOptions",JSON.parse(JSON.stringify(goalList)));
        component.set("v.mapOfGoals",mapOfGoals);
    },
    handleChange: function (component, event) {
        if($A.util.isUndefinedOrNull(event.getParam("value")) || $A.util.isEmpty(event.getParam("value")) ){
            component.set("v.addButton",true)
        }
        else{
           component.set("v.addButton",false)
        }
        component.set("v.selectedValues",event.getParam("value"));
    },
    closeAllGoalsModal: function (component) {
        component.set("v.customGoalModal",false);
    },
    save: function(component) {
        var mapOfExistingGoals = {};
        debugger;
        var masterObject= component.get("v.existingGoals");
        var listOfAllGoals = masterObject.listOfDef; //list of existing goals
        var mapOfGoals = component.get("v.mapOfGoals");//map of all problems
        var selectedOptionValue = component.get("v.selectedValues");
        for(var goalrec in listOfAllGoals){
            mapOfExistingGoals[listOfAllGoals[goalrec].Id] = listOfAllGoals[goalrec]; 
        }
        
        for(var rec in selectedOptionValue){
            if($A.util.isUndefinedOrNull(mapOfExistingGoals[selectedOptionValue[rec]]) ||  mapOfExistingGoals[selectedOptionValue[rec]].Action =='DELETE'){
                listOfAllGoals.push(mapOfGoals[selectedOptionValue[rec]]);
            }            
        }
        masterObject.listOfDef = listOfAllGoals;
        component.set("v.existingGoals",masterObject);   
        component.set("v.customGoalModal",false);
    },
    search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})