({
    doInit : function(component) {
        var listOfAllProblems = component.get("v.problemsList");
        var problemList = [];
        var mapOfProblems = {};
        for(var probrec in listOfAllProblems){
            problemList.push({value:listOfAllProblems[probrec].Id,
                              label:listOfAllProblems[probrec].Name}); 
            mapOfProblems[listOfAllProblems[probrec].Id] = listOfAllProblems[probrec]; 
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
        if($A.util.isUndefinedOrNull(event.getParam("value")) || $A.util.isEmpty(event.getParam("value")) ){
            component.set("v.addButton",true)
        }
        else{
           component.set("v.addButton",false)
        }
        component.set("v.selectedValues",event.getParam("value"));
    },
    closeModalAllProblems : function(component) {       
        component.set("v.openModalAllProblems",false);
    },
    save  : function(component) {
        var mapOfExistingProbs = {};
        var masterObject= component.get("v.masterProblems");
        var listOfAllProblems = masterObject.listOfProblem; //list of existing problems
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
       // masterObject.listOfProblem = listOfAllProblems;
        console.log('masterObj '+JSON.stringify(masterObject));
        component.set("v.masterProblems",masterObject); 
        component.set("v.openModalAllProblems",false);
    },
     search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})