({
    observationSectionReplica  : function(component) {
        //  console.log('for observation  '+JSON.stringify(component.get("v.copyDummy")));
        //  var getReplicatedData = getDummy ;
        //var acc = component.find("taskSection");
        /*  for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }*/
         var taskIdx = component.get("v.taskIdx");
         var taskId = component.get("v.taskId"); // undefined
         console.log("fvehf" , taskId + 'dsbdj' + taskIdx);
         //var taskFirstCallBack = component.get("v.taskFirstCallBack");
         
         var action = component.get("c.getInterventions");                
         action.setParams({ 
             taskId : taskId
         });
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {   
                 var listOfInterventions = response.getReturnValue();     
                 var task = component.get("v.task");
                 console.log('hsb',JSON.stringify(component.get("v.task")));
                 task['listOfIntervention'] = listOfInterventions;
                 
                 for(var objRec in task['listOfIntervention']){
                     task['listOfIntervention'][objRec]['endDate'] = task['endDate'];
                 } 
                 console.log('listOfTasks4 '+JSON.stringify(task));
                 component.set('v.InterventionsList',task);
                 component.set('v.task',task);
                 component.set("v.taskFirstCallBack",false);
                 if(component.get('v.carePlanObjective')){
                     var cmpEvent = component.getEvent("ObjectiveIntervEvents"); 
                     cmpEvent.setParams({"intervent" : task}); 
                     cmpEvent.fire();
                 }
                 
                 
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