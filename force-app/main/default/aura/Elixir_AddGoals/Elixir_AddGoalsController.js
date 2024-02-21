({
    doInit : function(component) {
        var listOfAllGoals = component.get("v.allGoals");
        console.log('list of all goals',JSON.stringify(listOfAllGoals));
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
        var masterObject= component.get("v.existingGoals");
        console.log('masterObject '+JSON.stringify(masterObject));
        var mapOfGoals = component.get("v.mapOfGoals");//map of all goals
        var listOfAllGoals=[];
        if(!$A.util.isEmpty(masterObject) && !$A.util.isUndefinedOrNull(masterObject.listOfGoal)){
            listOfAllGoals = masterObject.listOfGoal; //list of existing goals
            console.log('masterObject.listOfGoal '+masterObject.listOfGoal);
        }
         var selectedOptionValue = component.get("v.selectedValues");
        console.log('selectedOptionValue '+selectedOptionValue);
        if(component.get("v.carePlan"))
        {
            var appEvent = component.getEvent("GoalEventValue");//$A.get("e.c:GoalEventValue"); 
            var listOfAllGoals1 = component.get("v.allGoals");
            console.log(JSON.stringify(listOfAllGoals1));
            var goalList = [];
           
            for(var goalrec in listOfAllGoals1){
                for(var secvlue in selectedOptionValue){
                    console.log('listOfAllGoals1[goalrec].id '+listOfAllGoals1[goalrec].Id);
                    console.log('selectedOptionValue '+selectedOptionValue[secvlue]);
                    if(listOfAllGoals1[goalrec].Id === selectedOptionValue[secvlue]){
                        goalList.push(listOfAllGoals1[goalrec]);  
                    }
                }
            }
            console.log('goalList '+JSON.stringify(goalList));
            appEvent.setParams({"message" : goalList}); 
            appEvent.fire();  
            component.set("v.customGoalModal",false);
        }
        
        for(var goalrec in listOfAllGoals){
            mapOfExistingGoals[listOfAllGoals[goalrec].Id] = listOfAllGoals[goalrec]; 
        }
        
        for(var rec in selectedOptionValue){
            if($A.util.isUndefinedOrNull(mapOfExistingGoals[selectedOptionValue[rec]]) ||  mapOfExistingGoals[selectedOptionValue[rec]].Action =='DELETE'){
                listOfAllGoals.push(mapOfGoals[selectedOptionValue[rec]]);
            }            
        }
        
        if(!$A.util.isEmpty(masterObject)) masterObject.listOfGoal = listOfAllGoals;
        if(!$A.util.isEmpty(masterObject)) component.set("v.existingGoals",masterObject); 
        //else component.set("v.existingGoals",goalList);
        component.set("v.customGoalModal",false);
    },
    
    getData: function(component, event) {
        var params = event.getParam("value");
        if (params) {
            return event.getParam("value");
        }
        
    },
    
    search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})