({
    doInit : function(component) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //console.log('userId '+userId);
        var task =  component.get('v.task1');
        if(!$A.util.isUndefinedOrNull(task.OwnerId)){
           component.set('v.userId', task.OwnerId);
        }
        else{
            if(!$A.util.isUndefinedOrNull(task.assignedTo)){
                component.set('v.userId', task.assignedTo);
            }
            else{
                component.set('v.userId', userId);
                task['assignedTo'] = userId;
            }
            
        }
        if(!$A.util.isUndefinedOrNull(task.ElixirSuite__Description__c)){
            task['Description'] = task.ElixirSuite__Description__c;
        }
        component.set('v.task1',task);
        console.log('intervention asigned do init' , JSON.stringify(component.get("v.task1")));
        
        if(!$A.util.isUndefinedOrNull(component.get("v.task1").WhatId)){
            var action = component.get("c.fetchNotes");
            action.setParams({ 
                recordId : component.get("v.taskId1")
            });
            action.setCallback(this, function(response) {
                var state1 = response.getState();
                if (state1 === "SUCCESS") { 
                    console.log('Success2');
                    var listofNotesGoals = response.getReturnValue();
                    console.log('listofNotesGoals '+listofNotesGoals);
                    if(!$A.util.isUndefinedOrNull(listofNotesGoals)){
                        //var listOfNotes = component.get("v.listOfNotes");
                        component.set("v.listOfNotes",listofNotesGoals);
                        component.set("v.openNotes" , true);
                    }    
                }else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message in goal notes: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
        }
        
        if(component.get('v.carePlan')){
            var cmpEvent = component.getEvent("InterventionTopEvent"); 
            cmpEvent.setParams({"InterventionJSON" : component.get("v.task1")}); 
            cmpEvent.fire();
        }
        
    },   
    dueDate   : function(component, event){
        var endDate = event.getSource().get("v.value");
        var task =  component.get('v.task1');
        task['endDate'] = endDate;
        component.set('v.task1',task);
        console.log('task' , JSON.stringify(component.get("v.task1")));
        if(component.get('v.carePlan')){
            var cmpEvent = component.getEvent("InterventionTopEvent"); 
            cmpEvent.setParams({"InterventionJSON" : component.get("v.task1")}); 
            cmpEvent.fire();
        }
    }, 
    removeSection :	function(component) {
        var header = component.find("interv_header");
        $A.util.removeClass(header, 'slds-show');
        $A.util.addClass(header, 'slds-hide');
        var acc = component.find("taskId1");
        var allTaskIdx1 = component.get("v.taskIdx1");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        console.log('intervention List' , component.get('v.tasksList1'));
        
        var allTask =  component.get('v.tasksList1');
        if(!$A.util.isUndefinedOrNull(allTask.listOfIntervention)){
            var listOfAllTasks = allTask.listOfIntervention;
             for(var interv in listOfAllTasks){
                 if(listOfAllTasks[interv].Description == allTaskIdx1){
                     if(!$A.util.isUndefinedOrNull(listOfAllTasks[interv].WhatId)){
                         let arr = component.get("v.removedInterventionId");
                         arr.push(listOfAllTasks[interv].Id);
                         component.set("v.removedInterventionId",arr);
                     }
                     listOfAllTasks.splice(listOfAllTasks.indexOf(listOfAllTasks[interv]),1);
                }
             }
        }
        else{
            var listOfAllTasks = allTask;
             for(var interv in listOfAllTasks){
                 if(listOfAllTasks[interv].Subject == allTaskIdx1){
                     if(!$A.util.isUndefinedOrNull(listOfAllTasks[interv].WhatId)){
                         let arr = component.get("v.removedInterventionId");
                         arr.push(listOfAllTasks[interv].Id);
                         component.set("v.removedInterventionId",arr);
                     }
                     listOfAllTasks.splice(listOfAllTasks.indexOf(listOfAllTasks[interv]),1);
                }
             }
        }
        
        //console.log('dhbwdh--' , JSON.stringify(allTask));
        //var evt=component.getEvent("intEvent");
        //evt.setParam("Intervention",allTask);
        //evt.fire();
        //   component.set('v.tasksList1',allTask);
        // console.log('hjkk' , JSON.stringify(component.get('v.tasksList1')));
    },
    editableBox : function(component){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus : function(component){
        component.set("v.editableBoxVal", false);
    },
    AddNotes : function(component) {
        component.set("v.openModalAddNotes" , true);
        component.set("v.openNotes" , true);
    },
    setUserId : function(component, event) {
        /*var value = event.getSource().get("v.value");
        component.set("v.userId",value);*/
        
        var assignedTo = event.getSource().get("v.value");
        var task =  component.get('v.task1');
        task['assignedTo'] = assignedTo;
        component.set('v.task1',task);
        console.log('task asigned' , JSON.stringify(component.get("v.task1")));
        if(component.get('v.carePlan')){
            var cmpEvent = component.getEvent("InterventionTopEvent"); 
            cmpEvent.setParams({"InterventionJSON" : component.get("v.task1")}); 
            cmpEvent.fire();
        }
    },
    AccountEventInterv : function(component, event) {
        var message = event.getParam("Id"); 
        component.set("v.recordVal", message);  
        
    }
})