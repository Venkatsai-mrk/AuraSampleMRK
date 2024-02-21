({
    doInit : function(component) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('userId '+userId);
        component.set('v.userId', userId);
        var task =  component.get('v.task1');
        task['assignedTo'] = userId;
        component.set('v.task1',task);
        console.log('task asigned do init' , JSON.stringify(component.get("v.task1")));
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
        var header = component.find("intervHeader");
        $A.util.removeClass(header, 'slds-show');
        $A.util.addClass(header, 'slds-hide');
        var acc = component.find("taskId1");
        var allTaskIdx1 = component.get("v.taskIdx1");
        console.log('allTaskIdx1' , allTaskIdx1);
        var intervId1 = component.get("v.taskId1");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        
        if(component.get('v.carePlan')){
            console.log('inside if');
            var allTask =  component.get('v.task1');
             console.log('allTask inside if' , allTask);
            //var listOfAllTasks = allTask;  
            //listOfAllTasks.splice(allTaskIdx1 , 1);
            var evt=component.getEvent("intEvent");
            evt.setParam("Intervention",allTask);
            evt.fire();
        }
        else{
            console.log('inside else');
            let allTask =  component.get('v.tasksList1');
            console.log('allTask inside else' , allTask);
            var listOfAllTasks = allTask.listOfIntervention;
            for(var interv in listOfAllTasks){
                if(listOfAllTasks[interv].Id == intervId1){
                    listOfAllTasks.splice(listOfAllTasks.indexOf(listOfAllTasks[interv]),1);
                    console.log('dhbwdh--' , JSON.stringify(allTask));
                }
            }
        }
        
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