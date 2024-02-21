({
    doInit : function(component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var lstOfProblems =  component.get("v.existingGoals");
        
        var lstOfDaignoses = lstOfProblems.listOfRelatedDiagnosis;
        var arr = [];
        for (var existingId in lstOfDaignoses) {
            if(!$A.util.isUndefinedOrNull(lstOfDaignoses[existingId].Id)) {
                arr.push(lstOfDaignoses[existingId].Id);
            }
        }
        var action = component.get("c.getAllDaignosesTemplates");   
       // component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ existingDiagnosesList :  arr}); 
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
              //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                               
                var res = response.getReturnValue();
                 console.log('inside success'+JSON.stringify(res));             
                var b = [];
                var mapOfDiagnoses = {};
                for (var i = 0; i < res.length; i++) { 
                    // childRecords.push();
                    b.push({
                        'label': res[i]['ElixirSuite__Diagnosis_Code_and_Name__c'],
                        'value': res[i]['Id']                                               
                    });   
                    mapOfDiagnoses[res[i].Id] = res[i]; 
                }
                component.set("v.options",b); 
                component.set("v.mapOfGoals",mapOfDiagnoses); 
                console.log('map of diagnoses '+JSON.stringify(component.get("v.mapOfGoals")));
                component.set("v.allOptions",JSON.parse(JSON.stringify(b)));
                console.log('options set JSON'+JSON.stringify(component.get("v.options")));
            }
            else{
                //getting errors if callback fails
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
    handleChange: function (component, event) {
       // alert(event.getParam("value"));
        if($A.util.isUndefinedOrNull(event.getParam("value")) || $A.util.isEmpty(event.getParam("value")) ){
            component.set("v.addButton",true)
        }
        else{
           component.set("v.addButton",false)
        }
        component.set("v.selectedValues",event.getParam("value"));
    },
    closeAllGoalsModal: function (component, event) {
        component.set("v.customGoalModal",false);
    },
    save: function(component, event, helper) {
        var mapOfExistingGoals = {};
        debugger;
        var masterObject= component.get("v.existingGoals");
        var listOfAllGoals = masterObject.listOfRelatedDiagnosis; //list of existing goals
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
        masterObject.listOfRelatedDiagnosis = listOfAllGoals;
        component.set("v.existingGoals",masterObject);   
        component.set("v.customGoalModal",false);
    },
    search: function(component, event, helper) {
        // Filter list
        helper.search(component);
    }
})