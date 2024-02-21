({
    doInit : function(component) {
       // var listOfAllProblems = component.get("v.allTasksList");
               var allTasks = JSON.parse(JSON.stringify(component.get("v.allTasksList").listOfTemplateProblemObj)); 
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
        component.set("v.customTask",false);
    },
    save  : function(component) {
        var mapOfExistingProbs = {};
        var masterObject= component.get("v.existingTasksObj");
        console.log('existingTasksObj obj save',JSON.stringify(masterObject));
        var mapOfProblems = component.get("v.mapOfProblems");//map of all problems
        var listOfAllProblems = [];
        if(!$A.util.isEmpty(masterObject) && !$A.util.isUndefinedOrNull(masterObject.listOfTask)){
            listOfAllProblems = masterObject.listOfTask; //list of existing objectives
            console.log('masterObject.listOfObjectives '+masterObject.listOfTask); 
        }
        
        var selectedOptionValue = component.get("v.selectedValues");
        console.log('selectedOptionValue '+selectedOptionValue);
        if(component.get("v.carePlan"))
        {
            var appEvent =$A.get("e.c:ObjectiveEvent"); //component.getEvent("ObjectiveEvent"); 
            //Set event attribute value
            var listOfAllobj1 = component.get("v.allTasksList").listOfTemplateProblemObj;
            console.log(JSON.stringify(listOfAllobj1));
            var objList = [];
            
            for(var objrec in listOfAllobj1){
                for(var secvlue in selectedOptionValue){
                    console.log('listOfAllobj1[goalrec].id '+listOfAllobj1[objrec].Id);
                    console.log('selectedOptionValue '+selectedOptionValue[secvlue]);
                    if(listOfAllobj1[objrec].Id === selectedOptionValue[secvlue]){
                        listOfAllobj1[objrec]['Action'] = 'Update';
                        objList.push(listOfAllobj1[objrec]);  
                    }
                }
            }
            console.log('objList '+objList);
            appEvent.setParams({"message" : objList}); 
            appEvent.fire();  
            console.log('Fired');
        }
        for(var probrec in listOfAllProblems){
            mapOfExistingProbs[listOfAllProblems[probrec].Id] = listOfAllProblems[probrec]; 
        }
        
        for(var rec in selectedOptionValue){
            if($A.util.isUndefinedOrNull(mapOfExistingProbs[selectedOptionValue[rec]]) || mapOfExistingProbs[selectedOptionValue[rec]].Action =='DELETE'){
                listOfAllProblems.push(mapOfProblems[selectedOptionValue[rec]]);
            }            
        }
        if(!$A.util.isEmpty(masterObject)){
            masterObject.listOfTask = listOfAllProblems;
            masterObject['Action'] = 'Update';
            //   console.log('masterObj '+JSON.stringify(masterObject));
            component.set("v.existingTasksObj",masterObject); 
            component.set("v.existingTasksObj1",masterObject); 
            console.log('masterObjObjective '+JSON.stringify(masterObject));
        }
        component.set("v.customTask",false);
    },
     search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})