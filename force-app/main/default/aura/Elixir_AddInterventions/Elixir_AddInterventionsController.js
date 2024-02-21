({
    doInit : function(component) {
        // var listOfAllProblems = component.get("v.allTasksList");
        var allTasks =  JSON.parse(JSON.stringify(component.get("v.allIntsList").listOfTemplateProblemInterv))
        console.log("n" , allTasks);
        var problemList = [];
        var mapOfProblems = {};
        for(var probrec in allTasks){
            problemList.push({value:allTasks[probrec].Id,
                              label:allTasks[probrec].ElixirSuite__Description__c}); 
            mapOfProblems[allTasks[probrec].Id] = allTasks[probrec]; 
        }
        
        // console.log('ds' + JSON.stringify(problemList));
        component.set("v.optionsInt",problemList);
        component.set("v.allOptionsInt",JSON.parse(JSON.stringify(problemList)));
        component.set("v.mapOfInts",mapOfProblems);
        //event for modal
        /*var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "hideProblemMainModal" : true});
        cmpEvent.fire();*/
        //event 
    },
    handleChange: function (component, event) {
        component.set("v.selectedValuesInt",event.getParam("value"));
    },
    closeModalAllProblems : function(component) {       
        component.set("v.customInt",false);
    },
    save  : function(component) {
        var mapOfExistingProbs = {};
        component.set("v.customInt",false);
        var selectedOptionValue = component.get("v.selectedValuesInt");
        if(!$A.util.isUndefinedOrNull(component.get("v.existingIntsObj")))
        {
            var masterObject= component.get("v.existingIntsObj");
            var listOfAllProblems = masterObject.listOfIntervention; //list of existing problems
            var mapOfProblems = component.get("v.mapOfInts");//map of all problems
            for(var probrec in listOfAllProblems){
                mapOfExistingProbs[listOfAllProblems[probrec].Id] = listOfAllProblems[probrec]; 
            }
            for(var rec in selectedOptionValue){
                if($A.util.isUndefinedOrNull(mapOfExistingProbs[selectedOptionValue[rec]]) || mapOfExistingProbs[selectedOptionValue[rec]].Action =='DELETE'){
                    listOfAllProblems.push(mapOfProblems[selectedOptionValue[rec]]);
                }            
            }
            masterObject.listOfIntervention = listOfAllProblems;
            console.log('masterObjIntervention '+JSON.stringify(masterObject));
            component.set("v.existingIntsObj",masterObject);
            if(component.get('v.carePlanIntervention')){
                var cmpEvent = component.getEvent("ObjectiveIntervEvents"); 
                cmpEvent.setParams({"intervent" : masterObject}); 
                cmpEvent.fire();
            }
            
        }
        
        console.log('selectedOptionValue '+selectedOptionValue);
        if(component.get("v.carePlan"))
        {
            var appEvent = component.getEvent("IntrvntionEvent");//$A.get("e.c:IntrvntionEvent"); 
            var listOfAllIntrv1 = component.get("v.allIntsList").listOfTemplateProblemInterv;
            var objList = [];
            
            for(var objrec in listOfAllIntrv1){
                for(var secvlue in selectedOptionValue){
                    console.log('listOfAllIntrv1[goalrec].id '+listOfAllIntrv1[objrec].Id);
                    console.log('selectedOptionValue '+selectedOptionValue[secvlue]);
                    if(listOfAllIntrv1[objrec].Id === selectedOptionValue[secvlue]){
                        objList.push(listOfAllIntrv1[objrec]);  
                    }
                }
            }
            console.log('objList '+objList);
            appEvent.setParams({"message" : objList}); 
            appEvent.fire();  
        }
        
    },
    search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})