({
    helperMethod : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        
        if(!($A.util.isUndefinedOrNull(strtProcedureTime)))
        {
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                valid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
          
            if((dte.setDate(dte.getDate()) >today))
            {
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                valid = false;
                console.log('ss');
            }
            else 
            {
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        else if($A.util.isUndefinedOrNull(endProcedureTime))
        {
            valid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
        return valid;
    },
    fetchRelatedNotes: function(component, event, helper,accountId) {
        var action = component.get("c.getRelatedNotes");
        action.setParams({ accountId : accountId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.allRelateNote",result);
            }
        });
        $A.enqueueAction(action);
    },
    getAllUser: function(component) {
        var action = component.get("c.getAllUser");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            console.log('users' + JSON.stringify(response.getReturnValue()));
            component.set("v.AllUsers", res);
        });
        $A.enqueueAction(action);
        
    },
    
    getNameSpaceOrgWide: function(component) {
        var action = component.get("c.fetchNameSpace");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('name space org wide' + JSON.stringify(response.getReturnValue()));
                component.set("v.NameSpaceOrgWide", res);
            }
        });
        $A.enqueueAction(action);
        
    },
     goalSectionReplica  : function(component) {
        /*var goalIdx = component.get("v.goalIdx");
        var goalId = component.get("v.problemId");
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }*/
        
      /*   if(! $A.util.isUndefinedOrNull(goalId)){  
        var goalFirstCallBack = component.get("v.goalFirstCallBack");

            var action = component.get("c.getTasks");                
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue();     
                    console.log('listOfTasks1 '+JSON.stringify(listOfTasks));
                    var goal = {'listOfTask' : listOfTasks};
                     component.set("v.goal",goal);
                    //goal['listOfTask'] = listOfTasks;
                  
                    for(var goalRec in goal['listOfTask']){
                         goal['listOfTask'][goalRec]['endDate'] = goal['endDate'];
                        } 
                    component.set('v.tasksList',goal);
                    component.set('v.goal',goal);
                    component.set("v.goalFirstCallBack",false);
                    //helper.observationSectionReplica(component, event, helper);
                    
                    
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
        
         }*/
    },
})