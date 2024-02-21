({
    doInit : function(component, event, helper) {
       // var listOfAllProblems = component.get("v.allTasksList");
       var allTasks = JSON.parse(JSON.stringify(component.get("v.allTasksList").listOfObj));
        var problemList = [];
        var mapOfProblems = {};
        for(var probrec in allTasks) {
            problemList.push({value:allTasks[probrec].Id,
                              label:allTasks[probrec].ElixirSuite__Description__c}); 
            mapOfProblems[allTasks[probrec].Id] = allTasks[probrec]; 
        }
        console.log(JSON.stringify(problemList));
        component.set("v.options",problemList);
        component.set("v.allOptions",JSON.parse(JSON.stringify(problemList)));
        component.set("v.mapOfProblems",mapOfProblems);
        //event for modal
        /*var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "hideProblemMainModal" : true});
        cmpEvent.fire();*/
        //event 
    },
    handleChange: function (component, event) {
        component.set("v.selectedValues",event.getParam("value"));
    },
    closeModalAllProblems : function(component, event, helper) {       
        component.set("v.customTask",false);
    },
    save  : function(component, event, helper) {
        debugger;
        var mapOfExistingProbs = {};
        var masterObject= component.get("v.existingTasksObj");
        var listOfAllProblems = masterObject.listOfTask; //list of existing problems
        var mapOfProblems = component.get("v.mapOfProblems");//map of all problems
        var selectedOptionValue = component.get("v.selectedValues");
        for(var probrec in listOfAllProblems){
            mapOfExistingProbs[listOfAllProblems[probrec].Id] = listOfAllProblems[probrec]; 
        }
        
        for(var rec in selectedOptionValue){
            if($A.util.isUndefinedOrNull(mapOfExistingProbs[selectedOptionValue[rec]]) || mapOfExistingProbs[selectedOptionValue[rec]].Action =='DELETE'){
                listOfAllProblems.push(mapOfProblems[selectedOptionValue[rec]]);
            }            
        }
        masterObject.listOfTask = listOfAllProblems;
     //   console.log('masterObj '+JSON.stringify(masterObject));
        component.set("v.existingTasksObj",masterObject); 
        component.set("v.existingTasksObj1",masterObject); 
        console.log('masterObj '+JSON.stringify(masterObject));
        component.set("v.customTask",false);
    },
     search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})