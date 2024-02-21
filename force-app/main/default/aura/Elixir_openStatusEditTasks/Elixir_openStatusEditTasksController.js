({
	doInit : function(component, event, helper) {
		
    },    
    dueDate : function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var acc = component.find("taskId");
        var taskIdx = component.get("v.taskIdx");
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfIntervention;  
        var buttonName = event.getSource().get("v.name");
        var dueDate = event.getSource().get("v.value");
        if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace+'Care_Plan_Template_Intervention__c'])){
           //No Action Taken
         }else{
            listOfTasks[taskIdx]['Action'] = 'UPDATE';
         }
        if(buttonName == 'input1')
        listOfTasks[taskIdx]['ActivityDate'] = dueDate;
        
        if(buttonName == 'input2')
        listOfTasks[taskIdx][nameSpace+'Target_Date__c'] = dueDate;
        
        if(buttonName == 'input3')
        listOfTasks[taskIdx][nameSpace+'Resolved_Date__c'] = dueDate;
        
        if(buttonName == 'input4')
        listOfTasks[taskIdx][nameSpace+'Duration__c'] = dueDate;
        
        if(buttonName == 'input5')
        listOfTasks[taskIdx][nameSpace+'Frequency__c'] = dueDate;
        
        component.set('v.tasksList',task);
      //  console.log('All tasks ',JSON.stringify(component.get('v.tasksList')));
    }, 
    
    
     removeSection :	function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var acc = component.find("taskId");
        var taskIdx = component.get("v.taskIdx");
       $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfIntervention;  
        if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace+'Care_Plan_Template_Intervention__c'])){
            listOfTasks.splice(taskIdx,1);
      }else{
            listOfTasks[taskIdx]['Action'] = 'DELETE';
      }
        
        component.set('v.tasksList',task);
    },
    editableBox : function(component,event,helper){
        component.set("v.editableBoxVal", true);
    },
    outsideFocus1 : function(component,event,helper){
        component.set("v.editableBoxVal", false);
         var nameSpace = 'ElixirSuite__';
        var dueDate = event.getSource().get("v.value");
        var taskIdx = component.get("v.taskIdx");
        var task =  component.get('v.tasksList');
        var listOfTasks = task.listOfIntervention;  
         if($A.util.isUndefinedOrNull(listOfTasks[taskIdx][nameSpace+'Care_Plan_Template_Intervention__c'])){
         }else{
            listOfTasks[taskIdx]['Action'] = 'UPDATE';
         }
        component.set('v.tasksList',task);
    },
})